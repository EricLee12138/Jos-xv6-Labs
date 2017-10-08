
obj/user/init.debug：     文件格式 elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 00 26 80 00       	push   $0x802600
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 c8 26 80 00       	push   $0x8026c8
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 0f 26 80 00       	push   $0x80260f
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 50 80 00       	push   $0x805020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 04 27 80 00       	push   $0x802704
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 26 26 80 00       	push   $0x802626
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 3c 26 80 00       	push   $0x80263c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 f1 09 00 00       	call   800afc <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 48 26 80 00       	push   $0x802648
  800123:	56                   	push   %esi
  800124:	e8 d3 09 00 00       	call   800afc <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 c7 09 00 00       	call   800afc <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 49 26 80 00       	push   $0x802649
  80013d:	56                   	push   %esi
  80013e:	e8 b9 09 00 00       	call   800afc <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 4b 26 80 00       	push   $0x80264b
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 4f 26 80 00 	movl   $0x80264f,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 f6 10 00 00       	call   801270 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 61 26 80 00       	push   $0x802661
  80018c:	6a 37                	push   $0x37
  80018e:	68 6e 26 80 00       	push   $0x80266e
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 7a 26 80 00       	push   $0x80267a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 6e 26 80 00       	push   $0x80266e
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 06 11 00 00       	call   8012c0 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 94 26 80 00       	push   $0x802694
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 6e 26 80 00       	push   $0x80266e
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 9c 26 80 00       	push   $0x80269c
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 b0 26 80 00       	push   $0x8026b0
  8001ea:	68 af 26 80 00       	push   $0x8026af
  8001ef:	e8 10 1c 00 00       	call   801e04 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 b3 26 80 00       	push   $0x8026b3
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 bc 1f 00 00       	call   8021d3 <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 33 27 80 00       	push   $0x802733
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 a3 08 00 00       	call   800adc <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 f7 09 00 00       	call   800c6e <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 a2 0b 00 00       	call   800e23 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 13 0c 00 00       	call   800ec0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 8f 0b 00 00       	call   800e41 <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 3a 0b 00 00       	call   800e23 <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 ab 10 00 00       	call   8013ac <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 1b 0e 00 00       	call   801146 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 a3 0d 00 00       	call   8010f7 <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 70 0b 00 00       	call   800edf <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 3a 0d 00 00       	call   8010d0 <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8003aa:	e8 f2 0a 00 00       	call   800ea1 <sys_getenvid>
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 90 67 80 00       	mov    %eax,0x806790
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 ab 0e 00 00       	call   80129b <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 66 0a 00 00       	call   800e60 <sys_env_destroy>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80040d:	e8 8f 0a 00 00       	call   800ea1 <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 4c 27 80 00       	push   $0x80274c
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 20 2c 80 00 	movl   $0x802c20,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 ae 09 00 00       	call   800e23 <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 1a 01 00 00       	call   8005d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 53 09 00 00       	call   800e23 <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800505:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800510:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800513:	39 d3                	cmp    %edx,%ebx
  800515:	72 05                	jb     80051c <printnum+0x30>
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 45                	ja     800561 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	ff 75 18             	pushl  0x18(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800528:	53                   	push   %ebx
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 20 1e 00 00       	call   802360 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 18                	jmp    80056b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 03                	jmp    800564 <printnum+0x78>
  800561:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	85 db                	test   %ebx,%ebx
  800569:	7f e8                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 e4             	pushl  -0x1c(%ebp)
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 75 dc             	pushl  -0x24(%ebp)
  80057b:	ff 75 d8             	pushl  -0x28(%ebp)
  80057e:	e8 0d 1f 00 00       	call   802490 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 6f 27 80 00 	movsbl 0x80276f(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
}
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
  80059e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8005aa:	73 0a                	jae    8005b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005af:	89 08                	mov    %ecx,(%eax)
  8005b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b4:	88 02                	mov    %al,(%edx)
}
  8005b6:	5d                   	pop    %ebp
  8005b7:	c3                   	ret    

008005b8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
  8005bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 10             	pushl  0x10(%ebp)
  8005c5:	ff 75 0c             	pushl  0xc(%ebp)
  8005c8:	ff 75 08             	pushl  0x8(%ebp)
  8005cb:	e8 05 00 00 00       	call   8005d5 <vprintfmt>
	va_end(ap);
}
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	c9                   	leave  
  8005d4:	c3                   	ret    

008005d5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	57                   	push   %edi
  8005d9:	56                   	push   %esi
  8005da:	53                   	push   %ebx
  8005db:	83 ec 2c             	sub    $0x2c,%esp
  8005de:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005e7:	eb 12                	jmp    8005fb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	0f 84 42 04 00 00    	je     800a33 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	50                   	push   %eax
  8005f6:	ff d6                	call   *%esi
  8005f8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005fb:	83 c7 01             	add    $0x1,%edi
  8005fe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800602:	83 f8 25             	cmp    $0x25,%eax
  800605:	75 e2                	jne    8005e9 <vprintfmt+0x14>
  800607:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80060b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800612:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800619:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800620:	b9 00 00 00 00       	mov    $0x0,%ecx
  800625:	eb 07                	jmp    80062e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80062a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8d 47 01             	lea    0x1(%edi),%eax
  800631:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800634:	0f b6 07             	movzbl (%edi),%eax
  800637:	0f b6 d0             	movzbl %al,%edx
  80063a:	83 e8 23             	sub    $0x23,%eax
  80063d:	3c 55                	cmp    $0x55,%al
  80063f:	0f 87 d3 03 00 00    	ja     800a18 <vprintfmt+0x443>
  800645:	0f b6 c0             	movzbl %al,%eax
  800648:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800652:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800656:	eb d6                	jmp    80062e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065b:	b8 00 00 00 00       	mov    $0x0,%eax
  800660:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800663:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800666:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80066a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80066d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800670:	83 f9 09             	cmp    $0x9,%ecx
  800673:	77 3f                	ja     8006b4 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800675:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800678:	eb e9                	jmp    800663 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80068e:	eb 2a                	jmp    8006ba <vprintfmt+0xe5>
  800690:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800693:	85 c0                	test   %eax,%eax
  800695:	ba 00 00 00 00       	mov    $0x0,%edx
  80069a:	0f 49 d0             	cmovns %eax,%edx
  80069d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a3:	eb 89                	jmp    80062e <vprintfmt+0x59>
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006a8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006af:	e9 7a ff ff ff       	jmp    80062e <vprintfmt+0x59>
  8006b4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006b7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006be:	0f 89 6a ff ff ff    	jns    80062e <vprintfmt+0x59>
				width = precision, precision = -1;
  8006c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006d1:	e9 58 ff ff ff       	jmp    80062e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006d6:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006dc:	e9 4d ff ff ff       	jmp    80062e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 78 04             	lea    0x4(%eax),%edi
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	ff 30                	pushl  (%eax)
  8006ed:	ff d6                	call   *%esi
			break;
  8006ef:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006f2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006f8:	e9 fe fe ff ff       	jmp    8005fb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 78 04             	lea    0x4(%eax),%edi
  800703:	8b 00                	mov    (%eax),%eax
  800705:	99                   	cltd   
  800706:	31 d0                	xor    %edx,%eax
  800708:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80070a:	83 f8 0f             	cmp    $0xf,%eax
  80070d:	7f 0b                	jg     80071a <vprintfmt+0x145>
  80070f:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  800716:	85 d2                	test   %edx,%edx
  800718:	75 1b                	jne    800735 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80071a:	50                   	push   %eax
  80071b:	68 87 27 80 00       	push   $0x802787
  800720:	53                   	push   %ebx
  800721:	56                   	push   %esi
  800722:	e8 91 fe ff ff       	call   8005b8 <printfmt>
  800727:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80072a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800730:	e9 c6 fe ff ff       	jmp    8005fb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800735:	52                   	push   %edx
  800736:	68 51 2b 80 00       	push   $0x802b51
  80073b:	53                   	push   %ebx
  80073c:	56                   	push   %esi
  80073d:	e8 76 fe ff ff       	call   8005b8 <printfmt>
  800742:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800745:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800748:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074b:	e9 ab fe ff ff       	jmp    8005fb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	83 c0 04             	add    $0x4,%eax
  800756:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80075e:	85 ff                	test   %edi,%edi
  800760:	b8 80 27 80 00       	mov    $0x802780,%eax
  800765:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800768:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80076c:	0f 8e 94 00 00 00    	jle    800806 <vprintfmt+0x231>
  800772:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800776:	0f 84 98 00 00 00    	je     800814 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	ff 75 d0             	pushl  -0x30(%ebp)
  800782:	57                   	push   %edi
  800783:	e8 33 03 00 00       	call   800abb <strnlen>
  800788:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80078b:	29 c1                	sub    %eax,%ecx
  80078d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800790:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800793:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800797:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80079a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80079d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079f:	eb 0f                	jmp    8007b0 <vprintfmt+0x1db>
					putch(padc, putdat);
  8007a1:	83 ec 08             	sub    $0x8,%esp
  8007a4:	53                   	push   %ebx
  8007a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007aa:	83 ef 01             	sub    $0x1,%edi
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	85 ff                	test   %edi,%edi
  8007b2:	7f ed                	jg     8007a1 <vprintfmt+0x1cc>
  8007b4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007b7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8007ba:	85 c9                	test   %ecx,%ecx
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	0f 49 c1             	cmovns %ecx,%eax
  8007c4:	29 c1                	sub    %eax,%ecx
  8007c6:	89 75 08             	mov    %esi,0x8(%ebp)
  8007c9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007cc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007cf:	89 cb                	mov    %ecx,%ebx
  8007d1:	eb 4d                	jmp    800820 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007d7:	74 1b                	je     8007f4 <vprintfmt+0x21f>
  8007d9:	0f be c0             	movsbl %al,%eax
  8007dc:	83 e8 20             	sub    $0x20,%eax
  8007df:	83 f8 5e             	cmp    $0x5e,%eax
  8007e2:	76 10                	jbe    8007f4 <vprintfmt+0x21f>
					putch('?', putdat);
  8007e4:	83 ec 08             	sub    $0x8,%esp
  8007e7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ea:	6a 3f                	push   $0x3f
  8007ec:	ff 55 08             	call   *0x8(%ebp)
  8007ef:	83 c4 10             	add    $0x10,%esp
  8007f2:	eb 0d                	jmp    800801 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	ff 75 0c             	pushl  0xc(%ebp)
  8007fa:	52                   	push   %edx
  8007fb:	ff 55 08             	call   *0x8(%ebp)
  8007fe:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800801:	83 eb 01             	sub    $0x1,%ebx
  800804:	eb 1a                	jmp    800820 <vprintfmt+0x24b>
  800806:	89 75 08             	mov    %esi,0x8(%ebp)
  800809:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80080c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80080f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800812:	eb 0c                	jmp    800820 <vprintfmt+0x24b>
  800814:	89 75 08             	mov    %esi,0x8(%ebp)
  800817:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80081a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80081d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800820:	83 c7 01             	add    $0x1,%edi
  800823:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800827:	0f be d0             	movsbl %al,%edx
  80082a:	85 d2                	test   %edx,%edx
  80082c:	74 23                	je     800851 <vprintfmt+0x27c>
  80082e:	85 f6                	test   %esi,%esi
  800830:	78 a1                	js     8007d3 <vprintfmt+0x1fe>
  800832:	83 ee 01             	sub    $0x1,%esi
  800835:	79 9c                	jns    8007d3 <vprintfmt+0x1fe>
  800837:	89 df                	mov    %ebx,%edi
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083f:	eb 18                	jmp    800859 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	53                   	push   %ebx
  800845:	6a 20                	push   $0x20
  800847:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800849:	83 ef 01             	sub    $0x1,%edi
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	eb 08                	jmp    800859 <vprintfmt+0x284>
  800851:	89 df                	mov    %ebx,%edi
  800853:	8b 75 08             	mov    0x8(%ebp),%esi
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800859:	85 ff                	test   %edi,%edi
  80085b:	7f e4                	jg     800841 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80085d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800860:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800863:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800866:	e9 90 fd ff ff       	jmp    8005fb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80086b:	83 f9 01             	cmp    $0x1,%ecx
  80086e:	7e 19                	jle    800889 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8b 50 04             	mov    0x4(%eax),%edx
  800876:	8b 00                	mov    (%eax),%eax
  800878:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80087b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	8d 40 08             	lea    0x8(%eax),%eax
  800884:	89 45 14             	mov    %eax,0x14(%ebp)
  800887:	eb 38                	jmp    8008c1 <vprintfmt+0x2ec>
	else if (lflag)
  800889:	85 c9                	test   %ecx,%ecx
  80088b:	74 1b                	je     8008a8 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80088d:	8b 45 14             	mov    0x14(%ebp),%eax
  800890:	8b 00                	mov    (%eax),%eax
  800892:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800895:	89 c1                	mov    %eax,%ecx
  800897:	c1 f9 1f             	sar    $0x1f,%ecx
  80089a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8d 40 04             	lea    0x4(%eax),%eax
  8008a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a6:	eb 19                	jmp    8008c1 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8b 00                	mov    (%eax),%eax
  8008ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b0:	89 c1                	mov    %eax,%ecx
  8008b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8008b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bb:	8d 40 04             	lea    0x4(%eax),%eax
  8008be:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008c7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008d0:	0f 89 0e 01 00 00    	jns    8009e4 <vprintfmt+0x40f>
				putch('-', putdat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	53                   	push   %ebx
  8008da:	6a 2d                	push   $0x2d
  8008dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8008de:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008e1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008e4:	f7 da                	neg    %edx
  8008e6:	83 d1 00             	adc    $0x0,%ecx
  8008e9:	f7 d9                	neg    %ecx
  8008eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8008ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008f3:	e9 ec 00 00 00       	jmp    8009e4 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008f8:	83 f9 01             	cmp    $0x1,%ecx
  8008fb:	7e 18                	jle    800915 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8008fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800900:	8b 10                	mov    (%eax),%edx
  800902:	8b 48 04             	mov    0x4(%eax),%ecx
  800905:	8d 40 08             	lea    0x8(%eax),%eax
  800908:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80090b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800910:	e9 cf 00 00 00       	jmp    8009e4 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800915:	85 c9                	test   %ecx,%ecx
  800917:	74 1a                	je     800933 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800919:	8b 45 14             	mov    0x14(%ebp),%eax
  80091c:	8b 10                	mov    (%eax),%edx
  80091e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800923:	8d 40 04             	lea    0x4(%eax),%eax
  800926:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800929:	b8 0a 00 00 00       	mov    $0xa,%eax
  80092e:	e9 b1 00 00 00       	jmp    8009e4 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	8b 10                	mov    (%eax),%edx
  800938:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093d:	8d 40 04             	lea    0x4(%eax),%eax
  800940:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800943:	b8 0a 00 00 00       	mov    $0xa,%eax
  800948:	e9 97 00 00 00       	jmp    8009e4 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80094d:	83 ec 08             	sub    $0x8,%esp
  800950:	53                   	push   %ebx
  800951:	6a 58                	push   $0x58
  800953:	ff d6                	call   *%esi
			putch('X', putdat);
  800955:	83 c4 08             	add    $0x8,%esp
  800958:	53                   	push   %ebx
  800959:	6a 58                	push   $0x58
  80095b:	ff d6                	call   *%esi
			putch('X', putdat);
  80095d:	83 c4 08             	add    $0x8,%esp
  800960:	53                   	push   %ebx
  800961:	6a 58                	push   $0x58
  800963:	ff d6                	call   *%esi
			break;
  800965:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800968:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80096b:	e9 8b fc ff ff       	jmp    8005fb <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800970:	83 ec 08             	sub    $0x8,%esp
  800973:	53                   	push   %ebx
  800974:	6a 30                	push   $0x30
  800976:	ff d6                	call   *%esi
			putch('x', putdat);
  800978:	83 c4 08             	add    $0x8,%esp
  80097b:	53                   	push   %ebx
  80097c:	6a 78                	push   $0x78
  80097e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800980:	8b 45 14             	mov    0x14(%ebp),%eax
  800983:	8b 10                	mov    (%eax),%edx
  800985:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80098a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80098d:	8d 40 04             	lea    0x4(%eax),%eax
  800990:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800993:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800998:	eb 4a                	jmp    8009e4 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80099a:	83 f9 01             	cmp    $0x1,%ecx
  80099d:	7e 15                	jle    8009b4 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80099f:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a2:	8b 10                	mov    (%eax),%edx
  8009a4:	8b 48 04             	mov    0x4(%eax),%ecx
  8009a7:	8d 40 08             	lea    0x8(%eax),%eax
  8009aa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009ad:	b8 10 00 00 00       	mov    $0x10,%eax
  8009b2:	eb 30                	jmp    8009e4 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8009b4:	85 c9                	test   %ecx,%ecx
  8009b6:	74 17                	je     8009cf <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8009b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bb:	8b 10                	mov    (%eax),%edx
  8009bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c2:	8d 40 04             	lea    0x4(%eax),%eax
  8009c5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009c8:	b8 10 00 00 00       	mov    $0x10,%eax
  8009cd:	eb 15                	jmp    8009e4 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8009cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d2:	8b 10                	mov    (%eax),%edx
  8009d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d9:	8d 40 04             	lea    0x4(%eax),%eax
  8009dc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009df:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009e4:	83 ec 0c             	sub    $0xc,%esp
  8009e7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8009eb:	57                   	push   %edi
  8009ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ef:	50                   	push   %eax
  8009f0:	51                   	push   %ecx
  8009f1:	52                   	push   %edx
  8009f2:	89 da                	mov    %ebx,%edx
  8009f4:	89 f0                	mov    %esi,%eax
  8009f6:	e8 f1 fa ff ff       	call   8004ec <printnum>
			break;
  8009fb:	83 c4 20             	add    $0x20,%esp
  8009fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a01:	e9 f5 fb ff ff       	jmp    8005fb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a06:	83 ec 08             	sub    $0x8,%esp
  800a09:	53                   	push   %ebx
  800a0a:	52                   	push   %edx
  800a0b:	ff d6                	call   *%esi
			break;
  800a0d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a13:	e9 e3 fb ff ff       	jmp    8005fb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a18:	83 ec 08             	sub    $0x8,%esp
  800a1b:	53                   	push   %ebx
  800a1c:	6a 25                	push   $0x25
  800a1e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a20:	83 c4 10             	add    $0x10,%esp
  800a23:	eb 03                	jmp    800a28 <vprintfmt+0x453>
  800a25:	83 ef 01             	sub    $0x1,%edi
  800a28:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a2c:	75 f7                	jne    800a25 <vprintfmt+0x450>
  800a2e:	e9 c8 fb ff ff       	jmp    8005fb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	83 ec 18             	sub    $0x18,%esp
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a47:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a4a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a4e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a58:	85 c0                	test   %eax,%eax
  800a5a:	74 26                	je     800a82 <vsnprintf+0x47>
  800a5c:	85 d2                	test   %edx,%edx
  800a5e:	7e 22                	jle    800a82 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a60:	ff 75 14             	pushl  0x14(%ebp)
  800a63:	ff 75 10             	pushl  0x10(%ebp)
  800a66:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a69:	50                   	push   %eax
  800a6a:	68 9b 05 80 00       	push   $0x80059b
  800a6f:	e8 61 fb ff ff       	call   8005d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a74:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a77:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a7d:	83 c4 10             	add    $0x10,%esp
  800a80:	eb 05                	jmp    800a87 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a87:	c9                   	leave  
  800a88:	c3                   	ret    

00800a89 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a8f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a92:	50                   	push   %eax
  800a93:	ff 75 10             	pushl  0x10(%ebp)
  800a96:	ff 75 0c             	pushl  0xc(%ebp)
  800a99:	ff 75 08             	pushl  0x8(%ebp)
  800a9c:	e8 9a ff ff ff       	call   800a3b <vsnprintf>
	va_end(ap);

	return rc;
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aae:	eb 03                	jmp    800ab3 <strlen+0x10>
		n++;
  800ab0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ab7:	75 f7                	jne    800ab0 <strlen+0xd>
		n++;
	return n;
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	eb 03                	jmp    800ace <strnlen+0x13>
		n++;
  800acb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ace:	39 c2                	cmp    %eax,%edx
  800ad0:	74 08                	je     800ada <strnlen+0x1f>
  800ad2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ad6:	75 f3                	jne    800acb <strnlen+0x10>
  800ad8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	53                   	push   %ebx
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ae6:	89 c2                	mov    %eax,%edx
  800ae8:	83 c2 01             	add    $0x1,%edx
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800af2:	88 5a ff             	mov    %bl,-0x1(%edx)
  800af5:	84 db                	test   %bl,%bl
  800af7:	75 ef                	jne    800ae8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800af9:	5b                   	pop    %ebx
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	53                   	push   %ebx
  800b00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b03:	53                   	push   %ebx
  800b04:	e8 9a ff ff ff       	call   800aa3 <strlen>
  800b09:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b0c:	ff 75 0c             	pushl  0xc(%ebp)
  800b0f:	01 d8                	add    %ebx,%eax
  800b11:	50                   	push   %eax
  800b12:	e8 c5 ff ff ff       	call   800adc <strcpy>
	return dst;
}
  800b17:	89 d8                	mov    %ebx,%eax
  800b19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1c:	c9                   	leave  
  800b1d:	c3                   	ret    

00800b1e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	8b 75 08             	mov    0x8(%ebp),%esi
  800b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b29:	89 f3                	mov    %esi,%ebx
  800b2b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b2e:	89 f2                	mov    %esi,%edx
  800b30:	eb 0f                	jmp    800b41 <strncpy+0x23>
		*dst++ = *src;
  800b32:	83 c2 01             	add    $0x1,%edx
  800b35:	0f b6 01             	movzbl (%ecx),%eax
  800b38:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b3b:	80 39 01             	cmpb   $0x1,(%ecx)
  800b3e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b41:	39 da                	cmp    %ebx,%edx
  800b43:	75 ed                	jne    800b32 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b45:	89 f0                	mov    %esi,%eax
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	8b 75 08             	mov    0x8(%ebp),%esi
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b56:	8b 55 10             	mov    0x10(%ebp),%edx
  800b59:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b5b:	85 d2                	test   %edx,%edx
  800b5d:	74 21                	je     800b80 <strlcpy+0x35>
  800b5f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b63:	89 f2                	mov    %esi,%edx
  800b65:	eb 09                	jmp    800b70 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b67:	83 c2 01             	add    $0x1,%edx
  800b6a:	83 c1 01             	add    $0x1,%ecx
  800b6d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b70:	39 c2                	cmp    %eax,%edx
  800b72:	74 09                	je     800b7d <strlcpy+0x32>
  800b74:	0f b6 19             	movzbl (%ecx),%ebx
  800b77:	84 db                	test   %bl,%bl
  800b79:	75 ec                	jne    800b67 <strlcpy+0x1c>
  800b7b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b7d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b80:	29 f0                	sub    %esi,%eax
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b8f:	eb 06                	jmp    800b97 <strcmp+0x11>
		p++, q++;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b97:	0f b6 01             	movzbl (%ecx),%eax
  800b9a:	84 c0                	test   %al,%al
  800b9c:	74 04                	je     800ba2 <strcmp+0x1c>
  800b9e:	3a 02                	cmp    (%edx),%al
  800ba0:	74 ef                	je     800b91 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba2:	0f b6 c0             	movzbl %al,%eax
  800ba5:	0f b6 12             	movzbl (%edx),%edx
  800ba8:	29 d0                	sub    %edx,%eax
}
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	53                   	push   %ebx
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb6:	89 c3                	mov    %eax,%ebx
  800bb8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bbb:	eb 06                	jmp    800bc3 <strncmp+0x17>
		n--, p++, q++;
  800bbd:	83 c0 01             	add    $0x1,%eax
  800bc0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bc3:	39 d8                	cmp    %ebx,%eax
  800bc5:	74 15                	je     800bdc <strncmp+0x30>
  800bc7:	0f b6 08             	movzbl (%eax),%ecx
  800bca:	84 c9                	test   %cl,%cl
  800bcc:	74 04                	je     800bd2 <strncmp+0x26>
  800bce:	3a 0a                	cmp    (%edx),%cl
  800bd0:	74 eb                	je     800bbd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bd2:	0f b6 00             	movzbl (%eax),%eax
  800bd5:	0f b6 12             	movzbl (%edx),%edx
  800bd8:	29 d0                	sub    %edx,%eax
  800bda:	eb 05                	jmp    800be1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bdc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800be1:	5b                   	pop    %ebx
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bee:	eb 07                	jmp    800bf7 <strchr+0x13>
		if (*s == c)
  800bf0:	38 ca                	cmp    %cl,%dl
  800bf2:	74 0f                	je     800c03 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bf4:	83 c0 01             	add    $0x1,%eax
  800bf7:	0f b6 10             	movzbl (%eax),%edx
  800bfa:	84 d2                	test   %dl,%dl
  800bfc:	75 f2                	jne    800bf0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800bfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c0f:	eb 03                	jmp    800c14 <strfind+0xf>
  800c11:	83 c0 01             	add    $0x1,%eax
  800c14:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c17:	38 ca                	cmp    %cl,%dl
  800c19:	74 04                	je     800c1f <strfind+0x1a>
  800c1b:	84 d2                	test   %dl,%dl
  800c1d:	75 f2                	jne    800c11 <strfind+0xc>
			break;
	return (char *) s;
}
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c2d:	85 c9                	test   %ecx,%ecx
  800c2f:	74 36                	je     800c67 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c37:	75 28                	jne    800c61 <memset+0x40>
  800c39:	f6 c1 03             	test   $0x3,%cl
  800c3c:	75 23                	jne    800c61 <memset+0x40>
		c &= 0xFF;
  800c3e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c42:	89 d3                	mov    %edx,%ebx
  800c44:	c1 e3 08             	shl    $0x8,%ebx
  800c47:	89 d6                	mov    %edx,%esi
  800c49:	c1 e6 18             	shl    $0x18,%esi
  800c4c:	89 d0                	mov    %edx,%eax
  800c4e:	c1 e0 10             	shl    $0x10,%eax
  800c51:	09 f0                	or     %esi,%eax
  800c53:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c55:	89 d8                	mov    %ebx,%eax
  800c57:	09 d0                	or     %edx,%eax
  800c59:	c1 e9 02             	shr    $0x2,%ecx
  800c5c:	fc                   	cld    
  800c5d:	f3 ab                	rep stos %eax,%es:(%edi)
  800c5f:	eb 06                	jmp    800c67 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c64:	fc                   	cld    
  800c65:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c67:	89 f8                	mov    %edi,%eax
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	8b 45 08             	mov    0x8(%ebp),%eax
  800c76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c7c:	39 c6                	cmp    %eax,%esi
  800c7e:	73 35                	jae    800cb5 <memmove+0x47>
  800c80:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c83:	39 d0                	cmp    %edx,%eax
  800c85:	73 2e                	jae    800cb5 <memmove+0x47>
		s += n;
		d += n;
  800c87:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	09 fe                	or     %edi,%esi
  800c8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c94:	75 13                	jne    800ca9 <memmove+0x3b>
  800c96:	f6 c1 03             	test   $0x3,%cl
  800c99:	75 0e                	jne    800ca9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c9b:	83 ef 04             	sub    $0x4,%edi
  800c9e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca1:	c1 e9 02             	shr    $0x2,%ecx
  800ca4:	fd                   	std    
  800ca5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca7:	eb 09                	jmp    800cb2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ca9:	83 ef 01             	sub    $0x1,%edi
  800cac:	8d 72 ff             	lea    -0x1(%edx),%esi
  800caf:	fd                   	std    
  800cb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb2:	fc                   	cld    
  800cb3:	eb 1d                	jmp    800cd2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb5:	89 f2                	mov    %esi,%edx
  800cb7:	09 c2                	or     %eax,%edx
  800cb9:	f6 c2 03             	test   $0x3,%dl
  800cbc:	75 0f                	jne    800ccd <memmove+0x5f>
  800cbe:	f6 c1 03             	test   $0x3,%cl
  800cc1:	75 0a                	jne    800ccd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800cc3:	c1 e9 02             	shr    $0x2,%ecx
  800cc6:	89 c7                	mov    %eax,%edi
  800cc8:	fc                   	cld    
  800cc9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccb:	eb 05                	jmp    800cd2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ccd:	89 c7                	mov    %eax,%edi
  800ccf:	fc                   	cld    
  800cd0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cd9:	ff 75 10             	pushl  0x10(%ebp)
  800cdc:	ff 75 0c             	pushl  0xc(%ebp)
  800cdf:	ff 75 08             	pushl  0x8(%ebp)
  800ce2:	e8 87 ff ff ff       	call   800c6e <memmove>
}
  800ce7:	c9                   	leave  
  800ce8:	c3                   	ret    

00800ce9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cf4:	89 c6                	mov    %eax,%esi
  800cf6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf9:	eb 1a                	jmp    800d15 <memcmp+0x2c>
		if (*s1 != *s2)
  800cfb:	0f b6 08             	movzbl (%eax),%ecx
  800cfe:	0f b6 1a             	movzbl (%edx),%ebx
  800d01:	38 d9                	cmp    %bl,%cl
  800d03:	74 0a                	je     800d0f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d05:	0f b6 c1             	movzbl %cl,%eax
  800d08:	0f b6 db             	movzbl %bl,%ebx
  800d0b:	29 d8                	sub    %ebx,%eax
  800d0d:	eb 0f                	jmp    800d1e <memcmp+0x35>
		s1++, s2++;
  800d0f:	83 c0 01             	add    $0x1,%eax
  800d12:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d15:	39 f0                	cmp    %esi,%eax
  800d17:	75 e2                	jne    800cfb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	53                   	push   %ebx
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d29:	89 c1                	mov    %eax,%ecx
  800d2b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d2e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d32:	eb 0a                	jmp    800d3e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d34:	0f b6 10             	movzbl (%eax),%edx
  800d37:	39 da                	cmp    %ebx,%edx
  800d39:	74 07                	je     800d42 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d3b:	83 c0 01             	add    $0x1,%eax
  800d3e:	39 c8                	cmp    %ecx,%eax
  800d40:	72 f2                	jb     800d34 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d42:	5b                   	pop    %ebx
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d51:	eb 03                	jmp    800d56 <strtol+0x11>
		s++;
  800d53:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d56:	0f b6 01             	movzbl (%ecx),%eax
  800d59:	3c 20                	cmp    $0x20,%al
  800d5b:	74 f6                	je     800d53 <strtol+0xe>
  800d5d:	3c 09                	cmp    $0x9,%al
  800d5f:	74 f2                	je     800d53 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d61:	3c 2b                	cmp    $0x2b,%al
  800d63:	75 0a                	jne    800d6f <strtol+0x2a>
		s++;
  800d65:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d68:	bf 00 00 00 00       	mov    $0x0,%edi
  800d6d:	eb 11                	jmp    800d80 <strtol+0x3b>
  800d6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d74:	3c 2d                	cmp    $0x2d,%al
  800d76:	75 08                	jne    800d80 <strtol+0x3b>
		s++, neg = 1;
  800d78:	83 c1 01             	add    $0x1,%ecx
  800d7b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d80:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d86:	75 15                	jne    800d9d <strtol+0x58>
  800d88:	80 39 30             	cmpb   $0x30,(%ecx)
  800d8b:	75 10                	jne    800d9d <strtol+0x58>
  800d8d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d91:	75 7c                	jne    800e0f <strtol+0xca>
		s += 2, base = 16;
  800d93:	83 c1 02             	add    $0x2,%ecx
  800d96:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d9b:	eb 16                	jmp    800db3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d9d:	85 db                	test   %ebx,%ebx
  800d9f:	75 12                	jne    800db3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800da1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800da6:	80 39 30             	cmpb   $0x30,(%ecx)
  800da9:	75 08                	jne    800db3 <strtol+0x6e>
		s++, base = 8;
  800dab:	83 c1 01             	add    $0x1,%ecx
  800dae:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800db3:	b8 00 00 00 00       	mov    $0x0,%eax
  800db8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dbb:	0f b6 11             	movzbl (%ecx),%edx
  800dbe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dc1:	89 f3                	mov    %esi,%ebx
  800dc3:	80 fb 09             	cmp    $0x9,%bl
  800dc6:	77 08                	ja     800dd0 <strtol+0x8b>
			dig = *s - '0';
  800dc8:	0f be d2             	movsbl %dl,%edx
  800dcb:	83 ea 30             	sub    $0x30,%edx
  800dce:	eb 22                	jmp    800df2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800dd0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dd3:	89 f3                	mov    %esi,%ebx
  800dd5:	80 fb 19             	cmp    $0x19,%bl
  800dd8:	77 08                	ja     800de2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800dda:	0f be d2             	movsbl %dl,%edx
  800ddd:	83 ea 57             	sub    $0x57,%edx
  800de0:	eb 10                	jmp    800df2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800de2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800de5:	89 f3                	mov    %esi,%ebx
  800de7:	80 fb 19             	cmp    $0x19,%bl
  800dea:	77 16                	ja     800e02 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800dec:	0f be d2             	movsbl %dl,%edx
  800def:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800df2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800df5:	7d 0b                	jge    800e02 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800df7:	83 c1 01             	add    $0x1,%ecx
  800dfa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dfe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e00:	eb b9                	jmp    800dbb <strtol+0x76>

	if (endptr)
  800e02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e06:	74 0d                	je     800e15 <strtol+0xd0>
		*endptr = (char *) s;
  800e08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e0b:	89 0e                	mov    %ecx,(%esi)
  800e0d:	eb 06                	jmp    800e15 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0f:	85 db                	test   %ebx,%ebx
  800e11:	74 98                	je     800dab <strtol+0x66>
  800e13:	eb 9e                	jmp    800db3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e15:	89 c2                	mov    %eax,%edx
  800e17:	f7 da                	neg    %edx
  800e19:	85 ff                	test   %edi,%edi
  800e1b:	0f 45 c2             	cmovne %edx,%eax
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e29:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	8b 55 08             	mov    0x8(%ebp),%edx
  800e34:	89 c3                	mov    %eax,%ebx
  800e36:	89 c7                	mov    %eax,%edi
  800e38:	89 c6                	mov    %eax,%esi
  800e3a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e47:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e51:	89 d1                	mov    %edx,%ecx
  800e53:	89 d3                	mov    %edx,%ebx
  800e55:	89 d7                	mov    %edx,%edi
  800e57:	89 d6                	mov    %edx,%esi
  800e59:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	89 cb                	mov    %ecx,%ebx
  800e78:	89 cf                	mov    %ecx,%edi
  800e7a:	89 ce                	mov    %ecx,%esi
  800e7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	7e 17                	jle    800e99 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e82:	83 ec 0c             	sub    $0xc,%esp
  800e85:	50                   	push   %eax
  800e86:	6a 03                	push   $0x3
  800e88:	68 7f 2a 80 00       	push   $0x802a7f
  800e8d:	6a 23                	push   $0x23
  800e8f:	68 9c 2a 80 00       	push   $0x802a9c
  800e94:	e8 66 f5 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eac:	b8 02 00 00 00       	mov    $0x2,%eax
  800eb1:	89 d1                	mov    %edx,%ecx
  800eb3:	89 d3                	mov    %edx,%ebx
  800eb5:	89 d7                	mov    %edx,%edi
  800eb7:	89 d6                	mov    %edx,%esi
  800eb9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <sys_yield>:

void
sys_yield(void)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed0:	89 d1                	mov    %edx,%ecx
  800ed2:	89 d3                	mov    %edx,%ebx
  800ed4:	89 d7                	mov    %edx,%edi
  800ed6:	89 d6                	mov    %edx,%esi
  800ed8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800eda:	5b                   	pop    %ebx
  800edb:	5e                   	pop    %esi
  800edc:	5f                   	pop    %edi
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee8:	be 00 00 00 00       	mov    $0x0,%esi
  800eed:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efb:	89 f7                	mov    %esi,%edi
  800efd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eff:	85 c0                	test   %eax,%eax
  800f01:	7e 17                	jle    800f1a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	50                   	push   %eax
  800f07:	6a 04                	push   $0x4
  800f09:	68 7f 2a 80 00       	push   $0x802a7f
  800f0e:	6a 23                	push   $0x23
  800f10:	68 9c 2a 80 00       	push   $0x802a9c
  800f15:	e8 e5 f4 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	57                   	push   %edi
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2b:	b8 05 00 00 00       	mov    $0x5,%eax
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	8b 55 08             	mov    0x8(%ebp),%edx
  800f36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3c:	8b 75 18             	mov    0x18(%ebp),%esi
  800f3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 17                	jle    800f5c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f45:	83 ec 0c             	sub    $0xc,%esp
  800f48:	50                   	push   %eax
  800f49:	6a 05                	push   $0x5
  800f4b:	68 7f 2a 80 00       	push   $0x802a7f
  800f50:	6a 23                	push   $0x23
  800f52:	68 9c 2a 80 00       	push   $0x802a9c
  800f57:	e8 a3 f4 ff ff       	call   8003ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
  800f6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f72:	b8 06 00 00 00       	mov    $0x6,%eax
  800f77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7d:	89 df                	mov    %ebx,%edi
  800f7f:	89 de                	mov    %ebx,%esi
  800f81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f83:	85 c0                	test   %eax,%eax
  800f85:	7e 17                	jle    800f9e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f87:	83 ec 0c             	sub    $0xc,%esp
  800f8a:	50                   	push   %eax
  800f8b:	6a 06                	push   $0x6
  800f8d:	68 7f 2a 80 00       	push   $0x802a7f
  800f92:	6a 23                	push   $0x23
  800f94:	68 9c 2a 80 00       	push   $0x802a9c
  800f99:	e8 61 f4 ff ff       	call   8003ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800faf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb4:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbf:	89 df                	mov    %ebx,%edi
  800fc1:	89 de                	mov    %ebx,%esi
  800fc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	7e 17                	jle    800fe0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc9:	83 ec 0c             	sub    $0xc,%esp
  800fcc:	50                   	push   %eax
  800fcd:	6a 08                	push   $0x8
  800fcf:	68 7f 2a 80 00       	push   $0x802a7f
  800fd4:	6a 23                	push   $0x23
  800fd6:	68 9c 2a 80 00       	push   $0x802a9c
  800fdb:	e8 1f f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fe0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe3:	5b                   	pop    %ebx
  800fe4:	5e                   	pop    %esi
  800fe5:	5f                   	pop    %edi
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	57                   	push   %edi
  800fec:	56                   	push   %esi
  800fed:	53                   	push   %ebx
  800fee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff6:	b8 09 00 00 00       	mov    $0x9,%eax
  800ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	89 df                	mov    %ebx,%edi
  801003:	89 de                	mov    %ebx,%esi
  801005:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801007:	85 c0                	test   %eax,%eax
  801009:	7e 17                	jle    801022 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	50                   	push   %eax
  80100f:	6a 09                	push   $0x9
  801011:	68 7f 2a 80 00       	push   $0x802a7f
  801016:	6a 23                	push   $0x23
  801018:	68 9c 2a 80 00       	push   $0x802a9c
  80101d:	e8 dd f3 ff ff       	call   8003ff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801022:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801025:	5b                   	pop    %ebx
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	57                   	push   %edi
  80102e:	56                   	push   %esi
  80102f:	53                   	push   %ebx
  801030:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
  801038:	b8 0a 00 00 00       	mov    $0xa,%eax
  80103d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801040:	8b 55 08             	mov    0x8(%ebp),%edx
  801043:	89 df                	mov    %ebx,%edi
  801045:	89 de                	mov    %ebx,%esi
  801047:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801049:	85 c0                	test   %eax,%eax
  80104b:	7e 17                	jle    801064 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	50                   	push   %eax
  801051:	6a 0a                	push   $0xa
  801053:	68 7f 2a 80 00       	push   $0x802a7f
  801058:	6a 23                	push   $0x23
  80105a:	68 9c 2a 80 00       	push   $0x802a9c
  80105f:	e8 9b f3 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801064:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5f                   	pop    %edi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	57                   	push   %edi
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801072:	be 00 00 00 00       	mov    $0x0,%esi
  801077:	b8 0c 00 00 00       	mov    $0xc,%eax
  80107c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107f:	8b 55 08             	mov    0x8(%ebp),%edx
  801082:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801085:	8b 7d 14             	mov    0x14(%ebp),%edi
  801088:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80108a:	5b                   	pop    %ebx
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    

0080108f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	57                   	push   %edi
  801093:	56                   	push   %esi
  801094:	53                   	push   %ebx
  801095:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801098:	b9 00 00 00 00       	mov    $0x0,%ecx
  80109d:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a5:	89 cb                	mov    %ecx,%ebx
  8010a7:	89 cf                	mov    %ecx,%edi
  8010a9:	89 ce                	mov    %ecx,%esi
  8010ab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	7e 17                	jle    8010c8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	50                   	push   %eax
  8010b5:	6a 0d                	push   $0xd
  8010b7:	68 7f 2a 80 00       	push   $0x802a7f
  8010bc:	6a 23                	push   $0x23
  8010be:	68 9c 2a 80 00       	push   $0x802a9c
  8010c3:	e8 37 f3 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010db:	c1 e8 0c             	shr    $0xc,%eax
}
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801102:	89 c2                	mov    %eax,%edx
  801104:	c1 ea 16             	shr    $0x16,%edx
  801107:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110e:	f6 c2 01             	test   $0x1,%dl
  801111:	74 11                	je     801124 <fd_alloc+0x2d>
  801113:	89 c2                	mov    %eax,%edx
  801115:	c1 ea 0c             	shr    $0xc,%edx
  801118:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111f:	f6 c2 01             	test   $0x1,%dl
  801122:	75 09                	jne    80112d <fd_alloc+0x36>
			*fd_store = fd;
  801124:	89 01                	mov    %eax,(%ecx)
			return 0;
  801126:	b8 00 00 00 00       	mov    $0x0,%eax
  80112b:	eb 17                	jmp    801144 <fd_alloc+0x4d>
  80112d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801132:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801137:	75 c9                	jne    801102 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801139:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80113f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114c:	83 f8 1f             	cmp    $0x1f,%eax
  80114f:	77 36                	ja     801187 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801151:	c1 e0 0c             	shl    $0xc,%eax
  801154:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801159:	89 c2                	mov    %eax,%edx
  80115b:	c1 ea 16             	shr    $0x16,%edx
  80115e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801165:	f6 c2 01             	test   $0x1,%dl
  801168:	74 24                	je     80118e <fd_lookup+0x48>
  80116a:	89 c2                	mov    %eax,%edx
  80116c:	c1 ea 0c             	shr    $0xc,%edx
  80116f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801176:	f6 c2 01             	test   $0x1,%dl
  801179:	74 1a                	je     801195 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80117b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117e:	89 02                	mov    %eax,(%edx)
	return 0;
  801180:	b8 00 00 00 00       	mov    $0x0,%eax
  801185:	eb 13                	jmp    80119a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801187:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118c:	eb 0c                	jmp    80119a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80118e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801193:	eb 05                	jmp    80119a <fd_lookup+0x54>
  801195:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	83 ec 08             	sub    $0x8,%esp
  8011a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a5:	ba 28 2b 80 00       	mov    $0x802b28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011aa:	eb 13                	jmp    8011bf <dev_lookup+0x23>
  8011ac:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011af:	39 08                	cmp    %ecx,(%eax)
  8011b1:	75 0c                	jne    8011bf <dev_lookup+0x23>
			*dev = devtab[i];
  8011b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bd:	eb 2e                	jmp    8011ed <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011bf:	8b 02                	mov    (%edx),%eax
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	75 e7                	jne    8011ac <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c5:	a1 90 67 80 00       	mov    0x806790,%eax
  8011ca:	8b 40 48             	mov    0x48(%eax),%eax
  8011cd:	83 ec 04             	sub    $0x4,%esp
  8011d0:	51                   	push   %ecx
  8011d1:	50                   	push   %eax
  8011d2:	68 ac 2a 80 00       	push   $0x802aac
  8011d7:	e8 fc f2 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  8011dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 10             	sub    $0x10,%esp
  8011f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801200:	50                   	push   %eax
  801201:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801207:	c1 e8 0c             	shr    $0xc,%eax
  80120a:	50                   	push   %eax
  80120b:	e8 36 ff ff ff       	call   801146 <fd_lookup>
  801210:	83 c4 08             	add    $0x8,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	78 05                	js     80121c <fd_close+0x2d>
	    || fd != fd2)
  801217:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80121a:	74 0c                	je     801228 <fd_close+0x39>
		return (must_exist ? r : 0);
  80121c:	84 db                	test   %bl,%bl
  80121e:	ba 00 00 00 00       	mov    $0x0,%edx
  801223:	0f 44 c2             	cmove  %edx,%eax
  801226:	eb 41                	jmp    801269 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801228:	83 ec 08             	sub    $0x8,%esp
  80122b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	ff 36                	pushl  (%esi)
  801231:	e8 66 ff ff ff       	call   80119c <dev_lookup>
  801236:	89 c3                	mov    %eax,%ebx
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 1a                	js     801259 <fd_close+0x6a>
		if (dev->dev_close)
  80123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801242:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801245:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80124a:	85 c0                	test   %eax,%eax
  80124c:	74 0b                	je     801259 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	56                   	push   %esi
  801252:	ff d0                	call   *%eax
  801254:	89 c3                	mov    %eax,%ebx
  801256:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801259:	83 ec 08             	sub    $0x8,%esp
  80125c:	56                   	push   %esi
  80125d:	6a 00                	push   $0x0
  80125f:	e8 00 fd ff ff       	call   800f64 <sys_page_unmap>
	return r;
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	89 d8                	mov    %ebx,%eax
}
  801269:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801276:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	ff 75 08             	pushl  0x8(%ebp)
  80127d:	e8 c4 fe ff ff       	call   801146 <fd_lookup>
  801282:	83 c4 08             	add    $0x8,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	78 10                	js     801299 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	6a 01                	push   $0x1
  80128e:	ff 75 f4             	pushl  -0xc(%ebp)
  801291:	e8 59 ff ff ff       	call   8011ef <fd_close>
  801296:	83 c4 10             	add    $0x10,%esp
}
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <close_all>:

void
close_all(void)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	53                   	push   %ebx
  80129f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a7:	83 ec 0c             	sub    $0xc,%esp
  8012aa:	53                   	push   %ebx
  8012ab:	e8 c0 ff ff ff       	call   801270 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b0:	83 c3 01             	add    $0x1,%ebx
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	83 fb 20             	cmp    $0x20,%ebx
  8012b9:	75 ec                	jne    8012a7 <close_all+0xc>
		close(i);
}
  8012bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	57                   	push   %edi
  8012c4:	56                   	push   %esi
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 2c             	sub    $0x2c,%esp
  8012c9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	ff 75 08             	pushl  0x8(%ebp)
  8012d3:	e8 6e fe ff ff       	call   801146 <fd_lookup>
  8012d8:	83 c4 08             	add    $0x8,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	0f 88 c1 00 00 00    	js     8013a4 <dup+0xe4>
		return r;
	close(newfdnum);
  8012e3:	83 ec 0c             	sub    $0xc,%esp
  8012e6:	56                   	push   %esi
  8012e7:	e8 84 ff ff ff       	call   801270 <close>

	newfd = INDEX2FD(newfdnum);
  8012ec:	89 f3                	mov    %esi,%ebx
  8012ee:	c1 e3 0c             	shl    $0xc,%ebx
  8012f1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012f7:	83 c4 04             	add    $0x4,%esp
  8012fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012fd:	e8 de fd ff ff       	call   8010e0 <fd2data>
  801302:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801304:	89 1c 24             	mov    %ebx,(%esp)
  801307:	e8 d4 fd ff ff       	call   8010e0 <fd2data>
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801312:	89 f8                	mov    %edi,%eax
  801314:	c1 e8 16             	shr    $0x16,%eax
  801317:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80131e:	a8 01                	test   $0x1,%al
  801320:	74 37                	je     801359 <dup+0x99>
  801322:	89 f8                	mov    %edi,%eax
  801324:	c1 e8 0c             	shr    $0xc,%eax
  801327:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80132e:	f6 c2 01             	test   $0x1,%dl
  801331:	74 26                	je     801359 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801333:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	25 07 0e 00 00       	and    $0xe07,%eax
  801342:	50                   	push   %eax
  801343:	ff 75 d4             	pushl  -0x2c(%ebp)
  801346:	6a 00                	push   $0x0
  801348:	57                   	push   %edi
  801349:	6a 00                	push   $0x0
  80134b:	e8 d2 fb ff ff       	call   800f22 <sys_page_map>
  801350:	89 c7                	mov    %eax,%edi
  801352:	83 c4 20             	add    $0x20,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 2e                	js     801387 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801359:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80135c:	89 d0                	mov    %edx,%eax
  80135e:	c1 e8 0c             	shr    $0xc,%eax
  801361:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	25 07 0e 00 00       	and    $0xe07,%eax
  801370:	50                   	push   %eax
  801371:	53                   	push   %ebx
  801372:	6a 00                	push   $0x0
  801374:	52                   	push   %edx
  801375:	6a 00                	push   $0x0
  801377:	e8 a6 fb ff ff       	call   800f22 <sys_page_map>
  80137c:	89 c7                	mov    %eax,%edi
  80137e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801381:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801383:	85 ff                	test   %edi,%edi
  801385:	79 1d                	jns    8013a4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	53                   	push   %ebx
  80138b:	6a 00                	push   $0x0
  80138d:	e8 d2 fb ff ff       	call   800f64 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801392:	83 c4 08             	add    $0x8,%esp
  801395:	ff 75 d4             	pushl  -0x2c(%ebp)
  801398:	6a 00                	push   $0x0
  80139a:	e8 c5 fb ff ff       	call   800f64 <sys_page_unmap>
	return r;
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	89 f8                	mov    %edi,%eax
}
  8013a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	5f                   	pop    %edi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	53                   	push   %ebx
  8013b0:	83 ec 14             	sub    $0x14,%esp
  8013b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b9:	50                   	push   %eax
  8013ba:	53                   	push   %ebx
  8013bb:	e8 86 fd ff ff       	call   801146 <fd_lookup>
  8013c0:	83 c4 08             	add    $0x8,%esp
  8013c3:	89 c2                	mov    %eax,%edx
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 6d                	js     801436 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c9:	83 ec 08             	sub    $0x8,%esp
  8013cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d3:	ff 30                	pushl  (%eax)
  8013d5:	e8 c2 fd ff ff       	call   80119c <dev_lookup>
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 4c                	js     80142d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e4:	8b 42 08             	mov    0x8(%edx),%eax
  8013e7:	83 e0 03             	and    $0x3,%eax
  8013ea:	83 f8 01             	cmp    $0x1,%eax
  8013ed:	75 21                	jne    801410 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ef:	a1 90 67 80 00       	mov    0x806790,%eax
  8013f4:	8b 40 48             	mov    0x48(%eax),%eax
  8013f7:	83 ec 04             	sub    $0x4,%esp
  8013fa:	53                   	push   %ebx
  8013fb:	50                   	push   %eax
  8013fc:	68 ed 2a 80 00       	push   $0x802aed
  801401:	e8 d2 f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80140e:	eb 26                	jmp    801436 <read+0x8a>
	}
	if (!dev->dev_read)
  801410:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801413:	8b 40 08             	mov    0x8(%eax),%eax
  801416:	85 c0                	test   %eax,%eax
  801418:	74 17                	je     801431 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80141a:	83 ec 04             	sub    $0x4,%esp
  80141d:	ff 75 10             	pushl  0x10(%ebp)
  801420:	ff 75 0c             	pushl  0xc(%ebp)
  801423:	52                   	push   %edx
  801424:	ff d0                	call   *%eax
  801426:	89 c2                	mov    %eax,%edx
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	eb 09                	jmp    801436 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142d:	89 c2                	mov    %eax,%edx
  80142f:	eb 05                	jmp    801436 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801431:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801436:	89 d0                	mov    %edx,%eax
  801438:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	57                   	push   %edi
  801441:	56                   	push   %esi
  801442:	53                   	push   %ebx
  801443:	83 ec 0c             	sub    $0xc,%esp
  801446:	8b 7d 08             	mov    0x8(%ebp),%edi
  801449:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801451:	eb 21                	jmp    801474 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801453:	83 ec 04             	sub    $0x4,%esp
  801456:	89 f0                	mov    %esi,%eax
  801458:	29 d8                	sub    %ebx,%eax
  80145a:	50                   	push   %eax
  80145b:	89 d8                	mov    %ebx,%eax
  80145d:	03 45 0c             	add    0xc(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	57                   	push   %edi
  801462:	e8 45 ff ff ff       	call   8013ac <read>
		if (m < 0)
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 10                	js     80147e <readn+0x41>
			return m;
		if (m == 0)
  80146e:	85 c0                	test   %eax,%eax
  801470:	74 0a                	je     80147c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801472:	01 c3                	add    %eax,%ebx
  801474:	39 f3                	cmp    %esi,%ebx
  801476:	72 db                	jb     801453 <readn+0x16>
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	eb 02                	jmp    80147e <readn+0x41>
  80147c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80147e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5f                   	pop    %edi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	53                   	push   %ebx
  80148a:	83 ec 14             	sub    $0x14,%esp
  80148d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801490:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801493:	50                   	push   %eax
  801494:	53                   	push   %ebx
  801495:	e8 ac fc ff ff       	call   801146 <fd_lookup>
  80149a:	83 c4 08             	add    $0x8,%esp
  80149d:	89 c2                	mov    %eax,%edx
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 68                	js     80150b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a3:	83 ec 08             	sub    $0x8,%esp
  8014a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a9:	50                   	push   %eax
  8014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ad:	ff 30                	pushl  (%eax)
  8014af:	e8 e8 fc ff ff       	call   80119c <dev_lookup>
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 47                	js     801502 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c2:	75 21                	jne    8014e5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c4:	a1 90 67 80 00       	mov    0x806790,%eax
  8014c9:	8b 40 48             	mov    0x48(%eax),%eax
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	53                   	push   %ebx
  8014d0:	50                   	push   %eax
  8014d1:	68 09 2b 80 00       	push   $0x802b09
  8014d6:	e8 fd ef ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e3:	eb 26                	jmp    80150b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014eb:	85 d2                	test   %edx,%edx
  8014ed:	74 17                	je     801506 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ef:	83 ec 04             	sub    $0x4,%esp
  8014f2:	ff 75 10             	pushl  0x10(%ebp)
  8014f5:	ff 75 0c             	pushl  0xc(%ebp)
  8014f8:	50                   	push   %eax
  8014f9:	ff d2                	call   *%edx
  8014fb:	89 c2                	mov    %eax,%edx
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	eb 09                	jmp    80150b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801502:	89 c2                	mov    %eax,%edx
  801504:	eb 05                	jmp    80150b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801506:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80150b:	89 d0                	mov    %edx,%eax
  80150d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801510:	c9                   	leave  
  801511:	c3                   	ret    

00801512 <seek>:

int
seek(int fdnum, off_t offset)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801518:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	ff 75 08             	pushl  0x8(%ebp)
  80151f:	e8 22 fc ff ff       	call   801146 <fd_lookup>
  801524:	83 c4 08             	add    $0x8,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 0e                	js     801539 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80152b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80152e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801531:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801534:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801539:	c9                   	leave  
  80153a:	c3                   	ret    

0080153b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	53                   	push   %ebx
  80153f:	83 ec 14             	sub    $0x14,%esp
  801542:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801545:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	53                   	push   %ebx
  80154a:	e8 f7 fb ff ff       	call   801146 <fd_lookup>
  80154f:	83 c4 08             	add    $0x8,%esp
  801552:	89 c2                	mov    %eax,%edx
  801554:	85 c0                	test   %eax,%eax
  801556:	78 65                	js     8015bd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155e:	50                   	push   %eax
  80155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801562:	ff 30                	pushl  (%eax)
  801564:	e8 33 fc ff ff       	call   80119c <dev_lookup>
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 44                	js     8015b4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801570:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801573:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801577:	75 21                	jne    80159a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801579:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80157e:	8b 40 48             	mov    0x48(%eax),%eax
  801581:	83 ec 04             	sub    $0x4,%esp
  801584:	53                   	push   %ebx
  801585:	50                   	push   %eax
  801586:	68 cc 2a 80 00       	push   $0x802acc
  80158b:	e8 48 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801598:	eb 23                	jmp    8015bd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80159a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159d:	8b 52 18             	mov    0x18(%edx),%edx
  8015a0:	85 d2                	test   %edx,%edx
  8015a2:	74 14                	je     8015b8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	ff 75 0c             	pushl  0xc(%ebp)
  8015aa:	50                   	push   %eax
  8015ab:	ff d2                	call   *%edx
  8015ad:	89 c2                	mov    %eax,%edx
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	eb 09                	jmp    8015bd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b4:	89 c2                	mov    %eax,%edx
  8015b6:	eb 05                	jmp    8015bd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015bd:	89 d0                	mov    %edx,%eax
  8015bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 14             	sub    $0x14,%esp
  8015cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	ff 75 08             	pushl  0x8(%ebp)
  8015d5:	e8 6c fb ff ff       	call   801146 <fd_lookup>
  8015da:	83 c4 08             	add    $0x8,%esp
  8015dd:	89 c2                	mov    %eax,%edx
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 58                	js     80163b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ed:	ff 30                	pushl  (%eax)
  8015ef:	e8 a8 fb ff ff       	call   80119c <dev_lookup>
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 37                	js     801632 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801602:	74 32                	je     801636 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801604:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801607:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80160e:	00 00 00 
	stat->st_isdir = 0;
  801611:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801618:	00 00 00 
	stat->st_dev = dev;
  80161b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	53                   	push   %ebx
  801625:	ff 75 f0             	pushl  -0x10(%ebp)
  801628:	ff 50 14             	call   *0x14(%eax)
  80162b:	89 c2                	mov    %eax,%edx
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	eb 09                	jmp    80163b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801632:	89 c2                	mov    %eax,%edx
  801634:	eb 05                	jmp    80163b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801636:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80163b:	89 d0                	mov    %edx,%eax
  80163d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801640:	c9                   	leave  
  801641:	c3                   	ret    

00801642 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	56                   	push   %esi
  801646:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	6a 00                	push   $0x0
  80164c:	ff 75 08             	pushl  0x8(%ebp)
  80164f:	e8 e3 01 00 00       	call   801837 <open>
  801654:	89 c3                	mov    %eax,%ebx
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 1b                	js     801678 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	ff 75 0c             	pushl  0xc(%ebp)
  801663:	50                   	push   %eax
  801664:	e8 5b ff ff ff       	call   8015c4 <fstat>
  801669:	89 c6                	mov    %eax,%esi
	close(fd);
  80166b:	89 1c 24             	mov    %ebx,(%esp)
  80166e:	e8 fd fb ff ff       	call   801270 <close>
	return r;
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	89 f0                	mov    %esi,%eax
}
  801678:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	89 c6                	mov    %eax,%esi
  801686:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801688:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80168f:	75 12                	jne    8016a3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801691:	83 ec 0c             	sub    $0xc,%esp
  801694:	6a 01                	push   $0x1
  801696:	e8 4d 0c 00 00       	call   8022e8 <ipc_find_env>
  80169b:	a3 00 50 80 00       	mov    %eax,0x805000
  8016a0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a3:	6a 07                	push   $0x7
  8016a5:	68 00 70 80 00       	push   $0x807000
  8016aa:	56                   	push   %esi
  8016ab:	ff 35 00 50 80 00    	pushl  0x805000
  8016b1:	e8 de 0b 00 00       	call   802294 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b6:	83 c4 0c             	add    $0xc,%esp
  8016b9:	6a 00                	push   $0x0
  8016bb:	53                   	push   %ebx
  8016bc:	6a 00                	push   $0x0
  8016be:	e8 5f 0b 00 00       	call   802222 <ipc_recv>
}
  8016c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d6:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8016db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016de:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ed:	e8 8d ff ff ff       	call   80167f <fsipc>
}
  8016f2:	c9                   	leave  
  8016f3:	c3                   	ret    

008016f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801700:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
  80170a:	b8 06 00 00 00       	mov    $0x6,%eax
  80170f:	e8 6b ff ff ff       	call   80167f <fsipc>
}
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	53                   	push   %ebx
  80171a:	83 ec 04             	sub    $0x4,%esp
  80171d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801720:	8b 45 08             	mov    0x8(%ebp),%eax
  801723:	8b 40 0c             	mov    0xc(%eax),%eax
  801726:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172b:	ba 00 00 00 00       	mov    $0x0,%edx
  801730:	b8 05 00 00 00       	mov    $0x5,%eax
  801735:	e8 45 ff ff ff       	call   80167f <fsipc>
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 2c                	js     80176a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80173e:	83 ec 08             	sub    $0x8,%esp
  801741:	68 00 70 80 00       	push   $0x807000
  801746:	53                   	push   %ebx
  801747:	e8 90 f3 ff ff       	call   800adc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80174c:	a1 80 70 80 00       	mov    0x807080,%eax
  801751:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801757:	a1 84 70 80 00       	mov    0x807084,%eax
  80175c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	83 ec 0c             	sub    $0xc,%esp
  801775:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801778:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80177d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801782:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801785:	8b 55 08             	mov    0x8(%ebp),%edx
  801788:	8b 52 0c             	mov    0xc(%edx),%edx
  80178b:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  801791:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801796:	50                   	push   %eax
  801797:	ff 75 0c             	pushl  0xc(%ebp)
  80179a:	68 08 70 80 00       	push   $0x807008
  80179f:	e8 ca f4 ff ff       	call   800c6e <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a9:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ae:	e8 cc fe ff ff       	call   80167f <fsipc>
}
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	56                   	push   %esi
  8017b9:	53                   	push   %ebx
  8017ba:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c3:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8017c8:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d8:	e8 a2 fe ff ff       	call   80167f <fsipc>
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 4b                	js     80182e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017e3:	39 c6                	cmp    %eax,%esi
  8017e5:	73 16                	jae    8017fd <devfile_read+0x48>
  8017e7:	68 38 2b 80 00       	push   $0x802b38
  8017ec:	68 3f 2b 80 00       	push   $0x802b3f
  8017f1:	6a 7c                	push   $0x7c
  8017f3:	68 54 2b 80 00       	push   $0x802b54
  8017f8:	e8 02 ec ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  8017fd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801802:	7e 16                	jle    80181a <devfile_read+0x65>
  801804:	68 5f 2b 80 00       	push   $0x802b5f
  801809:	68 3f 2b 80 00       	push   $0x802b3f
  80180e:	6a 7d                	push   $0x7d
  801810:	68 54 2b 80 00       	push   $0x802b54
  801815:	e8 e5 eb ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	50                   	push   %eax
  80181e:	68 00 70 80 00       	push   $0x807000
  801823:	ff 75 0c             	pushl  0xc(%ebp)
  801826:	e8 43 f4 ff ff       	call   800c6e <memmove>
	return r;
  80182b:	83 c4 10             	add    $0x10,%esp
}
  80182e:	89 d8                	mov    %ebx,%eax
  801830:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801833:	5b                   	pop    %ebx
  801834:	5e                   	pop    %esi
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	53                   	push   %ebx
  80183b:	83 ec 20             	sub    $0x20,%esp
  80183e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801841:	53                   	push   %ebx
  801842:	e8 5c f2 ff ff       	call   800aa3 <strlen>
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80184f:	7f 67                	jg     8018b8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801851:	83 ec 0c             	sub    $0xc,%esp
  801854:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801857:	50                   	push   %eax
  801858:	e8 9a f8 ff ff       	call   8010f7 <fd_alloc>
  80185d:	83 c4 10             	add    $0x10,%esp
		return r;
  801860:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801862:	85 c0                	test   %eax,%eax
  801864:	78 57                	js     8018bd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	53                   	push   %ebx
  80186a:	68 00 70 80 00       	push   $0x807000
  80186f:	e8 68 f2 ff ff       	call   800adc <strcpy>
	fsipcbuf.open.req_omode = mode;
  801874:	8b 45 0c             	mov    0xc(%ebp),%eax
  801877:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187f:	b8 01 00 00 00       	mov    $0x1,%eax
  801884:	e8 f6 fd ff ff       	call   80167f <fsipc>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	79 14                	jns    8018a6 <open+0x6f>
		fd_close(fd, 0);
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	6a 00                	push   $0x0
  801897:	ff 75 f4             	pushl  -0xc(%ebp)
  80189a:	e8 50 f9 ff ff       	call   8011ef <fd_close>
		return r;
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	89 da                	mov    %ebx,%edx
  8018a4:	eb 17                	jmp    8018bd <open+0x86>
	}

	return fd2num(fd);
  8018a6:	83 ec 0c             	sub    $0xc,%esp
  8018a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ac:	e8 1f f8 ff ff       	call   8010d0 <fd2num>
  8018b1:	89 c2                	mov    %eax,%edx
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	eb 05                	jmp    8018bd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018bd:	89 d0                	mov    %edx,%eax
  8018bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d4:	e8 a6 fd ff ff       	call   80167f <fsipc>
}
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	57                   	push   %edi
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018e7:	6a 00                	push   $0x0
  8018e9:	ff 75 08             	pushl  0x8(%ebp)
  8018ec:	e8 46 ff ff ff       	call   801837 <open>
  8018f1:	89 c7                	mov    %eax,%edi
  8018f3:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	0f 88 96 04 00 00    	js     801d9a <spawn+0x4bf>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801904:	83 ec 04             	sub    $0x4,%esp
  801907:	68 00 02 00 00       	push   $0x200
  80190c:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801912:	50                   	push   %eax
  801913:	57                   	push   %edi
  801914:	e8 24 fb ff ff       	call   80143d <readn>
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	3d 00 02 00 00       	cmp    $0x200,%eax
  801921:	75 0c                	jne    80192f <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801923:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80192a:	45 4c 46 
  80192d:	74 33                	je     801962 <spawn+0x87>
		close(fd);
  80192f:	83 ec 0c             	sub    $0xc,%esp
  801932:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801938:	e8 33 f9 ff ff       	call   801270 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80193d:	83 c4 0c             	add    $0xc,%esp
  801940:	68 7f 45 4c 46       	push   $0x464c457f
  801945:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80194b:	68 6b 2b 80 00       	push   $0x802b6b
  801950:	e8 83 eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80195d:	e9 98 04 00 00       	jmp    801dfa <spawn+0x51f>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801962:	b8 07 00 00 00       	mov    $0x7,%eax
  801967:	cd 30                	int    $0x30
  801969:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80196f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801975:	85 c0                	test   %eax,%eax
  801977:	0f 88 25 04 00 00    	js     801da2 <spawn+0x4c7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80197d:	89 c6                	mov    %eax,%esi
  80197f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801985:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801988:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80198e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801994:	b9 11 00 00 00       	mov    $0x11,%ecx
  801999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80199b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019a1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019a7:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019ac:	be 00 00 00 00       	mov    $0x0,%esi
  8019b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019b4:	eb 13                	jmp    8019c9 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019b6:	83 ec 0c             	sub    $0xc,%esp
  8019b9:	50                   	push   %eax
  8019ba:	e8 e4 f0 ff ff       	call   800aa3 <strlen>
  8019bf:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019c3:	83 c3 01             	add    $0x1,%ebx
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019d0:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	75 df                	jne    8019b6 <spawn+0xdb>
  8019d7:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019dd:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019e3:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019e8:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019ea:	89 fa                	mov    %edi,%edx
  8019ec:	83 e2 fc             	and    $0xfffffffc,%edx
  8019ef:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019f6:	29 c2                	sub    %eax,%edx
  8019f8:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019fe:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a01:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a06:	0f 86 a6 03 00 00    	jbe    801db2 <spawn+0x4d7>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a0c:	83 ec 04             	sub    $0x4,%esp
  801a0f:	6a 07                	push   $0x7
  801a11:	68 00 00 40 00       	push   $0x400000
  801a16:	6a 00                	push   $0x0
  801a18:	e8 c2 f4 ff ff       	call   800edf <sys_page_alloc>
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	85 c0                	test   %eax,%eax
  801a22:	0f 88 91 03 00 00    	js     801db9 <spawn+0x4de>
  801a28:	be 00 00 00 00       	mov    $0x0,%esi
  801a2d:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a36:	eb 30                	jmp    801a68 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a38:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a3e:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801a44:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801a47:	83 ec 08             	sub    $0x8,%esp
  801a4a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a4d:	57                   	push   %edi
  801a4e:	e8 89 f0 ff ff       	call   800adc <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a53:	83 c4 04             	add    $0x4,%esp
  801a56:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a59:	e8 45 f0 ff ff       	call   800aa3 <strlen>
  801a5e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a62:	83 c6 01             	add    $0x1,%esi
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a6e:	7f c8                	jg     801a38 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a70:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a76:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a7c:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a83:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a89:	74 19                	je     801aa4 <spawn+0x1c9>
  801a8b:	68 e0 2b 80 00       	push   $0x802be0
  801a90:	68 3f 2b 80 00       	push   $0x802b3f
  801a95:	68 f1 00 00 00       	push   $0xf1
  801a9a:	68 85 2b 80 00       	push   $0x802b85
  801a9f:	e8 5b e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801aa4:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801aaa:	89 f8                	mov    %edi,%eax
  801aac:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ab1:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801ab4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801aba:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801abd:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801ac3:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	6a 07                	push   $0x7
  801ace:	68 00 d0 bf ee       	push   $0xeebfd000
  801ad3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ad9:	68 00 00 40 00       	push   $0x400000
  801ade:	6a 00                	push   $0x0
  801ae0:	e8 3d f4 ff ff       	call   800f22 <sys_page_map>
  801ae5:	89 c3                	mov    %eax,%ebx
  801ae7:	83 c4 20             	add    $0x20,%esp
  801aea:	85 c0                	test   %eax,%eax
  801aec:	0f 88 f6 02 00 00    	js     801de8 <spawn+0x50d>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801af2:	83 ec 08             	sub    $0x8,%esp
  801af5:	68 00 00 40 00       	push   $0x400000
  801afa:	6a 00                	push   $0x0
  801afc:	e8 63 f4 ff ff       	call   800f64 <sys_page_unmap>
  801b01:	89 c3                	mov    %eax,%ebx
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	85 c0                	test   %eax,%eax
  801b08:	0f 88 da 02 00 00    	js     801de8 <spawn+0x50d>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b0e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b14:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b1b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b21:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b28:	00 00 00 
  801b2b:	e9 88 01 00 00       	jmp    801cb8 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801b30:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b36:	83 38 01             	cmpl   $0x1,(%eax)
  801b39:	0f 85 6b 01 00 00    	jne    801caa <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b3f:	89 c2                	mov    %eax,%edx
  801b41:	8b 40 18             	mov    0x18(%eax),%eax
  801b44:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b4a:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b4d:	83 f8 01             	cmp    $0x1,%eax
  801b50:	19 c0                	sbb    %eax,%eax
  801b52:	83 e0 fe             	and    $0xfffffffe,%eax
  801b55:	83 c0 07             	add    $0x7,%eax
  801b58:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b5e:	89 d0                	mov    %edx,%eax
  801b60:	8b 7a 04             	mov    0x4(%edx),%edi
  801b63:	89 fa                	mov    %edi,%edx
  801b65:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b6b:	8b 78 10             	mov    0x10(%eax),%edi
  801b6e:	8b 48 14             	mov    0x14(%eax),%ecx
  801b71:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801b77:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b7a:	89 f0                	mov    %esi,%eax
  801b7c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b81:	74 14                	je     801b97 <spawn+0x2bc>
		va -= i;
  801b83:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b85:	01 c1                	add    %eax,%ecx
  801b87:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		filesz += i;
  801b8d:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b8f:	29 c2                	sub    %eax,%edx
  801b91:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b97:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b9c:	e9 f7 00 00 00       	jmp    801c98 <spawn+0x3bd>
		if (i >= filesz) {
  801ba1:	39 df                	cmp    %ebx,%edi
  801ba3:	77 27                	ja     801bcc <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ba5:	83 ec 04             	sub    $0x4,%esp
  801ba8:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bae:	56                   	push   %esi
  801baf:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bb5:	e8 25 f3 ff ff       	call   800edf <sys_page_alloc>
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 89 c7 00 00 00    	jns    801c8c <spawn+0x3b1>
  801bc5:	89 c3                	mov    %eax,%ebx
  801bc7:	e9 fb 01 00 00       	jmp    801dc7 <spawn+0x4ec>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bcc:	83 ec 04             	sub    $0x4,%esp
  801bcf:	6a 07                	push   $0x7
  801bd1:	68 00 00 40 00       	push   $0x400000
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 02 f3 ff ff       	call   800edf <sys_page_alloc>
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	85 c0                	test   %eax,%eax
  801be2:	0f 88 d5 01 00 00    	js     801dbd <spawn+0x4e2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801be8:	83 ec 08             	sub    $0x8,%esp
  801beb:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bf1:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bf7:	50                   	push   %eax
  801bf8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bfe:	e8 0f f9 ff ff       	call   801512 <seek>
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	85 c0                	test   %eax,%eax
  801c08:	0f 88 b3 01 00 00    	js     801dc1 <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c0e:	83 ec 04             	sub    $0x4,%esp
  801c11:	89 f8                	mov    %edi,%eax
  801c13:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c19:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c1e:	ba 00 10 00 00       	mov    $0x1000,%edx
  801c23:	0f 47 c2             	cmova  %edx,%eax
  801c26:	50                   	push   %eax
  801c27:	68 00 00 40 00       	push   $0x400000
  801c2c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c32:	e8 06 f8 ff ff       	call   80143d <readn>
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	0f 88 83 01 00 00    	js     801dc5 <spawn+0x4ea>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c42:	83 ec 0c             	sub    $0xc,%esp
  801c45:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c4b:	56                   	push   %esi
  801c4c:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c52:	68 00 00 40 00       	push   $0x400000
  801c57:	6a 00                	push   $0x0
  801c59:	e8 c4 f2 ff ff       	call   800f22 <sys_page_map>
  801c5e:	83 c4 20             	add    $0x20,%esp
  801c61:	85 c0                	test   %eax,%eax
  801c63:	79 15                	jns    801c7a <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c65:	50                   	push   %eax
  801c66:	68 91 2b 80 00       	push   $0x802b91
  801c6b:	68 24 01 00 00       	push   $0x124
  801c70:	68 85 2b 80 00       	push   $0x802b85
  801c75:	e8 85 e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c7a:	83 ec 08             	sub    $0x8,%esp
  801c7d:	68 00 00 40 00       	push   $0x400000
  801c82:	6a 00                	push   $0x0
  801c84:	e8 db f2 ff ff       	call   800f64 <sys_page_unmap>
  801c89:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c8c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c92:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c98:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c9e:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801ca4:	0f 87 f7 fe ff ff    	ja     801ba1 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801caa:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801cb1:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801cb8:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cbf:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801cc5:	0f 8c 65 fe ff ff    	jl     801b30 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cd4:	e8 97 f5 ff ff       	call   801270 <close>
// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();
  801cd9:	e8 c3 f1 ff ff       	call   800ea1 <sys_getenvid>
  801cde:	89 c6                	mov    %eax,%esi
  801ce0:	83 c4 10             	add    $0x10,%esp

	for (int i = 0; i < UTOP; i += PGSIZE) {
  801ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce8:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
		if ((uvpd[PDX(i)] & PTE_P) &&
  801cee:	89 d8                	mov    %ebx,%eax
  801cf0:	c1 e8 16             	shr    $0x16,%eax
  801cf3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cfa:	a8 01                	test   $0x1,%al
  801cfc:	74 31                	je     801d2f <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_P) &&
  801cfe:	89 d8                	mov    %ebx,%eax
  801d00:	c1 e8 0c             	shr    $0xc,%eax
  801d03:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
		if ((uvpd[PDX(i)] & PTE_P) &&
  801d0a:	f6 c2 01             	test   $0x1,%dl
  801d0d:	74 20                	je     801d2f <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_P) &&
			(uvpt[PGNUM(i)] & PTE_SHARE))
  801d0f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
		if ((uvpd[PDX(i)] & PTE_P) &&
			(uvpt[PGNUM(i)] & PTE_P) &&
  801d16:	f6 c4 04             	test   $0x4,%ah
  801d19:	74 14                	je     801d2f <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_SHARE))
			sys_page_map(curenvid, (void *)i,
  801d1b:	83 ec 0c             	sub    $0xc,%esp
  801d1e:	68 07 0e 00 00       	push   $0xe07
  801d23:	53                   	push   %ebx
  801d24:	57                   	push   %edi
  801d25:	53                   	push   %ebx
  801d26:	56                   	push   %esi
  801d27:	e8 f6 f1 ff ff       	call   800f22 <sys_page_map>
  801d2c:	83 c4 20             	add    $0x20,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
  801d2f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d35:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801d3b:	75 b1                	jne    801cee <spawn+0x413>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d3d:	83 ec 08             	sub    $0x8,%esp
  801d40:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d46:	50                   	push   %eax
  801d47:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d4d:	e8 96 f2 ff ff       	call   800fe8 <sys_env_set_trapframe>
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	85 c0                	test   %eax,%eax
  801d57:	79 15                	jns    801d6e <spawn+0x493>
		panic("sys_env_set_trapframe: %e", r);
  801d59:	50                   	push   %eax
  801d5a:	68 ae 2b 80 00       	push   $0x802bae
  801d5f:	68 85 00 00 00       	push   $0x85
  801d64:	68 85 2b 80 00       	push   $0x802b85
  801d69:	e8 91 e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d6e:	83 ec 08             	sub    $0x8,%esp
  801d71:	6a 02                	push   $0x2
  801d73:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d79:	e8 28 f2 ff ff       	call   800fa6 <sys_env_set_status>
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	85 c0                	test   %eax,%eax
  801d83:	79 25                	jns    801daa <spawn+0x4cf>
		panic("sys_env_set_status: %e", r);
  801d85:	50                   	push   %eax
  801d86:	68 c8 2b 80 00       	push   $0x802bc8
  801d8b:	68 88 00 00 00       	push   $0x88
  801d90:	68 85 2b 80 00       	push   $0x802b85
  801d95:	e8 65 e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d9a:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801da0:	eb 58                	jmp    801dfa <spawn+0x51f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801da2:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801da8:	eb 50                	jmp    801dfa <spawn+0x51f>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801daa:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801db0:	eb 48                	jmp    801dfa <spawn+0x51f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801db2:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801db7:	eb 41                	jmp    801dfa <spawn+0x51f>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	eb 3d                	jmp    801dfa <spawn+0x51f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dbd:	89 c3                	mov    %eax,%ebx
  801dbf:	eb 06                	jmp    801dc7 <spawn+0x4ec>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	eb 02                	jmp    801dc7 <spawn+0x4ec>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801dc5:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801dc7:	83 ec 0c             	sub    $0xc,%esp
  801dca:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dd0:	e8 8b f0 ff ff       	call   800e60 <sys_env_destroy>
	close(fd);
  801dd5:	83 c4 04             	add    $0x4,%esp
  801dd8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dde:	e8 8d f4 ff ff       	call   801270 <close>
	return r;
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	eb 12                	jmp    801dfa <spawn+0x51f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	68 00 00 40 00       	push   $0x400000
  801df0:	6a 00                	push   $0x0
  801df2:	e8 6d f1 ff ff       	call   800f64 <sys_page_unmap>
  801df7:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801dfa:	89 d8                	mov    %ebx,%eax
  801dfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dff:	5b                   	pop    %ebx
  801e00:	5e                   	pop    %esi
  801e01:	5f                   	pop    %edi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	56                   	push   %esi
  801e08:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e09:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e0c:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e11:	eb 03                	jmp    801e16 <spawnl+0x12>
		argc++;
  801e13:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e16:	83 c2 04             	add    $0x4,%edx
  801e19:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e1d:	75 f4                	jne    801e13 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e1f:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e26:	83 e2 f0             	and    $0xfffffff0,%edx
  801e29:	29 d4                	sub    %edx,%esp
  801e2b:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e2f:	c1 ea 02             	shr    $0x2,%edx
  801e32:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e39:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e3e:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e45:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e4c:	00 
  801e4d:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e54:	eb 0a                	jmp    801e60 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e56:	83 c0 01             	add    $0x1,%eax
  801e59:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e5d:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e60:	39 d0                	cmp    %edx,%eax
  801e62:	75 f2                	jne    801e56 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e64:	83 ec 08             	sub    $0x8,%esp
  801e67:	56                   	push   %esi
  801e68:	ff 75 08             	pushl  0x8(%ebp)
  801e6b:	e8 6b fa ff ff       	call   8018db <spawn>
}
  801e70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5d                   	pop    %ebp
  801e76:	c3                   	ret    

00801e77 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	56                   	push   %esi
  801e7b:	53                   	push   %ebx
  801e7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e7f:	83 ec 0c             	sub    $0xc,%esp
  801e82:	ff 75 08             	pushl  0x8(%ebp)
  801e85:	e8 56 f2 ff ff       	call   8010e0 <fd2data>
  801e8a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e8c:	83 c4 08             	add    $0x8,%esp
  801e8f:	68 08 2c 80 00       	push   $0x802c08
  801e94:	53                   	push   %ebx
  801e95:	e8 42 ec ff ff       	call   800adc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e9a:	8b 46 04             	mov    0x4(%esi),%eax
  801e9d:	2b 06                	sub    (%esi),%eax
  801e9f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ea5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eac:	00 00 00 
	stat->st_dev = &devpipe;
  801eaf:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801eb6:	47 80 00 
	return 0;
}
  801eb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    

00801ec5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	53                   	push   %ebx
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ecf:	53                   	push   %ebx
  801ed0:	6a 00                	push   $0x0
  801ed2:	e8 8d f0 ff ff       	call   800f64 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ed7:	89 1c 24             	mov    %ebx,(%esp)
  801eda:	e8 01 f2 ff ff       	call   8010e0 <fd2data>
  801edf:	83 c4 08             	add    $0x8,%esp
  801ee2:	50                   	push   %eax
  801ee3:	6a 00                	push   $0x0
  801ee5:	e8 7a f0 ff ff       	call   800f64 <sys_page_unmap>
}
  801eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	57                   	push   %edi
  801ef3:	56                   	push   %esi
  801ef4:	53                   	push   %ebx
  801ef5:	83 ec 1c             	sub    $0x1c,%esp
  801ef8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801efb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801efd:	a1 90 67 80 00       	mov    0x806790,%eax
  801f02:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f05:	83 ec 0c             	sub    $0xc,%esp
  801f08:	ff 75 e0             	pushl  -0x20(%ebp)
  801f0b:	e8 11 04 00 00       	call   802321 <pageref>
  801f10:	89 c3                	mov    %eax,%ebx
  801f12:	89 3c 24             	mov    %edi,(%esp)
  801f15:	e8 07 04 00 00       	call   802321 <pageref>
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	39 c3                	cmp    %eax,%ebx
  801f1f:	0f 94 c1             	sete   %cl
  801f22:	0f b6 c9             	movzbl %cl,%ecx
  801f25:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f28:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801f2e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f31:	39 ce                	cmp    %ecx,%esi
  801f33:	74 1b                	je     801f50 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f35:	39 c3                	cmp    %eax,%ebx
  801f37:	75 c4                	jne    801efd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f39:	8b 42 58             	mov    0x58(%edx),%eax
  801f3c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f3f:	50                   	push   %eax
  801f40:	56                   	push   %esi
  801f41:	68 0f 2c 80 00       	push   $0x802c0f
  801f46:	e8 8d e5 ff ff       	call   8004d8 <cprintf>
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	eb ad                	jmp    801efd <_pipeisclosed+0xe>
	}
}
  801f50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f56:	5b                   	pop    %ebx
  801f57:	5e                   	pop    %esi
  801f58:	5f                   	pop    %edi
  801f59:	5d                   	pop    %ebp
  801f5a:	c3                   	ret    

00801f5b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f5b:	55                   	push   %ebp
  801f5c:	89 e5                	mov    %esp,%ebp
  801f5e:	57                   	push   %edi
  801f5f:	56                   	push   %esi
  801f60:	53                   	push   %ebx
  801f61:	83 ec 28             	sub    $0x28,%esp
  801f64:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f67:	56                   	push   %esi
  801f68:	e8 73 f1 ff ff       	call   8010e0 <fd2data>
  801f6d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	bf 00 00 00 00       	mov    $0x0,%edi
  801f77:	eb 4b                	jmp    801fc4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f79:	89 da                	mov    %ebx,%edx
  801f7b:	89 f0                	mov    %esi,%eax
  801f7d:	e8 6d ff ff ff       	call   801eef <_pipeisclosed>
  801f82:	85 c0                	test   %eax,%eax
  801f84:	75 48                	jne    801fce <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f86:	e8 35 ef ff ff       	call   800ec0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f8b:	8b 43 04             	mov    0x4(%ebx),%eax
  801f8e:	8b 0b                	mov    (%ebx),%ecx
  801f90:	8d 51 20             	lea    0x20(%ecx),%edx
  801f93:	39 d0                	cmp    %edx,%eax
  801f95:	73 e2                	jae    801f79 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f9a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f9e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fa1:	89 c2                	mov    %eax,%edx
  801fa3:	c1 fa 1f             	sar    $0x1f,%edx
  801fa6:	89 d1                	mov    %edx,%ecx
  801fa8:	c1 e9 1b             	shr    $0x1b,%ecx
  801fab:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fae:	83 e2 1f             	and    $0x1f,%edx
  801fb1:	29 ca                	sub    %ecx,%edx
  801fb3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fb7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fbb:	83 c0 01             	add    $0x1,%eax
  801fbe:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fc1:	83 c7 01             	add    $0x1,%edi
  801fc4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fc7:	75 c2                	jne    801f8b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fc9:	8b 45 10             	mov    0x10(%ebp),%eax
  801fcc:	eb 05                	jmp    801fd3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fce:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd6:	5b                   	pop    %ebx
  801fd7:	5e                   	pop    %esi
  801fd8:	5f                   	pop    %edi
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	57                   	push   %edi
  801fdf:	56                   	push   %esi
  801fe0:	53                   	push   %ebx
  801fe1:	83 ec 18             	sub    $0x18,%esp
  801fe4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fe7:	57                   	push   %edi
  801fe8:	e8 f3 f0 ff ff       	call   8010e0 <fd2data>
  801fed:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ff7:	eb 3d                	jmp    802036 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ff9:	85 db                	test   %ebx,%ebx
  801ffb:	74 04                	je     802001 <devpipe_read+0x26>
				return i;
  801ffd:	89 d8                	mov    %ebx,%eax
  801fff:	eb 44                	jmp    802045 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802001:	89 f2                	mov    %esi,%edx
  802003:	89 f8                	mov    %edi,%eax
  802005:	e8 e5 fe ff ff       	call   801eef <_pipeisclosed>
  80200a:	85 c0                	test   %eax,%eax
  80200c:	75 32                	jne    802040 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80200e:	e8 ad ee ff ff       	call   800ec0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802013:	8b 06                	mov    (%esi),%eax
  802015:	3b 46 04             	cmp    0x4(%esi),%eax
  802018:	74 df                	je     801ff9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80201a:	99                   	cltd   
  80201b:	c1 ea 1b             	shr    $0x1b,%edx
  80201e:	01 d0                	add    %edx,%eax
  802020:	83 e0 1f             	and    $0x1f,%eax
  802023:	29 d0                	sub    %edx,%eax
  802025:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80202a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80202d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802030:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802033:	83 c3 01             	add    $0x1,%ebx
  802036:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802039:	75 d8                	jne    802013 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80203b:	8b 45 10             	mov    0x10(%ebp),%eax
  80203e:	eb 05                	jmp    802045 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802040:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802045:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802048:	5b                   	pop    %ebx
  802049:	5e                   	pop    %esi
  80204a:	5f                   	pop    %edi
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    

0080204d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	56                   	push   %esi
  802051:	53                   	push   %ebx
  802052:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802058:	50                   	push   %eax
  802059:	e8 99 f0 ff ff       	call   8010f7 <fd_alloc>
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	89 c2                	mov    %eax,%edx
  802063:	85 c0                	test   %eax,%eax
  802065:	0f 88 2c 01 00 00    	js     802197 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206b:	83 ec 04             	sub    $0x4,%esp
  80206e:	68 07 04 00 00       	push   $0x407
  802073:	ff 75 f4             	pushl  -0xc(%ebp)
  802076:	6a 00                	push   $0x0
  802078:	e8 62 ee ff ff       	call   800edf <sys_page_alloc>
  80207d:	83 c4 10             	add    $0x10,%esp
  802080:	89 c2                	mov    %eax,%edx
  802082:	85 c0                	test   %eax,%eax
  802084:	0f 88 0d 01 00 00    	js     802197 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80208a:	83 ec 0c             	sub    $0xc,%esp
  80208d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802090:	50                   	push   %eax
  802091:	e8 61 f0 ff ff       	call   8010f7 <fd_alloc>
  802096:	89 c3                	mov    %eax,%ebx
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	85 c0                	test   %eax,%eax
  80209d:	0f 88 e2 00 00 00    	js     802185 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a3:	83 ec 04             	sub    $0x4,%esp
  8020a6:	68 07 04 00 00       	push   $0x407
  8020ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ae:	6a 00                	push   $0x0
  8020b0:	e8 2a ee ff ff       	call   800edf <sys_page_alloc>
  8020b5:	89 c3                	mov    %eax,%ebx
  8020b7:	83 c4 10             	add    $0x10,%esp
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	0f 88 c3 00 00 00    	js     802185 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020c2:	83 ec 0c             	sub    $0xc,%esp
  8020c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c8:	e8 13 f0 ff ff       	call   8010e0 <fd2data>
  8020cd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020cf:	83 c4 0c             	add    $0xc,%esp
  8020d2:	68 07 04 00 00       	push   $0x407
  8020d7:	50                   	push   %eax
  8020d8:	6a 00                	push   $0x0
  8020da:	e8 00 ee ff ff       	call   800edf <sys_page_alloc>
  8020df:	89 c3                	mov    %eax,%ebx
  8020e1:	83 c4 10             	add    $0x10,%esp
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	0f 88 89 00 00 00    	js     802175 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ec:	83 ec 0c             	sub    $0xc,%esp
  8020ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f2:	e8 e9 ef ff ff       	call   8010e0 <fd2data>
  8020f7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020fe:	50                   	push   %eax
  8020ff:	6a 00                	push   $0x0
  802101:	56                   	push   %esi
  802102:	6a 00                	push   $0x0
  802104:	e8 19 ee ff ff       	call   800f22 <sys_page_map>
  802109:	89 c3                	mov    %eax,%ebx
  80210b:	83 c4 20             	add    $0x20,%esp
  80210e:	85 c0                	test   %eax,%eax
  802110:	78 55                	js     802167 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802112:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802118:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80211d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802120:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802127:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80212d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802130:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802132:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802135:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80213c:	83 ec 0c             	sub    $0xc,%esp
  80213f:	ff 75 f4             	pushl  -0xc(%ebp)
  802142:	e8 89 ef ff ff       	call   8010d0 <fd2num>
  802147:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80214a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80214c:	83 c4 04             	add    $0x4,%esp
  80214f:	ff 75 f0             	pushl  -0x10(%ebp)
  802152:	e8 79 ef ff ff       	call   8010d0 <fd2num>
  802157:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80215a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80215d:	83 c4 10             	add    $0x10,%esp
  802160:	ba 00 00 00 00       	mov    $0x0,%edx
  802165:	eb 30                	jmp    802197 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802167:	83 ec 08             	sub    $0x8,%esp
  80216a:	56                   	push   %esi
  80216b:	6a 00                	push   $0x0
  80216d:	e8 f2 ed ff ff       	call   800f64 <sys_page_unmap>
  802172:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802175:	83 ec 08             	sub    $0x8,%esp
  802178:	ff 75 f0             	pushl  -0x10(%ebp)
  80217b:	6a 00                	push   $0x0
  80217d:	e8 e2 ed ff ff       	call   800f64 <sys_page_unmap>
  802182:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802185:	83 ec 08             	sub    $0x8,%esp
  802188:	ff 75 f4             	pushl  -0xc(%ebp)
  80218b:	6a 00                	push   $0x0
  80218d:	e8 d2 ed ff ff       	call   800f64 <sys_page_unmap>
  802192:	83 c4 10             	add    $0x10,%esp
  802195:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802197:	89 d0                	mov    %edx,%eax
  802199:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80219c:	5b                   	pop    %ebx
  80219d:	5e                   	pop    %esi
  80219e:	5d                   	pop    %ebp
  80219f:	c3                   	ret    

008021a0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a9:	50                   	push   %eax
  8021aa:	ff 75 08             	pushl  0x8(%ebp)
  8021ad:	e8 94 ef ff ff       	call   801146 <fd_lookup>
  8021b2:	83 c4 10             	add    $0x10,%esp
  8021b5:	85 c0                	test   %eax,%eax
  8021b7:	78 18                	js     8021d1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021b9:	83 ec 0c             	sub    $0xc,%esp
  8021bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8021bf:	e8 1c ef ff ff       	call   8010e0 <fd2data>
	return _pipeisclosed(fd, p);
  8021c4:	89 c2                	mov    %eax,%edx
  8021c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c9:	e8 21 fd ff ff       	call   801eef <_pipeisclosed>
  8021ce:	83 c4 10             	add    $0x10,%esp
}
  8021d1:	c9                   	leave  
  8021d2:	c3                   	ret    

008021d3 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	56                   	push   %esi
  8021d7:	53                   	push   %ebx
  8021d8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8021db:	85 f6                	test   %esi,%esi
  8021dd:	75 16                	jne    8021f5 <wait+0x22>
  8021df:	68 27 2c 80 00       	push   $0x802c27
  8021e4:	68 3f 2b 80 00       	push   $0x802b3f
  8021e9:	6a 09                	push   $0x9
  8021eb:	68 32 2c 80 00       	push   $0x802c32
  8021f0:	e8 0a e2 ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  8021f5:	89 f3                	mov    %esi,%ebx
  8021f7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021fd:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802200:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802206:	eb 05                	jmp    80220d <wait+0x3a>
		sys_yield();
  802208:	e8 b3 ec ff ff       	call   800ec0 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80220d:	8b 43 48             	mov    0x48(%ebx),%eax
  802210:	39 c6                	cmp    %eax,%esi
  802212:	75 07                	jne    80221b <wait+0x48>
  802214:	8b 43 54             	mov    0x54(%ebx),%eax
  802217:	85 c0                	test   %eax,%eax
  802219:	75 ed                	jne    802208 <wait+0x35>
		sys_yield();
}
  80221b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80221e:	5b                   	pop    %ebx
  80221f:	5e                   	pop    %esi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    

00802222 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802222:	55                   	push   %ebp
  802223:	89 e5                	mov    %esp,%ebp
  802225:	56                   	push   %esi
  802226:	53                   	push   %ebx
  802227:	8b 75 08             	mov    0x8(%ebp),%esi
  80222a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  802230:	85 c0                	test   %eax,%eax
  802232:	74 0e                	je     802242 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  802234:	83 ec 0c             	sub    $0xc,%esp
  802237:	50                   	push   %eax
  802238:	e8 52 ee ff ff       	call   80108f <sys_ipc_recv>
  80223d:	83 c4 10             	add    $0x10,%esp
  802240:	eb 0d                	jmp    80224f <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  802242:	83 ec 0c             	sub    $0xc,%esp
  802245:	6a ff                	push   $0xffffffff
  802247:	e8 43 ee ff ff       	call   80108f <sys_ipc_recv>
  80224c:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  80224f:	85 c0                	test   %eax,%eax
  802251:	79 16                	jns    802269 <ipc_recv+0x47>

		if (from_env_store != NULL)
  802253:	85 f6                	test   %esi,%esi
  802255:	74 06                	je     80225d <ipc_recv+0x3b>
			*from_env_store = 0;
  802257:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  80225d:	85 db                	test   %ebx,%ebx
  80225f:	74 2c                	je     80228d <ipc_recv+0x6b>
			*perm_store = 0;
  802261:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802267:	eb 24                	jmp    80228d <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  802269:	85 f6                	test   %esi,%esi
  80226b:	74 0a                	je     802277 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  80226d:	a1 90 67 80 00       	mov    0x806790,%eax
  802272:	8b 40 74             	mov    0x74(%eax),%eax
  802275:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  802277:	85 db                	test   %ebx,%ebx
  802279:	74 0a                	je     802285 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  80227b:	a1 90 67 80 00       	mov    0x806790,%eax
  802280:	8b 40 78             	mov    0x78(%eax),%eax
  802283:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802285:	a1 90 67 80 00       	mov    0x806790,%eax
  80228a:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  80228d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802290:	5b                   	pop    %ebx
  802291:	5e                   	pop    %esi
  802292:	5d                   	pop    %ebp
  802293:	c3                   	ret    

00802294 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	57                   	push   %edi
  802298:	56                   	push   %esi
  802299:	53                   	push   %ebx
  80229a:	83 ec 0c             	sub    $0xc,%esp
  80229d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  8022a6:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  8022a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8022ad:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8022b0:	ff 75 14             	pushl  0x14(%ebp)
  8022b3:	53                   	push   %ebx
  8022b4:	56                   	push   %esi
  8022b5:	57                   	push   %edi
  8022b6:	e8 b1 ed ff ff       	call   80106c <sys_ipc_try_send>
		if (r >= 0)
  8022bb:	83 c4 10             	add    $0x10,%esp
  8022be:	85 c0                	test   %eax,%eax
  8022c0:	79 1e                	jns    8022e0 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  8022c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022c5:	74 12                	je     8022d9 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  8022c7:	50                   	push   %eax
  8022c8:	68 3d 2c 80 00       	push   $0x802c3d
  8022cd:	6a 49                	push   $0x49
  8022cf:	68 50 2c 80 00       	push   $0x802c50
  8022d4:	e8 26 e1 ff ff       	call   8003ff <_panic>
	
		sys_yield();
  8022d9:	e8 e2 eb ff ff       	call   800ec0 <sys_yield>
	}
  8022de:	eb d0                	jmp    8022b0 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8022e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    

008022e8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
  8022eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022ee:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022f3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022f6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022fc:	8b 52 50             	mov    0x50(%edx),%edx
  8022ff:	39 ca                	cmp    %ecx,%edx
  802301:	75 0d                	jne    802310 <ipc_find_env+0x28>
			return envs[i].env_id;
  802303:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802306:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80230b:	8b 40 48             	mov    0x48(%eax),%eax
  80230e:	eb 0f                	jmp    80231f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802310:	83 c0 01             	add    $0x1,%eax
  802313:	3d 00 04 00 00       	cmp    $0x400,%eax
  802318:	75 d9                	jne    8022f3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80231a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80231f:	5d                   	pop    %ebp
  802320:	c3                   	ret    

00802321 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802321:	55                   	push   %ebp
  802322:	89 e5                	mov    %esp,%ebp
  802324:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802327:	89 d0                	mov    %edx,%eax
  802329:	c1 e8 16             	shr    $0x16,%eax
  80232c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802333:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802338:	f6 c1 01             	test   $0x1,%cl
  80233b:	74 1d                	je     80235a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80233d:	c1 ea 0c             	shr    $0xc,%edx
  802340:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802347:	f6 c2 01             	test   $0x1,%dl
  80234a:	74 0e                	je     80235a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80234c:	c1 ea 0c             	shr    $0xc,%edx
  80234f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802356:	ef 
  802357:	0f b7 c0             	movzwl %ax,%eax
}
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	66 90                	xchg   %ax,%ax
  80235e:	66 90                	xchg   %ax,%ax

00802360 <__udivdi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	53                   	push   %ebx
  802364:	83 ec 1c             	sub    $0x1c,%esp
  802367:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80236b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80236f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802373:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802377:	85 f6                	test   %esi,%esi
  802379:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80237d:	89 ca                	mov    %ecx,%edx
  80237f:	89 f8                	mov    %edi,%eax
  802381:	75 3d                	jne    8023c0 <__udivdi3+0x60>
  802383:	39 cf                	cmp    %ecx,%edi
  802385:	0f 87 c5 00 00 00    	ja     802450 <__udivdi3+0xf0>
  80238b:	85 ff                	test   %edi,%edi
  80238d:	89 fd                	mov    %edi,%ebp
  80238f:	75 0b                	jne    80239c <__udivdi3+0x3c>
  802391:	b8 01 00 00 00       	mov    $0x1,%eax
  802396:	31 d2                	xor    %edx,%edx
  802398:	f7 f7                	div    %edi
  80239a:	89 c5                	mov    %eax,%ebp
  80239c:	89 c8                	mov    %ecx,%eax
  80239e:	31 d2                	xor    %edx,%edx
  8023a0:	f7 f5                	div    %ebp
  8023a2:	89 c1                	mov    %eax,%ecx
  8023a4:	89 d8                	mov    %ebx,%eax
  8023a6:	89 cf                	mov    %ecx,%edi
  8023a8:	f7 f5                	div    %ebp
  8023aa:	89 c3                	mov    %eax,%ebx
  8023ac:	89 d8                	mov    %ebx,%eax
  8023ae:	89 fa                	mov    %edi,%edx
  8023b0:	83 c4 1c             	add    $0x1c,%esp
  8023b3:	5b                   	pop    %ebx
  8023b4:	5e                   	pop    %esi
  8023b5:	5f                   	pop    %edi
  8023b6:	5d                   	pop    %ebp
  8023b7:	c3                   	ret    
  8023b8:	90                   	nop
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	39 ce                	cmp    %ecx,%esi
  8023c2:	77 74                	ja     802438 <__udivdi3+0xd8>
  8023c4:	0f bd fe             	bsr    %esi,%edi
  8023c7:	83 f7 1f             	xor    $0x1f,%edi
  8023ca:	0f 84 98 00 00 00    	je     802468 <__udivdi3+0x108>
  8023d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023d5:	89 f9                	mov    %edi,%ecx
  8023d7:	89 c5                	mov    %eax,%ebp
  8023d9:	29 fb                	sub    %edi,%ebx
  8023db:	d3 e6                	shl    %cl,%esi
  8023dd:	89 d9                	mov    %ebx,%ecx
  8023df:	d3 ed                	shr    %cl,%ebp
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	d3 e0                	shl    %cl,%eax
  8023e5:	09 ee                	or     %ebp,%esi
  8023e7:	89 d9                	mov    %ebx,%ecx
  8023e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ed:	89 d5                	mov    %edx,%ebp
  8023ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023f3:	d3 ed                	shr    %cl,%ebp
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e2                	shl    %cl,%edx
  8023f9:	89 d9                	mov    %ebx,%ecx
  8023fb:	d3 e8                	shr    %cl,%eax
  8023fd:	09 c2                	or     %eax,%edx
  8023ff:	89 d0                	mov    %edx,%eax
  802401:	89 ea                	mov    %ebp,%edx
  802403:	f7 f6                	div    %esi
  802405:	89 d5                	mov    %edx,%ebp
  802407:	89 c3                	mov    %eax,%ebx
  802409:	f7 64 24 0c          	mull   0xc(%esp)
  80240d:	39 d5                	cmp    %edx,%ebp
  80240f:	72 10                	jb     802421 <__udivdi3+0xc1>
  802411:	8b 74 24 08          	mov    0x8(%esp),%esi
  802415:	89 f9                	mov    %edi,%ecx
  802417:	d3 e6                	shl    %cl,%esi
  802419:	39 c6                	cmp    %eax,%esi
  80241b:	73 07                	jae    802424 <__udivdi3+0xc4>
  80241d:	39 d5                	cmp    %edx,%ebp
  80241f:	75 03                	jne    802424 <__udivdi3+0xc4>
  802421:	83 eb 01             	sub    $0x1,%ebx
  802424:	31 ff                	xor    %edi,%edi
  802426:	89 d8                	mov    %ebx,%eax
  802428:	89 fa                	mov    %edi,%edx
  80242a:	83 c4 1c             	add    $0x1c,%esp
  80242d:	5b                   	pop    %ebx
  80242e:	5e                   	pop    %esi
  80242f:	5f                   	pop    %edi
  802430:	5d                   	pop    %ebp
  802431:	c3                   	ret    
  802432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802438:	31 ff                	xor    %edi,%edi
  80243a:	31 db                	xor    %ebx,%ebx
  80243c:	89 d8                	mov    %ebx,%eax
  80243e:	89 fa                	mov    %edi,%edx
  802440:	83 c4 1c             	add    $0x1c,%esp
  802443:	5b                   	pop    %ebx
  802444:	5e                   	pop    %esi
  802445:	5f                   	pop    %edi
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    
  802448:	90                   	nop
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	89 d8                	mov    %ebx,%eax
  802452:	f7 f7                	div    %edi
  802454:	31 ff                	xor    %edi,%edi
  802456:	89 c3                	mov    %eax,%ebx
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	89 fa                	mov    %edi,%edx
  80245c:	83 c4 1c             	add    $0x1c,%esp
  80245f:	5b                   	pop    %ebx
  802460:	5e                   	pop    %esi
  802461:	5f                   	pop    %edi
  802462:	5d                   	pop    %ebp
  802463:	c3                   	ret    
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	39 ce                	cmp    %ecx,%esi
  80246a:	72 0c                	jb     802478 <__udivdi3+0x118>
  80246c:	31 db                	xor    %ebx,%ebx
  80246e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802472:	0f 87 34 ff ff ff    	ja     8023ac <__udivdi3+0x4c>
  802478:	bb 01 00 00 00       	mov    $0x1,%ebx
  80247d:	e9 2a ff ff ff       	jmp    8023ac <__udivdi3+0x4c>
  802482:	66 90                	xchg   %ax,%ax
  802484:	66 90                	xchg   %ax,%ax
  802486:	66 90                	xchg   %ax,%ax
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__umoddi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	53                   	push   %ebx
  802494:	83 ec 1c             	sub    $0x1c,%esp
  802497:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80249b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80249f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024a7:	85 d2                	test   %edx,%edx
  8024a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024b1:	89 f3                	mov    %esi,%ebx
  8024b3:	89 3c 24             	mov    %edi,(%esp)
  8024b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ba:	75 1c                	jne    8024d8 <__umoddi3+0x48>
  8024bc:	39 f7                	cmp    %esi,%edi
  8024be:	76 50                	jbe    802510 <__umoddi3+0x80>
  8024c0:	89 c8                	mov    %ecx,%eax
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	f7 f7                	div    %edi
  8024c6:	89 d0                	mov    %edx,%eax
  8024c8:	31 d2                	xor    %edx,%edx
  8024ca:	83 c4 1c             	add    $0x1c,%esp
  8024cd:	5b                   	pop    %ebx
  8024ce:	5e                   	pop    %esi
  8024cf:	5f                   	pop    %edi
  8024d0:	5d                   	pop    %ebp
  8024d1:	c3                   	ret    
  8024d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d8:	39 f2                	cmp    %esi,%edx
  8024da:	89 d0                	mov    %edx,%eax
  8024dc:	77 52                	ja     802530 <__umoddi3+0xa0>
  8024de:	0f bd ea             	bsr    %edx,%ebp
  8024e1:	83 f5 1f             	xor    $0x1f,%ebp
  8024e4:	75 5a                	jne    802540 <__umoddi3+0xb0>
  8024e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ea:	0f 82 e0 00 00 00    	jb     8025d0 <__umoddi3+0x140>
  8024f0:	39 0c 24             	cmp    %ecx,(%esp)
  8024f3:	0f 86 d7 00 00 00    	jbe    8025d0 <__umoddi3+0x140>
  8024f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802501:	83 c4 1c             	add    $0x1c,%esp
  802504:	5b                   	pop    %ebx
  802505:	5e                   	pop    %esi
  802506:	5f                   	pop    %edi
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	85 ff                	test   %edi,%edi
  802512:	89 fd                	mov    %edi,%ebp
  802514:	75 0b                	jne    802521 <__umoddi3+0x91>
  802516:	b8 01 00 00 00       	mov    $0x1,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	f7 f7                	div    %edi
  80251f:	89 c5                	mov    %eax,%ebp
  802521:	89 f0                	mov    %esi,%eax
  802523:	31 d2                	xor    %edx,%edx
  802525:	f7 f5                	div    %ebp
  802527:	89 c8                	mov    %ecx,%eax
  802529:	f7 f5                	div    %ebp
  80252b:	89 d0                	mov    %edx,%eax
  80252d:	eb 99                	jmp    8024c8 <__umoddi3+0x38>
  80252f:	90                   	nop
  802530:	89 c8                	mov    %ecx,%eax
  802532:	89 f2                	mov    %esi,%edx
  802534:	83 c4 1c             	add    $0x1c,%esp
  802537:	5b                   	pop    %ebx
  802538:	5e                   	pop    %esi
  802539:	5f                   	pop    %edi
  80253a:	5d                   	pop    %ebp
  80253b:	c3                   	ret    
  80253c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802540:	8b 34 24             	mov    (%esp),%esi
  802543:	bf 20 00 00 00       	mov    $0x20,%edi
  802548:	89 e9                	mov    %ebp,%ecx
  80254a:	29 ef                	sub    %ebp,%edi
  80254c:	d3 e0                	shl    %cl,%eax
  80254e:	89 f9                	mov    %edi,%ecx
  802550:	89 f2                	mov    %esi,%edx
  802552:	d3 ea                	shr    %cl,%edx
  802554:	89 e9                	mov    %ebp,%ecx
  802556:	09 c2                	or     %eax,%edx
  802558:	89 d8                	mov    %ebx,%eax
  80255a:	89 14 24             	mov    %edx,(%esp)
  80255d:	89 f2                	mov    %esi,%edx
  80255f:	d3 e2                	shl    %cl,%edx
  802561:	89 f9                	mov    %edi,%ecx
  802563:	89 54 24 04          	mov    %edx,0x4(%esp)
  802567:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80256b:	d3 e8                	shr    %cl,%eax
  80256d:	89 e9                	mov    %ebp,%ecx
  80256f:	89 c6                	mov    %eax,%esi
  802571:	d3 e3                	shl    %cl,%ebx
  802573:	89 f9                	mov    %edi,%ecx
  802575:	89 d0                	mov    %edx,%eax
  802577:	d3 e8                	shr    %cl,%eax
  802579:	89 e9                	mov    %ebp,%ecx
  80257b:	09 d8                	or     %ebx,%eax
  80257d:	89 d3                	mov    %edx,%ebx
  80257f:	89 f2                	mov    %esi,%edx
  802581:	f7 34 24             	divl   (%esp)
  802584:	89 d6                	mov    %edx,%esi
  802586:	d3 e3                	shl    %cl,%ebx
  802588:	f7 64 24 04          	mull   0x4(%esp)
  80258c:	39 d6                	cmp    %edx,%esi
  80258e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802592:	89 d1                	mov    %edx,%ecx
  802594:	89 c3                	mov    %eax,%ebx
  802596:	72 08                	jb     8025a0 <__umoddi3+0x110>
  802598:	75 11                	jne    8025ab <__umoddi3+0x11b>
  80259a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80259e:	73 0b                	jae    8025ab <__umoddi3+0x11b>
  8025a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025a4:	1b 14 24             	sbb    (%esp),%edx
  8025a7:	89 d1                	mov    %edx,%ecx
  8025a9:	89 c3                	mov    %eax,%ebx
  8025ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025af:	29 da                	sub    %ebx,%edx
  8025b1:	19 ce                	sbb    %ecx,%esi
  8025b3:	89 f9                	mov    %edi,%ecx
  8025b5:	89 f0                	mov    %esi,%eax
  8025b7:	d3 e0                	shl    %cl,%eax
  8025b9:	89 e9                	mov    %ebp,%ecx
  8025bb:	d3 ea                	shr    %cl,%edx
  8025bd:	89 e9                	mov    %ebp,%ecx
  8025bf:	d3 ee                	shr    %cl,%esi
  8025c1:	09 d0                	or     %edx,%eax
  8025c3:	89 f2                	mov    %esi,%edx
  8025c5:	83 c4 1c             	add    $0x1c,%esp
  8025c8:	5b                   	pop    %ebx
  8025c9:	5e                   	pop    %esi
  8025ca:	5f                   	pop    %edi
  8025cb:	5d                   	pop    %ebp
  8025cc:	c3                   	ret    
  8025cd:	8d 76 00             	lea    0x0(%esi),%esi
  8025d0:	29 f9                	sub    %edi,%ecx
  8025d2:	19 d6                	sbb    %edx,%esi
  8025d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025dc:	e9 18 ff ff ff       	jmp    8024f9 <__umoddi3+0x69>
