
obj/user/testpiperace.debug：     文件格式 elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 a0 22 80 00       	push   $0x8022a0
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 39 1c 00 00       	call   801c89 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 b9 22 80 00       	push   $0x8022b9
  80005d:	6a 0d                	push   $0xd
  80005f:	68 c2 22 80 00       	push   $0x8022c2
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 4c 0f 00 00       	call   800fba <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 d6 22 80 00       	push   $0x8022d6
  80007a:	6a 10                	push   $0x10
  80007c:	68 c2 22 80 00       	push   $0x8022c2
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 78 13 00 00       	call   80140d <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 34 1d 00 00       	call   801ddc <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 df 22 80 00       	push   $0x8022df
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 3c 0c 00 00       	call   800d05 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 92 10 00 00       	call   80116e <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 fa 22 80 00       	push   $0x8022fa
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 05 23 80 00       	push   $0x802305
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 43 13 00 00       	call   80145d <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 28 13 00 00       	call   80145d <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 10 23 80 00       	push   $0x802310
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 84 1c 00 00       	call   801ddc <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 6c 23 80 00       	push   $0x80236c
  800167:	6a 3a                	push   $0x3a
  800169:	68 c2 22 80 00       	push   $0x8022c2
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 61 11 00 00       	call   8012e3 <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 26 23 80 00       	push   $0x802326
  80018f:	6a 3c                	push   $0x3c
  800191:	68 c2 22 80 00       	push   $0x8022c2
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 d7 10 00 00       	call   80127d <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 ca 18 00 00       	call   801a78 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 3e 23 80 00       	push   $0x80233e
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 54 23 80 00       	push   $0x802354
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ef:	e8 f2 0a 00 00       	call   800ce6 <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 03 12 00 00       	call   801438 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 66 0a 00 00       	call   800ca5 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 8f 0a 00 00       	call   800ce6 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 a0 23 80 00       	push   $0x8023a0
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 b7 22 80 00 	movl   $0x8022b7,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 ae 09 00 00       	call   800c68 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 1a 01 00 00       	call   80041a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 53 09 00 00       	call   800c68 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 7b 1c 00 00       	call   802000 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 68 1d 00 00       	call   802130 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ef:	73 0a                	jae    8003fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f4:	89 08                	mov    %ecx,(%eax)
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	88 02                	mov    %al,(%edx)
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800403:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 10             	pushl  0x10(%ebp)
  80040a:	ff 75 0c             	pushl  0xc(%ebp)
  80040d:	ff 75 08             	pushl  0x8(%ebp)
  800410:	e8 05 00 00 00       	call   80041a <vprintfmt>
	va_end(ap);
}
  800415:	83 c4 10             	add    $0x10,%esp
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	57                   	push   %edi
  80041e:	56                   	push   %esi
  80041f:	53                   	push   %ebx
  800420:	83 ec 2c             	sub    $0x2c,%esp
  800423:	8b 75 08             	mov    0x8(%ebp),%esi
  800426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800429:	8b 7d 10             	mov    0x10(%ebp),%edi
  80042c:	eb 12                	jmp    800440 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042e:	85 c0                	test   %eax,%eax
  800430:	0f 84 42 04 00 00    	je     800878 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	53                   	push   %ebx
  80043a:	50                   	push   %eax
  80043b:	ff d6                	call   *%esi
  80043d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800440:	83 c7 01             	add    $0x1,%edi
  800443:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800447:	83 f8 25             	cmp    $0x25,%eax
  80044a:	75 e2                	jne    80042e <vprintfmt+0x14>
  80044c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800450:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800465:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046a:	eb 07                	jmp    800473 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80046f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8d 47 01             	lea    0x1(%edi),%eax
  800476:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800479:	0f b6 07             	movzbl (%edi),%eax
  80047c:	0f b6 d0             	movzbl %al,%edx
  80047f:	83 e8 23             	sub    $0x23,%eax
  800482:	3c 55                	cmp    $0x55,%al
  800484:	0f 87 d3 03 00 00    	ja     80085d <vprintfmt+0x443>
  80048a:	0f b6 c0             	movzbl %al,%eax
  80048d:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800497:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80049b:	eb d6                	jmp    800473 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004b5:	83 f9 09             	cmp    $0x9,%ecx
  8004b8:	77 3f                	ja     8004f9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004bd:	eb e9                	jmp    8004a8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 40 04             	lea    0x4(%eax),%eax
  8004cd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d3:	eb 2a                	jmp    8004ff <vprintfmt+0xe5>
  8004d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
  8004df:	0f 49 d0             	cmovns %eax,%edx
  8004e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e8:	eb 89                	jmp    800473 <vprintfmt+0x59>
  8004ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f4:	e9 7a ff ff ff       	jmp    800473 <vprintfmt+0x59>
  8004f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800503:	0f 89 6a ff ff ff    	jns    800473 <vprintfmt+0x59>
				width = precision, precision = -1;
  800509:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80050c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800516:	e9 58 ff ff ff       	jmp    800473 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800521:	e9 4d ff ff ff       	jmp    800473 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 78 04             	lea    0x4(%eax),%edi
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	53                   	push   %ebx
  800530:	ff 30                	pushl  (%eax)
  800532:	ff d6                	call   *%esi
			break;
  800534:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800537:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80053d:	e9 fe fe ff ff       	jmp    800440 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 78 04             	lea    0x4(%eax),%edi
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	99                   	cltd   
  80054b:	31 d0                	xor    %edx,%eax
  80054d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054f:	83 f8 0f             	cmp    $0xf,%eax
  800552:	7f 0b                	jg     80055f <vprintfmt+0x145>
  800554:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  80055b:	85 d2                	test   %edx,%edx
  80055d:	75 1b                	jne    80057a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80055f:	50                   	push   %eax
  800560:	68 db 23 80 00       	push   $0x8023db
  800565:	53                   	push   %ebx
  800566:	56                   	push   %esi
  800567:	e8 91 fe ff ff       	call   8003fd <printfmt>
  80056c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800575:	e9 c6 fe ff ff       	jmp    800440 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80057a:	52                   	push   %edx
  80057b:	68 19 28 80 00       	push   $0x802819
  800580:	53                   	push   %ebx
  800581:	56                   	push   %esi
  800582:	e8 76 fe ff ff       	call   8003fd <printfmt>
  800587:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800590:	e9 ab fe ff ff       	jmp    800440 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	83 c0 04             	add    $0x4,%eax
  80059b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a3:	85 ff                	test   %edi,%edi
  8005a5:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
  8005aa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b1:	0f 8e 94 00 00 00    	jle    80064b <vprintfmt+0x231>
  8005b7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bb:	0f 84 98 00 00 00    	je     800659 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c7:	57                   	push   %edi
  8005c8:	e8 33 03 00 00       	call   800900 <strnlen>
  8005cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d0:	29 c1                	sub    %eax,%ecx
  8005d2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005d8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005df:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	eb 0f                	jmp    8005f5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ed:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ef 01             	sub    $0x1,%edi
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	85 ff                	test   %edi,%edi
  8005f7:	7f ed                	jg     8005e6 <vprintfmt+0x1cc>
  8005f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005ff:	85 c9                	test   %ecx,%ecx
  800601:	b8 00 00 00 00       	mov    $0x0,%eax
  800606:	0f 49 c1             	cmovns %ecx,%eax
  800609:	29 c1                	sub    %eax,%ecx
  80060b:	89 75 08             	mov    %esi,0x8(%ebp)
  80060e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800611:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800614:	89 cb                	mov    %ecx,%ebx
  800616:	eb 4d                	jmp    800665 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800618:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061c:	74 1b                	je     800639 <vprintfmt+0x21f>
  80061e:	0f be c0             	movsbl %al,%eax
  800621:	83 e8 20             	sub    $0x20,%eax
  800624:	83 f8 5e             	cmp    $0x5e,%eax
  800627:	76 10                	jbe    800639 <vprintfmt+0x21f>
					putch('?', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	ff 75 0c             	pushl  0xc(%ebp)
  80062f:	6a 3f                	push   $0x3f
  800631:	ff 55 08             	call   *0x8(%ebp)
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb 0d                	jmp    800646 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	ff 75 0c             	pushl  0xc(%ebp)
  80063f:	52                   	push   %edx
  800640:	ff 55 08             	call   *0x8(%ebp)
  800643:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	eb 1a                	jmp    800665 <vprintfmt+0x24b>
  80064b:	89 75 08             	mov    %esi,0x8(%ebp)
  80064e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800651:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800654:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800657:	eb 0c                	jmp    800665 <vprintfmt+0x24b>
  800659:	89 75 08             	mov    %esi,0x8(%ebp)
  80065c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800662:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800665:	83 c7 01             	add    $0x1,%edi
  800668:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066c:	0f be d0             	movsbl %al,%edx
  80066f:	85 d2                	test   %edx,%edx
  800671:	74 23                	je     800696 <vprintfmt+0x27c>
  800673:	85 f6                	test   %esi,%esi
  800675:	78 a1                	js     800618 <vprintfmt+0x1fe>
  800677:	83 ee 01             	sub    $0x1,%esi
  80067a:	79 9c                	jns    800618 <vprintfmt+0x1fe>
  80067c:	89 df                	mov    %ebx,%edi
  80067e:	8b 75 08             	mov    0x8(%ebp),%esi
  800681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800684:	eb 18                	jmp    80069e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 20                	push   $0x20
  80068c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068e:	83 ef 01             	sub    $0x1,%edi
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 08                	jmp    80069e <vprintfmt+0x284>
  800696:	89 df                	mov    %ebx,%edi
  800698:	8b 75 08             	mov    0x8(%ebp),%esi
  80069b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069e:	85 ff                	test   %edi,%edi
  8006a0:	7f e4                	jg     800686 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ab:	e9 90 fd ff ff       	jmp    800440 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b0:	83 f9 01             	cmp    $0x1,%ecx
  8006b3:	7e 19                	jle    8006ce <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 50 04             	mov    0x4(%eax),%edx
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 40 08             	lea    0x8(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cc:	eb 38                	jmp    800706 <vprintfmt+0x2ec>
	else if (lflag)
  8006ce:	85 c9                	test   %ecx,%ecx
  8006d0:	74 1b                	je     8006ed <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006da:	89 c1                	mov    %eax,%ecx
  8006dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 40 04             	lea    0x4(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006eb:	eb 19                	jmp    800706 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f5:	89 c1                	mov    %eax,%ecx
  8006f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800706:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800709:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80070c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800711:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800715:	0f 89 0e 01 00 00    	jns    800829 <vprintfmt+0x40f>
				putch('-', putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	6a 2d                	push   $0x2d
  800721:	ff d6                	call   *%esi
				num = -(long long) num;
  800723:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800726:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800729:	f7 da                	neg    %edx
  80072b:	83 d1 00             	adc    $0x0,%ecx
  80072e:	f7 d9                	neg    %ecx
  800730:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800733:	b8 0a 00 00 00       	mov    $0xa,%eax
  800738:	e9 ec 00 00 00       	jmp    800829 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073d:	83 f9 01             	cmp    $0x1,%ecx
  800740:	7e 18                	jle    80075a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8b 10                	mov    (%eax),%edx
  800747:	8b 48 04             	mov    0x4(%eax),%ecx
  80074a:	8d 40 08             	lea    0x8(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800750:	b8 0a 00 00 00       	mov    $0xa,%eax
  800755:	e9 cf 00 00 00       	jmp    800829 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80075a:	85 c9                	test   %ecx,%ecx
  80075c:	74 1a                	je     800778 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 10                	mov    (%eax),%edx
  800763:	b9 00 00 00 00       	mov    $0x0,%ecx
  800768:	8d 40 04             	lea    0x4(%eax),%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800773:	e9 b1 00 00 00       	jmp    800829 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800782:	8d 40 04             	lea    0x4(%eax),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800788:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078d:	e9 97 00 00 00       	jmp    800829 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 58                	push   $0x58
  800798:	ff d6                	call   *%esi
			putch('X', putdat);
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	53                   	push   %ebx
  80079e:	6a 58                	push   $0x58
  8007a0:	ff d6                	call   *%esi
			putch('X', putdat);
  8007a2:	83 c4 08             	add    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	6a 58                	push   $0x58
  8007a8:	ff d6                	call   *%esi
			break;
  8007aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007b0:	e9 8b fc ff ff       	jmp    800440 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	53                   	push   %ebx
  8007b9:	6a 30                	push   $0x30
  8007bb:	ff d6                	call   *%esi
			putch('x', putdat);
  8007bd:	83 c4 08             	add    $0x8,%esp
  8007c0:	53                   	push   %ebx
  8007c1:	6a 78                	push   $0x78
  8007c3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8b 10                	mov    (%eax),%edx
  8007ca:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cf:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007dd:	eb 4a                	jmp    800829 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007df:	83 f9 01             	cmp    $0x1,%ecx
  8007e2:	7e 15                	jle    8007f9 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8b 10                	mov    (%eax),%edx
  8007e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ec:	8d 40 08             	lea    0x8(%eax),%eax
  8007ef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007f2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f7:	eb 30                	jmp    800829 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007f9:	85 c9                	test   %ecx,%ecx
  8007fb:	74 17                	je     800814 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8b 10                	mov    (%eax),%edx
  800802:	b9 00 00 00 00       	mov    $0x0,%ecx
  800807:	8d 40 04             	lea    0x4(%eax),%eax
  80080a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80080d:	b8 10 00 00 00       	mov    $0x10,%eax
  800812:	eb 15                	jmp    800829 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	8b 10                	mov    (%eax),%edx
  800819:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081e:	8d 40 04             	lea    0x4(%eax),%eax
  800821:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800824:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800829:	83 ec 0c             	sub    $0xc,%esp
  80082c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800830:	57                   	push   %edi
  800831:	ff 75 e0             	pushl  -0x20(%ebp)
  800834:	50                   	push   %eax
  800835:	51                   	push   %ecx
  800836:	52                   	push   %edx
  800837:	89 da                	mov    %ebx,%edx
  800839:	89 f0                	mov    %esi,%eax
  80083b:	e8 f1 fa ff ff       	call   800331 <printnum>
			break;
  800840:	83 c4 20             	add    $0x20,%esp
  800843:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800846:	e9 f5 fb ff ff       	jmp    800440 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	52                   	push   %edx
  800850:	ff d6                	call   *%esi
			break;
  800852:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800858:	e9 e3 fb ff ff       	jmp    800440 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	6a 25                	push   $0x25
  800863:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	eb 03                	jmp    80086d <vprintfmt+0x453>
  80086a:	83 ef 01             	sub    $0x1,%edi
  80086d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800871:	75 f7                	jne    80086a <vprintfmt+0x450>
  800873:	e9 c8 fb ff ff       	jmp    800440 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800878:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	83 ec 18             	sub    $0x18,%esp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800893:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800896:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089d:	85 c0                	test   %eax,%eax
  80089f:	74 26                	je     8008c7 <vsnprintf+0x47>
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	7e 22                	jle    8008c7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a5:	ff 75 14             	pushl  0x14(%ebp)
  8008a8:	ff 75 10             	pushl  0x10(%ebp)
  8008ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ae:	50                   	push   %eax
  8008af:	68 e0 03 80 00       	push   $0x8003e0
  8008b4:	e8 61 fb ff ff       	call   80041a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	eb 05                	jmp    8008cc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    

008008ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d7:	50                   	push   %eax
  8008d8:	ff 75 10             	pushl  0x10(%ebp)
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	ff 75 08             	pushl  0x8(%ebp)
  8008e1:	e8 9a ff ff ff       	call   800880 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f3:	eb 03                	jmp    8008f8 <strlen+0x10>
		n++;
  8008f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fc:	75 f7                	jne    8008f5 <strlen+0xd>
		n++;
	return n;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800906:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800909:	ba 00 00 00 00       	mov    $0x0,%edx
  80090e:	eb 03                	jmp    800913 <strnlen+0x13>
		n++;
  800910:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800913:	39 c2                	cmp    %eax,%edx
  800915:	74 08                	je     80091f <strnlen+0x1f>
  800917:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80091b:	75 f3                	jne    800910 <strnlen+0x10>
  80091d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80092b:	89 c2                	mov    %eax,%edx
  80092d:	83 c2 01             	add    $0x1,%edx
  800930:	83 c1 01             	add    $0x1,%ecx
  800933:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800937:	88 5a ff             	mov    %bl,-0x1(%edx)
  80093a:	84 db                	test   %bl,%bl
  80093c:	75 ef                	jne    80092d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800948:	53                   	push   %ebx
  800949:	e8 9a ff ff ff       	call   8008e8 <strlen>
  80094e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800951:	ff 75 0c             	pushl  0xc(%ebp)
  800954:	01 d8                	add    %ebx,%eax
  800956:	50                   	push   %eax
  800957:	e8 c5 ff ff ff       	call   800921 <strcpy>
	return dst;
}
  80095c:	89 d8                	mov    %ebx,%eax
  80095e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 75 08             	mov    0x8(%ebp),%esi
  80096b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096e:	89 f3                	mov    %esi,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800973:	89 f2                	mov    %esi,%edx
  800975:	eb 0f                	jmp    800986 <strncpy+0x23>
		*dst++ = *src;
  800977:	83 c2 01             	add    $0x1,%edx
  80097a:	0f b6 01             	movzbl (%ecx),%eax
  80097d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800980:	80 39 01             	cmpb   $0x1,(%ecx)
  800983:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800986:	39 da                	cmp    %ebx,%edx
  800988:	75 ed                	jne    800977 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80098a:	89 f0                	mov    %esi,%eax
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 75 08             	mov    0x8(%ebp),%esi
  800998:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099b:	8b 55 10             	mov    0x10(%ebp),%edx
  80099e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a0:	85 d2                	test   %edx,%edx
  8009a2:	74 21                	je     8009c5 <strlcpy+0x35>
  8009a4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009a8:	89 f2                	mov    %esi,%edx
  8009aa:	eb 09                	jmp    8009b5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ac:	83 c2 01             	add    $0x1,%edx
  8009af:	83 c1 01             	add    $0x1,%ecx
  8009b2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b5:	39 c2                	cmp    %eax,%edx
  8009b7:	74 09                	je     8009c2 <strlcpy+0x32>
  8009b9:	0f b6 19             	movzbl (%ecx),%ebx
  8009bc:	84 db                	test   %bl,%bl
  8009be:	75 ec                	jne    8009ac <strlcpy+0x1c>
  8009c0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009c2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c5:	29 f0                	sub    %esi,%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d4:	eb 06                	jmp    8009dc <strcmp+0x11>
		p++, q++;
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009dc:	0f b6 01             	movzbl (%ecx),%eax
  8009df:	84 c0                	test   %al,%al
  8009e1:	74 04                	je     8009e7 <strcmp+0x1c>
  8009e3:	3a 02                	cmp    (%edx),%al
  8009e5:	74 ef                	je     8009d6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e7:	0f b6 c0             	movzbl %al,%eax
  8009ea:	0f b6 12             	movzbl (%edx),%edx
  8009ed:	29 d0                	sub    %edx,%eax
}
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fb:	89 c3                	mov    %eax,%ebx
  8009fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a00:	eb 06                	jmp    800a08 <strncmp+0x17>
		n--, p++, q++;
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a08:	39 d8                	cmp    %ebx,%eax
  800a0a:	74 15                	je     800a21 <strncmp+0x30>
  800a0c:	0f b6 08             	movzbl (%eax),%ecx
  800a0f:	84 c9                	test   %cl,%cl
  800a11:	74 04                	je     800a17 <strncmp+0x26>
  800a13:	3a 0a                	cmp    (%edx),%cl
  800a15:	74 eb                	je     800a02 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a17:	0f b6 00             	movzbl (%eax),%eax
  800a1a:	0f b6 12             	movzbl (%edx),%edx
  800a1d:	29 d0                	sub    %edx,%eax
  800a1f:	eb 05                	jmp    800a26 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a33:	eb 07                	jmp    800a3c <strchr+0x13>
		if (*s == c)
  800a35:	38 ca                	cmp    %cl,%dl
  800a37:	74 0f                	je     800a48 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a39:	83 c0 01             	add    $0x1,%eax
  800a3c:	0f b6 10             	movzbl (%eax),%edx
  800a3f:	84 d2                	test   %dl,%dl
  800a41:	75 f2                	jne    800a35 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a54:	eb 03                	jmp    800a59 <strfind+0xf>
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5c:	38 ca                	cmp    %cl,%dl
  800a5e:	74 04                	je     800a64 <strfind+0x1a>
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 f2                	jne    800a56 <strfind+0xc>
			break;
	return (char *) s;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a72:	85 c9                	test   %ecx,%ecx
  800a74:	74 36                	je     800aac <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a76:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7c:	75 28                	jne    800aa6 <memset+0x40>
  800a7e:	f6 c1 03             	test   $0x3,%cl
  800a81:	75 23                	jne    800aa6 <memset+0x40>
		c &= 0xFF;
  800a83:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a87:	89 d3                	mov    %edx,%ebx
  800a89:	c1 e3 08             	shl    $0x8,%ebx
  800a8c:	89 d6                	mov    %edx,%esi
  800a8e:	c1 e6 18             	shl    $0x18,%esi
  800a91:	89 d0                	mov    %edx,%eax
  800a93:	c1 e0 10             	shl    $0x10,%eax
  800a96:	09 f0                	or     %esi,%eax
  800a98:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a9a:	89 d8                	mov    %ebx,%eax
  800a9c:	09 d0                	or     %edx,%eax
  800a9e:	c1 e9 02             	shr    $0x2,%ecx
  800aa1:	fc                   	cld    
  800aa2:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa4:	eb 06                	jmp    800aac <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa9:	fc                   	cld    
  800aaa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aac:	89 f8                	mov    %edi,%eax
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac1:	39 c6                	cmp    %eax,%esi
  800ac3:	73 35                	jae    800afa <memmove+0x47>
  800ac5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac8:	39 d0                	cmp    %edx,%eax
  800aca:	73 2e                	jae    800afa <memmove+0x47>
		s += n;
		d += n;
  800acc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	89 d6                	mov    %edx,%esi
  800ad1:	09 fe                	or     %edi,%esi
  800ad3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad9:	75 13                	jne    800aee <memmove+0x3b>
  800adb:	f6 c1 03             	test   $0x3,%cl
  800ade:	75 0e                	jne    800aee <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ae0:	83 ef 04             	sub    $0x4,%edi
  800ae3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae6:	c1 e9 02             	shr    $0x2,%ecx
  800ae9:	fd                   	std    
  800aea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aec:	eb 09                	jmp    800af7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aee:	83 ef 01             	sub    $0x1,%edi
  800af1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800af4:	fd                   	std    
  800af5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af7:	fc                   	cld    
  800af8:	eb 1d                	jmp    800b17 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afa:	89 f2                	mov    %esi,%edx
  800afc:	09 c2                	or     %eax,%edx
  800afe:	f6 c2 03             	test   $0x3,%dl
  800b01:	75 0f                	jne    800b12 <memmove+0x5f>
  800b03:	f6 c1 03             	test   $0x3,%cl
  800b06:	75 0a                	jne    800b12 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b08:	c1 e9 02             	shr    $0x2,%ecx
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b10:	eb 05                	jmp    800b17 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b12:	89 c7                	mov    %eax,%edi
  800b14:	fc                   	cld    
  800b15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b1e:	ff 75 10             	pushl  0x10(%ebp)
  800b21:	ff 75 0c             	pushl  0xc(%ebp)
  800b24:	ff 75 08             	pushl  0x8(%ebp)
  800b27:	e8 87 ff ff ff       	call   800ab3 <memmove>
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b39:	89 c6                	mov    %eax,%esi
  800b3b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3e:	eb 1a                	jmp    800b5a <memcmp+0x2c>
		if (*s1 != *s2)
  800b40:	0f b6 08             	movzbl (%eax),%ecx
  800b43:	0f b6 1a             	movzbl (%edx),%ebx
  800b46:	38 d9                	cmp    %bl,%cl
  800b48:	74 0a                	je     800b54 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b4a:	0f b6 c1             	movzbl %cl,%eax
  800b4d:	0f b6 db             	movzbl %bl,%ebx
  800b50:	29 d8                	sub    %ebx,%eax
  800b52:	eb 0f                	jmp    800b63 <memcmp+0x35>
		s1++, s2++;
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5a:	39 f0                	cmp    %esi,%eax
  800b5c:	75 e2                	jne    800b40 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	53                   	push   %ebx
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b6e:	89 c1                	mov    %eax,%ecx
  800b70:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b73:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b77:	eb 0a                	jmp    800b83 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b79:	0f b6 10             	movzbl (%eax),%edx
  800b7c:	39 da                	cmp    %ebx,%edx
  800b7e:	74 07                	je     800b87 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b80:	83 c0 01             	add    $0x1,%eax
  800b83:	39 c8                	cmp    %ecx,%eax
  800b85:	72 f2                	jb     800b79 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b87:	5b                   	pop    %ebx
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
  800b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b96:	eb 03                	jmp    800b9b <strtol+0x11>
		s++;
  800b98:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	3c 20                	cmp    $0x20,%al
  800ba0:	74 f6                	je     800b98 <strtol+0xe>
  800ba2:	3c 09                	cmp    $0x9,%al
  800ba4:	74 f2                	je     800b98 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba6:	3c 2b                	cmp    $0x2b,%al
  800ba8:	75 0a                	jne    800bb4 <strtol+0x2a>
		s++;
  800baa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bad:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb2:	eb 11                	jmp    800bc5 <strtol+0x3b>
  800bb4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb9:	3c 2d                	cmp    $0x2d,%al
  800bbb:	75 08                	jne    800bc5 <strtol+0x3b>
		s++, neg = 1;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bcb:	75 15                	jne    800be2 <strtol+0x58>
  800bcd:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd0:	75 10                	jne    800be2 <strtol+0x58>
  800bd2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd6:	75 7c                	jne    800c54 <strtol+0xca>
		s += 2, base = 16;
  800bd8:	83 c1 02             	add    $0x2,%ecx
  800bdb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be0:	eb 16                	jmp    800bf8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800be2:	85 db                	test   %ebx,%ebx
  800be4:	75 12                	jne    800bf8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800beb:	80 39 30             	cmpb   $0x30,(%ecx)
  800bee:	75 08                	jne    800bf8 <strtol+0x6e>
		s++, base = 8;
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c00:	0f b6 11             	movzbl (%ecx),%edx
  800c03:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c06:	89 f3                	mov    %esi,%ebx
  800c08:	80 fb 09             	cmp    $0x9,%bl
  800c0b:	77 08                	ja     800c15 <strtol+0x8b>
			dig = *s - '0';
  800c0d:	0f be d2             	movsbl %dl,%edx
  800c10:	83 ea 30             	sub    $0x30,%edx
  800c13:	eb 22                	jmp    800c37 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c15:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c18:	89 f3                	mov    %esi,%ebx
  800c1a:	80 fb 19             	cmp    $0x19,%bl
  800c1d:	77 08                	ja     800c27 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c1f:	0f be d2             	movsbl %dl,%edx
  800c22:	83 ea 57             	sub    $0x57,%edx
  800c25:	eb 10                	jmp    800c37 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c27:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c2a:	89 f3                	mov    %esi,%ebx
  800c2c:	80 fb 19             	cmp    $0x19,%bl
  800c2f:	77 16                	ja     800c47 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c31:	0f be d2             	movsbl %dl,%edx
  800c34:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c37:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c3a:	7d 0b                	jge    800c47 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c3c:	83 c1 01             	add    $0x1,%ecx
  800c3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c43:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c45:	eb b9                	jmp    800c00 <strtol+0x76>

	if (endptr)
  800c47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4b:	74 0d                	je     800c5a <strtol+0xd0>
		*endptr = (char *) s;
  800c4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c50:	89 0e                	mov    %ecx,(%esi)
  800c52:	eb 06                	jmp    800c5a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c54:	85 db                	test   %ebx,%ebx
  800c56:	74 98                	je     800bf0 <strtol+0x66>
  800c58:	eb 9e                	jmp    800bf8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c5a:	89 c2                	mov    %eax,%edx
  800c5c:	f7 da                	neg    %edx
  800c5e:	85 ff                	test   %edi,%edi
  800c60:	0f 45 c2             	cmovne %edx,%eax
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 c3                	mov    %eax,%ebx
  800c7b:	89 c7                	mov    %eax,%edi
  800c7d:	89 c6                	mov    %eax,%esi
  800c7f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 01 00 00 00       	mov    $0x1,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 cb                	mov    %ecx,%ebx
  800cbd:	89 cf                	mov    %ecx,%edi
  800cbf:	89 ce                	mov    %ecx,%esi
  800cc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 17                	jle    800cde <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 03                	push   $0x3
  800ccd:	68 bf 26 80 00       	push   $0x8026bf
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 dc 26 80 00       	push   $0x8026dc
  800cd9:	e8 66 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf1:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf6:	89 d1                	mov    %edx,%ecx
  800cf8:	89 d3                	mov    %edx,%ebx
  800cfa:	89 d7                	mov    %edx,%edi
  800cfc:	89 d6                	mov    %edx,%esi
  800cfe:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_yield>:

void
sys_yield(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	be 00 00 00 00       	mov    $0x0,%esi
  800d32:	b8 04 00 00 00       	mov    $0x4,%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d40:	89 f7                	mov    %esi,%edi
  800d42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 04                	push   $0x4
  800d4e:	68 bf 26 80 00       	push   $0x8026bf
  800d53:	6a 23                	push   $0x23
  800d55:	68 dc 26 80 00       	push   $0x8026dc
  800d5a:	e8 e5 f4 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	b8 05 00 00 00       	mov    $0x5,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d81:	8b 75 18             	mov    0x18(%ebp),%esi
  800d84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 05                	push   $0x5
  800d90:	68 bf 26 80 00       	push   $0x8026bf
  800d95:	6a 23                	push   $0x23
  800d97:	68 dc 26 80 00       	push   $0x8026dc
  800d9c:	e8 a3 f4 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db7:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	89 df                	mov    %ebx,%edi
  800dc4:	89 de                	mov    %ebx,%esi
  800dc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 17                	jle    800de3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	50                   	push   %eax
  800dd0:	6a 06                	push   $0x6
  800dd2:	68 bf 26 80 00       	push   $0x8026bf
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 dc 26 80 00       	push   $0x8026dc
  800dde:	e8 61 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	89 df                	mov    %ebx,%edi
  800e06:	89 de                	mov    %ebx,%esi
  800e08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	7e 17                	jle    800e25 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	50                   	push   %eax
  800e12:	6a 08                	push   $0x8
  800e14:	68 bf 26 80 00       	push   $0x8026bf
  800e19:	6a 23                	push   $0x23
  800e1b:	68 dc 26 80 00       	push   $0x8026dc
  800e20:	e8 1f f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
  800e46:	89 df                	mov    %ebx,%edi
  800e48:	89 de                	mov    %ebx,%esi
  800e4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 17                	jle    800e67 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	50                   	push   %eax
  800e54:	6a 09                	push   $0x9
  800e56:	68 bf 26 80 00       	push   $0x8026bf
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 dc 26 80 00       	push   $0x8026dc
  800e62:	e8 dd f3 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	89 df                	mov    %ebx,%edi
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	7e 17                	jle    800ea9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	50                   	push   %eax
  800e96:	6a 0a                	push   $0xa
  800e98:	68 bf 26 80 00       	push   $0x8026bf
  800e9d:	6a 23                	push   $0x23
  800e9f:	68 dc 26 80 00       	push   $0x8026dc
  800ea4:	e8 9b f3 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb7:	be 00 00 00 00       	mov    $0x0,%esi
  800ebc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eea:	89 cb                	mov    %ecx,%ebx
  800eec:	89 cf                	mov    %ecx,%edi
  800eee:	89 ce                	mov    %ecx,%esi
  800ef0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	7e 17                	jle    800f0d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	50                   	push   %eax
  800efa:	6a 0d                	push   $0xd
  800efc:	68 bf 26 80 00       	push   $0x8026bf
  800f01:	6a 23                	push   $0x23
  800f03:	68 dc 26 80 00       	push   $0x8026dc
  800f08:	e8 37 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
  800f1b:	83 ec 0c             	sub    $0xc,%esp
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f21:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800f23:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800f26:	e8 bb fd ff ff       	call   800ce6 <sys_getenvid>
  800f2b:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800f2d:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800f33:	75 25                	jne    800f5a <pgfault+0x45>
  800f35:	89 d8                	mov    %ebx,%eax
  800f37:	c1 e8 0c             	shr    $0xc,%eax
  800f3a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f41:	f6 c4 08             	test   $0x8,%ah
  800f44:	75 14                	jne    800f5a <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800f46:	83 ec 04             	sub    $0x4,%esp
  800f49:	68 ec 26 80 00       	push   $0x8026ec
  800f4e:	6a 1e                	push   $0x1e
  800f50:	68 11 27 80 00       	push   $0x802711
  800f55:	e8 ea f2 ff ff       	call   800244 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	6a 07                	push   $0x7
  800f5f:	68 00 f0 7f 00       	push   $0x7ff000
  800f64:	56                   	push   %esi
  800f65:	e8 ba fd ff ff       	call   800d24 <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800f6a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f70:	83 c4 0c             	add    $0xc,%esp
  800f73:	68 00 10 00 00       	push   $0x1000
  800f78:	53                   	push   %ebx
  800f79:	68 00 f0 7f 00       	push   $0x7ff000
  800f7e:	e8 30 fb ff ff       	call   800ab3 <memmove>

	sys_page_unmap(curenvid, addr);
  800f83:	83 c4 08             	add    $0x8,%esp
  800f86:	53                   	push   %ebx
  800f87:	56                   	push   %esi
  800f88:	e8 1c fe ff ff       	call   800da9 <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800f8d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f94:	53                   	push   %ebx
  800f95:	56                   	push   %esi
  800f96:	68 00 f0 7f 00       	push   $0x7ff000
  800f9b:	56                   	push   %esi
  800f9c:	e8 c6 fd ff ff       	call   800d67 <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800fa1:	83 c4 18             	add    $0x18,%esp
  800fa4:	68 00 f0 7f 00       	push   $0x7ff000
  800fa9:	56                   	push   %esi
  800faa:	e8 fa fd ff ff       	call   800da9 <sys_page_unmap>
}
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
  800fc0:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  800fc3:	e8 1e fd ff ff       	call   800ce6 <sys_getenvid>
	set_pgfault_handler(pgfault);
  800fc8:	83 ec 0c             	sub    $0xc,%esp
  800fcb:	68 15 0f 80 00       	push   $0x800f15
  800fd0:	e8 bd 0f 00 00       	call   801f92 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fd5:	b8 07 00 00 00       	mov    $0x7,%eax
  800fda:	cd 30                	int    $0x30
  800fdc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800fdf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	79 12                	jns    800ffb <fork+0x41>
	    panic("fork error: %e", new_envid);
  800fe9:	50                   	push   %eax
  800fea:	68 1c 27 80 00       	push   $0x80271c
  800fef:	6a 75                	push   $0x75
  800ff1:	68 11 27 80 00       	push   $0x802711
  800ff6:	e8 49 f2 ff ff       	call   800244 <_panic>
  800ffb:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  801000:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801004:	75 1c                	jne    801022 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  801006:	e8 db fc ff ff       	call   800ce6 <sys_getenvid>
  80100b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801010:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801013:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801018:	a3 04 40 80 00       	mov    %eax,0x804004
  80101d:	e9 27 01 00 00       	jmp    801149 <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  801022:	89 f8                	mov    %edi,%eax
  801024:	c1 e8 16             	shr    $0x16,%eax
  801027:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102e:	a8 01                	test   $0x1,%al
  801030:	0f 84 d2 00 00 00    	je     801108 <fork+0x14e>
  801036:	89 fb                	mov    %edi,%ebx
  801038:	c1 eb 0c             	shr    $0xc,%ebx
  80103b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801042:	a8 01                	test   $0x1,%al
  801044:	0f 84 be 00 00 00    	je     801108 <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  80104a:	e8 97 fc ff ff       	call   800ce6 <sys_getenvid>
  80104f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  801052:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  801059:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  80105e:	a8 02                	test   $0x2,%al
  801060:	75 1d                	jne    80107f <fork+0xc5>
  801062:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801069:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  80106e:	83 f8 01             	cmp    $0x1,%eax
  801071:	19 f6                	sbb    %esi,%esi
  801073:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  801079:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  80107f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801086:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  80108b:	b8 07 0e 00 00       	mov    $0xe07,%eax
  801090:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  801093:	89 d8                	mov    %ebx,%eax
  801095:	c1 e0 0c             	shl    $0xc,%eax
  801098:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	56                   	push   %esi
  80109f:	50                   	push   %eax
  8010a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8010a3:	50                   	push   %eax
  8010a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a7:	e8 bb fc ff ff       	call   800d67 <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 12                	jns    8010c5 <fork+0x10b>
		panic("duppage error: %e", r);
  8010b3:	50                   	push   %eax
  8010b4:	68 2b 27 80 00       	push   $0x80272b
  8010b9:	6a 4d                	push   $0x4d
  8010bb:	68 11 27 80 00       	push   $0x802711
  8010c0:	e8 7f f1 ff ff       	call   800244 <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  8010c5:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010cc:	a8 02                	test   $0x2,%al
  8010ce:	75 0c                	jne    8010dc <fork+0x122>
  8010d0:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010d7:	f6 c4 08             	test   $0x8,%ah
  8010da:	74 2c                	je     801108 <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	56                   	push   %esi
  8010e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010e3:	52                   	push   %edx
  8010e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e7:	50                   	push   %eax
  8010e8:	52                   	push   %edx
  8010e9:	50                   	push   %eax
  8010ea:	e8 78 fc ff ff       	call   800d67 <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 12                	jns    801108 <fork+0x14e>
			panic("duppage error: %e", r);
  8010f6:	50                   	push   %eax
  8010f7:	68 2b 27 80 00       	push   $0x80272b
  8010fc:	6a 53                	push   $0x53
  8010fe:	68 11 27 80 00       	push   $0x802711
  801103:	e8 3c f1 ff ff       	call   800244 <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  801108:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80110e:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  801114:	0f 85 08 ff ff ff    	jne    801022 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  80111a:	83 ec 04             	sub    $0x4,%esp
  80111d:	6a 07                	push   $0x7
  80111f:	68 00 f0 bf ee       	push   $0xeebff000
  801124:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801127:	56                   	push   %esi
  801128:	e8 f7 fb ff ff       	call   800d24 <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  80112d:	83 c4 08             	add    $0x8,%esp
  801130:	68 d7 1f 80 00       	push   $0x801fd7
  801135:	56                   	push   %esi
  801136:	e8 34 fd ff ff       	call   800e6f <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  80113b:	83 c4 08             	add    $0x8,%esp
  80113e:	6a 02                	push   $0x2
  801140:	56                   	push   %esi
  801141:	e8 a5 fc ff ff       	call   800deb <sys_env_set_status>
  801146:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  801149:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80114c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5f                   	pop    %edi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <sfork>:

// Challenge!
int
sfork(void)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80115a:	68 3d 27 80 00       	push   $0x80273d
  80115f:	68 8b 00 00 00       	push   $0x8b
  801164:	68 11 27 80 00       	push   $0x802711
  801169:	e8 d6 f0 ff ff       	call   800244 <_panic>

0080116e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	8b 75 08             	mov    0x8(%ebp),%esi
  801176:	8b 45 0c             	mov    0xc(%ebp),%eax
  801179:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  80117c:	85 c0                	test   %eax,%eax
  80117e:	74 0e                	je     80118e <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	50                   	push   %eax
  801184:	e8 4b fd ff ff       	call   800ed4 <sys_ipc_recv>
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	eb 0d                	jmp    80119b <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  80118e:	83 ec 0c             	sub    $0xc,%esp
  801191:	6a ff                	push   $0xffffffff
  801193:	e8 3c fd ff ff       	call   800ed4 <sys_ipc_recv>
  801198:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  80119b:	85 c0                	test   %eax,%eax
  80119d:	79 16                	jns    8011b5 <ipc_recv+0x47>

		if (from_env_store != NULL)
  80119f:	85 f6                	test   %esi,%esi
  8011a1:	74 06                	je     8011a9 <ipc_recv+0x3b>
			*from_env_store = 0;
  8011a3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  8011a9:	85 db                	test   %ebx,%ebx
  8011ab:	74 2c                	je     8011d9 <ipc_recv+0x6b>
			*perm_store = 0;
  8011ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011b3:	eb 24                	jmp    8011d9 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  8011b5:	85 f6                	test   %esi,%esi
  8011b7:	74 0a                	je     8011c3 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  8011b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011be:	8b 40 74             	mov    0x74(%eax),%eax
  8011c1:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  8011c3:	85 db                	test   %ebx,%ebx
  8011c5:	74 0a                	je     8011d1 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  8011c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cc:	8b 40 78             	mov    0x78(%eax),%eax
  8011cf:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8011d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d6:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8011d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 0c             	sub    $0xc,%esp
  8011e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  8011f2:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  8011f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011f9:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011fc:	ff 75 14             	pushl  0x14(%ebp)
  8011ff:	53                   	push   %ebx
  801200:	56                   	push   %esi
  801201:	57                   	push   %edi
  801202:	e8 aa fc ff ff       	call   800eb1 <sys_ipc_try_send>
		if (r >= 0)
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	85 c0                	test   %eax,%eax
  80120c:	79 1e                	jns    80122c <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  80120e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801211:	74 12                	je     801225 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801213:	50                   	push   %eax
  801214:	68 53 27 80 00       	push   $0x802753
  801219:	6a 49                	push   $0x49
  80121b:	68 66 27 80 00       	push   $0x802766
  801220:	e8 1f f0 ff ff       	call   800244 <_panic>
	
		sys_yield();
  801225:	e8 db fa ff ff       	call   800d05 <sys_yield>
	}
  80122a:	eb d0                	jmp    8011fc <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  80122c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5f                   	pop    %edi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80123f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801242:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801248:	8b 52 50             	mov    0x50(%edx),%edx
  80124b:	39 ca                	cmp    %ecx,%edx
  80124d:	75 0d                	jne    80125c <ipc_find_env+0x28>
			return envs[i].env_id;
  80124f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801252:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801257:	8b 40 48             	mov    0x48(%eax),%eax
  80125a:	eb 0f                	jmp    80126b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80125c:	83 c0 01             	add    $0x1,%eax
  80125f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801264:	75 d9                	jne    80123f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801270:	8b 45 08             	mov    0x8(%ebp),%eax
  801273:	05 00 00 00 30       	add    $0x30000000,%eax
  801278:	c1 e8 0c             	shr    $0xc,%eax
}
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801280:	8b 45 08             	mov    0x8(%ebp),%eax
  801283:	05 00 00 00 30       	add    $0x30000000,%eax
  801288:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80128d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80129f:	89 c2                	mov    %eax,%edx
  8012a1:	c1 ea 16             	shr    $0x16,%edx
  8012a4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ab:	f6 c2 01             	test   $0x1,%dl
  8012ae:	74 11                	je     8012c1 <fd_alloc+0x2d>
  8012b0:	89 c2                	mov    %eax,%edx
  8012b2:	c1 ea 0c             	shr    $0xc,%edx
  8012b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bc:	f6 c2 01             	test   $0x1,%dl
  8012bf:	75 09                	jne    8012ca <fd_alloc+0x36>
			*fd_store = fd;
  8012c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c8:	eb 17                	jmp    8012e1 <fd_alloc+0x4d>
  8012ca:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012cf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d4:	75 c9                	jne    80129f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012dc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e9:	83 f8 1f             	cmp    $0x1f,%eax
  8012ec:	77 36                	ja     801324 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ee:	c1 e0 0c             	shl    $0xc,%eax
  8012f1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f6:	89 c2                	mov    %eax,%edx
  8012f8:	c1 ea 16             	shr    $0x16,%edx
  8012fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801302:	f6 c2 01             	test   $0x1,%dl
  801305:	74 24                	je     80132b <fd_lookup+0x48>
  801307:	89 c2                	mov    %eax,%edx
  801309:	c1 ea 0c             	shr    $0xc,%edx
  80130c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801313:	f6 c2 01             	test   $0x1,%dl
  801316:	74 1a                	je     801332 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801318:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131b:	89 02                	mov    %eax,(%edx)
	return 0;
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
  801322:	eb 13                	jmp    801337 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801324:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801329:	eb 0c                	jmp    801337 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80132b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801330:	eb 05                	jmp    801337 <fd_lookup+0x54>
  801332:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801342:	ba f0 27 80 00       	mov    $0x8027f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801347:	eb 13                	jmp    80135c <dev_lookup+0x23>
  801349:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80134c:	39 08                	cmp    %ecx,(%eax)
  80134e:	75 0c                	jne    80135c <dev_lookup+0x23>
			*dev = devtab[i];
  801350:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801353:	89 01                	mov    %eax,(%ecx)
			return 0;
  801355:	b8 00 00 00 00       	mov    $0x0,%eax
  80135a:	eb 2e                	jmp    80138a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80135c:	8b 02                	mov    (%edx),%eax
  80135e:	85 c0                	test   %eax,%eax
  801360:	75 e7                	jne    801349 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801362:	a1 04 40 80 00       	mov    0x804004,%eax
  801367:	8b 40 48             	mov    0x48(%eax),%eax
  80136a:	83 ec 04             	sub    $0x4,%esp
  80136d:	51                   	push   %ecx
  80136e:	50                   	push   %eax
  80136f:	68 70 27 80 00       	push   $0x802770
  801374:	e8 a4 ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  801379:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	83 ec 10             	sub    $0x10,%esp
  801394:	8b 75 08             	mov    0x8(%ebp),%esi
  801397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80139a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013a4:	c1 e8 0c             	shr    $0xc,%eax
  8013a7:	50                   	push   %eax
  8013a8:	e8 36 ff ff ff       	call   8012e3 <fd_lookup>
  8013ad:	83 c4 08             	add    $0x8,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 05                	js     8013b9 <fd_close+0x2d>
	    || fd != fd2)
  8013b4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013b7:	74 0c                	je     8013c5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013b9:	84 db                	test   %bl,%bl
  8013bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c0:	0f 44 c2             	cmove  %edx,%eax
  8013c3:	eb 41                	jmp    801406 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	ff 36                	pushl  (%esi)
  8013ce:	e8 66 ff ff ff       	call   801339 <dev_lookup>
  8013d3:	89 c3                	mov    %eax,%ebx
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 1a                	js     8013f6 <fd_close+0x6a>
		if (dev->dev_close)
  8013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013df:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013e2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	74 0b                	je     8013f6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	56                   	push   %esi
  8013ef:	ff d0                	call   *%eax
  8013f1:	89 c3                	mov    %eax,%ebx
  8013f3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	56                   	push   %esi
  8013fa:	6a 00                	push   $0x0
  8013fc:	e8 a8 f9 ff ff       	call   800da9 <sys_page_unmap>
	return r;
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	89 d8                	mov    %ebx,%eax
}
  801406:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801409:	5b                   	pop    %ebx
  80140a:	5e                   	pop    %esi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801413:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801416:	50                   	push   %eax
  801417:	ff 75 08             	pushl  0x8(%ebp)
  80141a:	e8 c4 fe ff ff       	call   8012e3 <fd_lookup>
  80141f:	83 c4 08             	add    $0x8,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	78 10                	js     801436 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	6a 01                	push   $0x1
  80142b:	ff 75 f4             	pushl  -0xc(%ebp)
  80142e:	e8 59 ff ff ff       	call   80138c <fd_close>
  801433:	83 c4 10             	add    $0x10,%esp
}
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <close_all>:

void
close_all(void)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	53                   	push   %ebx
  80143c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80143f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801444:	83 ec 0c             	sub    $0xc,%esp
  801447:	53                   	push   %ebx
  801448:	e8 c0 ff ff ff       	call   80140d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80144d:	83 c3 01             	add    $0x1,%ebx
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	83 fb 20             	cmp    $0x20,%ebx
  801456:	75 ec                	jne    801444 <close_all+0xc>
		close(i);
}
  801458:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	57                   	push   %edi
  801461:	56                   	push   %esi
  801462:	53                   	push   %ebx
  801463:	83 ec 2c             	sub    $0x2c,%esp
  801466:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801469:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	ff 75 08             	pushl  0x8(%ebp)
  801470:	e8 6e fe ff ff       	call   8012e3 <fd_lookup>
  801475:	83 c4 08             	add    $0x8,%esp
  801478:	85 c0                	test   %eax,%eax
  80147a:	0f 88 c1 00 00 00    	js     801541 <dup+0xe4>
		return r;
	close(newfdnum);
  801480:	83 ec 0c             	sub    $0xc,%esp
  801483:	56                   	push   %esi
  801484:	e8 84 ff ff ff       	call   80140d <close>

	newfd = INDEX2FD(newfdnum);
  801489:	89 f3                	mov    %esi,%ebx
  80148b:	c1 e3 0c             	shl    $0xc,%ebx
  80148e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801494:	83 c4 04             	add    $0x4,%esp
  801497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80149a:	e8 de fd ff ff       	call   80127d <fd2data>
  80149f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014a1:	89 1c 24             	mov    %ebx,(%esp)
  8014a4:	e8 d4 fd ff ff       	call   80127d <fd2data>
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014af:	89 f8                	mov    %edi,%eax
  8014b1:	c1 e8 16             	shr    $0x16,%eax
  8014b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014bb:	a8 01                	test   $0x1,%al
  8014bd:	74 37                	je     8014f6 <dup+0x99>
  8014bf:	89 f8                	mov    %edi,%eax
  8014c1:	c1 e8 0c             	shr    $0xc,%eax
  8014c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014cb:	f6 c2 01             	test   $0x1,%dl
  8014ce:	74 26                	je     8014f6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d7:	83 ec 0c             	sub    $0xc,%esp
  8014da:	25 07 0e 00 00       	and    $0xe07,%eax
  8014df:	50                   	push   %eax
  8014e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e3:	6a 00                	push   $0x0
  8014e5:	57                   	push   %edi
  8014e6:	6a 00                	push   $0x0
  8014e8:	e8 7a f8 ff ff       	call   800d67 <sys_page_map>
  8014ed:	89 c7                	mov    %eax,%edi
  8014ef:	83 c4 20             	add    $0x20,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 2e                	js     801524 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014f9:	89 d0                	mov    %edx,%eax
  8014fb:	c1 e8 0c             	shr    $0xc,%eax
  8014fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	25 07 0e 00 00       	and    $0xe07,%eax
  80150d:	50                   	push   %eax
  80150e:	53                   	push   %ebx
  80150f:	6a 00                	push   $0x0
  801511:	52                   	push   %edx
  801512:	6a 00                	push   $0x0
  801514:	e8 4e f8 ff ff       	call   800d67 <sys_page_map>
  801519:	89 c7                	mov    %eax,%edi
  80151b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80151e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801520:	85 ff                	test   %edi,%edi
  801522:	79 1d                	jns    801541 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	53                   	push   %ebx
  801528:	6a 00                	push   $0x0
  80152a:	e8 7a f8 ff ff       	call   800da9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80152f:	83 c4 08             	add    $0x8,%esp
  801532:	ff 75 d4             	pushl  -0x2c(%ebp)
  801535:	6a 00                	push   $0x0
  801537:	e8 6d f8 ff ff       	call   800da9 <sys_page_unmap>
	return r;
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	89 f8                	mov    %edi,%eax
}
  801541:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	5f                   	pop    %edi
  801547:	5d                   	pop    %ebp
  801548:	c3                   	ret    

00801549 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	53                   	push   %ebx
  80154d:	83 ec 14             	sub    $0x14,%esp
  801550:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801553:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	53                   	push   %ebx
  801558:	e8 86 fd ff ff       	call   8012e3 <fd_lookup>
  80155d:	83 c4 08             	add    $0x8,%esp
  801560:	89 c2                	mov    %eax,%edx
  801562:	85 c0                	test   %eax,%eax
  801564:	78 6d                	js     8015d3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801566:	83 ec 08             	sub    $0x8,%esp
  801569:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156c:	50                   	push   %eax
  80156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801570:	ff 30                	pushl  (%eax)
  801572:	e8 c2 fd ff ff       	call   801339 <dev_lookup>
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 4c                	js     8015ca <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80157e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801581:	8b 42 08             	mov    0x8(%edx),%eax
  801584:	83 e0 03             	and    $0x3,%eax
  801587:	83 f8 01             	cmp    $0x1,%eax
  80158a:	75 21                	jne    8015ad <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80158c:	a1 04 40 80 00       	mov    0x804004,%eax
  801591:	8b 40 48             	mov    0x48(%eax),%eax
  801594:	83 ec 04             	sub    $0x4,%esp
  801597:	53                   	push   %ebx
  801598:	50                   	push   %eax
  801599:	68 b4 27 80 00       	push   $0x8027b4
  80159e:	e8 7a ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ab:	eb 26                	jmp    8015d3 <read+0x8a>
	}
	if (!dev->dev_read)
  8015ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b0:	8b 40 08             	mov    0x8(%eax),%eax
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	74 17                	je     8015ce <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015b7:	83 ec 04             	sub    $0x4,%esp
  8015ba:	ff 75 10             	pushl  0x10(%ebp)
  8015bd:	ff 75 0c             	pushl  0xc(%ebp)
  8015c0:	52                   	push   %edx
  8015c1:	ff d0                	call   *%eax
  8015c3:	89 c2                	mov    %eax,%edx
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	eb 09                	jmp    8015d3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	eb 05                	jmp    8015d3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015d3:	89 d0                	mov    %edx,%eax
  8015d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	57                   	push   %edi
  8015de:	56                   	push   %esi
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ee:	eb 21                	jmp    801611 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f0:	83 ec 04             	sub    $0x4,%esp
  8015f3:	89 f0                	mov    %esi,%eax
  8015f5:	29 d8                	sub    %ebx,%eax
  8015f7:	50                   	push   %eax
  8015f8:	89 d8                	mov    %ebx,%eax
  8015fa:	03 45 0c             	add    0xc(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	57                   	push   %edi
  8015ff:	e8 45 ff ff ff       	call   801549 <read>
		if (m < 0)
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	85 c0                	test   %eax,%eax
  801609:	78 10                	js     80161b <readn+0x41>
			return m;
		if (m == 0)
  80160b:	85 c0                	test   %eax,%eax
  80160d:	74 0a                	je     801619 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160f:	01 c3                	add    %eax,%ebx
  801611:	39 f3                	cmp    %esi,%ebx
  801613:	72 db                	jb     8015f0 <readn+0x16>
  801615:	89 d8                	mov    %ebx,%eax
  801617:	eb 02                	jmp    80161b <readn+0x41>
  801619:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80161b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161e:	5b                   	pop    %ebx
  80161f:	5e                   	pop    %esi
  801620:	5f                   	pop    %edi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    

00801623 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	53                   	push   %ebx
  801627:	83 ec 14             	sub    $0x14,%esp
  80162a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	53                   	push   %ebx
  801632:	e8 ac fc ff ff       	call   8012e3 <fd_lookup>
  801637:	83 c4 08             	add    $0x8,%esp
  80163a:	89 c2                	mov    %eax,%edx
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 68                	js     8016a8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801640:	83 ec 08             	sub    $0x8,%esp
  801643:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801646:	50                   	push   %eax
  801647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164a:	ff 30                	pushl  (%eax)
  80164c:	e8 e8 fc ff ff       	call   801339 <dev_lookup>
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	85 c0                	test   %eax,%eax
  801656:	78 47                	js     80169f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801658:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165f:	75 21                	jne    801682 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801661:	a1 04 40 80 00       	mov    0x804004,%eax
  801666:	8b 40 48             	mov    0x48(%eax),%eax
  801669:	83 ec 04             	sub    $0x4,%esp
  80166c:	53                   	push   %ebx
  80166d:	50                   	push   %eax
  80166e:	68 d0 27 80 00       	push   $0x8027d0
  801673:	e8 a5 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801680:	eb 26                	jmp    8016a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801682:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801685:	8b 52 0c             	mov    0xc(%edx),%edx
  801688:	85 d2                	test   %edx,%edx
  80168a:	74 17                	je     8016a3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80168c:	83 ec 04             	sub    $0x4,%esp
  80168f:	ff 75 10             	pushl  0x10(%ebp)
  801692:	ff 75 0c             	pushl  0xc(%ebp)
  801695:	50                   	push   %eax
  801696:	ff d2                	call   *%edx
  801698:	89 c2                	mov    %eax,%edx
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	eb 09                	jmp    8016a8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169f:	89 c2                	mov    %eax,%edx
  8016a1:	eb 05                	jmp    8016a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016a8:	89 d0                	mov    %edx,%eax
  8016aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <seek>:

int
seek(int fdnum, off_t offset)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016b8:	50                   	push   %eax
  8016b9:	ff 75 08             	pushl  0x8(%ebp)
  8016bc:	e8 22 fc ff ff       	call   8012e3 <fd_lookup>
  8016c1:	83 c4 08             	add    $0x8,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 0e                	js     8016d6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ce:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	53                   	push   %ebx
  8016dc:	83 ec 14             	sub    $0x14,%esp
  8016df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e5:	50                   	push   %eax
  8016e6:	53                   	push   %ebx
  8016e7:	e8 f7 fb ff ff       	call   8012e3 <fd_lookup>
  8016ec:	83 c4 08             	add    $0x8,%esp
  8016ef:	89 c2                	mov    %eax,%edx
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 65                	js     80175a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fb:	50                   	push   %eax
  8016fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ff:	ff 30                	pushl  (%eax)
  801701:	e8 33 fc ff ff       	call   801339 <dev_lookup>
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	85 c0                	test   %eax,%eax
  80170b:	78 44                	js     801751 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801710:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801714:	75 21                	jne    801737 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801716:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80171b:	8b 40 48             	mov    0x48(%eax),%eax
  80171e:	83 ec 04             	sub    $0x4,%esp
  801721:	53                   	push   %ebx
  801722:	50                   	push   %eax
  801723:	68 90 27 80 00       	push   $0x802790
  801728:	e8 f0 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801735:	eb 23                	jmp    80175a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801737:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173a:	8b 52 18             	mov    0x18(%edx),%edx
  80173d:	85 d2                	test   %edx,%edx
  80173f:	74 14                	je     801755 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	ff 75 0c             	pushl  0xc(%ebp)
  801747:	50                   	push   %eax
  801748:	ff d2                	call   *%edx
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	eb 09                	jmp    80175a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801751:	89 c2                	mov    %eax,%edx
  801753:	eb 05                	jmp    80175a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801755:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80175a:	89 d0                	mov    %edx,%eax
  80175c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	53                   	push   %ebx
  801765:	83 ec 14             	sub    $0x14,%esp
  801768:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176e:	50                   	push   %eax
  80176f:	ff 75 08             	pushl  0x8(%ebp)
  801772:	e8 6c fb ff ff       	call   8012e3 <fd_lookup>
  801777:	83 c4 08             	add    $0x8,%esp
  80177a:	89 c2                	mov    %eax,%edx
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 58                	js     8017d8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801786:	50                   	push   %eax
  801787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178a:	ff 30                	pushl  (%eax)
  80178c:	e8 a8 fb ff ff       	call   801339 <dev_lookup>
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	85 c0                	test   %eax,%eax
  801796:	78 37                	js     8017cf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80179f:	74 32                	je     8017d3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ab:	00 00 00 
	stat->st_isdir = 0;
  8017ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b5:	00 00 00 
	stat->st_dev = dev;
  8017b8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	53                   	push   %ebx
  8017c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c5:	ff 50 14             	call   *0x14(%eax)
  8017c8:	89 c2                	mov    %eax,%edx
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	eb 09                	jmp    8017d8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cf:	89 c2                	mov    %eax,%edx
  8017d1:	eb 05                	jmp    8017d8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017d8:	89 d0                	mov    %edx,%eax
  8017da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    

008017df <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	56                   	push   %esi
  8017e3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e4:	83 ec 08             	sub    $0x8,%esp
  8017e7:	6a 00                	push   $0x0
  8017e9:	ff 75 08             	pushl  0x8(%ebp)
  8017ec:	e8 e3 01 00 00       	call   8019d4 <open>
  8017f1:	89 c3                	mov    %eax,%ebx
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 1b                	js     801815 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	ff 75 0c             	pushl  0xc(%ebp)
  801800:	50                   	push   %eax
  801801:	e8 5b ff ff ff       	call   801761 <fstat>
  801806:	89 c6                	mov    %eax,%esi
	close(fd);
  801808:	89 1c 24             	mov    %ebx,(%esp)
  80180b:	e8 fd fb ff ff       	call   80140d <close>
	return r;
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	89 f0                	mov    %esi,%eax
}
  801815:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	89 c6                	mov    %eax,%esi
  801823:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801825:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80182c:	75 12                	jne    801840 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80182e:	83 ec 0c             	sub    $0xc,%esp
  801831:	6a 01                	push   $0x1
  801833:	e8 fc f9 ff ff       	call   801234 <ipc_find_env>
  801838:	a3 00 40 80 00       	mov    %eax,0x804000
  80183d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801840:	6a 07                	push   $0x7
  801842:	68 00 50 80 00       	push   $0x805000
  801847:	56                   	push   %esi
  801848:	ff 35 00 40 80 00    	pushl  0x804000
  80184e:	e8 8d f9 ff ff       	call   8011e0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801853:	83 c4 0c             	add    $0xc,%esp
  801856:	6a 00                	push   $0x0
  801858:	53                   	push   %ebx
  801859:	6a 00                	push   $0x0
  80185b:	e8 0e f9 ff ff       	call   80116e <ipc_recv>
}
  801860:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801863:	5b                   	pop    %ebx
  801864:	5e                   	pop    %esi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	8b 40 0c             	mov    0xc(%eax),%eax
  801873:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801880:	ba 00 00 00 00       	mov    $0x0,%edx
  801885:	b8 02 00 00 00       	mov    $0x2,%eax
  80188a:	e8 8d ff ff ff       	call   80181c <fsipc>
}
  80188f:	c9                   	leave  
  801890:	c3                   	ret    

00801891 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801897:	8b 45 08             	mov    0x8(%ebp),%eax
  80189a:	8b 40 0c             	mov    0xc(%eax),%eax
  80189d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ac:	e8 6b ff ff ff       	call   80181c <fsipc>
}
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8018d2:	e8 45 ff ff ff       	call   80181c <fsipc>
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 2c                	js     801907 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018db:	83 ec 08             	sub    $0x8,%esp
  8018de:	68 00 50 80 00       	push   $0x805000
  8018e3:	53                   	push   %ebx
  8018e4:	e8 38 f0 ff ff       	call   800921 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018e9:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018f4:	a1 84 50 80 00       	mov    0x805084,%eax
  8018f9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	83 ec 0c             	sub    $0xc,%esp
  801912:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801915:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80191a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80191f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801922:	8b 55 08             	mov    0x8(%ebp),%edx
  801925:	8b 52 0c             	mov    0xc(%edx),%edx
  801928:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80192e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801933:	50                   	push   %eax
  801934:	ff 75 0c             	pushl  0xc(%ebp)
  801937:	68 08 50 80 00       	push   $0x805008
  80193c:	e8 72 f1 ff ff       	call   800ab3 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  801941:	ba 00 00 00 00       	mov    $0x0,%edx
  801946:	b8 04 00 00 00       	mov    $0x4,%eax
  80194b:	e8 cc fe ff ff       	call   80181c <fsipc>
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
  801957:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
  80195d:	8b 40 0c             	mov    0xc(%eax),%eax
  801960:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801965:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196b:	ba 00 00 00 00       	mov    $0x0,%edx
  801970:	b8 03 00 00 00       	mov    $0x3,%eax
  801975:	e8 a2 fe ff ff       	call   80181c <fsipc>
  80197a:	89 c3                	mov    %eax,%ebx
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 4b                	js     8019cb <devfile_read+0x79>
		return r;
	assert(r <= n);
  801980:	39 c6                	cmp    %eax,%esi
  801982:	73 16                	jae    80199a <devfile_read+0x48>
  801984:	68 00 28 80 00       	push   $0x802800
  801989:	68 07 28 80 00       	push   $0x802807
  80198e:	6a 7c                	push   $0x7c
  801990:	68 1c 28 80 00       	push   $0x80281c
  801995:	e8 aa e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  80199a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80199f:	7e 16                	jle    8019b7 <devfile_read+0x65>
  8019a1:	68 27 28 80 00       	push   $0x802827
  8019a6:	68 07 28 80 00       	push   $0x802807
  8019ab:	6a 7d                	push   $0x7d
  8019ad:	68 1c 28 80 00       	push   $0x80281c
  8019b2:	e8 8d e8 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019b7:	83 ec 04             	sub    $0x4,%esp
  8019ba:	50                   	push   %eax
  8019bb:	68 00 50 80 00       	push   $0x805000
  8019c0:	ff 75 0c             	pushl  0xc(%ebp)
  8019c3:	e8 eb f0 ff ff       	call   800ab3 <memmove>
	return r;
  8019c8:	83 c4 10             	add    $0x10,%esp
}
  8019cb:	89 d8                	mov    %ebx,%eax
  8019cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5d                   	pop    %ebp
  8019d3:	c3                   	ret    

008019d4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	53                   	push   %ebx
  8019d8:	83 ec 20             	sub    $0x20,%esp
  8019db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019de:	53                   	push   %ebx
  8019df:	e8 04 ef ff ff       	call   8008e8 <strlen>
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ec:	7f 67                	jg     801a55 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f4:	50                   	push   %eax
  8019f5:	e8 9a f8 ff ff       	call   801294 <fd_alloc>
  8019fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8019fd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 57                	js     801a5a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	53                   	push   %ebx
  801a07:	68 00 50 80 00       	push   $0x805000
  801a0c:	e8 10 ef ff ff       	call   800921 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a14:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a21:	e8 f6 fd ff ff       	call   80181c <fsipc>
  801a26:	89 c3                	mov    %eax,%ebx
  801a28:	83 c4 10             	add    $0x10,%esp
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	79 14                	jns    801a43 <open+0x6f>
		fd_close(fd, 0);
  801a2f:	83 ec 08             	sub    $0x8,%esp
  801a32:	6a 00                	push   $0x0
  801a34:	ff 75 f4             	pushl  -0xc(%ebp)
  801a37:	e8 50 f9 ff ff       	call   80138c <fd_close>
		return r;
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	89 da                	mov    %ebx,%edx
  801a41:	eb 17                	jmp    801a5a <open+0x86>
	}

	return fd2num(fd);
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	ff 75 f4             	pushl  -0xc(%ebp)
  801a49:	e8 1f f8 ff ff       	call   80126d <fd2num>
  801a4e:	89 c2                	mov    %eax,%edx
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	eb 05                	jmp    801a5a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a55:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a5a:	89 d0                	mov    %edx,%eax
  801a5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a67:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6c:	b8 08 00 00 00       	mov    $0x8,%eax
  801a71:	e8 a6 fd ff ff       	call   80181c <fsipc>
}
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a7e:	89 d0                	mov    %edx,%eax
  801a80:	c1 e8 16             	shr    $0x16,%eax
  801a83:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a8f:	f6 c1 01             	test   $0x1,%cl
  801a92:	74 1d                	je     801ab1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801a94:	c1 ea 0c             	shr    $0xc,%edx
  801a97:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801a9e:	f6 c2 01             	test   $0x1,%dl
  801aa1:	74 0e                	je     801ab1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801aa3:	c1 ea 0c             	shr    $0xc,%edx
  801aa6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801aad:	ef 
  801aae:	0f b7 c0             	movzwl %ax,%eax
}
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	56                   	push   %esi
  801ab7:	53                   	push   %ebx
  801ab8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	ff 75 08             	pushl  0x8(%ebp)
  801ac1:	e8 b7 f7 ff ff       	call   80127d <fd2data>
  801ac6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ac8:	83 c4 08             	add    $0x8,%esp
  801acb:	68 33 28 80 00       	push   $0x802833
  801ad0:	53                   	push   %ebx
  801ad1:	e8 4b ee ff ff       	call   800921 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ad6:	8b 46 04             	mov    0x4(%esi),%eax
  801ad9:	2b 06                	sub    (%esi),%eax
  801adb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ae1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ae8:	00 00 00 
	stat->st_dev = &devpipe;
  801aeb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801af2:	30 80 00 
	return 0;
}
  801af5:	b8 00 00 00 00       	mov    $0x0,%eax
  801afa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afd:	5b                   	pop    %ebx
  801afe:	5e                   	pop    %esi
  801aff:	5d                   	pop    %ebp
  801b00:	c3                   	ret    

00801b01 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	53                   	push   %ebx
  801b05:	83 ec 0c             	sub    $0xc,%esp
  801b08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b0b:	53                   	push   %ebx
  801b0c:	6a 00                	push   $0x0
  801b0e:	e8 96 f2 ff ff       	call   800da9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b13:	89 1c 24             	mov    %ebx,(%esp)
  801b16:	e8 62 f7 ff ff       	call   80127d <fd2data>
  801b1b:	83 c4 08             	add    $0x8,%esp
  801b1e:	50                   	push   %eax
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 83 f2 ff ff       	call   800da9 <sys_page_unmap>
}
  801b26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	57                   	push   %edi
  801b2f:	56                   	push   %esi
  801b30:	53                   	push   %ebx
  801b31:	83 ec 1c             	sub    $0x1c,%esp
  801b34:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b37:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b39:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	ff 75 e0             	pushl  -0x20(%ebp)
  801b47:	e8 2c ff ff ff       	call   801a78 <pageref>
  801b4c:	89 c3                	mov    %eax,%ebx
  801b4e:	89 3c 24             	mov    %edi,(%esp)
  801b51:	e8 22 ff ff ff       	call   801a78 <pageref>
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	39 c3                	cmp    %eax,%ebx
  801b5b:	0f 94 c1             	sete   %cl
  801b5e:	0f b6 c9             	movzbl %cl,%ecx
  801b61:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b64:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b6a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b6d:	39 ce                	cmp    %ecx,%esi
  801b6f:	74 1b                	je     801b8c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b71:	39 c3                	cmp    %eax,%ebx
  801b73:	75 c4                	jne    801b39 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b75:	8b 42 58             	mov    0x58(%edx),%eax
  801b78:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b7b:	50                   	push   %eax
  801b7c:	56                   	push   %esi
  801b7d:	68 3a 28 80 00       	push   $0x80283a
  801b82:	e8 96 e7 ff ff       	call   80031d <cprintf>
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	eb ad                	jmp    801b39 <_pipeisclosed+0xe>
	}
}
  801b8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5f                   	pop    %edi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	57                   	push   %edi
  801b9b:	56                   	push   %esi
  801b9c:	53                   	push   %ebx
  801b9d:	83 ec 28             	sub    $0x28,%esp
  801ba0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ba3:	56                   	push   %esi
  801ba4:	e8 d4 f6 ff ff       	call   80127d <fd2data>
  801ba9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	bf 00 00 00 00       	mov    $0x0,%edi
  801bb3:	eb 4b                	jmp    801c00 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bb5:	89 da                	mov    %ebx,%edx
  801bb7:	89 f0                	mov    %esi,%eax
  801bb9:	e8 6d ff ff ff       	call   801b2b <_pipeisclosed>
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	75 48                	jne    801c0a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bc2:	e8 3e f1 ff ff       	call   800d05 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc7:	8b 43 04             	mov    0x4(%ebx),%eax
  801bca:	8b 0b                	mov    (%ebx),%ecx
  801bcc:	8d 51 20             	lea    0x20(%ecx),%edx
  801bcf:	39 d0                	cmp    %edx,%eax
  801bd1:	73 e2                	jae    801bb5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bda:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bdd:	89 c2                	mov    %eax,%edx
  801bdf:	c1 fa 1f             	sar    $0x1f,%edx
  801be2:	89 d1                	mov    %edx,%ecx
  801be4:	c1 e9 1b             	shr    $0x1b,%ecx
  801be7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bea:	83 e2 1f             	and    $0x1f,%edx
  801bed:	29 ca                	sub    %ecx,%edx
  801bef:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bf3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bf7:	83 c0 01             	add    $0x1,%eax
  801bfa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfd:	83 c7 01             	add    $0x1,%edi
  801c00:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c03:	75 c2                	jne    801bc7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c05:	8b 45 10             	mov    0x10(%ebp),%eax
  801c08:	eb 05                	jmp    801c0f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	57                   	push   %edi
  801c1b:	56                   	push   %esi
  801c1c:	53                   	push   %ebx
  801c1d:	83 ec 18             	sub    $0x18,%esp
  801c20:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c23:	57                   	push   %edi
  801c24:	e8 54 f6 ff ff       	call   80127d <fd2data>
  801c29:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c33:	eb 3d                	jmp    801c72 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c35:	85 db                	test   %ebx,%ebx
  801c37:	74 04                	je     801c3d <devpipe_read+0x26>
				return i;
  801c39:	89 d8                	mov    %ebx,%eax
  801c3b:	eb 44                	jmp    801c81 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c3d:	89 f2                	mov    %esi,%edx
  801c3f:	89 f8                	mov    %edi,%eax
  801c41:	e8 e5 fe ff ff       	call   801b2b <_pipeisclosed>
  801c46:	85 c0                	test   %eax,%eax
  801c48:	75 32                	jne    801c7c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c4a:	e8 b6 f0 ff ff       	call   800d05 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c4f:	8b 06                	mov    (%esi),%eax
  801c51:	3b 46 04             	cmp    0x4(%esi),%eax
  801c54:	74 df                	je     801c35 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c56:	99                   	cltd   
  801c57:	c1 ea 1b             	shr    $0x1b,%edx
  801c5a:	01 d0                	add    %edx,%eax
  801c5c:	83 e0 1f             	and    $0x1f,%eax
  801c5f:	29 d0                	sub    %edx,%eax
  801c61:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c69:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c6c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6f:	83 c3 01             	add    $0x1,%ebx
  801c72:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c75:	75 d8                	jne    801c4f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c77:	8b 45 10             	mov    0x10(%ebp),%eax
  801c7a:	eb 05                	jmp    801c81 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c7c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5f                   	pop    %edi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	56                   	push   %esi
  801c8d:	53                   	push   %ebx
  801c8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	e8 fa f5 ff ff       	call   801294 <fd_alloc>
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	89 c2                	mov    %eax,%edx
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	0f 88 2c 01 00 00    	js     801dd3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca7:	83 ec 04             	sub    $0x4,%esp
  801caa:	68 07 04 00 00       	push   $0x407
  801caf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb2:	6a 00                	push   $0x0
  801cb4:	e8 6b f0 ff ff       	call   800d24 <sys_page_alloc>
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	89 c2                	mov    %eax,%edx
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	0f 88 0d 01 00 00    	js     801dd3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ccc:	50                   	push   %eax
  801ccd:	e8 c2 f5 ff ff       	call   801294 <fd_alloc>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	0f 88 e2 00 00 00    	js     801dc1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdf:	83 ec 04             	sub    $0x4,%esp
  801ce2:	68 07 04 00 00       	push   $0x407
  801ce7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cea:	6a 00                	push   $0x0
  801cec:	e8 33 f0 ff ff       	call   800d24 <sys_page_alloc>
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	0f 88 c3 00 00 00    	js     801dc1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	ff 75 f4             	pushl  -0xc(%ebp)
  801d04:	e8 74 f5 ff ff       	call   80127d <fd2data>
  801d09:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0b:	83 c4 0c             	add    $0xc,%esp
  801d0e:	68 07 04 00 00       	push   $0x407
  801d13:	50                   	push   %eax
  801d14:	6a 00                	push   $0x0
  801d16:	e8 09 f0 ff ff       	call   800d24 <sys_page_alloc>
  801d1b:	89 c3                	mov    %eax,%ebx
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	85 c0                	test   %eax,%eax
  801d22:	0f 88 89 00 00 00    	js     801db1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d28:	83 ec 0c             	sub    $0xc,%esp
  801d2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2e:	e8 4a f5 ff ff       	call   80127d <fd2data>
  801d33:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d3a:	50                   	push   %eax
  801d3b:	6a 00                	push   $0x0
  801d3d:	56                   	push   %esi
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 22 f0 ff ff       	call   800d67 <sys_page_map>
  801d45:	89 c3                	mov    %eax,%ebx
  801d47:	83 c4 20             	add    $0x20,%esp
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 55                	js     801da3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d4e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d57:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d63:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d71:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d78:	83 ec 0c             	sub    $0xc,%esp
  801d7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7e:	e8 ea f4 ff ff       	call   80126d <fd2num>
  801d83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d86:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d88:	83 c4 04             	add    $0x4,%esp
  801d8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8e:	e8 da f4 ff ff       	call   80126d <fd2num>
  801d93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d96:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801da1:	eb 30                	jmp    801dd3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801da3:	83 ec 08             	sub    $0x8,%esp
  801da6:	56                   	push   %esi
  801da7:	6a 00                	push   $0x0
  801da9:	e8 fb ef ff ff       	call   800da9 <sys_page_unmap>
  801dae:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801db1:	83 ec 08             	sub    $0x8,%esp
  801db4:	ff 75 f0             	pushl  -0x10(%ebp)
  801db7:	6a 00                	push   $0x0
  801db9:	e8 eb ef ff ff       	call   800da9 <sys_page_unmap>
  801dbe:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dc1:	83 ec 08             	sub    $0x8,%esp
  801dc4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc7:	6a 00                	push   $0x0
  801dc9:	e8 db ef ff ff       	call   800da9 <sys_page_unmap>
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dd3:	89 d0                	mov    %edx,%eax
  801dd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5e                   	pop    %esi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de5:	50                   	push   %eax
  801de6:	ff 75 08             	pushl  0x8(%ebp)
  801de9:	e8 f5 f4 ff ff       	call   8012e3 <fd_lookup>
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	85 c0                	test   %eax,%eax
  801df3:	78 18                	js     801e0d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801df5:	83 ec 0c             	sub    $0xc,%esp
  801df8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfb:	e8 7d f4 ff ff       	call   80127d <fd2data>
	return _pipeisclosed(fd, p);
  801e00:	89 c2                	mov    %eax,%edx
  801e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e05:	e8 21 fd ff ff       	call   801b2b <_pipeisclosed>
  801e0a:	83 c4 10             	add    $0x10,%esp
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e12:	b8 00 00 00 00       	mov    $0x0,%eax
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e1f:	68 52 28 80 00       	push   $0x802852
  801e24:	ff 75 0c             	pushl  0xc(%ebp)
  801e27:	e8 f5 ea ff ff       	call   800921 <strcpy>
	return 0;
}
  801e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e31:	c9                   	leave  
  801e32:	c3                   	ret    

00801e33 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	57                   	push   %edi
  801e37:	56                   	push   %esi
  801e38:	53                   	push   %ebx
  801e39:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e3f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e44:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e4a:	eb 2d                	jmp    801e79 <devcons_write+0x46>
		m = n - tot;
  801e4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e4f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e51:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e54:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e59:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e5c:	83 ec 04             	sub    $0x4,%esp
  801e5f:	53                   	push   %ebx
  801e60:	03 45 0c             	add    0xc(%ebp),%eax
  801e63:	50                   	push   %eax
  801e64:	57                   	push   %edi
  801e65:	e8 49 ec ff ff       	call   800ab3 <memmove>
		sys_cputs(buf, m);
  801e6a:	83 c4 08             	add    $0x8,%esp
  801e6d:	53                   	push   %ebx
  801e6e:	57                   	push   %edi
  801e6f:	e8 f4 ed ff ff       	call   800c68 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e74:	01 de                	add    %ebx,%esi
  801e76:	83 c4 10             	add    $0x10,%esp
  801e79:	89 f0                	mov    %esi,%eax
  801e7b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e7e:	72 cc                	jb     801e4c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    

00801e88 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 08             	sub    $0x8,%esp
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e97:	74 2a                	je     801ec3 <devcons_read+0x3b>
  801e99:	eb 05                	jmp    801ea0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e9b:	e8 65 ee ff ff       	call   800d05 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ea0:	e8 e1 ed ff ff       	call   800c86 <sys_cgetc>
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	74 f2                	je     801e9b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 16                	js     801ec3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ead:	83 f8 04             	cmp    $0x4,%eax
  801eb0:	74 0c                	je     801ebe <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eb5:	88 02                	mov    %al,(%edx)
	return 1;
  801eb7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebc:	eb 05                	jmp    801ec3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ebe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    

00801ec5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ece:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ed1:	6a 01                	push   $0x1
  801ed3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed6:	50                   	push   %eax
  801ed7:	e8 8c ed ff ff       	call   800c68 <sys_cputs>
}
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	c9                   	leave  
  801ee0:	c3                   	ret    

00801ee1 <getchar>:

int
getchar(void)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ee7:	6a 01                	push   $0x1
  801ee9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eec:	50                   	push   %eax
  801eed:	6a 00                	push   $0x0
  801eef:	e8 55 f6 ff ff       	call   801549 <read>
	if (r < 0)
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	78 0f                	js     801f0a <getchar+0x29>
		return r;
	if (r < 1)
  801efb:	85 c0                	test   %eax,%eax
  801efd:	7e 06                	jle    801f05 <getchar+0x24>
		return -E_EOF;
	return c;
  801eff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f03:	eb 05                	jmp    801f0a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f05:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f15:	50                   	push   %eax
  801f16:	ff 75 08             	pushl  0x8(%ebp)
  801f19:	e8 c5 f3 ff ff       	call   8012e3 <fd_lookup>
  801f1e:	83 c4 10             	add    $0x10,%esp
  801f21:	85 c0                	test   %eax,%eax
  801f23:	78 11                	js     801f36 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f28:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f2e:	39 10                	cmp    %edx,(%eax)
  801f30:	0f 94 c0             	sete   %al
  801f33:	0f b6 c0             	movzbl %al,%eax
}
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <opencons>:

int
opencons(void)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f41:	50                   	push   %eax
  801f42:	e8 4d f3 ff ff       	call   801294 <fd_alloc>
  801f47:	83 c4 10             	add    $0x10,%esp
		return r;
  801f4a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	78 3e                	js     801f8e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f50:	83 ec 04             	sub    $0x4,%esp
  801f53:	68 07 04 00 00       	push   $0x407
  801f58:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5b:	6a 00                	push   $0x0
  801f5d:	e8 c2 ed ff ff       	call   800d24 <sys_page_alloc>
  801f62:	83 c4 10             	add    $0x10,%esp
		return r;
  801f65:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f67:	85 c0                	test   %eax,%eax
  801f69:	78 23                	js     801f8e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f6b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f74:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f79:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f80:	83 ec 0c             	sub    $0xc,%esp
  801f83:	50                   	push   %eax
  801f84:	e8 e4 f2 ff ff       	call   80126d <fd2num>
  801f89:	89 c2                	mov    %eax,%edx
  801f8b:	83 c4 10             	add    $0x10,%esp
}
  801f8e:	89 d0                	mov    %edx,%eax
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	53                   	push   %ebx
  801f96:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f99:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fa0:	75 28                	jne    801fca <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801fa2:	e8 3f ed ff ff       	call   800ce6 <sys_getenvid>
  801fa7:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801fa9:	83 ec 04             	sub    $0x4,%esp
  801fac:	6a 07                	push   $0x7
  801fae:	68 00 f0 bf ee       	push   $0xeebff000
  801fb3:	50                   	push   %eax
  801fb4:	e8 6b ed ff ff       	call   800d24 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801fb9:	83 c4 08             	add    $0x8,%esp
  801fbc:	68 d7 1f 80 00       	push   $0x801fd7
  801fc1:	53                   	push   %ebx
  801fc2:	e8 a8 ee ff ff       	call   800e6f <sys_env_set_pgfault_upcall>
  801fc7:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fca:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcd:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801fd7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fd8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fdd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fdf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801fe2:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801fe4:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801fe8:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801fec:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801fed:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801fef:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801ff4:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801ff5:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801ff6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801ff7:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801ffa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801ffb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ffc:	c3                   	ret    
  801ffd:	66 90                	xchg   %ax,%ax
  801fff:	90                   	nop

00802000 <__udivdi3>:
  802000:	55                   	push   %ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
  802007:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80200b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80200f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802017:	85 f6                	test   %esi,%esi
  802019:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80201d:	89 ca                	mov    %ecx,%edx
  80201f:	89 f8                	mov    %edi,%eax
  802021:	75 3d                	jne    802060 <__udivdi3+0x60>
  802023:	39 cf                	cmp    %ecx,%edi
  802025:	0f 87 c5 00 00 00    	ja     8020f0 <__udivdi3+0xf0>
  80202b:	85 ff                	test   %edi,%edi
  80202d:	89 fd                	mov    %edi,%ebp
  80202f:	75 0b                	jne    80203c <__udivdi3+0x3c>
  802031:	b8 01 00 00 00       	mov    $0x1,%eax
  802036:	31 d2                	xor    %edx,%edx
  802038:	f7 f7                	div    %edi
  80203a:	89 c5                	mov    %eax,%ebp
  80203c:	89 c8                	mov    %ecx,%eax
  80203e:	31 d2                	xor    %edx,%edx
  802040:	f7 f5                	div    %ebp
  802042:	89 c1                	mov    %eax,%ecx
  802044:	89 d8                	mov    %ebx,%eax
  802046:	89 cf                	mov    %ecx,%edi
  802048:	f7 f5                	div    %ebp
  80204a:	89 c3                	mov    %eax,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	39 ce                	cmp    %ecx,%esi
  802062:	77 74                	ja     8020d8 <__udivdi3+0xd8>
  802064:	0f bd fe             	bsr    %esi,%edi
  802067:	83 f7 1f             	xor    $0x1f,%edi
  80206a:	0f 84 98 00 00 00    	je     802108 <__udivdi3+0x108>
  802070:	bb 20 00 00 00       	mov    $0x20,%ebx
  802075:	89 f9                	mov    %edi,%ecx
  802077:	89 c5                	mov    %eax,%ebp
  802079:	29 fb                	sub    %edi,%ebx
  80207b:	d3 e6                	shl    %cl,%esi
  80207d:	89 d9                	mov    %ebx,%ecx
  80207f:	d3 ed                	shr    %cl,%ebp
  802081:	89 f9                	mov    %edi,%ecx
  802083:	d3 e0                	shl    %cl,%eax
  802085:	09 ee                	or     %ebp,%esi
  802087:	89 d9                	mov    %ebx,%ecx
  802089:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80208d:	89 d5                	mov    %edx,%ebp
  80208f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802093:	d3 ed                	shr    %cl,%ebp
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e2                	shl    %cl,%edx
  802099:	89 d9                	mov    %ebx,%ecx
  80209b:	d3 e8                	shr    %cl,%eax
  80209d:	09 c2                	or     %eax,%edx
  80209f:	89 d0                	mov    %edx,%eax
  8020a1:	89 ea                	mov    %ebp,%edx
  8020a3:	f7 f6                	div    %esi
  8020a5:	89 d5                	mov    %edx,%ebp
  8020a7:	89 c3                	mov    %eax,%ebx
  8020a9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	72 10                	jb     8020c1 <__udivdi3+0xc1>
  8020b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e6                	shl    %cl,%esi
  8020b9:	39 c6                	cmp    %eax,%esi
  8020bb:	73 07                	jae    8020c4 <__udivdi3+0xc4>
  8020bd:	39 d5                	cmp    %edx,%ebp
  8020bf:	75 03                	jne    8020c4 <__udivdi3+0xc4>
  8020c1:	83 eb 01             	sub    $0x1,%ebx
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 d8                	mov    %ebx,%eax
  8020c8:	89 fa                	mov    %edi,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	31 ff                	xor    %edi,%edi
  8020da:	31 db                	xor    %ebx,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	89 d8                	mov    %ebx,%eax
  8020f2:	f7 f7                	div    %edi
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 c3                	mov    %eax,%ebx
  8020f8:	89 d8                	mov    %ebx,%eax
  8020fa:	89 fa                	mov    %edi,%edx
  8020fc:	83 c4 1c             	add    $0x1c,%esp
  8020ff:	5b                   	pop    %ebx
  802100:	5e                   	pop    %esi
  802101:	5f                   	pop    %edi
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	39 ce                	cmp    %ecx,%esi
  80210a:	72 0c                	jb     802118 <__udivdi3+0x118>
  80210c:	31 db                	xor    %ebx,%ebx
  80210e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802112:	0f 87 34 ff ff ff    	ja     80204c <__udivdi3+0x4c>
  802118:	bb 01 00 00 00       	mov    $0x1,%ebx
  80211d:	e9 2a ff ff ff       	jmp    80204c <__udivdi3+0x4c>
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__umoddi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
  802137:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80213b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80213f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802147:	85 d2                	test   %edx,%edx
  802149:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80214d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802151:	89 f3                	mov    %esi,%ebx
  802153:	89 3c 24             	mov    %edi,(%esp)
  802156:	89 74 24 04          	mov    %esi,0x4(%esp)
  80215a:	75 1c                	jne    802178 <__umoddi3+0x48>
  80215c:	39 f7                	cmp    %esi,%edi
  80215e:	76 50                	jbe    8021b0 <__umoddi3+0x80>
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	f7 f7                	div    %edi
  802166:	89 d0                	mov    %edx,%eax
  802168:	31 d2                	xor    %edx,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	39 f2                	cmp    %esi,%edx
  80217a:	89 d0                	mov    %edx,%eax
  80217c:	77 52                	ja     8021d0 <__umoddi3+0xa0>
  80217e:	0f bd ea             	bsr    %edx,%ebp
  802181:	83 f5 1f             	xor    $0x1f,%ebp
  802184:	75 5a                	jne    8021e0 <__umoddi3+0xb0>
  802186:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80218a:	0f 82 e0 00 00 00    	jb     802270 <__umoddi3+0x140>
  802190:	39 0c 24             	cmp    %ecx,(%esp)
  802193:	0f 86 d7 00 00 00    	jbe    802270 <__umoddi3+0x140>
  802199:	8b 44 24 08          	mov    0x8(%esp),%eax
  80219d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021a1:	83 c4 1c             	add    $0x1c,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	85 ff                	test   %edi,%edi
  8021b2:	89 fd                	mov    %edi,%ebp
  8021b4:	75 0b                	jne    8021c1 <__umoddi3+0x91>
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f7                	div    %edi
  8021bf:	89 c5                	mov    %eax,%ebp
  8021c1:	89 f0                	mov    %esi,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  8021c5:	f7 f5                	div    %ebp
  8021c7:	89 c8                	mov    %ecx,%eax
  8021c9:	f7 f5                	div    %ebp
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	eb 99                	jmp    802168 <__umoddi3+0x38>
  8021cf:	90                   	nop
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	83 c4 1c             	add    $0x1c,%esp
  8021d7:	5b                   	pop    %ebx
  8021d8:	5e                   	pop    %esi
  8021d9:	5f                   	pop    %edi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    
  8021dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	8b 34 24             	mov    (%esp),%esi
  8021e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021e8:	89 e9                	mov    %ebp,%ecx
  8021ea:	29 ef                	sub    %ebp,%edi
  8021ec:	d3 e0                	shl    %cl,%eax
  8021ee:	89 f9                	mov    %edi,%ecx
  8021f0:	89 f2                	mov    %esi,%edx
  8021f2:	d3 ea                	shr    %cl,%edx
  8021f4:	89 e9                	mov    %ebp,%ecx
  8021f6:	09 c2                	or     %eax,%edx
  8021f8:	89 d8                	mov    %ebx,%eax
  8021fa:	89 14 24             	mov    %edx,(%esp)
  8021fd:	89 f2                	mov    %esi,%edx
  8021ff:	d3 e2                	shl    %cl,%edx
  802201:	89 f9                	mov    %edi,%ecx
  802203:	89 54 24 04          	mov    %edx,0x4(%esp)
  802207:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	89 c6                	mov    %eax,%esi
  802211:	d3 e3                	shl    %cl,%ebx
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 d0                	mov    %edx,%eax
  802217:	d3 e8                	shr    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	09 d8                	or     %ebx,%eax
  80221d:	89 d3                	mov    %edx,%ebx
  80221f:	89 f2                	mov    %esi,%edx
  802221:	f7 34 24             	divl   (%esp)
  802224:	89 d6                	mov    %edx,%esi
  802226:	d3 e3                	shl    %cl,%ebx
  802228:	f7 64 24 04          	mull   0x4(%esp)
  80222c:	39 d6                	cmp    %edx,%esi
  80222e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802232:	89 d1                	mov    %edx,%ecx
  802234:	89 c3                	mov    %eax,%ebx
  802236:	72 08                	jb     802240 <__umoddi3+0x110>
  802238:	75 11                	jne    80224b <__umoddi3+0x11b>
  80223a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80223e:	73 0b                	jae    80224b <__umoddi3+0x11b>
  802240:	2b 44 24 04          	sub    0x4(%esp),%eax
  802244:	1b 14 24             	sbb    (%esp),%edx
  802247:	89 d1                	mov    %edx,%ecx
  802249:	89 c3                	mov    %eax,%ebx
  80224b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80224f:	29 da                	sub    %ebx,%edx
  802251:	19 ce                	sbb    %ecx,%esi
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 f0                	mov    %esi,%eax
  802257:	d3 e0                	shl    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	d3 ea                	shr    %cl,%edx
  80225d:	89 e9                	mov    %ebp,%ecx
  80225f:	d3 ee                	shr    %cl,%esi
  802261:	09 d0                	or     %edx,%eax
  802263:	89 f2                	mov    %esi,%edx
  802265:	83 c4 1c             	add    $0x1c,%esp
  802268:	5b                   	pop    %ebx
  802269:	5e                   	pop    %esi
  80226a:	5f                   	pop    %edi
  80226b:	5d                   	pop    %ebp
  80226c:	c3                   	ret    
  80226d:	8d 76 00             	lea    0x0(%esi),%esi
  802270:	29 f9                	sub    %edi,%ecx
  802272:	19 d6                	sbb    %edx,%esi
  802274:	89 74 24 04          	mov    %esi,0x4(%esp)
  802278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80227c:	e9 18 ff ff ff       	jmp    802199 <__umoddi3+0x69>
