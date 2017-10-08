
obj/user/testfile.debug：     文件格式 elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 1e 0d 00 00       	call   800d65 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 c6 13 00 00       	call   80141f <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 63 13 00 00       	call   8013cb <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 e0 12 00 00       	call   801359 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 20 24 80 00       	mov    $0x802420,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 2b 24 80 00       	push   $0x80242b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 45 24 80 00       	push   $0x802445
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 e0 25 80 00       	push   $0x8025e0
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 45 24 80 00       	push   $0x802445
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 55 24 80 00       	mov    $0x802455,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 5e 24 80 00       	push   $0x80245e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 45 24 80 00       	push   $0x802445
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 04 26 80 00       	push   $0x802604
  800119:	6a 27                	push   $0x27
  80011b:	68 45 24 80 00       	push   $0x802445
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 76 24 80 00       	push   $0x802476
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 8a 24 80 00       	push   $0x80248a
  800154:	6a 2b                	push   $0x2b
  800156:	68 45 24 80 00       	push   $0x802445
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 be 0b 00 00       	call   800d2c <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 a8 0b 00 00       	call   800d2c <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 34 26 80 00       	push   $0x802634
  80018f:	6a 2d                	push   $0x2d
  800191:	68 45 24 80 00       	push   $0x802445
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 98 24 80 00       	push   $0x802498
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 ec 0c 00 00       	call   800eaa <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 ab 24 80 00       	push   $0x8024ab
  8001df:	6a 32                	push   $0x32
  8001e1:	68 45 24 80 00       	push   $0x802445
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 0f 0c 00 00       	call   800e0f <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 b9 24 80 00       	push   $0x8024b9
  80020f:	6a 34                	push   $0x34
  800211:	68 45 24 80 00       	push   $0x802445
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 d7 24 80 00       	push   $0x8024d7
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 ea 24 80 00       	push   $0x8024ea
  800242:	6a 38                	push   $0x38
  800244:	68 45 24 80 00       	push   $0x802445
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 f9 24 80 00       	push   $0x8024f9
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 63 0f 00 00       	call   8011ed <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 5c 26 80 00       	push   $0x80265c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 45 24 80 00       	push   $0x802445
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 0d 25 80 00       	push   $0x80250d
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 23 25 80 00       	mov    $0x802523,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 2d 25 80 00       	push   $0x80252d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 45 24 80 00       	push   $0x802445
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 26 0a 00 00       	call   800d2c <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 05 0a 00 00       	call   800d2c <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 46 25 80 00       	push   $0x802546
  800334:	6a 4b                	push   $0x4b
  800336:	68 45 24 80 00       	push   $0x802445
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 55 25 80 00       	push   $0x802555
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 3d 0b 00 00       	call   800eaa <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 94 26 80 00       	push   $0x802694
  800390:	6a 51                	push   $0x51
  800392:	68 45 24 80 00       	push   $0x802445
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 82 09 00 00       	call   800d2c <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 b4 26 80 00       	push   $0x8026b4
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 45 24 80 00       	push   $0x802445
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 37 0a 00 00       	call   800e0f <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 ec 26 80 00       	push   $0x8026ec
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 45 24 80 00       	push   $0x802445
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 1c 27 80 00       	push   $0x80271c
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 20 24 80 00       	push   $0x802420
  80040a:	e8 b0 17 00 00       	call   801bbf <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 31 24 80 00       	push   $0x802431
  800426:	6a 5a                	push   $0x5a
  800428:	68 45 24 80 00       	push   $0x802445
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 69 25 80 00       	push   $0x802569
  80043e:	6a 5c                	push   $0x5c
  800440:	68 45 24 80 00       	push   $0x802445
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 55 24 80 00       	push   $0x802455
  800454:	e8 66 17 00 00       	call   801bbf <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 64 24 80 00       	push   $0x802464
  800466:	6a 5f                	push   $0x5f
  800468:	68 45 24 80 00       	push   $0x802445
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 40 27 80 00       	push   $0x802740
  800498:	6a 62                	push   $0x62
  80049a:	68 45 24 80 00       	push   $0x802445
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 7c 24 80 00       	push   $0x80247c
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 84 25 80 00       	push   $0x802584
  8004be:	e8 fc 16 00 00       	call   801bbf <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 89 25 80 00       	push   $0x802589
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 45 24 80 00       	push   $0x802445
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 b6 09 00 00       	call   800eaa <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 f7 12 00 00       	call   80180e <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 98 25 80 00       	push   $0x802598
  800528:	6a 6c                	push   $0x6c
  80052a:	68 45 24 80 00       	push   $0x802445
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 ac 10 00 00       	call   8015f8 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 84 25 80 00       	push   $0x802584
  800556:	e8 64 16 00 00       	call   801bbf <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 aa 25 80 00       	push   $0x8025aa
  80056a:	6a 71                	push   $0x71
  80056c:	68 45 24 80 00       	push   $0x802445
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 2f 12 00 00       	call   8017c5 <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 b8 25 80 00       	push   $0x8025b8
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 45 24 80 00       	push   $0x802445
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 68 27 80 00       	push   $0x802768
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 45 24 80 00       	push   $0x802445
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 94 27 80 00       	push   $0x802794
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 45 24 80 00       	push   $0x802445
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 e7 0f 00 00       	call   8015f8 <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 c9 25 80 00 	movl   $0x8025c9,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800633:	e8 f2 0a 00 00       	call   80112a <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 aa 0f 00 00       	call   801623 <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 66 0a 00 00       	call   8010e9 <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800696:	e8 8f 0a 00 00       	call   80112a <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 ec 27 80 00       	push   $0x8027ec
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 43 2c 80 00 	movl   $0x802c43,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 ae 09 00 00       	call   8010ac <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 1a 01 00 00       	call   80085e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 53 09 00 00       	call   8010ac <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 b7 19 00 00       	call   802180 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 a4 1a 00 00       	call   8022b0 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 0f 28 80 00 	movsbl 0x80280f(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80082a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80082e:	8b 10                	mov    (%eax),%edx
  800830:	3b 50 04             	cmp    0x4(%eax),%edx
  800833:	73 0a                	jae    80083f <sprintputch+0x1b>
		*b->buf++ = ch;
  800835:	8d 4a 01             	lea    0x1(%edx),%ecx
  800838:	89 08                	mov    %ecx,(%eax)
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	88 02                	mov    %al,(%edx)
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 05 00 00 00       	call   80085e <vprintfmt>
	va_end(ap);
}
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	57                   	push   %edi
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	83 ec 2c             	sub    $0x2c,%esp
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800870:	eb 12                	jmp    800884 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800872:	85 c0                	test   %eax,%eax
  800874:	0f 84 42 04 00 00    	je     800cbc <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	50                   	push   %eax
  80087f:	ff d6                	call   *%esi
  800881:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800884:	83 c7 01             	add    $0x1,%edi
  800887:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80088b:	83 f8 25             	cmp    $0x25,%eax
  80088e:	75 e2                	jne    800872 <vprintfmt+0x14>
  800890:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800894:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80089b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ae:	eb 07                	jmp    8008b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008b3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	8d 47 01             	lea    0x1(%edi),%eax
  8008ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008bd:	0f b6 07             	movzbl (%edi),%eax
  8008c0:	0f b6 d0             	movzbl %al,%edx
  8008c3:	83 e8 23             	sub    $0x23,%eax
  8008c6:	3c 55                	cmp    $0x55,%al
  8008c8:	0f 87 d3 03 00 00    	ja     800ca1 <vprintfmt+0x443>
  8008ce:	0f b6 c0             	movzbl %al,%eax
  8008d1:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  8008d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008db:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008df:	eb d6                	jmp    8008b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008ef:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008f3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008f6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008f9:	83 f9 09             	cmp    $0x9,%ecx
  8008fc:	77 3f                	ja     80093d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008fe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800901:	eb e9                	jmp    8008ec <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8b 00                	mov    (%eax),%eax
  800908:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80090b:	8b 45 14             	mov    0x14(%ebp),%eax
  80090e:	8d 40 04             	lea    0x4(%eax),%eax
  800911:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800914:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800917:	eb 2a                	jmp    800943 <vprintfmt+0xe5>
  800919:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80091c:	85 c0                	test   %eax,%eax
  80091e:	ba 00 00 00 00       	mov    $0x0,%edx
  800923:	0f 49 d0             	cmovns %eax,%edx
  800926:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80092c:	eb 89                	jmp    8008b7 <vprintfmt+0x59>
  80092e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800931:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800938:	e9 7a ff ff ff       	jmp    8008b7 <vprintfmt+0x59>
  80093d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800940:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800943:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800947:	0f 89 6a ff ff ff    	jns    8008b7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80094d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800950:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800953:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80095a:	e9 58 ff ff ff       	jmp    8008b7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80095f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800962:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800965:	e9 4d ff ff ff       	jmp    8008b7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80096a:	8b 45 14             	mov    0x14(%ebp),%eax
  80096d:	8d 78 04             	lea    0x4(%eax),%edi
  800970:	83 ec 08             	sub    $0x8,%esp
  800973:	53                   	push   %ebx
  800974:	ff 30                	pushl  (%eax)
  800976:	ff d6                	call   *%esi
			break;
  800978:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80097b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800981:	e9 fe fe ff ff       	jmp    800884 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	8d 78 04             	lea    0x4(%eax),%edi
  80098c:	8b 00                	mov    (%eax),%eax
  80098e:	99                   	cltd   
  80098f:	31 d0                	xor    %edx,%eax
  800991:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800993:	83 f8 0f             	cmp    $0xf,%eax
  800996:	7f 0b                	jg     8009a3 <vprintfmt+0x145>
  800998:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	75 1b                	jne    8009be <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8009a3:	50                   	push   %eax
  8009a4:	68 27 28 80 00       	push   $0x802827
  8009a9:	53                   	push   %ebx
  8009aa:	56                   	push   %esi
  8009ab:	e8 91 fe ff ff       	call   800841 <printfmt>
  8009b0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009b3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009b9:	e9 c6 fe ff ff       	jmp    800884 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009be:	52                   	push   %edx
  8009bf:	68 11 2c 80 00       	push   $0x802c11
  8009c4:	53                   	push   %ebx
  8009c5:	56                   	push   %esi
  8009c6:	e8 76 fe ff ff       	call   800841 <printfmt>
  8009cb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ce:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009d4:	e9 ab fe ff ff       	jmp    800884 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dc:	83 c0 04             	add    $0x4,%eax
  8009df:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8009e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009e7:	85 ff                	test   %edi,%edi
  8009e9:	b8 20 28 80 00       	mov    $0x802820,%eax
  8009ee:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009f5:	0f 8e 94 00 00 00    	jle    800a8f <vprintfmt+0x231>
  8009fb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009ff:	0f 84 98 00 00 00    	je     800a9d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a05:	83 ec 08             	sub    $0x8,%esp
  800a08:	ff 75 d0             	pushl  -0x30(%ebp)
  800a0b:	57                   	push   %edi
  800a0c:	e8 33 03 00 00       	call   800d44 <strnlen>
  800a11:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a14:	29 c1                	sub    %eax,%ecx
  800a16:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800a19:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a1c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a20:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a23:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a26:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a28:	eb 0f                	jmp    800a39 <vprintfmt+0x1db>
					putch(padc, putdat);
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	53                   	push   %ebx
  800a2e:	ff 75 e0             	pushl  -0x20(%ebp)
  800a31:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 ef 01             	sub    $0x1,%edi
  800a36:	83 c4 10             	add    $0x10,%esp
  800a39:	85 ff                	test   %edi,%edi
  800a3b:	7f ed                	jg     800a2a <vprintfmt+0x1cc>
  800a3d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a40:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800a43:	85 c9                	test   %ecx,%ecx
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	0f 49 c1             	cmovns %ecx,%eax
  800a4d:	29 c1                	sub    %eax,%ecx
  800a4f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a52:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a55:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a58:	89 cb                	mov    %ecx,%ebx
  800a5a:	eb 4d                	jmp    800aa9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a5c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a60:	74 1b                	je     800a7d <vprintfmt+0x21f>
  800a62:	0f be c0             	movsbl %al,%eax
  800a65:	83 e8 20             	sub    $0x20,%eax
  800a68:	83 f8 5e             	cmp    $0x5e,%eax
  800a6b:	76 10                	jbe    800a7d <vprintfmt+0x21f>
					putch('?', putdat);
  800a6d:	83 ec 08             	sub    $0x8,%esp
  800a70:	ff 75 0c             	pushl  0xc(%ebp)
  800a73:	6a 3f                	push   $0x3f
  800a75:	ff 55 08             	call   *0x8(%ebp)
  800a78:	83 c4 10             	add    $0x10,%esp
  800a7b:	eb 0d                	jmp    800a8a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800a7d:	83 ec 08             	sub    $0x8,%esp
  800a80:	ff 75 0c             	pushl  0xc(%ebp)
  800a83:	52                   	push   %edx
  800a84:	ff 55 08             	call   *0x8(%ebp)
  800a87:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a8a:	83 eb 01             	sub    $0x1,%ebx
  800a8d:	eb 1a                	jmp    800aa9 <vprintfmt+0x24b>
  800a8f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a92:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a95:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a98:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a9b:	eb 0c                	jmp    800aa9 <vprintfmt+0x24b>
  800a9d:	89 75 08             	mov    %esi,0x8(%ebp)
  800aa0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800aa3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800aa6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800aa9:	83 c7 01             	add    $0x1,%edi
  800aac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ab0:	0f be d0             	movsbl %al,%edx
  800ab3:	85 d2                	test   %edx,%edx
  800ab5:	74 23                	je     800ada <vprintfmt+0x27c>
  800ab7:	85 f6                	test   %esi,%esi
  800ab9:	78 a1                	js     800a5c <vprintfmt+0x1fe>
  800abb:	83 ee 01             	sub    $0x1,%esi
  800abe:	79 9c                	jns    800a5c <vprintfmt+0x1fe>
  800ac0:	89 df                	mov    %ebx,%edi
  800ac2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac8:	eb 18                	jmp    800ae2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aca:	83 ec 08             	sub    $0x8,%esp
  800acd:	53                   	push   %ebx
  800ace:	6a 20                	push   $0x20
  800ad0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ad2:	83 ef 01             	sub    $0x1,%edi
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	eb 08                	jmp    800ae2 <vprintfmt+0x284>
  800ada:	89 df                	mov    %ebx,%edi
  800adc:	8b 75 08             	mov    0x8(%ebp),%esi
  800adf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	7f e4                	jg     800aca <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800ae6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ae9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aef:	e9 90 fd ff ff       	jmp    800884 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800af4:	83 f9 01             	cmp    $0x1,%ecx
  800af7:	7e 19                	jle    800b12 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800af9:	8b 45 14             	mov    0x14(%ebp),%eax
  800afc:	8b 50 04             	mov    0x4(%eax),%edx
  800aff:	8b 00                	mov    (%eax),%eax
  800b01:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b04:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b07:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0a:	8d 40 08             	lea    0x8(%eax),%eax
  800b0d:	89 45 14             	mov    %eax,0x14(%ebp)
  800b10:	eb 38                	jmp    800b4a <vprintfmt+0x2ec>
	else if (lflag)
  800b12:	85 c9                	test   %ecx,%ecx
  800b14:	74 1b                	je     800b31 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800b16:	8b 45 14             	mov    0x14(%ebp),%eax
  800b19:	8b 00                	mov    (%eax),%eax
  800b1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1e:	89 c1                	mov    %eax,%ecx
  800b20:	c1 f9 1f             	sar    $0x1f,%ecx
  800b23:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b26:	8b 45 14             	mov    0x14(%ebp),%eax
  800b29:	8d 40 04             	lea    0x4(%eax),%eax
  800b2c:	89 45 14             	mov    %eax,0x14(%ebp)
  800b2f:	eb 19                	jmp    800b4a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800b31:	8b 45 14             	mov    0x14(%ebp),%eax
  800b34:	8b 00                	mov    (%eax),%eax
  800b36:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b39:	89 c1                	mov    %eax,%ecx
  800b3b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b3e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b41:	8b 45 14             	mov    0x14(%ebp),%eax
  800b44:	8d 40 04             	lea    0x4(%eax),%eax
  800b47:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b4a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b4d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b50:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b55:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b59:	0f 89 0e 01 00 00    	jns    800c6d <vprintfmt+0x40f>
				putch('-', putdat);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	53                   	push   %ebx
  800b63:	6a 2d                	push   $0x2d
  800b65:	ff d6                	call   *%esi
				num = -(long long) num;
  800b67:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b6a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b6d:	f7 da                	neg    %edx
  800b6f:	83 d1 00             	adc    $0x0,%ecx
  800b72:	f7 d9                	neg    %ecx
  800b74:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7c:	e9 ec 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b81:	83 f9 01             	cmp    $0x1,%ecx
  800b84:	7e 18                	jle    800b9e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800b86:	8b 45 14             	mov    0x14(%ebp),%eax
  800b89:	8b 10                	mov    (%eax),%edx
  800b8b:	8b 48 04             	mov    0x4(%eax),%ecx
  800b8e:	8d 40 08             	lea    0x8(%eax),%eax
  800b91:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b94:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b99:	e9 cf 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800b9e:	85 c9                	test   %ecx,%ecx
  800ba0:	74 1a                	je     800bbc <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800ba2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba5:	8b 10                	mov    (%eax),%edx
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	8d 40 04             	lea    0x4(%eax),%eax
  800baf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800bb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb7:	e9 b1 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800bbc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bbf:	8b 10                	mov    (%eax),%edx
  800bc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc6:	8d 40 04             	lea    0x4(%eax),%eax
  800bc9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800bcc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd1:	e9 97 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800bd6:	83 ec 08             	sub    $0x8,%esp
  800bd9:	53                   	push   %ebx
  800bda:	6a 58                	push   $0x58
  800bdc:	ff d6                	call   *%esi
			putch('X', putdat);
  800bde:	83 c4 08             	add    $0x8,%esp
  800be1:	53                   	push   %ebx
  800be2:	6a 58                	push   $0x58
  800be4:	ff d6                	call   *%esi
			putch('X', putdat);
  800be6:	83 c4 08             	add    $0x8,%esp
  800be9:	53                   	push   %ebx
  800bea:	6a 58                	push   $0x58
  800bec:	ff d6                	call   *%esi
			break;
  800bee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800bf4:	e9 8b fc ff ff       	jmp    800884 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800bf9:	83 ec 08             	sub    $0x8,%esp
  800bfc:	53                   	push   %ebx
  800bfd:	6a 30                	push   $0x30
  800bff:	ff d6                	call   *%esi
			putch('x', putdat);
  800c01:	83 c4 08             	add    $0x8,%esp
  800c04:	53                   	push   %ebx
  800c05:	6a 78                	push   $0x78
  800c07:	ff d6                	call   *%esi
			num = (unsigned long long)
  800c09:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0c:	8b 10                	mov    (%eax),%edx
  800c0e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c13:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c16:	8d 40 04             	lea    0x4(%eax),%eax
  800c19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c1c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c21:	eb 4a                	jmp    800c6d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c23:	83 f9 01             	cmp    $0x1,%ecx
  800c26:	7e 15                	jle    800c3d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800c28:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2b:	8b 10                	mov    (%eax),%edx
  800c2d:	8b 48 04             	mov    0x4(%eax),%ecx
  800c30:	8d 40 08             	lea    0x8(%eax),%eax
  800c33:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c36:	b8 10 00 00 00       	mov    $0x10,%eax
  800c3b:	eb 30                	jmp    800c6d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800c3d:	85 c9                	test   %ecx,%ecx
  800c3f:	74 17                	je     800c58 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800c41:	8b 45 14             	mov    0x14(%ebp),%eax
  800c44:	8b 10                	mov    (%eax),%edx
  800c46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4b:	8d 40 04             	lea    0x4(%eax),%eax
  800c4e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c51:	b8 10 00 00 00       	mov    $0x10,%eax
  800c56:	eb 15                	jmp    800c6d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800c58:	8b 45 14             	mov    0x14(%ebp),%eax
  800c5b:	8b 10                	mov    (%eax),%edx
  800c5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c62:	8d 40 04             	lea    0x4(%eax),%eax
  800c65:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c68:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c74:	57                   	push   %edi
  800c75:	ff 75 e0             	pushl  -0x20(%ebp)
  800c78:	50                   	push   %eax
  800c79:	51                   	push   %ecx
  800c7a:	52                   	push   %edx
  800c7b:	89 da                	mov    %ebx,%edx
  800c7d:	89 f0                	mov    %esi,%eax
  800c7f:	e8 f1 fa ff ff       	call   800775 <printnum>
			break;
  800c84:	83 c4 20             	add    $0x20,%esp
  800c87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c8a:	e9 f5 fb ff ff       	jmp    800884 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c8f:	83 ec 08             	sub    $0x8,%esp
  800c92:	53                   	push   %ebx
  800c93:	52                   	push   %edx
  800c94:	ff d6                	call   *%esi
			break;
  800c96:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c9c:	e9 e3 fb ff ff       	jmp    800884 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ca1:	83 ec 08             	sub    $0x8,%esp
  800ca4:	53                   	push   %ebx
  800ca5:	6a 25                	push   $0x25
  800ca7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ca9:	83 c4 10             	add    $0x10,%esp
  800cac:	eb 03                	jmp    800cb1 <vprintfmt+0x453>
  800cae:	83 ef 01             	sub    $0x1,%edi
  800cb1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800cb5:	75 f7                	jne    800cae <vprintfmt+0x450>
  800cb7:	e9 c8 fb ff ff       	jmp    800884 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 18             	sub    $0x18,%esp
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cd3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cd7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	74 26                	je     800d0b <vsnprintf+0x47>
  800ce5:	85 d2                	test   %edx,%edx
  800ce7:	7e 22                	jle    800d0b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ce9:	ff 75 14             	pushl  0x14(%ebp)
  800cec:	ff 75 10             	pushl  0x10(%ebp)
  800cef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cf2:	50                   	push   %eax
  800cf3:	68 24 08 80 00       	push   $0x800824
  800cf8:	e8 61 fb ff ff       	call   80085e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d00:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d06:	83 c4 10             	add    $0x10,%esp
  800d09:	eb 05                	jmp    800d10 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d18:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d1b:	50                   	push   %eax
  800d1c:	ff 75 10             	pushl  0x10(%ebp)
  800d1f:	ff 75 0c             	pushl  0xc(%ebp)
  800d22:	ff 75 08             	pushl  0x8(%ebp)
  800d25:	e8 9a ff ff ff       	call   800cc4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d2a:	c9                   	leave  
  800d2b:	c3                   	ret    

00800d2c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
  800d37:	eb 03                	jmp    800d3c <strlen+0x10>
		n++;
  800d39:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d3c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d40:	75 f7                	jne    800d39 <strlen+0xd>
		n++;
	return n;
}
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	eb 03                	jmp    800d57 <strnlen+0x13>
		n++;
  800d54:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d57:	39 c2                	cmp    %eax,%edx
  800d59:	74 08                	je     800d63 <strnlen+0x1f>
  800d5b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d5f:	75 f3                	jne    800d54 <strnlen+0x10>
  800d61:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	53                   	push   %ebx
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	83 c2 01             	add    $0x1,%edx
  800d74:	83 c1 01             	add    $0x1,%ecx
  800d77:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d7b:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d7e:	84 db                	test   %bl,%bl
  800d80:	75 ef                	jne    800d71 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d82:	5b                   	pop    %ebx
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	53                   	push   %ebx
  800d89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d8c:	53                   	push   %ebx
  800d8d:	e8 9a ff ff ff       	call   800d2c <strlen>
  800d92:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d95:	ff 75 0c             	pushl  0xc(%ebp)
  800d98:	01 d8                	add    %ebx,%eax
  800d9a:	50                   	push   %eax
  800d9b:	e8 c5 ff ff ff       	call   800d65 <strcpy>
	return dst;
}
  800da0:	89 d8                	mov    %ebx,%eax
  800da2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	8b 75 08             	mov    0x8(%ebp),%esi
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	89 f3                	mov    %esi,%ebx
  800db4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db7:	89 f2                	mov    %esi,%edx
  800db9:	eb 0f                	jmp    800dca <strncpy+0x23>
		*dst++ = *src;
  800dbb:	83 c2 01             	add    $0x1,%edx
  800dbe:	0f b6 01             	movzbl (%ecx),%eax
  800dc1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dc4:	80 39 01             	cmpb   $0x1,(%ecx)
  800dc7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dca:	39 da                	cmp    %ebx,%edx
  800dcc:	75 ed                	jne    800dbb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dce:	89 f0                	mov    %esi,%eax
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	8b 75 08             	mov    0x8(%ebp),%esi
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddf:	8b 55 10             	mov    0x10(%ebp),%edx
  800de2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800de4:	85 d2                	test   %edx,%edx
  800de6:	74 21                	je     800e09 <strlcpy+0x35>
  800de8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800dec:	89 f2                	mov    %esi,%edx
  800dee:	eb 09                	jmp    800df9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800df0:	83 c2 01             	add    $0x1,%edx
  800df3:	83 c1 01             	add    $0x1,%ecx
  800df6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800df9:	39 c2                	cmp    %eax,%edx
  800dfb:	74 09                	je     800e06 <strlcpy+0x32>
  800dfd:	0f b6 19             	movzbl (%ecx),%ebx
  800e00:	84 db                	test   %bl,%bl
  800e02:	75 ec                	jne    800df0 <strlcpy+0x1c>
  800e04:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e06:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e09:	29 f0                	sub    %esi,%eax
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e15:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e18:	eb 06                	jmp    800e20 <strcmp+0x11>
		p++, q++;
  800e1a:	83 c1 01             	add    $0x1,%ecx
  800e1d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e20:	0f b6 01             	movzbl (%ecx),%eax
  800e23:	84 c0                	test   %al,%al
  800e25:	74 04                	je     800e2b <strcmp+0x1c>
  800e27:	3a 02                	cmp    (%edx),%al
  800e29:	74 ef                	je     800e1a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e2b:	0f b6 c0             	movzbl %al,%eax
  800e2e:	0f b6 12             	movzbl (%edx),%edx
  800e31:	29 d0                	sub    %edx,%eax
}
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	53                   	push   %ebx
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3f:	89 c3                	mov    %eax,%ebx
  800e41:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e44:	eb 06                	jmp    800e4c <strncmp+0x17>
		n--, p++, q++;
  800e46:	83 c0 01             	add    $0x1,%eax
  800e49:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e4c:	39 d8                	cmp    %ebx,%eax
  800e4e:	74 15                	je     800e65 <strncmp+0x30>
  800e50:	0f b6 08             	movzbl (%eax),%ecx
  800e53:	84 c9                	test   %cl,%cl
  800e55:	74 04                	je     800e5b <strncmp+0x26>
  800e57:	3a 0a                	cmp    (%edx),%cl
  800e59:	74 eb                	je     800e46 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e5b:	0f b6 00             	movzbl (%eax),%eax
  800e5e:	0f b6 12             	movzbl (%edx),%edx
  800e61:	29 d0                	sub    %edx,%eax
  800e63:	eb 05                	jmp    800e6a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e65:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e6a:	5b                   	pop    %ebx
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e77:	eb 07                	jmp    800e80 <strchr+0x13>
		if (*s == c)
  800e79:	38 ca                	cmp    %cl,%dl
  800e7b:	74 0f                	je     800e8c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e7d:	83 c0 01             	add    $0x1,%eax
  800e80:	0f b6 10             	movzbl (%eax),%edx
  800e83:	84 d2                	test   %dl,%dl
  800e85:	75 f2                	jne    800e79 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e98:	eb 03                	jmp    800e9d <strfind+0xf>
  800e9a:	83 c0 01             	add    $0x1,%eax
  800e9d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ea0:	38 ca                	cmp    %cl,%dl
  800ea2:	74 04                	je     800ea8 <strfind+0x1a>
  800ea4:	84 d2                	test   %dl,%dl
  800ea6:	75 f2                	jne    800e9a <strfind+0xc>
			break;
	return (char *) s;
}
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800eb6:	85 c9                	test   %ecx,%ecx
  800eb8:	74 36                	je     800ef0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eba:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ec0:	75 28                	jne    800eea <memset+0x40>
  800ec2:	f6 c1 03             	test   $0x3,%cl
  800ec5:	75 23                	jne    800eea <memset+0x40>
		c &= 0xFF;
  800ec7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ecb:	89 d3                	mov    %edx,%ebx
  800ecd:	c1 e3 08             	shl    $0x8,%ebx
  800ed0:	89 d6                	mov    %edx,%esi
  800ed2:	c1 e6 18             	shl    $0x18,%esi
  800ed5:	89 d0                	mov    %edx,%eax
  800ed7:	c1 e0 10             	shl    $0x10,%eax
  800eda:	09 f0                	or     %esi,%eax
  800edc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ede:	89 d8                	mov    %ebx,%eax
  800ee0:	09 d0                	or     %edx,%eax
  800ee2:	c1 e9 02             	shr    $0x2,%ecx
  800ee5:	fc                   	cld    
  800ee6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ee8:	eb 06                	jmp    800ef0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	fc                   	cld    
  800eee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ef0:	89 f8                	mov    %edi,%eax
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f05:	39 c6                	cmp    %eax,%esi
  800f07:	73 35                	jae    800f3e <memmove+0x47>
  800f09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f0c:	39 d0                	cmp    %edx,%eax
  800f0e:	73 2e                	jae    800f3e <memmove+0x47>
		s += n;
		d += n;
  800f10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f13:	89 d6                	mov    %edx,%esi
  800f15:	09 fe                	or     %edi,%esi
  800f17:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f1d:	75 13                	jne    800f32 <memmove+0x3b>
  800f1f:	f6 c1 03             	test   $0x3,%cl
  800f22:	75 0e                	jne    800f32 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f24:	83 ef 04             	sub    $0x4,%edi
  800f27:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f2a:	c1 e9 02             	shr    $0x2,%ecx
  800f2d:	fd                   	std    
  800f2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f30:	eb 09                	jmp    800f3b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f32:	83 ef 01             	sub    $0x1,%edi
  800f35:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f38:	fd                   	std    
  800f39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f3b:	fc                   	cld    
  800f3c:	eb 1d                	jmp    800f5b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3e:	89 f2                	mov    %esi,%edx
  800f40:	09 c2                	or     %eax,%edx
  800f42:	f6 c2 03             	test   $0x3,%dl
  800f45:	75 0f                	jne    800f56 <memmove+0x5f>
  800f47:	f6 c1 03             	test   $0x3,%cl
  800f4a:	75 0a                	jne    800f56 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f4c:	c1 e9 02             	shr    $0x2,%ecx
  800f4f:	89 c7                	mov    %eax,%edi
  800f51:	fc                   	cld    
  800f52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f54:	eb 05                	jmp    800f5b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f56:	89 c7                	mov    %eax,%edi
  800f58:	fc                   	cld    
  800f59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f62:	ff 75 10             	pushl  0x10(%ebp)
  800f65:	ff 75 0c             	pushl  0xc(%ebp)
  800f68:	ff 75 08             	pushl  0x8(%ebp)
  800f6b:	e8 87 ff ff ff       	call   800ef7 <memmove>
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7d:	89 c6                	mov    %eax,%esi
  800f7f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f82:	eb 1a                	jmp    800f9e <memcmp+0x2c>
		if (*s1 != *s2)
  800f84:	0f b6 08             	movzbl (%eax),%ecx
  800f87:	0f b6 1a             	movzbl (%edx),%ebx
  800f8a:	38 d9                	cmp    %bl,%cl
  800f8c:	74 0a                	je     800f98 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f8e:	0f b6 c1             	movzbl %cl,%eax
  800f91:	0f b6 db             	movzbl %bl,%ebx
  800f94:	29 d8                	sub    %ebx,%eax
  800f96:	eb 0f                	jmp    800fa7 <memcmp+0x35>
		s1++, s2++;
  800f98:	83 c0 01             	add    $0x1,%eax
  800f9b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f9e:	39 f0                	cmp    %esi,%eax
  800fa0:	75 e2                	jne    800f84 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	53                   	push   %ebx
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800fb2:	89 c1                	mov    %eax,%ecx
  800fb4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800fb7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fbb:	eb 0a                	jmp    800fc7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fbd:	0f b6 10             	movzbl (%eax),%edx
  800fc0:	39 da                	cmp    %ebx,%edx
  800fc2:	74 07                	je     800fcb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fc4:	83 c0 01             	add    $0x1,%eax
  800fc7:	39 c8                	cmp    %ecx,%eax
  800fc9:	72 f2                	jb     800fbd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fcb:	5b                   	pop    %ebx
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fda:	eb 03                	jmp    800fdf <strtol+0x11>
		s++;
  800fdc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fdf:	0f b6 01             	movzbl (%ecx),%eax
  800fe2:	3c 20                	cmp    $0x20,%al
  800fe4:	74 f6                	je     800fdc <strtol+0xe>
  800fe6:	3c 09                	cmp    $0x9,%al
  800fe8:	74 f2                	je     800fdc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fea:	3c 2b                	cmp    $0x2b,%al
  800fec:	75 0a                	jne    800ff8 <strtol+0x2a>
		s++;
  800fee:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ff1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ff6:	eb 11                	jmp    801009 <strtol+0x3b>
  800ff8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ffd:	3c 2d                	cmp    $0x2d,%al
  800fff:	75 08                	jne    801009 <strtol+0x3b>
		s++, neg = 1;
  801001:	83 c1 01             	add    $0x1,%ecx
  801004:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801009:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80100f:	75 15                	jne    801026 <strtol+0x58>
  801011:	80 39 30             	cmpb   $0x30,(%ecx)
  801014:	75 10                	jne    801026 <strtol+0x58>
  801016:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80101a:	75 7c                	jne    801098 <strtol+0xca>
		s += 2, base = 16;
  80101c:	83 c1 02             	add    $0x2,%ecx
  80101f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801024:	eb 16                	jmp    80103c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801026:	85 db                	test   %ebx,%ebx
  801028:	75 12                	jne    80103c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80102a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80102f:	80 39 30             	cmpb   $0x30,(%ecx)
  801032:	75 08                	jne    80103c <strtol+0x6e>
		s++, base = 8;
  801034:	83 c1 01             	add    $0x1,%ecx
  801037:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801044:	0f b6 11             	movzbl (%ecx),%edx
  801047:	8d 72 d0             	lea    -0x30(%edx),%esi
  80104a:	89 f3                	mov    %esi,%ebx
  80104c:	80 fb 09             	cmp    $0x9,%bl
  80104f:	77 08                	ja     801059 <strtol+0x8b>
			dig = *s - '0';
  801051:	0f be d2             	movsbl %dl,%edx
  801054:	83 ea 30             	sub    $0x30,%edx
  801057:	eb 22                	jmp    80107b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801059:	8d 72 9f             	lea    -0x61(%edx),%esi
  80105c:	89 f3                	mov    %esi,%ebx
  80105e:	80 fb 19             	cmp    $0x19,%bl
  801061:	77 08                	ja     80106b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801063:	0f be d2             	movsbl %dl,%edx
  801066:	83 ea 57             	sub    $0x57,%edx
  801069:	eb 10                	jmp    80107b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80106b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80106e:	89 f3                	mov    %esi,%ebx
  801070:	80 fb 19             	cmp    $0x19,%bl
  801073:	77 16                	ja     80108b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801075:	0f be d2             	movsbl %dl,%edx
  801078:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80107b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80107e:	7d 0b                	jge    80108b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801080:	83 c1 01             	add    $0x1,%ecx
  801083:	0f af 45 10          	imul   0x10(%ebp),%eax
  801087:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801089:	eb b9                	jmp    801044 <strtol+0x76>

	if (endptr)
  80108b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80108f:	74 0d                	je     80109e <strtol+0xd0>
		*endptr = (char *) s;
  801091:	8b 75 0c             	mov    0xc(%ebp),%esi
  801094:	89 0e                	mov    %ecx,(%esi)
  801096:	eb 06                	jmp    80109e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801098:	85 db                	test   %ebx,%ebx
  80109a:	74 98                	je     801034 <strtol+0x66>
  80109c:	eb 9e                	jmp    80103c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80109e:	89 c2                	mov    %eax,%edx
  8010a0:	f7 da                	neg    %edx
  8010a2:	85 ff                	test   %edi,%edi
  8010a4:	0f 45 c2             	cmovne %edx,%eax
}
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	57                   	push   %edi
  8010b0:	56                   	push   %esi
  8010b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bd:	89 c3                	mov    %eax,%ebx
  8010bf:	89 c7                	mov    %eax,%edi
  8010c1:	89 c6                	mov    %eax,%esi
  8010c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010da:	89 d1                	mov    %edx,%ecx
  8010dc:	89 d3                	mov    %edx,%ebx
  8010de:	89 d7                	mov    %edx,%edi
  8010e0:	89 d6                	mov    %edx,%esi
  8010e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8010fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ff:	89 cb                	mov    %ecx,%ebx
  801101:	89 cf                	mov    %ecx,%edi
  801103:	89 ce                	mov    %ecx,%esi
  801105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801107:	85 c0                	test   %eax,%eax
  801109:	7e 17                	jle    801122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	50                   	push   %eax
  80110f:	6a 03                	push   $0x3
  801111:	68 1f 2b 80 00       	push   $0x802b1f
  801116:	6a 23                	push   $0x23
  801118:	68 3c 2b 80 00       	push   $0x802b3c
  80111d:	e8 66 f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	57                   	push   %edi
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801130:	ba 00 00 00 00       	mov    $0x0,%edx
  801135:	b8 02 00 00 00       	mov    $0x2,%eax
  80113a:	89 d1                	mov    %edx,%ecx
  80113c:	89 d3                	mov    %edx,%ebx
  80113e:	89 d7                	mov    %edx,%edi
  801140:	89 d6                	mov    %edx,%esi
  801142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <sys_yield>:

void
sys_yield(void)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114f:	ba 00 00 00 00       	mov    $0x0,%edx
  801154:	b8 0b 00 00 00       	mov    $0xb,%eax
  801159:	89 d1                	mov    %edx,%ecx
  80115b:	89 d3                	mov    %edx,%ebx
  80115d:	89 d7                	mov    %edx,%edi
  80115f:	89 d6                	mov    %edx,%esi
  801161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	53                   	push   %ebx
  80116e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801171:	be 00 00 00 00       	mov    $0x0,%esi
  801176:	b8 04 00 00 00       	mov    $0x4,%eax
  80117b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117e:	8b 55 08             	mov    0x8(%ebp),%edx
  801181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801184:	89 f7                	mov    %esi,%edi
  801186:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801188:	85 c0                	test   %eax,%eax
  80118a:	7e 17                	jle    8011a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	50                   	push   %eax
  801190:	6a 04                	push   $0x4
  801192:	68 1f 2b 80 00       	push   $0x802b1f
  801197:	6a 23                	push   $0x23
  801199:	68 3c 2b 80 00       	push   $0x802b3c
  80119e:	e8 e5 f4 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	57                   	push   %edi
  8011af:	56                   	push   %esi
  8011b0:	53                   	push   %ebx
  8011b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8011b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8011c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	7e 17                	jle    8011e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ce:	83 ec 0c             	sub    $0xc,%esp
  8011d1:	50                   	push   %eax
  8011d2:	6a 05                	push   $0x5
  8011d4:	68 1f 2b 80 00       	push   $0x802b1f
  8011d9:	6a 23                	push   $0x23
  8011db:	68 3c 2b 80 00       	push   $0x802b3c
  8011e0:	e8 a3 f4 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	57                   	push   %edi
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fb:	b8 06 00 00 00       	mov    $0x6,%eax
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	8b 55 08             	mov    0x8(%ebp),%edx
  801206:	89 df                	mov    %ebx,%edi
  801208:	89 de                	mov    %ebx,%esi
  80120a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80120c:	85 c0                	test   %eax,%eax
  80120e:	7e 17                	jle    801227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801210:	83 ec 0c             	sub    $0xc,%esp
  801213:	50                   	push   %eax
  801214:	6a 06                	push   $0x6
  801216:	68 1f 2b 80 00       	push   $0x802b1f
  80121b:	6a 23                	push   $0x23
  80121d:	68 3c 2b 80 00       	push   $0x802b3c
  801222:	e8 61 f4 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122a:	5b                   	pop    %ebx
  80122b:	5e                   	pop    %esi
  80122c:	5f                   	pop    %edi
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    

0080122f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	57                   	push   %edi
  801233:	56                   	push   %esi
  801234:	53                   	push   %ebx
  801235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123d:	b8 08 00 00 00       	mov    $0x8,%eax
  801242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801245:	8b 55 08             	mov    0x8(%ebp),%edx
  801248:	89 df                	mov    %ebx,%edi
  80124a:	89 de                	mov    %ebx,%esi
  80124c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80124e:	85 c0                	test   %eax,%eax
  801250:	7e 17                	jle    801269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801252:	83 ec 0c             	sub    $0xc,%esp
  801255:	50                   	push   %eax
  801256:	6a 08                	push   $0x8
  801258:	68 1f 2b 80 00       	push   $0x802b1f
  80125d:	6a 23                	push   $0x23
  80125f:	68 3c 2b 80 00       	push   $0x802b3c
  801264:	e8 1f f4 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5f                   	pop    %edi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	57                   	push   %edi
  801275:	56                   	push   %esi
  801276:	53                   	push   %ebx
  801277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127f:	b8 09 00 00 00       	mov    $0x9,%eax
  801284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801287:	8b 55 08             	mov    0x8(%ebp),%edx
  80128a:	89 df                	mov    %ebx,%edi
  80128c:	89 de                	mov    %ebx,%esi
  80128e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801290:	85 c0                	test   %eax,%eax
  801292:	7e 17                	jle    8012ab <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801294:	83 ec 0c             	sub    $0xc,%esp
  801297:	50                   	push   %eax
  801298:	6a 09                	push   $0x9
  80129a:	68 1f 2b 80 00       	push   $0x802b1f
  80129f:	6a 23                	push   $0x23
  8012a1:	68 3c 2b 80 00       	push   $0x802b3c
  8012a6:	e8 dd f3 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	5f                   	pop    %edi
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	57                   	push   %edi
  8012b7:	56                   	push   %esi
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cc:	89 df                	mov    %ebx,%edi
  8012ce:	89 de                	mov    %ebx,%esi
  8012d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	7e 17                	jle    8012ed <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	50                   	push   %eax
  8012da:	6a 0a                	push   $0xa
  8012dc:	68 1f 2b 80 00       	push   $0x802b1f
  8012e1:	6a 23                	push   $0x23
  8012e3:	68 3c 2b 80 00       	push   $0x802b3c
  8012e8:	e8 9b f3 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5f                   	pop    %edi
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	57                   	push   %edi
  8012f9:	56                   	push   %esi
  8012fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012fb:	be 00 00 00 00       	mov    $0x0,%esi
  801300:	b8 0c 00 00 00       	mov    $0xc,%eax
  801305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801308:	8b 55 08             	mov    0x8(%ebp),%edx
  80130b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80130e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801311:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801321:	b9 00 00 00 00       	mov    $0x0,%ecx
  801326:	b8 0d 00 00 00       	mov    $0xd,%eax
  80132b:	8b 55 08             	mov    0x8(%ebp),%edx
  80132e:	89 cb                	mov    %ecx,%ebx
  801330:	89 cf                	mov    %ecx,%edi
  801332:	89 ce                	mov    %ecx,%esi
  801334:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801336:	85 c0                	test   %eax,%eax
  801338:	7e 17                	jle    801351 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	50                   	push   %eax
  80133e:	6a 0d                	push   $0xd
  801340:	68 1f 2b 80 00       	push   $0x802b1f
  801345:	6a 23                	push   $0x23
  801347:	68 3c 2b 80 00       	push   $0x802b3c
  80134c:	e8 37 f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801354:	5b                   	pop    %ebx
  801355:	5e                   	pop    %esi
  801356:	5f                   	pop    %edi
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    

00801359 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	56                   	push   %esi
  80135d:	53                   	push   %ebx
  80135e:	8b 75 08             	mov    0x8(%ebp),%esi
  801361:	8b 45 0c             	mov    0xc(%ebp),%eax
  801364:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801367:	85 c0                	test   %eax,%eax
  801369:	74 0e                	je     801379 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  80136b:	83 ec 0c             	sub    $0xc,%esp
  80136e:	50                   	push   %eax
  80136f:	e8 a4 ff ff ff       	call   801318 <sys_ipc_recv>
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	eb 0d                	jmp    801386 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801379:	83 ec 0c             	sub    $0xc,%esp
  80137c:	6a ff                	push   $0xffffffff
  80137e:	e8 95 ff ff ff       	call   801318 <sys_ipc_recv>
  801383:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801386:	85 c0                	test   %eax,%eax
  801388:	79 16                	jns    8013a0 <ipc_recv+0x47>

		if (from_env_store != NULL)
  80138a:	85 f6                	test   %esi,%esi
  80138c:	74 06                	je     801394 <ipc_recv+0x3b>
			*from_env_store = 0;
  80138e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801394:	85 db                	test   %ebx,%ebx
  801396:	74 2c                	je     8013c4 <ipc_recv+0x6b>
			*perm_store = 0;
  801398:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80139e:	eb 24                	jmp    8013c4 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  8013a0:	85 f6                	test   %esi,%esi
  8013a2:	74 0a                	je     8013ae <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  8013a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a9:	8b 40 74             	mov    0x74(%eax),%eax
  8013ac:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  8013ae:	85 db                	test   %ebx,%ebx
  8013b0:	74 0a                	je     8013bc <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  8013b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b7:	8b 40 78             	mov    0x78(%eax),%eax
  8013ba:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8013bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c1:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8013c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	57                   	push   %edi
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 0c             	sub    $0xc,%esp
  8013d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  8013dd:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  8013df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8013e4:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8013e7:	ff 75 14             	pushl  0x14(%ebp)
  8013ea:	53                   	push   %ebx
  8013eb:	56                   	push   %esi
  8013ec:	57                   	push   %edi
  8013ed:	e8 03 ff ff ff       	call   8012f5 <sys_ipc_try_send>
		if (r >= 0)
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	79 1e                	jns    801417 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  8013f9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013fc:	74 12                	je     801410 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  8013fe:	50                   	push   %eax
  8013ff:	68 4a 2b 80 00       	push   $0x802b4a
  801404:	6a 49                	push   $0x49
  801406:	68 5d 2b 80 00       	push   $0x802b5d
  80140b:	e8 78 f2 ff ff       	call   800688 <_panic>
	
		sys_yield();
  801410:	e8 34 fd ff ff       	call   801149 <sys_yield>
	}
  801415:	eb d0                	jmp    8013e7 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801417:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141a:	5b                   	pop    %ebx
  80141b:	5e                   	pop    %esi
  80141c:	5f                   	pop    %edi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    

0080141f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801425:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80142a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80142d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801433:	8b 52 50             	mov    0x50(%edx),%edx
  801436:	39 ca                	cmp    %ecx,%edx
  801438:	75 0d                	jne    801447 <ipc_find_env+0x28>
			return envs[i].env_id;
  80143a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80143d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801442:	8b 40 48             	mov    0x48(%eax),%eax
  801445:	eb 0f                	jmp    801456 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801447:	83 c0 01             	add    $0x1,%eax
  80144a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80144f:	75 d9                	jne    80142a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801451:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80145b:	8b 45 08             	mov    0x8(%ebp),%eax
  80145e:	05 00 00 00 30       	add    $0x30000000,%eax
  801463:	c1 e8 0c             	shr    $0xc,%eax
}
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80146b:	8b 45 08             	mov    0x8(%ebp),%eax
  80146e:	05 00 00 00 30       	add    $0x30000000,%eax
  801473:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801478:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80147d:	5d                   	pop    %ebp
  80147e:	c3                   	ret    

0080147f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801485:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80148a:	89 c2                	mov    %eax,%edx
  80148c:	c1 ea 16             	shr    $0x16,%edx
  80148f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801496:	f6 c2 01             	test   $0x1,%dl
  801499:	74 11                	je     8014ac <fd_alloc+0x2d>
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	c1 ea 0c             	shr    $0xc,%edx
  8014a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a7:	f6 c2 01             	test   $0x1,%dl
  8014aa:	75 09                	jne    8014b5 <fd_alloc+0x36>
			*fd_store = fd;
  8014ac:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b3:	eb 17                	jmp    8014cc <fd_alloc+0x4d>
  8014b5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014ba:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014bf:	75 c9                	jne    80148a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014c1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014c7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014cc:	5d                   	pop    %ebp
  8014cd:	c3                   	ret    

008014ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014d4:	83 f8 1f             	cmp    $0x1f,%eax
  8014d7:	77 36                	ja     80150f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014d9:	c1 e0 0c             	shl    $0xc,%eax
  8014dc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014e1:	89 c2                	mov    %eax,%edx
  8014e3:	c1 ea 16             	shr    $0x16,%edx
  8014e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014ed:	f6 c2 01             	test   $0x1,%dl
  8014f0:	74 24                	je     801516 <fd_lookup+0x48>
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	c1 ea 0c             	shr    $0xc,%edx
  8014f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014fe:	f6 c2 01             	test   $0x1,%dl
  801501:	74 1a                	je     80151d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801503:	8b 55 0c             	mov    0xc(%ebp),%edx
  801506:	89 02                	mov    %eax,(%edx)
	return 0;
  801508:	b8 00 00 00 00       	mov    $0x0,%eax
  80150d:	eb 13                	jmp    801522 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80150f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801514:	eb 0c                	jmp    801522 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801516:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151b:	eb 05                	jmp    801522 <fd_lookup+0x54>
  80151d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801522:	5d                   	pop    %ebp
  801523:	c3                   	ret    

00801524 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	83 ec 08             	sub    $0x8,%esp
  80152a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80152d:	ba e8 2b 80 00       	mov    $0x802be8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801532:	eb 13                	jmp    801547 <dev_lookup+0x23>
  801534:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801537:	39 08                	cmp    %ecx,(%eax)
  801539:	75 0c                	jne    801547 <dev_lookup+0x23>
			*dev = devtab[i];
  80153b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80153e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801540:	b8 00 00 00 00       	mov    $0x0,%eax
  801545:	eb 2e                	jmp    801575 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801547:	8b 02                	mov    (%edx),%eax
  801549:	85 c0                	test   %eax,%eax
  80154b:	75 e7                	jne    801534 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80154d:	a1 04 40 80 00       	mov    0x804004,%eax
  801552:	8b 40 48             	mov    0x48(%eax),%eax
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	51                   	push   %ecx
  801559:	50                   	push   %eax
  80155a:	68 68 2b 80 00       	push   $0x802b68
  80155f:	e8 fd f1 ff ff       	call   800761 <cprintf>
	*dev = 0;
  801564:	8b 45 0c             	mov    0xc(%ebp),%eax
  801567:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	56                   	push   %esi
  80157b:	53                   	push   %ebx
  80157c:	83 ec 10             	sub    $0x10,%esp
  80157f:	8b 75 08             	mov    0x8(%ebp),%esi
  801582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801585:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80158f:	c1 e8 0c             	shr    $0xc,%eax
  801592:	50                   	push   %eax
  801593:	e8 36 ff ff ff       	call   8014ce <fd_lookup>
  801598:	83 c4 08             	add    $0x8,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 05                	js     8015a4 <fd_close+0x2d>
	    || fd != fd2)
  80159f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015a2:	74 0c                	je     8015b0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015a4:	84 db                	test   %bl,%bl
  8015a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ab:	0f 44 c2             	cmove  %edx,%eax
  8015ae:	eb 41                	jmp    8015f1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	ff 36                	pushl  (%esi)
  8015b9:	e8 66 ff ff ff       	call   801524 <dev_lookup>
  8015be:	89 c3                	mov    %eax,%ebx
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 1a                	js     8015e1 <fd_close+0x6a>
		if (dev->dev_close)
  8015c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ca:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015cd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	74 0b                	je     8015e1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015d6:	83 ec 0c             	sub    $0xc,%esp
  8015d9:	56                   	push   %esi
  8015da:	ff d0                	call   *%eax
  8015dc:	89 c3                	mov    %eax,%ebx
  8015de:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	56                   	push   %esi
  8015e5:	6a 00                	push   $0x0
  8015e7:	e8 01 fc ff ff       	call   8011ed <sys_page_unmap>
	return r;
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	89 d8                	mov    %ebx,%eax
}
  8015f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5e                   	pop    %esi
  8015f6:	5d                   	pop    %ebp
  8015f7:	c3                   	ret    

008015f8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	ff 75 08             	pushl  0x8(%ebp)
  801605:	e8 c4 fe ff ff       	call   8014ce <fd_lookup>
  80160a:	83 c4 08             	add    $0x8,%esp
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 10                	js     801621 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	6a 01                	push   $0x1
  801616:	ff 75 f4             	pushl  -0xc(%ebp)
  801619:	e8 59 ff ff ff       	call   801577 <fd_close>
  80161e:	83 c4 10             	add    $0x10,%esp
}
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <close_all>:

void
close_all(void)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	53                   	push   %ebx
  801627:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80162a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80162f:	83 ec 0c             	sub    $0xc,%esp
  801632:	53                   	push   %ebx
  801633:	e8 c0 ff ff ff       	call   8015f8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801638:	83 c3 01             	add    $0x1,%ebx
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	83 fb 20             	cmp    $0x20,%ebx
  801641:	75 ec                	jne    80162f <close_all+0xc>
		close(i);
}
  801643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	57                   	push   %edi
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	83 ec 2c             	sub    $0x2c,%esp
  801651:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801654:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801657:	50                   	push   %eax
  801658:	ff 75 08             	pushl  0x8(%ebp)
  80165b:	e8 6e fe ff ff       	call   8014ce <fd_lookup>
  801660:	83 c4 08             	add    $0x8,%esp
  801663:	85 c0                	test   %eax,%eax
  801665:	0f 88 c1 00 00 00    	js     80172c <dup+0xe4>
		return r;
	close(newfdnum);
  80166b:	83 ec 0c             	sub    $0xc,%esp
  80166e:	56                   	push   %esi
  80166f:	e8 84 ff ff ff       	call   8015f8 <close>

	newfd = INDEX2FD(newfdnum);
  801674:	89 f3                	mov    %esi,%ebx
  801676:	c1 e3 0c             	shl    $0xc,%ebx
  801679:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80167f:	83 c4 04             	add    $0x4,%esp
  801682:	ff 75 e4             	pushl  -0x1c(%ebp)
  801685:	e8 de fd ff ff       	call   801468 <fd2data>
  80168a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80168c:	89 1c 24             	mov    %ebx,(%esp)
  80168f:	e8 d4 fd ff ff       	call   801468 <fd2data>
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80169a:	89 f8                	mov    %edi,%eax
  80169c:	c1 e8 16             	shr    $0x16,%eax
  80169f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016a6:	a8 01                	test   $0x1,%al
  8016a8:	74 37                	je     8016e1 <dup+0x99>
  8016aa:	89 f8                	mov    %edi,%eax
  8016ac:	c1 e8 0c             	shr    $0xc,%eax
  8016af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016b6:	f6 c2 01             	test   $0x1,%dl
  8016b9:	74 26                	je     8016e1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016c2:	83 ec 0c             	sub    $0xc,%esp
  8016c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ca:	50                   	push   %eax
  8016cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016ce:	6a 00                	push   $0x0
  8016d0:	57                   	push   %edi
  8016d1:	6a 00                	push   $0x0
  8016d3:	e8 d3 fa ff ff       	call   8011ab <sys_page_map>
  8016d8:	89 c7                	mov    %eax,%edi
  8016da:	83 c4 20             	add    $0x20,%esp
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 2e                	js     80170f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016e4:	89 d0                	mov    %edx,%eax
  8016e6:	c1 e8 0c             	shr    $0xc,%eax
  8016e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8016f8:	50                   	push   %eax
  8016f9:	53                   	push   %ebx
  8016fa:	6a 00                	push   $0x0
  8016fc:	52                   	push   %edx
  8016fd:	6a 00                	push   $0x0
  8016ff:	e8 a7 fa ff ff       	call   8011ab <sys_page_map>
  801704:	89 c7                	mov    %eax,%edi
  801706:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801709:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80170b:	85 ff                	test   %edi,%edi
  80170d:	79 1d                	jns    80172c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80170f:	83 ec 08             	sub    $0x8,%esp
  801712:	53                   	push   %ebx
  801713:	6a 00                	push   $0x0
  801715:	e8 d3 fa ff ff       	call   8011ed <sys_page_unmap>
	sys_page_unmap(0, nva);
  80171a:	83 c4 08             	add    $0x8,%esp
  80171d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801720:	6a 00                	push   $0x0
  801722:	e8 c6 fa ff ff       	call   8011ed <sys_page_unmap>
	return r;
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	89 f8                	mov    %edi,%eax
}
  80172c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172f:	5b                   	pop    %ebx
  801730:	5e                   	pop    %esi
  801731:	5f                   	pop    %edi
  801732:	5d                   	pop    %ebp
  801733:	c3                   	ret    

00801734 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	83 ec 14             	sub    $0x14,%esp
  80173b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801741:	50                   	push   %eax
  801742:	53                   	push   %ebx
  801743:	e8 86 fd ff ff       	call   8014ce <fd_lookup>
  801748:	83 c4 08             	add    $0x8,%esp
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 6d                	js     8017be <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801757:	50                   	push   %eax
  801758:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175b:	ff 30                	pushl  (%eax)
  80175d:	e8 c2 fd ff ff       	call   801524 <dev_lookup>
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	78 4c                	js     8017b5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801769:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80176c:	8b 42 08             	mov    0x8(%edx),%eax
  80176f:	83 e0 03             	and    $0x3,%eax
  801772:	83 f8 01             	cmp    $0x1,%eax
  801775:	75 21                	jne    801798 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801777:	a1 04 40 80 00       	mov    0x804004,%eax
  80177c:	8b 40 48             	mov    0x48(%eax),%eax
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	53                   	push   %ebx
  801783:	50                   	push   %eax
  801784:	68 ac 2b 80 00       	push   $0x802bac
  801789:	e8 d3 ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801796:	eb 26                	jmp    8017be <read+0x8a>
	}
	if (!dev->dev_read)
  801798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179b:	8b 40 08             	mov    0x8(%eax),%eax
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	74 17                	je     8017b9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017a2:	83 ec 04             	sub    $0x4,%esp
  8017a5:	ff 75 10             	pushl  0x10(%ebp)
  8017a8:	ff 75 0c             	pushl  0xc(%ebp)
  8017ab:	52                   	push   %edx
  8017ac:	ff d0                	call   *%eax
  8017ae:	89 c2                	mov    %eax,%edx
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	eb 09                	jmp    8017be <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b5:	89 c2                	mov    %eax,%edx
  8017b7:	eb 05                	jmp    8017be <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017be:	89 d0                	mov    %edx,%eax
  8017c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    

008017c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	57                   	push   %edi
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017d9:	eb 21                	jmp    8017fc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017db:	83 ec 04             	sub    $0x4,%esp
  8017de:	89 f0                	mov    %esi,%eax
  8017e0:	29 d8                	sub    %ebx,%eax
  8017e2:	50                   	push   %eax
  8017e3:	89 d8                	mov    %ebx,%eax
  8017e5:	03 45 0c             	add    0xc(%ebp),%eax
  8017e8:	50                   	push   %eax
  8017e9:	57                   	push   %edi
  8017ea:	e8 45 ff ff ff       	call   801734 <read>
		if (m < 0)
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	78 10                	js     801806 <readn+0x41>
			return m;
		if (m == 0)
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	74 0a                	je     801804 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017fa:	01 c3                	add    %eax,%ebx
  8017fc:	39 f3                	cmp    %esi,%ebx
  8017fe:	72 db                	jb     8017db <readn+0x16>
  801800:	89 d8                	mov    %ebx,%eax
  801802:	eb 02                	jmp    801806 <readn+0x41>
  801804:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801806:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5f                   	pop    %edi
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    

0080180e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 14             	sub    $0x14,%esp
  801815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801818:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181b:	50                   	push   %eax
  80181c:	53                   	push   %ebx
  80181d:	e8 ac fc ff ff       	call   8014ce <fd_lookup>
  801822:	83 c4 08             	add    $0x8,%esp
  801825:	89 c2                	mov    %eax,%edx
  801827:	85 c0                	test   %eax,%eax
  801829:	78 68                	js     801893 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801835:	ff 30                	pushl  (%eax)
  801837:	e8 e8 fc ff ff       	call   801524 <dev_lookup>
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 47                	js     80188a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801843:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801846:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80184a:	75 21                	jne    80186d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80184c:	a1 04 40 80 00       	mov    0x804004,%eax
  801851:	8b 40 48             	mov    0x48(%eax),%eax
  801854:	83 ec 04             	sub    $0x4,%esp
  801857:	53                   	push   %ebx
  801858:	50                   	push   %eax
  801859:	68 c8 2b 80 00       	push   $0x802bc8
  80185e:	e8 fe ee ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80186b:	eb 26                	jmp    801893 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80186d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801870:	8b 52 0c             	mov    0xc(%edx),%edx
  801873:	85 d2                	test   %edx,%edx
  801875:	74 17                	je     80188e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801877:	83 ec 04             	sub    $0x4,%esp
  80187a:	ff 75 10             	pushl  0x10(%ebp)
  80187d:	ff 75 0c             	pushl  0xc(%ebp)
  801880:	50                   	push   %eax
  801881:	ff d2                	call   *%edx
  801883:	89 c2                	mov    %eax,%edx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	eb 09                	jmp    801893 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188a:	89 c2                	mov    %eax,%edx
  80188c:	eb 05                	jmp    801893 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80188e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801893:	89 d0                	mov    %edx,%eax
  801895:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <seek>:

int
seek(int fdnum, off_t offset)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018a3:	50                   	push   %eax
  8018a4:	ff 75 08             	pushl  0x8(%ebp)
  8018a7:	e8 22 fc ff ff       	call   8014ce <fd_lookup>
  8018ac:	83 c4 08             	add    $0x8,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 0e                	js     8018c1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	53                   	push   %ebx
  8018c7:	83 ec 14             	sub    $0x14,%esp
  8018ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d0:	50                   	push   %eax
  8018d1:	53                   	push   %ebx
  8018d2:	e8 f7 fb ff ff       	call   8014ce <fd_lookup>
  8018d7:	83 c4 08             	add    $0x8,%esp
  8018da:	89 c2                	mov    %eax,%edx
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 65                	js     801945 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e6:	50                   	push   %eax
  8018e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ea:	ff 30                	pushl  (%eax)
  8018ec:	e8 33 fc ff ff       	call   801524 <dev_lookup>
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 44                	js     80193c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ff:	75 21                	jne    801922 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801901:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801906:	8b 40 48             	mov    0x48(%eax),%eax
  801909:	83 ec 04             	sub    $0x4,%esp
  80190c:	53                   	push   %ebx
  80190d:	50                   	push   %eax
  80190e:	68 88 2b 80 00       	push   $0x802b88
  801913:	e8 49 ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801920:	eb 23                	jmp    801945 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801922:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801925:	8b 52 18             	mov    0x18(%edx),%edx
  801928:	85 d2                	test   %edx,%edx
  80192a:	74 14                	je     801940 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80192c:	83 ec 08             	sub    $0x8,%esp
  80192f:	ff 75 0c             	pushl  0xc(%ebp)
  801932:	50                   	push   %eax
  801933:	ff d2                	call   *%edx
  801935:	89 c2                	mov    %eax,%edx
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	eb 09                	jmp    801945 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80193c:	89 c2                	mov    %eax,%edx
  80193e:	eb 05                	jmp    801945 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801940:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801945:	89 d0                	mov    %edx,%eax
  801947:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	53                   	push   %ebx
  801950:	83 ec 14             	sub    $0x14,%esp
  801953:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801956:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801959:	50                   	push   %eax
  80195a:	ff 75 08             	pushl  0x8(%ebp)
  80195d:	e8 6c fb ff ff       	call   8014ce <fd_lookup>
  801962:	83 c4 08             	add    $0x8,%esp
  801965:	89 c2                	mov    %eax,%edx
  801967:	85 c0                	test   %eax,%eax
  801969:	78 58                	js     8019c3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801971:	50                   	push   %eax
  801972:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801975:	ff 30                	pushl  (%eax)
  801977:	e8 a8 fb ff ff       	call   801524 <dev_lookup>
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	85 c0                	test   %eax,%eax
  801981:	78 37                	js     8019ba <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801983:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801986:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80198a:	74 32                	je     8019be <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80198c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80198f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801996:	00 00 00 
	stat->st_isdir = 0;
  801999:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a0:	00 00 00 
	stat->st_dev = dev;
  8019a3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	53                   	push   %ebx
  8019ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b0:	ff 50 14             	call   *0x14(%eax)
  8019b3:	89 c2                	mov    %eax,%edx
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	eb 09                	jmp    8019c3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ba:	89 c2                	mov    %eax,%edx
  8019bc:	eb 05                	jmp    8019c3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019c3:	89 d0                	mov    %edx,%eax
  8019c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	56                   	push   %esi
  8019ce:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	6a 00                	push   $0x0
  8019d4:	ff 75 08             	pushl  0x8(%ebp)
  8019d7:	e8 e3 01 00 00       	call   801bbf <open>
  8019dc:	89 c3                	mov    %eax,%ebx
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	78 1b                	js     801a00 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019e5:	83 ec 08             	sub    $0x8,%esp
  8019e8:	ff 75 0c             	pushl  0xc(%ebp)
  8019eb:	50                   	push   %eax
  8019ec:	e8 5b ff ff ff       	call   80194c <fstat>
  8019f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8019f3:	89 1c 24             	mov    %ebx,(%esp)
  8019f6:	e8 fd fb ff ff       	call   8015f8 <close>
	return r;
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	89 f0                	mov    %esi,%eax
}
  801a00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    

00801a07 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	56                   	push   %esi
  801a0b:	53                   	push   %ebx
  801a0c:	89 c6                	mov    %eax,%esi
  801a0e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a10:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a17:	75 12                	jne    801a2b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	6a 01                	push   $0x1
  801a1e:	e8 fc f9 ff ff       	call   80141f <ipc_find_env>
  801a23:	a3 00 40 80 00       	mov    %eax,0x804000
  801a28:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a2b:	6a 07                	push   $0x7
  801a2d:	68 00 50 80 00       	push   $0x805000
  801a32:	56                   	push   %esi
  801a33:	ff 35 00 40 80 00    	pushl  0x804000
  801a39:	e8 8d f9 ff ff       	call   8013cb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a3e:	83 c4 0c             	add    $0xc,%esp
  801a41:	6a 00                	push   $0x0
  801a43:	53                   	push   %ebx
  801a44:	6a 00                	push   $0x0
  801a46:	e8 0e f9 ff ff       	call   801359 <ipc_recv>
}
  801a4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4e:	5b                   	pop    %ebx
  801a4f:	5e                   	pop    %esi
  801a50:	5d                   	pop    %ebp
  801a51:	c3                   	ret    

00801a52 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a58:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a66:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a70:	b8 02 00 00 00       	mov    $0x2,%eax
  801a75:	e8 8d ff ff ff       	call   801a07 <fsipc>
}
  801a7a:	c9                   	leave  
  801a7b:	c3                   	ret    

00801a7c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a82:	8b 45 08             	mov    0x8(%ebp),%eax
  801a85:	8b 40 0c             	mov    0xc(%eax),%eax
  801a88:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a92:	b8 06 00 00 00       	mov    $0x6,%eax
  801a97:	e8 6b ff ff ff       	call   801a07 <fsipc>
}
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	53                   	push   %ebx
  801aa2:	83 ec 04             	sub    $0x4,%esp
  801aa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801aab:	8b 40 0c             	mov    0xc(%eax),%eax
  801aae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ab3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab8:	b8 05 00 00 00       	mov    $0x5,%eax
  801abd:	e8 45 ff ff ff       	call   801a07 <fsipc>
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 2c                	js     801af2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ac6:	83 ec 08             	sub    $0x8,%esp
  801ac9:	68 00 50 80 00       	push   $0x805000
  801ace:	53                   	push   %ebx
  801acf:	e8 91 f2 ff ff       	call   800d65 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ad4:	a1 80 50 80 00       	mov    0x805080,%eax
  801ad9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801adf:	a1 84 50 80 00       	mov    0x805084,%eax
  801ae4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b00:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b05:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b0a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b10:	8b 52 0c             	mov    0xc(%edx),%edx
  801b13:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801b19:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b1e:	50                   	push   %eax
  801b1f:	ff 75 0c             	pushl  0xc(%ebp)
  801b22:	68 08 50 80 00       	push   $0x805008
  801b27:	e8 cb f3 ff ff       	call   800ef7 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  801b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b31:	b8 04 00 00 00       	mov    $0x4,%eax
  801b36:	e8 cc fe ff ff       	call   801a07 <fsipc>
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b45:	8b 45 08             	mov    0x8(%ebp),%eax
  801b48:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b50:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b56:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5b:	b8 03 00 00 00       	mov    $0x3,%eax
  801b60:	e8 a2 fe ff ff       	call   801a07 <fsipc>
  801b65:	89 c3                	mov    %eax,%ebx
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 4b                	js     801bb6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b6b:	39 c6                	cmp    %eax,%esi
  801b6d:	73 16                	jae    801b85 <devfile_read+0x48>
  801b6f:	68 f8 2b 80 00       	push   $0x802bf8
  801b74:	68 ff 2b 80 00       	push   $0x802bff
  801b79:	6a 7c                	push   $0x7c
  801b7b:	68 14 2c 80 00       	push   $0x802c14
  801b80:	e8 03 eb ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801b85:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b8a:	7e 16                	jle    801ba2 <devfile_read+0x65>
  801b8c:	68 1f 2c 80 00       	push   $0x802c1f
  801b91:	68 ff 2b 80 00       	push   $0x802bff
  801b96:	6a 7d                	push   $0x7d
  801b98:	68 14 2c 80 00       	push   $0x802c14
  801b9d:	e8 e6 ea ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ba2:	83 ec 04             	sub    $0x4,%esp
  801ba5:	50                   	push   %eax
  801ba6:	68 00 50 80 00       	push   $0x805000
  801bab:	ff 75 0c             	pushl  0xc(%ebp)
  801bae:	e8 44 f3 ff ff       	call   800ef7 <memmove>
	return r;
  801bb3:	83 c4 10             	add    $0x10,%esp
}
  801bb6:	89 d8                	mov    %ebx,%eax
  801bb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 20             	sub    $0x20,%esp
  801bc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bc9:	53                   	push   %ebx
  801bca:	e8 5d f1 ff ff       	call   800d2c <strlen>
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bd7:	7f 67                	jg     801c40 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bd9:	83 ec 0c             	sub    $0xc,%esp
  801bdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdf:	50                   	push   %eax
  801be0:	e8 9a f8 ff ff       	call   80147f <fd_alloc>
  801be5:	83 c4 10             	add    $0x10,%esp
		return r;
  801be8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bea:	85 c0                	test   %eax,%eax
  801bec:	78 57                	js     801c45 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bee:	83 ec 08             	sub    $0x8,%esp
  801bf1:	53                   	push   %ebx
  801bf2:	68 00 50 80 00       	push   $0x805000
  801bf7:	e8 69 f1 ff ff       	call   800d65 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c07:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0c:	e8 f6 fd ff ff       	call   801a07 <fsipc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	85 c0                	test   %eax,%eax
  801c18:	79 14                	jns    801c2e <open+0x6f>
		fd_close(fd, 0);
  801c1a:	83 ec 08             	sub    $0x8,%esp
  801c1d:	6a 00                	push   $0x0
  801c1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c22:	e8 50 f9 ff ff       	call   801577 <fd_close>
		return r;
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	89 da                	mov    %ebx,%edx
  801c2c:	eb 17                	jmp    801c45 <open+0x86>
	}

	return fd2num(fd);
  801c2e:	83 ec 0c             	sub    $0xc,%esp
  801c31:	ff 75 f4             	pushl  -0xc(%ebp)
  801c34:	e8 1f f8 ff ff       	call   801458 <fd2num>
  801c39:	89 c2                	mov    %eax,%edx
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	eb 05                	jmp    801c45 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c40:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c45:	89 d0                	mov    %edx,%eax
  801c47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c52:	ba 00 00 00 00       	mov    $0x0,%edx
  801c57:	b8 08 00 00 00       	mov    $0x8,%eax
  801c5c:	e8 a6 fd ff ff       	call   801a07 <fsipc>
}
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c6b:	83 ec 0c             	sub    $0xc,%esp
  801c6e:	ff 75 08             	pushl  0x8(%ebp)
  801c71:	e8 f2 f7 ff ff       	call   801468 <fd2data>
  801c76:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c78:	83 c4 08             	add    $0x8,%esp
  801c7b:	68 2b 2c 80 00       	push   $0x802c2b
  801c80:	53                   	push   %ebx
  801c81:	e8 df f0 ff ff       	call   800d65 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c86:	8b 46 04             	mov    0x4(%esi),%eax
  801c89:	2b 06                	sub    (%esi),%eax
  801c8b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c91:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c98:	00 00 00 
	stat->st_dev = &devpipe;
  801c9b:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801ca2:	30 80 00 
	return 0;
}
  801ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  801caa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	53                   	push   %ebx
  801cb5:	83 ec 0c             	sub    $0xc,%esp
  801cb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cbb:	53                   	push   %ebx
  801cbc:	6a 00                	push   $0x0
  801cbe:	e8 2a f5 ff ff       	call   8011ed <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cc3:	89 1c 24             	mov    %ebx,(%esp)
  801cc6:	e8 9d f7 ff ff       	call   801468 <fd2data>
  801ccb:	83 c4 08             	add    $0x8,%esp
  801cce:	50                   	push   %eax
  801ccf:	6a 00                	push   $0x0
  801cd1:	e8 17 f5 ff ff       	call   8011ed <sys_page_unmap>
}
  801cd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	57                   	push   %edi
  801cdf:	56                   	push   %esi
  801ce0:	53                   	push   %ebx
  801ce1:	83 ec 1c             	sub    $0x1c,%esp
  801ce4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ce7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ce9:	a1 04 40 80 00       	mov    0x804004,%eax
  801cee:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cf1:	83 ec 0c             	sub    $0xc,%esp
  801cf4:	ff 75 e0             	pushl  -0x20(%ebp)
  801cf7:	e8 46 04 00 00       	call   802142 <pageref>
  801cfc:	89 c3                	mov    %eax,%ebx
  801cfe:	89 3c 24             	mov    %edi,(%esp)
  801d01:	e8 3c 04 00 00       	call   802142 <pageref>
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	39 c3                	cmp    %eax,%ebx
  801d0b:	0f 94 c1             	sete   %cl
  801d0e:	0f b6 c9             	movzbl %cl,%ecx
  801d11:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d14:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d1a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d1d:	39 ce                	cmp    %ecx,%esi
  801d1f:	74 1b                	je     801d3c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d21:	39 c3                	cmp    %eax,%ebx
  801d23:	75 c4                	jne    801ce9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d25:	8b 42 58             	mov    0x58(%edx),%eax
  801d28:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d2b:	50                   	push   %eax
  801d2c:	56                   	push   %esi
  801d2d:	68 32 2c 80 00       	push   $0x802c32
  801d32:	e8 2a ea ff ff       	call   800761 <cprintf>
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	eb ad                	jmp    801ce9 <_pipeisclosed+0xe>
	}
}
  801d3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d42:	5b                   	pop    %ebx
  801d43:	5e                   	pop    %esi
  801d44:	5f                   	pop    %edi
  801d45:	5d                   	pop    %ebp
  801d46:	c3                   	ret    

00801d47 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	57                   	push   %edi
  801d4b:	56                   	push   %esi
  801d4c:	53                   	push   %ebx
  801d4d:	83 ec 28             	sub    $0x28,%esp
  801d50:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d53:	56                   	push   %esi
  801d54:	e8 0f f7 ff ff       	call   801468 <fd2data>
  801d59:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	bf 00 00 00 00       	mov    $0x0,%edi
  801d63:	eb 4b                	jmp    801db0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d65:	89 da                	mov    %ebx,%edx
  801d67:	89 f0                	mov    %esi,%eax
  801d69:	e8 6d ff ff ff       	call   801cdb <_pipeisclosed>
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	75 48                	jne    801dba <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d72:	e8 d2 f3 ff ff       	call   801149 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d77:	8b 43 04             	mov    0x4(%ebx),%eax
  801d7a:	8b 0b                	mov    (%ebx),%ecx
  801d7c:	8d 51 20             	lea    0x20(%ecx),%edx
  801d7f:	39 d0                	cmp    %edx,%eax
  801d81:	73 e2                	jae    801d65 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d86:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d8a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d8d:	89 c2                	mov    %eax,%edx
  801d8f:	c1 fa 1f             	sar    $0x1f,%edx
  801d92:	89 d1                	mov    %edx,%ecx
  801d94:	c1 e9 1b             	shr    $0x1b,%ecx
  801d97:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d9a:	83 e2 1f             	and    $0x1f,%edx
  801d9d:	29 ca                	sub    %ecx,%edx
  801d9f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801da3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801da7:	83 c0 01             	add    $0x1,%eax
  801daa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dad:	83 c7 01             	add    $0x1,%edi
  801db0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801db3:	75 c2                	jne    801d77 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801db5:	8b 45 10             	mov    0x10(%ebp),%eax
  801db8:	eb 05                	jmp    801dbf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dba:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc2:	5b                   	pop    %ebx
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	57                   	push   %edi
  801dcb:	56                   	push   %esi
  801dcc:	53                   	push   %ebx
  801dcd:	83 ec 18             	sub    $0x18,%esp
  801dd0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dd3:	57                   	push   %edi
  801dd4:	e8 8f f6 ff ff       	call   801468 <fd2data>
  801dd9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	bb 00 00 00 00       	mov    $0x0,%ebx
  801de3:	eb 3d                	jmp    801e22 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801de5:	85 db                	test   %ebx,%ebx
  801de7:	74 04                	je     801ded <devpipe_read+0x26>
				return i;
  801de9:	89 d8                	mov    %ebx,%eax
  801deb:	eb 44                	jmp    801e31 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ded:	89 f2                	mov    %esi,%edx
  801def:	89 f8                	mov    %edi,%eax
  801df1:	e8 e5 fe ff ff       	call   801cdb <_pipeisclosed>
  801df6:	85 c0                	test   %eax,%eax
  801df8:	75 32                	jne    801e2c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dfa:	e8 4a f3 ff ff       	call   801149 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dff:	8b 06                	mov    (%esi),%eax
  801e01:	3b 46 04             	cmp    0x4(%esi),%eax
  801e04:	74 df                	je     801de5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e06:	99                   	cltd   
  801e07:	c1 ea 1b             	shr    $0x1b,%edx
  801e0a:	01 d0                	add    %edx,%eax
  801e0c:	83 e0 1f             	and    $0x1f,%eax
  801e0f:	29 d0                	sub    %edx,%eax
  801e11:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e19:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e1c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e1f:	83 c3 01             	add    $0x1,%ebx
  801e22:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e25:	75 d8                	jne    801dff <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e27:	8b 45 10             	mov    0x10(%ebp),%eax
  801e2a:	eb 05                	jmp    801e31 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e2c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    

00801e39 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	56                   	push   %esi
  801e3d:	53                   	push   %ebx
  801e3e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e44:	50                   	push   %eax
  801e45:	e8 35 f6 ff ff       	call   80147f <fd_alloc>
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	89 c2                	mov    %eax,%edx
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	0f 88 2c 01 00 00    	js     801f83 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e57:	83 ec 04             	sub    $0x4,%esp
  801e5a:	68 07 04 00 00       	push   $0x407
  801e5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e62:	6a 00                	push   $0x0
  801e64:	e8 ff f2 ff ff       	call   801168 <sys_page_alloc>
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	89 c2                	mov    %eax,%edx
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	0f 88 0d 01 00 00    	js     801f83 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e76:	83 ec 0c             	sub    $0xc,%esp
  801e79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e7c:	50                   	push   %eax
  801e7d:	e8 fd f5 ff ff       	call   80147f <fd_alloc>
  801e82:	89 c3                	mov    %eax,%ebx
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	85 c0                	test   %eax,%eax
  801e89:	0f 88 e2 00 00 00    	js     801f71 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8f:	83 ec 04             	sub    $0x4,%esp
  801e92:	68 07 04 00 00       	push   $0x407
  801e97:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9a:	6a 00                	push   $0x0
  801e9c:	e8 c7 f2 ff ff       	call   801168 <sys_page_alloc>
  801ea1:	89 c3                	mov    %eax,%ebx
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	0f 88 c3 00 00 00    	js     801f71 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb4:	e8 af f5 ff ff       	call   801468 <fd2data>
  801eb9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebb:	83 c4 0c             	add    $0xc,%esp
  801ebe:	68 07 04 00 00       	push   $0x407
  801ec3:	50                   	push   %eax
  801ec4:	6a 00                	push   $0x0
  801ec6:	e8 9d f2 ff ff       	call   801168 <sys_page_alloc>
  801ecb:	89 c3                	mov    %eax,%ebx
  801ecd:	83 c4 10             	add    $0x10,%esp
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	0f 88 89 00 00 00    	js     801f61 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed8:	83 ec 0c             	sub    $0xc,%esp
  801edb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ede:	e8 85 f5 ff ff       	call   801468 <fd2data>
  801ee3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eea:	50                   	push   %eax
  801eeb:	6a 00                	push   $0x0
  801eed:	56                   	push   %esi
  801eee:	6a 00                	push   $0x0
  801ef0:	e8 b6 f2 ff ff       	call   8011ab <sys_page_map>
  801ef5:	89 c3                	mov    %eax,%ebx
  801ef7:	83 c4 20             	add    $0x20,%esp
  801efa:	85 c0                	test   %eax,%eax
  801efc:	78 55                	js     801f53 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801efe:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f07:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f13:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f1c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f21:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f28:	83 ec 0c             	sub    $0xc,%esp
  801f2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2e:	e8 25 f5 ff ff       	call   801458 <fd2num>
  801f33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f36:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f38:	83 c4 04             	add    $0x4,%esp
  801f3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f3e:	e8 15 f5 ff ff       	call   801458 <fd2num>
  801f43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f46:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801f51:	eb 30                	jmp    801f83 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f53:	83 ec 08             	sub    $0x8,%esp
  801f56:	56                   	push   %esi
  801f57:	6a 00                	push   $0x0
  801f59:	e8 8f f2 ff ff       	call   8011ed <sys_page_unmap>
  801f5e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f61:	83 ec 08             	sub    $0x8,%esp
  801f64:	ff 75 f0             	pushl  -0x10(%ebp)
  801f67:	6a 00                	push   $0x0
  801f69:	e8 7f f2 ff ff       	call   8011ed <sys_page_unmap>
  801f6e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f71:	83 ec 08             	sub    $0x8,%esp
  801f74:	ff 75 f4             	pushl  -0xc(%ebp)
  801f77:	6a 00                	push   $0x0
  801f79:	e8 6f f2 ff ff       	call   8011ed <sys_page_unmap>
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f83:	89 d0                	mov    %edx,%eax
  801f85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f88:	5b                   	pop    %ebx
  801f89:	5e                   	pop    %esi
  801f8a:	5d                   	pop    %ebp
  801f8b:	c3                   	ret    

00801f8c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f95:	50                   	push   %eax
  801f96:	ff 75 08             	pushl  0x8(%ebp)
  801f99:	e8 30 f5 ff ff       	call   8014ce <fd_lookup>
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	78 18                	js     801fbd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fa5:	83 ec 0c             	sub    $0xc,%esp
  801fa8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fab:	e8 b8 f4 ff ff       	call   801468 <fd2data>
	return _pipeisclosed(fd, p);
  801fb0:	89 c2                	mov    %eax,%edx
  801fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb5:	e8 21 fd ff ff       	call   801cdb <_pipeisclosed>
  801fba:	83 c4 10             	add    $0x10,%esp
}
  801fbd:	c9                   	leave  
  801fbe:	c3                   	ret    

00801fbf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fc2:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fcf:	68 4a 2c 80 00       	push   $0x802c4a
  801fd4:	ff 75 0c             	pushl  0xc(%ebp)
  801fd7:	e8 89 ed ff ff       	call   800d65 <strcpy>
	return 0;
}
  801fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    

00801fe3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	57                   	push   %edi
  801fe7:	56                   	push   %esi
  801fe8:	53                   	push   %ebx
  801fe9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fef:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ff4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ffa:	eb 2d                	jmp    802029 <devcons_write+0x46>
		m = n - tot;
  801ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fff:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802001:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802004:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802009:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80200c:	83 ec 04             	sub    $0x4,%esp
  80200f:	53                   	push   %ebx
  802010:	03 45 0c             	add    0xc(%ebp),%eax
  802013:	50                   	push   %eax
  802014:	57                   	push   %edi
  802015:	e8 dd ee ff ff       	call   800ef7 <memmove>
		sys_cputs(buf, m);
  80201a:	83 c4 08             	add    $0x8,%esp
  80201d:	53                   	push   %ebx
  80201e:	57                   	push   %edi
  80201f:	e8 88 f0 ff ff       	call   8010ac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802024:	01 de                	add    %ebx,%esi
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	89 f0                	mov    %esi,%eax
  80202b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80202e:	72 cc                	jb     801ffc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802030:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    

00802038 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
  80203b:	83 ec 08             	sub    $0x8,%esp
  80203e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802043:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802047:	74 2a                	je     802073 <devcons_read+0x3b>
  802049:	eb 05                	jmp    802050 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80204b:	e8 f9 f0 ff ff       	call   801149 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802050:	e8 75 f0 ff ff       	call   8010ca <sys_cgetc>
  802055:	85 c0                	test   %eax,%eax
  802057:	74 f2                	je     80204b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802059:	85 c0                	test   %eax,%eax
  80205b:	78 16                	js     802073 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80205d:	83 f8 04             	cmp    $0x4,%eax
  802060:	74 0c                	je     80206e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802062:	8b 55 0c             	mov    0xc(%ebp),%edx
  802065:	88 02                	mov    %al,(%edx)
	return 1;
  802067:	b8 01 00 00 00       	mov    $0x1,%eax
  80206c:	eb 05                	jmp    802073 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80206e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802073:	c9                   	leave  
  802074:	c3                   	ret    

00802075 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80207b:	8b 45 08             	mov    0x8(%ebp),%eax
  80207e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802081:	6a 01                	push   $0x1
  802083:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802086:	50                   	push   %eax
  802087:	e8 20 f0 ff ff       	call   8010ac <sys_cputs>
}
  80208c:	83 c4 10             	add    $0x10,%esp
  80208f:	c9                   	leave  
  802090:	c3                   	ret    

00802091 <getchar>:

int
getchar(void)
{
  802091:	55                   	push   %ebp
  802092:	89 e5                	mov    %esp,%ebp
  802094:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802097:	6a 01                	push   $0x1
  802099:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209c:	50                   	push   %eax
  80209d:	6a 00                	push   $0x0
  80209f:	e8 90 f6 ff ff       	call   801734 <read>
	if (r < 0)
  8020a4:	83 c4 10             	add    $0x10,%esp
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	78 0f                	js     8020ba <getchar+0x29>
		return r;
	if (r < 1)
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	7e 06                	jle    8020b5 <getchar+0x24>
		return -E_EOF;
	return c;
  8020af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020b3:	eb 05                	jmp    8020ba <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020ba:	c9                   	leave  
  8020bb:	c3                   	ret    

008020bc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c5:	50                   	push   %eax
  8020c6:	ff 75 08             	pushl  0x8(%ebp)
  8020c9:	e8 00 f4 ff ff       	call   8014ce <fd_lookup>
  8020ce:	83 c4 10             	add    $0x10,%esp
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	78 11                	js     8020e6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d8:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020de:	39 10                	cmp    %edx,(%eax)
  8020e0:	0f 94 c0             	sete   %al
  8020e3:	0f b6 c0             	movzbl %al,%eax
}
  8020e6:	c9                   	leave  
  8020e7:	c3                   	ret    

008020e8 <opencons>:

int
opencons(void)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f1:	50                   	push   %eax
  8020f2:	e8 88 f3 ff ff       	call   80147f <fd_alloc>
  8020f7:	83 c4 10             	add    $0x10,%esp
		return r;
  8020fa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	78 3e                	js     80213e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802100:	83 ec 04             	sub    $0x4,%esp
  802103:	68 07 04 00 00       	push   $0x407
  802108:	ff 75 f4             	pushl  -0xc(%ebp)
  80210b:	6a 00                	push   $0x0
  80210d:	e8 56 f0 ff ff       	call   801168 <sys_page_alloc>
  802112:	83 c4 10             	add    $0x10,%esp
		return r;
  802115:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802117:	85 c0                	test   %eax,%eax
  802119:	78 23                	js     80213e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80211b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802121:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802124:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802126:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802129:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802130:	83 ec 0c             	sub    $0xc,%esp
  802133:	50                   	push   %eax
  802134:	e8 1f f3 ff ff       	call   801458 <fd2num>
  802139:	89 c2                	mov    %eax,%edx
  80213b:	83 c4 10             	add    $0x10,%esp
}
  80213e:	89 d0                	mov    %edx,%eax
  802140:	c9                   	leave  
  802141:	c3                   	ret    

00802142 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802148:	89 d0                	mov    %edx,%eax
  80214a:	c1 e8 16             	shr    $0x16,%eax
  80214d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802154:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802159:	f6 c1 01             	test   $0x1,%cl
  80215c:	74 1d                	je     80217b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80215e:	c1 ea 0c             	shr    $0xc,%edx
  802161:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802168:	f6 c2 01             	test   $0x1,%dl
  80216b:	74 0e                	je     80217b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80216d:	c1 ea 0c             	shr    $0xc,%edx
  802170:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802177:	ef 
  802178:	0f b7 c0             	movzwl %ax,%eax
}
  80217b:	5d                   	pop    %ebp
  80217c:	c3                   	ret    
  80217d:	66 90                	xchg   %ax,%ax
  80217f:	90                   	nop

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80218b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80218f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 f6                	test   %esi,%esi
  802199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80219d:	89 ca                	mov    %ecx,%edx
  80219f:	89 f8                	mov    %edi,%eax
  8021a1:	75 3d                	jne    8021e0 <__udivdi3+0x60>
  8021a3:	39 cf                	cmp    %ecx,%edi
  8021a5:	0f 87 c5 00 00 00    	ja     802270 <__udivdi3+0xf0>
  8021ab:	85 ff                	test   %edi,%edi
  8021ad:	89 fd                	mov    %edi,%ebp
  8021af:	75 0b                	jne    8021bc <__udivdi3+0x3c>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	f7 f7                	div    %edi
  8021ba:	89 c5                	mov    %eax,%ebp
  8021bc:	89 c8                	mov    %ecx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f5                	div    %ebp
  8021c2:	89 c1                	mov    %eax,%ecx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	89 cf                	mov    %ecx,%edi
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 ce                	cmp    %ecx,%esi
  8021e2:	77 74                	ja     802258 <__udivdi3+0xd8>
  8021e4:	0f bd fe             	bsr    %esi,%edi
  8021e7:	83 f7 1f             	xor    $0x1f,%edi
  8021ea:	0f 84 98 00 00 00    	je     802288 <__udivdi3+0x108>
  8021f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	29 fb                	sub    %edi,%ebx
  8021fb:	d3 e6                	shl    %cl,%esi
  8021fd:	89 d9                	mov    %ebx,%ecx
  8021ff:	d3 ed                	shr    %cl,%ebp
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	09 ee                	or     %ebp,%esi
  802207:	89 d9                	mov    %ebx,%ecx
  802209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220d:	89 d5                	mov    %edx,%ebp
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	d3 ed                	shr    %cl,%ebp
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 d9                	mov    %ebx,%ecx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 d0                	mov    %edx,%eax
  802221:	89 ea                	mov    %ebp,%edx
  802223:	f7 f6                	div    %esi
  802225:	89 d5                	mov    %edx,%ebp
  802227:	89 c3                	mov    %eax,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	72 10                	jb     802241 <__udivdi3+0xc1>
  802231:	8b 74 24 08          	mov    0x8(%esp),%esi
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e6                	shl    %cl,%esi
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	73 07                	jae    802244 <__udivdi3+0xc4>
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	75 03                	jne    802244 <__udivdi3+0xc4>
  802241:	83 eb 01             	sub    $0x1,%ebx
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 d8                	mov    %ebx,%eax
  802248:	89 fa                	mov    %edi,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	31 ff                	xor    %edi,%edi
  80225a:	31 db                	xor    %ebx,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d8                	mov    %ebx,%eax
  802272:	f7 f7                	div    %edi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 c3                	mov    %eax,%ebx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 fa                	mov    %edi,%edx
  80227c:	83 c4 1c             	add    $0x1c,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	72 0c                	jb     802298 <__udivdi3+0x118>
  80228c:	31 db                	xor    %ebx,%ebx
  80228e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802292:	0f 87 34 ff ff ff    	ja     8021cc <__udivdi3+0x4c>
  802298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80229d:	e9 2a ff ff ff       	jmp    8021cc <__udivdi3+0x4c>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f3                	mov    %esi,%ebx
  8022d3:	89 3c 24             	mov    %edi,(%esp)
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	75 1c                	jne    8022f8 <__umoddi3+0x48>
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	76 50                	jbe    802330 <__umoddi3+0x80>
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	f7 f7                	div    %edi
  8022e6:	89 d0                	mov    %edx,%eax
  8022e8:	31 d2                	xor    %edx,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	77 52                	ja     802350 <__umoddi3+0xa0>
  8022fe:	0f bd ea             	bsr    %edx,%ebp
  802301:	83 f5 1f             	xor    $0x1f,%ebp
  802304:	75 5a                	jne    802360 <__umoddi3+0xb0>
  802306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	39 0c 24             	cmp    %ecx,(%esp)
  802313:	0f 86 d7 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  802319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80231d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	85 ff                	test   %edi,%edi
  802332:	89 fd                	mov    %edi,%ebp
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	eb 99                	jmp    8022e8 <__umoddi3+0x38>
  80234f:	90                   	nop
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 1c             	add    $0x1c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	8b 34 24             	mov    (%esp),%esi
  802363:	bf 20 00 00 00       	mov    $0x20,%edi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	29 ef                	sub    %ebp,%edi
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	89 f2                	mov    %esi,%edx
  802372:	d3 ea                	shr    %cl,%edx
  802374:	89 e9                	mov    %ebp,%ecx
  802376:	09 c2                	or     %eax,%edx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 14 24             	mov    %edx,(%esp)
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	d3 e2                	shl    %cl,%edx
  802381:	89 f9                	mov    %edi,%ecx
  802383:	89 54 24 04          	mov    %edx,0x4(%esp)
  802387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	89 c6                	mov    %eax,%esi
  802391:	d3 e3                	shl    %cl,%ebx
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 d0                	mov    %edx,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	09 d8                	or     %ebx,%eax
  80239d:	89 d3                	mov    %edx,%ebx
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	f7 34 24             	divl   (%esp)
  8023a4:	89 d6                	mov    %edx,%esi
  8023a6:	d3 e3                	shl    %cl,%ebx
  8023a8:	f7 64 24 04          	mull   0x4(%esp)
  8023ac:	39 d6                	cmp    %edx,%esi
  8023ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b2:	89 d1                	mov    %edx,%ecx
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	72 08                	jb     8023c0 <__umoddi3+0x110>
  8023b8:	75 11                	jne    8023cb <__umoddi3+0x11b>
  8023ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023be:	73 0b                	jae    8023cb <__umoddi3+0x11b>
  8023c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023c4:	1b 14 24             	sbb    (%esp),%edx
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 c3                	mov    %eax,%ebx
  8023cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023cf:	29 da                	sub    %ebx,%edx
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	d3 ea                	shr    %cl,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	09 d0                	or     %edx,%eax
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	83 c4 1c             	add    $0x1c,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 f9                	sub    %edi,%ecx
  8023f2:	19 d6                	sbb    %edx,%esi
  8023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023fc:	e9 18 ff ff ff       	jmp    802319 <__umoddi3+0x69>
