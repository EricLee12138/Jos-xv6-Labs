
obj/user/testfdsharing.debug：     文件格式 elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 c0 22 80 00       	push   $0x8022c0
  800043:	e8 61 18 00 00       	call   8018a9 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 c5 22 80 00       	push   $0x8022c5
  800057:	6a 0c                	push   $0xc
  800059:	68 d3 22 80 00       	push   $0x8022d3
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 16 15 00 00       	call   801584 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 2e 14 00 00       	call   8014af <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 e8 22 80 00       	push   $0x8022e8
  800090:	6a 0f                	push   $0xf
  800092:	68 d3 22 80 00       	push   $0x8022d3
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 ed 0e 00 00       	call   800f8e <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 f2 22 80 00       	push   $0x8022f2
  8000ad:	6a 12                	push   $0x12
  8000af:	68 d3 22 80 00       	push   $0x8022d3
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 b8 14 00 00       	call   801584 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 30 23 80 00 	movl   $0x802330,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 c4 13 00 00       	call   8014af <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 74 23 80 00       	push   $0x802374
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 d3 22 80 00       	push   $0x8022d3
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 e7 09 00 00       	call   800b02 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 a0 23 80 00       	push   $0x8023a0
  80012a:	6a 19                	push   $0x19
  80012c:	68 d3 22 80 00       	push   $0x8022d3
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 fb 22 80 00       	push   $0x8022fb
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 36 14 00 00       	call   801584 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 8c 11 00 00       	call   8012e2 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 42 1b 00 00       	call   801ca9 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 35 13 00 00       	call   8014af <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 d8 23 80 00       	push   $0x8023d8
  80018b:	6a 21                	push   $0x21
  80018d:	68 d3 22 80 00       	push   $0x8022d3
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 14 23 80 00       	push   $0x802314
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 36 11 00 00       	call   8012e2 <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 f2 0a 00 00       	call   800cba <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 04 11 00 00       	call   80130d <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 66 0a 00 00       	call   800c79 <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 8f 0a 00 00       	call   800cba <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 08 24 80 00       	push   $0x802408
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 12 23 80 00 	movl   $0x802312,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 ae 09 00 00       	call   800c3c <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 1a 01 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 53 09 00 00       	call   800c3c <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 c7 1c 00 00       	call   802020 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 b4 1d 00 00       	call   802150 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 2b 24 80 00 	movsbl 0x80242b(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003be:	8b 10                	mov    (%eax),%edx
  8003c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c3:	73 0a                	jae    8003cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c8:	89 08                	mov    %ecx,(%eax)
  8003ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cd:	88 02                	mov    %al,(%edx)
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003da:	50                   	push   %eax
  8003db:	ff 75 10             	pushl  0x10(%ebp)
  8003de:	ff 75 0c             	pushl  0xc(%ebp)
  8003e1:	ff 75 08             	pushl  0x8(%ebp)
  8003e4:	e8 05 00 00 00       	call   8003ee <vprintfmt>
	va_end(ap);
}
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 2c             	sub    $0x2c,%esp
  8003f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800400:	eb 12                	jmp    800414 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800402:	85 c0                	test   %eax,%eax
  800404:	0f 84 42 04 00 00    	je     80084c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	53                   	push   %ebx
  80040e:	50                   	push   %eax
  80040f:	ff d6                	call   *%esi
  800411:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800414:	83 c7 01             	add    $0x1,%edi
  800417:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80041b:	83 f8 25             	cmp    $0x25,%eax
  80041e:	75 e2                	jne    800402 <vprintfmt+0x14>
  800420:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800424:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80042b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800432:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800439:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043e:	eb 07                	jmp    800447 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800443:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8d 47 01             	lea    0x1(%edi),%eax
  80044a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044d:	0f b6 07             	movzbl (%edi),%eax
  800450:	0f b6 d0             	movzbl %al,%edx
  800453:	83 e8 23             	sub    $0x23,%eax
  800456:	3c 55                	cmp    $0x55,%al
  800458:	0f 87 d3 03 00 00    	ja     800831 <vprintfmt+0x443>
  80045e:	0f b6 c0             	movzbl %al,%eax
  800461:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046f:	eb d6                	jmp    800447 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800483:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800486:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800489:	83 f9 09             	cmp    $0x9,%ecx
  80048c:	77 3f                	ja     8004cd <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800491:	eb e9                	jmp    80047c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8d 40 04             	lea    0x4(%eax),%eax
  8004a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a7:	eb 2a                	jmp    8004d3 <vprintfmt+0xe5>
  8004a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b3:	0f 49 d0             	cmovns %eax,%edx
  8004b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bc:	eb 89                	jmp    800447 <vprintfmt+0x59>
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c8:	e9 7a ff ff ff       	jmp    800447 <vprintfmt+0x59>
  8004cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	0f 89 6a ff ff ff    	jns    800447 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ea:	e9 58 ff ff ff       	jmp    800447 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f5:	e9 4d ff ff ff       	jmp    800447 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 78 04             	lea    0x4(%eax),%edi
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	53                   	push   %ebx
  800504:	ff 30                	pushl  (%eax)
  800506:	ff d6                	call   *%esi
			break;
  800508:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800511:	e9 fe fe ff ff       	jmp    800414 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 78 04             	lea    0x4(%eax),%edi
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	99                   	cltd   
  80051f:	31 d0                	xor    %edx,%eax
  800521:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800523:	83 f8 0f             	cmp    $0xf,%eax
  800526:	7f 0b                	jg     800533 <vprintfmt+0x145>
  800528:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  80052f:	85 d2                	test   %edx,%edx
  800531:	75 1b                	jne    80054e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800533:	50                   	push   %eax
  800534:	68 43 24 80 00       	push   $0x802443
  800539:	53                   	push   %ebx
  80053a:	56                   	push   %esi
  80053b:	e8 91 fe ff ff       	call   8003d1 <printfmt>
  800540:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800543:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800549:	e9 c6 fe ff ff       	jmp    800414 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80054e:	52                   	push   %edx
  80054f:	68 5d 28 80 00       	push   $0x80285d
  800554:	53                   	push   %ebx
  800555:	56                   	push   %esi
  800556:	e8 76 fe ff ff       	call   8003d1 <printfmt>
  80055b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800564:	e9 ab fe ff ff       	jmp    800414 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	83 c0 04             	add    $0x4,%eax
  80056f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800577:	85 ff                	test   %edi,%edi
  800579:	b8 3c 24 80 00       	mov    $0x80243c,%eax
  80057e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800581:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800585:	0f 8e 94 00 00 00    	jle    80061f <vprintfmt+0x231>
  80058b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058f:	0f 84 98 00 00 00    	je     80062d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	ff 75 d0             	pushl  -0x30(%ebp)
  80059b:	57                   	push   %edi
  80059c:	e8 33 03 00 00       	call   8008d4 <strnlen>
  8005a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a4:	29 c1                	sub    %eax,%ecx
  8005a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b8:	eb 0f                	jmp    8005c9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ef 01             	sub    $0x1,%edi
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	7f ed                	jg     8005ba <vprintfmt+0x1cc>
  8005cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005d3:	85 c9                	test   %ecx,%ecx
  8005d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005da:	0f 49 c1             	cmovns %ecx,%eax
  8005dd:	29 c1                	sub    %eax,%ecx
  8005df:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	89 cb                	mov    %ecx,%ebx
  8005ea:	eb 4d                	jmp    800639 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f0:	74 1b                	je     80060d <vprintfmt+0x21f>
  8005f2:	0f be c0             	movsbl %al,%eax
  8005f5:	83 e8 20             	sub    $0x20,%eax
  8005f8:	83 f8 5e             	cmp    $0x5e,%eax
  8005fb:	76 10                	jbe    80060d <vprintfmt+0x21f>
					putch('?', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	ff 75 0c             	pushl  0xc(%ebp)
  800603:	6a 3f                	push   $0x3f
  800605:	ff 55 08             	call   *0x8(%ebp)
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	eb 0d                	jmp    80061a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	ff 75 0c             	pushl  0xc(%ebp)
  800613:	52                   	push   %edx
  800614:	ff 55 08             	call   *0x8(%ebp)
  800617:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061a:	83 eb 01             	sub    $0x1,%ebx
  80061d:	eb 1a                	jmp    800639 <vprintfmt+0x24b>
  80061f:	89 75 08             	mov    %esi,0x8(%ebp)
  800622:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800625:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800628:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062b:	eb 0c                	jmp    800639 <vprintfmt+0x24b>
  80062d:	89 75 08             	mov    %esi,0x8(%ebp)
  800630:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800633:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800636:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800639:	83 c7 01             	add    $0x1,%edi
  80063c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800640:	0f be d0             	movsbl %al,%edx
  800643:	85 d2                	test   %edx,%edx
  800645:	74 23                	je     80066a <vprintfmt+0x27c>
  800647:	85 f6                	test   %esi,%esi
  800649:	78 a1                	js     8005ec <vprintfmt+0x1fe>
  80064b:	83 ee 01             	sub    $0x1,%esi
  80064e:	79 9c                	jns    8005ec <vprintfmt+0x1fe>
  800650:	89 df                	mov    %ebx,%edi
  800652:	8b 75 08             	mov    0x8(%ebp),%esi
  800655:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800658:	eb 18                	jmp    800672 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 20                	push   $0x20
  800660:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	eb 08                	jmp    800672 <vprintfmt+0x284>
  80066a:	89 df                	mov    %ebx,%edi
  80066c:	8b 75 08             	mov    0x8(%ebp),%esi
  80066f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800672:	85 ff                	test   %edi,%edi
  800674:	7f e4                	jg     80065a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800676:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067f:	e9 90 fd ff ff       	jmp    800414 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800684:	83 f9 01             	cmp    $0x1,%ecx
  800687:	7e 19                	jle    8006a2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8b 50 04             	mov    0x4(%eax),%edx
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 40 08             	lea    0x8(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a0:	eb 38                	jmp    8006da <vprintfmt+0x2ec>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	74 1b                	je     8006c1 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ae:	89 c1                	mov    %eax,%ecx
  8006b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 40 04             	lea    0x4(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bf:	eb 19                	jmp    8006da <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c9:	89 c1                	mov    %eax,%ecx
  8006cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 40 04             	lea    0x4(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e9:	0f 89 0e 01 00 00    	jns    8007fd <vprintfmt+0x40f>
				putch('-', putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	6a 2d                	push   $0x2d
  8006f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006fd:	f7 da                	neg    %edx
  8006ff:	83 d1 00             	adc    $0x0,%ecx
  800702:	f7 d9                	neg    %ecx
  800704:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800707:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070c:	e9 ec 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800711:	83 f9 01             	cmp    $0x1,%ecx
  800714:	7e 18                	jle    80072e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8b 10                	mov    (%eax),%edx
  80071b:	8b 48 04             	mov    0x4(%eax),%ecx
  80071e:	8d 40 08             	lea    0x8(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800724:	b8 0a 00 00 00       	mov    $0xa,%eax
  800729:	e9 cf 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80072e:	85 c9                	test   %ecx,%ecx
  800730:	74 1a                	je     80074c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	8d 40 04             	lea    0x4(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800742:	b8 0a 00 00 00       	mov    $0xa,%eax
  800747:	e9 b1 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8b 10                	mov    (%eax),%edx
  800751:	b9 00 00 00 00       	mov    $0x0,%ecx
  800756:	8d 40 04             	lea    0x4(%eax),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80075c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800761:	e9 97 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 58                	push   $0x58
  80076c:	ff d6                	call   *%esi
			putch('X', putdat);
  80076e:	83 c4 08             	add    $0x8,%esp
  800771:	53                   	push   %ebx
  800772:	6a 58                	push   $0x58
  800774:	ff d6                	call   *%esi
			putch('X', putdat);
  800776:	83 c4 08             	add    $0x8,%esp
  800779:	53                   	push   %ebx
  80077a:	6a 58                	push   $0x58
  80077c:	ff d6                	call   *%esi
			break;
  80077e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800784:	e9 8b fc ff ff       	jmp    800414 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	53                   	push   %ebx
  80078d:	6a 30                	push   $0x30
  80078f:	ff d6                	call   *%esi
			putch('x', putdat);
  800791:	83 c4 08             	add    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 78                	push   $0x78
  800797:	ff d6                	call   *%esi
			num = (unsigned long long)
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8b 10                	mov    (%eax),%edx
  80079e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a6:	8d 40 04             	lea    0x4(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ac:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007b1:	eb 4a                	jmp    8007fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b3:	83 f9 01             	cmp    $0x1,%ecx
  8007b6:	7e 15                	jle    8007cd <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8b 10                	mov    (%eax),%edx
  8007bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c0:	8d 40 08             	lea    0x8(%eax),%eax
  8007c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007cb:	eb 30                	jmp    8007fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007cd:	85 c9                	test   %ecx,%ecx
  8007cf:	74 17                	je     8007e8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8b 10                	mov    (%eax),%edx
  8007d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007db:	8d 40 04             	lea    0x4(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007e1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e6:	eb 15                	jmp    8007fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007f8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fd:	83 ec 0c             	sub    $0xc,%esp
  800800:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800804:	57                   	push   %edi
  800805:	ff 75 e0             	pushl  -0x20(%ebp)
  800808:	50                   	push   %eax
  800809:	51                   	push   %ecx
  80080a:	52                   	push   %edx
  80080b:	89 da                	mov    %ebx,%edx
  80080d:	89 f0                	mov    %esi,%eax
  80080f:	e8 f1 fa ff ff       	call   800305 <printnum>
			break;
  800814:	83 c4 20             	add    $0x20,%esp
  800817:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081a:	e9 f5 fb ff ff       	jmp    800414 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	53                   	push   %ebx
  800823:	52                   	push   %edx
  800824:	ff d6                	call   *%esi
			break;
  800826:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800829:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80082c:	e9 e3 fb ff ff       	jmp    800414 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800831:	83 ec 08             	sub    $0x8,%esp
  800834:	53                   	push   %ebx
  800835:	6a 25                	push   $0x25
  800837:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	eb 03                	jmp    800841 <vprintfmt+0x453>
  80083e:	83 ef 01             	sub    $0x1,%edi
  800841:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800845:	75 f7                	jne    80083e <vprintfmt+0x450>
  800847:	e9 c8 fb ff ff       	jmp    800414 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80084c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5f                   	pop    %edi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	83 ec 18             	sub    $0x18,%esp
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800860:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800863:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800867:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800871:	85 c0                	test   %eax,%eax
  800873:	74 26                	je     80089b <vsnprintf+0x47>
  800875:	85 d2                	test   %edx,%edx
  800877:	7e 22                	jle    80089b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800879:	ff 75 14             	pushl  0x14(%ebp)
  80087c:	ff 75 10             	pushl  0x10(%ebp)
  80087f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800882:	50                   	push   %eax
  800883:	68 b4 03 80 00       	push   $0x8003b4
  800888:	e8 61 fb ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800890:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800893:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	eb 05                	jmp    8008a0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ab:	50                   	push   %eax
  8008ac:	ff 75 10             	pushl  0x10(%ebp)
  8008af:	ff 75 0c             	pushl  0xc(%ebp)
  8008b2:	ff 75 08             	pushl  0x8(%ebp)
  8008b5:	e8 9a ff ff ff       	call   800854 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c7:	eb 03                	jmp    8008cc <strlen+0x10>
		n++;
  8008c9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d0:	75 f7                	jne    8008c9 <strlen+0xd>
		n++;
	return n;
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008da:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	eb 03                	jmp    8008e7 <strnlen+0x13>
		n++;
  8008e4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e7:	39 c2                	cmp    %eax,%edx
  8008e9:	74 08                	je     8008f3 <strnlen+0x1f>
  8008eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ef:	75 f3                	jne    8008e4 <strnlen+0x10>
  8008f1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	53                   	push   %ebx
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ff:	89 c2                	mov    %eax,%edx
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090e:	84 db                	test   %bl,%bl
  800910:	75 ef                	jne    800901 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	53                   	push   %ebx
  800919:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091c:	53                   	push   %ebx
  80091d:	e8 9a ff ff ff       	call   8008bc <strlen>
  800922:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800925:	ff 75 0c             	pushl  0xc(%ebp)
  800928:	01 d8                	add    %ebx,%eax
  80092a:	50                   	push   %eax
  80092b:	e8 c5 ff ff ff       	call   8008f5 <strcpy>
	return dst;
}
  800930:	89 d8                	mov    %ebx,%eax
  800932:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 75 08             	mov    0x8(%ebp),%esi
  80093f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800942:	89 f3                	mov    %esi,%ebx
  800944:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800947:	89 f2                	mov    %esi,%edx
  800949:	eb 0f                	jmp    80095a <strncpy+0x23>
		*dst++ = *src;
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	0f b6 01             	movzbl (%ecx),%eax
  800951:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800954:	80 39 01             	cmpb   $0x1,(%ecx)
  800957:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095a:	39 da                	cmp    %ebx,%edx
  80095c:	75 ed                	jne    80094b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095e:	89 f0                	mov    %esi,%eax
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 75 08             	mov    0x8(%ebp),%esi
  80096c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096f:	8b 55 10             	mov    0x10(%ebp),%edx
  800972:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800974:	85 d2                	test   %edx,%edx
  800976:	74 21                	je     800999 <strlcpy+0x35>
  800978:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097c:	89 f2                	mov    %esi,%edx
  80097e:	eb 09                	jmp    800989 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800980:	83 c2 01             	add    $0x1,%edx
  800983:	83 c1 01             	add    $0x1,%ecx
  800986:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800989:	39 c2                	cmp    %eax,%edx
  80098b:	74 09                	je     800996 <strlcpy+0x32>
  80098d:	0f b6 19             	movzbl (%ecx),%ebx
  800990:	84 db                	test   %bl,%bl
  800992:	75 ec                	jne    800980 <strlcpy+0x1c>
  800994:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800996:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800999:	29 f0                	sub    %esi,%eax
}
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a8:	eb 06                	jmp    8009b0 <strcmp+0x11>
		p++, q++;
  8009aa:	83 c1 01             	add    $0x1,%ecx
  8009ad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b0:	0f b6 01             	movzbl (%ecx),%eax
  8009b3:	84 c0                	test   %al,%al
  8009b5:	74 04                	je     8009bb <strcmp+0x1c>
  8009b7:	3a 02                	cmp    (%edx),%al
  8009b9:	74 ef                	je     8009aa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bb:	0f b6 c0             	movzbl %al,%eax
  8009be:	0f b6 12             	movzbl (%edx),%edx
  8009c1:	29 d0                	sub    %edx,%eax
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	89 c3                	mov    %eax,%ebx
  8009d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d4:	eb 06                	jmp    8009dc <strncmp+0x17>
		n--, p++, q++;
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009dc:	39 d8                	cmp    %ebx,%eax
  8009de:	74 15                	je     8009f5 <strncmp+0x30>
  8009e0:	0f b6 08             	movzbl (%eax),%ecx
  8009e3:	84 c9                	test   %cl,%cl
  8009e5:	74 04                	je     8009eb <strncmp+0x26>
  8009e7:	3a 0a                	cmp    (%edx),%cl
  8009e9:	74 eb                	je     8009d6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009eb:	0f b6 00             	movzbl (%eax),%eax
  8009ee:	0f b6 12             	movzbl (%edx),%edx
  8009f1:	29 d0                	sub    %edx,%eax
  8009f3:	eb 05                	jmp    8009fa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a07:	eb 07                	jmp    800a10 <strchr+0x13>
		if (*s == c)
  800a09:	38 ca                	cmp    %cl,%dl
  800a0b:	74 0f                	je     800a1c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0d:	83 c0 01             	add    $0x1,%eax
  800a10:	0f b6 10             	movzbl (%eax),%edx
  800a13:	84 d2                	test   %dl,%dl
  800a15:	75 f2                	jne    800a09 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a28:	eb 03                	jmp    800a2d <strfind+0xf>
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a30:	38 ca                	cmp    %cl,%dl
  800a32:	74 04                	je     800a38 <strfind+0x1a>
  800a34:	84 d2                	test   %dl,%dl
  800a36:	75 f2                	jne    800a2a <strfind+0xc>
			break;
	return (char *) s;
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a46:	85 c9                	test   %ecx,%ecx
  800a48:	74 36                	je     800a80 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a50:	75 28                	jne    800a7a <memset+0x40>
  800a52:	f6 c1 03             	test   $0x3,%cl
  800a55:	75 23                	jne    800a7a <memset+0x40>
		c &= 0xFF;
  800a57:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5b:	89 d3                	mov    %edx,%ebx
  800a5d:	c1 e3 08             	shl    $0x8,%ebx
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	c1 e6 18             	shl    $0x18,%esi
  800a65:	89 d0                	mov    %edx,%eax
  800a67:	c1 e0 10             	shl    $0x10,%eax
  800a6a:	09 f0                	or     %esi,%eax
  800a6c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6e:	89 d8                	mov    %ebx,%eax
  800a70:	09 d0                	or     %edx,%eax
  800a72:	c1 e9 02             	shr    $0x2,%ecx
  800a75:	fc                   	cld    
  800a76:	f3 ab                	rep stos %eax,%es:(%edi)
  800a78:	eb 06                	jmp    800a80 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	fc                   	cld    
  800a7e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a80:	89 f8                	mov    %edi,%eax
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a95:	39 c6                	cmp    %eax,%esi
  800a97:	73 35                	jae    800ace <memmove+0x47>
  800a99:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9c:	39 d0                	cmp    %edx,%eax
  800a9e:	73 2e                	jae    800ace <memmove+0x47>
		s += n;
		d += n;
  800aa0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa3:	89 d6                	mov    %edx,%esi
  800aa5:	09 fe                	or     %edi,%esi
  800aa7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aad:	75 13                	jne    800ac2 <memmove+0x3b>
  800aaf:	f6 c1 03             	test   $0x3,%cl
  800ab2:	75 0e                	jne    800ac2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab4:	83 ef 04             	sub    $0x4,%edi
  800ab7:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aba:	c1 e9 02             	shr    $0x2,%ecx
  800abd:	fd                   	std    
  800abe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac0:	eb 09                	jmp    800acb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac2:	83 ef 01             	sub    $0x1,%edi
  800ac5:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac8:	fd                   	std    
  800ac9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acb:	fc                   	cld    
  800acc:	eb 1d                	jmp    800aeb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ace:	89 f2                	mov    %esi,%edx
  800ad0:	09 c2                	or     %eax,%edx
  800ad2:	f6 c2 03             	test   $0x3,%dl
  800ad5:	75 0f                	jne    800ae6 <memmove+0x5f>
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 0a                	jne    800ae6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800adc:	c1 e9 02             	shr    $0x2,%ecx
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	fc                   	cld    
  800ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae4:	eb 05                	jmp    800aeb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae6:	89 c7                	mov    %eax,%edi
  800ae8:	fc                   	cld    
  800ae9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af2:	ff 75 10             	pushl  0x10(%ebp)
  800af5:	ff 75 0c             	pushl  0xc(%ebp)
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 87 ff ff ff       	call   800a87 <memmove>
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0d:	89 c6                	mov    %eax,%esi
  800b0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b12:	eb 1a                	jmp    800b2e <memcmp+0x2c>
		if (*s1 != *s2)
  800b14:	0f b6 08             	movzbl (%eax),%ecx
  800b17:	0f b6 1a             	movzbl (%edx),%ebx
  800b1a:	38 d9                	cmp    %bl,%cl
  800b1c:	74 0a                	je     800b28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1e:	0f b6 c1             	movzbl %cl,%eax
  800b21:	0f b6 db             	movzbl %bl,%ebx
  800b24:	29 d8                	sub    %ebx,%eax
  800b26:	eb 0f                	jmp    800b37 <memcmp+0x35>
		s1++, s2++;
  800b28:	83 c0 01             	add    $0x1,%eax
  800b2b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2e:	39 f0                	cmp    %esi,%eax
  800b30:	75 e2                	jne    800b14 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	53                   	push   %ebx
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b42:	89 c1                	mov    %eax,%ecx
  800b44:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4b:	eb 0a                	jmp    800b57 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4d:	0f b6 10             	movzbl (%eax),%edx
  800b50:	39 da                	cmp    %ebx,%edx
  800b52:	74 07                	je     800b5b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	39 c8                	cmp    %ecx,%eax
  800b59:	72 f2                	jb     800b4d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6a:	eb 03                	jmp    800b6f <strtol+0x11>
		s++;
  800b6c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6f:	0f b6 01             	movzbl (%ecx),%eax
  800b72:	3c 20                	cmp    $0x20,%al
  800b74:	74 f6                	je     800b6c <strtol+0xe>
  800b76:	3c 09                	cmp    $0x9,%al
  800b78:	74 f2                	je     800b6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7a:	3c 2b                	cmp    $0x2b,%al
  800b7c:	75 0a                	jne    800b88 <strtol+0x2a>
		s++;
  800b7e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b81:	bf 00 00 00 00       	mov    $0x0,%edi
  800b86:	eb 11                	jmp    800b99 <strtol+0x3b>
  800b88:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8d:	3c 2d                	cmp    $0x2d,%al
  800b8f:	75 08                	jne    800b99 <strtol+0x3b>
		s++, neg = 1;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b9f:	75 15                	jne    800bb6 <strtol+0x58>
  800ba1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba4:	75 10                	jne    800bb6 <strtol+0x58>
  800ba6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800baa:	75 7c                	jne    800c28 <strtol+0xca>
		s += 2, base = 16;
  800bac:	83 c1 02             	add    $0x2,%ecx
  800baf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb4:	eb 16                	jmp    800bcc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb6:	85 db                	test   %ebx,%ebx
  800bb8:	75 12                	jne    800bcc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbf:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc2:	75 08                	jne    800bcc <strtol+0x6e>
		s++, base = 8;
  800bc4:	83 c1 01             	add    $0x1,%ecx
  800bc7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd4:	0f b6 11             	movzbl (%ecx),%edx
  800bd7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bda:	89 f3                	mov    %esi,%ebx
  800bdc:	80 fb 09             	cmp    $0x9,%bl
  800bdf:	77 08                	ja     800be9 <strtol+0x8b>
			dig = *s - '0';
  800be1:	0f be d2             	movsbl %dl,%edx
  800be4:	83 ea 30             	sub    $0x30,%edx
  800be7:	eb 22                	jmp    800c0b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800be9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bec:	89 f3                	mov    %esi,%ebx
  800bee:	80 fb 19             	cmp    $0x19,%bl
  800bf1:	77 08                	ja     800bfb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bf3:	0f be d2             	movsbl %dl,%edx
  800bf6:	83 ea 57             	sub    $0x57,%edx
  800bf9:	eb 10                	jmp    800c0b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bfb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfe:	89 f3                	mov    %esi,%ebx
  800c00:	80 fb 19             	cmp    $0x19,%bl
  800c03:	77 16                	ja     800c1b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c05:	0f be d2             	movsbl %dl,%edx
  800c08:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0e:	7d 0b                	jge    800c1b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c10:	83 c1 01             	add    $0x1,%ecx
  800c13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c19:	eb b9                	jmp    800bd4 <strtol+0x76>

	if (endptr)
  800c1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1f:	74 0d                	je     800c2e <strtol+0xd0>
		*endptr = (char *) s;
  800c21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c24:	89 0e                	mov    %ecx,(%esi)
  800c26:	eb 06                	jmp    800c2e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c28:	85 db                	test   %ebx,%ebx
  800c2a:	74 98                	je     800bc4 <strtol+0x66>
  800c2c:	eb 9e                	jmp    800bcc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2e:	89 c2                	mov    %eax,%edx
  800c30:	f7 da                	neg    %edx
  800c32:	85 ff                	test   %edi,%edi
  800c34:	0f 45 c2             	cmovne %edx,%eax
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 c3                	mov    %eax,%ebx
  800c4f:	89 c7                	mov    %eax,%edi
  800c51:	89 c6                	mov    %eax,%esi
  800c53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c87:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 cb                	mov    %ecx,%ebx
  800c91:	89 cf                	mov    %ecx,%edi
  800c93:	89 ce                	mov    %ecx,%esi
  800c95:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7e 17                	jle    800cb2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	50                   	push   %eax
  800c9f:	6a 03                	push   $0x3
  800ca1:	68 1f 27 80 00       	push   $0x80271f
  800ca6:	6a 23                	push   $0x23
  800ca8:	68 3c 27 80 00       	push   $0x80273c
  800cad:	e8 66 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc5:	b8 02 00 00 00       	mov    $0x2,%eax
  800cca:	89 d1                	mov    %edx,%ecx
  800ccc:	89 d3                	mov    %edx,%ebx
  800cce:	89 d7                	mov    %edx,%edi
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_yield>:

void
sys_yield(void)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce9:	89 d1                	mov    %edx,%ecx
  800ceb:	89 d3                	mov    %edx,%ebx
  800ced:	89 d7                	mov    %edx,%edi
  800cef:	89 d6                	mov    %edx,%esi
  800cf1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	be 00 00 00 00       	mov    $0x0,%esi
  800d06:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d14:	89 f7                	mov    %esi,%edi
  800d16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 04                	push   $0x4
  800d22:	68 1f 27 80 00       	push   $0x80271f
  800d27:	6a 23                	push   $0x23
  800d29:	68 3c 27 80 00       	push   $0x80273c
  800d2e:	e8 e5 f4 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d44:	b8 05 00 00 00       	mov    $0x5,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d55:	8b 75 18             	mov    0x18(%ebp),%esi
  800d58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7e 17                	jle    800d75 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 05                	push   $0x5
  800d64:	68 1f 27 80 00       	push   $0x80271f
  800d69:	6a 23                	push   $0x23
  800d6b:	68 3c 27 80 00       	push   $0x80273c
  800d70:	e8 a3 f4 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 17                	jle    800db7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 06                	push   $0x6
  800da6:	68 1f 27 80 00       	push   $0x80271f
  800dab:	6a 23                	push   $0x23
  800dad:	68 3c 27 80 00       	push   $0x80273c
  800db2:	e8 61 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 17                	jle    800df9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 08                	push   $0x8
  800de8:	68 1f 27 80 00       	push   $0x80271f
  800ded:	6a 23                	push   $0x23
  800def:	68 3c 27 80 00       	push   $0x80273c
  800df4:	e8 1f f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	89 df                	mov    %ebx,%edi
  800e1c:	89 de                	mov    %ebx,%esi
  800e1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 17                	jle    800e3b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	50                   	push   %eax
  800e28:	6a 09                	push   $0x9
  800e2a:	68 1f 27 80 00       	push   $0x80271f
  800e2f:	6a 23                	push   $0x23
  800e31:	68 3c 27 80 00       	push   $0x80273c
  800e36:	e8 dd f3 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	89 de                	mov    %ebx,%esi
  800e60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e62:	85 c0                	test   %eax,%eax
  800e64:	7e 17                	jle    800e7d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	50                   	push   %eax
  800e6a:	6a 0a                	push   $0xa
  800e6c:	68 1f 27 80 00       	push   $0x80271f
  800e71:	6a 23                	push   $0x23
  800e73:	68 3c 27 80 00       	push   $0x80273c
  800e78:	e8 9b f3 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	be 00 00 00 00       	mov    $0x0,%esi
  800e90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 cb                	mov    %ecx,%ebx
  800ec0:	89 cf                	mov    %ecx,%edi
  800ec2:	89 ce                	mov    %ecx,%esi
  800ec4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	7e 17                	jle    800ee1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	50                   	push   %eax
  800ece:	6a 0d                	push   $0xd
  800ed0:	68 1f 27 80 00       	push   $0x80271f
  800ed5:	6a 23                	push   $0x23
  800ed7:	68 3c 27 80 00       	push   $0x80273c
  800edc:	e8 37 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 0c             	sub    $0xc,%esp
  800ef2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ef5:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800ef7:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800efa:	e8 bb fd ff ff       	call   800cba <sys_getenvid>
  800eff:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800f01:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800f07:	75 25                	jne    800f2e <pgfault+0x45>
  800f09:	89 d8                	mov    %ebx,%eax
  800f0b:	c1 e8 0c             	shr    $0xc,%eax
  800f0e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f15:	f6 c4 08             	test   $0x8,%ah
  800f18:	75 14                	jne    800f2e <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800f1a:	83 ec 04             	sub    $0x4,%esp
  800f1d:	68 4c 27 80 00       	push   $0x80274c
  800f22:	6a 1e                	push   $0x1e
  800f24:	68 71 27 80 00       	push   $0x802771
  800f29:	e8 ea f2 ff ff       	call   800218 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	6a 07                	push   $0x7
  800f33:	68 00 f0 7f 00       	push   $0x7ff000
  800f38:	56                   	push   %esi
  800f39:	e8 ba fd ff ff       	call   800cf8 <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800f3e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f44:	83 c4 0c             	add    $0xc,%esp
  800f47:	68 00 10 00 00       	push   $0x1000
  800f4c:	53                   	push   %ebx
  800f4d:	68 00 f0 7f 00       	push   $0x7ff000
  800f52:	e8 30 fb ff ff       	call   800a87 <memmove>

	sys_page_unmap(curenvid, addr);
  800f57:	83 c4 08             	add    $0x8,%esp
  800f5a:	53                   	push   %ebx
  800f5b:	56                   	push   %esi
  800f5c:	e8 1c fe ff ff       	call   800d7d <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800f61:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f68:	53                   	push   %ebx
  800f69:	56                   	push   %esi
  800f6a:	68 00 f0 7f 00       	push   $0x7ff000
  800f6f:	56                   	push   %esi
  800f70:	e8 c6 fd ff ff       	call   800d3b <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800f75:	83 c4 18             	add    $0x18,%esp
  800f78:	68 00 f0 7f 00       	push   $0x7ff000
  800f7d:	56                   	push   %esi
  800f7e:	e8 fa fd ff ff       	call   800d7d <sys_page_unmap>
}
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
  800f94:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  800f97:	e8 1e fd ff ff       	call   800cba <sys_getenvid>
	set_pgfault_handler(pgfault);
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	68 e9 0e 80 00       	push   $0x800ee9
  800fa4:	e8 d2 0e 00 00       	call   801e7b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fa9:	b8 07 00 00 00       	mov    $0x7,%eax
  800fae:	cd 30                	int    $0x30
  800fb0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800fb3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	79 12                	jns    800fcf <fork+0x41>
	    panic("fork error: %e", new_envid);
  800fbd:	50                   	push   %eax
  800fbe:	68 7c 27 80 00       	push   $0x80277c
  800fc3:	6a 75                	push   $0x75
  800fc5:	68 71 27 80 00       	push   $0x802771
  800fca:	e8 49 f2 ff ff       	call   800218 <_panic>
  800fcf:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  800fd4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800fd8:	75 1c                	jne    800ff6 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  800fda:	e8 db fc ff ff       	call   800cba <sys_getenvid>
  800fdf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fec:	a3 20 44 80 00       	mov    %eax,0x804420
  800ff1:	e9 27 01 00 00       	jmp    80111d <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800ff6:	89 f8                	mov    %edi,%eax
  800ff8:	c1 e8 16             	shr    $0x16,%eax
  800ffb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801002:	a8 01                	test   $0x1,%al
  801004:	0f 84 d2 00 00 00    	je     8010dc <fork+0x14e>
  80100a:	89 fb                	mov    %edi,%ebx
  80100c:	c1 eb 0c             	shr    $0xc,%ebx
  80100f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801016:	a8 01                	test   $0x1,%al
  801018:	0f 84 be 00 00 00    	je     8010dc <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  80101e:	e8 97 fc ff ff       	call   800cba <sys_getenvid>
  801023:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  801026:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  80102d:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  801032:	a8 02                	test   $0x2,%al
  801034:	75 1d                	jne    801053 <fork+0xc5>
  801036:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80103d:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  801042:	83 f8 01             	cmp    $0x1,%eax
  801045:	19 f6                	sbb    %esi,%esi
  801047:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  80104d:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  801053:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80105a:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  80105f:	b8 07 0e 00 00       	mov    $0xe07,%eax
  801064:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  801067:	89 d8                	mov    %ebx,%eax
  801069:	c1 e0 0c             	shl    $0xc,%eax
  80106c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	56                   	push   %esi
  801073:	50                   	push   %eax
  801074:	ff 75 dc             	pushl  -0x24(%ebp)
  801077:	50                   	push   %eax
  801078:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107b:	e8 bb fc ff ff       	call   800d3b <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  801080:	83 c4 20             	add    $0x20,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	79 12                	jns    801099 <fork+0x10b>
		panic("duppage error: %e", r);
  801087:	50                   	push   %eax
  801088:	68 8b 27 80 00       	push   $0x80278b
  80108d:	6a 4d                	push   $0x4d
  80108f:	68 71 27 80 00       	push   $0x802771
  801094:	e8 7f f1 ff ff       	call   800218 <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  801099:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010a0:	a8 02                	test   $0x2,%al
  8010a2:	75 0c                	jne    8010b0 <fork+0x122>
  8010a4:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010ab:	f6 c4 08             	test   $0x8,%ah
  8010ae:	74 2c                	je     8010dc <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	56                   	push   %esi
  8010b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010b7:	52                   	push   %edx
  8010b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010bb:	50                   	push   %eax
  8010bc:	52                   	push   %edx
  8010bd:	50                   	push   %eax
  8010be:	e8 78 fc ff ff       	call   800d3b <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  8010c3:	83 c4 20             	add    $0x20,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	79 12                	jns    8010dc <fork+0x14e>
			panic("duppage error: %e", r);
  8010ca:	50                   	push   %eax
  8010cb:	68 8b 27 80 00       	push   $0x80278b
  8010d0:	6a 53                	push   $0x53
  8010d2:	68 71 27 80 00       	push   $0x802771
  8010d7:	e8 3c f1 ff ff       	call   800218 <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  8010dc:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8010e2:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  8010e8:	0f 85 08 ff ff ff    	jne    800ff6 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	6a 07                	push   $0x7
  8010f3:	68 00 f0 bf ee       	push   $0xeebff000
  8010f8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8010fb:	56                   	push   %esi
  8010fc:	e8 f7 fb ff ff       	call   800cf8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	68 c0 1e 80 00       	push   $0x801ec0
  801109:	56                   	push   %esi
  80110a:	e8 34 fd ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  80110f:	83 c4 08             	add    $0x8,%esp
  801112:	6a 02                	push   $0x2
  801114:	56                   	push   %esi
  801115:	e8 a5 fc ff ff       	call   800dbf <sys_env_set_status>
  80111a:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  80111d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <sfork>:

// Challenge!
int
sfork(void)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80112e:	68 9d 27 80 00       	push   $0x80279d
  801133:	68 8b 00 00 00       	push   $0x8b
  801138:	68 71 27 80 00       	push   $0x802771
  80113d:	e8 d6 f0 ff ff       	call   800218 <_panic>

00801142 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	05 00 00 00 30       	add    $0x30000000,%eax
  80114d:	c1 e8 0c             	shr    $0xc,%eax
}
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801155:	8b 45 08             	mov    0x8(%ebp),%eax
  801158:	05 00 00 00 30       	add    $0x30000000,%eax
  80115d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801162:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801174:	89 c2                	mov    %eax,%edx
  801176:	c1 ea 16             	shr    $0x16,%edx
  801179:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801180:	f6 c2 01             	test   $0x1,%dl
  801183:	74 11                	je     801196 <fd_alloc+0x2d>
  801185:	89 c2                	mov    %eax,%edx
  801187:	c1 ea 0c             	shr    $0xc,%edx
  80118a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801191:	f6 c2 01             	test   $0x1,%dl
  801194:	75 09                	jne    80119f <fd_alloc+0x36>
			*fd_store = fd;
  801196:	89 01                	mov    %eax,(%ecx)
			return 0;
  801198:	b8 00 00 00 00       	mov    $0x0,%eax
  80119d:	eb 17                	jmp    8011b6 <fd_alloc+0x4d>
  80119f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011a4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a9:	75 c9                	jne    801174 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011ab:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011b1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011be:	83 f8 1f             	cmp    $0x1f,%eax
  8011c1:	77 36                	ja     8011f9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011c3:	c1 e0 0c             	shl    $0xc,%eax
  8011c6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011cb:	89 c2                	mov    %eax,%edx
  8011cd:	c1 ea 16             	shr    $0x16,%edx
  8011d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d7:	f6 c2 01             	test   $0x1,%dl
  8011da:	74 24                	je     801200 <fd_lookup+0x48>
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	c1 ea 0c             	shr    $0xc,%edx
  8011e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e8:	f6 c2 01             	test   $0x1,%dl
  8011eb:	74 1a                	je     801207 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f0:	89 02                	mov    %eax,(%edx)
	return 0;
  8011f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f7:	eb 13                	jmp    80120c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fe:	eb 0c                	jmp    80120c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801200:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801205:	eb 05                	jmp    80120c <fd_lookup+0x54>
  801207:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	83 ec 08             	sub    $0x8,%esp
  801214:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801217:	ba 34 28 80 00       	mov    $0x802834,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80121c:	eb 13                	jmp    801231 <dev_lookup+0x23>
  80121e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801221:	39 08                	cmp    %ecx,(%eax)
  801223:	75 0c                	jne    801231 <dev_lookup+0x23>
			*dev = devtab[i];
  801225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801228:	89 01                	mov    %eax,(%ecx)
			return 0;
  80122a:	b8 00 00 00 00       	mov    $0x0,%eax
  80122f:	eb 2e                	jmp    80125f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801231:	8b 02                	mov    (%edx),%eax
  801233:	85 c0                	test   %eax,%eax
  801235:	75 e7                	jne    80121e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801237:	a1 20 44 80 00       	mov    0x804420,%eax
  80123c:	8b 40 48             	mov    0x48(%eax),%eax
  80123f:	83 ec 04             	sub    $0x4,%esp
  801242:	51                   	push   %ecx
  801243:	50                   	push   %eax
  801244:	68 b4 27 80 00       	push   $0x8027b4
  801249:	e8 a3 f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  80124e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801251:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80125f:	c9                   	leave  
  801260:	c3                   	ret    

00801261 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	56                   	push   %esi
  801265:	53                   	push   %ebx
  801266:	83 ec 10             	sub    $0x10,%esp
  801269:	8b 75 08             	mov    0x8(%ebp),%esi
  80126c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80126f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801279:	c1 e8 0c             	shr    $0xc,%eax
  80127c:	50                   	push   %eax
  80127d:	e8 36 ff ff ff       	call   8011b8 <fd_lookup>
  801282:	83 c4 08             	add    $0x8,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	78 05                	js     80128e <fd_close+0x2d>
	    || fd != fd2)
  801289:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80128c:	74 0c                	je     80129a <fd_close+0x39>
		return (must_exist ? r : 0);
  80128e:	84 db                	test   %bl,%bl
  801290:	ba 00 00 00 00       	mov    $0x0,%edx
  801295:	0f 44 c2             	cmove  %edx,%eax
  801298:	eb 41                	jmp    8012db <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80129a:	83 ec 08             	sub    $0x8,%esp
  80129d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a0:	50                   	push   %eax
  8012a1:	ff 36                	pushl  (%esi)
  8012a3:	e8 66 ff ff ff       	call   80120e <dev_lookup>
  8012a8:	89 c3                	mov    %eax,%ebx
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 1a                	js     8012cb <fd_close+0x6a>
		if (dev->dev_close)
  8012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012b7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	74 0b                	je     8012cb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012c0:	83 ec 0c             	sub    $0xc,%esp
  8012c3:	56                   	push   %esi
  8012c4:	ff d0                	call   *%eax
  8012c6:	89 c3                	mov    %eax,%ebx
  8012c8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012cb:	83 ec 08             	sub    $0x8,%esp
  8012ce:	56                   	push   %esi
  8012cf:	6a 00                	push   $0x0
  8012d1:	e8 a7 fa ff ff       	call   800d7d <sys_page_unmap>
	return r;
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	89 d8                	mov    %ebx,%eax
}
  8012db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	ff 75 08             	pushl  0x8(%ebp)
  8012ef:	e8 c4 fe ff ff       	call   8011b8 <fd_lookup>
  8012f4:	83 c4 08             	add    $0x8,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 10                	js     80130b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	6a 01                	push   $0x1
  801300:	ff 75 f4             	pushl  -0xc(%ebp)
  801303:	e8 59 ff ff ff       	call   801261 <fd_close>
  801308:	83 c4 10             	add    $0x10,%esp
}
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    

0080130d <close_all>:

void
close_all(void)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	53                   	push   %ebx
  801311:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801314:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801319:	83 ec 0c             	sub    $0xc,%esp
  80131c:	53                   	push   %ebx
  80131d:	e8 c0 ff ff ff       	call   8012e2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801322:	83 c3 01             	add    $0x1,%ebx
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	83 fb 20             	cmp    $0x20,%ebx
  80132b:	75 ec                	jne    801319 <close_all+0xc>
		close(i);
}
  80132d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	57                   	push   %edi
  801336:	56                   	push   %esi
  801337:	53                   	push   %ebx
  801338:	83 ec 2c             	sub    $0x2c,%esp
  80133b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80133e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	ff 75 08             	pushl  0x8(%ebp)
  801345:	e8 6e fe ff ff       	call   8011b8 <fd_lookup>
  80134a:	83 c4 08             	add    $0x8,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	0f 88 c1 00 00 00    	js     801416 <dup+0xe4>
		return r;
	close(newfdnum);
  801355:	83 ec 0c             	sub    $0xc,%esp
  801358:	56                   	push   %esi
  801359:	e8 84 ff ff ff       	call   8012e2 <close>

	newfd = INDEX2FD(newfdnum);
  80135e:	89 f3                	mov    %esi,%ebx
  801360:	c1 e3 0c             	shl    $0xc,%ebx
  801363:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801369:	83 c4 04             	add    $0x4,%esp
  80136c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80136f:	e8 de fd ff ff       	call   801152 <fd2data>
  801374:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801376:	89 1c 24             	mov    %ebx,(%esp)
  801379:	e8 d4 fd ff ff       	call   801152 <fd2data>
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801384:	89 f8                	mov    %edi,%eax
  801386:	c1 e8 16             	shr    $0x16,%eax
  801389:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801390:	a8 01                	test   $0x1,%al
  801392:	74 37                	je     8013cb <dup+0x99>
  801394:	89 f8                	mov    %edi,%eax
  801396:	c1 e8 0c             	shr    $0xc,%eax
  801399:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a0:	f6 c2 01             	test   $0x1,%dl
  8013a3:	74 26                	je     8013cb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b4:	50                   	push   %eax
  8013b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b8:	6a 00                	push   $0x0
  8013ba:	57                   	push   %edi
  8013bb:	6a 00                	push   $0x0
  8013bd:	e8 79 f9 ff ff       	call   800d3b <sys_page_map>
  8013c2:	89 c7                	mov    %eax,%edi
  8013c4:	83 c4 20             	add    $0x20,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 2e                	js     8013f9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013ce:	89 d0                	mov    %edx,%eax
  8013d0:	c1 e8 0c             	shr    $0xc,%eax
  8013d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013da:	83 ec 0c             	sub    $0xc,%esp
  8013dd:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e2:	50                   	push   %eax
  8013e3:	53                   	push   %ebx
  8013e4:	6a 00                	push   $0x0
  8013e6:	52                   	push   %edx
  8013e7:	6a 00                	push   $0x0
  8013e9:	e8 4d f9 ff ff       	call   800d3b <sys_page_map>
  8013ee:	89 c7                	mov    %eax,%edi
  8013f0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013f3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f5:	85 ff                	test   %edi,%edi
  8013f7:	79 1d                	jns    801416 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	53                   	push   %ebx
  8013fd:	6a 00                	push   $0x0
  8013ff:	e8 79 f9 ff ff       	call   800d7d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801404:	83 c4 08             	add    $0x8,%esp
  801407:	ff 75 d4             	pushl  -0x2c(%ebp)
  80140a:	6a 00                	push   $0x0
  80140c:	e8 6c f9 ff ff       	call   800d7d <sys_page_unmap>
	return r;
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	89 f8                	mov    %edi,%eax
}
  801416:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801419:	5b                   	pop    %ebx
  80141a:	5e                   	pop    %esi
  80141b:	5f                   	pop    %edi
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 14             	sub    $0x14,%esp
  801425:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801428:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	53                   	push   %ebx
  80142d:	e8 86 fd ff ff       	call   8011b8 <fd_lookup>
  801432:	83 c4 08             	add    $0x8,%esp
  801435:	89 c2                	mov    %eax,%edx
  801437:	85 c0                	test   %eax,%eax
  801439:	78 6d                	js     8014a8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801445:	ff 30                	pushl  (%eax)
  801447:	e8 c2 fd ff ff       	call   80120e <dev_lookup>
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 4c                	js     80149f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801453:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801456:	8b 42 08             	mov    0x8(%edx),%eax
  801459:	83 e0 03             	and    $0x3,%eax
  80145c:	83 f8 01             	cmp    $0x1,%eax
  80145f:	75 21                	jne    801482 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801461:	a1 20 44 80 00       	mov    0x804420,%eax
  801466:	8b 40 48             	mov    0x48(%eax),%eax
  801469:	83 ec 04             	sub    $0x4,%esp
  80146c:	53                   	push   %ebx
  80146d:	50                   	push   %eax
  80146e:	68 f8 27 80 00       	push   $0x8027f8
  801473:	e8 79 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801480:	eb 26                	jmp    8014a8 <read+0x8a>
	}
	if (!dev->dev_read)
  801482:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801485:	8b 40 08             	mov    0x8(%eax),%eax
  801488:	85 c0                	test   %eax,%eax
  80148a:	74 17                	je     8014a3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	ff 75 10             	pushl  0x10(%ebp)
  801492:	ff 75 0c             	pushl  0xc(%ebp)
  801495:	52                   	push   %edx
  801496:	ff d0                	call   *%eax
  801498:	89 c2                	mov    %eax,%edx
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	eb 09                	jmp    8014a8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	eb 05                	jmp    8014a8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014a8:	89 d0                	mov    %edx,%eax
  8014aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	57                   	push   %edi
  8014b3:	56                   	push   %esi
  8014b4:	53                   	push   %ebx
  8014b5:	83 ec 0c             	sub    $0xc,%esp
  8014b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014bb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c3:	eb 21                	jmp    8014e6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014c5:	83 ec 04             	sub    $0x4,%esp
  8014c8:	89 f0                	mov    %esi,%eax
  8014ca:	29 d8                	sub    %ebx,%eax
  8014cc:	50                   	push   %eax
  8014cd:	89 d8                	mov    %ebx,%eax
  8014cf:	03 45 0c             	add    0xc(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	57                   	push   %edi
  8014d4:	e8 45 ff ff ff       	call   80141e <read>
		if (m < 0)
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 10                	js     8014f0 <readn+0x41>
			return m;
		if (m == 0)
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	74 0a                	je     8014ee <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e4:	01 c3                	add    %eax,%ebx
  8014e6:	39 f3                	cmp    %esi,%ebx
  8014e8:	72 db                	jb     8014c5 <readn+0x16>
  8014ea:	89 d8                	mov    %ebx,%eax
  8014ec:	eb 02                	jmp    8014f0 <readn+0x41>
  8014ee:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f3:	5b                   	pop    %ebx
  8014f4:	5e                   	pop    %esi
  8014f5:	5f                   	pop    %edi
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    

008014f8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	53                   	push   %ebx
  8014fc:	83 ec 14             	sub    $0x14,%esp
  8014ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801502:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	53                   	push   %ebx
  801507:	e8 ac fc ff ff       	call   8011b8 <fd_lookup>
  80150c:	83 c4 08             	add    $0x8,%esp
  80150f:	89 c2                	mov    %eax,%edx
  801511:	85 c0                	test   %eax,%eax
  801513:	78 68                	js     80157d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151f:	ff 30                	pushl  (%eax)
  801521:	e8 e8 fc ff ff       	call   80120e <dev_lookup>
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 47                	js     801574 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80152d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801530:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801534:	75 21                	jne    801557 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801536:	a1 20 44 80 00       	mov    0x804420,%eax
  80153b:	8b 40 48             	mov    0x48(%eax),%eax
  80153e:	83 ec 04             	sub    $0x4,%esp
  801541:	53                   	push   %ebx
  801542:	50                   	push   %eax
  801543:	68 14 28 80 00       	push   $0x802814
  801548:	e8 a4 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801555:	eb 26                	jmp    80157d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801557:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155a:	8b 52 0c             	mov    0xc(%edx),%edx
  80155d:	85 d2                	test   %edx,%edx
  80155f:	74 17                	je     801578 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	ff 75 10             	pushl  0x10(%ebp)
  801567:	ff 75 0c             	pushl  0xc(%ebp)
  80156a:	50                   	push   %eax
  80156b:	ff d2                	call   *%edx
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	eb 09                	jmp    80157d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801574:	89 c2                	mov    %eax,%edx
  801576:	eb 05                	jmp    80157d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801578:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80157d:	89 d0                	mov    %edx,%eax
  80157f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801582:	c9                   	leave  
  801583:	c3                   	ret    

00801584 <seek>:

int
seek(int fdnum, off_t offset)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	ff 75 08             	pushl  0x8(%ebp)
  801591:	e8 22 fc ff ff       	call   8011b8 <fd_lookup>
  801596:	83 c4 08             	add    $0x8,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 0e                	js     8015ab <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80159d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 14             	sub    $0x14,%esp
  8015b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	53                   	push   %ebx
  8015bc:	e8 f7 fb ff ff       	call   8011b8 <fd_lookup>
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	89 c2                	mov    %eax,%edx
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 65                	js     80162f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d4:	ff 30                	pushl  (%eax)
  8015d6:	e8 33 fc ff ff       	call   80120e <dev_lookup>
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 44                	js     801626 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e9:	75 21                	jne    80160c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015eb:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015f0:	8b 40 48             	mov    0x48(%eax),%eax
  8015f3:	83 ec 04             	sub    $0x4,%esp
  8015f6:	53                   	push   %ebx
  8015f7:	50                   	push   %eax
  8015f8:	68 d4 27 80 00       	push   $0x8027d4
  8015fd:	e8 ef ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80160a:	eb 23                	jmp    80162f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80160c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160f:	8b 52 18             	mov    0x18(%edx),%edx
  801612:	85 d2                	test   %edx,%edx
  801614:	74 14                	je     80162a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	ff 75 0c             	pushl  0xc(%ebp)
  80161c:	50                   	push   %eax
  80161d:	ff d2                	call   *%edx
  80161f:	89 c2                	mov    %eax,%edx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	eb 09                	jmp    80162f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801626:	89 c2                	mov    %eax,%edx
  801628:	eb 05                	jmp    80162f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80162a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80162f:	89 d0                	mov    %edx,%eax
  801631:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	53                   	push   %ebx
  80163a:	83 ec 14             	sub    $0x14,%esp
  80163d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801640:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	ff 75 08             	pushl  0x8(%ebp)
  801647:	e8 6c fb ff ff       	call   8011b8 <fd_lookup>
  80164c:	83 c4 08             	add    $0x8,%esp
  80164f:	89 c2                	mov    %eax,%edx
  801651:	85 c0                	test   %eax,%eax
  801653:	78 58                	js     8016ad <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801655:	83 ec 08             	sub    $0x8,%esp
  801658:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165b:	50                   	push   %eax
  80165c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165f:	ff 30                	pushl  (%eax)
  801661:	e8 a8 fb ff ff       	call   80120e <dev_lookup>
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	78 37                	js     8016a4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80166d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801670:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801674:	74 32                	je     8016a8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801676:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801679:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801680:	00 00 00 
	stat->st_isdir = 0;
  801683:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80168a:	00 00 00 
	stat->st_dev = dev;
  80168d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801693:	83 ec 08             	sub    $0x8,%esp
  801696:	53                   	push   %ebx
  801697:	ff 75 f0             	pushl  -0x10(%ebp)
  80169a:	ff 50 14             	call   *0x14(%eax)
  80169d:	89 c2                	mov    %eax,%edx
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	eb 09                	jmp    8016ad <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a4:	89 c2                	mov    %eax,%edx
  8016a6:	eb 05                	jmp    8016ad <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ad:	89 d0                	mov    %edx,%eax
  8016af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b9:	83 ec 08             	sub    $0x8,%esp
  8016bc:	6a 00                	push   $0x0
  8016be:	ff 75 08             	pushl  0x8(%ebp)
  8016c1:	e8 e3 01 00 00       	call   8018a9 <open>
  8016c6:	89 c3                	mov    %eax,%ebx
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	78 1b                	js     8016ea <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	ff 75 0c             	pushl  0xc(%ebp)
  8016d5:	50                   	push   %eax
  8016d6:	e8 5b ff ff ff       	call   801636 <fstat>
  8016db:	89 c6                	mov    %eax,%esi
	close(fd);
  8016dd:	89 1c 24             	mov    %ebx,(%esp)
  8016e0:	e8 fd fb ff ff       	call   8012e2 <close>
	return r;
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	89 f0                	mov    %esi,%eax
}
  8016ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	89 c6                	mov    %eax,%esi
  8016f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016fa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801701:	75 12                	jne    801715 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801703:	83 ec 0c             	sub    $0xc,%esp
  801706:	6a 01                	push   $0x1
  801708:	e8 9f 08 00 00       	call   801fac <ipc_find_env>
  80170d:	a3 00 40 80 00       	mov    %eax,0x804000
  801712:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801715:	6a 07                	push   $0x7
  801717:	68 00 50 80 00       	push   $0x805000
  80171c:	56                   	push   %esi
  80171d:	ff 35 00 40 80 00    	pushl  0x804000
  801723:	e8 30 08 00 00       	call   801f58 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801728:	83 c4 0c             	add    $0xc,%esp
  80172b:	6a 00                	push   $0x0
  80172d:	53                   	push   %ebx
  80172e:	6a 00                	push   $0x0
  801730:	e8 b1 07 00 00       	call   801ee6 <ipc_recv>
}
  801735:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801738:	5b                   	pop    %ebx
  801739:	5e                   	pop    %esi
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	8b 40 0c             	mov    0xc(%eax),%eax
  801748:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80174d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801750:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801755:	ba 00 00 00 00       	mov    $0x0,%edx
  80175a:	b8 02 00 00 00       	mov    $0x2,%eax
  80175f:	e8 8d ff ff ff       	call   8016f1 <fsipc>
}
  801764:	c9                   	leave  
  801765:	c3                   	ret    

00801766 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80176c:	8b 45 08             	mov    0x8(%ebp),%eax
  80176f:	8b 40 0c             	mov    0xc(%eax),%eax
  801772:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801777:	ba 00 00 00 00       	mov    $0x0,%edx
  80177c:	b8 06 00 00 00       	mov    $0x6,%eax
  801781:	e8 6b ff ff ff       	call   8016f1 <fsipc>
}
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	83 ec 04             	sub    $0x4,%esp
  80178f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	8b 40 0c             	mov    0xc(%eax),%eax
  801798:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80179d:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a7:	e8 45 ff ff ff       	call   8016f1 <fsipc>
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 2c                	js     8017dc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	68 00 50 80 00       	push   $0x805000
  8017b8:	53                   	push   %ebx
  8017b9:	e8 37 f1 ff ff       	call   8008f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017be:	a1 80 50 80 00       	mov    0x805080,%eax
  8017c3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c9:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ce:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017ea:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017ef:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017f4:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8017fa:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801803:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801808:	50                   	push   %eax
  801809:	ff 75 0c             	pushl  0xc(%ebp)
  80180c:	68 08 50 80 00       	push   $0x805008
  801811:	e8 71 f2 ff ff       	call   800a87 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  801816:	ba 00 00 00 00       	mov    $0x0,%edx
  80181b:	b8 04 00 00 00       	mov    $0x4,%eax
  801820:	e8 cc fe ff ff       	call   8016f1 <fsipc>
}
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	56                   	push   %esi
  80182b:	53                   	push   %ebx
  80182c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80182f:	8b 45 08             	mov    0x8(%ebp),%eax
  801832:	8b 40 0c             	mov    0xc(%eax),%eax
  801835:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80183a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801840:	ba 00 00 00 00       	mov    $0x0,%edx
  801845:	b8 03 00 00 00       	mov    $0x3,%eax
  80184a:	e8 a2 fe ff ff       	call   8016f1 <fsipc>
  80184f:	89 c3                	mov    %eax,%ebx
  801851:	85 c0                	test   %eax,%eax
  801853:	78 4b                	js     8018a0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801855:	39 c6                	cmp    %eax,%esi
  801857:	73 16                	jae    80186f <devfile_read+0x48>
  801859:	68 44 28 80 00       	push   $0x802844
  80185e:	68 4b 28 80 00       	push   $0x80284b
  801863:	6a 7c                	push   $0x7c
  801865:	68 60 28 80 00       	push   $0x802860
  80186a:	e8 a9 e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  80186f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801874:	7e 16                	jle    80188c <devfile_read+0x65>
  801876:	68 6b 28 80 00       	push   $0x80286b
  80187b:	68 4b 28 80 00       	push   $0x80284b
  801880:	6a 7d                	push   $0x7d
  801882:	68 60 28 80 00       	push   $0x802860
  801887:	e8 8c e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	50                   	push   %eax
  801890:	68 00 50 80 00       	push   $0x805000
  801895:	ff 75 0c             	pushl  0xc(%ebp)
  801898:	e8 ea f1 ff ff       	call   800a87 <memmove>
	return r;
  80189d:	83 c4 10             	add    $0x10,%esp
}
  8018a0:	89 d8                	mov    %ebx,%eax
  8018a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 20             	sub    $0x20,%esp
  8018b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018b3:	53                   	push   %ebx
  8018b4:	e8 03 f0 ff ff       	call   8008bc <strlen>
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c1:	7f 67                	jg     80192a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c3:	83 ec 0c             	sub    $0xc,%esp
  8018c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c9:	50                   	push   %eax
  8018ca:	e8 9a f8 ff ff       	call   801169 <fd_alloc>
  8018cf:	83 c4 10             	add    $0x10,%esp
		return r;
  8018d2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	78 57                	js     80192f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d8:	83 ec 08             	sub    $0x8,%esp
  8018db:	53                   	push   %ebx
  8018dc:	68 00 50 80 00       	push   $0x805000
  8018e1:	e8 0f f0 ff ff       	call   8008f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f6:	e8 f6 fd ff ff       	call   8016f1 <fsipc>
  8018fb:	89 c3                	mov    %eax,%ebx
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	85 c0                	test   %eax,%eax
  801902:	79 14                	jns    801918 <open+0x6f>
		fd_close(fd, 0);
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	6a 00                	push   $0x0
  801909:	ff 75 f4             	pushl  -0xc(%ebp)
  80190c:	e8 50 f9 ff ff       	call   801261 <fd_close>
		return r;
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	89 da                	mov    %ebx,%edx
  801916:	eb 17                	jmp    80192f <open+0x86>
	}

	return fd2num(fd);
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	ff 75 f4             	pushl  -0xc(%ebp)
  80191e:	e8 1f f8 ff ff       	call   801142 <fd2num>
  801923:	89 c2                	mov    %eax,%edx
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	eb 05                	jmp    80192f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80192a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80192f:	89 d0                	mov    %edx,%eax
  801931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80193c:	ba 00 00 00 00       	mov    $0x0,%edx
  801941:	b8 08 00 00 00       	mov    $0x8,%eax
  801946:	e8 a6 fd ff ff       	call   8016f1 <fsipc>
}
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	56                   	push   %esi
  801951:	53                   	push   %ebx
  801952:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801955:	83 ec 0c             	sub    $0xc,%esp
  801958:	ff 75 08             	pushl  0x8(%ebp)
  80195b:	e8 f2 f7 ff ff       	call   801152 <fd2data>
  801960:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801962:	83 c4 08             	add    $0x8,%esp
  801965:	68 77 28 80 00       	push   $0x802877
  80196a:	53                   	push   %ebx
  80196b:	e8 85 ef ff ff       	call   8008f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801970:	8b 46 04             	mov    0x4(%esi),%eax
  801973:	2b 06                	sub    (%esi),%eax
  801975:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80197b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801982:	00 00 00 
	stat->st_dev = &devpipe;
  801985:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80198c:	30 80 00 
	return 0;
}
  80198f:	b8 00 00 00 00       	mov    $0x0,%eax
  801994:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801997:	5b                   	pop    %ebx
  801998:	5e                   	pop    %esi
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	53                   	push   %ebx
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a5:	53                   	push   %ebx
  8019a6:	6a 00                	push   $0x0
  8019a8:	e8 d0 f3 ff ff       	call   800d7d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ad:	89 1c 24             	mov    %ebx,(%esp)
  8019b0:	e8 9d f7 ff ff       	call   801152 <fd2data>
  8019b5:	83 c4 08             	add    $0x8,%esp
  8019b8:	50                   	push   %eax
  8019b9:	6a 00                	push   $0x0
  8019bb:	e8 bd f3 ff ff       	call   800d7d <sys_page_unmap>
}
  8019c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	57                   	push   %edi
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	83 ec 1c             	sub    $0x1c,%esp
  8019ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019d1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019d3:	a1 20 44 80 00       	mov    0x804420,%eax
  8019d8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019db:	83 ec 0c             	sub    $0xc,%esp
  8019de:	ff 75 e0             	pushl  -0x20(%ebp)
  8019e1:	e8 ff 05 00 00       	call   801fe5 <pageref>
  8019e6:	89 c3                	mov    %eax,%ebx
  8019e8:	89 3c 24             	mov    %edi,(%esp)
  8019eb:	e8 f5 05 00 00       	call   801fe5 <pageref>
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	39 c3                	cmp    %eax,%ebx
  8019f5:	0f 94 c1             	sete   %cl
  8019f8:	0f b6 c9             	movzbl %cl,%ecx
  8019fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019fe:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a04:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a07:	39 ce                	cmp    %ecx,%esi
  801a09:	74 1b                	je     801a26 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a0b:	39 c3                	cmp    %eax,%ebx
  801a0d:	75 c4                	jne    8019d3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a0f:	8b 42 58             	mov    0x58(%edx),%eax
  801a12:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a15:	50                   	push   %eax
  801a16:	56                   	push   %esi
  801a17:	68 7e 28 80 00       	push   $0x80287e
  801a1c:	e8 d0 e8 ff ff       	call   8002f1 <cprintf>
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	eb ad                	jmp    8019d3 <_pipeisclosed+0xe>
	}
}
  801a26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5f                   	pop    %edi
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    

00801a31 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	57                   	push   %edi
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	83 ec 28             	sub    $0x28,%esp
  801a3a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a3d:	56                   	push   %esi
  801a3e:	e8 0f f7 ff ff       	call   801152 <fd2data>
  801a43:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	bf 00 00 00 00       	mov    $0x0,%edi
  801a4d:	eb 4b                	jmp    801a9a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a4f:	89 da                	mov    %ebx,%edx
  801a51:	89 f0                	mov    %esi,%eax
  801a53:	e8 6d ff ff ff       	call   8019c5 <_pipeisclosed>
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	75 48                	jne    801aa4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a5c:	e8 78 f2 ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a61:	8b 43 04             	mov    0x4(%ebx),%eax
  801a64:	8b 0b                	mov    (%ebx),%ecx
  801a66:	8d 51 20             	lea    0x20(%ecx),%edx
  801a69:	39 d0                	cmp    %edx,%eax
  801a6b:	73 e2                	jae    801a4f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a70:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a74:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a77:	89 c2                	mov    %eax,%edx
  801a79:	c1 fa 1f             	sar    $0x1f,%edx
  801a7c:	89 d1                	mov    %edx,%ecx
  801a7e:	c1 e9 1b             	shr    $0x1b,%ecx
  801a81:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a84:	83 e2 1f             	and    $0x1f,%edx
  801a87:	29 ca                	sub    %ecx,%edx
  801a89:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a91:	83 c0 01             	add    $0x1,%eax
  801a94:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a97:	83 c7 01             	add    $0x1,%edi
  801a9a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a9d:	75 c2                	jne    801a61 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa2:	eb 05                	jmp    801aa9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5f                   	pop    %edi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	57                   	push   %edi
  801ab5:	56                   	push   %esi
  801ab6:	53                   	push   %ebx
  801ab7:	83 ec 18             	sub    $0x18,%esp
  801aba:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801abd:	57                   	push   %edi
  801abe:	e8 8f f6 ff ff       	call   801152 <fd2data>
  801ac3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801acd:	eb 3d                	jmp    801b0c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801acf:	85 db                	test   %ebx,%ebx
  801ad1:	74 04                	je     801ad7 <devpipe_read+0x26>
				return i;
  801ad3:	89 d8                	mov    %ebx,%eax
  801ad5:	eb 44                	jmp    801b1b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ad7:	89 f2                	mov    %esi,%edx
  801ad9:	89 f8                	mov    %edi,%eax
  801adb:	e8 e5 fe ff ff       	call   8019c5 <_pipeisclosed>
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	75 32                	jne    801b16 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ae4:	e8 f0 f1 ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ae9:	8b 06                	mov    (%esi),%eax
  801aeb:	3b 46 04             	cmp    0x4(%esi),%eax
  801aee:	74 df                	je     801acf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af0:	99                   	cltd   
  801af1:	c1 ea 1b             	shr    $0x1b,%edx
  801af4:	01 d0                	add    %edx,%eax
  801af6:	83 e0 1f             	and    $0x1f,%eax
  801af9:	29 d0                	sub    %edx,%eax
  801afb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b03:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b06:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b09:	83 c3 01             	add    $0x1,%ebx
  801b0c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b0f:	75 d8                	jne    801ae9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b11:	8b 45 10             	mov    0x10(%ebp),%eax
  801b14:	eb 05                	jmp    801b1b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b16:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5f                   	pop    %edi
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2e:	50                   	push   %eax
  801b2f:	e8 35 f6 ff ff       	call   801169 <fd_alloc>
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	89 c2                	mov    %eax,%edx
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	0f 88 2c 01 00 00    	js     801c6d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b41:	83 ec 04             	sub    $0x4,%esp
  801b44:	68 07 04 00 00       	push   $0x407
  801b49:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4c:	6a 00                	push   $0x0
  801b4e:	e8 a5 f1 ff ff       	call   800cf8 <sys_page_alloc>
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	89 c2                	mov    %eax,%edx
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	0f 88 0d 01 00 00    	js     801c6d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b60:	83 ec 0c             	sub    $0xc,%esp
  801b63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b66:	50                   	push   %eax
  801b67:	e8 fd f5 ff ff       	call   801169 <fd_alloc>
  801b6c:	89 c3                	mov    %eax,%ebx
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	85 c0                	test   %eax,%eax
  801b73:	0f 88 e2 00 00 00    	js     801c5b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b79:	83 ec 04             	sub    $0x4,%esp
  801b7c:	68 07 04 00 00       	push   $0x407
  801b81:	ff 75 f0             	pushl  -0x10(%ebp)
  801b84:	6a 00                	push   $0x0
  801b86:	e8 6d f1 ff ff       	call   800cf8 <sys_page_alloc>
  801b8b:	89 c3                	mov    %eax,%ebx
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	85 c0                	test   %eax,%eax
  801b92:	0f 88 c3 00 00 00    	js     801c5b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b98:	83 ec 0c             	sub    $0xc,%esp
  801b9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9e:	e8 af f5 ff ff       	call   801152 <fd2data>
  801ba3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba5:	83 c4 0c             	add    $0xc,%esp
  801ba8:	68 07 04 00 00       	push   $0x407
  801bad:	50                   	push   %eax
  801bae:	6a 00                	push   $0x0
  801bb0:	e8 43 f1 ff ff       	call   800cf8 <sys_page_alloc>
  801bb5:	89 c3                	mov    %eax,%ebx
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	0f 88 89 00 00 00    	js     801c4b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc2:	83 ec 0c             	sub    $0xc,%esp
  801bc5:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc8:	e8 85 f5 ff ff       	call   801152 <fd2data>
  801bcd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bd4:	50                   	push   %eax
  801bd5:	6a 00                	push   $0x0
  801bd7:	56                   	push   %esi
  801bd8:	6a 00                	push   $0x0
  801bda:	e8 5c f1 ff ff       	call   800d3b <sys_page_map>
  801bdf:	89 c3                	mov    %eax,%ebx
  801be1:	83 c4 20             	add    $0x20,%esp
  801be4:	85 c0                	test   %eax,%eax
  801be6:	78 55                	js     801c3d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801be8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bfd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c06:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c0b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c12:	83 ec 0c             	sub    $0xc,%esp
  801c15:	ff 75 f4             	pushl  -0xc(%ebp)
  801c18:	e8 25 f5 ff ff       	call   801142 <fd2num>
  801c1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c20:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c22:	83 c4 04             	add    $0x4,%esp
  801c25:	ff 75 f0             	pushl  -0x10(%ebp)
  801c28:	e8 15 f5 ff ff       	call   801142 <fd2num>
  801c2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c30:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3b:	eb 30                	jmp    801c6d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c3d:	83 ec 08             	sub    $0x8,%esp
  801c40:	56                   	push   %esi
  801c41:	6a 00                	push   $0x0
  801c43:	e8 35 f1 ff ff       	call   800d7d <sys_page_unmap>
  801c48:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c4b:	83 ec 08             	sub    $0x8,%esp
  801c4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c51:	6a 00                	push   $0x0
  801c53:	e8 25 f1 ff ff       	call   800d7d <sys_page_unmap>
  801c58:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c5b:	83 ec 08             	sub    $0x8,%esp
  801c5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c61:	6a 00                	push   $0x0
  801c63:	e8 15 f1 ff ff       	call   800d7d <sys_page_unmap>
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c6d:	89 d0                	mov    %edx,%eax
  801c6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c72:	5b                   	pop    %ebx
  801c73:	5e                   	pop    %esi
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    

00801c76 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7f:	50                   	push   %eax
  801c80:	ff 75 08             	pushl  0x8(%ebp)
  801c83:	e8 30 f5 ff ff       	call   8011b8 <fd_lookup>
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	78 18                	js     801ca7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c8f:	83 ec 0c             	sub    $0xc,%esp
  801c92:	ff 75 f4             	pushl  -0xc(%ebp)
  801c95:	e8 b8 f4 ff ff       	call   801152 <fd2data>
	return _pipeisclosed(fd, p);
  801c9a:	89 c2                	mov    %eax,%edx
  801c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9f:	e8 21 fd ff ff       	call   8019c5 <_pipeisclosed>
  801ca4:	83 c4 10             	add    $0x10,%esp
}
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    

00801ca9 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	56                   	push   %esi
  801cad:	53                   	push   %ebx
  801cae:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801cb1:	85 f6                	test   %esi,%esi
  801cb3:	75 16                	jne    801ccb <wait+0x22>
  801cb5:	68 96 28 80 00       	push   $0x802896
  801cba:	68 4b 28 80 00       	push   $0x80284b
  801cbf:	6a 09                	push   $0x9
  801cc1:	68 a1 28 80 00       	push   $0x8028a1
  801cc6:	e8 4d e5 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801ccb:	89 f3                	mov    %esi,%ebx
  801ccd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801cd3:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801cd6:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801cdc:	eb 05                	jmp    801ce3 <wait+0x3a>
		sys_yield();
  801cde:	e8 f6 ef ff ff       	call   800cd9 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801ce3:	8b 43 48             	mov    0x48(%ebx),%eax
  801ce6:	39 c6                	cmp    %eax,%esi
  801ce8:	75 07                	jne    801cf1 <wait+0x48>
  801cea:	8b 43 54             	mov    0x54(%ebx),%eax
  801ced:	85 c0                	test   %eax,%eax
  801cef:	75 ed                	jne    801cde <wait+0x35>
		sys_yield();
}
  801cf1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    

00801d02 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d08:	68 ac 28 80 00       	push   $0x8028ac
  801d0d:	ff 75 0c             	pushl  0xc(%ebp)
  801d10:	e8 e0 eb ff ff       	call   8008f5 <strcpy>
	return 0;
}
  801d15:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    

00801d1c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	57                   	push   %edi
  801d20:	56                   	push   %esi
  801d21:	53                   	push   %ebx
  801d22:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d28:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d2d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d33:	eb 2d                	jmp    801d62 <devcons_write+0x46>
		m = n - tot;
  801d35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d38:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d3a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d3d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d42:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d45:	83 ec 04             	sub    $0x4,%esp
  801d48:	53                   	push   %ebx
  801d49:	03 45 0c             	add    0xc(%ebp),%eax
  801d4c:	50                   	push   %eax
  801d4d:	57                   	push   %edi
  801d4e:	e8 34 ed ff ff       	call   800a87 <memmove>
		sys_cputs(buf, m);
  801d53:	83 c4 08             	add    $0x8,%esp
  801d56:	53                   	push   %ebx
  801d57:	57                   	push   %edi
  801d58:	e8 df ee ff ff       	call   800c3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5d:	01 de                	add    %ebx,%esi
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	89 f0                	mov    %esi,%eax
  801d64:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d67:	72 cc                	jb     801d35 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5f                   	pop    %edi
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	83 ec 08             	sub    $0x8,%esp
  801d77:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d80:	74 2a                	je     801dac <devcons_read+0x3b>
  801d82:	eb 05                	jmp    801d89 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d84:	e8 50 ef ff ff       	call   800cd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d89:	e8 cc ee ff ff       	call   800c5a <sys_cgetc>
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	74 f2                	je     801d84 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d92:	85 c0                	test   %eax,%eax
  801d94:	78 16                	js     801dac <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d96:	83 f8 04             	cmp    $0x4,%eax
  801d99:	74 0c                	je     801da7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9e:	88 02                	mov    %al,(%edx)
	return 1;
  801da0:	b8 01 00 00 00       	mov    $0x1,%eax
  801da5:	eb 05                	jmp    801dac <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dac:	c9                   	leave  
  801dad:	c3                   	ret    

00801dae <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801db4:	8b 45 08             	mov    0x8(%ebp),%eax
  801db7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dba:	6a 01                	push   $0x1
  801dbc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dbf:	50                   	push   %eax
  801dc0:	e8 77 ee ff ff       	call   800c3c <sys_cputs>
}
  801dc5:	83 c4 10             	add    $0x10,%esp
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <getchar>:

int
getchar(void)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dd0:	6a 01                	push   $0x1
  801dd2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd5:	50                   	push   %eax
  801dd6:	6a 00                	push   $0x0
  801dd8:	e8 41 f6 ff ff       	call   80141e <read>
	if (r < 0)
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	85 c0                	test   %eax,%eax
  801de2:	78 0f                	js     801df3 <getchar+0x29>
		return r;
	if (r < 1)
  801de4:	85 c0                	test   %eax,%eax
  801de6:	7e 06                	jle    801dee <getchar+0x24>
		return -E_EOF;
	return c;
  801de8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dec:	eb 05                	jmp    801df3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	ff 75 08             	pushl  0x8(%ebp)
  801e02:	e8 b1 f3 ff ff       	call   8011b8 <fd_lookup>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	78 11                	js     801e1f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e11:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e17:	39 10                	cmp    %edx,(%eax)
  801e19:	0f 94 c0             	sete   %al
  801e1c:	0f b6 c0             	movzbl %al,%eax
}
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    

00801e21 <opencons>:

int
opencons(void)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2a:	50                   	push   %eax
  801e2b:	e8 39 f3 ff ff       	call   801169 <fd_alloc>
  801e30:	83 c4 10             	add    $0x10,%esp
		return r;
  801e33:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e35:	85 c0                	test   %eax,%eax
  801e37:	78 3e                	js     801e77 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e39:	83 ec 04             	sub    $0x4,%esp
  801e3c:	68 07 04 00 00       	push   $0x407
  801e41:	ff 75 f4             	pushl  -0xc(%ebp)
  801e44:	6a 00                	push   $0x0
  801e46:	e8 ad ee ff ff       	call   800cf8 <sys_page_alloc>
  801e4b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e4e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 23                	js     801e77 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e54:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e62:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e69:	83 ec 0c             	sub    $0xc,%esp
  801e6c:	50                   	push   %eax
  801e6d:	e8 d0 f2 ff ff       	call   801142 <fd2num>
  801e72:	89 c2                	mov    %eax,%edx
  801e74:	83 c4 10             	add    $0x10,%esp
}
  801e77:	89 d0                	mov    %edx,%eax
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    

00801e7b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	53                   	push   %ebx
  801e7f:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e82:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e89:	75 28                	jne    801eb3 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801e8b:	e8 2a ee ff ff       	call   800cba <sys_getenvid>
  801e90:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801e92:	83 ec 04             	sub    $0x4,%esp
  801e95:	6a 07                	push   $0x7
  801e97:	68 00 f0 bf ee       	push   $0xeebff000
  801e9c:	50                   	push   %eax
  801e9d:	e8 56 ee ff ff       	call   800cf8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801ea2:	83 c4 08             	add    $0x8,%esp
  801ea5:	68 c0 1e 80 00       	push   $0x801ec0
  801eaa:	53                   	push   %ebx
  801eab:	e8 93 ef ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
  801eb0:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb6:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ebb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801ec0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ec1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ec6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ec8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801ecb:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801ecd:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801ed1:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801ed5:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801ed6:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801ed8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801edd:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801ede:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801edf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801ee0:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801ee3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801ee4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ee5:	c3                   	ret    

00801ee6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	56                   	push   %esi
  801eea:	53                   	push   %ebx
  801eeb:	8b 75 08             	mov    0x8(%ebp),%esi
  801eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	74 0e                	je     801f06 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801ef8:	83 ec 0c             	sub    $0xc,%esp
  801efb:	50                   	push   %eax
  801efc:	e8 a7 ef ff ff       	call   800ea8 <sys_ipc_recv>
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	eb 0d                	jmp    801f13 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801f06:	83 ec 0c             	sub    $0xc,%esp
  801f09:	6a ff                	push   $0xffffffff
  801f0b:	e8 98 ef ff ff       	call   800ea8 <sys_ipc_recv>
  801f10:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801f13:	85 c0                	test   %eax,%eax
  801f15:	79 16                	jns    801f2d <ipc_recv+0x47>

		if (from_env_store != NULL)
  801f17:	85 f6                	test   %esi,%esi
  801f19:	74 06                	je     801f21 <ipc_recv+0x3b>
			*from_env_store = 0;
  801f1b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801f21:	85 db                	test   %ebx,%ebx
  801f23:	74 2c                	je     801f51 <ipc_recv+0x6b>
			*perm_store = 0;
  801f25:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f2b:	eb 24                	jmp    801f51 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801f2d:	85 f6                	test   %esi,%esi
  801f2f:	74 0a                	je     801f3b <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801f31:	a1 20 44 80 00       	mov    0x804420,%eax
  801f36:	8b 40 74             	mov    0x74(%eax),%eax
  801f39:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801f3b:	85 db                	test   %ebx,%ebx
  801f3d:	74 0a                	je     801f49 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801f3f:	a1 20 44 80 00       	mov    0x804420,%eax
  801f44:	8b 40 78             	mov    0x78(%eax),%eax
  801f47:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801f49:	a1 20 44 80 00       	mov    0x804420,%eax
  801f4e:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801f51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    

00801f58 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	57                   	push   %edi
  801f5c:	56                   	push   %esi
  801f5d:	53                   	push   %ebx
  801f5e:	83 ec 0c             	sub    $0xc,%esp
  801f61:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801f6a:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801f6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f71:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f74:	ff 75 14             	pushl  0x14(%ebp)
  801f77:	53                   	push   %ebx
  801f78:	56                   	push   %esi
  801f79:	57                   	push   %edi
  801f7a:	e8 06 ef ff ff       	call   800e85 <sys_ipc_try_send>
		if (r >= 0)
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	85 c0                	test   %eax,%eax
  801f84:	79 1e                	jns    801fa4 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801f86:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f89:	74 12                	je     801f9d <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801f8b:	50                   	push   %eax
  801f8c:	68 b8 28 80 00       	push   $0x8028b8
  801f91:	6a 49                	push   $0x49
  801f93:	68 cb 28 80 00       	push   $0x8028cb
  801f98:	e8 7b e2 ff ff       	call   800218 <_panic>
	
		sys_yield();
  801f9d:	e8 37 ed ff ff       	call   800cd9 <sys_yield>
	}
  801fa2:	eb d0                	jmp    801f74 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5f                   	pop    %edi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fc0:	8b 52 50             	mov    0x50(%edx),%edx
  801fc3:	39 ca                	cmp    %ecx,%edx
  801fc5:	75 0d                	jne    801fd4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fc7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fcf:	8b 40 48             	mov    0x48(%eax),%eax
  801fd2:	eb 0f                	jmp    801fe3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd4:	83 c0 01             	add    $0x1,%eax
  801fd7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fdc:	75 d9                	jne    801fb7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    

00801fe5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801feb:	89 d0                	mov    %edx,%eax
  801fed:	c1 e8 16             	shr    $0x16,%eax
  801ff0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ff7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ffc:	f6 c1 01             	test   $0x1,%cl
  801fff:	74 1d                	je     80201e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802001:	c1 ea 0c             	shr    $0xc,%edx
  802004:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80200b:	f6 c2 01             	test   $0x1,%dl
  80200e:	74 0e                	je     80201e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802010:	c1 ea 0c             	shr    $0xc,%edx
  802013:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80201a:	ef 
  80201b:	0f b7 c0             	movzwl %ax,%eax
}
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 1c             	sub    $0x1c,%esp
  802027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80202b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80202f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802037:	85 f6                	test   %esi,%esi
  802039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203d:	89 ca                	mov    %ecx,%edx
  80203f:	89 f8                	mov    %edi,%eax
  802041:	75 3d                	jne    802080 <__udivdi3+0x60>
  802043:	39 cf                	cmp    %ecx,%edi
  802045:	0f 87 c5 00 00 00    	ja     802110 <__udivdi3+0xf0>
  80204b:	85 ff                	test   %edi,%edi
  80204d:	89 fd                	mov    %edi,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f7                	div    %edi
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 c8                	mov    %ecx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c1                	mov    %eax,%ecx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	89 cf                	mov    %ecx,%edi
  802068:	f7 f5                	div    %ebp
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 ce                	cmp    %ecx,%esi
  802082:	77 74                	ja     8020f8 <__udivdi3+0xd8>
  802084:	0f bd fe             	bsr    %esi,%edi
  802087:	83 f7 1f             	xor    $0x1f,%edi
  80208a:	0f 84 98 00 00 00    	je     802128 <__udivdi3+0x108>
  802090:	bb 20 00 00 00       	mov    $0x20,%ebx
  802095:	89 f9                	mov    %edi,%ecx
  802097:	89 c5                	mov    %eax,%ebp
  802099:	29 fb                	sub    %edi,%ebx
  80209b:	d3 e6                	shl    %cl,%esi
  80209d:	89 d9                	mov    %ebx,%ecx
  80209f:	d3 ed                	shr    %cl,%ebp
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	09 ee                	or     %ebp,%esi
  8020a7:	89 d9                	mov    %ebx,%ecx
  8020a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ad:	89 d5                	mov    %edx,%ebp
  8020af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b3:	d3 ed                	shr    %cl,%ebp
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e2                	shl    %cl,%edx
  8020b9:	89 d9                	mov    %ebx,%ecx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	09 c2                	or     %eax,%edx
  8020bf:	89 d0                	mov    %edx,%eax
  8020c1:	89 ea                	mov    %ebp,%edx
  8020c3:	f7 f6                	div    %esi
  8020c5:	89 d5                	mov    %edx,%ebp
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	f7 64 24 0c          	mull   0xc(%esp)
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	72 10                	jb     8020e1 <__udivdi3+0xc1>
  8020d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e6                	shl    %cl,%esi
  8020d9:	39 c6                	cmp    %eax,%esi
  8020db:	73 07                	jae    8020e4 <__udivdi3+0xc4>
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	75 03                	jne    8020e4 <__udivdi3+0xc4>
  8020e1:	83 eb 01             	sub    $0x1,%ebx
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	31 db                	xor    %ebx,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f7                	div    %edi
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 c3                	mov    %eax,%ebx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	39 ce                	cmp    %ecx,%esi
  80212a:	72 0c                	jb     802138 <__udivdi3+0x118>
  80212c:	31 db                	xor    %ebx,%ebx
  80212e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802132:	0f 87 34 ff ff ff    	ja     80206c <__udivdi3+0x4c>
  802138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80213d:	e9 2a ff ff ff       	jmp    80206c <__udivdi3+0x4c>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 d2                	test   %edx,%edx
  802169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f3                	mov    %esi,%ebx
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	75 1c                	jne    802198 <__umoddi3+0x48>
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	76 50                	jbe    8021d0 <__umoddi3+0x80>
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	f7 f7                	div    %edi
  802186:	89 d0                	mov    %edx,%eax
  802188:	31 d2                	xor    %edx,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	77 52                	ja     8021f0 <__umoddi3+0xa0>
  80219e:	0f bd ea             	bsr    %edx,%ebp
  8021a1:	83 f5 1f             	xor    $0x1f,%ebp
  8021a4:	75 5a                	jne    802200 <__umoddi3+0xb0>
  8021a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021aa:	0f 82 e0 00 00 00    	jb     802290 <__umoddi3+0x140>
  8021b0:	39 0c 24             	cmp    %ecx,(%esp)
  8021b3:	0f 86 d7 00 00 00    	jbe    802290 <__umoddi3+0x140>
  8021b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	89 fd                	mov    %edi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f7                	div    %edi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f5                	div    %ebp
  8021e7:	89 c8                	mov    %ecx,%eax
  8021e9:	f7 f5                	div    %ebp
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	eb 99                	jmp    802188 <__umoddi3+0x38>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 34 24             	mov    (%esp),%esi
  802203:	bf 20 00 00 00       	mov    $0x20,%edi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ef                	sub    %ebp,%edi
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 f9                	mov    %edi,%ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	d3 ea                	shr    %cl,%edx
  802214:	89 e9                	mov    %ebp,%ecx
  802216:	09 c2                	or     %eax,%edx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 14 24             	mov    %edx,(%esp)
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	d3 e2                	shl    %cl,%edx
  802221:	89 f9                	mov    %edi,%ecx
  802223:	89 54 24 04          	mov    %edx,0x4(%esp)
  802227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	89 c6                	mov    %eax,%esi
  802231:	d3 e3                	shl    %cl,%ebx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 d0                	mov    %edx,%eax
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	09 d8                	or     %ebx,%eax
  80223d:	89 d3                	mov    %edx,%ebx
  80223f:	89 f2                	mov    %esi,%edx
  802241:	f7 34 24             	divl   (%esp)
  802244:	89 d6                	mov    %edx,%esi
  802246:	d3 e3                	shl    %cl,%ebx
  802248:	f7 64 24 04          	mull   0x4(%esp)
  80224c:	39 d6                	cmp    %edx,%esi
  80224e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802252:	89 d1                	mov    %edx,%ecx
  802254:	89 c3                	mov    %eax,%ebx
  802256:	72 08                	jb     802260 <__umoddi3+0x110>
  802258:	75 11                	jne    80226b <__umoddi3+0x11b>
  80225a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80225e:	73 0b                	jae    80226b <__umoddi3+0x11b>
  802260:	2b 44 24 04          	sub    0x4(%esp),%eax
  802264:	1b 14 24             	sbb    (%esp),%edx
  802267:	89 d1                	mov    %edx,%ecx
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80226f:	29 da                	sub    %ebx,%edx
  802271:	19 ce                	sbb    %ecx,%esi
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 f0                	mov    %esi,%eax
  802277:	d3 e0                	shl    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	d3 ee                	shr    %cl,%esi
  802281:	09 d0                	or     %edx,%eax
  802283:	89 f2                	mov    %esi,%edx
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	29 f9                	sub    %edi,%ecx
  802292:	19 d6                	sbb    %edx,%esi
  802294:	89 74 24 04          	mov    %esi,0x4(%esp)
  802298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229c:	e9 18 ff ff ff       	jmp    8021b9 <__umoddi3+0x69>
