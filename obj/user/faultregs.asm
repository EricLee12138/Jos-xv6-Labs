
obj/user/faultregs.debug：     文件格式 elf32-i386


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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 31 24 80 00       	push   $0x802431
  800049:	68 00 24 80 00       	push   $0x802400
  80004e:	e8 77 06 00 00       	call   8006ca <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 10 24 80 00       	push   $0x802410
  80005c:	68 14 24 80 00       	push   $0x802414
  800061:	e8 64 06 00 00       	call   8006ca <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 24 24 80 00       	push   $0x802424
  800077:	e8 4e 06 00 00       	call   8006ca <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 28 24 80 00       	push   $0x802428
  80008e:	e8 37 06 00 00       	call   8006ca <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 32 24 80 00       	push   $0x802432
  8000a6:	68 14 24 80 00       	push   $0x802414
  8000ab:	e8 1a 06 00 00       	call   8006ca <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 24 24 80 00       	push   $0x802424
  8000c3:	e8 02 06 00 00       	call   8006ca <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 28 24 80 00       	push   $0x802428
  8000d5:	e8 f0 05 00 00       	call   8006ca <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 36 24 80 00       	push   $0x802436
  8000ed:	68 14 24 80 00       	push   $0x802414
  8000f2:	e8 d3 05 00 00       	call   8006ca <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 24 24 80 00       	push   $0x802424
  80010a:	e8 bb 05 00 00       	call   8006ca <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 28 24 80 00       	push   $0x802428
  80011c:	e8 a9 05 00 00       	call   8006ca <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 3a 24 80 00       	push   $0x80243a
  800134:	68 14 24 80 00       	push   $0x802414
  800139:	e8 8c 05 00 00       	call   8006ca <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 24 24 80 00       	push   $0x802424
  800151:	e8 74 05 00 00       	call   8006ca <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 28 24 80 00       	push   $0x802428
  800163:	e8 62 05 00 00       	call   8006ca <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 3e 24 80 00       	push   $0x80243e
  80017b:	68 14 24 80 00       	push   $0x802414
  800180:	e8 45 05 00 00       	call   8006ca <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 24 24 80 00       	push   $0x802424
  800198:	e8 2d 05 00 00       	call   8006ca <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 28 24 80 00       	push   $0x802428
  8001aa:	e8 1b 05 00 00       	call   8006ca <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 42 24 80 00       	push   $0x802442
  8001c2:	68 14 24 80 00       	push   $0x802414
  8001c7:	e8 fe 04 00 00       	call   8006ca <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 24 24 80 00       	push   $0x802424
  8001df:	e8 e6 04 00 00       	call   8006ca <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 28 24 80 00       	push   $0x802428
  8001f1:	e8 d4 04 00 00       	call   8006ca <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 46 24 80 00       	push   $0x802446
  800209:	68 14 24 80 00       	push   $0x802414
  80020e:	e8 b7 04 00 00       	call   8006ca <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 24 24 80 00       	push   $0x802424
  800226:	e8 9f 04 00 00       	call   8006ca <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 28 24 80 00       	push   $0x802428
  800238:	e8 8d 04 00 00       	call   8006ca <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 4a 24 80 00       	push   $0x80244a
  800250:	68 14 24 80 00       	push   $0x802414
  800255:	e8 70 04 00 00       	call   8006ca <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 24 24 80 00       	push   $0x802424
  80026d:	e8 58 04 00 00       	call   8006ca <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 28 24 80 00       	push   $0x802428
  80027f:	e8 46 04 00 00       	call   8006ca <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 4e 24 80 00       	push   $0x80244e
  800297:	68 14 24 80 00       	push   $0x802414
  80029c:	e8 29 04 00 00       	call   8006ca <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 24 24 80 00       	push   $0x802424
  8002b4:	e8 11 04 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 55 24 80 00       	push   $0x802455
  8002c4:	68 14 24 80 00       	push   $0x802414
  8002c9:	e8 fc 03 00 00       	call   8006ca <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 28 24 80 00       	push   $0x802428
  8002e3:	e8 e2 03 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 55 24 80 00       	push   $0x802455
  8002f3:	68 14 24 80 00       	push   $0x802414
  8002f8:	e8 cd 03 00 00       	call   8006ca <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 24 24 80 00       	push   $0x802424
  800312:	e8 b3 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 59 24 80 00       	push   $0x802459
  800322:	e8 a3 03 00 00       	call   8006ca <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 28 24 80 00       	push   $0x802428
  800338:	e8 8d 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 59 24 80 00       	push   $0x802459
  800348:	e8 7d 03 00 00       	call   8006ca <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 24 24 80 00       	push   $0x802424
  80035a:	e8 6b 03 00 00       	call   8006ca <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 28 24 80 00       	push   $0x802428
  80036c:	e8 59 03 00 00       	call   8006ca <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 24 24 80 00       	push   $0x802424
  80037e:	e8 47 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 59 24 80 00       	push   $0x802459
  80038e:	e8 37 03 00 00       	call   8006ca <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 c0 24 80 00       	push   $0x8024c0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 67 24 80 00       	push   $0x802467
  8003c6:	e8 26 02 00 00       	call   8005f1 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 7f 24 80 00       	push   $0x80247f
  800435:	68 8d 24 80 00       	push   $0x80248d
  80043a:	b9 40 40 80 00       	mov    $0x804040,%ecx
  80043f:	ba 78 24 80 00       	mov    $0x802478,%edx
  800444:	b8 80 40 80 00       	mov    $0x804080,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 72 0c 00 00       	call   8010d1 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 94 24 80 00       	push   $0x802494
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 67 24 80 00       	push   $0x802467
  800473:	e8 79 01 00 00       	call   8005f1 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 38 0e 00 00       	call   8012c2 <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004ab:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b1:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004b7:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004bd:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c3:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004c9:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004ce:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004e4:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004ea:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f0:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004f6:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004fc:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800502:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800507:	89 25 28 40 80 00    	mov    %esp,0x804028
  80050d:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800513:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800519:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80051f:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800525:	8b 15 94 40 80 00    	mov    0x804094,%edx
  80052b:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800531:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800536:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 24 40 80 00       	mov    %eax,0x804024
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 f4 24 80 00       	push   $0x8024f4
  800559:	e8 6c 01 00 00       	call   8006ca <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  800566:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 a7 24 80 00       	push   $0x8024a7
  800573:	68 b8 24 80 00       	push   $0x8024b8
  800578:	b9 00 40 80 00       	mov    $0x804000,%ecx
  80057d:	ba 78 24 80 00       	mov    $0x802478,%edx
  800582:	b8 80 40 80 00       	mov    $0x804080,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
}
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80059c:	e8 f2 0a 00 00       	call   801093 <sys_getenvid>
  8005a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ae:	a3 b0 40 80 00       	mov    %eax,0x8040b0
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7e 07                	jle    8005be <libmain+0x2d>
		binaryname = argv[0];
  8005b7:	8b 06                	mov    (%esi),%eax
  8005b9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	e8 b2 fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005c8:	e8 0a 00 00 00       	call   8005d7 <exit>
}
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005dd:	e8 16 0f 00 00       	call   8014f8 <close_all>
	sys_env_destroy(0);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	6a 00                	push   $0x0
  8005e7:	e8 66 0a 00 00       	call   801052 <sys_env_destroy>
}
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	c9                   	leave  
  8005f0:	c3                   	ret    

008005f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	56                   	push   %esi
  8005f5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8005ff:	e8 8f 0a 00 00       	call   801093 <sys_getenvid>
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	ff 75 0c             	pushl  0xc(%ebp)
  80060a:	ff 75 08             	pushl  0x8(%ebp)
  80060d:	56                   	push   %esi
  80060e:	50                   	push   %eax
  80060f:	68 20 25 80 00       	push   $0x802520
  800614:	e8 b1 00 00 00       	call   8006ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800619:	83 c4 18             	add    $0x18,%esp
  80061c:	53                   	push   %ebx
  80061d:	ff 75 10             	pushl  0x10(%ebp)
  800620:	e8 54 00 00 00       	call   800679 <vcprintf>
	cprintf("\n");
  800625:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  80062c:	e8 99 00 00 00       	call   8006ca <cprintf>
  800631:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800634:	cc                   	int3   
  800635:	eb fd                	jmp    800634 <_panic+0x43>

00800637 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 04             	sub    $0x4,%esp
  80063e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800641:	8b 13                	mov    (%ebx),%edx
  800643:	8d 42 01             	lea    0x1(%edx),%eax
  800646:	89 03                	mov    %eax,(%ebx)
  800648:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800654:	75 1a                	jne    800670 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	68 ff 00 00 00       	push   $0xff
  80065e:	8d 43 08             	lea    0x8(%ebx),%eax
  800661:	50                   	push   %eax
  800662:	e8 ae 09 00 00       	call   801015 <sys_cputs>
		b->idx = 0;
  800667:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80066d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800670:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800682:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800689:	00 00 00 
	b.cnt = 0;
  80068c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800693:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	ff 75 08             	pushl  0x8(%ebp)
  80069c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a2:	50                   	push   %eax
  8006a3:	68 37 06 80 00       	push   $0x800637
  8006a8:	e8 1a 01 00 00       	call   8007c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ad:	83 c4 08             	add    $0x8,%esp
  8006b0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	e8 53 09 00 00       	call   801015 <sys_cputs>

	return b.cnt;
}
  8006c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d3:	50                   	push   %eax
  8006d4:	ff 75 08             	pushl  0x8(%ebp)
  8006d7:	e8 9d ff ff ff       	call   800679 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	57                   	push   %edi
  8006e2:	56                   	push   %esi
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 1c             	sub    $0x1c,%esp
  8006e7:	89 c7                	mov    %eax,%edi
  8006e9:	89 d6                	mov    %edx,%esi
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800702:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800705:	39 d3                	cmp    %edx,%ebx
  800707:	72 05                	jb     80070e <printnum+0x30>
  800709:	39 45 10             	cmp    %eax,0x10(%ebp)
  80070c:	77 45                	ja     800753 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80070e:	83 ec 0c             	sub    $0xc,%esp
  800711:	ff 75 18             	pushl  0x18(%ebp)
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80071a:	53                   	push   %ebx
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	ff 75 e4             	pushl  -0x1c(%ebp)
  800724:	ff 75 e0             	pushl  -0x20(%ebp)
  800727:	ff 75 dc             	pushl  -0x24(%ebp)
  80072a:	ff 75 d8             	pushl  -0x28(%ebp)
  80072d:	e8 2e 1a 00 00       	call   802160 <__udivdi3>
  800732:	83 c4 18             	add    $0x18,%esp
  800735:	52                   	push   %edx
  800736:	50                   	push   %eax
  800737:	89 f2                	mov    %esi,%edx
  800739:	89 f8                	mov    %edi,%eax
  80073b:	e8 9e ff ff ff       	call   8006de <printnum>
  800740:	83 c4 20             	add    $0x20,%esp
  800743:	eb 18                	jmp    80075d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	ff 75 18             	pushl  0x18(%ebp)
  80074c:	ff d7                	call   *%edi
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	eb 03                	jmp    800756 <printnum+0x78>
  800753:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800756:	83 eb 01             	sub    $0x1,%ebx
  800759:	85 db                	test   %ebx,%ebx
  80075b:	7f e8                	jg     800745 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	56                   	push   %esi
  800761:	83 ec 04             	sub    $0x4,%esp
  800764:	ff 75 e4             	pushl  -0x1c(%ebp)
  800767:	ff 75 e0             	pushl  -0x20(%ebp)
  80076a:	ff 75 dc             	pushl  -0x24(%ebp)
  80076d:	ff 75 d8             	pushl  -0x28(%ebp)
  800770:	e8 1b 1b 00 00       	call   802290 <__umoddi3>
  800775:	83 c4 14             	add    $0x14,%esp
  800778:	0f be 80 43 25 80 00 	movsbl 0x802543(%eax),%eax
  80077f:	50                   	push   %eax
  800780:	ff d7                	call   *%edi
}
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5f                   	pop    %edi
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800793:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800797:	8b 10                	mov    (%eax),%edx
  800799:	3b 50 04             	cmp    0x4(%eax),%edx
  80079c:	73 0a                	jae    8007a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80079e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007a1:	89 08                	mov    %ecx,(%eax)
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	88 02                	mov    %al,(%edx)
}
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007b3:	50                   	push   %eax
  8007b4:	ff 75 10             	pushl  0x10(%ebp)
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	ff 75 08             	pushl  0x8(%ebp)
  8007bd:	e8 05 00 00 00       	call   8007c7 <vprintfmt>
	va_end(ap);
}
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	57                   	push   %edi
  8007cb:	56                   	push   %esi
  8007cc:	53                   	push   %ebx
  8007cd:	83 ec 2c             	sub    $0x2c,%esp
  8007d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8007d9:	eb 12                	jmp    8007ed <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	0f 84 42 04 00 00    	je     800c25 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	50                   	push   %eax
  8007e8:	ff d6                	call   *%esi
  8007ea:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ed:	83 c7 01             	add    $0x1,%edi
  8007f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007f4:	83 f8 25             	cmp    $0x25,%eax
  8007f7:	75 e2                	jne    8007db <vprintfmt+0x14>
  8007f9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8007fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800804:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80080b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800812:	b9 00 00 00 00       	mov    $0x0,%ecx
  800817:	eb 07                	jmp    800820 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800819:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80081c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800820:	8d 47 01             	lea    0x1(%edi),%eax
  800823:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800826:	0f b6 07             	movzbl (%edi),%eax
  800829:	0f b6 d0             	movzbl %al,%edx
  80082c:	83 e8 23             	sub    $0x23,%eax
  80082f:	3c 55                	cmp    $0x55,%al
  800831:	0f 87 d3 03 00 00    	ja     800c0a <vprintfmt+0x443>
  800837:	0f b6 c0             	movzbl %al,%eax
  80083a:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  800841:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800844:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800848:	eb d6                	jmp    800820 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
  800852:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800855:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800858:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80085c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80085f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800862:	83 f9 09             	cmp    $0x9,%ecx
  800865:	77 3f                	ja     8008a6 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800867:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80086a:	eb e9                	jmp    800855 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8b 00                	mov    (%eax),%eax
  800871:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	8d 40 04             	lea    0x4(%eax),%eax
  80087a:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800880:	eb 2a                	jmp    8008ac <vprintfmt+0xe5>
  800882:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800885:	85 c0                	test   %eax,%eax
  800887:	ba 00 00 00 00       	mov    $0x0,%edx
  80088c:	0f 49 d0             	cmovns %eax,%edx
  80088f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800892:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800895:	eb 89                	jmp    800820 <vprintfmt+0x59>
  800897:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80089a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008a1:	e9 7a ff ff ff       	jmp    800820 <vprintfmt+0x59>
  8008a6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8008a9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008b0:	0f 89 6a ff ff ff    	jns    800820 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008b6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008bc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008c3:	e9 58 ff ff ff       	jmp    800820 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008c8:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008ce:	e9 4d ff ff ff       	jmp    800820 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d6:	8d 78 04             	lea    0x4(%eax),%edi
  8008d9:	83 ec 08             	sub    $0x8,%esp
  8008dc:	53                   	push   %ebx
  8008dd:	ff 30                	pushl  (%eax)
  8008df:	ff d6                	call   *%esi
			break;
  8008e1:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008e4:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008ea:	e9 fe fe ff ff       	jmp    8007ed <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f2:	8d 78 04             	lea    0x4(%eax),%edi
  8008f5:	8b 00                	mov    (%eax),%eax
  8008f7:	99                   	cltd   
  8008f8:	31 d0                	xor    %edx,%eax
  8008fa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008fc:	83 f8 0f             	cmp    $0xf,%eax
  8008ff:	7f 0b                	jg     80090c <vprintfmt+0x145>
  800901:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  800908:	85 d2                	test   %edx,%edx
  80090a:	75 1b                	jne    800927 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80090c:	50                   	push   %eax
  80090d:	68 5b 25 80 00       	push   $0x80255b
  800912:	53                   	push   %ebx
  800913:	56                   	push   %esi
  800914:	e8 91 fe ff ff       	call   8007aa <printfmt>
  800919:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80091c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800922:	e9 c6 fe ff ff       	jmp    8007ed <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800927:	52                   	push   %edx
  800928:	68 15 29 80 00       	push   $0x802915
  80092d:	53                   	push   %ebx
  80092e:	56                   	push   %esi
  80092f:	e8 76 fe ff ff       	call   8007aa <printfmt>
  800934:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800937:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80093d:	e9 ab fe ff ff       	jmp    8007ed <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	83 c0 04             	add    $0x4,%eax
  800948:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80094b:	8b 45 14             	mov    0x14(%ebp),%eax
  80094e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800950:	85 ff                	test   %edi,%edi
  800952:	b8 54 25 80 00       	mov    $0x802554,%eax
  800957:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80095a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80095e:	0f 8e 94 00 00 00    	jle    8009f8 <vprintfmt+0x231>
  800964:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800968:	0f 84 98 00 00 00    	je     800a06 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80096e:	83 ec 08             	sub    $0x8,%esp
  800971:	ff 75 d0             	pushl  -0x30(%ebp)
  800974:	57                   	push   %edi
  800975:	e8 33 03 00 00       	call   800cad <strnlen>
  80097a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80097d:	29 c1                	sub    %eax,%ecx
  80097f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800982:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800985:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800989:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80098c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80098f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800991:	eb 0f                	jmp    8009a2 <vprintfmt+0x1db>
					putch(padc, putdat);
  800993:	83 ec 08             	sub    $0x8,%esp
  800996:	53                   	push   %ebx
  800997:	ff 75 e0             	pushl  -0x20(%ebp)
  80099a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80099c:	83 ef 01             	sub    $0x1,%edi
  80099f:	83 c4 10             	add    $0x10,%esp
  8009a2:	85 ff                	test   %edi,%edi
  8009a4:	7f ed                	jg     800993 <vprintfmt+0x1cc>
  8009a6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009a9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8009ac:	85 c9                	test   %ecx,%ecx
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b3:	0f 49 c1             	cmovns %ecx,%eax
  8009b6:	29 c1                	sub    %eax,%ecx
  8009b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8009bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009c1:	89 cb                	mov    %ecx,%ebx
  8009c3:	eb 4d                	jmp    800a12 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009c9:	74 1b                	je     8009e6 <vprintfmt+0x21f>
  8009cb:	0f be c0             	movsbl %al,%eax
  8009ce:	83 e8 20             	sub    $0x20,%eax
  8009d1:	83 f8 5e             	cmp    $0x5e,%eax
  8009d4:	76 10                	jbe    8009e6 <vprintfmt+0x21f>
					putch('?', putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	ff 75 0c             	pushl  0xc(%ebp)
  8009dc:	6a 3f                	push   $0x3f
  8009de:	ff 55 08             	call   *0x8(%ebp)
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	eb 0d                	jmp    8009f3 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8009e6:	83 ec 08             	sub    $0x8,%esp
  8009e9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ec:	52                   	push   %edx
  8009ed:	ff 55 08             	call   *0x8(%ebp)
  8009f0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f3:	83 eb 01             	sub    $0x1,%ebx
  8009f6:	eb 1a                	jmp    800a12 <vprintfmt+0x24b>
  8009f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8009fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a01:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a04:	eb 0c                	jmp    800a12 <vprintfmt+0x24b>
  800a06:	89 75 08             	mov    %esi,0x8(%ebp)
  800a09:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a0c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a0f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a12:	83 c7 01             	add    $0x1,%edi
  800a15:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a19:	0f be d0             	movsbl %al,%edx
  800a1c:	85 d2                	test   %edx,%edx
  800a1e:	74 23                	je     800a43 <vprintfmt+0x27c>
  800a20:	85 f6                	test   %esi,%esi
  800a22:	78 a1                	js     8009c5 <vprintfmt+0x1fe>
  800a24:	83 ee 01             	sub    $0x1,%esi
  800a27:	79 9c                	jns    8009c5 <vprintfmt+0x1fe>
  800a29:	89 df                	mov    %ebx,%edi
  800a2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a31:	eb 18                	jmp    800a4b <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	53                   	push   %ebx
  800a37:	6a 20                	push   $0x20
  800a39:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a3b:	83 ef 01             	sub    $0x1,%edi
  800a3e:	83 c4 10             	add    $0x10,%esp
  800a41:	eb 08                	jmp    800a4b <vprintfmt+0x284>
  800a43:	89 df                	mov    %ebx,%edi
  800a45:	8b 75 08             	mov    0x8(%ebp),%esi
  800a48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4b:	85 ff                	test   %edi,%edi
  800a4d:	7f e4                	jg     800a33 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a4f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a52:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a58:	e9 90 fd ff ff       	jmp    8007ed <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a5d:	83 f9 01             	cmp    $0x1,%ecx
  800a60:	7e 19                	jle    800a7b <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800a62:	8b 45 14             	mov    0x14(%ebp),%eax
  800a65:	8b 50 04             	mov    0x4(%eax),%edx
  800a68:	8b 00                	mov    (%eax),%eax
  800a6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a6d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a70:	8b 45 14             	mov    0x14(%ebp),%eax
  800a73:	8d 40 08             	lea    0x8(%eax),%eax
  800a76:	89 45 14             	mov    %eax,0x14(%ebp)
  800a79:	eb 38                	jmp    800ab3 <vprintfmt+0x2ec>
	else if (lflag)
  800a7b:	85 c9                	test   %ecx,%ecx
  800a7d:	74 1b                	je     800a9a <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800a7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a82:	8b 00                	mov    (%eax),%eax
  800a84:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a87:	89 c1                	mov    %eax,%ecx
  800a89:	c1 f9 1f             	sar    $0x1f,%ecx
  800a8c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a92:	8d 40 04             	lea    0x4(%eax),%eax
  800a95:	89 45 14             	mov    %eax,0x14(%ebp)
  800a98:	eb 19                	jmp    800ab3 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800a9a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9d:	8b 00                	mov    (%eax),%eax
  800a9f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa2:	89 c1                	mov    %eax,%ecx
  800aa4:	c1 f9 1f             	sar    $0x1f,%ecx
  800aa7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800aaa:	8b 45 14             	mov    0x14(%ebp),%eax
  800aad:	8d 40 04             	lea    0x4(%eax),%eax
  800ab0:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ab3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ab6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ab9:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800abe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ac2:	0f 89 0e 01 00 00    	jns    800bd6 <vprintfmt+0x40f>
				putch('-', putdat);
  800ac8:	83 ec 08             	sub    $0x8,%esp
  800acb:	53                   	push   %ebx
  800acc:	6a 2d                	push   $0x2d
  800ace:	ff d6                	call   *%esi
				num = -(long long) num;
  800ad0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ad3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ad6:	f7 da                	neg    %edx
  800ad8:	83 d1 00             	adc    $0x0,%ecx
  800adb:	f7 d9                	neg    %ecx
  800add:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ae0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae5:	e9 ec 00 00 00       	jmp    800bd6 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aea:	83 f9 01             	cmp    $0x1,%ecx
  800aed:	7e 18                	jle    800b07 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800aef:	8b 45 14             	mov    0x14(%ebp),%eax
  800af2:	8b 10                	mov    (%eax),%edx
  800af4:	8b 48 04             	mov    0x4(%eax),%ecx
  800af7:	8d 40 08             	lea    0x8(%eax),%eax
  800afa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800afd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b02:	e9 cf 00 00 00       	jmp    800bd6 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800b07:	85 c9                	test   %ecx,%ecx
  800b09:	74 1a                	je     800b25 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800b0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0e:	8b 10                	mov    (%eax),%edx
  800b10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b15:	8d 40 04             	lea    0x4(%eax),%eax
  800b18:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b20:	e9 b1 00 00 00       	jmp    800bd6 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800b25:	8b 45 14             	mov    0x14(%ebp),%eax
  800b28:	8b 10                	mov    (%eax),%edx
  800b2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2f:	8d 40 04             	lea    0x4(%eax),%eax
  800b32:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3a:	e9 97 00 00 00       	jmp    800bd6 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b3f:	83 ec 08             	sub    $0x8,%esp
  800b42:	53                   	push   %ebx
  800b43:	6a 58                	push   $0x58
  800b45:	ff d6                	call   *%esi
			putch('X', putdat);
  800b47:	83 c4 08             	add    $0x8,%esp
  800b4a:	53                   	push   %ebx
  800b4b:	6a 58                	push   $0x58
  800b4d:	ff d6                	call   *%esi
			putch('X', putdat);
  800b4f:	83 c4 08             	add    $0x8,%esp
  800b52:	53                   	push   %ebx
  800b53:	6a 58                	push   $0x58
  800b55:	ff d6                	call   *%esi
			break;
  800b57:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b5a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800b5d:	e9 8b fc ff ff       	jmp    8007ed <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800b62:	83 ec 08             	sub    $0x8,%esp
  800b65:	53                   	push   %ebx
  800b66:	6a 30                	push   $0x30
  800b68:	ff d6                	call   *%esi
			putch('x', putdat);
  800b6a:	83 c4 08             	add    $0x8,%esp
  800b6d:	53                   	push   %ebx
  800b6e:	6a 78                	push   $0x78
  800b70:	ff d6                	call   *%esi
			num = (unsigned long long)
  800b72:	8b 45 14             	mov    0x14(%ebp),%eax
  800b75:	8b 10                	mov    (%eax),%edx
  800b77:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b7c:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b7f:	8d 40 04             	lea    0x4(%eax),%eax
  800b82:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b85:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b8a:	eb 4a                	jmp    800bd6 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b8c:	83 f9 01             	cmp    $0x1,%ecx
  800b8f:	7e 15                	jle    800ba6 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800b91:	8b 45 14             	mov    0x14(%ebp),%eax
  800b94:	8b 10                	mov    (%eax),%edx
  800b96:	8b 48 04             	mov    0x4(%eax),%ecx
  800b99:	8d 40 08             	lea    0x8(%eax),%eax
  800b9c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800b9f:	b8 10 00 00 00       	mov    $0x10,%eax
  800ba4:	eb 30                	jmp    800bd6 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800ba6:	85 c9                	test   %ecx,%ecx
  800ba8:	74 17                	je     800bc1 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800baa:	8b 45 14             	mov    0x14(%ebp),%eax
  800bad:	8b 10                	mov    (%eax),%edx
  800baf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb4:	8d 40 04             	lea    0x4(%eax),%eax
  800bb7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bba:	b8 10 00 00 00       	mov    $0x10,%eax
  800bbf:	eb 15                	jmp    800bd6 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800bc1:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc4:	8b 10                	mov    (%eax),%edx
  800bc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcb:	8d 40 04             	lea    0x4(%eax),%eax
  800bce:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bd1:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bd6:	83 ec 0c             	sub    $0xc,%esp
  800bd9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bdd:	57                   	push   %edi
  800bde:	ff 75 e0             	pushl  -0x20(%ebp)
  800be1:	50                   	push   %eax
  800be2:	51                   	push   %ecx
  800be3:	52                   	push   %edx
  800be4:	89 da                	mov    %ebx,%edx
  800be6:	89 f0                	mov    %esi,%eax
  800be8:	e8 f1 fa ff ff       	call   8006de <printnum>
			break;
  800bed:	83 c4 20             	add    $0x20,%esp
  800bf0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bf3:	e9 f5 fb ff ff       	jmp    8007ed <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bf8:	83 ec 08             	sub    $0x8,%esp
  800bfb:	53                   	push   %ebx
  800bfc:	52                   	push   %edx
  800bfd:	ff d6                	call   *%esi
			break;
  800bff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c05:	e9 e3 fb ff ff       	jmp    8007ed <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c0a:	83 ec 08             	sub    $0x8,%esp
  800c0d:	53                   	push   %ebx
  800c0e:	6a 25                	push   $0x25
  800c10:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c12:	83 c4 10             	add    $0x10,%esp
  800c15:	eb 03                	jmp    800c1a <vprintfmt+0x453>
  800c17:	83 ef 01             	sub    $0x1,%edi
  800c1a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c1e:	75 f7                	jne    800c17 <vprintfmt+0x450>
  800c20:	e9 c8 fb ff ff       	jmp    8007ed <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	83 ec 18             	sub    $0x18,%esp
  800c33:	8b 45 08             	mov    0x8(%ebp),%eax
  800c36:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c3c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c40:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	74 26                	je     800c74 <vsnprintf+0x47>
  800c4e:	85 d2                	test   %edx,%edx
  800c50:	7e 22                	jle    800c74 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c52:	ff 75 14             	pushl  0x14(%ebp)
  800c55:	ff 75 10             	pushl  0x10(%ebp)
  800c58:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c5b:	50                   	push   %eax
  800c5c:	68 8d 07 80 00       	push   $0x80078d
  800c61:	e8 61 fb ff ff       	call   8007c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c66:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c69:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	eb 05                	jmp    800c79 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c81:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c84:	50                   	push   %eax
  800c85:	ff 75 10             	pushl  0x10(%ebp)
  800c88:	ff 75 0c             	pushl  0xc(%ebp)
  800c8b:	ff 75 08             	pushl  0x8(%ebp)
  800c8e:	e8 9a ff ff ff       	call   800c2d <vsnprintf>
	va_end(ap);

	return rc;
}
  800c93:	c9                   	leave  
  800c94:	c3                   	ret    

00800c95 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca0:	eb 03                	jmp    800ca5 <strlen+0x10>
		n++;
  800ca2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ca5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ca9:	75 f7                	jne    800ca2 <strlen+0xd>
		n++;
	return n;
}
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbb:	eb 03                	jmp    800cc0 <strnlen+0x13>
		n++;
  800cbd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cc0:	39 c2                	cmp    %eax,%edx
  800cc2:	74 08                	je     800ccc <strnlen+0x1f>
  800cc4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800cc8:	75 f3                	jne    800cbd <strnlen+0x10>
  800cca:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	53                   	push   %ebx
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cd8:	89 c2                	mov    %eax,%edx
  800cda:	83 c2 01             	add    $0x1,%edx
  800cdd:	83 c1 01             	add    $0x1,%ecx
  800ce0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ce4:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ce7:	84 db                	test   %bl,%bl
  800ce9:	75 ef                	jne    800cda <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ceb:	5b                   	pop    %ebx
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	53                   	push   %ebx
  800cf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cf5:	53                   	push   %ebx
  800cf6:	e8 9a ff ff ff       	call   800c95 <strlen>
  800cfb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800cfe:	ff 75 0c             	pushl  0xc(%ebp)
  800d01:	01 d8                	add    %ebx,%eax
  800d03:	50                   	push   %eax
  800d04:	e8 c5 ff ff ff       	call   800cce <strcpy>
	return dst;
}
  800d09:	89 d8                	mov    %ebx,%eax
  800d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	8b 75 08             	mov    0x8(%ebp),%esi
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	89 f3                	mov    %esi,%ebx
  800d1d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d20:	89 f2                	mov    %esi,%edx
  800d22:	eb 0f                	jmp    800d33 <strncpy+0x23>
		*dst++ = *src;
  800d24:	83 c2 01             	add    $0x1,%edx
  800d27:	0f b6 01             	movzbl (%ecx),%eax
  800d2a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d2d:	80 39 01             	cmpb   $0x1,(%ecx)
  800d30:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d33:	39 da                	cmp    %ebx,%edx
  800d35:	75 ed                	jne    800d24 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d37:	89 f0                	mov    %esi,%eax
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	8b 75 08             	mov    0x8(%ebp),%esi
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	8b 55 10             	mov    0x10(%ebp),%edx
  800d4b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d4d:	85 d2                	test   %edx,%edx
  800d4f:	74 21                	je     800d72 <strlcpy+0x35>
  800d51:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d55:	89 f2                	mov    %esi,%edx
  800d57:	eb 09                	jmp    800d62 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d59:	83 c2 01             	add    $0x1,%edx
  800d5c:	83 c1 01             	add    $0x1,%ecx
  800d5f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d62:	39 c2                	cmp    %eax,%edx
  800d64:	74 09                	je     800d6f <strlcpy+0x32>
  800d66:	0f b6 19             	movzbl (%ecx),%ebx
  800d69:	84 db                	test   %bl,%bl
  800d6b:	75 ec                	jne    800d59 <strlcpy+0x1c>
  800d6d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d6f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d72:	29 f0                	sub    %esi,%eax
}
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d81:	eb 06                	jmp    800d89 <strcmp+0x11>
		p++, q++;
  800d83:	83 c1 01             	add    $0x1,%ecx
  800d86:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d89:	0f b6 01             	movzbl (%ecx),%eax
  800d8c:	84 c0                	test   %al,%al
  800d8e:	74 04                	je     800d94 <strcmp+0x1c>
  800d90:	3a 02                	cmp    (%edx),%al
  800d92:	74 ef                	je     800d83 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d94:	0f b6 c0             	movzbl %al,%eax
  800d97:	0f b6 12             	movzbl (%edx),%edx
  800d9a:	29 d0                	sub    %edx,%eax
}
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	53                   	push   %ebx
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da8:	89 c3                	mov    %eax,%ebx
  800daa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dad:	eb 06                	jmp    800db5 <strncmp+0x17>
		n--, p++, q++;
  800daf:	83 c0 01             	add    $0x1,%eax
  800db2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800db5:	39 d8                	cmp    %ebx,%eax
  800db7:	74 15                	je     800dce <strncmp+0x30>
  800db9:	0f b6 08             	movzbl (%eax),%ecx
  800dbc:	84 c9                	test   %cl,%cl
  800dbe:	74 04                	je     800dc4 <strncmp+0x26>
  800dc0:	3a 0a                	cmp    (%edx),%cl
  800dc2:	74 eb                	je     800daf <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc4:	0f b6 00             	movzbl (%eax),%eax
  800dc7:	0f b6 12             	movzbl (%edx),%edx
  800dca:	29 d0                	sub    %edx,%eax
  800dcc:	eb 05                	jmp    800dd3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dce:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dd3:	5b                   	pop    %ebx
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de0:	eb 07                	jmp    800de9 <strchr+0x13>
		if (*s == c)
  800de2:	38 ca                	cmp    %cl,%dl
  800de4:	74 0f                	je     800df5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800de6:	83 c0 01             	add    $0x1,%eax
  800de9:	0f b6 10             	movzbl (%eax),%edx
  800dec:	84 d2                	test   %dl,%dl
  800dee:	75 f2                	jne    800de2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800df0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e01:	eb 03                	jmp    800e06 <strfind+0xf>
  800e03:	83 c0 01             	add    $0x1,%eax
  800e06:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e09:	38 ca                	cmp    %cl,%dl
  800e0b:	74 04                	je     800e11 <strfind+0x1a>
  800e0d:	84 d2                	test   %dl,%dl
  800e0f:	75 f2                	jne    800e03 <strfind+0xc>
			break;
	return (char *) s;
}
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e1f:	85 c9                	test   %ecx,%ecx
  800e21:	74 36                	je     800e59 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e23:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e29:	75 28                	jne    800e53 <memset+0x40>
  800e2b:	f6 c1 03             	test   $0x3,%cl
  800e2e:	75 23                	jne    800e53 <memset+0x40>
		c &= 0xFF;
  800e30:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e34:	89 d3                	mov    %edx,%ebx
  800e36:	c1 e3 08             	shl    $0x8,%ebx
  800e39:	89 d6                	mov    %edx,%esi
  800e3b:	c1 e6 18             	shl    $0x18,%esi
  800e3e:	89 d0                	mov    %edx,%eax
  800e40:	c1 e0 10             	shl    $0x10,%eax
  800e43:	09 f0                	or     %esi,%eax
  800e45:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e47:	89 d8                	mov    %ebx,%eax
  800e49:	09 d0                	or     %edx,%eax
  800e4b:	c1 e9 02             	shr    $0x2,%ecx
  800e4e:	fc                   	cld    
  800e4f:	f3 ab                	rep stos %eax,%es:(%edi)
  800e51:	eb 06                	jmp    800e59 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e56:	fc                   	cld    
  800e57:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e59:	89 f8                	mov    %edi,%eax
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
  800e68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e6e:	39 c6                	cmp    %eax,%esi
  800e70:	73 35                	jae    800ea7 <memmove+0x47>
  800e72:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e75:	39 d0                	cmp    %edx,%eax
  800e77:	73 2e                	jae    800ea7 <memmove+0x47>
		s += n;
		d += n;
  800e79:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e7c:	89 d6                	mov    %edx,%esi
  800e7e:	09 fe                	or     %edi,%esi
  800e80:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e86:	75 13                	jne    800e9b <memmove+0x3b>
  800e88:	f6 c1 03             	test   $0x3,%cl
  800e8b:	75 0e                	jne    800e9b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e8d:	83 ef 04             	sub    $0x4,%edi
  800e90:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e93:	c1 e9 02             	shr    $0x2,%ecx
  800e96:	fd                   	std    
  800e97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e99:	eb 09                	jmp    800ea4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e9b:	83 ef 01             	sub    $0x1,%edi
  800e9e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ea1:	fd                   	std    
  800ea2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ea4:	fc                   	cld    
  800ea5:	eb 1d                	jmp    800ec4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea7:	89 f2                	mov    %esi,%edx
  800ea9:	09 c2                	or     %eax,%edx
  800eab:	f6 c2 03             	test   $0x3,%dl
  800eae:	75 0f                	jne    800ebf <memmove+0x5f>
  800eb0:	f6 c1 03             	test   $0x3,%cl
  800eb3:	75 0a                	jne    800ebf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800eb5:	c1 e9 02             	shr    $0x2,%ecx
  800eb8:	89 c7                	mov    %eax,%edi
  800eba:	fc                   	cld    
  800ebb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ebd:	eb 05                	jmp    800ec4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ebf:	89 c7                	mov    %eax,%edi
  800ec1:	fc                   	cld    
  800ec2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ecb:	ff 75 10             	pushl  0x10(%ebp)
  800ece:	ff 75 0c             	pushl  0xc(%ebp)
  800ed1:	ff 75 08             	pushl  0x8(%ebp)
  800ed4:	e8 87 ff ff ff       	call   800e60 <memmove>
}
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee6:	89 c6                	mov    %eax,%esi
  800ee8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eeb:	eb 1a                	jmp    800f07 <memcmp+0x2c>
		if (*s1 != *s2)
  800eed:	0f b6 08             	movzbl (%eax),%ecx
  800ef0:	0f b6 1a             	movzbl (%edx),%ebx
  800ef3:	38 d9                	cmp    %bl,%cl
  800ef5:	74 0a                	je     800f01 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ef7:	0f b6 c1             	movzbl %cl,%eax
  800efa:	0f b6 db             	movzbl %bl,%ebx
  800efd:	29 d8                	sub    %ebx,%eax
  800eff:	eb 0f                	jmp    800f10 <memcmp+0x35>
		s1++, s2++;
  800f01:	83 c0 01             	add    $0x1,%eax
  800f04:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f07:	39 f0                	cmp    %esi,%eax
  800f09:	75 e2                	jne    800eed <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	53                   	push   %ebx
  800f18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f1b:	89 c1                	mov    %eax,%ecx
  800f1d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f20:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f24:	eb 0a                	jmp    800f30 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f26:	0f b6 10             	movzbl (%eax),%edx
  800f29:	39 da                	cmp    %ebx,%edx
  800f2b:	74 07                	je     800f34 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f2d:	83 c0 01             	add    $0x1,%eax
  800f30:	39 c8                	cmp    %ecx,%eax
  800f32:	72 f2                	jb     800f26 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f34:	5b                   	pop    %ebx
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	57                   	push   %edi
  800f3b:	56                   	push   %esi
  800f3c:	53                   	push   %ebx
  800f3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f43:	eb 03                	jmp    800f48 <strtol+0x11>
		s++;
  800f45:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f48:	0f b6 01             	movzbl (%ecx),%eax
  800f4b:	3c 20                	cmp    $0x20,%al
  800f4d:	74 f6                	je     800f45 <strtol+0xe>
  800f4f:	3c 09                	cmp    $0x9,%al
  800f51:	74 f2                	je     800f45 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f53:	3c 2b                	cmp    $0x2b,%al
  800f55:	75 0a                	jne    800f61 <strtol+0x2a>
		s++;
  800f57:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f5f:	eb 11                	jmp    800f72 <strtol+0x3b>
  800f61:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f66:	3c 2d                	cmp    $0x2d,%al
  800f68:	75 08                	jne    800f72 <strtol+0x3b>
		s++, neg = 1;
  800f6a:	83 c1 01             	add    $0x1,%ecx
  800f6d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f78:	75 15                	jne    800f8f <strtol+0x58>
  800f7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800f7d:	75 10                	jne    800f8f <strtol+0x58>
  800f7f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f83:	75 7c                	jne    801001 <strtol+0xca>
		s += 2, base = 16;
  800f85:	83 c1 02             	add    $0x2,%ecx
  800f88:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f8d:	eb 16                	jmp    800fa5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f8f:	85 db                	test   %ebx,%ebx
  800f91:	75 12                	jne    800fa5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f93:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f98:	80 39 30             	cmpb   $0x30,(%ecx)
  800f9b:	75 08                	jne    800fa5 <strtol+0x6e>
		s++, base = 8;
  800f9d:	83 c1 01             	add    $0x1,%ecx
  800fa0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800faa:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fad:	0f b6 11             	movzbl (%ecx),%edx
  800fb0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fb3:	89 f3                	mov    %esi,%ebx
  800fb5:	80 fb 09             	cmp    $0x9,%bl
  800fb8:	77 08                	ja     800fc2 <strtol+0x8b>
			dig = *s - '0';
  800fba:	0f be d2             	movsbl %dl,%edx
  800fbd:	83 ea 30             	sub    $0x30,%edx
  800fc0:	eb 22                	jmp    800fe4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800fc2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fc5:	89 f3                	mov    %esi,%ebx
  800fc7:	80 fb 19             	cmp    $0x19,%bl
  800fca:	77 08                	ja     800fd4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800fcc:	0f be d2             	movsbl %dl,%edx
  800fcf:	83 ea 57             	sub    $0x57,%edx
  800fd2:	eb 10                	jmp    800fe4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fd4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fd7:	89 f3                	mov    %esi,%ebx
  800fd9:	80 fb 19             	cmp    $0x19,%bl
  800fdc:	77 16                	ja     800ff4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800fde:	0f be d2             	movsbl %dl,%edx
  800fe1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fe4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fe7:	7d 0b                	jge    800ff4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800fe9:	83 c1 01             	add    $0x1,%ecx
  800fec:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ff0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ff2:	eb b9                	jmp    800fad <strtol+0x76>

	if (endptr)
  800ff4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ff8:	74 0d                	je     801007 <strtol+0xd0>
		*endptr = (char *) s;
  800ffa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ffd:	89 0e                	mov    %ecx,(%esi)
  800fff:	eb 06                	jmp    801007 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801001:	85 db                	test   %ebx,%ebx
  801003:	74 98                	je     800f9d <strtol+0x66>
  801005:	eb 9e                	jmp    800fa5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801007:	89 c2                	mov    %eax,%edx
  801009:	f7 da                	neg    %edx
  80100b:	85 ff                	test   %edi,%edi
  80100d:	0f 45 c2             	cmovne %edx,%eax
}
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	57                   	push   %edi
  801019:	56                   	push   %esi
  80101a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101b:	b8 00 00 00 00       	mov    $0x0,%eax
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	89 c3                	mov    %eax,%ebx
  801028:	89 c7                	mov    %eax,%edi
  80102a:	89 c6                	mov    %eax,%esi
  80102c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_cgetc>:

int
sys_cgetc(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801039:	ba 00 00 00 00       	mov    $0x0,%edx
  80103e:	b8 01 00 00 00       	mov    $0x1,%eax
  801043:	89 d1                	mov    %edx,%ecx
  801045:	89 d3                	mov    %edx,%ebx
  801047:	89 d7                	mov    %edx,%edi
  801049:	89 d6                	mov    %edx,%esi
  80104b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801060:	b8 03 00 00 00       	mov    $0x3,%eax
  801065:	8b 55 08             	mov    0x8(%ebp),%edx
  801068:	89 cb                	mov    %ecx,%ebx
  80106a:	89 cf                	mov    %ecx,%edi
  80106c:	89 ce                	mov    %ecx,%esi
  80106e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801070:	85 c0                	test   %eax,%eax
  801072:	7e 17                	jle    80108b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	50                   	push   %eax
  801078:	6a 03                	push   $0x3
  80107a:	68 3f 28 80 00       	push   $0x80283f
  80107f:	6a 23                	push   $0x23
  801081:	68 5c 28 80 00       	push   $0x80285c
  801086:	e8 66 f5 ff ff       	call   8005f1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80108b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	ba 00 00 00 00       	mov    $0x0,%edx
  80109e:	b8 02 00 00 00       	mov    $0x2,%eax
  8010a3:	89 d1                	mov    %edx,%ecx
  8010a5:	89 d3                	mov    %edx,%ebx
  8010a7:	89 d7                	mov    %edx,%edi
  8010a9:	89 d6                	mov    %edx,%esi
  8010ab:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <sys_yield>:

void
sys_yield(void)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bd:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010c2:	89 d1                	mov    %edx,%ecx
  8010c4:	89 d3                	mov    %edx,%ebx
  8010c6:	89 d7                	mov    %edx,%edi
  8010c8:	89 d6                	mov    %edx,%esi
  8010ca:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	57                   	push   %edi
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010da:	be 00 00 00 00       	mov    $0x0,%esi
  8010df:	b8 04 00 00 00       	mov    $0x4,%eax
  8010e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ed:	89 f7                	mov    %esi,%edi
  8010ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	7e 17                	jle    80110c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	50                   	push   %eax
  8010f9:	6a 04                	push   $0x4
  8010fb:	68 3f 28 80 00       	push   $0x80283f
  801100:	6a 23                	push   $0x23
  801102:	68 5c 28 80 00       	push   $0x80285c
  801107:	e8 e5 f4 ff ff       	call   8005f1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80110c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111d:	b8 05 00 00 00       	mov    $0x5,%eax
  801122:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801125:	8b 55 08             	mov    0x8(%ebp),%edx
  801128:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80112b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80112e:	8b 75 18             	mov    0x18(%ebp),%esi
  801131:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801133:	85 c0                	test   %eax,%eax
  801135:	7e 17                	jle    80114e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	50                   	push   %eax
  80113b:	6a 05                	push   $0x5
  80113d:	68 3f 28 80 00       	push   $0x80283f
  801142:	6a 23                	push   $0x23
  801144:	68 5c 28 80 00       	push   $0x80285c
  801149:	e8 a3 f4 ff ff       	call   8005f1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	57                   	push   %edi
  80115a:	56                   	push   %esi
  80115b:	53                   	push   %ebx
  80115c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801164:	b8 06 00 00 00       	mov    $0x6,%eax
  801169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116c:	8b 55 08             	mov    0x8(%ebp),%edx
  80116f:	89 df                	mov    %ebx,%edi
  801171:	89 de                	mov    %ebx,%esi
  801173:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801175:	85 c0                	test   %eax,%eax
  801177:	7e 17                	jle    801190 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	50                   	push   %eax
  80117d:	6a 06                	push   $0x6
  80117f:	68 3f 28 80 00       	push   $0x80283f
  801184:	6a 23                	push   $0x23
  801186:	68 5c 28 80 00       	push   $0x80285c
  80118b:	e8 61 f4 ff ff       	call   8005f1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	57                   	push   %edi
  80119c:	56                   	push   %esi
  80119d:	53                   	push   %ebx
  80119e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8011ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b1:	89 df                	mov    %ebx,%edi
  8011b3:	89 de                	mov    %ebx,%esi
  8011b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	7e 17                	jle    8011d2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	50                   	push   %eax
  8011bf:	6a 08                	push   $0x8
  8011c1:	68 3f 28 80 00       	push   $0x80283f
  8011c6:	6a 23                	push   $0x23
  8011c8:	68 5c 28 80 00       	push   $0x80285c
  8011cd:	e8 1f f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8011ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f3:	89 df                	mov    %ebx,%edi
  8011f5:	89 de                	mov    %ebx,%esi
  8011f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	7e 17                	jle    801214 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	50                   	push   %eax
  801201:	6a 09                	push   $0x9
  801203:	68 3f 28 80 00       	push   $0x80283f
  801208:	6a 23                	push   $0x23
  80120a:	68 5c 28 80 00       	push   $0x80285c
  80120f:	e8 dd f3 ff ff       	call   8005f1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5f                   	pop    %edi
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	57                   	push   %edi
  801220:	56                   	push   %esi
  801221:	53                   	push   %ebx
  801222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801232:	8b 55 08             	mov    0x8(%ebp),%edx
  801235:	89 df                	mov    %ebx,%edi
  801237:	89 de                	mov    %ebx,%esi
  801239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80123b:	85 c0                	test   %eax,%eax
  80123d:	7e 17                	jle    801256 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80123f:	83 ec 0c             	sub    $0xc,%esp
  801242:	50                   	push   %eax
  801243:	6a 0a                	push   $0xa
  801245:	68 3f 28 80 00       	push   $0x80283f
  80124a:	6a 23                	push   $0x23
  80124c:	68 5c 28 80 00       	push   $0x80285c
  801251:	e8 9b f3 ff ff       	call   8005f1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801259:	5b                   	pop    %ebx
  80125a:	5e                   	pop    %esi
  80125b:	5f                   	pop    %edi
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    

0080125e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801264:	be 00 00 00 00       	mov    $0x0,%esi
  801269:	b8 0c 00 00 00       	mov    $0xc,%eax
  80126e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801271:	8b 55 08             	mov    0x8(%ebp),%edx
  801274:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801277:	8b 7d 14             	mov    0x14(%ebp),%edi
  80127a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80127c:	5b                   	pop    %ebx
  80127d:	5e                   	pop    %esi
  80127e:	5f                   	pop    %edi
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	57                   	push   %edi
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
  801287:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80128a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80128f:	b8 0d 00 00 00       	mov    $0xd,%eax
  801294:	8b 55 08             	mov    0x8(%ebp),%edx
  801297:	89 cb                	mov    %ecx,%ebx
  801299:	89 cf                	mov    %ecx,%edi
  80129b:	89 ce                	mov    %ecx,%esi
  80129d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	7e 17                	jle    8012ba <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a3:	83 ec 0c             	sub    $0xc,%esp
  8012a6:	50                   	push   %eax
  8012a7:	6a 0d                	push   $0xd
  8012a9:	68 3f 28 80 00       	push   $0x80283f
  8012ae:	6a 23                	push   $0x23
  8012b0:	68 5c 28 80 00       	push   $0x80285c
  8012b5:	e8 37 f3 ff ff       	call   8005f1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012c9:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012d0:	75 28                	jne    8012fa <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  8012d2:	e8 bc fd ff ff       	call   801093 <sys_getenvid>
  8012d7:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	6a 07                	push   $0x7
  8012de:	68 00 f0 bf ee       	push   $0xeebff000
  8012e3:	50                   	push   %eax
  8012e4:	e8 e8 fd ff ff       	call   8010d1 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8012e9:	83 c4 08             	add    $0x8,%esp
  8012ec:	68 07 13 80 00       	push   $0x801307
  8012f1:	53                   	push   %ebx
  8012f2:	e8 25 ff ff ff       	call   80121c <sys_env_set_pgfault_upcall>
  8012f7:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fd:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801305:	c9                   	leave  
  801306:	c3                   	ret    

00801307 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801307:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801308:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80130d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80130f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801312:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801314:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801318:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  80131c:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  80131d:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  80131f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801324:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801325:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801326:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801327:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  80132a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  80132b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80132c:	c3                   	ret    

0080132d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	05 00 00 00 30       	add    $0x30000000,%eax
  801338:	c1 e8 0c             	shr    $0xc,%eax
}
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	05 00 00 00 30       	add    $0x30000000,%eax
  801348:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80134d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    

00801354 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80135a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80135f:	89 c2                	mov    %eax,%edx
  801361:	c1 ea 16             	shr    $0x16,%edx
  801364:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80136b:	f6 c2 01             	test   $0x1,%dl
  80136e:	74 11                	je     801381 <fd_alloc+0x2d>
  801370:	89 c2                	mov    %eax,%edx
  801372:	c1 ea 0c             	shr    $0xc,%edx
  801375:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137c:	f6 c2 01             	test   $0x1,%dl
  80137f:	75 09                	jne    80138a <fd_alloc+0x36>
			*fd_store = fd;
  801381:	89 01                	mov    %eax,(%ecx)
			return 0;
  801383:	b8 00 00 00 00       	mov    $0x0,%eax
  801388:	eb 17                	jmp    8013a1 <fd_alloc+0x4d>
  80138a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80138f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801394:	75 c9                	jne    80135f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801396:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80139c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013a9:	83 f8 1f             	cmp    $0x1f,%eax
  8013ac:	77 36                	ja     8013e4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013ae:	c1 e0 0c             	shl    $0xc,%eax
  8013b1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	c1 ea 16             	shr    $0x16,%edx
  8013bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013c2:	f6 c2 01             	test   $0x1,%dl
  8013c5:	74 24                	je     8013eb <fd_lookup+0x48>
  8013c7:	89 c2                	mov    %eax,%edx
  8013c9:	c1 ea 0c             	shr    $0xc,%edx
  8013cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013d3:	f6 c2 01             	test   $0x1,%dl
  8013d6:	74 1a                	je     8013f2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013db:	89 02                	mov    %eax,(%edx)
	return 0;
  8013dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e2:	eb 13                	jmp    8013f7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e9:	eb 0c                	jmp    8013f7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f0:	eb 05                	jmp    8013f7 <fd_lookup+0x54>
  8013f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    

008013f9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801402:	ba ec 28 80 00       	mov    $0x8028ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801407:	eb 13                	jmp    80141c <dev_lookup+0x23>
  801409:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80140c:	39 08                	cmp    %ecx,(%eax)
  80140e:	75 0c                	jne    80141c <dev_lookup+0x23>
			*dev = devtab[i];
  801410:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801413:	89 01                	mov    %eax,(%ecx)
			return 0;
  801415:	b8 00 00 00 00       	mov    $0x0,%eax
  80141a:	eb 2e                	jmp    80144a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80141c:	8b 02                	mov    (%edx),%eax
  80141e:	85 c0                	test   %eax,%eax
  801420:	75 e7                	jne    801409 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801422:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801427:	8b 40 48             	mov    0x48(%eax),%eax
  80142a:	83 ec 04             	sub    $0x4,%esp
  80142d:	51                   	push   %ecx
  80142e:	50                   	push   %eax
  80142f:	68 6c 28 80 00       	push   $0x80286c
  801434:	e8 91 f2 ff ff       	call   8006ca <cprintf>
	*dev = 0;
  801439:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	56                   	push   %esi
  801450:	53                   	push   %ebx
  801451:	83 ec 10             	sub    $0x10,%esp
  801454:	8b 75 08             	mov    0x8(%ebp),%esi
  801457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80145a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801464:	c1 e8 0c             	shr    $0xc,%eax
  801467:	50                   	push   %eax
  801468:	e8 36 ff ff ff       	call   8013a3 <fd_lookup>
  80146d:	83 c4 08             	add    $0x8,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	78 05                	js     801479 <fd_close+0x2d>
	    || fd != fd2)
  801474:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801477:	74 0c                	je     801485 <fd_close+0x39>
		return (must_exist ? r : 0);
  801479:	84 db                	test   %bl,%bl
  80147b:	ba 00 00 00 00       	mov    $0x0,%edx
  801480:	0f 44 c2             	cmove  %edx,%eax
  801483:	eb 41                	jmp    8014c6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	ff 36                	pushl  (%esi)
  80148e:	e8 66 ff ff ff       	call   8013f9 <dev_lookup>
  801493:	89 c3                	mov    %eax,%ebx
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 1a                	js     8014b6 <fd_close+0x6a>
		if (dev->dev_close)
  80149c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	74 0b                	je     8014b6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	56                   	push   %esi
  8014af:	ff d0                	call   *%eax
  8014b1:	89 c3                	mov    %eax,%ebx
  8014b3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	56                   	push   %esi
  8014ba:	6a 00                	push   $0x0
  8014bc:	e8 95 fc ff ff       	call   801156 <sys_page_unmap>
	return r;
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	89 d8                	mov    %ebx,%eax
}
  8014c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c9:	5b                   	pop    %ebx
  8014ca:	5e                   	pop    %esi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	ff 75 08             	pushl  0x8(%ebp)
  8014da:	e8 c4 fe ff ff       	call   8013a3 <fd_lookup>
  8014df:	83 c4 08             	add    $0x8,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 10                	js     8014f6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	6a 01                	push   $0x1
  8014eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ee:	e8 59 ff ff ff       	call   80144c <fd_close>
  8014f3:	83 c4 10             	add    $0x10,%esp
}
  8014f6:	c9                   	leave  
  8014f7:	c3                   	ret    

008014f8 <close_all>:

void
close_all(void)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	53                   	push   %ebx
  8014fc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ff:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801504:	83 ec 0c             	sub    $0xc,%esp
  801507:	53                   	push   %ebx
  801508:	e8 c0 ff ff ff       	call   8014cd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80150d:	83 c3 01             	add    $0x1,%ebx
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	83 fb 20             	cmp    $0x20,%ebx
  801516:	75 ec                	jne    801504 <close_all+0xc>
		close(i);
}
  801518:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	57                   	push   %edi
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
  801523:	83 ec 2c             	sub    $0x2c,%esp
  801526:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801529:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80152c:	50                   	push   %eax
  80152d:	ff 75 08             	pushl  0x8(%ebp)
  801530:	e8 6e fe ff ff       	call   8013a3 <fd_lookup>
  801535:	83 c4 08             	add    $0x8,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	0f 88 c1 00 00 00    	js     801601 <dup+0xe4>
		return r;
	close(newfdnum);
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	56                   	push   %esi
  801544:	e8 84 ff ff ff       	call   8014cd <close>

	newfd = INDEX2FD(newfdnum);
  801549:	89 f3                	mov    %esi,%ebx
  80154b:	c1 e3 0c             	shl    $0xc,%ebx
  80154e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801554:	83 c4 04             	add    $0x4,%esp
  801557:	ff 75 e4             	pushl  -0x1c(%ebp)
  80155a:	e8 de fd ff ff       	call   80133d <fd2data>
  80155f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801561:	89 1c 24             	mov    %ebx,(%esp)
  801564:	e8 d4 fd ff ff       	call   80133d <fd2data>
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80156f:	89 f8                	mov    %edi,%eax
  801571:	c1 e8 16             	shr    $0x16,%eax
  801574:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80157b:	a8 01                	test   $0x1,%al
  80157d:	74 37                	je     8015b6 <dup+0x99>
  80157f:	89 f8                	mov    %edi,%eax
  801581:	c1 e8 0c             	shr    $0xc,%eax
  801584:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80158b:	f6 c2 01             	test   $0x1,%dl
  80158e:	74 26                	je     8015b6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801590:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	25 07 0e 00 00       	and    $0xe07,%eax
  80159f:	50                   	push   %eax
  8015a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015a3:	6a 00                	push   $0x0
  8015a5:	57                   	push   %edi
  8015a6:	6a 00                	push   $0x0
  8015a8:	e8 67 fb ff ff       	call   801114 <sys_page_map>
  8015ad:	89 c7                	mov    %eax,%edi
  8015af:	83 c4 20             	add    $0x20,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 2e                	js     8015e4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015b9:	89 d0                	mov    %edx,%eax
  8015bb:	c1 e8 0c             	shr    $0xc,%eax
  8015be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c5:	83 ec 0c             	sub    $0xc,%esp
  8015c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8015cd:	50                   	push   %eax
  8015ce:	53                   	push   %ebx
  8015cf:	6a 00                	push   $0x0
  8015d1:	52                   	push   %edx
  8015d2:	6a 00                	push   $0x0
  8015d4:	e8 3b fb ff ff       	call   801114 <sys_page_map>
  8015d9:	89 c7                	mov    %eax,%edi
  8015db:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015de:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e0:	85 ff                	test   %edi,%edi
  8015e2:	79 1d                	jns    801601 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	53                   	push   %ebx
  8015e8:	6a 00                	push   $0x0
  8015ea:	e8 67 fb ff ff       	call   801156 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015ef:	83 c4 08             	add    $0x8,%esp
  8015f2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015f5:	6a 00                	push   $0x0
  8015f7:	e8 5a fb ff ff       	call   801156 <sys_page_unmap>
	return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	89 f8                	mov    %edi,%eax
}
  801601:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5f                   	pop    %edi
  801607:	5d                   	pop    %ebp
  801608:	c3                   	ret    

00801609 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	53                   	push   %ebx
  80160d:	83 ec 14             	sub    $0x14,%esp
  801610:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801613:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801616:	50                   	push   %eax
  801617:	53                   	push   %ebx
  801618:	e8 86 fd ff ff       	call   8013a3 <fd_lookup>
  80161d:	83 c4 08             	add    $0x8,%esp
  801620:	89 c2                	mov    %eax,%edx
  801622:	85 c0                	test   %eax,%eax
  801624:	78 6d                	js     801693 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801630:	ff 30                	pushl  (%eax)
  801632:	e8 c2 fd ff ff       	call   8013f9 <dev_lookup>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 4c                	js     80168a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80163e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801641:	8b 42 08             	mov    0x8(%edx),%eax
  801644:	83 e0 03             	and    $0x3,%eax
  801647:	83 f8 01             	cmp    $0x1,%eax
  80164a:	75 21                	jne    80166d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80164c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801651:	8b 40 48             	mov    0x48(%eax),%eax
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	53                   	push   %ebx
  801658:	50                   	push   %eax
  801659:	68 b0 28 80 00       	push   $0x8028b0
  80165e:	e8 67 f0 ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80166b:	eb 26                	jmp    801693 <read+0x8a>
	}
	if (!dev->dev_read)
  80166d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801670:	8b 40 08             	mov    0x8(%eax),%eax
  801673:	85 c0                	test   %eax,%eax
  801675:	74 17                	je     80168e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801677:	83 ec 04             	sub    $0x4,%esp
  80167a:	ff 75 10             	pushl  0x10(%ebp)
  80167d:	ff 75 0c             	pushl  0xc(%ebp)
  801680:	52                   	push   %edx
  801681:	ff d0                	call   *%eax
  801683:	89 c2                	mov    %eax,%edx
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	eb 09                	jmp    801693 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	eb 05                	jmp    801693 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80168e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801693:	89 d0                	mov    %edx,%eax
  801695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	57                   	push   %edi
  80169e:	56                   	push   %esi
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 0c             	sub    $0xc,%esp
  8016a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ae:	eb 21                	jmp    8016d1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016b0:	83 ec 04             	sub    $0x4,%esp
  8016b3:	89 f0                	mov    %esi,%eax
  8016b5:	29 d8                	sub    %ebx,%eax
  8016b7:	50                   	push   %eax
  8016b8:	89 d8                	mov    %ebx,%eax
  8016ba:	03 45 0c             	add    0xc(%ebp),%eax
  8016bd:	50                   	push   %eax
  8016be:	57                   	push   %edi
  8016bf:	e8 45 ff ff ff       	call   801609 <read>
		if (m < 0)
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 10                	js     8016db <readn+0x41>
			return m;
		if (m == 0)
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	74 0a                	je     8016d9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016cf:	01 c3                	add    %eax,%ebx
  8016d1:	39 f3                	cmp    %esi,%ebx
  8016d3:	72 db                	jb     8016b0 <readn+0x16>
  8016d5:	89 d8                	mov    %ebx,%eax
  8016d7:	eb 02                	jmp    8016db <readn+0x41>
  8016d9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5f                   	pop    %edi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 14             	sub    $0x14,%esp
  8016ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	53                   	push   %ebx
  8016f2:	e8 ac fc ff ff       	call   8013a3 <fd_lookup>
  8016f7:	83 c4 08             	add    $0x8,%esp
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 68                	js     801768 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801706:	50                   	push   %eax
  801707:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170a:	ff 30                	pushl  (%eax)
  80170c:	e8 e8 fc ff ff       	call   8013f9 <dev_lookup>
  801711:	83 c4 10             	add    $0x10,%esp
  801714:	85 c0                	test   %eax,%eax
  801716:	78 47                	js     80175f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801718:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80171f:	75 21                	jne    801742 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801721:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801726:	8b 40 48             	mov    0x48(%eax),%eax
  801729:	83 ec 04             	sub    $0x4,%esp
  80172c:	53                   	push   %ebx
  80172d:	50                   	push   %eax
  80172e:	68 cc 28 80 00       	push   $0x8028cc
  801733:	e8 92 ef ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801740:	eb 26                	jmp    801768 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801742:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801745:	8b 52 0c             	mov    0xc(%edx),%edx
  801748:	85 d2                	test   %edx,%edx
  80174a:	74 17                	je     801763 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80174c:	83 ec 04             	sub    $0x4,%esp
  80174f:	ff 75 10             	pushl  0x10(%ebp)
  801752:	ff 75 0c             	pushl  0xc(%ebp)
  801755:	50                   	push   %eax
  801756:	ff d2                	call   *%edx
  801758:	89 c2                	mov    %eax,%edx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	eb 09                	jmp    801768 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	89 c2                	mov    %eax,%edx
  801761:	eb 05                	jmp    801768 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801763:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801768:	89 d0                	mov    %edx,%eax
  80176a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <seek>:

int
seek(int fdnum, off_t offset)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801775:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801778:	50                   	push   %eax
  801779:	ff 75 08             	pushl  0x8(%ebp)
  80177c:	e8 22 fc ff ff       	call   8013a3 <fd_lookup>
  801781:	83 c4 08             	add    $0x8,%esp
  801784:	85 c0                	test   %eax,%eax
  801786:	78 0e                	js     801796 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801788:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80178b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801791:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801796:	c9                   	leave  
  801797:	c3                   	ret    

00801798 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	53                   	push   %ebx
  80179c:	83 ec 14             	sub    $0x14,%esp
  80179f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a5:	50                   	push   %eax
  8017a6:	53                   	push   %ebx
  8017a7:	e8 f7 fb ff ff       	call   8013a3 <fd_lookup>
  8017ac:	83 c4 08             	add    $0x8,%esp
  8017af:	89 c2                	mov    %eax,%edx
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 65                	js     80181a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b5:	83 ec 08             	sub    $0x8,%esp
  8017b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017bb:	50                   	push   %eax
  8017bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bf:	ff 30                	pushl  (%eax)
  8017c1:	e8 33 fc ff ff       	call   8013f9 <dev_lookup>
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	78 44                	js     801811 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d4:	75 21                	jne    8017f7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017d6:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017db:	8b 40 48             	mov    0x48(%eax),%eax
  8017de:	83 ec 04             	sub    $0x4,%esp
  8017e1:	53                   	push   %ebx
  8017e2:	50                   	push   %eax
  8017e3:	68 8c 28 80 00       	push   $0x80288c
  8017e8:	e8 dd ee ff ff       	call   8006ca <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017f5:	eb 23                	jmp    80181a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017fa:	8b 52 18             	mov    0x18(%edx),%edx
  8017fd:	85 d2                	test   %edx,%edx
  8017ff:	74 14                	je     801815 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801801:	83 ec 08             	sub    $0x8,%esp
  801804:	ff 75 0c             	pushl  0xc(%ebp)
  801807:	50                   	push   %eax
  801808:	ff d2                	call   *%edx
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	eb 09                	jmp    80181a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801811:	89 c2                	mov    %eax,%edx
  801813:	eb 05                	jmp    80181a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801815:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80181a:	89 d0                	mov    %edx,%eax
  80181c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	53                   	push   %ebx
  801825:	83 ec 14             	sub    $0x14,%esp
  801828:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182e:	50                   	push   %eax
  80182f:	ff 75 08             	pushl  0x8(%ebp)
  801832:	e8 6c fb ff ff       	call   8013a3 <fd_lookup>
  801837:	83 c4 08             	add    $0x8,%esp
  80183a:	89 c2                	mov    %eax,%edx
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 58                	js     801898 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801846:	50                   	push   %eax
  801847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184a:	ff 30                	pushl  (%eax)
  80184c:	e8 a8 fb ff ff       	call   8013f9 <dev_lookup>
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	78 37                	js     80188f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801858:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80185f:	74 32                	je     801893 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801861:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801864:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80186b:	00 00 00 
	stat->st_isdir = 0;
  80186e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801875:	00 00 00 
	stat->st_dev = dev;
  801878:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	53                   	push   %ebx
  801882:	ff 75 f0             	pushl  -0x10(%ebp)
  801885:	ff 50 14             	call   *0x14(%eax)
  801888:	89 c2                	mov    %eax,%edx
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	eb 09                	jmp    801898 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188f:	89 c2                	mov    %eax,%edx
  801891:	eb 05                	jmp    801898 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801893:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801898:	89 d0                	mov    %edx,%eax
  80189a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	56                   	push   %esi
  8018a3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	6a 00                	push   $0x0
  8018a9:	ff 75 08             	pushl  0x8(%ebp)
  8018ac:	e8 e3 01 00 00       	call   801a94 <open>
  8018b1:	89 c3                	mov    %eax,%ebx
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 1b                	js     8018d5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018ba:	83 ec 08             	sub    $0x8,%esp
  8018bd:	ff 75 0c             	pushl  0xc(%ebp)
  8018c0:	50                   	push   %eax
  8018c1:	e8 5b ff ff ff       	call   801821 <fstat>
  8018c6:	89 c6                	mov    %eax,%esi
	close(fd);
  8018c8:	89 1c 24             	mov    %ebx,(%esp)
  8018cb:	e8 fd fb ff ff       	call   8014cd <close>
	return r;
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	89 f0                	mov    %esi,%eax
}
  8018d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	89 c6                	mov    %eax,%esi
  8018e3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018e5:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8018ec:	75 12                	jne    801900 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018ee:	83 ec 0c             	sub    $0xc,%esp
  8018f1:	6a 01                	push   $0x1
  8018f3:	e8 e5 07 00 00       	call   8020dd <ipc_find_env>
  8018f8:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018fd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801900:	6a 07                	push   $0x7
  801902:	68 00 50 80 00       	push   $0x805000
  801907:	56                   	push   %esi
  801908:	ff 35 ac 40 80 00    	pushl  0x8040ac
  80190e:	e8 76 07 00 00       	call   802089 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801913:	83 c4 0c             	add    $0xc,%esp
  801916:	6a 00                	push   $0x0
  801918:	53                   	push   %ebx
  801919:	6a 00                	push   $0x0
  80191b:	e8 f7 06 00 00       	call   802017 <ipc_recv>
}
  801920:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801923:	5b                   	pop    %ebx
  801924:	5e                   	pop    %esi
  801925:	5d                   	pop    %ebp
  801926:	c3                   	ret    

00801927 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80192d:	8b 45 08             	mov    0x8(%ebp),%eax
  801930:	8b 40 0c             	mov    0xc(%eax),%eax
  801933:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801938:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801940:	ba 00 00 00 00       	mov    $0x0,%edx
  801945:	b8 02 00 00 00       	mov    $0x2,%eax
  80194a:	e8 8d ff ff ff       	call   8018dc <fsipc>
}
  80194f:	c9                   	leave  
  801950:	c3                   	ret    

00801951 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
  80195a:	8b 40 0c             	mov    0xc(%eax),%eax
  80195d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801962:	ba 00 00 00 00       	mov    $0x0,%edx
  801967:	b8 06 00 00 00       	mov    $0x6,%eax
  80196c:	e8 6b ff ff ff       	call   8018dc <fsipc>
}
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	53                   	push   %ebx
  801977:	83 ec 04             	sub    $0x4,%esp
  80197a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80197d:	8b 45 08             	mov    0x8(%ebp),%eax
  801980:	8b 40 0c             	mov    0xc(%eax),%eax
  801983:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801988:	ba 00 00 00 00       	mov    $0x0,%edx
  80198d:	b8 05 00 00 00       	mov    $0x5,%eax
  801992:	e8 45 ff ff ff       	call   8018dc <fsipc>
  801997:	85 c0                	test   %eax,%eax
  801999:	78 2c                	js     8019c7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80199b:	83 ec 08             	sub    $0x8,%esp
  80199e:	68 00 50 80 00       	push   $0x805000
  8019a3:	53                   	push   %ebx
  8019a4:	e8 25 f3 ff ff       	call   800cce <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019a9:	a1 80 50 80 00       	mov    0x805080,%eax
  8019ae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019b4:	a1 84 50 80 00       	mov    0x805084,%eax
  8019b9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019d5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019da:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019df:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8019e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8019e8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019ee:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019f3:	50                   	push   %eax
  8019f4:	ff 75 0c             	pushl  0xc(%ebp)
  8019f7:	68 08 50 80 00       	push   $0x805008
  8019fc:	e8 5f f4 ff ff       	call   800e60 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  801a01:	ba 00 00 00 00       	mov    $0x0,%edx
  801a06:	b8 04 00 00 00       	mov    $0x4,%eax
  801a0b:	e8 cc fe ff ff       	call   8018dc <fsipc>
}
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	56                   	push   %esi
  801a16:	53                   	push   %ebx
  801a17:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a20:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a25:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a30:	b8 03 00 00 00       	mov    $0x3,%eax
  801a35:	e8 a2 fe ff ff       	call   8018dc <fsipc>
  801a3a:	89 c3                	mov    %eax,%ebx
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 4b                	js     801a8b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a40:	39 c6                	cmp    %eax,%esi
  801a42:	73 16                	jae    801a5a <devfile_read+0x48>
  801a44:	68 fc 28 80 00       	push   $0x8028fc
  801a49:	68 03 29 80 00       	push   $0x802903
  801a4e:	6a 7c                	push   $0x7c
  801a50:	68 18 29 80 00       	push   $0x802918
  801a55:	e8 97 eb ff ff       	call   8005f1 <_panic>
	assert(r <= PGSIZE);
  801a5a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a5f:	7e 16                	jle    801a77 <devfile_read+0x65>
  801a61:	68 23 29 80 00       	push   $0x802923
  801a66:	68 03 29 80 00       	push   $0x802903
  801a6b:	6a 7d                	push   $0x7d
  801a6d:	68 18 29 80 00       	push   $0x802918
  801a72:	e8 7a eb ff ff       	call   8005f1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a77:	83 ec 04             	sub    $0x4,%esp
  801a7a:	50                   	push   %eax
  801a7b:	68 00 50 80 00       	push   $0x805000
  801a80:	ff 75 0c             	pushl  0xc(%ebp)
  801a83:	e8 d8 f3 ff ff       	call   800e60 <memmove>
	return r;
  801a88:	83 c4 10             	add    $0x10,%esp
}
  801a8b:	89 d8                	mov    %ebx,%eax
  801a8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a90:	5b                   	pop    %ebx
  801a91:	5e                   	pop    %esi
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    

00801a94 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	53                   	push   %ebx
  801a98:	83 ec 20             	sub    $0x20,%esp
  801a9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a9e:	53                   	push   %ebx
  801a9f:	e8 f1 f1 ff ff       	call   800c95 <strlen>
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aac:	7f 67                	jg     801b15 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab4:	50                   	push   %eax
  801ab5:	e8 9a f8 ff ff       	call   801354 <fd_alloc>
  801aba:	83 c4 10             	add    $0x10,%esp
		return r;
  801abd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	78 57                	js     801b1a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ac3:	83 ec 08             	sub    $0x8,%esp
  801ac6:	53                   	push   %ebx
  801ac7:	68 00 50 80 00       	push   $0x805000
  801acc:	e8 fd f1 ff ff       	call   800cce <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ad9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801adc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ae1:	e8 f6 fd ff ff       	call   8018dc <fsipc>
  801ae6:	89 c3                	mov    %eax,%ebx
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	79 14                	jns    801b03 <open+0x6f>
		fd_close(fd, 0);
  801aef:	83 ec 08             	sub    $0x8,%esp
  801af2:	6a 00                	push   $0x0
  801af4:	ff 75 f4             	pushl  -0xc(%ebp)
  801af7:	e8 50 f9 ff ff       	call   80144c <fd_close>
		return r;
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	89 da                	mov    %ebx,%edx
  801b01:	eb 17                	jmp    801b1a <open+0x86>
	}

	return fd2num(fd);
  801b03:	83 ec 0c             	sub    $0xc,%esp
  801b06:	ff 75 f4             	pushl  -0xc(%ebp)
  801b09:	e8 1f f8 ff ff       	call   80132d <fd2num>
  801b0e:	89 c2                	mov    %eax,%edx
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	eb 05                	jmp    801b1a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b15:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b1a:	89 d0                	mov    %edx,%eax
  801b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    

00801b21 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b27:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2c:	b8 08 00 00 00       	mov    $0x8,%eax
  801b31:	e8 a6 fd ff ff       	call   8018dc <fsipc>
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	56                   	push   %esi
  801b3c:	53                   	push   %ebx
  801b3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b40:	83 ec 0c             	sub    $0xc,%esp
  801b43:	ff 75 08             	pushl  0x8(%ebp)
  801b46:	e8 f2 f7 ff ff       	call   80133d <fd2data>
  801b4b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b4d:	83 c4 08             	add    $0x8,%esp
  801b50:	68 2f 29 80 00       	push   $0x80292f
  801b55:	53                   	push   %ebx
  801b56:	e8 73 f1 ff ff       	call   800cce <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b5b:	8b 46 04             	mov    0x4(%esi),%eax
  801b5e:	2b 06                	sub    (%esi),%eax
  801b60:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b66:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b6d:	00 00 00 
	stat->st_dev = &devpipe;
  801b70:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b77:	30 80 00 
	return 0;
}
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 0c             	sub    $0xc,%esp
  801b8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b90:	53                   	push   %ebx
  801b91:	6a 00                	push   $0x0
  801b93:	e8 be f5 ff ff       	call   801156 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b98:	89 1c 24             	mov    %ebx,(%esp)
  801b9b:	e8 9d f7 ff ff       	call   80133d <fd2data>
  801ba0:	83 c4 08             	add    $0x8,%esp
  801ba3:	50                   	push   %eax
  801ba4:	6a 00                	push   $0x0
  801ba6:	e8 ab f5 ff ff       	call   801156 <sys_page_unmap>
}
  801bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	57                   	push   %edi
  801bb4:	56                   	push   %esi
  801bb5:	53                   	push   %ebx
  801bb6:	83 ec 1c             	sub    $0x1c,%esp
  801bb9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bbc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bbe:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801bc3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	ff 75 e0             	pushl  -0x20(%ebp)
  801bcc:	e8 45 05 00 00       	call   802116 <pageref>
  801bd1:	89 c3                	mov    %eax,%ebx
  801bd3:	89 3c 24             	mov    %edi,(%esp)
  801bd6:	e8 3b 05 00 00       	call   802116 <pageref>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	39 c3                	cmp    %eax,%ebx
  801be0:	0f 94 c1             	sete   %cl
  801be3:	0f b6 c9             	movzbl %cl,%ecx
  801be6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801be9:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801bef:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bf2:	39 ce                	cmp    %ecx,%esi
  801bf4:	74 1b                	je     801c11 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bf6:	39 c3                	cmp    %eax,%ebx
  801bf8:	75 c4                	jne    801bbe <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bfa:	8b 42 58             	mov    0x58(%edx),%eax
  801bfd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c00:	50                   	push   %eax
  801c01:	56                   	push   %esi
  801c02:	68 36 29 80 00       	push   $0x802936
  801c07:	e8 be ea ff ff       	call   8006ca <cprintf>
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	eb ad                	jmp    801bbe <_pipeisclosed+0xe>
	}
}
  801c11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c17:	5b                   	pop    %ebx
  801c18:	5e                   	pop    %esi
  801c19:	5f                   	pop    %edi
  801c1a:	5d                   	pop    %ebp
  801c1b:	c3                   	ret    

00801c1c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	57                   	push   %edi
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	83 ec 28             	sub    $0x28,%esp
  801c25:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c28:	56                   	push   %esi
  801c29:	e8 0f f7 ff ff       	call   80133d <fd2data>
  801c2e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	bf 00 00 00 00       	mov    $0x0,%edi
  801c38:	eb 4b                	jmp    801c85 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c3a:	89 da                	mov    %ebx,%edx
  801c3c:	89 f0                	mov    %esi,%eax
  801c3e:	e8 6d ff ff ff       	call   801bb0 <_pipeisclosed>
  801c43:	85 c0                	test   %eax,%eax
  801c45:	75 48                	jne    801c8f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c47:	e8 66 f4 ff ff       	call   8010b2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c4c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c4f:	8b 0b                	mov    (%ebx),%ecx
  801c51:	8d 51 20             	lea    0x20(%ecx),%edx
  801c54:	39 d0                	cmp    %edx,%eax
  801c56:	73 e2                	jae    801c3a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c5b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c5f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c62:	89 c2                	mov    %eax,%edx
  801c64:	c1 fa 1f             	sar    $0x1f,%edx
  801c67:	89 d1                	mov    %edx,%ecx
  801c69:	c1 e9 1b             	shr    $0x1b,%ecx
  801c6c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c6f:	83 e2 1f             	and    $0x1f,%edx
  801c72:	29 ca                	sub    %ecx,%edx
  801c74:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c78:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c7c:	83 c0 01             	add    $0x1,%eax
  801c7f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c82:	83 c7 01             	add    $0x1,%edi
  801c85:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c88:	75 c2                	jne    801c4c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c8a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8d:	eb 05                	jmp    801c94 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c8f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c97:	5b                   	pop    %ebx
  801c98:	5e                   	pop    %esi
  801c99:	5f                   	pop    %edi
  801c9a:	5d                   	pop    %ebp
  801c9b:	c3                   	ret    

00801c9c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	57                   	push   %edi
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	83 ec 18             	sub    $0x18,%esp
  801ca5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ca8:	57                   	push   %edi
  801ca9:	e8 8f f6 ff ff       	call   80133d <fd2data>
  801cae:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cb8:	eb 3d                	jmp    801cf7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cba:	85 db                	test   %ebx,%ebx
  801cbc:	74 04                	je     801cc2 <devpipe_read+0x26>
				return i;
  801cbe:	89 d8                	mov    %ebx,%eax
  801cc0:	eb 44                	jmp    801d06 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	89 f8                	mov    %edi,%eax
  801cc6:	e8 e5 fe ff ff       	call   801bb0 <_pipeisclosed>
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	75 32                	jne    801d01 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ccf:	e8 de f3 ff ff       	call   8010b2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cd4:	8b 06                	mov    (%esi),%eax
  801cd6:	3b 46 04             	cmp    0x4(%esi),%eax
  801cd9:	74 df                	je     801cba <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cdb:	99                   	cltd   
  801cdc:	c1 ea 1b             	shr    $0x1b,%edx
  801cdf:	01 d0                	add    %edx,%eax
  801ce1:	83 e0 1f             	and    $0x1f,%eax
  801ce4:	29 d0                	sub    %edx,%eax
  801ce6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cee:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cf1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf4:	83 c3 01             	add    $0x1,%ebx
  801cf7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cfa:	75 d8                	jne    801cd4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cfc:	8b 45 10             	mov    0x10(%ebp),%eax
  801cff:	eb 05                	jmp    801d06 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d01:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d09:	5b                   	pop    %ebx
  801d0a:	5e                   	pop    %esi
  801d0b:	5f                   	pop    %edi
  801d0c:	5d                   	pop    %ebp
  801d0d:	c3                   	ret    

00801d0e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	56                   	push   %esi
  801d12:	53                   	push   %ebx
  801d13:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d19:	50                   	push   %eax
  801d1a:	e8 35 f6 ff ff       	call   801354 <fd_alloc>
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	89 c2                	mov    %eax,%edx
  801d24:	85 c0                	test   %eax,%eax
  801d26:	0f 88 2c 01 00 00    	js     801e58 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d2c:	83 ec 04             	sub    $0x4,%esp
  801d2f:	68 07 04 00 00       	push   $0x407
  801d34:	ff 75 f4             	pushl  -0xc(%ebp)
  801d37:	6a 00                	push   $0x0
  801d39:	e8 93 f3 ff ff       	call   8010d1 <sys_page_alloc>
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	89 c2                	mov    %eax,%edx
  801d43:	85 c0                	test   %eax,%eax
  801d45:	0f 88 0d 01 00 00    	js     801e58 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d4b:	83 ec 0c             	sub    $0xc,%esp
  801d4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d51:	50                   	push   %eax
  801d52:	e8 fd f5 ff ff       	call   801354 <fd_alloc>
  801d57:	89 c3                	mov    %eax,%ebx
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	0f 88 e2 00 00 00    	js     801e46 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d64:	83 ec 04             	sub    $0x4,%esp
  801d67:	68 07 04 00 00       	push   $0x407
  801d6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6f:	6a 00                	push   $0x0
  801d71:	e8 5b f3 ff ff       	call   8010d1 <sys_page_alloc>
  801d76:	89 c3                	mov    %eax,%ebx
  801d78:	83 c4 10             	add    $0x10,%esp
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	0f 88 c3 00 00 00    	js     801e46 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	ff 75 f4             	pushl  -0xc(%ebp)
  801d89:	e8 af f5 ff ff       	call   80133d <fd2data>
  801d8e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d90:	83 c4 0c             	add    $0xc,%esp
  801d93:	68 07 04 00 00       	push   $0x407
  801d98:	50                   	push   %eax
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 31 f3 ff ff       	call   8010d1 <sys_page_alloc>
  801da0:	89 c3                	mov    %eax,%ebx
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	85 c0                	test   %eax,%eax
  801da7:	0f 88 89 00 00 00    	js     801e36 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dad:	83 ec 0c             	sub    $0xc,%esp
  801db0:	ff 75 f0             	pushl  -0x10(%ebp)
  801db3:	e8 85 f5 ff ff       	call   80133d <fd2data>
  801db8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dbf:	50                   	push   %eax
  801dc0:	6a 00                	push   $0x0
  801dc2:	56                   	push   %esi
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 4a f3 ff ff       	call   801114 <sys_page_map>
  801dca:	89 c3                	mov    %eax,%ebx
  801dcc:	83 c4 20             	add    $0x20,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 55                	js     801e28 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dd3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801de8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dfd:	83 ec 0c             	sub    $0xc,%esp
  801e00:	ff 75 f4             	pushl  -0xc(%ebp)
  801e03:	e8 25 f5 ff ff       	call   80132d <fd2num>
  801e08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e0b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e0d:	83 c4 04             	add    $0x4,%esp
  801e10:	ff 75 f0             	pushl  -0x10(%ebp)
  801e13:	e8 15 f5 ff ff       	call   80132d <fd2num>
  801e18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e1b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	ba 00 00 00 00       	mov    $0x0,%edx
  801e26:	eb 30                	jmp    801e58 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e28:	83 ec 08             	sub    $0x8,%esp
  801e2b:	56                   	push   %esi
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 23 f3 ff ff       	call   801156 <sys_page_unmap>
  801e33:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e36:	83 ec 08             	sub    $0x8,%esp
  801e39:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3c:	6a 00                	push   $0x0
  801e3e:	e8 13 f3 ff ff       	call   801156 <sys_page_unmap>
  801e43:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e46:	83 ec 08             	sub    $0x8,%esp
  801e49:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4c:	6a 00                	push   $0x0
  801e4e:	e8 03 f3 ff ff       	call   801156 <sys_page_unmap>
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e58:	89 d0                	mov    %edx,%eax
  801e5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5d:	5b                   	pop    %ebx
  801e5e:	5e                   	pop    %esi
  801e5f:	5d                   	pop    %ebp
  801e60:	c3                   	ret    

00801e61 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6a:	50                   	push   %eax
  801e6b:	ff 75 08             	pushl  0x8(%ebp)
  801e6e:	e8 30 f5 ff ff       	call   8013a3 <fd_lookup>
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 18                	js     801e92 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e7a:	83 ec 0c             	sub    $0xc,%esp
  801e7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e80:	e8 b8 f4 ff ff       	call   80133d <fd2data>
	return _pipeisclosed(fd, p);
  801e85:	89 c2                	mov    %eax,%edx
  801e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8a:	e8 21 fd ff ff       	call   801bb0 <_pipeisclosed>
  801e8f:	83 c4 10             	add    $0x10,%esp
}
  801e92:	c9                   	leave  
  801e93:	c3                   	ret    

00801e94 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e97:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9c:	5d                   	pop    %ebp
  801e9d:	c3                   	ret    

00801e9e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ea4:	68 4e 29 80 00       	push   $0x80294e
  801ea9:	ff 75 0c             	pushl  0xc(%ebp)
  801eac:	e8 1d ee ff ff       	call   800cce <strcpy>
	return 0;
}
  801eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	57                   	push   %edi
  801ebc:	56                   	push   %esi
  801ebd:	53                   	push   %ebx
  801ebe:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ec9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ecf:	eb 2d                	jmp    801efe <devcons_write+0x46>
		m = n - tot;
  801ed1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ed4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ed6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ed9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ede:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee1:	83 ec 04             	sub    $0x4,%esp
  801ee4:	53                   	push   %ebx
  801ee5:	03 45 0c             	add    0xc(%ebp),%eax
  801ee8:	50                   	push   %eax
  801ee9:	57                   	push   %edi
  801eea:	e8 71 ef ff ff       	call   800e60 <memmove>
		sys_cputs(buf, m);
  801eef:	83 c4 08             	add    $0x8,%esp
  801ef2:	53                   	push   %ebx
  801ef3:	57                   	push   %edi
  801ef4:	e8 1c f1 ff ff       	call   801015 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef9:	01 de                	add    %ebx,%esi
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	89 f0                	mov    %esi,%eax
  801f00:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f03:	72 cc                	jb     801ed1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5f                   	pop    %edi
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    

00801f0d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	83 ec 08             	sub    $0x8,%esp
  801f13:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f1c:	74 2a                	je     801f48 <devcons_read+0x3b>
  801f1e:	eb 05                	jmp    801f25 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f20:	e8 8d f1 ff ff       	call   8010b2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f25:	e8 09 f1 ff ff       	call   801033 <sys_cgetc>
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	74 f2                	je     801f20 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	78 16                	js     801f48 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f32:	83 f8 04             	cmp    $0x4,%eax
  801f35:	74 0c                	je     801f43 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f37:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f3a:	88 02                	mov    %al,(%edx)
	return 1;
  801f3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f41:	eb 05                	jmp    801f48 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f43:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f48:	c9                   	leave  
  801f49:	c3                   	ret    

00801f4a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f50:	8b 45 08             	mov    0x8(%ebp),%eax
  801f53:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f56:	6a 01                	push   $0x1
  801f58:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f5b:	50                   	push   %eax
  801f5c:	e8 b4 f0 ff ff       	call   801015 <sys_cputs>
}
  801f61:	83 c4 10             	add    $0x10,%esp
  801f64:	c9                   	leave  
  801f65:	c3                   	ret    

00801f66 <getchar>:

int
getchar(void)
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f6c:	6a 01                	push   $0x1
  801f6e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f71:	50                   	push   %eax
  801f72:	6a 00                	push   $0x0
  801f74:	e8 90 f6 ff ff       	call   801609 <read>
	if (r < 0)
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	78 0f                	js     801f8f <getchar+0x29>
		return r;
	if (r < 1)
  801f80:	85 c0                	test   %eax,%eax
  801f82:	7e 06                	jle    801f8a <getchar+0x24>
		return -E_EOF;
	return c;
  801f84:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f88:	eb 05                	jmp    801f8f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f8a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9a:	50                   	push   %eax
  801f9b:	ff 75 08             	pushl  0x8(%ebp)
  801f9e:	e8 00 f4 ff ff       	call   8013a3 <fd_lookup>
  801fa3:	83 c4 10             	add    $0x10,%esp
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	78 11                	js     801fbb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fb3:	39 10                	cmp    %edx,(%eax)
  801fb5:	0f 94 c0             	sete   %al
  801fb8:	0f b6 c0             	movzbl %al,%eax
}
  801fbb:	c9                   	leave  
  801fbc:	c3                   	ret    

00801fbd <opencons>:

int
opencons(void)
{
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
  801fc0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc6:	50                   	push   %eax
  801fc7:	e8 88 f3 ff ff       	call   801354 <fd_alloc>
  801fcc:	83 c4 10             	add    $0x10,%esp
		return r;
  801fcf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	78 3e                	js     802013 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd5:	83 ec 04             	sub    $0x4,%esp
  801fd8:	68 07 04 00 00       	push   $0x407
  801fdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe0:	6a 00                	push   $0x0
  801fe2:	e8 ea f0 ff ff       	call   8010d1 <sys_page_alloc>
  801fe7:	83 c4 10             	add    $0x10,%esp
		return r;
  801fea:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fec:	85 c0                	test   %eax,%eax
  801fee:	78 23                	js     802013 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ff0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802005:	83 ec 0c             	sub    $0xc,%esp
  802008:	50                   	push   %eax
  802009:	e8 1f f3 ff ff       	call   80132d <fd2num>
  80200e:	89 c2                	mov    %eax,%edx
  802010:	83 c4 10             	add    $0x10,%esp
}
  802013:	89 d0                	mov    %edx,%eax
  802015:	c9                   	leave  
  802016:	c3                   	ret    

00802017 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	56                   	push   %esi
  80201b:	53                   	push   %ebx
  80201c:	8b 75 08             	mov    0x8(%ebp),%esi
  80201f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802022:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  802025:	85 c0                	test   %eax,%eax
  802027:	74 0e                	je     802037 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  802029:	83 ec 0c             	sub    $0xc,%esp
  80202c:	50                   	push   %eax
  80202d:	e8 4f f2 ff ff       	call   801281 <sys_ipc_recv>
  802032:	83 c4 10             	add    $0x10,%esp
  802035:	eb 0d                	jmp    802044 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  802037:	83 ec 0c             	sub    $0xc,%esp
  80203a:	6a ff                	push   $0xffffffff
  80203c:	e8 40 f2 ff ff       	call   801281 <sys_ipc_recv>
  802041:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  802044:	85 c0                	test   %eax,%eax
  802046:	79 16                	jns    80205e <ipc_recv+0x47>

		if (from_env_store != NULL)
  802048:	85 f6                	test   %esi,%esi
  80204a:	74 06                	je     802052 <ipc_recv+0x3b>
			*from_env_store = 0;
  80204c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  802052:	85 db                	test   %ebx,%ebx
  802054:	74 2c                	je     802082 <ipc_recv+0x6b>
			*perm_store = 0;
  802056:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80205c:	eb 24                	jmp    802082 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  80205e:	85 f6                	test   %esi,%esi
  802060:	74 0a                	je     80206c <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  802062:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802067:	8b 40 74             	mov    0x74(%eax),%eax
  80206a:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  80206c:	85 db                	test   %ebx,%ebx
  80206e:	74 0a                	je     80207a <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  802070:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802075:	8b 40 78             	mov    0x78(%eax),%eax
  802078:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  80207a:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80207f:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802082:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802085:	5b                   	pop    %ebx
  802086:	5e                   	pop    %esi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    

00802089 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	57                   	push   %edi
  80208d:	56                   	push   %esi
  80208e:	53                   	push   %ebx
  80208f:	83 ec 0c             	sub    $0xc,%esp
  802092:	8b 7d 08             	mov    0x8(%ebp),%edi
  802095:	8b 75 0c             	mov    0xc(%ebp),%esi
  802098:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  80209b:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  80209d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8020a2:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020a5:	ff 75 14             	pushl  0x14(%ebp)
  8020a8:	53                   	push   %ebx
  8020a9:	56                   	push   %esi
  8020aa:	57                   	push   %edi
  8020ab:	e8 ae f1 ff ff       	call   80125e <sys_ipc_try_send>
		if (r >= 0)
  8020b0:	83 c4 10             	add    $0x10,%esp
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	79 1e                	jns    8020d5 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  8020b7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ba:	74 12                	je     8020ce <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  8020bc:	50                   	push   %eax
  8020bd:	68 5a 29 80 00       	push   $0x80295a
  8020c2:	6a 49                	push   $0x49
  8020c4:	68 6d 29 80 00       	push   $0x80296d
  8020c9:	e8 23 e5 ff ff       	call   8005f1 <_panic>
	
		sys_yield();
  8020ce:	e8 df ef ff ff       	call   8010b2 <sys_yield>
	}
  8020d3:	eb d0                	jmp    8020a5 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8020d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d8:	5b                   	pop    %ebx
  8020d9:	5e                   	pop    %esi
  8020da:	5f                   	pop    %edi
  8020db:	5d                   	pop    %ebp
  8020dc:	c3                   	ret    

008020dd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020e3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020e8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020eb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020f1:	8b 52 50             	mov    0x50(%edx),%edx
  8020f4:	39 ca                	cmp    %ecx,%edx
  8020f6:	75 0d                	jne    802105 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802100:	8b 40 48             	mov    0x48(%eax),%eax
  802103:	eb 0f                	jmp    802114 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802105:	83 c0 01             	add    $0x1,%eax
  802108:	3d 00 04 00 00       	cmp    $0x400,%eax
  80210d:	75 d9                	jne    8020e8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80210f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    

00802116 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211c:	89 d0                	mov    %edx,%eax
  80211e:	c1 e8 16             	shr    $0x16,%eax
  802121:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802128:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212d:	f6 c1 01             	test   $0x1,%cl
  802130:	74 1d                	je     80214f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802132:	c1 ea 0c             	shr    $0xc,%edx
  802135:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80213c:	f6 c2 01             	test   $0x1,%dl
  80213f:	74 0e                	je     80214f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802141:	c1 ea 0c             	shr    $0xc,%edx
  802144:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80214b:	ef 
  80214c:	0f b7 c0             	movzwl %ax,%eax
}
  80214f:	5d                   	pop    %ebp
  802150:	c3                   	ret    
  802151:	66 90                	xchg   %ax,%ax
  802153:	66 90                	xchg   %ax,%ax
  802155:	66 90                	xchg   %ax,%ax
  802157:	66 90                	xchg   %ax,%ax
  802159:	66 90                	xchg   %ax,%ax
  80215b:	66 90                	xchg   %ax,%ax
  80215d:	66 90                	xchg   %ax,%ax
  80215f:	90                   	nop

00802160 <__udivdi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80216b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80216f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 f6                	test   %esi,%esi
  802179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80217d:	89 ca                	mov    %ecx,%edx
  80217f:	89 f8                	mov    %edi,%eax
  802181:	75 3d                	jne    8021c0 <__udivdi3+0x60>
  802183:	39 cf                	cmp    %ecx,%edi
  802185:	0f 87 c5 00 00 00    	ja     802250 <__udivdi3+0xf0>
  80218b:	85 ff                	test   %edi,%edi
  80218d:	89 fd                	mov    %edi,%ebp
  80218f:	75 0b                	jne    80219c <__udivdi3+0x3c>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	31 d2                	xor    %edx,%edx
  802198:	f7 f7                	div    %edi
  80219a:	89 c5                	mov    %eax,%ebp
  80219c:	89 c8                	mov    %ecx,%eax
  80219e:	31 d2                	xor    %edx,%edx
  8021a0:	f7 f5                	div    %ebp
  8021a2:	89 c1                	mov    %eax,%ecx
  8021a4:	89 d8                	mov    %ebx,%eax
  8021a6:	89 cf                	mov    %ecx,%edi
  8021a8:	f7 f5                	div    %ebp
  8021aa:	89 c3                	mov    %eax,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	39 ce                	cmp    %ecx,%esi
  8021c2:	77 74                	ja     802238 <__udivdi3+0xd8>
  8021c4:	0f bd fe             	bsr    %esi,%edi
  8021c7:	83 f7 1f             	xor    $0x1f,%edi
  8021ca:	0f 84 98 00 00 00    	je     802268 <__udivdi3+0x108>
  8021d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	89 c5                	mov    %eax,%ebp
  8021d9:	29 fb                	sub    %edi,%ebx
  8021db:	d3 e6                	shl    %cl,%esi
  8021dd:	89 d9                	mov    %ebx,%ecx
  8021df:	d3 ed                	shr    %cl,%ebp
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	d3 e0                	shl    %cl,%eax
  8021e5:	09 ee                	or     %ebp,%esi
  8021e7:	89 d9                	mov    %ebx,%ecx
  8021e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ed:	89 d5                	mov    %edx,%ebp
  8021ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021f3:	d3 ed                	shr    %cl,%ebp
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	d3 e2                	shl    %cl,%edx
  8021f9:	89 d9                	mov    %ebx,%ecx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	09 c2                	or     %eax,%edx
  8021ff:	89 d0                	mov    %edx,%eax
  802201:	89 ea                	mov    %ebp,%edx
  802203:	f7 f6                	div    %esi
  802205:	89 d5                	mov    %edx,%ebp
  802207:	89 c3                	mov    %eax,%ebx
  802209:	f7 64 24 0c          	mull   0xc(%esp)
  80220d:	39 d5                	cmp    %edx,%ebp
  80220f:	72 10                	jb     802221 <__udivdi3+0xc1>
  802211:	8b 74 24 08          	mov    0x8(%esp),%esi
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e6                	shl    %cl,%esi
  802219:	39 c6                	cmp    %eax,%esi
  80221b:	73 07                	jae    802224 <__udivdi3+0xc4>
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	75 03                	jne    802224 <__udivdi3+0xc4>
  802221:	83 eb 01             	sub    $0x1,%ebx
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 d8                	mov    %ebx,%eax
  802228:	89 fa                	mov    %edi,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	31 ff                	xor    %edi,%edi
  80223a:	31 db                	xor    %ebx,%ebx
  80223c:	89 d8                	mov    %ebx,%eax
  80223e:	89 fa                	mov    %edi,%edx
  802240:	83 c4 1c             	add    $0x1c,%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	90                   	nop
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 d8                	mov    %ebx,%eax
  802252:	f7 f7                	div    %edi
  802254:	31 ff                	xor    %edi,%edi
  802256:	89 c3                	mov    %eax,%ebx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 fa                	mov    %edi,%edx
  80225c:	83 c4 1c             	add    $0x1c,%esp
  80225f:	5b                   	pop    %ebx
  802260:	5e                   	pop    %esi
  802261:	5f                   	pop    %edi
  802262:	5d                   	pop    %ebp
  802263:	c3                   	ret    
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	39 ce                	cmp    %ecx,%esi
  80226a:	72 0c                	jb     802278 <__udivdi3+0x118>
  80226c:	31 db                	xor    %ebx,%ebx
  80226e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802272:	0f 87 34 ff ff ff    	ja     8021ac <__udivdi3+0x4c>
  802278:	bb 01 00 00 00       	mov    $0x1,%ebx
  80227d:	e9 2a ff ff ff       	jmp    8021ac <__udivdi3+0x4c>
  802282:	66 90                	xchg   %ax,%ax
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	53                   	push   %ebx
  802294:	83 ec 1c             	sub    $0x1c,%esp
  802297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80229b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80229f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022a7:	85 d2                	test   %edx,%edx
  8022a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b1:	89 f3                	mov    %esi,%ebx
  8022b3:	89 3c 24             	mov    %edi,(%esp)
  8022b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ba:	75 1c                	jne    8022d8 <__umoddi3+0x48>
  8022bc:	39 f7                	cmp    %esi,%edi
  8022be:	76 50                	jbe    802310 <__umoddi3+0x80>
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	f7 f7                	div    %edi
  8022c6:	89 d0                	mov    %edx,%eax
  8022c8:	31 d2                	xor    %edx,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	89 d0                	mov    %edx,%eax
  8022dc:	77 52                	ja     802330 <__umoddi3+0xa0>
  8022de:	0f bd ea             	bsr    %edx,%ebp
  8022e1:	83 f5 1f             	xor    $0x1f,%ebp
  8022e4:	75 5a                	jne    802340 <__umoddi3+0xb0>
  8022e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ea:	0f 82 e0 00 00 00    	jb     8023d0 <__umoddi3+0x140>
  8022f0:	39 0c 24             	cmp    %ecx,(%esp)
  8022f3:	0f 86 d7 00 00 00    	jbe    8023d0 <__umoddi3+0x140>
  8022f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	85 ff                	test   %edi,%edi
  802312:	89 fd                	mov    %edi,%ebp
  802314:	75 0b                	jne    802321 <__umoddi3+0x91>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f7                	div    %edi
  80231f:	89 c5                	mov    %eax,%ebp
  802321:	89 f0                	mov    %esi,%eax
  802323:	31 d2                	xor    %edx,%edx
  802325:	f7 f5                	div    %ebp
  802327:	89 c8                	mov    %ecx,%eax
  802329:	f7 f5                	div    %ebp
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	eb 99                	jmp    8022c8 <__umoddi3+0x38>
  80232f:	90                   	nop
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	83 c4 1c             	add    $0x1c,%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5f                   	pop    %edi
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	8b 34 24             	mov    (%esp),%esi
  802343:	bf 20 00 00 00       	mov    $0x20,%edi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	29 ef                	sub    %ebp,%edi
  80234c:	d3 e0                	shl    %cl,%eax
  80234e:	89 f9                	mov    %edi,%ecx
  802350:	89 f2                	mov    %esi,%edx
  802352:	d3 ea                	shr    %cl,%edx
  802354:	89 e9                	mov    %ebp,%ecx
  802356:	09 c2                	or     %eax,%edx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 14 24             	mov    %edx,(%esp)
  80235d:	89 f2                	mov    %esi,%edx
  80235f:	d3 e2                	shl    %cl,%edx
  802361:	89 f9                	mov    %edi,%ecx
  802363:	89 54 24 04          	mov    %edx,0x4(%esp)
  802367:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	89 c6                	mov    %eax,%esi
  802371:	d3 e3                	shl    %cl,%ebx
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 d0                	mov    %edx,%eax
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	09 d8                	or     %ebx,%eax
  80237d:	89 d3                	mov    %edx,%ebx
  80237f:	89 f2                	mov    %esi,%edx
  802381:	f7 34 24             	divl   (%esp)
  802384:	89 d6                	mov    %edx,%esi
  802386:	d3 e3                	shl    %cl,%ebx
  802388:	f7 64 24 04          	mull   0x4(%esp)
  80238c:	39 d6                	cmp    %edx,%esi
  80238e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802392:	89 d1                	mov    %edx,%ecx
  802394:	89 c3                	mov    %eax,%ebx
  802396:	72 08                	jb     8023a0 <__umoddi3+0x110>
  802398:	75 11                	jne    8023ab <__umoddi3+0x11b>
  80239a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80239e:	73 0b                	jae    8023ab <__umoddi3+0x11b>
  8023a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023a4:	1b 14 24             	sbb    (%esp),%edx
  8023a7:	89 d1                	mov    %edx,%ecx
  8023a9:	89 c3                	mov    %eax,%ebx
  8023ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023af:	29 da                	sub    %ebx,%edx
  8023b1:	19 ce                	sbb    %ecx,%esi
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 f0                	mov    %esi,%eax
  8023b7:	d3 e0                	shl    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	d3 ea                	shr    %cl,%edx
  8023bd:	89 e9                	mov    %ebp,%ecx
  8023bf:	d3 ee                	shr    %cl,%esi
  8023c1:	09 d0                	or     %edx,%eax
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	83 c4 1c             	add    $0x1c,%esp
  8023c8:	5b                   	pop    %ebx
  8023c9:	5e                   	pop    %esi
  8023ca:	5f                   	pop    %edi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    
  8023cd:	8d 76 00             	lea    0x0(%esi),%esi
  8023d0:	29 f9                	sub    %edi,%ecx
  8023d2:	19 d6                	sbb    %edx,%esi
  8023d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023dc:	e9 18 ff ff ff       	jmp    8022f9 <__umoddi3+0x69>
