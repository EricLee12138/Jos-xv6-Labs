
obj/user/sh.debug：     文件格式 elf32-i386


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
  80002c:	e8 84 09 00 00       	call   8009b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 20 32 80 00       	push   $0x803220
  800060:	e8 89 0a 00 00       	call   800aee <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 2f 32 80 00       	push   $0x80322f
  800084:	e8 65 0a 00 00       	call   800aee <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 3d 32 80 00       	push   $0x80323d
  8000b0:	e8 38 12 00 00       	call   8012ed <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 42 32 80 00       	push   $0x803242
  8000dd:	e8 0c 0a 00 00       	call   800aee <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 53 32 80 00       	push   $0x803253
  8000fb:	e8 ed 11 00 00       	call   8012ed <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 47 32 80 00       	push   $0x803247
  80012b:	e8 be 09 00 00       	call   800aee <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 4f 32 80 00       	push   $0x80324f
  800151:	e8 97 11 00 00       	call   8012ed <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 5b 32 80 00       	push   $0x80325b
  800180:	e8 69 09 00 00       	call   800aee <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cc 00 00 00    	je     80030d <runcmd+0x104>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3b 02 00 00    	je     800489 <runcmd+0x280>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1f 02 00 00       	jmp    800477 <runcmd+0x26e>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 25 01 00 00    	je     80038b <runcmd+0x182>
  800266:	e9 0c 02 00 00       	jmp    800477 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 65 32 80 00       	push   $0x803265
  800278:	e8 71 08 00 00       	call   800aee <cprintf>
				exit();
  80027d:	e8 79 07 00 00       	call   8009fb <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 b8 33 80 00       	push   $0x8033b8
  8002ac:	e8 3d 08 00 00       	call   800aee <cprintf>
				exit();
  8002b1:	e8 45 07 00 00       	call   8009fb <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 27 20 00 00       	call   8022ed <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 79 32 80 00       	push   $0x803279
  8002db:	e8 0e 08 00 00       	call   800aee <cprintf>
				exit();
  8002e0:	e8 16 07 00 00       	call   8009fb <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
			}
			if (fd != 0) {
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 0);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 79 1a 00 00       	call   801d76 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 21 1a 00 00       	call   801d26 <close>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	e9 1d ff ff ff       	jmp    80022a <runcmd+0x21>

			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 86 fe ff ff       	call   80019e <gettoken>
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	83 f8 77             	cmp    $0x77,%eax
  80031e:	74 15                	je     800335 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	68 e0 33 80 00       	push   $0x8033e0
  800328:	e8 c1 07 00 00       	call   800aee <cprintf>
				exit();
  80032d:	e8 c9 06 00 00       	call   8009fb <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 a8 1f 00 00       	call   8022ed <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 8e 32 80 00       	push   $0x80328e
  80035a:	e8 8f 07 00 00       	call   800aee <cprintf>
				exit();
  80035f:	e8 97 06 00 00       	call   8009fb <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 fb 19 00 00       	call   801d76 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 a3 19 00 00       	call   801d26 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 79 28 00 00       	call   802c13 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 a4 32 80 00       	push   $0x8032a4
  8003aa:	e8 3f 07 00 00       	call   800aee <cprintf>
				exit();
  8003af:	e8 47 06 00 00       	call   8009fb <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 ad 32 80 00       	push   $0x8032ad
  8003d4:	e8 15 07 00 00       	call   800aee <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 9d 14 00 00       	call   80187e <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 ba 32 80 00       	push   $0x8032ba
  8003f0:	e8 f9 06 00 00       	call   800aee <cprintf>
				exit();
  8003f5:	e8 01 06 00 00       	call   8009fb <exit>
  8003fa:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	75 3c                	jne    80043d <runcmd+0x234>
				if (p[0] != 0) {
  800401:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[0], 0);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 00                	push   $0x0
  800410:	50                   	push   %eax
  800411:	e8 60 19 00 00       	call   801d76 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 02 19 00 00       	call   801d26 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 f1 18 00 00       	call   801d26 <close>
				goto again;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 e8 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043d:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800443:	83 f8 01             	cmp    $0x1,%eax
  800446:	74 1c                	je     800464 <runcmd+0x25b>
					dup(p[1], 1);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	6a 01                	push   $0x1
  80044d:	50                   	push   %eax
  80044e:	e8 23 19 00 00       	call   801d76 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 c5 18 00 00       	call   801d26 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 b4 18 00 00       	call   801d26 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 c3 32 80 00       	push   $0x8032c3
  80047d:	6a 78                	push   $0x78
  80047f:	68 df 32 80 00       	push   $0x8032df
  800484:	e8 8c 05 00 00       	call   800a15 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800489:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 22                	jne    8004b4 <runcmd+0x2ab>
		if (debug)
  800492:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800499:	0f 84 96 01 00 00    	je     800635 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 e9 32 80 00       	push   $0x8032e9
  8004a7:	e8 42 06 00 00       	call   800aee <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 81 01 00 00       	jmp    800635 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004ba:	74 23                	je     8004df <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004bc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	50                   	push   %eax
  8004c7:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 0c 0d 00 00       	call   8011e5 <strcpy>
		argv[0] = argv0buf;
  8004d9:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e6:	00 

	// Print the command.
	if (debug) {
  8004e7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ee:	74 49                	je     800539 <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 24 54 80 00       	mov    0x805424,%eax
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 f8 32 80 00       	push   $0x8032f8
  800501:	e8 e8 05 00 00       	call   800aee <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 80 33 80 00       	push   $0x803380
  800517:	e8 d2 05 00 00       	call   800aee <cprintf>
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800522:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e5                	jne    80050e <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	68 40 32 80 00       	push   $0x803240
  800531:	e8 b8 05 00 00       	call   800aee <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 59 1f 00 00       	call   8024a1 <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 06 33 80 00       	push   $0x803306
  800561:	e8 88 05 00 00       	call   800aee <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 e6 17 00 00       	call   801d51 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 14 33 80 00       	push   $0x803314
  800582:	e8 67 05 00 00       	call   800aee <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 06 28 00 00       	call   802d99 <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 29 33 80 00       	push   $0x803329
  8005b4:	e8 35 05 00 00       	call   800aee <cprintf>
  8005b9:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	74 51                	je     800611 <runcmd+0x408>
		if (debug)
  8005c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c7:	74 1a                	je     8005e3 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 3f 33 80 00       	push   $0x80333f
  8005db:	e8 0e 05 00 00       	call   800aee <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 ad 27 00 00       	call   802d99 <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 29 33 80 00       	push   $0x803329
  800609:	e8 e0 04 00 00       	call   800aee <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 e5 03 00 00       	call   8009fb <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 34 17 00 00       	call   801d51 <close_all>
	if (r >= 0) {
		if (debug)
  80061d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800624:	0f 84 60 ff ff ff    	je     80058a <runcmd+0x381>
  80062a:	e9 41 ff ff ff       	jmp    800570 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062f:	85 ff                	test   %edi,%edi
  800631:	75 b0                	jne    8005e3 <runcmd+0x3da>
  800633:	eb dc                	jmp    800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <usage>:
}


void
usage(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800643:	68 08 34 80 00       	push   $0x803408
  800648:	e8 a1 04 00 00       	call   800aee <cprintf>
	exit();
  80064d:	e8 a9 03 00 00       	call   8009fb <exit>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <umain>:

void
umain(int argc, char **argv)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 30             	sub    $0x30,%esp
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800663:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	57                   	push   %edi
  800668:	8d 45 08             	lea    0x8(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 c1 13 00 00       	call   801a32 <argstart>
	while ((r = argnext(&args)) >= 0)
  800671:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800674:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067b:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800680:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800683:	eb 2f                	jmp    8006b4 <umain+0x5d>
		switch (r) {
  800685:	83 f8 69             	cmp    $0x69,%eax
  800688:	74 25                	je     8006af <umain+0x58>
  80068a:	83 f8 78             	cmp    $0x78,%eax
  80068d:	74 07                	je     800696 <umain+0x3f>
  80068f:	83 f8 64             	cmp    $0x64,%eax
  800692:	75 14                	jne    8006a8 <umain+0x51>
  800694:	eb 09                	jmp    80069f <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800696:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069d:	eb 15                	jmp    8006b4 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069f:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a6:	eb 0c                	jmp    8006b4 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a8:	e8 90 ff ff ff       	call   80063d <usage>
  8006ad:	eb 05                	jmp    8006b4 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006af:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	e8 a5 13 00 00       	call   801a62 <argnext>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	79 c1                	jns    800685 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c8:	7e 05                	jle    8006cf <umain+0x78>
		usage();
  8006ca:	e8 6e ff ff ff       	call   80063d <usage>
	if (argc == 2) {
  8006cf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d3:	75 56                	jne    80072b <umain+0xd4>
		close(0);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 47 16 00 00       	call   801d26 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 01 1c 00 00       	call   8022ed <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 5c 33 80 00       	push   $0x80335c
  8006ff:	68 28 01 00 00       	push   $0x128
  800704:	68 df 32 80 00       	push   $0x8032df
  800709:	e8 07 03 00 00       	call   800a15 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 68 33 80 00       	push   $0x803368
  800717:	68 6f 33 80 00       	push   $0x80336f
  80071c:	68 29 01 00 00       	push   $0x129
  800721:	68 df 32 80 00       	push   $0x8032df
  800726:	e8 ea 02 00 00       	call   800a15 <_panic>
	}
	if (interactive == '?')
  80072b:	83 fe 3f             	cmp    $0x3f,%esi
  80072e:	75 0f                	jne    80073f <umain+0xe8>
		interactive = iscons(0);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	6a 00                	push   $0x0
  800735:	e8 f5 01 00 00       	call   80092f <iscons>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 f6                	test   %esi,%esi
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	bf 84 33 80 00       	mov    $0x803384,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 62 09 00 00       	call   8010b9 <readline>
  800757:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	75 1e                	jne    80077e <umain+0x127>
			if (debug)
  800760:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800767:	74 10                	je     800779 <umain+0x122>
				cprintf("EXITING\n");
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	68 87 33 80 00       	push   $0x803387
  800771:	e8 78 03 00 00       	call   800aee <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 7d 02 00 00       	call   8009fb <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 90 33 80 00       	push   $0x803390
  800790:	e8 59 03 00 00       	call   800aee <cprintf>
  800795:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 b1                	je     80074e <umain+0xf7>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 11                	je     8007b4 <umain+0x15d>
			printf("# %s\n", buf);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	68 9a 33 80 00       	push   $0x80339a
  8007ac:	e8 da 1c 00 00       	call   80248b <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 a0 33 80 00       	push   $0x8033a0
  8007c5:	e8 24 03 00 00       	call   800aee <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 ac 10 00 00       	call   80187e <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 ba 32 80 00       	push   $0x8032ba
  8007de:	68 40 01 00 00       	push   $0x140
  8007e3:	68 df 32 80 00       	push   $0x8032df
  8007e8:	e8 28 02 00 00       	call   800a15 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 ad 33 80 00       	push   $0x8033ad
  8007ff:	e8 ea 02 00 00       	call   800aee <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 e2 01 00 00       	call   8009fb <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 6f 25 00 00       	call   802d99 <wait>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	e9 1c ff ff ff       	jmp    80074e <umain+0xf7>

00800832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800842:	68 29 34 80 00       	push   $0x803429
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 96 09 00 00       	call   8011e5 <strcpy>
	return 0;
}
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086d:	eb 2d                	jmp    80089c <devcons_write+0x46>
		m = n - tot;
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	03 45 0c             	add    0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	57                   	push   %edi
  800888:	e8 ea 0a 00 00       	call   801377 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 95 0c 00 00       	call   80152c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800897:	01 de                	add    %ebx,%esi
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a1:	72 cc                	jb     80086f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ba:	74 2a                	je     8008e6 <devcons_read+0x3b>
  8008bc:	eb 05                	jmp    8008c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008be:	e8 06 0d 00 00       	call   8015c9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 82 0c 00 00       	call   80154a <sys_cgetc>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 f2                	je     8008be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 16                	js     8008e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d0:	83 f8 04             	cmp    $0x4,%eax
  8008d3:	74 0c                	je     8008e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	88 02                	mov    %al,(%edx)
	return 1;
  8008da:	b8 01 00 00 00       	mov    $0x1,%eax
  8008df:	eb 05                	jmp    8008e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f4:	6a 01                	push   $0x1
  8008f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 2d 0c 00 00       	call   80152c <sys_cputs>
}
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <getchar>:

int
getchar(void)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090a:	6a 01                	push   $0x1
  80090c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	6a 00                	push   $0x0
  800912:	e8 4b 15 00 00       	call   801e62 <read>
	if (r < 0)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0f                	js     80092d <getchar+0x29>
		return r;
	if (r < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	7e 06                	jle    800928 <getchar+0x24>
		return -E_EOF;
	return c;
  800922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800926:	eb 05                	jmp    80092d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 bb 12 00 00       	call   801bfc <fd_lookup>
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	85 c0                	test   %eax,%eax
  800946:	78 11                	js     800959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800951:	39 10                	cmp    %edx,(%eax)
  800953:	0f 94 c0             	sete   %al
  800956:	0f b6 c0             	movzbl %al,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <opencons>:

int
opencons(void)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	e8 43 12 00 00       	call   801bad <fd_alloc>
  80096a:	83 c4 10             	add    $0x10,%esp
		return r;
  80096d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 3e                	js     8009b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	68 07 04 00 00       	push   $0x407
  80097b:	ff 75 f4             	pushl  -0xc(%ebp)
  80097e:	6a 00                	push   $0x0
  800980:	e8 63 0c 00 00       	call   8015e8 <sys_page_alloc>
  800985:	83 c4 10             	add    $0x10,%esp
		return r;
  800988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098a:	85 c0                	test   %eax,%eax
  80098c:	78 23                	js     8009b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	50                   	push   %eax
  8009a7:	e8 da 11 00 00       	call   801b86 <fd2num>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009c0:	e8 e5 0b 00 00       	call   8015aa <sys_getenvid>
  8009c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d2:	a3 24 54 80 00       	mov    %eax,0x805424
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	7e 07                	jle    8009e2 <libmain+0x2d>
		binaryname = argv[0];
  8009db:	8b 06                	mov    (%esi),%eax
  8009dd:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	e8 6b fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009ec:	e8 0a 00 00 00       	call   8009fb <exit>
}
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a01:	e8 4b 13 00 00       	call   801d51 <close_all>
	sys_env_destroy(0);
  800a06:	83 ec 0c             	sub    $0xc,%esp
  800a09:	6a 00                	push   $0x0
  800a0b:	e8 59 0b 00 00       	call   801569 <sys_env_destroy>
}
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a1a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1d:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a23:	e8 82 0b 00 00       	call   8015aa <sys_getenvid>
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	ff 75 08             	pushl  0x8(%ebp)
  800a31:	56                   	push   %esi
  800a32:	50                   	push   %eax
  800a33:	68 40 34 80 00       	push   $0x803440
  800a38:	e8 b1 00 00 00       	call   800aee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3d:	83 c4 18             	add    $0x18,%esp
  800a40:	53                   	push   %ebx
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	e8 54 00 00 00       	call   800a9d <vcprintf>
	cprintf("\n");
  800a49:	c7 04 24 40 32 80 00 	movl   $0x803240,(%esp)
  800a50:	e8 99 00 00 00       	call   800aee <cprintf>
  800a55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a58:	cc                   	int3   
  800a59:	eb fd                	jmp    800a58 <_panic+0x43>

00800a5b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a65:	8b 13                	mov    (%ebx),%edx
  800a67:	8d 42 01             	lea    0x1(%edx),%eax
  800a6a:	89 03                	mov    %eax,(%ebx)
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a73:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a78:	75 1a                	jne    800a94 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a7a:	83 ec 08             	sub    $0x8,%esp
  800a7d:	68 ff 00 00 00       	push   $0xff
  800a82:	8d 43 08             	lea    0x8(%ebx),%eax
  800a85:	50                   	push   %eax
  800a86:	e8 a1 0a 00 00       	call   80152c <sys_cputs>
		b->idx = 0;
  800a8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a91:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a94:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aad:	00 00 00 
	b.cnt = 0;
  800ab0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	ff 75 08             	pushl  0x8(%ebp)
  800ac0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac6:	50                   	push   %eax
  800ac7:	68 5b 0a 80 00       	push   $0x800a5b
  800acc:	e8 1a 01 00 00       	call   800beb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ada:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ae0:	50                   	push   %eax
  800ae1:	e8 46 0a 00 00       	call   80152c <sys_cputs>

	return b.cnt;
}
  800ae6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af7:	50                   	push   %eax
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 9d ff ff ff       	call   800a9d <vcprintf>
	va_end(ap);

	return cnt;
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 1c             	sub    $0x1c,%esp
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b18:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b23:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b29:	39 d3                	cmp    %edx,%ebx
  800b2b:	72 05                	jb     800b32 <printnum+0x30>
  800b2d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b30:	77 45                	ja     800b77 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 18             	pushl  0x18(%ebp)
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b3e:	53                   	push   %ebx
  800b3f:	ff 75 10             	pushl  0x10(%ebp)
  800b42:	83 ec 08             	sub    $0x8,%esp
  800b45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b48:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4b:	ff 75 dc             	pushl  -0x24(%ebp)
  800b4e:	ff 75 d8             	pushl  -0x28(%ebp)
  800b51:	e8 3a 24 00 00       	call   802f90 <__udivdi3>
  800b56:	83 c4 18             	add    $0x18,%esp
  800b59:	52                   	push   %edx
  800b5a:	50                   	push   %eax
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	e8 9e ff ff ff       	call   800b02 <printnum>
  800b64:	83 c4 20             	add    $0x20,%esp
  800b67:	eb 18                	jmp    800b81 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	56                   	push   %esi
  800b6d:	ff 75 18             	pushl  0x18(%ebp)
  800b70:	ff d7                	call   *%edi
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 03                	jmp    800b7a <printnum+0x78>
  800b77:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b7a:	83 eb 01             	sub    $0x1,%ebx
  800b7d:	85 db                	test   %ebx,%ebx
  800b7f:	7f e8                	jg     800b69 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	56                   	push   %esi
  800b85:	83 ec 04             	sub    $0x4,%esp
  800b88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b91:	ff 75 d8             	pushl  -0x28(%ebp)
  800b94:	e8 27 25 00 00       	call   8030c0 <__umoddi3>
  800b99:	83 c4 14             	add    $0x14,%esp
  800b9c:	0f be 80 63 34 80 00 	movsbl 0x803463(%eax),%eax
  800ba3:	50                   	push   %eax
  800ba4:	ff d7                	call   *%edi
}
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bb7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bbb:	8b 10                	mov    (%eax),%edx
  800bbd:	3b 50 04             	cmp    0x4(%eax),%edx
  800bc0:	73 0a                	jae    800bcc <sprintputch+0x1b>
		*b->buf++ = ch;
  800bc2:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bc5:	89 08                	mov    %ecx,(%eax)
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	88 02                	mov    %al,(%edx)
}
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800bd4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800bd7:	50                   	push   %eax
  800bd8:	ff 75 10             	pushl  0x10(%ebp)
  800bdb:	ff 75 0c             	pushl  0xc(%ebp)
  800bde:	ff 75 08             	pushl  0x8(%ebp)
  800be1:	e8 05 00 00 00       	call   800beb <vprintfmt>
	va_end(ap);
}
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 2c             	sub    $0x2c,%esp
  800bf4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bfa:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bfd:	eb 12                	jmp    800c11 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bff:	85 c0                	test   %eax,%eax
  800c01:	0f 84 42 04 00 00    	je     801049 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800c07:	83 ec 08             	sub    $0x8,%esp
  800c0a:	53                   	push   %ebx
  800c0b:	50                   	push   %eax
  800c0c:	ff d6                	call   *%esi
  800c0e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c11:	83 c7 01             	add    $0x1,%edi
  800c14:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c18:	83 f8 25             	cmp    $0x25,%eax
  800c1b:	75 e2                	jne    800bff <vprintfmt+0x14>
  800c1d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c21:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c28:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c2f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3b:	eb 07                	jmp    800c44 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c40:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c44:	8d 47 01             	lea    0x1(%edi),%eax
  800c47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c4a:	0f b6 07             	movzbl (%edi),%eax
  800c4d:	0f b6 d0             	movzbl %al,%edx
  800c50:	83 e8 23             	sub    $0x23,%eax
  800c53:	3c 55                	cmp    $0x55,%al
  800c55:	0f 87 d3 03 00 00    	ja     80102e <vprintfmt+0x443>
  800c5b:	0f b6 c0             	movzbl %al,%eax
  800c5e:	ff 24 85 a0 35 80 00 	jmp    *0x8035a0(,%eax,4)
  800c65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c68:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800c6c:	eb d6                	jmp    800c44 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
  800c76:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c79:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800c7c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800c80:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800c83:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c86:	83 f9 09             	cmp    $0x9,%ecx
  800c89:	77 3f                	ja     800cca <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c8b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c8e:	eb e9                	jmp    800c79 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c90:	8b 45 14             	mov    0x14(%ebp),%eax
  800c93:	8b 00                	mov    (%eax),%eax
  800c95:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800c98:	8b 45 14             	mov    0x14(%ebp),%eax
  800c9b:	8d 40 04             	lea    0x4(%eax),%eax
  800c9e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800ca4:	eb 2a                	jmp    800cd0 <vprintfmt+0xe5>
  800ca6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	0f 49 d0             	cmovns %eax,%edx
  800cb3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb9:	eb 89                	jmp    800c44 <vprintfmt+0x59>
  800cbb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cbe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cc5:	e9 7a ff ff ff       	jmp    800c44 <vprintfmt+0x59>
  800cca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ccd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800cd0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cd4:	0f 89 6a ff ff ff    	jns    800c44 <vprintfmt+0x59>
				width = precision, precision = -1;
  800cda:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800cdd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ce0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800ce7:	e9 58 ff ff ff       	jmp    800c44 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800cec:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800cf2:	e9 4d ff ff ff       	jmp    800c44 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800cf7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cfa:	8d 78 04             	lea    0x4(%eax),%edi
  800cfd:	83 ec 08             	sub    $0x8,%esp
  800d00:	53                   	push   %ebx
  800d01:	ff 30                	pushl  (%eax)
  800d03:	ff d6                	call   *%esi
			break;
  800d05:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d08:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d0b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d0e:	e9 fe fe ff ff       	jmp    800c11 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d13:	8b 45 14             	mov    0x14(%ebp),%eax
  800d16:	8d 78 04             	lea    0x4(%eax),%edi
  800d19:	8b 00                	mov    (%eax),%eax
  800d1b:	99                   	cltd   
  800d1c:	31 d0                	xor    %edx,%eax
  800d1e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d20:	83 f8 0f             	cmp    $0xf,%eax
  800d23:	7f 0b                	jg     800d30 <vprintfmt+0x145>
  800d25:	8b 14 85 00 37 80 00 	mov    0x803700(,%eax,4),%edx
  800d2c:	85 d2                	test   %edx,%edx
  800d2e:	75 1b                	jne    800d4b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800d30:	50                   	push   %eax
  800d31:	68 7b 34 80 00       	push   $0x80347b
  800d36:	53                   	push   %ebx
  800d37:	56                   	push   %esi
  800d38:	e8 91 fe ff ff       	call   800bce <printfmt>
  800d3d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d40:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d46:	e9 c6 fe ff ff       	jmp    800c11 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d4b:	52                   	push   %edx
  800d4c:	68 81 33 80 00       	push   $0x803381
  800d51:	53                   	push   %ebx
  800d52:	56                   	push   %esi
  800d53:	e8 76 fe ff ff       	call   800bce <printfmt>
  800d58:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d5b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d61:	e9 ab fe ff ff       	jmp    800c11 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d66:	8b 45 14             	mov    0x14(%ebp),%eax
  800d69:	83 c0 04             	add    $0x4,%eax
  800d6c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800d6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d72:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800d74:	85 ff                	test   %edi,%edi
  800d76:	b8 74 34 80 00       	mov    $0x803474,%eax
  800d7b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800d7e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d82:	0f 8e 94 00 00 00    	jle    800e1c <vprintfmt+0x231>
  800d88:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800d8c:	0f 84 98 00 00 00    	je     800e2a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d92:	83 ec 08             	sub    $0x8,%esp
  800d95:	ff 75 d0             	pushl  -0x30(%ebp)
  800d98:	57                   	push   %edi
  800d99:	e8 26 04 00 00       	call   8011c4 <strnlen>
  800d9e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800da1:	29 c1                	sub    %eax,%ecx
  800da3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800da6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800da9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800dad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800db0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800db3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800db5:	eb 0f                	jmp    800dc6 <vprintfmt+0x1db>
					putch(padc, putdat);
  800db7:	83 ec 08             	sub    $0x8,%esp
  800dba:	53                   	push   %ebx
  800dbb:	ff 75 e0             	pushl  -0x20(%ebp)
  800dbe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800dc0:	83 ef 01             	sub    $0x1,%edi
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 ff                	test   %edi,%edi
  800dc8:	7f ed                	jg     800db7 <vprintfmt+0x1cc>
  800dca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dcd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800dd0:	85 c9                	test   %ecx,%ecx
  800dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd7:	0f 49 c1             	cmovns %ecx,%eax
  800dda:	29 c1                	sub    %eax,%ecx
  800ddc:	89 75 08             	mov    %esi,0x8(%ebp)
  800ddf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800de2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800de5:	89 cb                	mov    %ecx,%ebx
  800de7:	eb 4d                	jmp    800e36 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800de9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ded:	74 1b                	je     800e0a <vprintfmt+0x21f>
  800def:	0f be c0             	movsbl %al,%eax
  800df2:	83 e8 20             	sub    $0x20,%eax
  800df5:	83 f8 5e             	cmp    $0x5e,%eax
  800df8:	76 10                	jbe    800e0a <vprintfmt+0x21f>
					putch('?', putdat);
  800dfa:	83 ec 08             	sub    $0x8,%esp
  800dfd:	ff 75 0c             	pushl  0xc(%ebp)
  800e00:	6a 3f                	push   $0x3f
  800e02:	ff 55 08             	call   *0x8(%ebp)
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	eb 0d                	jmp    800e17 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800e0a:	83 ec 08             	sub    $0x8,%esp
  800e0d:	ff 75 0c             	pushl  0xc(%ebp)
  800e10:	52                   	push   %edx
  800e11:	ff 55 08             	call   *0x8(%ebp)
  800e14:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e17:	83 eb 01             	sub    $0x1,%ebx
  800e1a:	eb 1a                	jmp    800e36 <vprintfmt+0x24b>
  800e1c:	89 75 08             	mov    %esi,0x8(%ebp)
  800e1f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e22:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e25:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e28:	eb 0c                	jmp    800e36 <vprintfmt+0x24b>
  800e2a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e2d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e30:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e33:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e36:	83 c7 01             	add    $0x1,%edi
  800e39:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e3d:	0f be d0             	movsbl %al,%edx
  800e40:	85 d2                	test   %edx,%edx
  800e42:	74 23                	je     800e67 <vprintfmt+0x27c>
  800e44:	85 f6                	test   %esi,%esi
  800e46:	78 a1                	js     800de9 <vprintfmt+0x1fe>
  800e48:	83 ee 01             	sub    $0x1,%esi
  800e4b:	79 9c                	jns    800de9 <vprintfmt+0x1fe>
  800e4d:	89 df                	mov    %ebx,%edi
  800e4f:	8b 75 08             	mov    0x8(%ebp),%esi
  800e52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e55:	eb 18                	jmp    800e6f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e57:	83 ec 08             	sub    $0x8,%esp
  800e5a:	53                   	push   %ebx
  800e5b:	6a 20                	push   $0x20
  800e5d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e5f:	83 ef 01             	sub    $0x1,%edi
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	eb 08                	jmp    800e6f <vprintfmt+0x284>
  800e67:	89 df                	mov    %ebx,%edi
  800e69:	8b 75 08             	mov    0x8(%ebp),%esi
  800e6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e6f:	85 ff                	test   %edi,%edi
  800e71:	7f e4                	jg     800e57 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e73:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e76:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e7c:	e9 90 fd ff ff       	jmp    800c11 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e81:	83 f9 01             	cmp    $0x1,%ecx
  800e84:	7e 19                	jle    800e9f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800e86:	8b 45 14             	mov    0x14(%ebp),%eax
  800e89:	8b 50 04             	mov    0x4(%eax),%edx
  800e8c:	8b 00                	mov    (%eax),%eax
  800e8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e91:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800e94:	8b 45 14             	mov    0x14(%ebp),%eax
  800e97:	8d 40 08             	lea    0x8(%eax),%eax
  800e9a:	89 45 14             	mov    %eax,0x14(%ebp)
  800e9d:	eb 38                	jmp    800ed7 <vprintfmt+0x2ec>
	else if (lflag)
  800e9f:	85 c9                	test   %ecx,%ecx
  800ea1:	74 1b                	je     800ebe <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800ea3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea6:	8b 00                	mov    (%eax),%eax
  800ea8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eab:	89 c1                	mov    %eax,%ecx
  800ead:	c1 f9 1f             	sar    $0x1f,%ecx
  800eb0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800eb3:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb6:	8d 40 04             	lea    0x4(%eax),%eax
  800eb9:	89 45 14             	mov    %eax,0x14(%ebp)
  800ebc:	eb 19                	jmp    800ed7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800ebe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec1:	8b 00                	mov    (%eax),%eax
  800ec3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec6:	89 c1                	mov    %eax,%ecx
  800ec8:	c1 f9 1f             	sar    $0x1f,%ecx
  800ecb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ece:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed1:	8d 40 04             	lea    0x4(%eax),%eax
  800ed4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ed7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800eda:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800edd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ee2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ee6:	0f 89 0e 01 00 00    	jns    800ffa <vprintfmt+0x40f>
				putch('-', putdat);
  800eec:	83 ec 08             	sub    $0x8,%esp
  800eef:	53                   	push   %ebx
  800ef0:	6a 2d                	push   $0x2d
  800ef2:	ff d6                	call   *%esi
				num = -(long long) num;
  800ef4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ef7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800efa:	f7 da                	neg    %edx
  800efc:	83 d1 00             	adc    $0x0,%ecx
  800eff:	f7 d9                	neg    %ecx
  800f01:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f09:	e9 ec 00 00 00       	jmp    800ffa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800f0e:	83 f9 01             	cmp    $0x1,%ecx
  800f11:	7e 18                	jle    800f2b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800f13:	8b 45 14             	mov    0x14(%ebp),%eax
  800f16:	8b 10                	mov    (%eax),%edx
  800f18:	8b 48 04             	mov    0x4(%eax),%ecx
  800f1b:	8d 40 08             	lea    0x8(%eax),%eax
  800f1e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f26:	e9 cf 00 00 00       	jmp    800ffa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800f2b:	85 c9                	test   %ecx,%ecx
  800f2d:	74 1a                	je     800f49 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800f2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f32:	8b 10                	mov    (%eax),%edx
  800f34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f39:	8d 40 04             	lea    0x4(%eax),%eax
  800f3c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f44:	e9 b1 00 00 00       	jmp    800ffa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800f49:	8b 45 14             	mov    0x14(%ebp),%eax
  800f4c:	8b 10                	mov    (%eax),%edx
  800f4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f53:	8d 40 04             	lea    0x4(%eax),%eax
  800f56:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f5e:	e9 97 00 00 00       	jmp    800ffa <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800f63:	83 ec 08             	sub    $0x8,%esp
  800f66:	53                   	push   %ebx
  800f67:	6a 58                	push   $0x58
  800f69:	ff d6                	call   *%esi
			putch('X', putdat);
  800f6b:	83 c4 08             	add    $0x8,%esp
  800f6e:	53                   	push   %ebx
  800f6f:	6a 58                	push   $0x58
  800f71:	ff d6                	call   *%esi
			putch('X', putdat);
  800f73:	83 c4 08             	add    $0x8,%esp
  800f76:	53                   	push   %ebx
  800f77:	6a 58                	push   $0x58
  800f79:	ff d6                	call   *%esi
			break;
  800f7b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800f81:	e9 8b fc ff ff       	jmp    800c11 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	53                   	push   %ebx
  800f8a:	6a 30                	push   $0x30
  800f8c:	ff d6                	call   *%esi
			putch('x', putdat);
  800f8e:	83 c4 08             	add    $0x8,%esp
  800f91:	53                   	push   %ebx
  800f92:	6a 78                	push   $0x78
  800f94:	ff d6                	call   *%esi
			num = (unsigned long long)
  800f96:	8b 45 14             	mov    0x14(%ebp),%eax
  800f99:	8b 10                	mov    (%eax),%edx
  800f9b:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800fa0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800fa3:	8d 40 04             	lea    0x4(%eax),%eax
  800fa6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800fa9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800fae:	eb 4a                	jmp    800ffa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800fb0:	83 f9 01             	cmp    $0x1,%ecx
  800fb3:	7e 15                	jle    800fca <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800fb5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb8:	8b 10                	mov    (%eax),%edx
  800fba:	8b 48 04             	mov    0x4(%eax),%ecx
  800fbd:	8d 40 08             	lea    0x8(%eax),%eax
  800fc0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800fc3:	b8 10 00 00 00       	mov    $0x10,%eax
  800fc8:	eb 30                	jmp    800ffa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800fca:	85 c9                	test   %ecx,%ecx
  800fcc:	74 17                	je     800fe5 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800fce:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd1:	8b 10                	mov    (%eax),%edx
  800fd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd8:	8d 40 04             	lea    0x4(%eax),%eax
  800fdb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800fde:	b8 10 00 00 00       	mov    $0x10,%eax
  800fe3:	eb 15                	jmp    800ffa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800fe5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fe8:	8b 10                	mov    (%eax),%edx
  800fea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fef:	8d 40 04             	lea    0x4(%eax),%eax
  800ff2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800ff5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801001:	57                   	push   %edi
  801002:	ff 75 e0             	pushl  -0x20(%ebp)
  801005:	50                   	push   %eax
  801006:	51                   	push   %ecx
  801007:	52                   	push   %edx
  801008:	89 da                	mov    %ebx,%edx
  80100a:	89 f0                	mov    %esi,%eax
  80100c:	e8 f1 fa ff ff       	call   800b02 <printnum>
			break;
  801011:	83 c4 20             	add    $0x20,%esp
  801014:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801017:	e9 f5 fb ff ff       	jmp    800c11 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80101c:	83 ec 08             	sub    $0x8,%esp
  80101f:	53                   	push   %ebx
  801020:	52                   	push   %edx
  801021:	ff d6                	call   *%esi
			break;
  801023:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801026:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801029:	e9 e3 fb ff ff       	jmp    800c11 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	53                   	push   %ebx
  801032:	6a 25                	push   $0x25
  801034:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	eb 03                	jmp    80103e <vprintfmt+0x453>
  80103b:	83 ef 01             	sub    $0x1,%edi
  80103e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801042:	75 f7                	jne    80103b <vprintfmt+0x450>
  801044:	e9 c8 fb ff ff       	jmp    800c11 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	83 ec 18             	sub    $0x18,%esp
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80105d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801060:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801064:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801067:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80106e:	85 c0                	test   %eax,%eax
  801070:	74 26                	je     801098 <vsnprintf+0x47>
  801072:	85 d2                	test   %edx,%edx
  801074:	7e 22                	jle    801098 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801076:	ff 75 14             	pushl  0x14(%ebp)
  801079:	ff 75 10             	pushl  0x10(%ebp)
  80107c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80107f:	50                   	push   %eax
  801080:	68 b1 0b 80 00       	push   $0x800bb1
  801085:	e8 61 fb ff ff       	call   800beb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80108a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80108d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801090:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	eb 05                	jmp    80109d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801098:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80109d:	c9                   	leave  
  80109e:	c3                   	ret    

0080109f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8010a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8010a8:	50                   	push   %eax
  8010a9:	ff 75 10             	pushl  0x10(%ebp)
  8010ac:	ff 75 0c             	pushl  0xc(%ebp)
  8010af:	ff 75 08             	pushl  0x8(%ebp)
  8010b2:	e8 9a ff ff ff       	call   801051 <vsnprintf>
	va_end(ap);

	return rc;
}
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	74 13                	je     8010dc <readline+0x23>
		fprintf(1, "%s", prompt);
  8010c9:	83 ec 04             	sub    $0x4,%esp
  8010cc:	50                   	push   %eax
  8010cd:	68 81 33 80 00       	push   $0x803381
  8010d2:	6a 01                	push   $0x1
  8010d4:	e8 9b 13 00 00       	call   802474 <fprintf>
  8010d9:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 49 f8 ff ff       	call   80092f <iscons>
  8010e6:	89 c7                	mov    %eax,%edi
  8010e8:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010eb:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010f0:	e8 0f f8 ff ff       	call   800904 <getchar>
  8010f5:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	79 29                	jns    801124 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8010fb:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  801100:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801103:	0f 84 9b 00 00 00    	je     8011a4 <readline+0xeb>
				cprintf("read error: %e\n", c);
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	53                   	push   %ebx
  80110d:	68 5f 37 80 00       	push   $0x80375f
  801112:	e8 d7 f9 ff ff       	call   800aee <cprintf>
  801117:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80111a:	b8 00 00 00 00       	mov    $0x0,%eax
  80111f:	e9 80 00 00 00       	jmp    8011a4 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801124:	83 f8 08             	cmp    $0x8,%eax
  801127:	0f 94 c2             	sete   %dl
  80112a:	83 f8 7f             	cmp    $0x7f,%eax
  80112d:	0f 94 c0             	sete   %al
  801130:	08 c2                	or     %al,%dl
  801132:	74 1a                	je     80114e <readline+0x95>
  801134:	85 f6                	test   %esi,%esi
  801136:	7e 16                	jle    80114e <readline+0x95>
			if (echoing)
  801138:	85 ff                	test   %edi,%edi
  80113a:	74 0d                	je     801149 <readline+0x90>
				cputchar('\b');
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	6a 08                	push   $0x8
  801141:	e8 a2 f7 ff ff       	call   8008e8 <cputchar>
  801146:	83 c4 10             	add    $0x10,%esp
			i--;
  801149:	83 ee 01             	sub    $0x1,%esi
  80114c:	eb a2                	jmp    8010f0 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80114e:	83 fb 1f             	cmp    $0x1f,%ebx
  801151:	7e 26                	jle    801179 <readline+0xc0>
  801153:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801159:	7f 1e                	jg     801179 <readline+0xc0>
			if (echoing)
  80115b:	85 ff                	test   %edi,%edi
  80115d:	74 0c                	je     80116b <readline+0xb2>
				cputchar(c);
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	53                   	push   %ebx
  801163:	e8 80 f7 ff ff       	call   8008e8 <cputchar>
  801168:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80116b:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801171:	8d 76 01             	lea    0x1(%esi),%esi
  801174:	e9 77 ff ff ff       	jmp    8010f0 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801179:	83 fb 0a             	cmp    $0xa,%ebx
  80117c:	74 09                	je     801187 <readline+0xce>
  80117e:	83 fb 0d             	cmp    $0xd,%ebx
  801181:	0f 85 69 ff ff ff    	jne    8010f0 <readline+0x37>
			if (echoing)
  801187:	85 ff                	test   %edi,%edi
  801189:	74 0d                	je     801198 <readline+0xdf>
				cputchar('\n');
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	6a 0a                	push   $0xa
  801190:	e8 53 f7 ff ff       	call   8008e8 <cputchar>
  801195:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801198:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80119f:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  8011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8011b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b7:	eb 03                	jmp    8011bc <strlen+0x10>
		n++;
  8011b9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011c0:	75 f7                	jne    8011b9 <strlen+0xd>
		n++;
	return n;
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d2:	eb 03                	jmp    8011d7 <strnlen+0x13>
		n++;
  8011d4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011d7:	39 c2                	cmp    %eax,%edx
  8011d9:	74 08                	je     8011e3 <strnlen+0x1f>
  8011db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8011df:	75 f3                	jne    8011d4 <strnlen+0x10>
  8011e1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	53                   	push   %ebx
  8011e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	83 c2 01             	add    $0x1,%edx
  8011f4:	83 c1 01             	add    $0x1,%ecx
  8011f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8011fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8011fe:	84 db                	test   %bl,%bl
  801200:	75 ef                	jne    8011f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801202:	5b                   	pop    %ebx
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	53                   	push   %ebx
  801209:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80120c:	53                   	push   %ebx
  80120d:	e8 9a ff ff ff       	call   8011ac <strlen>
  801212:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801215:	ff 75 0c             	pushl  0xc(%ebp)
  801218:	01 d8                	add    %ebx,%eax
  80121a:	50                   	push   %eax
  80121b:	e8 c5 ff ff ff       	call   8011e5 <strcpy>
	return dst;
}
  801220:	89 d8                	mov    %ebx,%eax
  801222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	56                   	push   %esi
  80122b:	53                   	push   %ebx
  80122c:	8b 75 08             	mov    0x8(%ebp),%esi
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801232:	89 f3                	mov    %esi,%ebx
  801234:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801237:	89 f2                	mov    %esi,%edx
  801239:	eb 0f                	jmp    80124a <strncpy+0x23>
		*dst++ = *src;
  80123b:	83 c2 01             	add    $0x1,%edx
  80123e:	0f b6 01             	movzbl (%ecx),%eax
  801241:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801244:	80 39 01             	cmpb   $0x1,(%ecx)
  801247:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80124a:	39 da                	cmp    %ebx,%edx
  80124c:	75 ed                	jne    80123b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80124e:	89 f0                	mov    %esi,%eax
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	8b 75 08             	mov    0x8(%ebp),%esi
  80125c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125f:	8b 55 10             	mov    0x10(%ebp),%edx
  801262:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801264:	85 d2                	test   %edx,%edx
  801266:	74 21                	je     801289 <strlcpy+0x35>
  801268:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80126c:	89 f2                	mov    %esi,%edx
  80126e:	eb 09                	jmp    801279 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801270:	83 c2 01             	add    $0x1,%edx
  801273:	83 c1 01             	add    $0x1,%ecx
  801276:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801279:	39 c2                	cmp    %eax,%edx
  80127b:	74 09                	je     801286 <strlcpy+0x32>
  80127d:	0f b6 19             	movzbl (%ecx),%ebx
  801280:	84 db                	test   %bl,%bl
  801282:	75 ec                	jne    801270 <strlcpy+0x1c>
  801284:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801286:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801289:	29 f0                	sub    %esi,%eax
}
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801295:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801298:	eb 06                	jmp    8012a0 <strcmp+0x11>
		p++, q++;
  80129a:	83 c1 01             	add    $0x1,%ecx
  80129d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8012a0:	0f b6 01             	movzbl (%ecx),%eax
  8012a3:	84 c0                	test   %al,%al
  8012a5:	74 04                	je     8012ab <strcmp+0x1c>
  8012a7:	3a 02                	cmp    (%edx),%al
  8012a9:	74 ef                	je     80129a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012ab:	0f b6 c0             	movzbl %al,%eax
  8012ae:	0f b6 12             	movzbl (%edx),%edx
  8012b1:	29 d0                	sub    %edx,%eax
}
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	53                   	push   %ebx
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bf:	89 c3                	mov    %eax,%ebx
  8012c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8012c4:	eb 06                	jmp    8012cc <strncmp+0x17>
		n--, p++, q++;
  8012c6:	83 c0 01             	add    $0x1,%eax
  8012c9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012cc:	39 d8                	cmp    %ebx,%eax
  8012ce:	74 15                	je     8012e5 <strncmp+0x30>
  8012d0:	0f b6 08             	movzbl (%eax),%ecx
  8012d3:	84 c9                	test   %cl,%cl
  8012d5:	74 04                	je     8012db <strncmp+0x26>
  8012d7:	3a 0a                	cmp    (%edx),%cl
  8012d9:	74 eb                	je     8012c6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012db:	0f b6 00             	movzbl (%eax),%eax
  8012de:	0f b6 12             	movzbl (%edx),%edx
  8012e1:	29 d0                	sub    %edx,%eax
  8012e3:	eb 05                	jmp    8012ea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012ea:	5b                   	pop    %ebx
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012f7:	eb 07                	jmp    801300 <strchr+0x13>
		if (*s == c)
  8012f9:	38 ca                	cmp    %cl,%dl
  8012fb:	74 0f                	je     80130c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012fd:	83 c0 01             	add    $0x1,%eax
  801300:	0f b6 10             	movzbl (%eax),%edx
  801303:	84 d2                	test   %dl,%dl
  801305:	75 f2                	jne    8012f9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801307:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	8b 45 08             	mov    0x8(%ebp),%eax
  801314:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801318:	eb 03                	jmp    80131d <strfind+0xf>
  80131a:	83 c0 01             	add    $0x1,%eax
  80131d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801320:	38 ca                	cmp    %cl,%dl
  801322:	74 04                	je     801328 <strfind+0x1a>
  801324:	84 d2                	test   %dl,%dl
  801326:	75 f2                	jne    80131a <strfind+0xc>
			break;
	return (char *) s;
}
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	57                   	push   %edi
  80132e:	56                   	push   %esi
  80132f:	53                   	push   %ebx
  801330:	8b 7d 08             	mov    0x8(%ebp),%edi
  801333:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801336:	85 c9                	test   %ecx,%ecx
  801338:	74 36                	je     801370 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80133a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801340:	75 28                	jne    80136a <memset+0x40>
  801342:	f6 c1 03             	test   $0x3,%cl
  801345:	75 23                	jne    80136a <memset+0x40>
		c &= 0xFF;
  801347:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80134b:	89 d3                	mov    %edx,%ebx
  80134d:	c1 e3 08             	shl    $0x8,%ebx
  801350:	89 d6                	mov    %edx,%esi
  801352:	c1 e6 18             	shl    $0x18,%esi
  801355:	89 d0                	mov    %edx,%eax
  801357:	c1 e0 10             	shl    $0x10,%eax
  80135a:	09 f0                	or     %esi,%eax
  80135c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80135e:	89 d8                	mov    %ebx,%eax
  801360:	09 d0                	or     %edx,%eax
  801362:	c1 e9 02             	shr    $0x2,%ecx
  801365:	fc                   	cld    
  801366:	f3 ab                	rep stos %eax,%es:(%edi)
  801368:	eb 06                	jmp    801370 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80136a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136d:	fc                   	cld    
  80136e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801370:	89 f8                	mov    %edi,%eax
  801372:	5b                   	pop    %ebx
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	57                   	push   %edi
  80137b:	56                   	push   %esi
  80137c:	8b 45 08             	mov    0x8(%ebp),%eax
  80137f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801382:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801385:	39 c6                	cmp    %eax,%esi
  801387:	73 35                	jae    8013be <memmove+0x47>
  801389:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80138c:	39 d0                	cmp    %edx,%eax
  80138e:	73 2e                	jae    8013be <memmove+0x47>
		s += n;
		d += n;
  801390:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801393:	89 d6                	mov    %edx,%esi
  801395:	09 fe                	or     %edi,%esi
  801397:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80139d:	75 13                	jne    8013b2 <memmove+0x3b>
  80139f:	f6 c1 03             	test   $0x3,%cl
  8013a2:	75 0e                	jne    8013b2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8013a4:	83 ef 04             	sub    $0x4,%edi
  8013a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013aa:	c1 e9 02             	shr    $0x2,%ecx
  8013ad:	fd                   	std    
  8013ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013b0:	eb 09                	jmp    8013bb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8013b2:	83 ef 01             	sub    $0x1,%edi
  8013b5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8013b8:	fd                   	std    
  8013b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013bb:	fc                   	cld    
  8013bc:	eb 1d                	jmp    8013db <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013be:	89 f2                	mov    %esi,%edx
  8013c0:	09 c2                	or     %eax,%edx
  8013c2:	f6 c2 03             	test   $0x3,%dl
  8013c5:	75 0f                	jne    8013d6 <memmove+0x5f>
  8013c7:	f6 c1 03             	test   $0x3,%cl
  8013ca:	75 0a                	jne    8013d6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8013cc:	c1 e9 02             	shr    $0x2,%ecx
  8013cf:	89 c7                	mov    %eax,%edi
  8013d1:	fc                   	cld    
  8013d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013d4:	eb 05                	jmp    8013db <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8013d6:	89 c7                	mov    %eax,%edi
  8013d8:	fc                   	cld    
  8013d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013db:	5e                   	pop    %esi
  8013dc:	5f                   	pop    %edi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8013e2:	ff 75 10             	pushl  0x10(%ebp)
  8013e5:	ff 75 0c             	pushl  0xc(%ebp)
  8013e8:	ff 75 08             	pushl  0x8(%ebp)
  8013eb:	e8 87 ff ff ff       	call   801377 <memmove>
}
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    

008013f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fd:	89 c6                	mov    %eax,%esi
  8013ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801402:	eb 1a                	jmp    80141e <memcmp+0x2c>
		if (*s1 != *s2)
  801404:	0f b6 08             	movzbl (%eax),%ecx
  801407:	0f b6 1a             	movzbl (%edx),%ebx
  80140a:	38 d9                	cmp    %bl,%cl
  80140c:	74 0a                	je     801418 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80140e:	0f b6 c1             	movzbl %cl,%eax
  801411:	0f b6 db             	movzbl %bl,%ebx
  801414:	29 d8                	sub    %ebx,%eax
  801416:	eb 0f                	jmp    801427 <memcmp+0x35>
		s1++, s2++;
  801418:	83 c0 01             	add    $0x1,%eax
  80141b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80141e:	39 f0                	cmp    %esi,%eax
  801420:	75 e2                	jne    801404 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801422:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    

0080142b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	53                   	push   %ebx
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801432:	89 c1                	mov    %eax,%ecx
  801434:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801437:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80143b:	eb 0a                	jmp    801447 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80143d:	0f b6 10             	movzbl (%eax),%edx
  801440:	39 da                	cmp    %ebx,%edx
  801442:	74 07                	je     80144b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801444:	83 c0 01             	add    $0x1,%eax
  801447:	39 c8                	cmp    %ecx,%eax
  801449:	72 f2                	jb     80143d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80144b:	5b                   	pop    %ebx
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    

0080144e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	57                   	push   %edi
  801452:	56                   	push   %esi
  801453:	53                   	push   %ebx
  801454:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801457:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80145a:	eb 03                	jmp    80145f <strtol+0x11>
		s++;
  80145c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80145f:	0f b6 01             	movzbl (%ecx),%eax
  801462:	3c 20                	cmp    $0x20,%al
  801464:	74 f6                	je     80145c <strtol+0xe>
  801466:	3c 09                	cmp    $0x9,%al
  801468:	74 f2                	je     80145c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80146a:	3c 2b                	cmp    $0x2b,%al
  80146c:	75 0a                	jne    801478 <strtol+0x2a>
		s++;
  80146e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801471:	bf 00 00 00 00       	mov    $0x0,%edi
  801476:	eb 11                	jmp    801489 <strtol+0x3b>
  801478:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80147d:	3c 2d                	cmp    $0x2d,%al
  80147f:	75 08                	jne    801489 <strtol+0x3b>
		s++, neg = 1;
  801481:	83 c1 01             	add    $0x1,%ecx
  801484:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801489:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80148f:	75 15                	jne    8014a6 <strtol+0x58>
  801491:	80 39 30             	cmpb   $0x30,(%ecx)
  801494:	75 10                	jne    8014a6 <strtol+0x58>
  801496:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80149a:	75 7c                	jne    801518 <strtol+0xca>
		s += 2, base = 16;
  80149c:	83 c1 02             	add    $0x2,%ecx
  80149f:	bb 10 00 00 00       	mov    $0x10,%ebx
  8014a4:	eb 16                	jmp    8014bc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8014a6:	85 db                	test   %ebx,%ebx
  8014a8:	75 12                	jne    8014bc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8014aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014af:	80 39 30             	cmpb   $0x30,(%ecx)
  8014b2:	75 08                	jne    8014bc <strtol+0x6e>
		s++, base = 8;
  8014b4:	83 c1 01             	add    $0x1,%ecx
  8014b7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8014bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8014c4:	0f b6 11             	movzbl (%ecx),%edx
  8014c7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8014ca:	89 f3                	mov    %esi,%ebx
  8014cc:	80 fb 09             	cmp    $0x9,%bl
  8014cf:	77 08                	ja     8014d9 <strtol+0x8b>
			dig = *s - '0';
  8014d1:	0f be d2             	movsbl %dl,%edx
  8014d4:	83 ea 30             	sub    $0x30,%edx
  8014d7:	eb 22                	jmp    8014fb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8014d9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8014dc:	89 f3                	mov    %esi,%ebx
  8014de:	80 fb 19             	cmp    $0x19,%bl
  8014e1:	77 08                	ja     8014eb <strtol+0x9d>
			dig = *s - 'a' + 10;
  8014e3:	0f be d2             	movsbl %dl,%edx
  8014e6:	83 ea 57             	sub    $0x57,%edx
  8014e9:	eb 10                	jmp    8014fb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8014eb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8014ee:	89 f3                	mov    %esi,%ebx
  8014f0:	80 fb 19             	cmp    $0x19,%bl
  8014f3:	77 16                	ja     80150b <strtol+0xbd>
			dig = *s - 'A' + 10;
  8014f5:	0f be d2             	movsbl %dl,%edx
  8014f8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8014fb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014fe:	7d 0b                	jge    80150b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801500:	83 c1 01             	add    $0x1,%ecx
  801503:	0f af 45 10          	imul   0x10(%ebp),%eax
  801507:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801509:	eb b9                	jmp    8014c4 <strtol+0x76>

	if (endptr)
  80150b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80150f:	74 0d                	je     80151e <strtol+0xd0>
		*endptr = (char *) s;
  801511:	8b 75 0c             	mov    0xc(%ebp),%esi
  801514:	89 0e                	mov    %ecx,(%esi)
  801516:	eb 06                	jmp    80151e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801518:	85 db                	test   %ebx,%ebx
  80151a:	74 98                	je     8014b4 <strtol+0x66>
  80151c:	eb 9e                	jmp    8014bc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80151e:	89 c2                	mov    %eax,%edx
  801520:	f7 da                	neg    %edx
  801522:	85 ff                	test   %edi,%edi
  801524:	0f 45 c2             	cmovne %edx,%eax
}
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5f                   	pop    %edi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	57                   	push   %edi
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801532:	b8 00 00 00 00       	mov    $0x0,%eax
  801537:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80153a:	8b 55 08             	mov    0x8(%ebp),%edx
  80153d:	89 c3                	mov    %eax,%ebx
  80153f:	89 c7                	mov    %eax,%edi
  801541:	89 c6                	mov    %eax,%esi
  801543:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <sys_cgetc>:

int
sys_cgetc(void)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	57                   	push   %edi
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	b8 01 00 00 00       	mov    $0x1,%eax
  80155a:	89 d1                	mov    %edx,%ecx
  80155c:	89 d3                	mov    %edx,%ebx
  80155e:	89 d7                	mov    %edx,%edi
  801560:	89 d6                	mov    %edx,%esi
  801562:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801564:	5b                   	pop    %ebx
  801565:	5e                   	pop    %esi
  801566:	5f                   	pop    %edi
  801567:	5d                   	pop    %ebp
  801568:	c3                   	ret    

00801569 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	57                   	push   %edi
  80156d:	56                   	push   %esi
  80156e:	53                   	push   %ebx
  80156f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801572:	b9 00 00 00 00       	mov    $0x0,%ecx
  801577:	b8 03 00 00 00       	mov    $0x3,%eax
  80157c:	8b 55 08             	mov    0x8(%ebp),%edx
  80157f:	89 cb                	mov    %ecx,%ebx
  801581:	89 cf                	mov    %ecx,%edi
  801583:	89 ce                	mov    %ecx,%esi
  801585:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801587:	85 c0                	test   %eax,%eax
  801589:	7e 17                	jle    8015a2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	50                   	push   %eax
  80158f:	6a 03                	push   $0x3
  801591:	68 6f 37 80 00       	push   $0x80376f
  801596:	6a 23                	push   $0x23
  801598:	68 8c 37 80 00       	push   $0x80378c
  80159d:	e8 73 f4 ff ff       	call   800a15 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5e                   	pop    %esi
  8015a7:	5f                   	pop    %edi
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    

008015aa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	57                   	push   %edi
  8015ae:	56                   	push   %esi
  8015af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b5:	b8 02 00 00 00       	mov    $0x2,%eax
  8015ba:	89 d1                	mov    %edx,%ecx
  8015bc:	89 d3                	mov    %edx,%ebx
  8015be:	89 d7                	mov    %edx,%edi
  8015c0:	89 d6                	mov    %edx,%esi
  8015c2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <sys_yield>:

void
sys_yield(void)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	57                   	push   %edi
  8015cd:	56                   	push   %esi
  8015ce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8015d9:	89 d1                	mov    %edx,%ecx
  8015db:	89 d3                	mov    %edx,%ebx
  8015dd:	89 d7                	mov    %edx,%edi
  8015df:	89 d6                	mov    %edx,%esi
  8015e1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015e3:	5b                   	pop    %ebx
  8015e4:	5e                   	pop    %esi
  8015e5:	5f                   	pop    %edi
  8015e6:	5d                   	pop    %ebp
  8015e7:	c3                   	ret    

008015e8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	57                   	push   %edi
  8015ec:	56                   	push   %esi
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f1:	be 00 00 00 00       	mov    $0x0,%esi
  8015f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8015fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801601:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801604:	89 f7                	mov    %esi,%edi
  801606:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801608:	85 c0                	test   %eax,%eax
  80160a:	7e 17                	jle    801623 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	50                   	push   %eax
  801610:	6a 04                	push   $0x4
  801612:	68 6f 37 80 00       	push   $0x80376f
  801617:	6a 23                	push   $0x23
  801619:	68 8c 37 80 00       	push   $0x80378c
  80161e:	e8 f2 f3 ff ff       	call   800a15 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5f                   	pop    %edi
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	57                   	push   %edi
  80162f:	56                   	push   %esi
  801630:	53                   	push   %ebx
  801631:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801634:	b8 05 00 00 00       	mov    $0x5,%eax
  801639:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80163c:	8b 55 08             	mov    0x8(%ebp),%edx
  80163f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801642:	8b 7d 14             	mov    0x14(%ebp),%edi
  801645:	8b 75 18             	mov    0x18(%ebp),%esi
  801648:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80164a:	85 c0                	test   %eax,%eax
  80164c:	7e 17                	jle    801665 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	50                   	push   %eax
  801652:	6a 05                	push   $0x5
  801654:	68 6f 37 80 00       	push   $0x80376f
  801659:	6a 23                	push   $0x23
  80165b:	68 8c 37 80 00       	push   $0x80378c
  801660:	e8 b0 f3 ff ff       	call   800a15 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5f                   	pop    %edi
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	57                   	push   %edi
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
  801673:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801676:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167b:	b8 06 00 00 00       	mov    $0x6,%eax
  801680:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801683:	8b 55 08             	mov    0x8(%ebp),%edx
  801686:	89 df                	mov    %ebx,%edi
  801688:	89 de                	mov    %ebx,%esi
  80168a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80168c:	85 c0                	test   %eax,%eax
  80168e:	7e 17                	jle    8016a7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801690:	83 ec 0c             	sub    $0xc,%esp
  801693:	50                   	push   %eax
  801694:	6a 06                	push   $0x6
  801696:	68 6f 37 80 00       	push   $0x80376f
  80169b:	6a 23                	push   $0x23
  80169d:	68 8c 37 80 00       	push   $0x80378c
  8016a2:	e8 6e f3 ff ff       	call   800a15 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8016a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5f                   	pop    %edi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	57                   	push   %edi
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8016c8:	89 df                	mov    %ebx,%edi
  8016ca:	89 de                	mov    %ebx,%esi
  8016cc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	7e 17                	jle    8016e9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	50                   	push   %eax
  8016d6:	6a 08                	push   $0x8
  8016d8:	68 6f 37 80 00       	push   $0x80376f
  8016dd:	6a 23                	push   $0x23
  8016df:	68 8c 37 80 00       	push   $0x80378c
  8016e4:	e8 2c f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ec:	5b                   	pop    %ebx
  8016ed:	5e                   	pop    %esi
  8016ee:	5f                   	pop    %edi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	57                   	push   %edi
  8016f5:	56                   	push   %esi
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ff:	b8 09 00 00 00       	mov    $0x9,%eax
  801704:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801707:	8b 55 08             	mov    0x8(%ebp),%edx
  80170a:	89 df                	mov    %ebx,%edi
  80170c:	89 de                	mov    %ebx,%esi
  80170e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801710:	85 c0                	test   %eax,%eax
  801712:	7e 17                	jle    80172b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801714:	83 ec 0c             	sub    $0xc,%esp
  801717:	50                   	push   %eax
  801718:	6a 09                	push   $0x9
  80171a:	68 6f 37 80 00       	push   $0x80376f
  80171f:	6a 23                	push   $0x23
  801721:	68 8c 37 80 00       	push   $0x80378c
  801726:	e8 ea f2 ff ff       	call   800a15 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80172b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5f                   	pop    %edi
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	57                   	push   %edi
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80173c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801741:	b8 0a 00 00 00       	mov    $0xa,%eax
  801746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801749:	8b 55 08             	mov    0x8(%ebp),%edx
  80174c:	89 df                	mov    %ebx,%edi
  80174e:	89 de                	mov    %ebx,%esi
  801750:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801752:	85 c0                	test   %eax,%eax
  801754:	7e 17                	jle    80176d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801756:	83 ec 0c             	sub    $0xc,%esp
  801759:	50                   	push   %eax
  80175a:	6a 0a                	push   $0xa
  80175c:	68 6f 37 80 00       	push   $0x80376f
  801761:	6a 23                	push   $0x23
  801763:	68 8c 37 80 00       	push   $0x80378c
  801768:	e8 a8 f2 ff ff       	call   800a15 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80176d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801770:	5b                   	pop    %ebx
  801771:	5e                   	pop    %esi
  801772:	5f                   	pop    %edi
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	57                   	push   %edi
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80177b:	be 00 00 00 00       	mov    $0x0,%esi
  801780:	b8 0c 00 00 00       	mov    $0xc,%eax
  801785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801788:	8b 55 08             	mov    0x8(%ebp),%edx
  80178b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80178e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801791:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801793:	5b                   	pop    %ebx
  801794:	5e                   	pop    %esi
  801795:	5f                   	pop    %edi
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	57                   	push   %edi
  80179c:	56                   	push   %esi
  80179d:	53                   	push   %ebx
  80179e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017a6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ae:	89 cb                	mov    %ecx,%ebx
  8017b0:	89 cf                	mov    %ecx,%edi
  8017b2:	89 ce                	mov    %ecx,%esi
  8017b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	7e 17                	jle    8017d1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017ba:	83 ec 0c             	sub    $0xc,%esp
  8017bd:	50                   	push   %eax
  8017be:	6a 0d                	push   $0xd
  8017c0:	68 6f 37 80 00       	push   $0x80376f
  8017c5:	6a 23                	push   $0x23
  8017c7:	68 8c 37 80 00       	push   $0x80378c
  8017cc:	e8 44 f2 ff ff       	call   800a15 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d4:	5b                   	pop    %ebx
  8017d5:	5e                   	pop    %esi
  8017d6:	5f                   	pop    %edi
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	57                   	push   %edi
  8017dd:	56                   	push   %esi
  8017de:	53                   	push   %ebx
  8017df:	83 ec 0c             	sub    $0xc,%esp
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017e5:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  8017e7:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  8017ea:	e8 bb fd ff ff       	call   8015aa <sys_getenvid>
  8017ef:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  8017f1:	f7 c7 02 00 00 00    	test   $0x2,%edi
  8017f7:	75 25                	jne    80181e <pgfault+0x45>
  8017f9:	89 d8                	mov    %ebx,%eax
  8017fb:	c1 e8 0c             	shr    $0xc,%eax
  8017fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801805:	f6 c4 08             	test   $0x8,%ah
  801808:	75 14                	jne    80181e <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  80180a:	83 ec 04             	sub    $0x4,%esp
  80180d:	68 9c 37 80 00       	push   $0x80379c
  801812:	6a 1e                	push   $0x1e
  801814:	68 c1 37 80 00       	push   $0x8037c1
  801819:	e8 f7 f1 ff ff       	call   800a15 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  80181e:	83 ec 04             	sub    $0x4,%esp
  801821:	6a 07                	push   $0x7
  801823:	68 00 f0 7f 00       	push   $0x7ff000
  801828:	56                   	push   %esi
  801829:	e8 ba fd ff ff       	call   8015e8 <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  80182e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  801834:	83 c4 0c             	add    $0xc,%esp
  801837:	68 00 10 00 00       	push   $0x1000
  80183c:	53                   	push   %ebx
  80183d:	68 00 f0 7f 00       	push   $0x7ff000
  801842:	e8 30 fb ff ff       	call   801377 <memmove>

	sys_page_unmap(curenvid, addr);
  801847:	83 c4 08             	add    $0x8,%esp
  80184a:	53                   	push   %ebx
  80184b:	56                   	push   %esi
  80184c:	e8 1c fe ff ff       	call   80166d <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  801851:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801858:	53                   	push   %ebx
  801859:	56                   	push   %esi
  80185a:	68 00 f0 7f 00       	push   $0x7ff000
  80185f:	56                   	push   %esi
  801860:	e8 c6 fd ff ff       	call   80162b <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  801865:	83 c4 18             	add    $0x18,%esp
  801868:	68 00 f0 7f 00       	push   $0x7ff000
  80186d:	56                   	push   %esi
  80186e:	e8 fa fd ff ff       	call   80166d <sys_page_unmap>
}
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801879:	5b                   	pop    %ebx
  80187a:	5e                   	pop    %esi
  80187b:	5f                   	pop    %edi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	57                   	push   %edi
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  801887:	e8 1e fd ff ff       	call   8015aa <sys_getenvid>
	set_pgfault_handler(pgfault);
  80188c:	83 ec 0c             	sub    $0xc,%esp
  80188f:	68 d9 17 80 00       	push   $0x8017d9
  801894:	e8 4f 15 00 00       	call   802de8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801899:	b8 07 00 00 00       	mov    $0x7,%eax
  80189e:	cd 30                	int    $0x30
  8018a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	79 12                	jns    8018bf <fork+0x41>
	    panic("fork error: %e", new_envid);
  8018ad:	50                   	push   %eax
  8018ae:	68 cc 37 80 00       	push   $0x8037cc
  8018b3:	6a 75                	push   $0x75
  8018b5:	68 c1 37 80 00       	push   $0x8037c1
  8018ba:	e8 56 f1 ff ff       	call   800a15 <_panic>
  8018bf:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  8018c4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018c8:	75 1c                	jne    8018e6 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  8018ca:	e8 db fc ff ff       	call   8015aa <sys_getenvid>
  8018cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018d4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018dc:	a3 24 54 80 00       	mov    %eax,0x805424
  8018e1:	e9 27 01 00 00       	jmp    801a0d <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  8018e6:	89 f8                	mov    %edi,%eax
  8018e8:	c1 e8 16             	shr    $0x16,%eax
  8018eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018f2:	a8 01                	test   $0x1,%al
  8018f4:	0f 84 d2 00 00 00    	je     8019cc <fork+0x14e>
  8018fa:	89 fb                	mov    %edi,%ebx
  8018fc:	c1 eb 0c             	shr    $0xc,%ebx
  8018ff:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801906:	a8 01                	test   $0x1,%al
  801908:	0f 84 be 00 00 00    	je     8019cc <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  80190e:	e8 97 fc ff ff       	call   8015aa <sys_getenvid>
  801913:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  801916:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  80191d:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  801922:	a8 02                	test   $0x2,%al
  801924:	75 1d                	jne    801943 <fork+0xc5>
  801926:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80192d:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  801932:	83 f8 01             	cmp    $0x1,%eax
  801935:	19 f6                	sbb    %esi,%esi
  801937:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  80193d:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  801943:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80194a:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  80194f:	b8 07 0e 00 00       	mov    $0xe07,%eax
  801954:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  801957:	89 d8                	mov    %ebx,%eax
  801959:	c1 e0 0c             	shl    $0xc,%eax
  80195c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80195f:	83 ec 0c             	sub    $0xc,%esp
  801962:	56                   	push   %esi
  801963:	50                   	push   %eax
  801964:	ff 75 dc             	pushl  -0x24(%ebp)
  801967:	50                   	push   %eax
  801968:	ff 75 e4             	pushl  -0x1c(%ebp)
  80196b:	e8 bb fc ff ff       	call   80162b <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  801970:	83 c4 20             	add    $0x20,%esp
  801973:	85 c0                	test   %eax,%eax
  801975:	79 12                	jns    801989 <fork+0x10b>
		panic("duppage error: %e", r);
  801977:	50                   	push   %eax
  801978:	68 db 37 80 00       	push   $0x8037db
  80197d:	6a 4d                	push   $0x4d
  80197f:	68 c1 37 80 00       	push   $0x8037c1
  801984:	e8 8c f0 ff ff       	call   800a15 <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  801989:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801990:	a8 02                	test   $0x2,%al
  801992:	75 0c                	jne    8019a0 <fork+0x122>
  801994:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80199b:	f6 c4 08             	test   $0x8,%ah
  80199e:	74 2c                	je     8019cc <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	56                   	push   %esi
  8019a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8019a7:	52                   	push   %edx
  8019a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ab:	50                   	push   %eax
  8019ac:	52                   	push   %edx
  8019ad:	50                   	push   %eax
  8019ae:	e8 78 fc ff ff       	call   80162b <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  8019b3:	83 c4 20             	add    $0x20,%esp
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	79 12                	jns    8019cc <fork+0x14e>
			panic("duppage error: %e", r);
  8019ba:	50                   	push   %eax
  8019bb:	68 db 37 80 00       	push   $0x8037db
  8019c0:	6a 53                	push   $0x53
  8019c2:	68 c1 37 80 00       	push   $0x8037c1
  8019c7:	e8 49 f0 ff ff       	call   800a15 <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  8019cc:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8019d2:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  8019d8:	0f 85 08 ff ff ff    	jne    8018e6 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  8019de:	83 ec 04             	sub    $0x4,%esp
  8019e1:	6a 07                	push   $0x7
  8019e3:	68 00 f0 bf ee       	push   $0xeebff000
  8019e8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8019eb:	56                   	push   %esi
  8019ec:	e8 f7 fb ff ff       	call   8015e8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  8019f1:	83 c4 08             	add    $0x8,%esp
  8019f4:	68 2d 2e 80 00       	push   $0x802e2d
  8019f9:	56                   	push   %esi
  8019fa:	e8 34 fd ff ff       	call   801733 <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  8019ff:	83 c4 08             	add    $0x8,%esp
  801a02:	6a 02                	push   $0x2
  801a04:	56                   	push   %esi
  801a05:	e8 a5 fc ff ff       	call   8016af <sys_env_set_status>
  801a0a:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  801a0d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a13:	5b                   	pop    %ebx
  801a14:	5e                   	pop    %esi
  801a15:	5f                   	pop    %edi
  801a16:	5d                   	pop    %ebp
  801a17:	c3                   	ret    

00801a18 <sfork>:

// Challenge!
int
sfork(void)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a1e:	68 ed 37 80 00       	push   $0x8037ed
  801a23:	68 8b 00 00 00       	push   $0x8b
  801a28:	68 c1 37 80 00       	push   $0x8037c1
  801a2d:	e8 e3 ef ff ff       	call   800a15 <_panic>

00801a32 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	8b 55 08             	mov    0x8(%ebp),%edx
  801a38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3b:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a3e:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a40:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a43:	83 3a 01             	cmpl   $0x1,(%edx)
  801a46:	7e 09                	jle    801a51 <argstart+0x1f>
  801a48:	ba 41 32 80 00       	mov    $0x803241,%edx
  801a4d:	85 c9                	test   %ecx,%ecx
  801a4f:	75 05                	jne    801a56 <argstart+0x24>
  801a51:	ba 00 00 00 00       	mov    $0x0,%edx
  801a56:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801a59:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    

00801a62 <argnext>:

int
argnext(struct Argstate *args)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	53                   	push   %ebx
  801a66:	83 ec 04             	sub    $0x4,%esp
  801a69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801a6c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801a73:	8b 43 08             	mov    0x8(%ebx),%eax
  801a76:	85 c0                	test   %eax,%eax
  801a78:	74 6f                	je     801ae9 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801a7a:	80 38 00             	cmpb   $0x0,(%eax)
  801a7d:	75 4e                	jne    801acd <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801a7f:	8b 0b                	mov    (%ebx),%ecx
  801a81:	83 39 01             	cmpl   $0x1,(%ecx)
  801a84:	74 55                	je     801adb <argnext+0x79>
		    || args->argv[1][0] != '-'
  801a86:	8b 53 04             	mov    0x4(%ebx),%edx
  801a89:	8b 42 04             	mov    0x4(%edx),%eax
  801a8c:	80 38 2d             	cmpb   $0x2d,(%eax)
  801a8f:	75 4a                	jne    801adb <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801a91:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801a95:	74 44                	je     801adb <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801a97:	83 c0 01             	add    $0x1,%eax
  801a9a:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801a9d:	83 ec 04             	sub    $0x4,%esp
  801aa0:	8b 01                	mov    (%ecx),%eax
  801aa2:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801aa9:	50                   	push   %eax
  801aaa:	8d 42 08             	lea    0x8(%edx),%eax
  801aad:	50                   	push   %eax
  801aae:	83 c2 04             	add    $0x4,%edx
  801ab1:	52                   	push   %edx
  801ab2:	e8 c0 f8 ff ff       	call   801377 <memmove>
		(*args->argc)--;
  801ab7:	8b 03                	mov    (%ebx),%eax
  801ab9:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801abc:	8b 43 08             	mov    0x8(%ebx),%eax
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ac5:	75 06                	jne    801acd <argnext+0x6b>
  801ac7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801acb:	74 0e                	je     801adb <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801acd:	8b 53 08             	mov    0x8(%ebx),%edx
  801ad0:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801ad3:	83 c2 01             	add    $0x1,%edx
  801ad6:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801ad9:	eb 13                	jmp    801aee <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801adb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801ae2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ae7:	eb 05                	jmp    801aee <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801ae9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801aee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	53                   	push   %ebx
  801af7:	83 ec 04             	sub    $0x4,%esp
  801afa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801afd:	8b 43 08             	mov    0x8(%ebx),%eax
  801b00:	85 c0                	test   %eax,%eax
  801b02:	74 58                	je     801b5c <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b04:	80 38 00             	cmpb   $0x0,(%eax)
  801b07:	74 0c                	je     801b15 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b09:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b0c:	c7 43 08 41 32 80 00 	movl   $0x803241,0x8(%ebx)
  801b13:	eb 42                	jmp    801b57 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b15:	8b 13                	mov    (%ebx),%edx
  801b17:	83 3a 01             	cmpl   $0x1,(%edx)
  801b1a:	7e 2d                	jle    801b49 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b1c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b1f:	8b 48 04             	mov    0x4(%eax),%ecx
  801b22:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b25:	83 ec 04             	sub    $0x4,%esp
  801b28:	8b 12                	mov    (%edx),%edx
  801b2a:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b31:	52                   	push   %edx
  801b32:	8d 50 08             	lea    0x8(%eax),%edx
  801b35:	52                   	push   %edx
  801b36:	83 c0 04             	add    $0x4,%eax
  801b39:	50                   	push   %eax
  801b3a:	e8 38 f8 ff ff       	call   801377 <memmove>
		(*args->argc)--;
  801b3f:	8b 03                	mov    (%ebx),%eax
  801b41:	83 28 01             	subl   $0x1,(%eax)
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	eb 0e                	jmp    801b57 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801b49:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b50:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801b57:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b5a:	eb 05                	jmp    801b61 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801b5c:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801b61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 08             	sub    $0x8,%esp
  801b6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801b6f:	8b 51 0c             	mov    0xc(%ecx),%edx
  801b72:	89 d0                	mov    %edx,%eax
  801b74:	85 d2                	test   %edx,%edx
  801b76:	75 0c                	jne    801b84 <argvalue+0x1e>
  801b78:	83 ec 0c             	sub    $0xc,%esp
  801b7b:	51                   	push   %ecx
  801b7c:	e8 72 ff ff ff       	call   801af3 <argnextvalue>
  801b81:	83 c4 10             	add    $0x10,%esp
}
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801b89:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8c:	05 00 00 00 30       	add    $0x30000000,%eax
  801b91:	c1 e8 0c             	shr    $0xc,%eax
}
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801b99:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9c:	05 00 00 00 30       	add    $0x30000000,%eax
  801ba1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801ba6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801bb8:	89 c2                	mov    %eax,%edx
  801bba:	c1 ea 16             	shr    $0x16,%edx
  801bbd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bc4:	f6 c2 01             	test   $0x1,%dl
  801bc7:	74 11                	je     801bda <fd_alloc+0x2d>
  801bc9:	89 c2                	mov    %eax,%edx
  801bcb:	c1 ea 0c             	shr    $0xc,%edx
  801bce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bd5:	f6 c2 01             	test   $0x1,%dl
  801bd8:	75 09                	jne    801be3 <fd_alloc+0x36>
			*fd_store = fd;
  801bda:	89 01                	mov    %eax,(%ecx)
			return 0;
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801be1:	eb 17                	jmp    801bfa <fd_alloc+0x4d>
  801be3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801be8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801bed:	75 c9                	jne    801bb8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801bef:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801bf5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c02:	83 f8 1f             	cmp    $0x1f,%eax
  801c05:	77 36                	ja     801c3d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c07:	c1 e0 0c             	shl    $0xc,%eax
  801c0a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c0f:	89 c2                	mov    %eax,%edx
  801c11:	c1 ea 16             	shr    $0x16,%edx
  801c14:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c1b:	f6 c2 01             	test   $0x1,%dl
  801c1e:	74 24                	je     801c44 <fd_lookup+0x48>
  801c20:	89 c2                	mov    %eax,%edx
  801c22:	c1 ea 0c             	shr    $0xc,%edx
  801c25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c2c:	f6 c2 01             	test   $0x1,%dl
  801c2f:	74 1a                	je     801c4b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c31:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c34:	89 02                	mov    %eax,(%edx)
	return 0;
  801c36:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3b:	eb 13                	jmp    801c50 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c42:	eb 0c                	jmp    801c50 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c49:	eb 05                	jmp    801c50 <fd_lookup+0x54>
  801c4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5b:	ba 80 38 80 00       	mov    $0x803880,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801c60:	eb 13                	jmp    801c75 <dev_lookup+0x23>
  801c62:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801c65:	39 08                	cmp    %ecx,(%eax)
  801c67:	75 0c                	jne    801c75 <dev_lookup+0x23>
			*dev = devtab[i];
  801c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6c:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c73:	eb 2e                	jmp    801ca3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c75:	8b 02                	mov    (%edx),%eax
  801c77:	85 c0                	test   %eax,%eax
  801c79:	75 e7                	jne    801c62 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801c7b:	a1 24 54 80 00       	mov    0x805424,%eax
  801c80:	8b 40 48             	mov    0x48(%eax),%eax
  801c83:	83 ec 04             	sub    $0x4,%esp
  801c86:	51                   	push   %ecx
  801c87:	50                   	push   %eax
  801c88:	68 04 38 80 00       	push   $0x803804
  801c8d:	e8 5c ee ff ff       	call   800aee <cprintf>
	*dev = 0;
  801c92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c95:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	56                   	push   %esi
  801ca9:	53                   	push   %ebx
  801caa:	83 ec 10             	sub    $0x10,%esp
  801cad:	8b 75 08             	mov    0x8(%ebp),%esi
  801cb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801cb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb6:	50                   	push   %eax
  801cb7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801cbd:	c1 e8 0c             	shr    $0xc,%eax
  801cc0:	50                   	push   %eax
  801cc1:	e8 36 ff ff ff       	call   801bfc <fd_lookup>
  801cc6:	83 c4 08             	add    $0x8,%esp
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 05                	js     801cd2 <fd_close+0x2d>
	    || fd != fd2)
  801ccd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801cd0:	74 0c                	je     801cde <fd_close+0x39>
		return (must_exist ? r : 0);
  801cd2:	84 db                	test   %bl,%bl
  801cd4:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd9:	0f 44 c2             	cmove  %edx,%eax
  801cdc:	eb 41                	jmp    801d1f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801cde:	83 ec 08             	sub    $0x8,%esp
  801ce1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce4:	50                   	push   %eax
  801ce5:	ff 36                	pushl  (%esi)
  801ce7:	e8 66 ff ff ff       	call   801c52 <dev_lookup>
  801cec:	89 c3                	mov    %eax,%ebx
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	78 1a                	js     801d0f <fd_close+0x6a>
		if (dev->dev_close)
  801cf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d00:	85 c0                	test   %eax,%eax
  801d02:	74 0b                	je     801d0f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	56                   	push   %esi
  801d08:	ff d0                	call   *%eax
  801d0a:	89 c3                	mov    %eax,%ebx
  801d0c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d0f:	83 ec 08             	sub    $0x8,%esp
  801d12:	56                   	push   %esi
  801d13:	6a 00                	push   $0x0
  801d15:	e8 53 f9 ff ff       	call   80166d <sys_page_unmap>
	return r;
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	89 d8                	mov    %ebx,%eax
}
  801d1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5e                   	pop    %esi
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    

00801d26 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2f:	50                   	push   %eax
  801d30:	ff 75 08             	pushl  0x8(%ebp)
  801d33:	e8 c4 fe ff ff       	call   801bfc <fd_lookup>
  801d38:	83 c4 08             	add    $0x8,%esp
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	78 10                	js     801d4f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801d3f:	83 ec 08             	sub    $0x8,%esp
  801d42:	6a 01                	push   $0x1
  801d44:	ff 75 f4             	pushl  -0xc(%ebp)
  801d47:	e8 59 ff ff ff       	call   801ca5 <fd_close>
  801d4c:	83 c4 10             	add    $0x10,%esp
}
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <close_all>:

void
close_all(void)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	53                   	push   %ebx
  801d55:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d58:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801d5d:	83 ec 0c             	sub    $0xc,%esp
  801d60:	53                   	push   %ebx
  801d61:	e8 c0 ff ff ff       	call   801d26 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d66:	83 c3 01             	add    $0x1,%ebx
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	83 fb 20             	cmp    $0x20,%ebx
  801d6f:	75 ec                	jne    801d5d <close_all+0xc>
		close(i);
}
  801d71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d74:	c9                   	leave  
  801d75:	c3                   	ret    

00801d76 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	57                   	push   %edi
  801d7a:	56                   	push   %esi
  801d7b:	53                   	push   %ebx
  801d7c:	83 ec 2c             	sub    $0x2c,%esp
  801d7f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801d82:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d85:	50                   	push   %eax
  801d86:	ff 75 08             	pushl  0x8(%ebp)
  801d89:	e8 6e fe ff ff       	call   801bfc <fd_lookup>
  801d8e:	83 c4 08             	add    $0x8,%esp
  801d91:	85 c0                	test   %eax,%eax
  801d93:	0f 88 c1 00 00 00    	js     801e5a <dup+0xe4>
		return r;
	close(newfdnum);
  801d99:	83 ec 0c             	sub    $0xc,%esp
  801d9c:	56                   	push   %esi
  801d9d:	e8 84 ff ff ff       	call   801d26 <close>

	newfd = INDEX2FD(newfdnum);
  801da2:	89 f3                	mov    %esi,%ebx
  801da4:	c1 e3 0c             	shl    $0xc,%ebx
  801da7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801dad:	83 c4 04             	add    $0x4,%esp
  801db0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801db3:	e8 de fd ff ff       	call   801b96 <fd2data>
  801db8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801dba:	89 1c 24             	mov    %ebx,(%esp)
  801dbd:	e8 d4 fd ff ff       	call   801b96 <fd2data>
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801dc8:	89 f8                	mov    %edi,%eax
  801dca:	c1 e8 16             	shr    $0x16,%eax
  801dcd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801dd4:	a8 01                	test   $0x1,%al
  801dd6:	74 37                	je     801e0f <dup+0x99>
  801dd8:	89 f8                	mov    %edi,%eax
  801dda:	c1 e8 0c             	shr    $0xc,%eax
  801ddd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801de4:	f6 c2 01             	test   $0x1,%dl
  801de7:	74 26                	je     801e0f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801de9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801df0:	83 ec 0c             	sub    $0xc,%esp
  801df3:	25 07 0e 00 00       	and    $0xe07,%eax
  801df8:	50                   	push   %eax
  801df9:	ff 75 d4             	pushl  -0x2c(%ebp)
  801dfc:	6a 00                	push   $0x0
  801dfe:	57                   	push   %edi
  801dff:	6a 00                	push   $0x0
  801e01:	e8 25 f8 ff ff       	call   80162b <sys_page_map>
  801e06:	89 c7                	mov    %eax,%edi
  801e08:	83 c4 20             	add    $0x20,%esp
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	78 2e                	js     801e3d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e12:	89 d0                	mov    %edx,%eax
  801e14:	c1 e8 0c             	shr    $0xc,%eax
  801e17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e1e:	83 ec 0c             	sub    $0xc,%esp
  801e21:	25 07 0e 00 00       	and    $0xe07,%eax
  801e26:	50                   	push   %eax
  801e27:	53                   	push   %ebx
  801e28:	6a 00                	push   $0x0
  801e2a:	52                   	push   %edx
  801e2b:	6a 00                	push   $0x0
  801e2d:	e8 f9 f7 ff ff       	call   80162b <sys_page_map>
  801e32:	89 c7                	mov    %eax,%edi
  801e34:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e37:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e39:	85 ff                	test   %edi,%edi
  801e3b:	79 1d                	jns    801e5a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	53                   	push   %ebx
  801e41:	6a 00                	push   $0x0
  801e43:	e8 25 f8 ff ff       	call   80166d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e48:	83 c4 08             	add    $0x8,%esp
  801e4b:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e4e:	6a 00                	push   $0x0
  801e50:	e8 18 f8 ff ff       	call   80166d <sys_page_unmap>
	return r;
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	89 f8                	mov    %edi,%eax
}
  801e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e5d:	5b                   	pop    %ebx
  801e5e:	5e                   	pop    %esi
  801e5f:	5f                   	pop    %edi
  801e60:	5d                   	pop    %ebp
  801e61:	c3                   	ret    

00801e62 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	53                   	push   %ebx
  801e66:	83 ec 14             	sub    $0x14,%esp
  801e69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e6f:	50                   	push   %eax
  801e70:	53                   	push   %ebx
  801e71:	e8 86 fd ff ff       	call   801bfc <fd_lookup>
  801e76:	83 c4 08             	add    $0x8,%esp
  801e79:	89 c2                	mov    %eax,%edx
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	78 6d                	js     801eec <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e7f:	83 ec 08             	sub    $0x8,%esp
  801e82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e85:	50                   	push   %eax
  801e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e89:	ff 30                	pushl  (%eax)
  801e8b:	e8 c2 fd ff ff       	call   801c52 <dev_lookup>
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	85 c0                	test   %eax,%eax
  801e95:	78 4c                	js     801ee3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801e97:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e9a:	8b 42 08             	mov    0x8(%edx),%eax
  801e9d:	83 e0 03             	and    $0x3,%eax
  801ea0:	83 f8 01             	cmp    $0x1,%eax
  801ea3:	75 21                	jne    801ec6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ea5:	a1 24 54 80 00       	mov    0x805424,%eax
  801eaa:	8b 40 48             	mov    0x48(%eax),%eax
  801ead:	83 ec 04             	sub    $0x4,%esp
  801eb0:	53                   	push   %ebx
  801eb1:	50                   	push   %eax
  801eb2:	68 45 38 80 00       	push   $0x803845
  801eb7:	e8 32 ec ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ec4:	eb 26                	jmp    801eec <read+0x8a>
	}
	if (!dev->dev_read)
  801ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec9:	8b 40 08             	mov    0x8(%eax),%eax
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	74 17                	je     801ee7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ed0:	83 ec 04             	sub    $0x4,%esp
  801ed3:	ff 75 10             	pushl  0x10(%ebp)
  801ed6:	ff 75 0c             	pushl  0xc(%ebp)
  801ed9:	52                   	push   %edx
  801eda:	ff d0                	call   *%eax
  801edc:	89 c2                	mov    %eax,%edx
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	eb 09                	jmp    801eec <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ee3:	89 c2                	mov    %eax,%edx
  801ee5:	eb 05                	jmp    801eec <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801ee7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801eec:	89 d0                	mov    %edx,%eax
  801eee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	57                   	push   %edi
  801ef7:	56                   	push   %esi
  801ef8:	53                   	push   %ebx
  801ef9:	83 ec 0c             	sub    $0xc,%esp
  801efc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eff:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f02:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f07:	eb 21                	jmp    801f2a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f09:	83 ec 04             	sub    $0x4,%esp
  801f0c:	89 f0                	mov    %esi,%eax
  801f0e:	29 d8                	sub    %ebx,%eax
  801f10:	50                   	push   %eax
  801f11:	89 d8                	mov    %ebx,%eax
  801f13:	03 45 0c             	add    0xc(%ebp),%eax
  801f16:	50                   	push   %eax
  801f17:	57                   	push   %edi
  801f18:	e8 45 ff ff ff       	call   801e62 <read>
		if (m < 0)
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 10                	js     801f34 <readn+0x41>
			return m;
		if (m == 0)
  801f24:	85 c0                	test   %eax,%eax
  801f26:	74 0a                	je     801f32 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f28:	01 c3                	add    %eax,%ebx
  801f2a:	39 f3                	cmp    %esi,%ebx
  801f2c:	72 db                	jb     801f09 <readn+0x16>
  801f2e:	89 d8                	mov    %ebx,%eax
  801f30:	eb 02                	jmp    801f34 <readn+0x41>
  801f32:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f37:	5b                   	pop    %ebx
  801f38:	5e                   	pop    %esi
  801f39:	5f                   	pop    %edi
  801f3a:	5d                   	pop    %ebp
  801f3b:	c3                   	ret    

00801f3c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	53                   	push   %ebx
  801f40:	83 ec 14             	sub    $0x14,%esp
  801f43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f49:	50                   	push   %eax
  801f4a:	53                   	push   %ebx
  801f4b:	e8 ac fc ff ff       	call   801bfc <fd_lookup>
  801f50:	83 c4 08             	add    $0x8,%esp
  801f53:	89 c2                	mov    %eax,%edx
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 68                	js     801fc1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f59:	83 ec 08             	sub    $0x8,%esp
  801f5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5f:	50                   	push   %eax
  801f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f63:	ff 30                	pushl  (%eax)
  801f65:	e8 e8 fc ff ff       	call   801c52 <dev_lookup>
  801f6a:	83 c4 10             	add    $0x10,%esp
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	78 47                	js     801fb8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f74:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801f78:	75 21                	jne    801f9b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801f7a:	a1 24 54 80 00       	mov    0x805424,%eax
  801f7f:	8b 40 48             	mov    0x48(%eax),%eax
  801f82:	83 ec 04             	sub    $0x4,%esp
  801f85:	53                   	push   %ebx
  801f86:	50                   	push   %eax
  801f87:	68 61 38 80 00       	push   $0x803861
  801f8c:	e8 5d eb ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801f91:	83 c4 10             	add    $0x10,%esp
  801f94:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f99:	eb 26                	jmp    801fc1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801f9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f9e:	8b 52 0c             	mov    0xc(%edx),%edx
  801fa1:	85 d2                	test   %edx,%edx
  801fa3:	74 17                	je     801fbc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801fa5:	83 ec 04             	sub    $0x4,%esp
  801fa8:	ff 75 10             	pushl  0x10(%ebp)
  801fab:	ff 75 0c             	pushl  0xc(%ebp)
  801fae:	50                   	push   %eax
  801faf:	ff d2                	call   *%edx
  801fb1:	89 c2                	mov    %eax,%edx
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	eb 09                	jmp    801fc1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fb8:	89 c2                	mov    %eax,%edx
  801fba:	eb 05                	jmp    801fc1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801fbc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801fc1:	89 d0                	mov    %edx,%eax
  801fc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <seek>:

int
seek(int fdnum, off_t offset)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fce:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801fd1:	50                   	push   %eax
  801fd2:	ff 75 08             	pushl  0x8(%ebp)
  801fd5:	e8 22 fc ff ff       	call   801bfc <fd_lookup>
  801fda:	83 c4 08             	add    $0x8,%esp
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	78 0e                	js     801fef <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801fe1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fe4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fe7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801fea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fef:	c9                   	leave  
  801ff0:	c3                   	ret    

00801ff1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	53                   	push   %ebx
  801ff5:	83 ec 14             	sub    $0x14,%esp
  801ff8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ffb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ffe:	50                   	push   %eax
  801fff:	53                   	push   %ebx
  802000:	e8 f7 fb ff ff       	call   801bfc <fd_lookup>
  802005:	83 c4 08             	add    $0x8,%esp
  802008:	89 c2                	mov    %eax,%edx
  80200a:	85 c0                	test   %eax,%eax
  80200c:	78 65                	js     802073 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80200e:	83 ec 08             	sub    $0x8,%esp
  802011:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802014:	50                   	push   %eax
  802015:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802018:	ff 30                	pushl  (%eax)
  80201a:	e8 33 fc ff ff       	call   801c52 <dev_lookup>
  80201f:	83 c4 10             	add    $0x10,%esp
  802022:	85 c0                	test   %eax,%eax
  802024:	78 44                	js     80206a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802026:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802029:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80202d:	75 21                	jne    802050 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80202f:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802034:	8b 40 48             	mov    0x48(%eax),%eax
  802037:	83 ec 04             	sub    $0x4,%esp
  80203a:	53                   	push   %ebx
  80203b:	50                   	push   %eax
  80203c:	68 24 38 80 00       	push   $0x803824
  802041:	e8 a8 ea ff ff       	call   800aee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80204e:	eb 23                	jmp    802073 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802050:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802053:	8b 52 18             	mov    0x18(%edx),%edx
  802056:	85 d2                	test   %edx,%edx
  802058:	74 14                	je     80206e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80205a:	83 ec 08             	sub    $0x8,%esp
  80205d:	ff 75 0c             	pushl  0xc(%ebp)
  802060:	50                   	push   %eax
  802061:	ff d2                	call   *%edx
  802063:	89 c2                	mov    %eax,%edx
  802065:	83 c4 10             	add    $0x10,%esp
  802068:	eb 09                	jmp    802073 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80206a:	89 c2                	mov    %eax,%edx
  80206c:	eb 05                	jmp    802073 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80206e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802073:	89 d0                	mov    %edx,%eax
  802075:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802078:	c9                   	leave  
  802079:	c3                   	ret    

0080207a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	53                   	push   %ebx
  80207e:	83 ec 14             	sub    $0x14,%esp
  802081:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802084:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802087:	50                   	push   %eax
  802088:	ff 75 08             	pushl  0x8(%ebp)
  80208b:	e8 6c fb ff ff       	call   801bfc <fd_lookup>
  802090:	83 c4 08             	add    $0x8,%esp
  802093:	89 c2                	mov    %eax,%edx
  802095:	85 c0                	test   %eax,%eax
  802097:	78 58                	js     8020f1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802099:	83 ec 08             	sub    $0x8,%esp
  80209c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209f:	50                   	push   %eax
  8020a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a3:	ff 30                	pushl  (%eax)
  8020a5:	e8 a8 fb ff ff       	call   801c52 <dev_lookup>
  8020aa:	83 c4 10             	add    $0x10,%esp
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	78 37                	js     8020e8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8020b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8020b8:	74 32                	je     8020ec <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8020ba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8020bd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8020c4:	00 00 00 
	stat->st_isdir = 0;
  8020c7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020ce:	00 00 00 
	stat->st_dev = dev;
  8020d1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8020d7:	83 ec 08             	sub    $0x8,%esp
  8020da:	53                   	push   %ebx
  8020db:	ff 75 f0             	pushl  -0x10(%ebp)
  8020de:	ff 50 14             	call   *0x14(%eax)
  8020e1:	89 c2                	mov    %eax,%edx
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	eb 09                	jmp    8020f1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020e8:	89 c2                	mov    %eax,%edx
  8020ea:	eb 05                	jmp    8020f1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8020ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8020f1:	89 d0                	mov    %edx,%eax
  8020f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020f6:	c9                   	leave  
  8020f7:	c3                   	ret    

008020f8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	56                   	push   %esi
  8020fc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8020fd:	83 ec 08             	sub    $0x8,%esp
  802100:	6a 00                	push   $0x0
  802102:	ff 75 08             	pushl  0x8(%ebp)
  802105:	e8 e3 01 00 00       	call   8022ed <open>
  80210a:	89 c3                	mov    %eax,%ebx
  80210c:	83 c4 10             	add    $0x10,%esp
  80210f:	85 c0                	test   %eax,%eax
  802111:	78 1b                	js     80212e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802113:	83 ec 08             	sub    $0x8,%esp
  802116:	ff 75 0c             	pushl  0xc(%ebp)
  802119:	50                   	push   %eax
  80211a:	e8 5b ff ff ff       	call   80207a <fstat>
  80211f:	89 c6                	mov    %eax,%esi
	close(fd);
  802121:	89 1c 24             	mov    %ebx,(%esp)
  802124:	e8 fd fb ff ff       	call   801d26 <close>
	return r;
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	89 f0                	mov    %esi,%eax
}
  80212e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802131:	5b                   	pop    %ebx
  802132:	5e                   	pop    %esi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    

00802135 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	56                   	push   %esi
  802139:	53                   	push   %ebx
  80213a:	89 c6                	mov    %eax,%esi
  80213c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80213e:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802145:	75 12                	jne    802159 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802147:	83 ec 0c             	sub    $0xc,%esp
  80214a:	6a 01                	push   $0x1
  80214c:	e8 c8 0d 00 00       	call   802f19 <ipc_find_env>
  802151:	a3 20 54 80 00       	mov    %eax,0x805420
  802156:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802159:	6a 07                	push   $0x7
  80215b:	68 00 60 80 00       	push   $0x806000
  802160:	56                   	push   %esi
  802161:	ff 35 20 54 80 00    	pushl  0x805420
  802167:	e8 59 0d 00 00       	call   802ec5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80216c:	83 c4 0c             	add    $0xc,%esp
  80216f:	6a 00                	push   $0x0
  802171:	53                   	push   %ebx
  802172:	6a 00                	push   $0x0
  802174:	e8 da 0c 00 00       	call   802e53 <ipc_recv>
}
  802179:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80217c:	5b                   	pop    %ebx
  80217d:	5e                   	pop    %esi
  80217e:	5d                   	pop    %ebp
  80217f:	c3                   	ret    

00802180 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802186:	8b 45 08             	mov    0x8(%ebp),%eax
  802189:	8b 40 0c             	mov    0xc(%eax),%eax
  80218c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802191:	8b 45 0c             	mov    0xc(%ebp),%eax
  802194:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802199:	ba 00 00 00 00       	mov    $0x0,%edx
  80219e:	b8 02 00 00 00       	mov    $0x2,%eax
  8021a3:	e8 8d ff ff ff       	call   802135 <fsipc>
}
  8021a8:	c9                   	leave  
  8021a9:	c3                   	ret    

008021aa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
  8021ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8021b6:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8021bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8021c0:	b8 06 00 00 00       	mov    $0x6,%eax
  8021c5:	e8 6b ff ff ff       	call   802135 <fsipc>
}
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	53                   	push   %ebx
  8021d0:	83 ec 04             	sub    $0x4,%esp
  8021d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8021d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8021dc:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8021e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8021e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8021eb:	e8 45 ff ff ff       	call   802135 <fsipc>
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	78 2c                	js     802220 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8021f4:	83 ec 08             	sub    $0x8,%esp
  8021f7:	68 00 60 80 00       	push   $0x806000
  8021fc:	53                   	push   %ebx
  8021fd:	e8 e3 ef ff ff       	call   8011e5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802202:	a1 80 60 80 00       	mov    0x806080,%eax
  802207:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80220d:	a1 84 60 80 00       	mov    0x806084,%eax
  802212:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802218:	83 c4 10             	add    $0x10,%esp
  80221b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802220:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802223:	c9                   	leave  
  802224:	c3                   	ret    

00802225 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	83 ec 0c             	sub    $0xc,%esp
  80222b:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80222e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802233:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802238:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80223b:	8b 55 08             	mov    0x8(%ebp),%edx
  80223e:	8b 52 0c             	mov    0xc(%edx),%edx
  802241:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  802247:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80224c:	50                   	push   %eax
  80224d:	ff 75 0c             	pushl  0xc(%ebp)
  802250:	68 08 60 80 00       	push   $0x806008
  802255:	e8 1d f1 ff ff       	call   801377 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  80225a:	ba 00 00 00 00       	mov    $0x0,%edx
  80225f:	b8 04 00 00 00       	mov    $0x4,%eax
  802264:	e8 cc fe ff ff       	call   802135 <fsipc>
}
  802269:	c9                   	leave  
  80226a:	c3                   	ret    

0080226b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80226b:	55                   	push   %ebp
  80226c:	89 e5                	mov    %esp,%ebp
  80226e:	56                   	push   %esi
  80226f:	53                   	push   %ebx
  802270:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802273:	8b 45 08             	mov    0x8(%ebp),%eax
  802276:	8b 40 0c             	mov    0xc(%eax),%eax
  802279:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80227e:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802284:	ba 00 00 00 00       	mov    $0x0,%edx
  802289:	b8 03 00 00 00       	mov    $0x3,%eax
  80228e:	e8 a2 fe ff ff       	call   802135 <fsipc>
  802293:	89 c3                	mov    %eax,%ebx
  802295:	85 c0                	test   %eax,%eax
  802297:	78 4b                	js     8022e4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 16                	jae    8022b3 <devfile_read+0x48>
  80229d:	68 90 38 80 00       	push   $0x803890
  8022a2:	68 6f 33 80 00       	push   $0x80336f
  8022a7:	6a 7c                	push   $0x7c
  8022a9:	68 97 38 80 00       	push   $0x803897
  8022ae:	e8 62 e7 ff ff       	call   800a15 <_panic>
	assert(r <= PGSIZE);
  8022b3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022b8:	7e 16                	jle    8022d0 <devfile_read+0x65>
  8022ba:	68 a2 38 80 00       	push   $0x8038a2
  8022bf:	68 6f 33 80 00       	push   $0x80336f
  8022c4:	6a 7d                	push   $0x7d
  8022c6:	68 97 38 80 00       	push   $0x803897
  8022cb:	e8 45 e7 ff ff       	call   800a15 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8022d0:	83 ec 04             	sub    $0x4,%esp
  8022d3:	50                   	push   %eax
  8022d4:	68 00 60 80 00       	push   $0x806000
  8022d9:	ff 75 0c             	pushl  0xc(%ebp)
  8022dc:	e8 96 f0 ff ff       	call   801377 <memmove>
	return r;
  8022e1:	83 c4 10             	add    $0x10,%esp
}
  8022e4:	89 d8                	mov    %ebx,%eax
  8022e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e9:	5b                   	pop    %ebx
  8022ea:	5e                   	pop    %esi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    

008022ed <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8022ed:	55                   	push   %ebp
  8022ee:	89 e5                	mov    %esp,%ebp
  8022f0:	53                   	push   %ebx
  8022f1:	83 ec 20             	sub    $0x20,%esp
  8022f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8022f7:	53                   	push   %ebx
  8022f8:	e8 af ee ff ff       	call   8011ac <strlen>
  8022fd:	83 c4 10             	add    $0x10,%esp
  802300:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802305:	7f 67                	jg     80236e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802307:	83 ec 0c             	sub    $0xc,%esp
  80230a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80230d:	50                   	push   %eax
  80230e:	e8 9a f8 ff ff       	call   801bad <fd_alloc>
  802313:	83 c4 10             	add    $0x10,%esp
		return r;
  802316:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802318:	85 c0                	test   %eax,%eax
  80231a:	78 57                	js     802373 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80231c:	83 ec 08             	sub    $0x8,%esp
  80231f:	53                   	push   %ebx
  802320:	68 00 60 80 00       	push   $0x806000
  802325:	e8 bb ee ff ff       	call   8011e5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80232a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80232d:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802332:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802335:	b8 01 00 00 00       	mov    $0x1,%eax
  80233a:	e8 f6 fd ff ff       	call   802135 <fsipc>
  80233f:	89 c3                	mov    %eax,%ebx
  802341:	83 c4 10             	add    $0x10,%esp
  802344:	85 c0                	test   %eax,%eax
  802346:	79 14                	jns    80235c <open+0x6f>
		fd_close(fd, 0);
  802348:	83 ec 08             	sub    $0x8,%esp
  80234b:	6a 00                	push   $0x0
  80234d:	ff 75 f4             	pushl  -0xc(%ebp)
  802350:	e8 50 f9 ff ff       	call   801ca5 <fd_close>
		return r;
  802355:	83 c4 10             	add    $0x10,%esp
  802358:	89 da                	mov    %ebx,%edx
  80235a:	eb 17                	jmp    802373 <open+0x86>
	}

	return fd2num(fd);
  80235c:	83 ec 0c             	sub    $0xc,%esp
  80235f:	ff 75 f4             	pushl  -0xc(%ebp)
  802362:	e8 1f f8 ff ff       	call   801b86 <fd2num>
  802367:	89 c2                	mov    %eax,%edx
  802369:	83 c4 10             	add    $0x10,%esp
  80236c:	eb 05                	jmp    802373 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80236e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802373:	89 d0                	mov    %edx,%eax
  802375:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802378:	c9                   	leave  
  802379:	c3                   	ret    

0080237a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80237a:	55                   	push   %ebp
  80237b:	89 e5                	mov    %esp,%ebp
  80237d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802380:	ba 00 00 00 00       	mov    $0x0,%edx
  802385:	b8 08 00 00 00       	mov    $0x8,%eax
  80238a:	e8 a6 fd ff ff       	call   802135 <fsipc>
}
  80238f:	c9                   	leave  
  802390:	c3                   	ret    

00802391 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802391:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802395:	7e 37                	jle    8023ce <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802397:	55                   	push   %ebp
  802398:	89 e5                	mov    %esp,%ebp
  80239a:	53                   	push   %ebx
  80239b:	83 ec 08             	sub    $0x8,%esp
  80239e:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8023a0:	ff 70 04             	pushl  0x4(%eax)
  8023a3:	8d 40 10             	lea    0x10(%eax),%eax
  8023a6:	50                   	push   %eax
  8023a7:	ff 33                	pushl  (%ebx)
  8023a9:	e8 8e fb ff ff       	call   801f3c <write>
		if (result > 0)
  8023ae:	83 c4 10             	add    $0x10,%esp
  8023b1:	85 c0                	test   %eax,%eax
  8023b3:	7e 03                	jle    8023b8 <writebuf+0x27>
			b->result += result;
  8023b5:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8023b8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023bb:	74 0d                	je     8023ca <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8023bd:	85 c0                	test   %eax,%eax
  8023bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8023c4:	0f 4f c2             	cmovg  %edx,%eax
  8023c7:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8023ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023cd:	c9                   	leave  
  8023ce:	f3 c3                	repz ret 

008023d0 <putch>:

static void
putch(int ch, void *thunk)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	53                   	push   %ebx
  8023d4:	83 ec 04             	sub    $0x4,%esp
  8023d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8023da:	8b 53 04             	mov    0x4(%ebx),%edx
  8023dd:	8d 42 01             	lea    0x1(%edx),%eax
  8023e0:	89 43 04             	mov    %eax,0x4(%ebx)
  8023e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023e6:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8023ea:	3d 00 01 00 00       	cmp    $0x100,%eax
  8023ef:	75 0e                	jne    8023ff <putch+0x2f>
		writebuf(b);
  8023f1:	89 d8                	mov    %ebx,%eax
  8023f3:	e8 99 ff ff ff       	call   802391 <writebuf>
		b->idx = 0;
  8023f8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8023ff:	83 c4 04             	add    $0x4,%esp
  802402:	5b                   	pop    %ebx
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    

00802405 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802405:	55                   	push   %ebp
  802406:	89 e5                	mov    %esp,%ebp
  802408:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80240e:	8b 45 08             	mov    0x8(%ebp),%eax
  802411:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802417:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80241e:	00 00 00 
	b.result = 0;
  802421:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802428:	00 00 00 
	b.error = 1;
  80242b:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802432:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802435:	ff 75 10             	pushl  0x10(%ebp)
  802438:	ff 75 0c             	pushl  0xc(%ebp)
  80243b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802441:	50                   	push   %eax
  802442:	68 d0 23 80 00       	push   $0x8023d0
  802447:	e8 9f e7 ff ff       	call   800beb <vprintfmt>
	if (b.idx > 0)
  80244c:	83 c4 10             	add    $0x10,%esp
  80244f:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802456:	7e 0b                	jle    802463 <vfprintf+0x5e>
		writebuf(&b);
  802458:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80245e:	e8 2e ff ff ff       	call   802391 <writebuf>

	return (b.result ? b.result : b.error);
  802463:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802469:	85 c0                	test   %eax,%eax
  80246b:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802472:	c9                   	leave  
  802473:	c3                   	ret    

00802474 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802474:	55                   	push   %ebp
  802475:	89 e5                	mov    %esp,%ebp
  802477:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80247a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80247d:	50                   	push   %eax
  80247e:	ff 75 0c             	pushl  0xc(%ebp)
  802481:	ff 75 08             	pushl  0x8(%ebp)
  802484:	e8 7c ff ff ff       	call   802405 <vfprintf>
	va_end(ap);

	return cnt;
}
  802489:	c9                   	leave  
  80248a:	c3                   	ret    

0080248b <printf>:

int
printf(const char *fmt, ...)
{
  80248b:	55                   	push   %ebp
  80248c:	89 e5                	mov    %esp,%ebp
  80248e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802491:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802494:	50                   	push   %eax
  802495:	ff 75 08             	pushl  0x8(%ebp)
  802498:	6a 01                	push   $0x1
  80249a:	e8 66 ff ff ff       	call   802405 <vfprintf>
	va_end(ap);

	return cnt;
}
  80249f:	c9                   	leave  
  8024a0:	c3                   	ret    

008024a1 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8024a1:	55                   	push   %ebp
  8024a2:	89 e5                	mov    %esp,%ebp
  8024a4:	57                   	push   %edi
  8024a5:	56                   	push   %esi
  8024a6:	53                   	push   %ebx
  8024a7:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8024ad:	6a 00                	push   $0x0
  8024af:	ff 75 08             	pushl  0x8(%ebp)
  8024b2:	e8 36 fe ff ff       	call   8022ed <open>
  8024b7:	89 c7                	mov    %eax,%edi
  8024b9:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8024bf:	83 c4 10             	add    $0x10,%esp
  8024c2:	85 c0                	test   %eax,%eax
  8024c4:	0f 88 96 04 00 00    	js     802960 <spawn+0x4bf>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8024ca:	83 ec 04             	sub    $0x4,%esp
  8024cd:	68 00 02 00 00       	push   $0x200
  8024d2:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8024d8:	50                   	push   %eax
  8024d9:	57                   	push   %edi
  8024da:	e8 14 fa ff ff       	call   801ef3 <readn>
  8024df:	83 c4 10             	add    $0x10,%esp
  8024e2:	3d 00 02 00 00       	cmp    $0x200,%eax
  8024e7:	75 0c                	jne    8024f5 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8024e9:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8024f0:	45 4c 46 
  8024f3:	74 33                	je     802528 <spawn+0x87>
		close(fd);
  8024f5:	83 ec 0c             	sub    $0xc,%esp
  8024f8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8024fe:	e8 23 f8 ff ff       	call   801d26 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802503:	83 c4 0c             	add    $0xc,%esp
  802506:	68 7f 45 4c 46       	push   $0x464c457f
  80250b:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802511:	68 ae 38 80 00       	push   $0x8038ae
  802516:	e8 d3 e5 ff ff       	call   800aee <cprintf>
		return -E_NOT_EXEC;
  80251b:	83 c4 10             	add    $0x10,%esp
  80251e:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  802523:	e9 98 04 00 00       	jmp    8029c0 <spawn+0x51f>
  802528:	b8 07 00 00 00       	mov    $0x7,%eax
  80252d:	cd 30                	int    $0x30
  80252f:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802535:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80253b:	85 c0                	test   %eax,%eax
  80253d:	0f 88 25 04 00 00    	js     802968 <spawn+0x4c7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802543:	89 c6                	mov    %eax,%esi
  802545:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80254b:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80254e:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802554:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80255a:	b9 11 00 00 00       	mov    $0x11,%ecx
  80255f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802561:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802567:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80256d:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802572:	be 00 00 00 00       	mov    $0x0,%esi
  802577:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80257a:	eb 13                	jmp    80258f <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80257c:	83 ec 0c             	sub    $0xc,%esp
  80257f:	50                   	push   %eax
  802580:	e8 27 ec ff ff       	call   8011ac <strlen>
  802585:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802589:	83 c3 01             	add    $0x1,%ebx
  80258c:	83 c4 10             	add    $0x10,%esp
  80258f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802596:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802599:	85 c0                	test   %eax,%eax
  80259b:	75 df                	jne    80257c <spawn+0xdb>
  80259d:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8025a3:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025a9:	bf 00 10 40 00       	mov    $0x401000,%edi
  8025ae:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8025b0:	89 fa                	mov    %edi,%edx
  8025b2:	83 e2 fc             	and    $0xfffffffc,%edx
  8025b5:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8025bc:	29 c2                	sub    %eax,%edx
  8025be:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8025c4:	8d 42 f8             	lea    -0x8(%edx),%eax
  8025c7:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8025cc:	0f 86 a6 03 00 00    	jbe    802978 <spawn+0x4d7>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8025d2:	83 ec 04             	sub    $0x4,%esp
  8025d5:	6a 07                	push   $0x7
  8025d7:	68 00 00 40 00       	push   $0x400000
  8025dc:	6a 00                	push   $0x0
  8025de:	e8 05 f0 ff ff       	call   8015e8 <sys_page_alloc>
  8025e3:	83 c4 10             	add    $0x10,%esp
  8025e6:	85 c0                	test   %eax,%eax
  8025e8:	0f 88 91 03 00 00    	js     80297f <spawn+0x4de>
  8025ee:	be 00 00 00 00       	mov    $0x0,%esi
  8025f3:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8025f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8025fc:	eb 30                	jmp    80262e <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8025fe:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802604:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80260a:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80260d:	83 ec 08             	sub    $0x8,%esp
  802610:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802613:	57                   	push   %edi
  802614:	e8 cc eb ff ff       	call   8011e5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802619:	83 c4 04             	add    $0x4,%esp
  80261c:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80261f:	e8 88 eb ff ff       	call   8011ac <strlen>
  802624:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802628:	83 c6 01             	add    $0x1,%esi
  80262b:	83 c4 10             	add    $0x10,%esp
  80262e:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802634:	7f c8                	jg     8025fe <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802636:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80263c:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802642:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802649:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80264f:	74 19                	je     80266a <spawn+0x1c9>
  802651:	68 24 39 80 00       	push   $0x803924
  802656:	68 6f 33 80 00       	push   $0x80336f
  80265b:	68 f1 00 00 00       	push   $0xf1
  802660:	68 c8 38 80 00       	push   $0x8038c8
  802665:	e8 ab e3 ff ff       	call   800a15 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80266a:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802670:	89 f8                	mov    %edi,%eax
  802672:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802677:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80267a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802680:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802683:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  802689:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80268f:	83 ec 0c             	sub    $0xc,%esp
  802692:	6a 07                	push   $0x7
  802694:	68 00 d0 bf ee       	push   $0xeebfd000
  802699:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80269f:	68 00 00 40 00       	push   $0x400000
  8026a4:	6a 00                	push   $0x0
  8026a6:	e8 80 ef ff ff       	call   80162b <sys_page_map>
  8026ab:	89 c3                	mov    %eax,%ebx
  8026ad:	83 c4 20             	add    $0x20,%esp
  8026b0:	85 c0                	test   %eax,%eax
  8026b2:	0f 88 f6 02 00 00    	js     8029ae <spawn+0x50d>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8026b8:	83 ec 08             	sub    $0x8,%esp
  8026bb:	68 00 00 40 00       	push   $0x400000
  8026c0:	6a 00                	push   $0x0
  8026c2:	e8 a6 ef ff ff       	call   80166d <sys_page_unmap>
  8026c7:	89 c3                	mov    %eax,%ebx
  8026c9:	83 c4 10             	add    $0x10,%esp
  8026cc:	85 c0                	test   %eax,%eax
  8026ce:	0f 88 da 02 00 00    	js     8029ae <spawn+0x50d>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8026d4:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8026da:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8026e1:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8026e7:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8026ee:	00 00 00 
  8026f1:	e9 88 01 00 00       	jmp    80287e <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8026f6:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8026fc:	83 38 01             	cmpl   $0x1,(%eax)
  8026ff:	0f 85 6b 01 00 00    	jne    802870 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802705:	89 c2                	mov    %eax,%edx
  802707:	8b 40 18             	mov    0x18(%eax),%eax
  80270a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802710:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802713:	83 f8 01             	cmp    $0x1,%eax
  802716:	19 c0                	sbb    %eax,%eax
  802718:	83 e0 fe             	and    $0xfffffffe,%eax
  80271b:	83 c0 07             	add    $0x7,%eax
  80271e:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802724:	89 d0                	mov    %edx,%eax
  802726:	8b 7a 04             	mov    0x4(%edx),%edi
  802729:	89 fa                	mov    %edi,%edx
  80272b:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  802731:	8b 78 10             	mov    0x10(%eax),%edi
  802734:	8b 48 14             	mov    0x14(%eax),%ecx
  802737:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  80273d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802740:	89 f0                	mov    %esi,%eax
  802742:	25 ff 0f 00 00       	and    $0xfff,%eax
  802747:	74 14                	je     80275d <spawn+0x2bc>
		va -= i;
  802749:	29 c6                	sub    %eax,%esi
		memsz += i;
  80274b:	01 c1                	add    %eax,%ecx
  80274d:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		filesz += i;
  802753:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802755:	29 c2                	sub    %eax,%edx
  802757:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80275d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802762:	e9 f7 00 00 00       	jmp    80285e <spawn+0x3bd>
		if (i >= filesz) {
  802767:	39 df                	cmp    %ebx,%edi
  802769:	77 27                	ja     802792 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80276b:	83 ec 04             	sub    $0x4,%esp
  80276e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802774:	56                   	push   %esi
  802775:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80277b:	e8 68 ee ff ff       	call   8015e8 <sys_page_alloc>
  802780:	83 c4 10             	add    $0x10,%esp
  802783:	85 c0                	test   %eax,%eax
  802785:	0f 89 c7 00 00 00    	jns    802852 <spawn+0x3b1>
  80278b:	89 c3                	mov    %eax,%ebx
  80278d:	e9 fb 01 00 00       	jmp    80298d <spawn+0x4ec>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802792:	83 ec 04             	sub    $0x4,%esp
  802795:	6a 07                	push   $0x7
  802797:	68 00 00 40 00       	push   $0x400000
  80279c:	6a 00                	push   $0x0
  80279e:	e8 45 ee ff ff       	call   8015e8 <sys_page_alloc>
  8027a3:	83 c4 10             	add    $0x10,%esp
  8027a6:	85 c0                	test   %eax,%eax
  8027a8:	0f 88 d5 01 00 00    	js     802983 <spawn+0x4e2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8027ae:	83 ec 08             	sub    $0x8,%esp
  8027b1:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8027b7:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8027bd:	50                   	push   %eax
  8027be:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8027c4:	e8 ff f7 ff ff       	call   801fc8 <seek>
  8027c9:	83 c4 10             	add    $0x10,%esp
  8027cc:	85 c0                	test   %eax,%eax
  8027ce:	0f 88 b3 01 00 00    	js     802987 <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8027d4:	83 ec 04             	sub    $0x4,%esp
  8027d7:	89 f8                	mov    %edi,%eax
  8027d9:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8027df:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8027e4:	ba 00 10 00 00       	mov    $0x1000,%edx
  8027e9:	0f 47 c2             	cmova  %edx,%eax
  8027ec:	50                   	push   %eax
  8027ed:	68 00 00 40 00       	push   $0x400000
  8027f2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8027f8:	e8 f6 f6 ff ff       	call   801ef3 <readn>
  8027fd:	83 c4 10             	add    $0x10,%esp
  802800:	85 c0                	test   %eax,%eax
  802802:	0f 88 83 01 00 00    	js     80298b <spawn+0x4ea>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802808:	83 ec 0c             	sub    $0xc,%esp
  80280b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802811:	56                   	push   %esi
  802812:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802818:	68 00 00 40 00       	push   $0x400000
  80281d:	6a 00                	push   $0x0
  80281f:	e8 07 ee ff ff       	call   80162b <sys_page_map>
  802824:	83 c4 20             	add    $0x20,%esp
  802827:	85 c0                	test   %eax,%eax
  802829:	79 15                	jns    802840 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  80282b:	50                   	push   %eax
  80282c:	68 d4 38 80 00       	push   $0x8038d4
  802831:	68 24 01 00 00       	push   $0x124
  802836:	68 c8 38 80 00       	push   $0x8038c8
  80283b:	e8 d5 e1 ff ff       	call   800a15 <_panic>
			sys_page_unmap(0, UTEMP);
  802840:	83 ec 08             	sub    $0x8,%esp
  802843:	68 00 00 40 00       	push   $0x400000
  802848:	6a 00                	push   $0x0
  80284a:	e8 1e ee ff ff       	call   80166d <sys_page_unmap>
  80284f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802852:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802858:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80285e:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802864:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  80286a:	0f 87 f7 fe ff ff    	ja     802767 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802870:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802877:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80287e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802885:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80288b:	0f 8c 65 fe ff ff    	jl     8026f6 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802891:	83 ec 0c             	sub    $0xc,%esp
  802894:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80289a:	e8 87 f4 ff ff       	call   801d26 <close>
// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();
  80289f:	e8 06 ed ff ff       	call   8015aa <sys_getenvid>
  8028a4:	89 c6                	mov    %eax,%esi
  8028a6:	83 c4 10             	add    $0x10,%esp

	for (int i = 0; i < UTOP; i += PGSIZE) {
  8028a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028ae:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
		if ((uvpd[PDX(i)] & PTE_P) &&
  8028b4:	89 d8                	mov    %ebx,%eax
  8028b6:	c1 e8 16             	shr    $0x16,%eax
  8028b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8028c0:	a8 01                	test   $0x1,%al
  8028c2:	74 31                	je     8028f5 <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_P) &&
  8028c4:	89 d8                	mov    %ebx,%eax
  8028c6:	c1 e8 0c             	shr    $0xc,%eax
  8028c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
		if ((uvpd[PDX(i)] & PTE_P) &&
  8028d0:	f6 c2 01             	test   $0x1,%dl
  8028d3:	74 20                	je     8028f5 <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_P) &&
			(uvpt[PGNUM(i)] & PTE_SHARE))
  8028d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
		if ((uvpd[PDX(i)] & PTE_P) &&
			(uvpt[PGNUM(i)] & PTE_P) &&
  8028dc:	f6 c4 04             	test   $0x4,%ah
  8028df:	74 14                	je     8028f5 <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_SHARE))
			sys_page_map(curenvid, (void *)i,
  8028e1:	83 ec 0c             	sub    $0xc,%esp
  8028e4:	68 07 0e 00 00       	push   $0xe07
  8028e9:	53                   	push   %ebx
  8028ea:	57                   	push   %edi
  8028eb:	53                   	push   %ebx
  8028ec:	56                   	push   %esi
  8028ed:	e8 39 ed ff ff       	call   80162b <sys_page_map>
  8028f2:	83 c4 20             	add    $0x20,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
  8028f5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028fb:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802901:	75 b1                	jne    8028b4 <spawn+0x413>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802903:	83 ec 08             	sub    $0x8,%esp
  802906:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80290c:	50                   	push   %eax
  80290d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802913:	e8 d9 ed ff ff       	call   8016f1 <sys_env_set_trapframe>
  802918:	83 c4 10             	add    $0x10,%esp
  80291b:	85 c0                	test   %eax,%eax
  80291d:	79 15                	jns    802934 <spawn+0x493>
		panic("sys_env_set_trapframe: %e", r);
  80291f:	50                   	push   %eax
  802920:	68 f1 38 80 00       	push   $0x8038f1
  802925:	68 85 00 00 00       	push   $0x85
  80292a:	68 c8 38 80 00       	push   $0x8038c8
  80292f:	e8 e1 e0 ff ff       	call   800a15 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802934:	83 ec 08             	sub    $0x8,%esp
  802937:	6a 02                	push   $0x2
  802939:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80293f:	e8 6b ed ff ff       	call   8016af <sys_env_set_status>
  802944:	83 c4 10             	add    $0x10,%esp
  802947:	85 c0                	test   %eax,%eax
  802949:	79 25                	jns    802970 <spawn+0x4cf>
		panic("sys_env_set_status: %e", r);
  80294b:	50                   	push   %eax
  80294c:	68 0b 39 80 00       	push   $0x80390b
  802951:	68 88 00 00 00       	push   $0x88
  802956:	68 c8 38 80 00       	push   $0x8038c8
  80295b:	e8 b5 e0 ff ff       	call   800a15 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802960:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802966:	eb 58                	jmp    8029c0 <spawn+0x51f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802968:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80296e:	eb 50                	jmp    8029c0 <spawn+0x51f>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802970:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802976:	eb 48                	jmp    8029c0 <spawn+0x51f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802978:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80297d:	eb 41                	jmp    8029c0 <spawn+0x51f>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80297f:	89 c3                	mov    %eax,%ebx
  802981:	eb 3d                	jmp    8029c0 <spawn+0x51f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802983:	89 c3                	mov    %eax,%ebx
  802985:	eb 06                	jmp    80298d <spawn+0x4ec>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802987:	89 c3                	mov    %eax,%ebx
  802989:	eb 02                	jmp    80298d <spawn+0x4ec>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80298b:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  80298d:	83 ec 0c             	sub    $0xc,%esp
  802990:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802996:	e8 ce eb ff ff       	call   801569 <sys_env_destroy>
	close(fd);
  80299b:	83 c4 04             	add    $0x4,%esp
  80299e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8029a4:	e8 7d f3 ff ff       	call   801d26 <close>
	return r;
  8029a9:	83 c4 10             	add    $0x10,%esp
  8029ac:	eb 12                	jmp    8029c0 <spawn+0x51f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8029ae:	83 ec 08             	sub    $0x8,%esp
  8029b1:	68 00 00 40 00       	push   $0x400000
  8029b6:	6a 00                	push   $0x0
  8029b8:	e8 b0 ec ff ff       	call   80166d <sys_page_unmap>
  8029bd:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8029c0:	89 d8                	mov    %ebx,%eax
  8029c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029c5:	5b                   	pop    %ebx
  8029c6:	5e                   	pop    %esi
  8029c7:	5f                   	pop    %edi
  8029c8:	5d                   	pop    %ebp
  8029c9:	c3                   	ret    

008029ca <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8029ca:	55                   	push   %ebp
  8029cb:	89 e5                	mov    %esp,%ebp
  8029cd:	56                   	push   %esi
  8029ce:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029cf:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8029d2:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029d7:	eb 03                	jmp    8029dc <spawnl+0x12>
		argc++;
  8029d9:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029dc:	83 c2 04             	add    $0x4,%edx
  8029df:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8029e3:	75 f4                	jne    8029d9 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8029e5:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8029ec:	83 e2 f0             	and    $0xfffffff0,%edx
  8029ef:	29 d4                	sub    %edx,%esp
  8029f1:	8d 54 24 03          	lea    0x3(%esp),%edx
  8029f5:	c1 ea 02             	shr    $0x2,%edx
  8029f8:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8029ff:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a04:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a0b:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a12:	00 
  802a13:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a15:	b8 00 00 00 00       	mov    $0x0,%eax
  802a1a:	eb 0a                	jmp    802a26 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802a1c:	83 c0 01             	add    $0x1,%eax
  802a1f:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802a23:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a26:	39 d0                	cmp    %edx,%eax
  802a28:	75 f2                	jne    802a1c <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802a2a:	83 ec 08             	sub    $0x8,%esp
  802a2d:	56                   	push   %esi
  802a2e:	ff 75 08             	pushl  0x8(%ebp)
  802a31:	e8 6b fa ff ff       	call   8024a1 <spawn>
}
  802a36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a39:	5b                   	pop    %ebx
  802a3a:	5e                   	pop    %esi
  802a3b:	5d                   	pop    %ebp
  802a3c:	c3                   	ret    

00802a3d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802a3d:	55                   	push   %ebp
  802a3e:	89 e5                	mov    %esp,%ebp
  802a40:	56                   	push   %esi
  802a41:	53                   	push   %ebx
  802a42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802a45:	83 ec 0c             	sub    $0xc,%esp
  802a48:	ff 75 08             	pushl  0x8(%ebp)
  802a4b:	e8 46 f1 ff ff       	call   801b96 <fd2data>
  802a50:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802a52:	83 c4 08             	add    $0x8,%esp
  802a55:	68 4c 39 80 00       	push   $0x80394c
  802a5a:	53                   	push   %ebx
  802a5b:	e8 85 e7 ff ff       	call   8011e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802a60:	8b 46 04             	mov    0x4(%esi),%eax
  802a63:	2b 06                	sub    (%esi),%eax
  802a65:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802a6b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802a72:	00 00 00 
	stat->st_dev = &devpipe;
  802a75:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802a7c:	40 80 00 
	return 0;
}
  802a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  802a84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a87:	5b                   	pop    %ebx
  802a88:	5e                   	pop    %esi
  802a89:	5d                   	pop    %ebp
  802a8a:	c3                   	ret    

00802a8b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802a8b:	55                   	push   %ebp
  802a8c:	89 e5                	mov    %esp,%ebp
  802a8e:	53                   	push   %ebx
  802a8f:	83 ec 0c             	sub    $0xc,%esp
  802a92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802a95:	53                   	push   %ebx
  802a96:	6a 00                	push   $0x0
  802a98:	e8 d0 eb ff ff       	call   80166d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802a9d:	89 1c 24             	mov    %ebx,(%esp)
  802aa0:	e8 f1 f0 ff ff       	call   801b96 <fd2data>
  802aa5:	83 c4 08             	add    $0x8,%esp
  802aa8:	50                   	push   %eax
  802aa9:	6a 00                	push   $0x0
  802aab:	e8 bd eb ff ff       	call   80166d <sys_page_unmap>
}
  802ab0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ab3:	c9                   	leave  
  802ab4:	c3                   	ret    

00802ab5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802ab5:	55                   	push   %ebp
  802ab6:	89 e5                	mov    %esp,%ebp
  802ab8:	57                   	push   %edi
  802ab9:	56                   	push   %esi
  802aba:	53                   	push   %ebx
  802abb:	83 ec 1c             	sub    $0x1c,%esp
  802abe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802ac1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802ac3:	a1 24 54 80 00       	mov    0x805424,%eax
  802ac8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802acb:	83 ec 0c             	sub    $0xc,%esp
  802ace:	ff 75 e0             	pushl  -0x20(%ebp)
  802ad1:	e8 7c 04 00 00       	call   802f52 <pageref>
  802ad6:	89 c3                	mov    %eax,%ebx
  802ad8:	89 3c 24             	mov    %edi,(%esp)
  802adb:	e8 72 04 00 00       	call   802f52 <pageref>
  802ae0:	83 c4 10             	add    $0x10,%esp
  802ae3:	39 c3                	cmp    %eax,%ebx
  802ae5:	0f 94 c1             	sete   %cl
  802ae8:	0f b6 c9             	movzbl %cl,%ecx
  802aeb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802aee:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802af4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802af7:	39 ce                	cmp    %ecx,%esi
  802af9:	74 1b                	je     802b16 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802afb:	39 c3                	cmp    %eax,%ebx
  802afd:	75 c4                	jne    802ac3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802aff:	8b 42 58             	mov    0x58(%edx),%eax
  802b02:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b05:	50                   	push   %eax
  802b06:	56                   	push   %esi
  802b07:	68 53 39 80 00       	push   $0x803953
  802b0c:	e8 dd df ff ff       	call   800aee <cprintf>
  802b11:	83 c4 10             	add    $0x10,%esp
  802b14:	eb ad                	jmp    802ac3 <_pipeisclosed+0xe>
	}
}
  802b16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b1c:	5b                   	pop    %ebx
  802b1d:	5e                   	pop    %esi
  802b1e:	5f                   	pop    %edi
  802b1f:	5d                   	pop    %ebp
  802b20:	c3                   	ret    

00802b21 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b21:	55                   	push   %ebp
  802b22:	89 e5                	mov    %esp,%ebp
  802b24:	57                   	push   %edi
  802b25:	56                   	push   %esi
  802b26:	53                   	push   %ebx
  802b27:	83 ec 28             	sub    $0x28,%esp
  802b2a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802b2d:	56                   	push   %esi
  802b2e:	e8 63 f0 ff ff       	call   801b96 <fd2data>
  802b33:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b35:	83 c4 10             	add    $0x10,%esp
  802b38:	bf 00 00 00 00       	mov    $0x0,%edi
  802b3d:	eb 4b                	jmp    802b8a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802b3f:	89 da                	mov    %ebx,%edx
  802b41:	89 f0                	mov    %esi,%eax
  802b43:	e8 6d ff ff ff       	call   802ab5 <_pipeisclosed>
  802b48:	85 c0                	test   %eax,%eax
  802b4a:	75 48                	jne    802b94 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802b4c:	e8 78 ea ff ff       	call   8015c9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802b51:	8b 43 04             	mov    0x4(%ebx),%eax
  802b54:	8b 0b                	mov    (%ebx),%ecx
  802b56:	8d 51 20             	lea    0x20(%ecx),%edx
  802b59:	39 d0                	cmp    %edx,%eax
  802b5b:	73 e2                	jae    802b3f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802b5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b60:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802b64:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802b67:	89 c2                	mov    %eax,%edx
  802b69:	c1 fa 1f             	sar    $0x1f,%edx
  802b6c:	89 d1                	mov    %edx,%ecx
  802b6e:	c1 e9 1b             	shr    $0x1b,%ecx
  802b71:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802b74:	83 e2 1f             	and    $0x1f,%edx
  802b77:	29 ca                	sub    %ecx,%edx
  802b79:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802b7d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802b81:	83 c0 01             	add    $0x1,%eax
  802b84:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b87:	83 c7 01             	add    $0x1,%edi
  802b8a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802b8d:	75 c2                	jne    802b51 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802b8f:	8b 45 10             	mov    0x10(%ebp),%eax
  802b92:	eb 05                	jmp    802b99 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b94:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b9c:	5b                   	pop    %ebx
  802b9d:	5e                   	pop    %esi
  802b9e:	5f                   	pop    %edi
  802b9f:	5d                   	pop    %ebp
  802ba0:	c3                   	ret    

00802ba1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802ba1:	55                   	push   %ebp
  802ba2:	89 e5                	mov    %esp,%ebp
  802ba4:	57                   	push   %edi
  802ba5:	56                   	push   %esi
  802ba6:	53                   	push   %ebx
  802ba7:	83 ec 18             	sub    $0x18,%esp
  802baa:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802bad:	57                   	push   %edi
  802bae:	e8 e3 ef ff ff       	call   801b96 <fd2data>
  802bb3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bb5:	83 c4 10             	add    $0x10,%esp
  802bb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  802bbd:	eb 3d                	jmp    802bfc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802bbf:	85 db                	test   %ebx,%ebx
  802bc1:	74 04                	je     802bc7 <devpipe_read+0x26>
				return i;
  802bc3:	89 d8                	mov    %ebx,%eax
  802bc5:	eb 44                	jmp    802c0b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802bc7:	89 f2                	mov    %esi,%edx
  802bc9:	89 f8                	mov    %edi,%eax
  802bcb:	e8 e5 fe ff ff       	call   802ab5 <_pipeisclosed>
  802bd0:	85 c0                	test   %eax,%eax
  802bd2:	75 32                	jne    802c06 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802bd4:	e8 f0 e9 ff ff       	call   8015c9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802bd9:	8b 06                	mov    (%esi),%eax
  802bdb:	3b 46 04             	cmp    0x4(%esi),%eax
  802bde:	74 df                	je     802bbf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802be0:	99                   	cltd   
  802be1:	c1 ea 1b             	shr    $0x1b,%edx
  802be4:	01 d0                	add    %edx,%eax
  802be6:	83 e0 1f             	and    $0x1f,%eax
  802be9:	29 d0                	sub    %edx,%eax
  802beb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bf3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802bf6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bf9:	83 c3 01             	add    $0x1,%ebx
  802bfc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802bff:	75 d8                	jne    802bd9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c01:	8b 45 10             	mov    0x10(%ebp),%eax
  802c04:	eb 05                	jmp    802c0b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c06:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c0e:	5b                   	pop    %ebx
  802c0f:	5e                   	pop    %esi
  802c10:	5f                   	pop    %edi
  802c11:	5d                   	pop    %ebp
  802c12:	c3                   	ret    

00802c13 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c13:	55                   	push   %ebp
  802c14:	89 e5                	mov    %esp,%ebp
  802c16:	56                   	push   %esi
  802c17:	53                   	push   %ebx
  802c18:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c1e:	50                   	push   %eax
  802c1f:	e8 89 ef ff ff       	call   801bad <fd_alloc>
  802c24:	83 c4 10             	add    $0x10,%esp
  802c27:	89 c2                	mov    %eax,%edx
  802c29:	85 c0                	test   %eax,%eax
  802c2b:	0f 88 2c 01 00 00    	js     802d5d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c31:	83 ec 04             	sub    $0x4,%esp
  802c34:	68 07 04 00 00       	push   $0x407
  802c39:	ff 75 f4             	pushl  -0xc(%ebp)
  802c3c:	6a 00                	push   $0x0
  802c3e:	e8 a5 e9 ff ff       	call   8015e8 <sys_page_alloc>
  802c43:	83 c4 10             	add    $0x10,%esp
  802c46:	89 c2                	mov    %eax,%edx
  802c48:	85 c0                	test   %eax,%eax
  802c4a:	0f 88 0d 01 00 00    	js     802d5d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802c50:	83 ec 0c             	sub    $0xc,%esp
  802c53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c56:	50                   	push   %eax
  802c57:	e8 51 ef ff ff       	call   801bad <fd_alloc>
  802c5c:	89 c3                	mov    %eax,%ebx
  802c5e:	83 c4 10             	add    $0x10,%esp
  802c61:	85 c0                	test   %eax,%eax
  802c63:	0f 88 e2 00 00 00    	js     802d4b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c69:	83 ec 04             	sub    $0x4,%esp
  802c6c:	68 07 04 00 00       	push   $0x407
  802c71:	ff 75 f0             	pushl  -0x10(%ebp)
  802c74:	6a 00                	push   $0x0
  802c76:	e8 6d e9 ff ff       	call   8015e8 <sys_page_alloc>
  802c7b:	89 c3                	mov    %eax,%ebx
  802c7d:	83 c4 10             	add    $0x10,%esp
  802c80:	85 c0                	test   %eax,%eax
  802c82:	0f 88 c3 00 00 00    	js     802d4b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802c88:	83 ec 0c             	sub    $0xc,%esp
  802c8b:	ff 75 f4             	pushl  -0xc(%ebp)
  802c8e:	e8 03 ef ff ff       	call   801b96 <fd2data>
  802c93:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c95:	83 c4 0c             	add    $0xc,%esp
  802c98:	68 07 04 00 00       	push   $0x407
  802c9d:	50                   	push   %eax
  802c9e:	6a 00                	push   $0x0
  802ca0:	e8 43 e9 ff ff       	call   8015e8 <sys_page_alloc>
  802ca5:	89 c3                	mov    %eax,%ebx
  802ca7:	83 c4 10             	add    $0x10,%esp
  802caa:	85 c0                	test   %eax,%eax
  802cac:	0f 88 89 00 00 00    	js     802d3b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cb2:	83 ec 0c             	sub    $0xc,%esp
  802cb5:	ff 75 f0             	pushl  -0x10(%ebp)
  802cb8:	e8 d9 ee ff ff       	call   801b96 <fd2data>
  802cbd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802cc4:	50                   	push   %eax
  802cc5:	6a 00                	push   $0x0
  802cc7:	56                   	push   %esi
  802cc8:	6a 00                	push   $0x0
  802cca:	e8 5c e9 ff ff       	call   80162b <sys_page_map>
  802ccf:	89 c3                	mov    %eax,%ebx
  802cd1:	83 c4 20             	add    $0x20,%esp
  802cd4:	85 c0                	test   %eax,%eax
  802cd6:	78 55                	js     802d2d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802cd8:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ce1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ce6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802ced:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cf6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802cf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cfb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d02:	83 ec 0c             	sub    $0xc,%esp
  802d05:	ff 75 f4             	pushl  -0xc(%ebp)
  802d08:	e8 79 ee ff ff       	call   801b86 <fd2num>
  802d0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d10:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d12:	83 c4 04             	add    $0x4,%esp
  802d15:	ff 75 f0             	pushl  -0x10(%ebp)
  802d18:	e8 69 ee ff ff       	call   801b86 <fd2num>
  802d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d20:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802d23:	83 c4 10             	add    $0x10,%esp
  802d26:	ba 00 00 00 00       	mov    $0x0,%edx
  802d2b:	eb 30                	jmp    802d5d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802d2d:	83 ec 08             	sub    $0x8,%esp
  802d30:	56                   	push   %esi
  802d31:	6a 00                	push   $0x0
  802d33:	e8 35 e9 ff ff       	call   80166d <sys_page_unmap>
  802d38:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802d3b:	83 ec 08             	sub    $0x8,%esp
  802d3e:	ff 75 f0             	pushl  -0x10(%ebp)
  802d41:	6a 00                	push   $0x0
  802d43:	e8 25 e9 ff ff       	call   80166d <sys_page_unmap>
  802d48:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802d4b:	83 ec 08             	sub    $0x8,%esp
  802d4e:	ff 75 f4             	pushl  -0xc(%ebp)
  802d51:	6a 00                	push   $0x0
  802d53:	e8 15 e9 ff ff       	call   80166d <sys_page_unmap>
  802d58:	83 c4 10             	add    $0x10,%esp
  802d5b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802d5d:	89 d0                	mov    %edx,%eax
  802d5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d62:	5b                   	pop    %ebx
  802d63:	5e                   	pop    %esi
  802d64:	5d                   	pop    %ebp
  802d65:	c3                   	ret    

00802d66 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802d66:	55                   	push   %ebp
  802d67:	89 e5                	mov    %esp,%ebp
  802d69:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d6f:	50                   	push   %eax
  802d70:	ff 75 08             	pushl  0x8(%ebp)
  802d73:	e8 84 ee ff ff       	call   801bfc <fd_lookup>
  802d78:	83 c4 10             	add    $0x10,%esp
  802d7b:	85 c0                	test   %eax,%eax
  802d7d:	78 18                	js     802d97 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802d7f:	83 ec 0c             	sub    $0xc,%esp
  802d82:	ff 75 f4             	pushl  -0xc(%ebp)
  802d85:	e8 0c ee ff ff       	call   801b96 <fd2data>
	return _pipeisclosed(fd, p);
  802d8a:	89 c2                	mov    %eax,%edx
  802d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d8f:	e8 21 fd ff ff       	call   802ab5 <_pipeisclosed>
  802d94:	83 c4 10             	add    $0x10,%esp
}
  802d97:	c9                   	leave  
  802d98:	c3                   	ret    

00802d99 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802d99:	55                   	push   %ebp
  802d9a:	89 e5                	mov    %esp,%ebp
  802d9c:	56                   	push   %esi
  802d9d:	53                   	push   %ebx
  802d9e:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802da1:	85 f6                	test   %esi,%esi
  802da3:	75 16                	jne    802dbb <wait+0x22>
  802da5:	68 6b 39 80 00       	push   $0x80396b
  802daa:	68 6f 33 80 00       	push   $0x80336f
  802daf:	6a 09                	push   $0x9
  802db1:	68 76 39 80 00       	push   $0x803976
  802db6:	e8 5a dc ff ff       	call   800a15 <_panic>
	e = &envs[ENVX(envid)];
  802dbb:	89 f3                	mov    %esi,%ebx
  802dbd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802dc3:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802dc6:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802dcc:	eb 05                	jmp    802dd3 <wait+0x3a>
		sys_yield();
  802dce:	e8 f6 e7 ff ff       	call   8015c9 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802dd3:	8b 43 48             	mov    0x48(%ebx),%eax
  802dd6:	39 c6                	cmp    %eax,%esi
  802dd8:	75 07                	jne    802de1 <wait+0x48>
  802dda:	8b 43 54             	mov    0x54(%ebx),%eax
  802ddd:	85 c0                	test   %eax,%eax
  802ddf:	75 ed                	jne    802dce <wait+0x35>
		sys_yield();
}
  802de1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802de4:	5b                   	pop    %ebx
  802de5:	5e                   	pop    %esi
  802de6:	5d                   	pop    %ebp
  802de7:	c3                   	ret    

00802de8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802de8:	55                   	push   %ebp
  802de9:	89 e5                	mov    %esp,%ebp
  802deb:	53                   	push   %ebx
  802dec:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802def:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802df6:	75 28                	jne    802e20 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  802df8:	e8 ad e7 ff ff       	call   8015aa <sys_getenvid>
  802dfd:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  802dff:	83 ec 04             	sub    $0x4,%esp
  802e02:	6a 07                	push   $0x7
  802e04:	68 00 f0 bf ee       	push   $0xeebff000
  802e09:	50                   	push   %eax
  802e0a:	e8 d9 e7 ff ff       	call   8015e8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  802e0f:	83 c4 08             	add    $0x8,%esp
  802e12:	68 2d 2e 80 00       	push   $0x802e2d
  802e17:	53                   	push   %ebx
  802e18:	e8 16 e9 ff ff       	call   801733 <sys_env_set_pgfault_upcall>
  802e1d:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802e20:	8b 45 08             	mov    0x8(%ebp),%eax
  802e23:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802e28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e2b:	c9                   	leave  
  802e2c:	c3                   	ret    

00802e2d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  802e2d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802e2e:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802e33:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802e35:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  802e38:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  802e3a:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  802e3e:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  802e42:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  802e43:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  802e45:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  802e4a:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  802e4b:	58                   	pop    %eax
	popal 				// pop utf_regs 
  802e4c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  802e4d:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  802e50:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  802e51:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802e52:	c3                   	ret    

00802e53 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802e53:	55                   	push   %ebp
  802e54:	89 e5                	mov    %esp,%ebp
  802e56:	56                   	push   %esi
  802e57:	53                   	push   %ebx
  802e58:	8b 75 08             	mov    0x8(%ebp),%esi
  802e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  802e61:	85 c0                	test   %eax,%eax
  802e63:	74 0e                	je     802e73 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  802e65:	83 ec 0c             	sub    $0xc,%esp
  802e68:	50                   	push   %eax
  802e69:	e8 2a e9 ff ff       	call   801798 <sys_ipc_recv>
  802e6e:	83 c4 10             	add    $0x10,%esp
  802e71:	eb 0d                	jmp    802e80 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  802e73:	83 ec 0c             	sub    $0xc,%esp
  802e76:	6a ff                	push   $0xffffffff
  802e78:	e8 1b e9 ff ff       	call   801798 <sys_ipc_recv>
  802e7d:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  802e80:	85 c0                	test   %eax,%eax
  802e82:	79 16                	jns    802e9a <ipc_recv+0x47>

		if (from_env_store != NULL)
  802e84:	85 f6                	test   %esi,%esi
  802e86:	74 06                	je     802e8e <ipc_recv+0x3b>
			*from_env_store = 0;
  802e88:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  802e8e:	85 db                	test   %ebx,%ebx
  802e90:	74 2c                	je     802ebe <ipc_recv+0x6b>
			*perm_store = 0;
  802e92:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802e98:	eb 24                	jmp    802ebe <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  802e9a:	85 f6                	test   %esi,%esi
  802e9c:	74 0a                	je     802ea8 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  802e9e:	a1 24 54 80 00       	mov    0x805424,%eax
  802ea3:	8b 40 74             	mov    0x74(%eax),%eax
  802ea6:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  802ea8:	85 db                	test   %ebx,%ebx
  802eaa:	74 0a                	je     802eb6 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  802eac:	a1 24 54 80 00       	mov    0x805424,%eax
  802eb1:	8b 40 78             	mov    0x78(%eax),%eax
  802eb4:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802eb6:	a1 24 54 80 00       	mov    0x805424,%eax
  802ebb:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802ebe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ec1:	5b                   	pop    %ebx
  802ec2:	5e                   	pop    %esi
  802ec3:	5d                   	pop    %ebp
  802ec4:	c3                   	ret    

00802ec5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802ec5:	55                   	push   %ebp
  802ec6:	89 e5                	mov    %esp,%ebp
  802ec8:	57                   	push   %edi
  802ec9:	56                   	push   %esi
  802eca:	53                   	push   %ebx
  802ecb:	83 ec 0c             	sub    $0xc,%esp
  802ece:	8b 7d 08             	mov    0x8(%ebp),%edi
  802ed1:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ed4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  802ed7:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  802ed9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802ede:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802ee1:	ff 75 14             	pushl  0x14(%ebp)
  802ee4:	53                   	push   %ebx
  802ee5:	56                   	push   %esi
  802ee6:	57                   	push   %edi
  802ee7:	e8 89 e8 ff ff       	call   801775 <sys_ipc_try_send>
		if (r >= 0)
  802eec:	83 c4 10             	add    $0x10,%esp
  802eef:	85 c0                	test   %eax,%eax
  802ef1:	79 1e                	jns    802f11 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  802ef3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802ef6:	74 12                	je     802f0a <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  802ef8:	50                   	push   %eax
  802ef9:	68 81 39 80 00       	push   $0x803981
  802efe:	6a 49                	push   $0x49
  802f00:	68 94 39 80 00       	push   $0x803994
  802f05:	e8 0b db ff ff       	call   800a15 <_panic>
	
		sys_yield();
  802f0a:	e8 ba e6 ff ff       	call   8015c9 <sys_yield>
	}
  802f0f:	eb d0                	jmp    802ee1 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802f11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f14:	5b                   	pop    %ebx
  802f15:	5e                   	pop    %esi
  802f16:	5f                   	pop    %edi
  802f17:	5d                   	pop    %ebp
  802f18:	c3                   	ret    

00802f19 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802f19:	55                   	push   %ebp
  802f1a:	89 e5                	mov    %esp,%ebp
  802f1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802f1f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802f24:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802f27:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802f2d:	8b 52 50             	mov    0x50(%edx),%edx
  802f30:	39 ca                	cmp    %ecx,%edx
  802f32:	75 0d                	jne    802f41 <ipc_find_env+0x28>
			return envs[i].env_id;
  802f34:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f37:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f3c:	8b 40 48             	mov    0x48(%eax),%eax
  802f3f:	eb 0f                	jmp    802f50 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802f41:	83 c0 01             	add    $0x1,%eax
  802f44:	3d 00 04 00 00       	cmp    $0x400,%eax
  802f49:	75 d9                	jne    802f24 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802f4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f50:	5d                   	pop    %ebp
  802f51:	c3                   	ret    

00802f52 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f52:	55                   	push   %ebp
  802f53:	89 e5                	mov    %esp,%ebp
  802f55:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f58:	89 d0                	mov    %edx,%eax
  802f5a:	c1 e8 16             	shr    $0x16,%eax
  802f5d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802f64:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f69:	f6 c1 01             	test   $0x1,%cl
  802f6c:	74 1d                	je     802f8b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802f6e:	c1 ea 0c             	shr    $0xc,%edx
  802f71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802f78:	f6 c2 01             	test   $0x1,%dl
  802f7b:	74 0e                	je     802f8b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802f7d:	c1 ea 0c             	shr    $0xc,%edx
  802f80:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802f87:	ef 
  802f88:	0f b7 c0             	movzwl %ax,%eax
}
  802f8b:	5d                   	pop    %ebp
  802f8c:	c3                   	ret    
  802f8d:	66 90                	xchg   %ax,%ax
  802f8f:	90                   	nop

00802f90 <__udivdi3>:
  802f90:	55                   	push   %ebp
  802f91:	57                   	push   %edi
  802f92:	56                   	push   %esi
  802f93:	53                   	push   %ebx
  802f94:	83 ec 1c             	sub    $0x1c,%esp
  802f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802fa7:	85 f6                	test   %esi,%esi
  802fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802fad:	89 ca                	mov    %ecx,%edx
  802faf:	89 f8                	mov    %edi,%eax
  802fb1:	75 3d                	jne    802ff0 <__udivdi3+0x60>
  802fb3:	39 cf                	cmp    %ecx,%edi
  802fb5:	0f 87 c5 00 00 00    	ja     803080 <__udivdi3+0xf0>
  802fbb:	85 ff                	test   %edi,%edi
  802fbd:	89 fd                	mov    %edi,%ebp
  802fbf:	75 0b                	jne    802fcc <__udivdi3+0x3c>
  802fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  802fc6:	31 d2                	xor    %edx,%edx
  802fc8:	f7 f7                	div    %edi
  802fca:	89 c5                	mov    %eax,%ebp
  802fcc:	89 c8                	mov    %ecx,%eax
  802fce:	31 d2                	xor    %edx,%edx
  802fd0:	f7 f5                	div    %ebp
  802fd2:	89 c1                	mov    %eax,%ecx
  802fd4:	89 d8                	mov    %ebx,%eax
  802fd6:	89 cf                	mov    %ecx,%edi
  802fd8:	f7 f5                	div    %ebp
  802fda:	89 c3                	mov    %eax,%ebx
  802fdc:	89 d8                	mov    %ebx,%eax
  802fde:	89 fa                	mov    %edi,%edx
  802fe0:	83 c4 1c             	add    $0x1c,%esp
  802fe3:	5b                   	pop    %ebx
  802fe4:	5e                   	pop    %esi
  802fe5:	5f                   	pop    %edi
  802fe6:	5d                   	pop    %ebp
  802fe7:	c3                   	ret    
  802fe8:	90                   	nop
  802fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ff0:	39 ce                	cmp    %ecx,%esi
  802ff2:	77 74                	ja     803068 <__udivdi3+0xd8>
  802ff4:	0f bd fe             	bsr    %esi,%edi
  802ff7:	83 f7 1f             	xor    $0x1f,%edi
  802ffa:	0f 84 98 00 00 00    	je     803098 <__udivdi3+0x108>
  803000:	bb 20 00 00 00       	mov    $0x20,%ebx
  803005:	89 f9                	mov    %edi,%ecx
  803007:	89 c5                	mov    %eax,%ebp
  803009:	29 fb                	sub    %edi,%ebx
  80300b:	d3 e6                	shl    %cl,%esi
  80300d:	89 d9                	mov    %ebx,%ecx
  80300f:	d3 ed                	shr    %cl,%ebp
  803011:	89 f9                	mov    %edi,%ecx
  803013:	d3 e0                	shl    %cl,%eax
  803015:	09 ee                	or     %ebp,%esi
  803017:	89 d9                	mov    %ebx,%ecx
  803019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80301d:	89 d5                	mov    %edx,%ebp
  80301f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803023:	d3 ed                	shr    %cl,%ebp
  803025:	89 f9                	mov    %edi,%ecx
  803027:	d3 e2                	shl    %cl,%edx
  803029:	89 d9                	mov    %ebx,%ecx
  80302b:	d3 e8                	shr    %cl,%eax
  80302d:	09 c2                	or     %eax,%edx
  80302f:	89 d0                	mov    %edx,%eax
  803031:	89 ea                	mov    %ebp,%edx
  803033:	f7 f6                	div    %esi
  803035:	89 d5                	mov    %edx,%ebp
  803037:	89 c3                	mov    %eax,%ebx
  803039:	f7 64 24 0c          	mull   0xc(%esp)
  80303d:	39 d5                	cmp    %edx,%ebp
  80303f:	72 10                	jb     803051 <__udivdi3+0xc1>
  803041:	8b 74 24 08          	mov    0x8(%esp),%esi
  803045:	89 f9                	mov    %edi,%ecx
  803047:	d3 e6                	shl    %cl,%esi
  803049:	39 c6                	cmp    %eax,%esi
  80304b:	73 07                	jae    803054 <__udivdi3+0xc4>
  80304d:	39 d5                	cmp    %edx,%ebp
  80304f:	75 03                	jne    803054 <__udivdi3+0xc4>
  803051:	83 eb 01             	sub    $0x1,%ebx
  803054:	31 ff                	xor    %edi,%edi
  803056:	89 d8                	mov    %ebx,%eax
  803058:	89 fa                	mov    %edi,%edx
  80305a:	83 c4 1c             	add    $0x1c,%esp
  80305d:	5b                   	pop    %ebx
  80305e:	5e                   	pop    %esi
  80305f:	5f                   	pop    %edi
  803060:	5d                   	pop    %ebp
  803061:	c3                   	ret    
  803062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803068:	31 ff                	xor    %edi,%edi
  80306a:	31 db                	xor    %ebx,%ebx
  80306c:	89 d8                	mov    %ebx,%eax
  80306e:	89 fa                	mov    %edi,%edx
  803070:	83 c4 1c             	add    $0x1c,%esp
  803073:	5b                   	pop    %ebx
  803074:	5e                   	pop    %esi
  803075:	5f                   	pop    %edi
  803076:	5d                   	pop    %ebp
  803077:	c3                   	ret    
  803078:	90                   	nop
  803079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803080:	89 d8                	mov    %ebx,%eax
  803082:	f7 f7                	div    %edi
  803084:	31 ff                	xor    %edi,%edi
  803086:	89 c3                	mov    %eax,%ebx
  803088:	89 d8                	mov    %ebx,%eax
  80308a:	89 fa                	mov    %edi,%edx
  80308c:	83 c4 1c             	add    $0x1c,%esp
  80308f:	5b                   	pop    %ebx
  803090:	5e                   	pop    %esi
  803091:	5f                   	pop    %edi
  803092:	5d                   	pop    %ebp
  803093:	c3                   	ret    
  803094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803098:	39 ce                	cmp    %ecx,%esi
  80309a:	72 0c                	jb     8030a8 <__udivdi3+0x118>
  80309c:	31 db                	xor    %ebx,%ebx
  80309e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8030a2:	0f 87 34 ff ff ff    	ja     802fdc <__udivdi3+0x4c>
  8030a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8030ad:	e9 2a ff ff ff       	jmp    802fdc <__udivdi3+0x4c>
  8030b2:	66 90                	xchg   %ax,%ax
  8030b4:	66 90                	xchg   %ax,%ax
  8030b6:	66 90                	xchg   %ax,%ax
  8030b8:	66 90                	xchg   %ax,%ax
  8030ba:	66 90                	xchg   %ax,%ax
  8030bc:	66 90                	xchg   %ax,%ax
  8030be:	66 90                	xchg   %ax,%ax

008030c0 <__umoddi3>:
  8030c0:	55                   	push   %ebp
  8030c1:	57                   	push   %edi
  8030c2:	56                   	push   %esi
  8030c3:	53                   	push   %ebx
  8030c4:	83 ec 1c             	sub    $0x1c,%esp
  8030c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8030cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8030cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8030d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8030d7:	85 d2                	test   %edx,%edx
  8030d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8030dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8030e1:	89 f3                	mov    %esi,%ebx
  8030e3:	89 3c 24             	mov    %edi,(%esp)
  8030e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8030ea:	75 1c                	jne    803108 <__umoddi3+0x48>
  8030ec:	39 f7                	cmp    %esi,%edi
  8030ee:	76 50                	jbe    803140 <__umoddi3+0x80>
  8030f0:	89 c8                	mov    %ecx,%eax
  8030f2:	89 f2                	mov    %esi,%edx
  8030f4:	f7 f7                	div    %edi
  8030f6:	89 d0                	mov    %edx,%eax
  8030f8:	31 d2                	xor    %edx,%edx
  8030fa:	83 c4 1c             	add    $0x1c,%esp
  8030fd:	5b                   	pop    %ebx
  8030fe:	5e                   	pop    %esi
  8030ff:	5f                   	pop    %edi
  803100:	5d                   	pop    %ebp
  803101:	c3                   	ret    
  803102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803108:	39 f2                	cmp    %esi,%edx
  80310a:	89 d0                	mov    %edx,%eax
  80310c:	77 52                	ja     803160 <__umoddi3+0xa0>
  80310e:	0f bd ea             	bsr    %edx,%ebp
  803111:	83 f5 1f             	xor    $0x1f,%ebp
  803114:	75 5a                	jne    803170 <__umoddi3+0xb0>
  803116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80311a:	0f 82 e0 00 00 00    	jb     803200 <__umoddi3+0x140>
  803120:	39 0c 24             	cmp    %ecx,(%esp)
  803123:	0f 86 d7 00 00 00    	jbe    803200 <__umoddi3+0x140>
  803129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80312d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803131:	83 c4 1c             	add    $0x1c,%esp
  803134:	5b                   	pop    %ebx
  803135:	5e                   	pop    %esi
  803136:	5f                   	pop    %edi
  803137:	5d                   	pop    %ebp
  803138:	c3                   	ret    
  803139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803140:	85 ff                	test   %edi,%edi
  803142:	89 fd                	mov    %edi,%ebp
  803144:	75 0b                	jne    803151 <__umoddi3+0x91>
  803146:	b8 01 00 00 00       	mov    $0x1,%eax
  80314b:	31 d2                	xor    %edx,%edx
  80314d:	f7 f7                	div    %edi
  80314f:	89 c5                	mov    %eax,%ebp
  803151:	89 f0                	mov    %esi,%eax
  803153:	31 d2                	xor    %edx,%edx
  803155:	f7 f5                	div    %ebp
  803157:	89 c8                	mov    %ecx,%eax
  803159:	f7 f5                	div    %ebp
  80315b:	89 d0                	mov    %edx,%eax
  80315d:	eb 99                	jmp    8030f8 <__umoddi3+0x38>
  80315f:	90                   	nop
  803160:	89 c8                	mov    %ecx,%eax
  803162:	89 f2                	mov    %esi,%edx
  803164:	83 c4 1c             	add    $0x1c,%esp
  803167:	5b                   	pop    %ebx
  803168:	5e                   	pop    %esi
  803169:	5f                   	pop    %edi
  80316a:	5d                   	pop    %ebp
  80316b:	c3                   	ret    
  80316c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803170:	8b 34 24             	mov    (%esp),%esi
  803173:	bf 20 00 00 00       	mov    $0x20,%edi
  803178:	89 e9                	mov    %ebp,%ecx
  80317a:	29 ef                	sub    %ebp,%edi
  80317c:	d3 e0                	shl    %cl,%eax
  80317e:	89 f9                	mov    %edi,%ecx
  803180:	89 f2                	mov    %esi,%edx
  803182:	d3 ea                	shr    %cl,%edx
  803184:	89 e9                	mov    %ebp,%ecx
  803186:	09 c2                	or     %eax,%edx
  803188:	89 d8                	mov    %ebx,%eax
  80318a:	89 14 24             	mov    %edx,(%esp)
  80318d:	89 f2                	mov    %esi,%edx
  80318f:	d3 e2                	shl    %cl,%edx
  803191:	89 f9                	mov    %edi,%ecx
  803193:	89 54 24 04          	mov    %edx,0x4(%esp)
  803197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80319b:	d3 e8                	shr    %cl,%eax
  80319d:	89 e9                	mov    %ebp,%ecx
  80319f:	89 c6                	mov    %eax,%esi
  8031a1:	d3 e3                	shl    %cl,%ebx
  8031a3:	89 f9                	mov    %edi,%ecx
  8031a5:	89 d0                	mov    %edx,%eax
  8031a7:	d3 e8                	shr    %cl,%eax
  8031a9:	89 e9                	mov    %ebp,%ecx
  8031ab:	09 d8                	or     %ebx,%eax
  8031ad:	89 d3                	mov    %edx,%ebx
  8031af:	89 f2                	mov    %esi,%edx
  8031b1:	f7 34 24             	divl   (%esp)
  8031b4:	89 d6                	mov    %edx,%esi
  8031b6:	d3 e3                	shl    %cl,%ebx
  8031b8:	f7 64 24 04          	mull   0x4(%esp)
  8031bc:	39 d6                	cmp    %edx,%esi
  8031be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8031c2:	89 d1                	mov    %edx,%ecx
  8031c4:	89 c3                	mov    %eax,%ebx
  8031c6:	72 08                	jb     8031d0 <__umoddi3+0x110>
  8031c8:	75 11                	jne    8031db <__umoddi3+0x11b>
  8031ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8031ce:	73 0b                	jae    8031db <__umoddi3+0x11b>
  8031d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8031d4:	1b 14 24             	sbb    (%esp),%edx
  8031d7:	89 d1                	mov    %edx,%ecx
  8031d9:	89 c3                	mov    %eax,%ebx
  8031db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8031df:	29 da                	sub    %ebx,%edx
  8031e1:	19 ce                	sbb    %ecx,%esi
  8031e3:	89 f9                	mov    %edi,%ecx
  8031e5:	89 f0                	mov    %esi,%eax
  8031e7:	d3 e0                	shl    %cl,%eax
  8031e9:	89 e9                	mov    %ebp,%ecx
  8031eb:	d3 ea                	shr    %cl,%edx
  8031ed:	89 e9                	mov    %ebp,%ecx
  8031ef:	d3 ee                	shr    %cl,%esi
  8031f1:	09 d0                	or     %edx,%eax
  8031f3:	89 f2                	mov    %esi,%edx
  8031f5:	83 c4 1c             	add    $0x1c,%esp
  8031f8:	5b                   	pop    %ebx
  8031f9:	5e                   	pop    %esi
  8031fa:	5f                   	pop    %edi
  8031fb:	5d                   	pop    %ebp
  8031fc:	c3                   	ret    
  8031fd:	8d 76 00             	lea    0x0(%esi),%esi
  803200:	29 f9                	sub    %edi,%ecx
  803202:	19 d6                	sbb    %edx,%esi
  803204:	89 74 24 04          	mov    %esi,0x4(%esp)
  803208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80320c:	e9 18 ff ff ff       	jmp    803129 <__umoddi3+0x69>
