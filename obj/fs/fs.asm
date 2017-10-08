
obj/fs/fs：     文件格式 elf32-i386


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
  80002c:	e8 a0 18 00 00       	call   8018d1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 40 37 80 00       	push   $0x803740
  8000b7:	e8 4e 19 00 00       	call   801a0a <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 57 37 80 00       	push   $0x803757
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 67 37 80 00       	push   $0x803767
  8000e0:	e8 4c 18 00 00       	call   801931 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 70 37 80 00       	push   $0x803770
  80010b:	68 7d 37 80 00       	push   $0x80377d
  800110:	6a 44                	push   $0x44
  800112:	68 67 37 80 00       	push   $0x803767
  800117:	e8 15 18 00 00       	call   801931 <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 70 37 80 00       	push   $0x803770
  8001cf:	68 7d 37 80 00       	push   $0x80377d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 67 37 80 00       	push   $0x803767
  8001db:	e8 51 17 00 00       	call   801931 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800280:	8b 32                	mov    (%edx),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800282:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  800288:	89 c7                	mov    %eax,%edi
  80028a:	c1 ef 0c             	shr    $0xc,%edi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028d:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800292:	76 1b                	jbe    8002af <bc_pgfault+0x3b>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	ff 72 04             	pushl  0x4(%edx)
  80029a:	56                   	push   %esi
  80029b:	ff 72 28             	pushl  0x28(%edx)
  80029e:	68 94 37 80 00       	push   $0x803794
  8002a3:	6a 27                	push   $0x27
  8002a5:	68 50 38 80 00       	push   $0x803850
  8002aa:	e8 82 16 00 00       	call   801931 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002af:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 78 04             	cmp    0x4(%eax),%edi
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	57                   	push   %edi
  8002be:	68 c4 37 80 00       	push   $0x8037c4
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 50 38 80 00       	push   $0x803850
  8002ca:	e8 62 16 00 00       	call   801931 <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	void *raddr = ROUNDDOWN(addr, PGSIZE);
  8002cf:	89 f3                	mov    %esi,%ebx
  8002d1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t curenvid = sys_getenvid();
  8002d7:	e8 f7 20 00 00       	call   8023d3 <sys_getenvid>
	uint32_t secno = ((uint32_t)raddr - DISKMAP) / SECTSIZE;

	sys_page_alloc(curenvid, raddr, PTE_SYSCALL);
  8002dc:	83 ec 04             	sub    $0x4,%esp
  8002df:	68 07 0e 00 00       	push   $0xe07
  8002e4:	53                   	push   %ebx
  8002e5:	50                   	push   %eax
  8002e6:	e8 26 21 00 00       	call   802411 <sys_page_alloc>
	ide_read(secno, raddr, BLKSECTS);
  8002eb:	83 c4 0c             	add    $0xc,%esp
  8002ee:	6a 08                	push   $0x8
  8002f0:	53                   	push   %ebx
  8002f1:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  8002f7:	c1 eb 09             	shr    $0x9,%ebx
  8002fa:	53                   	push   %ebx
  8002fb:	e8 ec fd ff ff       	call   8000ec <ide_read>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800300:	89 f0                	mov    %esi,%eax
  800302:	c1 e8 0c             	shr    $0xc,%eax
  800305:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80030c:	25 07 0e 00 00       	and    $0xe07,%eax
  800311:	89 04 24             	mov    %eax,(%esp)
  800314:	56                   	push   %esi
  800315:	6a 00                	push   $0x0
  800317:	56                   	push   %esi
  800318:	6a 00                	push   $0x0
  80031a:	e8 35 21 00 00       	call   802454 <sys_page_map>
  80031f:	83 c4 20             	add    $0x20,%esp
  800322:	85 c0                	test   %eax,%eax
  800324:	79 12                	jns    800338 <bc_pgfault+0xc4>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800326:	50                   	push   %eax
  800327:	68 e8 37 80 00       	push   $0x8037e8
  80032c:	6a 3d                	push   $0x3d
  80032e:	68 50 38 80 00       	push   $0x803850
  800333:	e8 f9 15 00 00       	call   801931 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800338:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  80033f:	74 22                	je     800363 <bc_pgfault+0xef>
  800341:	83 ec 0c             	sub    $0xc,%esp
  800344:	57                   	push   %edi
  800345:	e8 1a 03 00 00       	call   800664 <block_is_free>
  80034a:	83 c4 10             	add    $0x10,%esp
  80034d:	84 c0                	test   %al,%al
  80034f:	74 12                	je     800363 <bc_pgfault+0xef>
		panic("reading free block %08x\n", blockno);
  800351:	57                   	push   %edi
  800352:	68 58 38 80 00       	push   $0x803858
  800357:	6a 43                	push   $0x43
  800359:	68 50 38 80 00       	push   $0x803850
  80035e:	e8 ce 15 00 00       	call   801931 <_panic>
}
  800363:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800366:	5b                   	pop    %ebx
  800367:	5e                   	pop    %esi
  800368:	5f                   	pop    %edi
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	83 ec 08             	sub    $0x8,%esp
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800374:	85 c0                	test   %eax,%eax
  800376:	74 0f                	je     800387 <diskaddr+0x1c>
  800378:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80037e:	85 d2                	test   %edx,%edx
  800380:	74 17                	je     800399 <diskaddr+0x2e>
  800382:	3b 42 04             	cmp    0x4(%edx),%eax
  800385:	72 12                	jb     800399 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  800387:	50                   	push   %eax
  800388:	68 08 38 80 00       	push   $0x803808
  80038d:	6a 09                	push   $0x9
  80038f:	68 50 38 80 00       	push   $0x803850
  800394:	e8 98 15 00 00       	call   801931 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  800399:	05 00 00 01 00       	add    $0x10000,%eax
  80039e:	c1 e0 0c             	shl    $0xc,%eax
}
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003a9:	89 d0                	mov    %edx,%eax
  8003ab:	c1 e8 16             	shr    $0x16,%eax
  8003ae:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ba:	f6 c1 01             	test   $0x1,%cl
  8003bd:	74 0d                	je     8003cc <va_is_mapped+0x29>
  8003bf:	c1 ea 0c             	shr    $0xc,%edx
  8003c2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003c9:	83 e0 01             	and    $0x1,%eax
  8003cc:	83 e0 01             	and    $0x1,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d7:	c1 e8 0c             	shr    $0xc,%eax
  8003da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003e1:	c1 e8 06             	shr    $0x6,%eax
  8003e4:	83 e0 01             	and    $0x1,%eax
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8003f1:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  8003f7:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8003fc:	76 12                	jbe    800410 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  8003fe:	53                   	push   %ebx
  8003ff:	68 71 38 80 00       	push   $0x803871
  800404:	6a 53                	push   $0x53
  800406:	68 50 38 80 00       	push   $0x803850
  80040b:	e8 21 15 00 00       	call   801931 <_panic>

	// LAB 5: Your code here.
	void *raddr = ROUNDDOWN(addr, PGSIZE);
	envid_t curenvid = sys_getenvid();
  800410:	e8 be 1f 00 00       	call   8023d3 <sys_getenvid>
  800415:	89 c6                	mov    %eax,%esi
	uint32_t secno = ((uint32_t)raddr - DISKMAP) / SECTSIZE;

	if (!(!va_is_mapped(addr) || !va_is_dirty(addr))) {
  800417:	83 ec 0c             	sub    $0xc,%esp
  80041a:	53                   	push   %ebx
  80041b:	e8 83 ff ff ff       	call   8003a3 <va_is_mapped>
  800420:	83 c4 10             	add    $0x10,%esp
  800423:	84 c0                	test   %al,%al
  800425:	74 3e                	je     800465 <flush_block+0x7c>
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	53                   	push   %ebx
  80042b:	e8 a1 ff ff ff       	call   8003d1 <va_is_dirty>
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	84 c0                	test   %al,%al
  800435:	74 2e                	je     800465 <flush_block+0x7c>
		ide_write(secno, addr, BLKSECTS);
  800437:	83 ec 04             	sub    $0x4,%esp
  80043a:	6a 08                	push   $0x8
  80043c:	53                   	push   %ebx
  80043d:	89 d8                	mov    %ebx,%eax
  80043f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800444:	2d 00 00 00 10       	sub    $0x10000000,%eax
  800449:	c1 e8 09             	shr    $0x9,%eax
  80044c:	50                   	push   %eax
  80044d:	e8 5e fd ff ff       	call   8001b0 <ide_write>
		sys_page_map(curenvid, addr, curenvid, addr, PTE_SYSCALL);
  800452:	c7 04 24 07 0e 00 00 	movl   $0xe07,(%esp)
  800459:	53                   	push   %ebx
  80045a:	56                   	push   %esi
  80045b:	53                   	push   %ebx
  80045c:	56                   	push   %esi
  80045d:	e8 f2 1f 00 00       	call   802454 <sys_page_map>
  800462:	83 c4 20             	add    $0x20,%esp
	}

	//panic("flush_block not implemented");
}
  800465:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800468:	5b                   	pop    %ebx
  800469:	5e                   	pop    %esi
  80046a:	5d                   	pop    %ebp
  80046b:	c3                   	ret    

0080046c <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  800475:	68 74 02 80 00       	push   $0x800274
  80047a:	e8 83 21 00 00       	call   802602 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  80047f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800486:	e8 e0 fe ff ff       	call   80036b <diskaddr>
  80048b:	83 c4 0c             	add    $0xc,%esp
  80048e:	68 08 01 00 00       	push   $0x108
  800493:	50                   	push   %eax
  800494:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80049a:	50                   	push   %eax
  80049b:	e8 00 1d 00 00       	call   8021a0 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004a7:	e8 bf fe ff ff       	call   80036b <diskaddr>
  8004ac:	83 c4 08             	add    $0x8,%esp
  8004af:	68 8c 38 80 00       	push   $0x80388c
  8004b4:	50                   	push   %eax
  8004b5:	e8 54 1b 00 00       	call   80200e <strcpy>
	flush_block(diskaddr(1));
  8004ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004c1:	e8 a5 fe ff ff       	call   80036b <diskaddr>
  8004c6:	89 04 24             	mov    %eax,(%esp)
  8004c9:	e8 1b ff ff ff       	call   8003e9 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8004ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004d5:	e8 91 fe ff ff       	call   80036b <diskaddr>
  8004da:	89 04 24             	mov    %eax,(%esp)
  8004dd:	e8 c1 fe ff ff       	call   8003a3 <va_is_mapped>
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	84 c0                	test   %al,%al
  8004e7:	75 16                	jne    8004ff <bc_init+0x93>
  8004e9:	68 ae 38 80 00       	push   $0x8038ae
  8004ee:	68 7d 37 80 00       	push   $0x80377d
  8004f3:	6a 6f                	push   $0x6f
  8004f5:	68 50 38 80 00       	push   $0x803850
  8004fa:	e8 32 14 00 00       	call   801931 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  8004ff:	83 ec 0c             	sub    $0xc,%esp
  800502:	6a 01                	push   $0x1
  800504:	e8 62 fe ff ff       	call   80036b <diskaddr>
  800509:	89 04 24             	mov    %eax,(%esp)
  80050c:	e8 c0 fe ff ff       	call   8003d1 <va_is_dirty>
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	84 c0                	test   %al,%al
  800516:	74 16                	je     80052e <bc_init+0xc2>
  800518:	68 93 38 80 00       	push   $0x803893
  80051d:	68 7d 37 80 00       	push   $0x80377d
  800522:	6a 70                	push   $0x70
  800524:	68 50 38 80 00       	push   $0x803850
  800529:	e8 03 14 00 00       	call   801931 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	6a 01                	push   $0x1
  800533:	e8 33 fe ff ff       	call   80036b <diskaddr>
  800538:	83 c4 08             	add    $0x8,%esp
  80053b:	50                   	push   %eax
  80053c:	6a 00                	push   $0x0
  80053e:	e8 53 1f 00 00       	call   802496 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800543:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80054a:	e8 1c fe ff ff       	call   80036b <diskaddr>
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	e8 4c fe ff ff       	call   8003a3 <va_is_mapped>
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	84 c0                	test   %al,%al
  80055c:	74 16                	je     800574 <bc_init+0x108>
  80055e:	68 ad 38 80 00       	push   $0x8038ad
  800563:	68 7d 37 80 00       	push   $0x80377d
  800568:	6a 74                	push   $0x74
  80056a:	68 50 38 80 00       	push   $0x803850
  80056f:	e8 bd 13 00 00       	call   801931 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800574:	83 ec 0c             	sub    $0xc,%esp
  800577:	6a 01                	push   $0x1
  800579:	e8 ed fd ff ff       	call   80036b <diskaddr>
  80057e:	83 c4 08             	add    $0x8,%esp
  800581:	68 8c 38 80 00       	push   $0x80388c
  800586:	50                   	push   %eax
  800587:	e8 2c 1b 00 00       	call   8020b8 <strcmp>
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	85 c0                	test   %eax,%eax
  800591:	74 16                	je     8005a9 <bc_init+0x13d>
  800593:	68 2c 38 80 00       	push   $0x80382c
  800598:	68 7d 37 80 00       	push   $0x80377d
  80059d:	6a 77                	push   $0x77
  80059f:	68 50 38 80 00       	push   $0x803850
  8005a4:	e8 88 13 00 00       	call   801931 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8005a9:	83 ec 0c             	sub    $0xc,%esp
  8005ac:	6a 01                	push   $0x1
  8005ae:	e8 b8 fd ff ff       	call   80036b <diskaddr>
  8005b3:	83 c4 0c             	add    $0xc,%esp
  8005b6:	68 08 01 00 00       	push   $0x108
  8005bb:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8005c1:	52                   	push   %edx
  8005c2:	50                   	push   %eax
  8005c3:	e8 d8 1b 00 00       	call   8021a0 <memmove>
	flush_block(diskaddr(1));
  8005c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005cf:	e8 97 fd ff ff       	call   80036b <diskaddr>
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	e8 0d fe ff ff       	call   8003e9 <flush_block>

	cprintf("block cache is good\n");
  8005dc:	c7 04 24 c8 38 80 00 	movl   $0x8038c8,(%esp)
  8005e3:	e8 22 14 00 00       	call   801a0a <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  8005e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ef:	e8 77 fd ff ff       	call   80036b <diskaddr>
  8005f4:	83 c4 0c             	add    $0xc,%esp
  8005f7:	68 08 01 00 00       	push   $0x108
  8005fc:	50                   	push   %eax
  8005fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800603:	50                   	push   %eax
  800604:	e8 97 1b 00 00       	call   8021a0 <memmove>
}
  800609:	83 c4 10             	add    $0x10,%esp
  80060c:	c9                   	leave  
  80060d:	c3                   	ret    

0080060e <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80060e:	55                   	push   %ebp
  80060f:	89 e5                	mov    %esp,%ebp
  800611:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800614:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800619:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80061f:	74 14                	je     800635 <check_super+0x27>
		panic("bad file system magic number");
  800621:	83 ec 04             	sub    $0x4,%esp
  800624:	68 dd 38 80 00       	push   $0x8038dd
  800629:	6a 0f                	push   $0xf
  80062b:	68 fa 38 80 00       	push   $0x8038fa
  800630:	e8 fc 12 00 00       	call   801931 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800635:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  80063c:	76 14                	jbe    800652 <check_super+0x44>
		panic("file system is too large");
  80063e:	83 ec 04             	sub    $0x4,%esp
  800641:	68 02 39 80 00       	push   $0x803902
  800646:	6a 12                	push   $0x12
  800648:	68 fa 38 80 00       	push   $0x8038fa
  80064d:	e8 df 12 00 00       	call   801931 <_panic>

	cprintf("superblock is good\n");
  800652:	83 ec 0c             	sub    $0xc,%esp
  800655:	68 1b 39 80 00       	push   $0x80391b
  80065a:	e8 ab 13 00 00       	call   801a0a <cprintf>
}
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	c9                   	leave  
  800663:	c3                   	ret    

00800664 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800664:	55                   	push   %ebp
  800665:	89 e5                	mov    %esp,%ebp
  800667:	53                   	push   %ebx
  800668:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80066b:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	74 24                	je     800699 <block_is_free+0x35>
		return 0;
  800675:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  80067a:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80067d:	76 1f                	jbe    80069e <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80067f:	89 cb                	mov    %ecx,%ebx
  800681:	c1 eb 05             	shr    $0x5,%ebx
  800684:	b8 01 00 00 00       	mov    $0x1,%eax
  800689:	d3 e0                	shl    %cl,%eax
  80068b:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800691:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800694:	0f 95 c0             	setne  %al
  800697:	eb 05                	jmp    80069e <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800699:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80069e:	5b                   	pop    %ebx
  80069f:	5d                   	pop    %ebp
  8006a0:	c3                   	ret    

008006a1 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
  8006a4:	53                   	push   %ebx
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  8006ab:	85 c9                	test   %ecx,%ecx
  8006ad:	75 14                	jne    8006c3 <free_block+0x22>
		panic("attempt to free zero block");
  8006af:	83 ec 04             	sub    $0x4,%esp
  8006b2:	68 2f 39 80 00       	push   $0x80392f
  8006b7:	6a 2d                	push   $0x2d
  8006b9:	68 fa 38 80 00       	push   $0x8038fa
  8006be:	e8 6e 12 00 00       	call   801931 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  8006c3:	89 cb                	mov    %ecx,%ebx
  8006c5:	c1 eb 05             	shr    $0x5,%ebx
  8006c8:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8006ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8006d3:	d3 e0                	shl    %cl,%eax
  8006d5:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  8006d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	57                   	push   %edi
  8006e1:	56                   	push   %esi
  8006e2:	53                   	push   %ebx
  8006e3:	83 ec 1c             	sub    $0x1c,%esp
		}
	}*/

	uint32_t i, j;

    for (i = 0; i < super->s_nblocks/32; i++) {
  8006e6:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8006eb:	8b 40 04             	mov    0x4(%eax),%eax
  8006ee:	c1 e8 05             	shr    $0x5,%eax
  8006f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006fb:	eb 52                	jmp    80074f <alloc_block+0x72>
		for (j = 0; j < 32; j++) {
			uint32_t match = (1 << j);
			if (block_is_free((i * 32) | j)) {
  8006fd:	89 fe                	mov    %edi,%esi
  8006ff:	09 de                	or     %ebx,%esi
  800701:	56                   	push   %esi
  800702:	e8 5d ff ff ff       	call   800664 <block_is_free>
  800707:	83 c4 04             	add    $0x4,%esp
  80070a:	84 c0                	test   %al,%al
  80070c:	74 35                	je     800743 <alloc_block+0x66>
				bitmap[i] &= ~match;
  80070e:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800714:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  800719:	89 d9                	mov    %ebx,%ecx
  80071b:	d3 c0                	rol    %cl,%eax
  80071d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800720:	21 04 8a             	and    %eax,(%edx,%ecx,4)
				flush_block(diskaddr((i * 32 | j)/BLKBITSIZE + 2));
  800723:	83 ec 0c             	sub    $0xc,%esp
  800726:	89 f0                	mov    %esi,%eax
  800728:	c1 e8 0f             	shr    $0xf,%eax
  80072b:	83 c0 02             	add    $0x2,%eax
  80072e:	50                   	push   %eax
  80072f:	e8 37 fc ff ff       	call   80036b <diskaddr>
  800734:	89 04 24             	mov    %eax,(%esp)
  800737:	e8 ad fc ff ff       	call   8003e9 <flush_block>
				return (i * 32) | j;
  80073c:	89 f0                	mov    %esi,%eax
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	eb 27                	jmp    80076a <alloc_block+0x8d>
	}*/

	uint32_t i, j;

    for (i = 0; i < super->s_nblocks/32; i++) {
		for (j = 0; j < 32; j++) {
  800743:	83 c3 01             	add    $0x1,%ebx
  800746:	83 fb 20             	cmp    $0x20,%ebx
  800749:	75 b2                	jne    8006fd <alloc_block+0x20>
		}
	}*/

	uint32_t i, j;

    for (i = 0; i < super->s_nblocks/32; i++) {
  80074b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  80074f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800752:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800755:	39 d0                	cmp    %edx,%eax
  800757:	74 0c                	je     800765 <alloc_block+0x88>
  800759:	89 c7                	mov    %eax,%edi
  80075b:	c1 e7 05             	shl    $0x5,%edi
  80075e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800763:	eb 98                	jmp    8006fd <alloc_block+0x20>
				return (i * 32) | j;
			}
		}
    }

	return -E_NO_DISK;
  800765:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  80076a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	5f                   	pop    %edi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	57                   	push   %edi
  800776:	56                   	push   %esi
  800777:	53                   	push   %ebx
  800778:	83 ec 1c             	sub    $0x1c,%esp
  80077b:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 5: Your code here.
	int ret = 0;

	if (filebno >= NDIRECT + NINDIRECT)
  80077e:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800784:	77 7d                	ja     800803 <file_block_walk+0x91>
		return -E_INVAL;

	if (filebno >= NDIRECT) {
  800786:	83 fa 09             	cmp    $0x9,%edx
  800789:	76 68                	jbe    8007f3 <file_block_walk+0x81>
  80078b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80078e:	89 d3                	mov    %edx,%ebx
  800790:	89 c7                	mov    %eax,%edi
		if (f->f_indirect == 0) {
  800792:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  800799:	75 35                	jne    8007d0 <file_block_walk+0x5e>
			if (!alloc)
  80079b:	89 f0                	mov    %esi,%eax
  80079d:	84 c0                	test   %al,%al
  80079f:	74 69                	je     80080a <file_block_walk+0x98>
				return -E_NOT_FOUND;
			else {
				ret = alloc_block();
  8007a1:	e8 37 ff ff ff       	call   8006dd <alloc_block>
  8007a6:	89 c6                	mov    %eax,%esi
				if (ret < 0)
  8007a8:	85 c0                	test   %eax,%eax
  8007aa:	78 65                	js     800811 <file_block_walk+0x9f>
					return -E_NO_DISK;
				
				f->f_indirect = ret;
  8007ac:	89 87 b0 00 00 00    	mov    %eax,0xb0(%edi)
				memset(diskaddr(ret), 0, BLKSIZE);
  8007b2:	83 ec 0c             	sub    $0xc,%esp
  8007b5:	50                   	push   %eax
  8007b6:	e8 b0 fb ff ff       	call   80036b <diskaddr>
  8007bb:	83 c4 0c             	add    $0xc,%esp
  8007be:	68 00 10 00 00       	push   $0x1000
  8007c3:	6a 00                	push   $0x0
  8007c5:	50                   	push   %eax
  8007c6:	e8 88 19 00 00       	call   802153 <memset>
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	eb 05                	jmp    8007d5 <file_block_walk+0x63>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
	// LAB 5: Your code here.
	int ret = 0;
  8007d0:	be 00 00 00 00       	mov    $0x0,%esi
				
				f->f_indirect = ret;
				memset(diskaddr(ret), 0, BLKSIZE);
			}
		}
		*ppdiskbno = &((uintptr_t *) diskaddr(f->f_indirect))[filebno - NDIRECT];
  8007d5:	83 ec 0c             	sub    $0xc,%esp
  8007d8:	ff b7 b0 00 00 00    	pushl  0xb0(%edi)
  8007de:	e8 88 fb ff ff       	call   80036b <diskaddr>
  8007e3:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  8007e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007ea:	89 03                	mov    %eax,(%ebx)
  8007ec:	83 c4 10             	add    $0x10,%esp
  8007ef:	89 f0                	mov    %esi,%eax
  8007f1:	eb 23                	jmp    800816 <file_block_walk+0xa4>
	} else
		*ppdiskbno = &f->f_direct[filebno];
  8007f3:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8007fa:	89 01                	mov    %eax,(%ecx)
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
	// LAB 5: Your code here.
	int ret = 0;
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800801:	eb 13                	jmp    800816 <file_block_walk+0xa4>

	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800808:	eb 0c                	jmp    800816 <file_block_walk+0xa4>

	if (filebno >= NDIRECT) {
		if (f->f_indirect == 0) {
			if (!alloc)
				return -E_NOT_FOUND;
  80080a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80080f:	eb 05                	jmp    800816 <file_block_walk+0xa4>
			else {
				ret = alloc_block();
				if (ret < 0)
					return -E_NO_DISK;
  800811:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
		*ppdiskbno = &((uintptr_t *) diskaddr(f->f_indirect))[filebno - NDIRECT];
	} else
		*ppdiskbno = &f->f_direct[filebno];

	return ret;
}
  800816:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5f                   	pop    %edi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800823:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800828:	8b 70 04             	mov    0x4(%eax),%esi
  80082b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800830:	eb 29                	jmp    80085b <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800832:	8d 43 02             	lea    0x2(%ebx),%eax
  800835:	50                   	push   %eax
  800836:	e8 29 fe ff ff       	call   800664 <block_is_free>
  80083b:	83 c4 04             	add    $0x4,%esp
  80083e:	84 c0                	test   %al,%al
  800840:	74 16                	je     800858 <check_bitmap+0x3a>
  800842:	68 4a 39 80 00       	push   $0x80394a
  800847:	68 7d 37 80 00       	push   $0x80377d
  80084c:	6a 64                	push   $0x64
  80084e:	68 fa 38 80 00       	push   $0x8038fa
  800853:	e8 d9 10 00 00       	call   801931 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800858:	83 c3 01             	add    $0x1,%ebx
  80085b:	89 d8                	mov    %ebx,%eax
  80085d:	c1 e0 0f             	shl    $0xf,%eax
  800860:	39 f0                	cmp    %esi,%eax
  800862:	72 ce                	jb     800832 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800864:	83 ec 0c             	sub    $0xc,%esp
  800867:	6a 00                	push   $0x0
  800869:	e8 f6 fd ff ff       	call   800664 <block_is_free>
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	84 c0                	test   %al,%al
  800873:	74 16                	je     80088b <check_bitmap+0x6d>
  800875:	68 5e 39 80 00       	push   $0x80395e
  80087a:	68 7d 37 80 00       	push   $0x80377d
  80087f:	6a 67                	push   $0x67
  800881:	68 fa 38 80 00       	push   $0x8038fa
  800886:	e8 a6 10 00 00       	call   801931 <_panic>
	assert(!block_is_free(1));
  80088b:	83 ec 0c             	sub    $0xc,%esp
  80088e:	6a 01                	push   $0x1
  800890:	e8 cf fd ff ff       	call   800664 <block_is_free>
  800895:	83 c4 10             	add    $0x10,%esp
  800898:	84 c0                	test   %al,%al
  80089a:	74 16                	je     8008b2 <check_bitmap+0x94>
  80089c:	68 70 39 80 00       	push   $0x803970
  8008a1:	68 7d 37 80 00       	push   $0x80377d
  8008a6:	6a 68                	push   $0x68
  8008a8:	68 fa 38 80 00       	push   $0x8038fa
  8008ad:	e8 7f 10 00 00       	call   801931 <_panic>

	cprintf("bitmap is good\n");
  8008b2:	83 ec 0c             	sub    $0xc,%esp
  8008b5:	68 82 39 80 00       	push   $0x803982
  8008ba:	e8 4b 11 00 00       	call   801a0a <cprintf>
}
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  8008cf:	e8 8b f7 ff ff       	call   80005f <ide_probe_disk1>
  8008d4:	84 c0                	test   %al,%al
  8008d6:	74 0f                	je     8008e7 <fs_init+0x1e>
               ide_set_disk(1);
  8008d8:	83 ec 0c             	sub    $0xc,%esp
  8008db:	6a 01                	push   $0x1
  8008dd:	e8 e1 f7 ff ff       	call   8000c3 <ide_set_disk>
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 0d                	jmp    8008f4 <fs_init+0x2b>
       else
               ide_set_disk(0);
  8008e7:	83 ec 0c             	sub    $0xc,%esp
  8008ea:	6a 00                	push   $0x0
  8008ec:	e8 d2 f7 ff ff       	call   8000c3 <ide_set_disk>
  8008f1:	83 c4 10             	add    $0x10,%esp
	bc_init();
  8008f4:	e8 73 fb ff ff       	call   80046c <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  8008f9:	83 ec 0c             	sub    $0xc,%esp
  8008fc:	6a 01                	push   $0x1
  8008fe:	e8 68 fa ff ff       	call   80036b <diskaddr>
  800903:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800908:	e8 01 fd ff ff       	call   80060e <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  80090d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800914:	e8 52 fa ff ff       	call   80036b <diskaddr>
  800919:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  80091e:	e8 fb fe ff ff       	call   80081e <check_bitmap>
	
}
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	83 ec 24             	sub    $0x24,%esp
	// LAB 5: Your code here.
	int ret, bno;
	uint32_t *ppdiskbno;

	ret = file_block_walk(f, filebno, &ppdiskbno, true);
  80092e:	6a 01                	push   $0x1
  800930:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800933:	8b 55 0c             	mov    0xc(%ebp),%edx
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	e8 34 fe ff ff       	call   800772 <file_block_walk>
	if (ret < 0)
  80093e:	83 c4 10             	add    $0x10,%esp
  800941:	85 c0                	test   %eax,%eax
  800943:	78 37                	js     80097c <file_get_block+0x54>
		return ret;
	else {
		if (*ppdiskbno == 0) {
  800945:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800948:	83 38 00             	cmpl   $0x0,(%eax)
  80094b:	75 0e                	jne    80095b <file_get_block+0x33>
			bno = alloc_block();
  80094d:	e8 8b fd ff ff       	call   8006dd <alloc_block>
			if (bno < 0)
  800952:	85 c0                	test   %eax,%eax
  800954:	78 21                	js     800977 <file_get_block+0x4f>
				return -E_NO_DISK;

			*ppdiskbno = bno;
  800956:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800959:	89 02                	mov    %eax,(%edx)
		}

		*blk = (char *)diskaddr(*ppdiskbno);
  80095b:	83 ec 0c             	sub    $0xc,%esp
  80095e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800961:	ff 30                	pushl  (%eax)
  800963:	e8 03 fa ff ff       	call   80036b <diskaddr>
  800968:	8b 55 10             	mov    0x10(%ebp),%edx
  80096b:	89 02                	mov    %eax,(%edx)
	}

	return 0;
  80096d:	83 c4 10             	add    $0x10,%esp
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
  800975:	eb 05                	jmp    80097c <file_get_block+0x54>
		return ret;
	else {
		if (*ppdiskbno == 0) {
			bno = alloc_block();
			if (bno < 0)
				return -E_NO_DISK;
  800977:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax

		*blk = (char *)diskaddr(*ppdiskbno);
	}

	return 0;
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	57                   	push   %edi
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  80098a:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800990:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800996:	eb 03                	jmp    80099b <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800998:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  80099b:	80 38 2f             	cmpb   $0x2f,(%eax)
  80099e:	74 f8                	je     800998 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  8009a0:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  8009a6:	83 c1 08             	add    $0x8,%ecx
  8009a9:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  8009af:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  8009b6:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	74 06                	je     8009c6 <walk_path+0x48>
		*pdir = 0;
  8009c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  8009c6:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  8009cc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  8009d2:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  8009d7:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  8009dd:	e9 5f 01 00 00       	jmp    800b41 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  8009e2:	83 c7 01             	add    $0x1,%edi
  8009e5:	eb 02                	jmp    8009e9 <walk_path+0x6b>
  8009e7:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  8009e9:	0f b6 17             	movzbl (%edi),%edx
  8009ec:	80 fa 2f             	cmp    $0x2f,%dl
  8009ef:	74 04                	je     8009f5 <walk_path+0x77>
  8009f1:	84 d2                	test   %dl,%dl
  8009f3:	75 ed                	jne    8009e2 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  8009f5:	89 fb                	mov    %edi,%ebx
  8009f7:	29 c3                	sub    %eax,%ebx
  8009f9:	83 fb 7f             	cmp    $0x7f,%ebx
  8009fc:	0f 8f 69 01 00 00    	jg     800b6b <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a02:	83 ec 04             	sub    $0x4,%esp
  800a05:	53                   	push   %ebx
  800a06:	50                   	push   %eax
  800a07:	56                   	push   %esi
  800a08:	e8 93 17 00 00       	call   8021a0 <memmove>
		name[path - p] = '\0';
  800a0d:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800a14:	00 
  800a15:	83 c4 10             	add    $0x10,%esp
  800a18:	eb 03                	jmp    800a1d <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a1a:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a1d:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800a20:	74 f8                	je     800a1a <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800a22:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800a28:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800a2f:	0f 85 3d 01 00 00    	jne    800b72 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800a35:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800a3b:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800a40:	74 19                	je     800a5b <walk_path+0xdd>
  800a42:	68 92 39 80 00       	push   $0x803992
  800a47:	68 7d 37 80 00       	push   $0x80377d
  800a4c:	68 e7 00 00 00       	push   $0xe7
  800a51:	68 fa 38 80 00       	push   $0x8038fa
  800a56:	e8 d6 0e 00 00       	call   801931 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800a5b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800a61:	85 c0                	test   %eax,%eax
  800a63:	0f 48 c2             	cmovs  %edx,%eax
  800a66:	c1 f8 0c             	sar    $0xc,%eax
  800a69:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800a6f:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800a76:	00 00 00 
  800a79:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800a7f:	eb 5e                	jmp    800adf <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800a81:	83 ec 04             	sub    $0x4,%esp
  800a84:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800a8a:	50                   	push   %eax
  800a8b:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800a91:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800a97:	e8 8c fe ff ff       	call   800928 <file_get_block>
  800a9c:	83 c4 10             	add    $0x10,%esp
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	0f 88 ee 00 00 00    	js     800b95 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800aa7:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800aad:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800ab3:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800ab9:	83 ec 08             	sub    $0x8,%esp
  800abc:	56                   	push   %esi
  800abd:	53                   	push   %ebx
  800abe:	e8 f5 15 00 00       	call   8020b8 <strcmp>
  800ac3:	83 c4 10             	add    $0x10,%esp
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	0f 84 ab 00 00 00    	je     800b79 <walk_path+0x1fb>
  800ace:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800ad4:	39 fb                	cmp    %edi,%ebx
  800ad6:	75 db                	jne    800ab3 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800ad8:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800adf:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800ae5:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800aeb:	75 94                	jne    800a81 <walk_path+0x103>
  800aed:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800af3:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800af8:	80 3f 00             	cmpb   $0x0,(%edi)
  800afb:	0f 85 a3 00 00 00    	jne    800ba4 <walk_path+0x226>
				if (pdir)
  800b01:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b07:	85 c0                	test   %eax,%eax
  800b09:	74 08                	je     800b13 <walk_path+0x195>
					*pdir = dir;
  800b0b:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b11:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800b13:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b17:	74 15                	je     800b2e <walk_path+0x1b0>
					strcpy(lastelem, name);
  800b19:	83 ec 08             	sub    $0x8,%esp
  800b1c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800b22:	50                   	push   %eax
  800b23:	ff 75 08             	pushl  0x8(%ebp)
  800b26:	e8 e3 14 00 00       	call   80200e <strcpy>
  800b2b:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800b2e:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800b3a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800b3f:	eb 63                	jmp    800ba4 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b41:	80 38 00             	cmpb   $0x0,(%eax)
  800b44:	0f 85 9d fe ff ff    	jne    8009e7 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800b4a:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b50:	85 c0                	test   %eax,%eax
  800b52:	74 02                	je     800b56 <walk_path+0x1d8>
		*pdir = dir;
  800b54:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800b56:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b5c:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b62:	89 08                	mov    %ecx,(%eax)
	return 0;
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
  800b69:	eb 39                	jmp    800ba4 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800b6b:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800b70:	eb 32                	jmp    800ba4 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800b72:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800b77:	eb 2b                	jmp    800ba4 <walk_path+0x226>
  800b79:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800b7f:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800b85:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800b8b:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800b91:	89 f8                	mov    %edi,%eax
  800b93:	eb ac                	jmp    800b41 <walk_path+0x1c3>
  800b95:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b9b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800b9e:	0f 84 4f ff ff ff    	je     800af3 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800bb2:	6a 00                	push   $0x0
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbf:	e8 ba fd ff ff       	call   80097e <walk_path>
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 2c             	sub    $0x2c,%esp
  800bcf:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bd2:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800be3:	39 ca                	cmp    %ecx,%edx
  800be5:	7e 7c                	jle    800c63 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800be7:	29 ca                	sub    %ecx,%edx
  800be9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bec:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800bf0:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800bf3:	89 ce                	mov    %ecx,%esi
  800bf5:	01 d1                	add    %edx,%ecx
  800bf7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800bfa:	eb 5d                	jmp    800c59 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800bfc:	83 ec 04             	sub    $0x4,%esp
  800bff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c02:	50                   	push   %eax
  800c03:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800c09:	85 f6                	test   %esi,%esi
  800c0b:	0f 49 c6             	cmovns %esi,%eax
  800c0e:	c1 f8 0c             	sar    $0xc,%eax
  800c11:	50                   	push   %eax
  800c12:	ff 75 08             	pushl  0x8(%ebp)
  800c15:	e8 0e fd ff ff       	call   800928 <file_get_block>
  800c1a:	83 c4 10             	add    $0x10,%esp
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	78 42                	js     800c63 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800c21:	89 f2                	mov    %esi,%edx
  800c23:	c1 fa 1f             	sar    $0x1f,%edx
  800c26:	c1 ea 14             	shr    $0x14,%edx
  800c29:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800c2c:	25 ff 0f 00 00       	and    $0xfff,%eax
  800c31:	29 d0                	sub    %edx,%eax
  800c33:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800c36:	29 da                	sub    %ebx,%edx
  800c38:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800c3d:	29 c3                	sub    %eax,%ebx
  800c3f:	39 da                	cmp    %ebx,%edx
  800c41:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800c44:	83 ec 04             	sub    $0x4,%esp
  800c47:	53                   	push   %ebx
  800c48:	03 45 e4             	add    -0x1c(%ebp),%eax
  800c4b:	50                   	push   %eax
  800c4c:	57                   	push   %edi
  800c4d:	e8 4e 15 00 00       	call   8021a0 <memmove>
		pos += bn;
  800c52:	01 de                	add    %ebx,%esi
		buf += bn;
  800c54:	01 df                	add    %ebx,%edi
  800c56:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800c59:	89 f3                	mov    %esi,%ebx
  800c5b:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800c5e:	77 9c                	ja     800bfc <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800c60:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 2c             	sub    $0x2c,%esp
  800c74:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800c77:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800c7d:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800c80:	0f 8e a7 00 00 00    	jle    800d2d <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800c86:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800c8c:	05 ff 0f 00 00       	add    $0xfff,%eax
  800c91:	0f 49 f8             	cmovns %eax,%edi
  800c94:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800c97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9a:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800c9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca2:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800ca8:	0f 49 c2             	cmovns %edx,%eax
  800cab:	c1 f8 0c             	sar    $0xc,%eax
  800cae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	eb 39                	jmp    800cee <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	6a 00                	push   $0x0
  800cba:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800cbd:	89 da                	mov    %ebx,%edx
  800cbf:	89 f0                	mov    %esi,%eax
  800cc1:	e8 ac fa ff ff       	call   800772 <file_block_walk>
  800cc6:	83 c4 10             	add    $0x10,%esp
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	78 4d                	js     800d1a <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800ccd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cd0:	8b 00                	mov    (%eax),%eax
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	74 15                	je     800ceb <file_set_size+0x80>
		free_block(*ptr);
  800cd6:	83 ec 0c             	sub    $0xc,%esp
  800cd9:	50                   	push   %eax
  800cda:	e8 c2 f9 ff ff       	call   8006a1 <free_block>
		*ptr = 0;
  800cdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ce2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800ce8:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ceb:	83 c3 01             	add    $0x1,%ebx
  800cee:	39 df                	cmp    %ebx,%edi
  800cf0:	77 c3                	ja     800cb5 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800cf2:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800cf6:	77 35                	ja     800d2d <file_set_size+0xc2>
  800cf8:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	74 2b                	je     800d2d <file_set_size+0xc2>
		free_block(f->f_indirect);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	e8 96 f9 ff ff       	call   8006a1 <free_block>
		f->f_indirect = 0;
  800d0b:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800d12:	00 00 00 
  800d15:	83 c4 10             	add    $0x10,%esp
  800d18:	eb 13                	jmp    800d2d <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800d1a:	83 ec 08             	sub    $0x8,%esp
  800d1d:	50                   	push   %eax
  800d1e:	68 af 39 80 00       	push   $0x8039af
  800d23:	e8 e2 0c 00 00       	call   801a0a <cprintf>
  800d28:	83 c4 10             	add    $0x10,%esp
  800d2b:	eb be                	jmp    800ceb <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d30:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	56                   	push   %esi
  800d3a:	e8 aa f6 ff ff       	call   8003e9 <flush_block>
	return 0;
}
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 2c             	sub    $0x2c,%esp
  800d55:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d58:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800d5b:	89 f0                	mov    %esi,%eax
  800d5d:	03 45 10             	add    0x10(%ebp),%eax
  800d60:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d66:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800d6c:	76 72                	jbe    800de0 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800d6e:	83 ec 08             	sub    $0x8,%esp
  800d71:	50                   	push   %eax
  800d72:	51                   	push   %ecx
  800d73:	e8 f3 fe ff ff       	call   800c6b <file_set_size>
  800d78:	83 c4 10             	add    $0x10,%esp
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	79 61                	jns    800de0 <file_write+0x94>
  800d7f:	eb 69                	jmp    800dea <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d87:	50                   	push   %eax
  800d88:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800d8e:	85 f6                	test   %esi,%esi
  800d90:	0f 49 c6             	cmovns %esi,%eax
  800d93:	c1 f8 0c             	sar    $0xc,%eax
  800d96:	50                   	push   %eax
  800d97:	ff 75 08             	pushl  0x8(%ebp)
  800d9a:	e8 89 fb ff ff       	call   800928 <file_get_block>
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	78 44                	js     800dea <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800da6:	89 f2                	mov    %esi,%edx
  800da8:	c1 fa 1f             	sar    $0x1f,%edx
  800dab:	c1 ea 14             	shr    $0x14,%edx
  800dae:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800db1:	25 ff 0f 00 00       	and    $0xfff,%eax
  800db6:	29 d0                	sub    %edx,%eax
  800db8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800dbb:	29 d9                	sub    %ebx,%ecx
  800dbd:	89 cb                	mov    %ecx,%ebx
  800dbf:	ba 00 10 00 00       	mov    $0x1000,%edx
  800dc4:	29 c2                	sub    %eax,%edx
  800dc6:	39 d1                	cmp    %edx,%ecx
  800dc8:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800dcb:	83 ec 04             	sub    $0x4,%esp
  800dce:	53                   	push   %ebx
  800dcf:	57                   	push   %edi
  800dd0:	03 45 e4             	add    -0x1c(%ebp),%eax
  800dd3:	50                   	push   %eax
  800dd4:	e8 c7 13 00 00       	call   8021a0 <memmove>
		pos += bn;
  800dd9:	01 de                	add    %ebx,%esi
		buf += bn;
  800ddb:	01 df                	add    %ebx,%edi
  800ddd:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800de0:	89 f3                	mov    %esi,%ebx
  800de2:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800de5:	77 9a                	ja     800d81 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800de7:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800dea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
  800df7:	83 ec 10             	sub    $0x10,%esp
  800dfa:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800dfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e02:	eb 3c                	jmp    800e40 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	6a 00                	push   $0x0
  800e09:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e0c:	89 da                	mov    %ebx,%edx
  800e0e:	89 f0                	mov    %esi,%eax
  800e10:	e8 5d f9 ff ff       	call   800772 <file_block_walk>
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	78 21                	js     800e3d <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	74 1a                	je     800e3d <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e23:	8b 00                	mov    (%eax),%eax
  800e25:	85 c0                	test   %eax,%eax
  800e27:	74 14                	je     800e3d <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800e29:	83 ec 0c             	sub    $0xc,%esp
  800e2c:	50                   	push   %eax
  800e2d:	e8 39 f5 ff ff       	call   80036b <diskaddr>
  800e32:	89 04 24             	mov    %eax,(%esp)
  800e35:	e8 af f5 ff ff       	call   8003e9 <flush_block>
  800e3a:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e3d:	83 c3 01             	add    $0x1,%ebx
  800e40:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800e46:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800e4c:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800e52:	85 c9                	test   %ecx,%ecx
  800e54:	0f 49 c1             	cmovns %ecx,%eax
  800e57:	c1 f8 0c             	sar    $0xc,%eax
  800e5a:	39 c3                	cmp    %eax,%ebx
  800e5c:	7c a6                	jl     800e04 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800e5e:	83 ec 0c             	sub    $0xc,%esp
  800e61:	56                   	push   %esi
  800e62:	e8 82 f5 ff ff       	call   8003e9 <flush_block>
	if (f->f_indirect)
  800e67:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	85 c0                	test   %eax,%eax
  800e72:	74 14                	je     800e88 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800e74:	83 ec 0c             	sub    $0xc,%esp
  800e77:	50                   	push   %eax
  800e78:	e8 ee f4 ff ff       	call   80036b <diskaddr>
  800e7d:	89 04 24             	mov    %eax,(%esp)
  800e80:	e8 64 f5 ff ff       	call   8003e9 <flush_block>
  800e85:	83 c4 10             	add    $0x10,%esp
}
  800e88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	57                   	push   %edi
  800e93:	56                   	push   %esi
  800e94:	53                   	push   %ebx
  800e95:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800e9b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800ea1:	50                   	push   %eax
  800ea2:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800ea8:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	e8 c8 fa ff ff       	call   80097e <walk_path>
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	0f 84 d1 00 00 00    	je     800f92 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800ec1:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ec4:	0f 85 0c 01 00 00    	jne    800fd6 <file_create+0x147>
  800eca:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800ed0:	85 f6                	test   %esi,%esi
  800ed2:	0f 84 c1 00 00 00    	je     800f99 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800ed8:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800ede:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800ee3:	74 19                	je     800efe <file_create+0x6f>
  800ee5:	68 92 39 80 00       	push   $0x803992
  800eea:	68 7d 37 80 00       	push   $0x80377d
  800eef:	68 00 01 00 00       	push   $0x100
  800ef4:	68 fa 38 80 00       	push   $0x8038fa
  800ef9:	e8 33 0a 00 00       	call   801931 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800efe:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f04:	85 c0                	test   %eax,%eax
  800f06:	0f 48 c2             	cmovs  %edx,%eax
  800f09:	c1 f8 0c             	sar    $0xc,%eax
  800f0c:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f12:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f17:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800f1d:	eb 3b                	jmp    800f5a <file_create+0xcb>
  800f1f:	83 ec 04             	sub    $0x4,%esp
  800f22:	57                   	push   %edi
  800f23:	53                   	push   %ebx
  800f24:	56                   	push   %esi
  800f25:	e8 fe f9 ff ff       	call   800928 <file_get_block>
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	0f 88 a1 00 00 00    	js     800fd6 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  800f35:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f3b:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800f41:	80 38 00             	cmpb   $0x0,(%eax)
  800f44:	75 08                	jne    800f4e <file_create+0xbf>
				*file = &f[j];
  800f46:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800f4c:	eb 52                	jmp    800fa0 <file_create+0x111>
  800f4e:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800f53:	39 d0                	cmp    %edx,%eax
  800f55:	75 ea                	jne    800f41 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800f57:	83 c3 01             	add    $0x1,%ebx
  800f5a:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800f60:	75 bd                	jne    800f1f <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800f62:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800f69:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800f75:	50                   	push   %eax
  800f76:	53                   	push   %ebx
  800f77:	56                   	push   %esi
  800f78:	e8 ab f9 ff ff       	call   800928 <file_get_block>
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 52                	js     800fd6 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  800f84:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f8a:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800f90:	eb 0e                	jmp    800fa0 <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800f92:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800f97:	eb 3d                	jmp    800fd6 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  800f99:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800f9e:	eb 36                	jmp    800fd6 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  800fa0:	83 ec 08             	sub    $0x8,%esp
  800fa3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800fa9:	50                   	push   %eax
  800faa:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  800fb0:	e8 59 10 00 00       	call   80200e <strcpy>
	*pf = f;
  800fb5:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbe:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  800fc0:	83 c4 04             	add    $0x4,%esp
  800fc3:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  800fc9:	e8 24 fe ff ff       	call   800df2 <file_flush>
	return 0;
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd9:	5b                   	pop    %ebx
  800fda:	5e                   	pop    %esi
  800fdb:	5f                   	pop    %edi
  800fdc:	5d                   	pop    %ebp
  800fdd:	c3                   	ret    

00800fde <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	53                   	push   %ebx
  800fe2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800fe5:	bb 01 00 00 00       	mov    $0x1,%ebx
  800fea:	eb 17                	jmp    801003 <fs_sync+0x25>
		flush_block(diskaddr(i));
  800fec:	83 ec 0c             	sub    $0xc,%esp
  800fef:	53                   	push   %ebx
  800ff0:	e8 76 f3 ff ff       	call   80036b <diskaddr>
  800ff5:	89 04 24             	mov    %eax,(%esp)
  800ff8:	e8 ec f3 ff ff       	call   8003e9 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800ffd:	83 c3 01             	add    $0x1,%ebx
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801008:	39 58 04             	cmp    %ebx,0x4(%eax)
  80100b:	77 df                	ja     800fec <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80100d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801018:	e8 c1 ff ff ff       	call   800fde <fs_sync>
	return 0;
}
  80101d:	b8 00 00 00 00       	mov    $0x0,%eax
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  80102c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801031:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801036:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  801038:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80103b:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801041:	83 c0 01             	add    $0x1,%eax
  801044:	83 c2 10             	add    $0x10,%edx
  801047:	3d 00 04 00 00       	cmp    $0x400,%eax
  80104c:	75 e8                	jne    801036 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801058:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	89 d8                	mov    %ebx,%eax
  801062:	c1 e0 04             	shl    $0x4,%eax
  801065:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80106b:	e8 07 1f 00 00       	call   802f77 <pageref>
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	74 07                	je     80107e <openfile_alloc+0x2e>
  801077:	83 f8 01             	cmp    $0x1,%eax
  80107a:	74 20                	je     80109c <openfile_alloc+0x4c>
  80107c:	eb 51                	jmp    8010cf <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  80107e:	83 ec 04             	sub    $0x4,%esp
  801081:	6a 07                	push   $0x7
  801083:	89 d8                	mov    %ebx,%eax
  801085:	c1 e0 04             	shl    $0x4,%eax
  801088:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80108e:	6a 00                	push   $0x0
  801090:	e8 7c 13 00 00       	call   802411 <sys_page_alloc>
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	78 43                	js     8010df <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  80109c:	c1 e3 04             	shl    $0x4,%ebx
  80109f:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8010a5:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8010ac:	04 00 00 
			*o = &opentab[i];
  8010af:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	68 00 10 00 00       	push   $0x1000
  8010b9:	6a 00                	push   $0x0
  8010bb:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  8010c1:	e8 8d 10 00 00       	call   802153 <memset>
			return (*o)->o_fileid;
  8010c6:	8b 06                	mov    (%esi),%eax
  8010c8:	8b 00                	mov    (%eax),%eax
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	eb 10                	jmp    8010df <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8010cf:	83 c3 01             	add    $0x1,%ebx
  8010d2:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8010d8:	75 83                	jne    80105d <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  8010da:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5e                   	pop    %esi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	57                   	push   %edi
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 18             	sub    $0x18,%esp
  8010ef:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8010f2:	89 fb                	mov    %edi,%ebx
  8010f4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8010fa:	89 de                	mov    %ebx,%esi
  8010fc:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8010ff:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801105:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80110b:	e8 67 1e 00 00       	call   802f77 <pageref>
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	83 f8 01             	cmp    $0x1,%eax
  801116:	7e 17                	jle    80112f <openfile_lookup+0x49>
  801118:	c1 e3 04             	shl    $0x4,%ebx
  80111b:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801121:	75 13                	jne    801136 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801123:	8b 45 10             	mov    0x10(%ebp),%eax
  801126:	89 30                	mov    %esi,(%eax)
	return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
  80112d:	eb 0c                	jmp    80113b <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  80112f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801134:	eb 05                	jmp    80113b <openfile_lookup+0x55>
  801136:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80113b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	53                   	push   %ebx
  801147:	83 ec 18             	sub    $0x18,%esp
  80114a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	ff 33                	pushl  (%ebx)
  801153:	ff 75 08             	pushl  0x8(%ebp)
  801156:	e8 8b ff ff ff       	call   8010e6 <openfile_lookup>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 14                	js     801176 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801162:	83 ec 08             	sub    $0x8,%esp
  801165:	ff 73 04             	pushl  0x4(%ebx)
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	ff 70 04             	pushl  0x4(%eax)
  80116e:	e8 f8 fa ff ff       	call   800c6b <file_set_size>
  801173:	83 c4 10             	add    $0x10,%esp
}
  801176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	53                   	push   %ebx
  80117f:	83 ec 18             	sub    $0x18,%esp
  801182:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	r = openfile_lookup(envid, req->req_fileid, &of);
  801185:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801188:	50                   	push   %eax
  801189:	ff 33                	pushl  (%ebx)
  80118b:	ff 75 08             	pushl  0x8(%ebp)
  80118e:	e8 53 ff ff ff       	call   8010e6 <openfile_lookup>
	if (r < 0)
  801193:	83 c4 10             	add    $0x10,%esp
		return r;
  801196:	89 c2                	mov    %eax,%edx
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	r = openfile_lookup(envid, req->req_fileid, &of);
	if (r < 0)
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 2b                	js     8011c7 <serve_read+0x4c>
		return r;

    r = file_read(of->o_file,
					ret->ret_buf,
					req->req_n,
					of->o_fd->fd_offset);
  80119c:	8b 45 f4             	mov    -0xc(%ebp),%eax
	// Lab 5: Your code here:
	r = openfile_lookup(envid, req->req_fileid, &of);
	if (r < 0)
		return r;

    r = file_read(of->o_file,
  80119f:	8b 50 0c             	mov    0xc(%eax),%edx
  8011a2:	ff 72 04             	pushl  0x4(%edx)
  8011a5:	ff 73 04             	pushl  0x4(%ebx)
  8011a8:	53                   	push   %ebx
  8011a9:	ff 70 04             	pushl  0x4(%eax)
  8011ac:	e8 15 fa ff ff       	call   800bc6 <file_read>
					ret->ret_buf,
					req->req_n,
					of->o_fd->fd_offset);
    if (r >= 0)
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	78 0d                	js     8011c5 <serve_read+0x4a>
        of->o_fd->fd_offset += r;
  8011b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011bb:	8b 52 0c             	mov    0xc(%edx),%edx
  8011be:	01 42 04             	add    %eax,0x4(%edx)
	return r;
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	eb 02                	jmp    8011c7 <serve_read+0x4c>
  8011c5:	89 c2                	mov    %eax,%edx
}
  8011c7:	89 d0                	mov    %edx,%eax
  8011c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	53                   	push   %ebx
  8011d2:	83 ec 18             	sub    $0x18,%esp
  8011d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
  8011d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011db:	50                   	push   %eax
  8011dc:	ff 33                	pushl  (%ebx)
  8011de:	ff 75 08             	pushl  0x8(%ebp)
  8011e1:	e8 00 ff ff ff       	call   8010e6 <openfile_lookup>
  8011e6:	83 c4 10             	add    $0x10,%esp
		return r;
  8011e9:	89 c2                	mov    %eax,%edx
	int r;

	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 2e                	js     80121d <serve_write+0x4f>
		return r;
	}
	
	nwrite = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
  8011ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f2:	8b 50 0c             	mov    0xc(%eax),%edx
  8011f5:	ff 72 04             	pushl  0x4(%edx)
  8011f8:	ff 73 04             	pushl  0x4(%ebx)
  8011fb:	83 c3 08             	add    $0x8,%ebx
  8011fe:	53                   	push   %ebx
  8011ff:	ff 70 04             	pushl  0x4(%eax)
  801202:	e8 45 fb ff ff       	call   800d4c <file_write>
	if (nwrite < 0) {
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	85 c0                	test   %eax,%eax
  80120c:	78 0d                	js     80121b <serve_write+0x4d>
		return nwrite;
	}
	o->o_fd->fd_offset += nwrite;
  80120e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801211:	8b 52 0c             	mov    0xc(%edx),%edx
  801214:	01 42 04             	add    %eax,0x4(%edx)
	return nwrite;
  801217:	89 c2                	mov    %eax,%edx
  801219:	eb 02                	jmp    80121d <serve_write+0x4f>
		return r;
	}
	
	nwrite = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
	if (nwrite < 0) {
		return nwrite;
  80121b:	89 c2                	mov    %eax,%edx
	}
	o->o_fd->fd_offset += nwrite;
	return nwrite;
}
  80121d:	89 d0                	mov    %edx,%eax
  80121f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801222:	c9                   	leave  
  801223:	c3                   	ret    

00801224 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	53                   	push   %ebx
  801228:	83 ec 18             	sub    $0x18,%esp
  80122b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80122e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	ff 33                	pushl  (%ebx)
  801234:	ff 75 08             	pushl  0x8(%ebp)
  801237:	e8 aa fe ff ff       	call   8010e6 <openfile_lookup>
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 3f                	js     801282 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  801243:	83 ec 08             	sub    $0x8,%esp
  801246:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801249:	ff 70 04             	pushl  0x4(%eax)
  80124c:	53                   	push   %ebx
  80124d:	e8 bc 0d 00 00       	call   80200e <strcpy>
	ret->ret_size = o->o_file->f_size;
  801252:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801255:	8b 50 04             	mov    0x4(%eax),%edx
  801258:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  80125e:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  801264:	8b 40 04             	mov    0x4(%eax),%eax
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801271:	0f 94 c0             	sete   %al
  801274:	0f b6 c0             	movzbl %al,%eax
  801277:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801282:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801285:	c9                   	leave  
  801286:	c3                   	ret    

00801287 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80128d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	8b 45 0c             	mov    0xc(%ebp),%eax
  801294:	ff 30                	pushl  (%eax)
  801296:	ff 75 08             	pushl  0x8(%ebp)
  801299:	e8 48 fe ff ff       	call   8010e6 <openfile_lookup>
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 16                	js     8012bb <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  8012a5:	83 ec 0c             	sub    $0xc,%esp
  8012a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ab:	ff 70 04             	pushl  0x4(%eax)
  8012ae:	e8 3f fb ff ff       	call   800df2 <file_flush>
	return 0;
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	53                   	push   %ebx
  8012c1:	81 ec 18 04 00 00    	sub    $0x418,%esp
  8012c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  8012ca:	68 00 04 00 00       	push   $0x400
  8012cf:	53                   	push   %ebx
  8012d0:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8012d6:	50                   	push   %eax
  8012d7:	e8 c4 0e 00 00       	call   8021a0 <memmove>
	path[MAXPATHLEN-1] = 0;
  8012dc:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  8012e0:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 62 fd ff ff       	call   801050 <openfile_alloc>
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	0f 88 f0 00 00 00    	js     8013e9 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  8012f9:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801300:	74 33                	je     801335 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801312:	50                   	push   %eax
  801313:	e8 77 fb ff ff       	call   800e8f <file_create>
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	79 37                	jns    801356 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80131f:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801326:	0f 85 bd 00 00 00    	jne    8013e9 <serve_open+0x12c>
  80132c:	83 f8 f3             	cmp    $0xfffffff3,%eax
  80132f:	0f 85 b4 00 00 00    	jne    8013e9 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	e8 61 f8 ff ff       	call   800bac <file_open>
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	85 c0                	test   %eax,%eax
  801350:	0f 88 93 00 00 00    	js     8013e9 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  801356:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  80135d:	74 17                	je     801376 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  80135f:	83 ec 08             	sub    $0x8,%esp
  801362:	6a 00                	push   $0x0
  801364:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  80136a:	e8 fc f8 ff ff       	call   800c6b <file_set_size>
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	78 73                	js     8013e9 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801386:	50                   	push   %eax
  801387:	e8 20 f8 ff ff       	call   800bac <file_open>
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 56                	js     8013e9 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  801393:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801399:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80139f:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8013a2:	8b 50 0c             	mov    0xc(%eax),%edx
  8013a5:	8b 08                	mov    (%eax),%ecx
  8013a7:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8013aa:	8b 48 0c             	mov    0xc(%eax),%ecx
  8013ad:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8013b3:	83 e2 03             	and    $0x3,%edx
  8013b6:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8013b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013bc:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8013c2:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8013c4:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8013ca:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8013d0:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  8013d3:	8b 50 0c             	mov    0xc(%eax),%edx
  8013d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8013d9:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  8013db:	8b 45 14             	mov    0x14(%ebp),%eax
  8013de:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  8013e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8013f6:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8013f9:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  8013fc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801403:	83 ec 04             	sub    $0x4,%esp
  801406:	53                   	push   %ebx
  801407:	ff 35 44 50 80 00    	pushl  0x805044
  80140d:	56                   	push   %esi
  80140e:	e8 5a 12 00 00       	call   80266d <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  80141a:	75 15                	jne    801431 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  80141c:	83 ec 08             	sub    $0x8,%esp
  80141f:	ff 75 f4             	pushl  -0xc(%ebp)
  801422:	68 cc 39 80 00       	push   $0x8039cc
  801427:	e8 de 05 00 00       	call   801a0a <cprintf>
				whom);
			continue; // just leave it hanging...
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	eb cb                	jmp    8013fc <serve+0xe>
		}

		pg = NULL;
  801431:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801438:	83 f8 01             	cmp    $0x1,%eax
  80143b:	75 18                	jne    801455 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  80143d:	53                   	push   %ebx
  80143e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	ff 35 44 50 80 00    	pushl  0x805044
  801448:	ff 75 f4             	pushl  -0xc(%ebp)
  80144b:	e8 6d fe ff ff       	call   8012bd <serve_open>
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	eb 3c                	jmp    801491 <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  801455:	83 f8 08             	cmp    $0x8,%eax
  801458:	77 1e                	ja     801478 <serve+0x8a>
  80145a:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801461:	85 d2                	test   %edx,%edx
  801463:	74 13                	je     801478 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  801465:	83 ec 08             	sub    $0x8,%esp
  801468:	ff 35 44 50 80 00    	pushl  0x805044
  80146e:	ff 75 f4             	pushl  -0xc(%ebp)
  801471:	ff d2                	call   *%edx
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	eb 19                	jmp    801491 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	ff 75 f4             	pushl  -0xc(%ebp)
  80147e:	50                   	push   %eax
  80147f:	68 fc 39 80 00       	push   $0x8039fc
  801484:	e8 81 05 00 00       	call   801a0a <cprintf>
  801489:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  80148c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801491:	ff 75 f0             	pushl  -0x10(%ebp)
  801494:	ff 75 ec             	pushl  -0x14(%ebp)
  801497:	50                   	push   %eax
  801498:	ff 75 f4             	pushl  -0xc(%ebp)
  80149b:	e8 3f 12 00 00       	call   8026df <ipc_send>
		sys_page_unmap(0, fsreq);
  8014a0:	83 c4 08             	add    $0x8,%esp
  8014a3:	ff 35 44 50 80 00    	pushl  0x805044
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 e6 0f 00 00       	call   802496 <sys_page_unmap>
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	e9 44 ff ff ff       	jmp    8013fc <serve+0xe>

008014b8 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  8014be:	c7 05 60 90 80 00 1f 	movl   $0x803a1f,0x809060
  8014c5:	3a 80 00 
	cprintf("FS is running\n");
  8014c8:	68 22 3a 80 00       	push   $0x803a22
  8014cd:	e8 38 05 00 00       	call   801a0a <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  8014d2:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  8014d7:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  8014dc:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  8014de:	c7 04 24 31 3a 80 00 	movl   $0x803a31,(%esp)
  8014e5:	e8 20 05 00 00       	call   801a0a <cprintf>

	serve_init();
  8014ea:	e8 35 fb ff ff       	call   801024 <serve_init>
	fs_init();
  8014ef:	e8 d5 f3 ff ff       	call   8008c9 <fs_init>
        fs_test();
  8014f4:	e8 05 00 00 00       	call   8014fe <fs_test>
	serve();
  8014f9:	e8 f0 fe ff ff       	call   8013ee <serve>

008014fe <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	53                   	push   %ebx
  801502:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801505:	6a 07                	push   $0x7
  801507:	68 00 10 00 00       	push   $0x1000
  80150c:	6a 00                	push   $0x0
  80150e:	e8 fe 0e 00 00       	call   802411 <sys_page_alloc>
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	79 12                	jns    80152c <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80151a:	50                   	push   %eax
  80151b:	68 40 3a 80 00       	push   $0x803a40
  801520:	6a 12                	push   $0x12
  801522:	68 53 3a 80 00       	push   $0x803a53
  801527:	e8 05 04 00 00       	call   801931 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	68 00 10 00 00       	push   $0x1000
  801534:	ff 35 04 a0 80 00    	pushl  0x80a004
  80153a:	68 00 10 00 00       	push   $0x1000
  80153f:	e8 5c 0c 00 00       	call   8021a0 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801544:	e8 94 f1 ff ff       	call   8006dd <alloc_block>
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	85 c0                	test   %eax,%eax
  80154e:	79 12                	jns    801562 <fs_test+0x64>
		panic("alloc_block: %e", r);
  801550:	50                   	push   %eax
  801551:	68 5d 3a 80 00       	push   $0x803a5d
  801556:	6a 17                	push   $0x17
  801558:	68 53 3a 80 00       	push   $0x803a53
  80155d:	e8 cf 03 00 00       	call   801931 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801562:	8d 50 1f             	lea    0x1f(%eax),%edx
  801565:	85 c0                	test   %eax,%eax
  801567:	0f 49 d0             	cmovns %eax,%edx
  80156a:	c1 fa 05             	sar    $0x5,%edx
  80156d:	89 c3                	mov    %eax,%ebx
  80156f:	c1 fb 1f             	sar    $0x1f,%ebx
  801572:	c1 eb 1b             	shr    $0x1b,%ebx
  801575:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  801578:	83 e1 1f             	and    $0x1f,%ecx
  80157b:	29 d9                	sub    %ebx,%ecx
  80157d:	b8 01 00 00 00       	mov    $0x1,%eax
  801582:	d3 e0                	shl    %cl,%eax
  801584:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  80158b:	75 16                	jne    8015a3 <fs_test+0xa5>
  80158d:	68 6d 3a 80 00       	push   $0x803a6d
  801592:	68 7d 37 80 00       	push   $0x80377d
  801597:	6a 19                	push   $0x19
  801599:	68 53 3a 80 00       	push   $0x803a53
  80159e:	e8 8e 03 00 00       	call   801931 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8015a3:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8015a9:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8015ac:	74 16                	je     8015c4 <fs_test+0xc6>
  8015ae:	68 e8 3b 80 00       	push   $0x803be8
  8015b3:	68 7d 37 80 00       	push   $0x80377d
  8015b8:	6a 1b                	push   $0x1b
  8015ba:	68 53 3a 80 00       	push   $0x803a53
  8015bf:	e8 6d 03 00 00       	call   801931 <_panic>
	cprintf("alloc_block is good\n");
  8015c4:	83 ec 0c             	sub    $0xc,%esp
  8015c7:	68 88 3a 80 00       	push   $0x803a88
  8015cc:	e8 39 04 00 00       	call   801a0a <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  8015d1:	83 c4 08             	add    $0x8,%esp
  8015d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	68 9d 3a 80 00       	push   $0x803a9d
  8015dd:	e8 ca f5 ff ff       	call   800bac <file_open>
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8015e8:	74 1b                	je     801605 <fs_test+0x107>
  8015ea:	89 c2                	mov    %eax,%edx
  8015ec:	c1 ea 1f             	shr    $0x1f,%edx
  8015ef:	84 d2                	test   %dl,%dl
  8015f1:	74 12                	je     801605 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  8015f3:	50                   	push   %eax
  8015f4:	68 a8 3a 80 00       	push   $0x803aa8
  8015f9:	6a 1f                	push   $0x1f
  8015fb:	68 53 3a 80 00       	push   $0x803a53
  801600:	e8 2c 03 00 00       	call   801931 <_panic>
	else if (r == 0)
  801605:	85 c0                	test   %eax,%eax
  801607:	75 14                	jne    80161d <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801609:	83 ec 04             	sub    $0x4,%esp
  80160c:	68 08 3c 80 00       	push   $0x803c08
  801611:	6a 21                	push   $0x21
  801613:	68 53 3a 80 00       	push   $0x803a53
  801618:	e8 14 03 00 00       	call   801931 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	68 c1 3a 80 00       	push   $0x803ac1
  801629:	e8 7e f5 ff ff       	call   800bac <file_open>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	79 12                	jns    801647 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801635:	50                   	push   %eax
  801636:	68 ca 3a 80 00       	push   $0x803aca
  80163b:	6a 23                	push   $0x23
  80163d:	68 53 3a 80 00       	push   $0x803a53
  801642:	e8 ea 02 00 00       	call   801931 <_panic>
	cprintf("file_open is good\n");
  801647:	83 ec 0c             	sub    $0xc,%esp
  80164a:	68 e1 3a 80 00       	push   $0x803ae1
  80164f:	e8 b6 03 00 00       	call   801a0a <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801654:	83 c4 0c             	add    $0xc,%esp
  801657:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165a:	50                   	push   %eax
  80165b:	6a 00                	push   $0x0
  80165d:	ff 75 f4             	pushl  -0xc(%ebp)
  801660:	e8 c3 f2 ff ff       	call   800928 <file_get_block>
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	85 c0                	test   %eax,%eax
  80166a:	79 12                	jns    80167e <fs_test+0x180>
		panic("file_get_block: %e", r);
  80166c:	50                   	push   %eax
  80166d:	68 f4 3a 80 00       	push   $0x803af4
  801672:	6a 27                	push   $0x27
  801674:	68 53 3a 80 00       	push   $0x803a53
  801679:	e8 b3 02 00 00       	call   801931 <_panic>
	if (strcmp(blk, msg) != 0)
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	68 28 3c 80 00       	push   $0x803c28
  801686:	ff 75 f0             	pushl  -0x10(%ebp)
  801689:	e8 2a 0a 00 00       	call   8020b8 <strcmp>
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	85 c0                	test   %eax,%eax
  801693:	74 14                	je     8016a9 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  801695:	83 ec 04             	sub    $0x4,%esp
  801698:	68 50 3c 80 00       	push   $0x803c50
  80169d:	6a 29                	push   $0x29
  80169f:	68 53 3a 80 00       	push   $0x803a53
  8016a4:	e8 88 02 00 00       	call   801931 <_panic>
	cprintf("file_get_block is good\n");
  8016a9:	83 ec 0c             	sub    $0xc,%esp
  8016ac:	68 07 3b 80 00       	push   $0x803b07
  8016b1:	e8 54 03 00 00       	call   801a0a <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8016b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b9:	0f b6 10             	movzbl (%eax),%edx
  8016bc:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8016be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c1:	c1 e8 0c             	shr    $0xc,%eax
  8016c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	a8 40                	test   $0x40,%al
  8016d0:	75 16                	jne    8016e8 <fs_test+0x1ea>
  8016d2:	68 20 3b 80 00       	push   $0x803b20
  8016d7:	68 7d 37 80 00       	push   $0x80377d
  8016dc:	6a 2d                	push   $0x2d
  8016de:	68 53 3a 80 00       	push   $0x803a53
  8016e3:	e8 49 02 00 00       	call   801931 <_panic>
	file_flush(f);
  8016e8:	83 ec 0c             	sub    $0xc,%esp
  8016eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ee:	e8 ff f6 ff ff       	call   800df2 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8016f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f6:	c1 e8 0c             	shr    $0xc,%eax
  8016f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	a8 40                	test   $0x40,%al
  801705:	74 16                	je     80171d <fs_test+0x21f>
  801707:	68 1f 3b 80 00       	push   $0x803b1f
  80170c:	68 7d 37 80 00       	push   $0x80377d
  801711:	6a 2f                	push   $0x2f
  801713:	68 53 3a 80 00       	push   $0x803a53
  801718:	e8 14 02 00 00       	call   801931 <_panic>
	cprintf("file_flush is good\n");
  80171d:	83 ec 0c             	sub    $0xc,%esp
  801720:	68 3b 3b 80 00       	push   $0x803b3b
  801725:	e8 e0 02 00 00       	call   801a0a <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80172a:	83 c4 08             	add    $0x8,%esp
  80172d:	6a 00                	push   $0x0
  80172f:	ff 75 f4             	pushl  -0xc(%ebp)
  801732:	e8 34 f5 ff ff       	call   800c6b <file_set_size>
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	85 c0                	test   %eax,%eax
  80173c:	79 12                	jns    801750 <fs_test+0x252>
		panic("file_set_size: %e", r);
  80173e:	50                   	push   %eax
  80173f:	68 4f 3b 80 00       	push   $0x803b4f
  801744:	6a 33                	push   $0x33
  801746:	68 53 3a 80 00       	push   $0x803a53
  80174b:	e8 e1 01 00 00       	call   801931 <_panic>
	assert(f->f_direct[0] == 0);
  801750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801753:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80175a:	74 16                	je     801772 <fs_test+0x274>
  80175c:	68 61 3b 80 00       	push   $0x803b61
  801761:	68 7d 37 80 00       	push   $0x80377d
  801766:	6a 34                	push   $0x34
  801768:	68 53 3a 80 00       	push   $0x803a53
  80176d:	e8 bf 01 00 00       	call   801931 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801772:	c1 e8 0c             	shr    $0xc,%eax
  801775:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80177c:	a8 40                	test   $0x40,%al
  80177e:	74 16                	je     801796 <fs_test+0x298>
  801780:	68 75 3b 80 00       	push   $0x803b75
  801785:	68 7d 37 80 00       	push   $0x80377d
  80178a:	6a 35                	push   $0x35
  80178c:	68 53 3a 80 00       	push   $0x803a53
  801791:	e8 9b 01 00 00       	call   801931 <_panic>
	cprintf("file_truncate is good\n");
  801796:	83 ec 0c             	sub    $0xc,%esp
  801799:	68 8f 3b 80 00       	push   $0x803b8f
  80179e:	e8 67 02 00 00       	call   801a0a <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8017a3:	c7 04 24 28 3c 80 00 	movl   $0x803c28,(%esp)
  8017aa:	e8 26 08 00 00       	call   801fd5 <strlen>
  8017af:	83 c4 08             	add    $0x8,%esp
  8017b2:	50                   	push   %eax
  8017b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b6:	e8 b0 f4 ff ff       	call   800c6b <file_set_size>
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	79 12                	jns    8017d4 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  8017c2:	50                   	push   %eax
  8017c3:	68 a6 3b 80 00       	push   $0x803ba6
  8017c8:	6a 39                	push   $0x39
  8017ca:	68 53 3a 80 00       	push   $0x803a53
  8017cf:	e8 5d 01 00 00       	call   801931 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8017d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d7:	89 c2                	mov    %eax,%edx
  8017d9:	c1 ea 0c             	shr    $0xc,%edx
  8017dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017e3:	f6 c2 40             	test   $0x40,%dl
  8017e6:	74 16                	je     8017fe <fs_test+0x300>
  8017e8:	68 75 3b 80 00       	push   $0x803b75
  8017ed:	68 7d 37 80 00       	push   $0x80377d
  8017f2:	6a 3a                	push   $0x3a
  8017f4:	68 53 3a 80 00       	push   $0x803a53
  8017f9:	e8 33 01 00 00       	call   801931 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017fe:	83 ec 04             	sub    $0x4,%esp
  801801:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801804:	52                   	push   %edx
  801805:	6a 00                	push   $0x0
  801807:	50                   	push   %eax
  801808:	e8 1b f1 ff ff       	call   800928 <file_get_block>
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	79 12                	jns    801826 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801814:	50                   	push   %eax
  801815:	68 ba 3b 80 00       	push   $0x803bba
  80181a:	6a 3c                	push   $0x3c
  80181c:	68 53 3a 80 00       	push   $0x803a53
  801821:	e8 0b 01 00 00       	call   801931 <_panic>
	strcpy(blk, msg);
  801826:	83 ec 08             	sub    $0x8,%esp
  801829:	68 28 3c 80 00       	push   $0x803c28
  80182e:	ff 75 f0             	pushl  -0x10(%ebp)
  801831:	e8 d8 07 00 00       	call   80200e <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801839:	c1 e8 0c             	shr    $0xc,%eax
  80183c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	a8 40                	test   $0x40,%al
  801848:	75 16                	jne    801860 <fs_test+0x362>
  80184a:	68 20 3b 80 00       	push   $0x803b20
  80184f:	68 7d 37 80 00       	push   $0x80377d
  801854:	6a 3e                	push   $0x3e
  801856:	68 53 3a 80 00       	push   $0x803a53
  80185b:	e8 d1 00 00 00       	call   801931 <_panic>
	file_flush(f);
  801860:	83 ec 0c             	sub    $0xc,%esp
  801863:	ff 75 f4             	pushl  -0xc(%ebp)
  801866:	e8 87 f5 ff ff       	call   800df2 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80186b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186e:	c1 e8 0c             	shr    $0xc,%eax
  801871:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	a8 40                	test   $0x40,%al
  80187d:	74 16                	je     801895 <fs_test+0x397>
  80187f:	68 1f 3b 80 00       	push   $0x803b1f
  801884:	68 7d 37 80 00       	push   $0x80377d
  801889:	6a 40                	push   $0x40
  80188b:	68 53 3a 80 00       	push   $0x803a53
  801890:	e8 9c 00 00 00       	call   801931 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801895:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801898:	c1 e8 0c             	shr    $0xc,%eax
  80189b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018a2:	a8 40                	test   $0x40,%al
  8018a4:	74 16                	je     8018bc <fs_test+0x3be>
  8018a6:	68 75 3b 80 00       	push   $0x803b75
  8018ab:	68 7d 37 80 00       	push   $0x80377d
  8018b0:	6a 41                	push   $0x41
  8018b2:	68 53 3a 80 00       	push   $0x803a53
  8018b7:	e8 75 00 00 00       	call   801931 <_panic>
	cprintf("file rewrite is good\n");
  8018bc:	83 ec 0c             	sub    $0xc,%esp
  8018bf:	68 cf 3b 80 00       	push   $0x803bcf
  8018c4:	e8 41 01 00 00       	call   801a0a <cprintf>
}
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018d9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8018dc:	e8 f2 0a 00 00       	call   8023d3 <sys_getenvid>
  8018e1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018e6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018e9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018ee:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8018f3:	85 db                	test   %ebx,%ebx
  8018f5:	7e 07                	jle    8018fe <libmain+0x2d>
		binaryname = argv[0];
  8018f7:	8b 06                	mov    (%esi),%eax
  8018f9:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	56                   	push   %esi
  801902:	53                   	push   %ebx
  801903:	e8 b0 fb ff ff       	call   8014b8 <umain>

	// exit gracefully
	exit();
  801908:	e8 0a 00 00 00       	call   801917 <exit>
}
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801913:	5b                   	pop    %ebx
  801914:	5e                   	pop    %esi
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80191d:	e8 15 10 00 00       	call   802937 <close_all>
	sys_env_destroy(0);
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	6a 00                	push   $0x0
  801927:	e8 66 0a 00 00       	call   802392 <sys_env_destroy>
}
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	c9                   	leave  
  801930:	c3                   	ret    

00801931 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	56                   	push   %esi
  801935:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801936:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801939:	8b 35 60 90 80 00    	mov    0x809060,%esi
  80193f:	e8 8f 0a 00 00       	call   8023d3 <sys_getenvid>
  801944:	83 ec 0c             	sub    $0xc,%esp
  801947:	ff 75 0c             	pushl  0xc(%ebp)
  80194a:	ff 75 08             	pushl  0x8(%ebp)
  80194d:	56                   	push   %esi
  80194e:	50                   	push   %eax
  80194f:	68 80 3c 80 00       	push   $0x803c80
  801954:	e8 b1 00 00 00       	call   801a0a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801959:	83 c4 18             	add    $0x18,%esp
  80195c:	53                   	push   %ebx
  80195d:	ff 75 10             	pushl  0x10(%ebp)
  801960:	e8 54 00 00 00       	call   8019b9 <vcprintf>
	cprintf("\n");
  801965:	c7 04 24 91 38 80 00 	movl   $0x803891,(%esp)
  80196c:	e8 99 00 00 00       	call   801a0a <cprintf>
  801971:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801974:	cc                   	int3   
  801975:	eb fd                	jmp    801974 <_panic+0x43>

00801977 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	53                   	push   %ebx
  80197b:	83 ec 04             	sub    $0x4,%esp
  80197e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801981:	8b 13                	mov    (%ebx),%edx
  801983:	8d 42 01             	lea    0x1(%edx),%eax
  801986:	89 03                	mov    %eax,(%ebx)
  801988:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80198f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801994:	75 1a                	jne    8019b0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	68 ff 00 00 00       	push   $0xff
  80199e:	8d 43 08             	lea    0x8(%ebx),%eax
  8019a1:	50                   	push   %eax
  8019a2:	e8 ae 09 00 00       	call   802355 <sys_cputs>
		b->idx = 0;
  8019a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019ad:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8019b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8019b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8019c2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019c9:	00 00 00 
	b.cnt = 0;
  8019cc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8019d3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8019d6:	ff 75 0c             	pushl  0xc(%ebp)
  8019d9:	ff 75 08             	pushl  0x8(%ebp)
  8019dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8019e2:	50                   	push   %eax
  8019e3:	68 77 19 80 00       	push   $0x801977
  8019e8:	e8 1a 01 00 00       	call   801b07 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8019ed:	83 c4 08             	add    $0x8,%esp
  8019f0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8019f6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8019fc:	50                   	push   %eax
  8019fd:	e8 53 09 00 00       	call   802355 <sys_cputs>

	return b.cnt;
}
  801a02:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a10:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a13:	50                   	push   %eax
  801a14:	ff 75 08             	pushl  0x8(%ebp)
  801a17:	e8 9d ff ff ff       	call   8019b9 <vcprintf>
	va_end(ap);

	return cnt;
}
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	57                   	push   %edi
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
  801a24:	83 ec 1c             	sub    $0x1c,%esp
  801a27:	89 c7                	mov    %eax,%edi
  801a29:	89 d6                	mov    %edx,%esi
  801a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a31:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a34:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801a37:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a3f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801a42:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801a45:	39 d3                	cmp    %edx,%ebx
  801a47:	72 05                	jb     801a4e <printnum+0x30>
  801a49:	39 45 10             	cmp    %eax,0x10(%ebp)
  801a4c:	77 45                	ja     801a93 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	ff 75 18             	pushl  0x18(%ebp)
  801a54:	8b 45 14             	mov    0x14(%ebp),%eax
  801a57:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801a5a:	53                   	push   %ebx
  801a5b:	ff 75 10             	pushl  0x10(%ebp)
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a64:	ff 75 e0             	pushl  -0x20(%ebp)
  801a67:	ff 75 dc             	pushl  -0x24(%ebp)
  801a6a:	ff 75 d8             	pushl  -0x28(%ebp)
  801a6d:	e8 2e 1a 00 00       	call   8034a0 <__udivdi3>
  801a72:	83 c4 18             	add    $0x18,%esp
  801a75:	52                   	push   %edx
  801a76:	50                   	push   %eax
  801a77:	89 f2                	mov    %esi,%edx
  801a79:	89 f8                	mov    %edi,%eax
  801a7b:	e8 9e ff ff ff       	call   801a1e <printnum>
  801a80:	83 c4 20             	add    $0x20,%esp
  801a83:	eb 18                	jmp    801a9d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801a85:	83 ec 08             	sub    $0x8,%esp
  801a88:	56                   	push   %esi
  801a89:	ff 75 18             	pushl  0x18(%ebp)
  801a8c:	ff d7                	call   *%edi
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	eb 03                	jmp    801a96 <printnum+0x78>
  801a93:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801a96:	83 eb 01             	sub    $0x1,%ebx
  801a99:	85 db                	test   %ebx,%ebx
  801a9b:	7f e8                	jg     801a85 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801a9d:	83 ec 08             	sub    $0x8,%esp
  801aa0:	56                   	push   %esi
  801aa1:	83 ec 04             	sub    $0x4,%esp
  801aa4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aa7:	ff 75 e0             	pushl  -0x20(%ebp)
  801aaa:	ff 75 dc             	pushl  -0x24(%ebp)
  801aad:	ff 75 d8             	pushl  -0x28(%ebp)
  801ab0:	e8 1b 1b 00 00       	call   8035d0 <__umoddi3>
  801ab5:	83 c4 14             	add    $0x14,%esp
  801ab8:	0f be 80 a3 3c 80 00 	movsbl 0x803ca3(%eax),%eax
  801abf:	50                   	push   %eax
  801ac0:	ff d7                	call   *%edi
}
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac8:	5b                   	pop    %ebx
  801ac9:	5e                   	pop    %esi
  801aca:	5f                   	pop    %edi
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    

00801acd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801ad3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801ad7:	8b 10                	mov    (%eax),%edx
  801ad9:	3b 50 04             	cmp    0x4(%eax),%edx
  801adc:	73 0a                	jae    801ae8 <sprintputch+0x1b>
		*b->buf++ = ch;
  801ade:	8d 4a 01             	lea    0x1(%edx),%ecx
  801ae1:	89 08                	mov    %ecx,(%eax)
  801ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae6:	88 02                	mov    %al,(%edx)
}
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801af0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801af3:	50                   	push   %eax
  801af4:	ff 75 10             	pushl  0x10(%ebp)
  801af7:	ff 75 0c             	pushl  0xc(%ebp)
  801afa:	ff 75 08             	pushl  0x8(%ebp)
  801afd:	e8 05 00 00 00       	call   801b07 <vprintfmt>
	va_end(ap);
}
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	57                   	push   %edi
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	83 ec 2c             	sub    $0x2c,%esp
  801b10:	8b 75 08             	mov    0x8(%ebp),%esi
  801b13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b16:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b19:	eb 12                	jmp    801b2d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	0f 84 42 04 00 00    	je     801f65 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801b23:	83 ec 08             	sub    $0x8,%esp
  801b26:	53                   	push   %ebx
  801b27:	50                   	push   %eax
  801b28:	ff d6                	call   *%esi
  801b2a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801b2d:	83 c7 01             	add    $0x1,%edi
  801b30:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801b34:	83 f8 25             	cmp    $0x25,%eax
  801b37:	75 e2                	jne    801b1b <vprintfmt+0x14>
  801b39:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801b3d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801b44:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801b4b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801b52:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b57:	eb 07                	jmp    801b60 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b59:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801b5c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b60:	8d 47 01             	lea    0x1(%edi),%eax
  801b63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b66:	0f b6 07             	movzbl (%edi),%eax
  801b69:	0f b6 d0             	movzbl %al,%edx
  801b6c:	83 e8 23             	sub    $0x23,%eax
  801b6f:	3c 55                	cmp    $0x55,%al
  801b71:	0f 87 d3 03 00 00    	ja     801f4a <vprintfmt+0x443>
  801b77:	0f b6 c0             	movzbl %al,%eax
  801b7a:	ff 24 85 e0 3d 80 00 	jmp    *0x803de0(,%eax,4)
  801b81:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801b84:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801b88:	eb d6                	jmp    801b60 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b8a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b92:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801b95:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801b98:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801b9c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801b9f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801ba2:	83 f9 09             	cmp    $0x9,%ecx
  801ba5:	77 3f                	ja     801be6 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801ba7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801baa:	eb e9                	jmp    801b95 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801bac:	8b 45 14             	mov    0x14(%ebp),%eax
  801baf:	8b 00                	mov    (%eax),%eax
  801bb1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801bb4:	8b 45 14             	mov    0x14(%ebp),%eax
  801bb7:	8d 40 04             	lea    0x4(%eax),%eax
  801bba:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bbd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801bc0:	eb 2a                	jmp    801bec <vprintfmt+0xe5>
  801bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcc:	0f 49 d0             	cmovns %eax,%edx
  801bcf:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bd2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bd5:	eb 89                	jmp    801b60 <vprintfmt+0x59>
  801bd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801bda:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801be1:	e9 7a ff ff ff       	jmp    801b60 <vprintfmt+0x59>
  801be6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801be9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801bec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801bf0:	0f 89 6a ff ff ff    	jns    801b60 <vprintfmt+0x59>
				width = precision, precision = -1;
  801bf6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801bf9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bfc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c03:	e9 58 ff ff ff       	jmp    801b60 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c08:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c0b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801c0e:	e9 4d ff ff ff       	jmp    801b60 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c13:	8b 45 14             	mov    0x14(%ebp),%eax
  801c16:	8d 78 04             	lea    0x4(%eax),%edi
  801c19:	83 ec 08             	sub    $0x8,%esp
  801c1c:	53                   	push   %ebx
  801c1d:	ff 30                	pushl  (%eax)
  801c1f:	ff d6                	call   *%esi
			break;
  801c21:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c24:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c27:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801c2a:	e9 fe fe ff ff       	jmp    801b2d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801c2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801c32:	8d 78 04             	lea    0x4(%eax),%edi
  801c35:	8b 00                	mov    (%eax),%eax
  801c37:	99                   	cltd   
  801c38:	31 d0                	xor    %edx,%eax
  801c3a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801c3c:	83 f8 0f             	cmp    $0xf,%eax
  801c3f:	7f 0b                	jg     801c4c <vprintfmt+0x145>
  801c41:	8b 14 85 40 3f 80 00 	mov    0x803f40(,%eax,4),%edx
  801c48:	85 d2                	test   %edx,%edx
  801c4a:	75 1b                	jne    801c67 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801c4c:	50                   	push   %eax
  801c4d:	68 bb 3c 80 00       	push   $0x803cbb
  801c52:	53                   	push   %ebx
  801c53:	56                   	push   %esi
  801c54:	e8 91 fe ff ff       	call   801aea <printfmt>
  801c59:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801c5c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801c62:	e9 c6 fe ff ff       	jmp    801b2d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801c67:	52                   	push   %edx
  801c68:	68 8f 37 80 00       	push   $0x80378f
  801c6d:	53                   	push   %ebx
  801c6e:	56                   	push   %esi
  801c6f:	e8 76 fe ff ff       	call   801aea <printfmt>
  801c74:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801c77:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c7d:	e9 ab fe ff ff       	jmp    801b2d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801c82:	8b 45 14             	mov    0x14(%ebp),%eax
  801c85:	83 c0 04             	add    $0x4,%eax
  801c88:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801c8b:	8b 45 14             	mov    0x14(%ebp),%eax
  801c8e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801c90:	85 ff                	test   %edi,%edi
  801c92:	b8 b4 3c 80 00       	mov    $0x803cb4,%eax
  801c97:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801c9a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c9e:	0f 8e 94 00 00 00    	jle    801d38 <vprintfmt+0x231>
  801ca4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801ca8:	0f 84 98 00 00 00    	je     801d46 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801cae:	83 ec 08             	sub    $0x8,%esp
  801cb1:	ff 75 d0             	pushl  -0x30(%ebp)
  801cb4:	57                   	push   %edi
  801cb5:	e8 33 03 00 00       	call   801fed <strnlen>
  801cba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801cbd:	29 c1                	sub    %eax,%ecx
  801cbf:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801cc2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801cc5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801cc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ccc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801ccf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801cd1:	eb 0f                	jmp    801ce2 <vprintfmt+0x1db>
					putch(padc, putdat);
  801cd3:	83 ec 08             	sub    $0x8,%esp
  801cd6:	53                   	push   %ebx
  801cd7:	ff 75 e0             	pushl  -0x20(%ebp)
  801cda:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801cdc:	83 ef 01             	sub    $0x1,%edi
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	85 ff                	test   %edi,%edi
  801ce4:	7f ed                	jg     801cd3 <vprintfmt+0x1cc>
  801ce6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801ce9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801cec:	85 c9                	test   %ecx,%ecx
  801cee:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf3:	0f 49 c1             	cmovns %ecx,%eax
  801cf6:	29 c1                	sub    %eax,%ecx
  801cf8:	89 75 08             	mov    %esi,0x8(%ebp)
  801cfb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801cfe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d01:	89 cb                	mov    %ecx,%ebx
  801d03:	eb 4d                	jmp    801d52 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d05:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d09:	74 1b                	je     801d26 <vprintfmt+0x21f>
  801d0b:	0f be c0             	movsbl %al,%eax
  801d0e:	83 e8 20             	sub    $0x20,%eax
  801d11:	83 f8 5e             	cmp    $0x5e,%eax
  801d14:	76 10                	jbe    801d26 <vprintfmt+0x21f>
					putch('?', putdat);
  801d16:	83 ec 08             	sub    $0x8,%esp
  801d19:	ff 75 0c             	pushl  0xc(%ebp)
  801d1c:	6a 3f                	push   $0x3f
  801d1e:	ff 55 08             	call   *0x8(%ebp)
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	eb 0d                	jmp    801d33 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801d26:	83 ec 08             	sub    $0x8,%esp
  801d29:	ff 75 0c             	pushl  0xc(%ebp)
  801d2c:	52                   	push   %edx
  801d2d:	ff 55 08             	call   *0x8(%ebp)
  801d30:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801d33:	83 eb 01             	sub    $0x1,%ebx
  801d36:	eb 1a                	jmp    801d52 <vprintfmt+0x24b>
  801d38:	89 75 08             	mov    %esi,0x8(%ebp)
  801d3b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d3e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d41:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d44:	eb 0c                	jmp    801d52 <vprintfmt+0x24b>
  801d46:	89 75 08             	mov    %esi,0x8(%ebp)
  801d49:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d4c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d4f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d52:	83 c7 01             	add    $0x1,%edi
  801d55:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d59:	0f be d0             	movsbl %al,%edx
  801d5c:	85 d2                	test   %edx,%edx
  801d5e:	74 23                	je     801d83 <vprintfmt+0x27c>
  801d60:	85 f6                	test   %esi,%esi
  801d62:	78 a1                	js     801d05 <vprintfmt+0x1fe>
  801d64:	83 ee 01             	sub    $0x1,%esi
  801d67:	79 9c                	jns    801d05 <vprintfmt+0x1fe>
  801d69:	89 df                	mov    %ebx,%edi
  801d6b:	8b 75 08             	mov    0x8(%ebp),%esi
  801d6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d71:	eb 18                	jmp    801d8b <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801d73:	83 ec 08             	sub    $0x8,%esp
  801d76:	53                   	push   %ebx
  801d77:	6a 20                	push   $0x20
  801d79:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801d7b:	83 ef 01             	sub    $0x1,%edi
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	eb 08                	jmp    801d8b <vprintfmt+0x284>
  801d83:	89 df                	mov    %ebx,%edi
  801d85:	8b 75 08             	mov    0x8(%ebp),%esi
  801d88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d8b:	85 ff                	test   %edi,%edi
  801d8d:	7f e4                	jg     801d73 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d8f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d92:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d98:	e9 90 fd ff ff       	jmp    801b2d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801d9d:	83 f9 01             	cmp    $0x1,%ecx
  801da0:	7e 19                	jle    801dbb <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801da2:	8b 45 14             	mov    0x14(%ebp),%eax
  801da5:	8b 50 04             	mov    0x4(%eax),%edx
  801da8:	8b 00                	mov    (%eax),%eax
  801daa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dad:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801db0:	8b 45 14             	mov    0x14(%ebp),%eax
  801db3:	8d 40 08             	lea    0x8(%eax),%eax
  801db6:	89 45 14             	mov    %eax,0x14(%ebp)
  801db9:	eb 38                	jmp    801df3 <vprintfmt+0x2ec>
	else if (lflag)
  801dbb:	85 c9                	test   %ecx,%ecx
  801dbd:	74 1b                	je     801dda <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801dbf:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc2:	8b 00                	mov    (%eax),%eax
  801dc4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dc7:	89 c1                	mov    %eax,%ecx
  801dc9:	c1 f9 1f             	sar    $0x1f,%ecx
  801dcc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801dcf:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd2:	8d 40 04             	lea    0x4(%eax),%eax
  801dd5:	89 45 14             	mov    %eax,0x14(%ebp)
  801dd8:	eb 19                	jmp    801df3 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801dda:	8b 45 14             	mov    0x14(%ebp),%eax
  801ddd:	8b 00                	mov    (%eax),%eax
  801ddf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801de2:	89 c1                	mov    %eax,%ecx
  801de4:	c1 f9 1f             	sar    $0x1f,%ecx
  801de7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801dea:	8b 45 14             	mov    0x14(%ebp),%eax
  801ded:	8d 40 04             	lea    0x4(%eax),%eax
  801df0:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801df3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801df6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801df9:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801dfe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e02:	0f 89 0e 01 00 00    	jns    801f16 <vprintfmt+0x40f>
				putch('-', putdat);
  801e08:	83 ec 08             	sub    $0x8,%esp
  801e0b:	53                   	push   %ebx
  801e0c:	6a 2d                	push   $0x2d
  801e0e:	ff d6                	call   *%esi
				num = -(long long) num;
  801e10:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801e13:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801e16:	f7 da                	neg    %edx
  801e18:	83 d1 00             	adc    $0x0,%ecx
  801e1b:	f7 d9                	neg    %ecx
  801e1d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801e20:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e25:	e9 ec 00 00 00       	jmp    801f16 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e2a:	83 f9 01             	cmp    $0x1,%ecx
  801e2d:	7e 18                	jle    801e47 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801e2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e32:	8b 10                	mov    (%eax),%edx
  801e34:	8b 48 04             	mov    0x4(%eax),%ecx
  801e37:	8d 40 08             	lea    0x8(%eax),%eax
  801e3a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801e3d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e42:	e9 cf 00 00 00       	jmp    801f16 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801e47:	85 c9                	test   %ecx,%ecx
  801e49:	74 1a                	je     801e65 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801e4b:	8b 45 14             	mov    0x14(%ebp),%eax
  801e4e:	8b 10                	mov    (%eax),%edx
  801e50:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e55:	8d 40 04             	lea    0x4(%eax),%eax
  801e58:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801e5b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e60:	e9 b1 00 00 00       	jmp    801f16 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801e65:	8b 45 14             	mov    0x14(%ebp),%eax
  801e68:	8b 10                	mov    (%eax),%edx
  801e6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e6f:	8d 40 04             	lea    0x4(%eax),%eax
  801e72:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801e75:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e7a:	e9 97 00 00 00       	jmp    801f16 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801e7f:	83 ec 08             	sub    $0x8,%esp
  801e82:	53                   	push   %ebx
  801e83:	6a 58                	push   $0x58
  801e85:	ff d6                	call   *%esi
			putch('X', putdat);
  801e87:	83 c4 08             	add    $0x8,%esp
  801e8a:	53                   	push   %ebx
  801e8b:	6a 58                	push   $0x58
  801e8d:	ff d6                	call   *%esi
			putch('X', putdat);
  801e8f:	83 c4 08             	add    $0x8,%esp
  801e92:	53                   	push   %ebx
  801e93:	6a 58                	push   $0x58
  801e95:	ff d6                	call   *%esi
			break;
  801e97:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801e9d:	e9 8b fc ff ff       	jmp    801b2d <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801ea2:	83 ec 08             	sub    $0x8,%esp
  801ea5:	53                   	push   %ebx
  801ea6:	6a 30                	push   $0x30
  801ea8:	ff d6                	call   *%esi
			putch('x', putdat);
  801eaa:	83 c4 08             	add    $0x8,%esp
  801ead:	53                   	push   %ebx
  801eae:	6a 78                	push   $0x78
  801eb0:	ff d6                	call   *%esi
			num = (unsigned long long)
  801eb2:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb5:	8b 10                	mov    (%eax),%edx
  801eb7:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ebc:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ebf:	8d 40 04             	lea    0x4(%eax),%eax
  801ec2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ec5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801eca:	eb 4a                	jmp    801f16 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801ecc:	83 f9 01             	cmp    $0x1,%ecx
  801ecf:	7e 15                	jle    801ee6 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801ed1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ed4:	8b 10                	mov    (%eax),%edx
  801ed6:	8b 48 04             	mov    0x4(%eax),%ecx
  801ed9:	8d 40 08             	lea    0x8(%eax),%eax
  801edc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801edf:	b8 10 00 00 00       	mov    $0x10,%eax
  801ee4:	eb 30                	jmp    801f16 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801ee6:	85 c9                	test   %ecx,%ecx
  801ee8:	74 17                	je     801f01 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801eea:	8b 45 14             	mov    0x14(%ebp),%eax
  801eed:	8b 10                	mov    (%eax),%edx
  801eef:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ef4:	8d 40 04             	lea    0x4(%eax),%eax
  801ef7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801efa:	b8 10 00 00 00       	mov    $0x10,%eax
  801eff:	eb 15                	jmp    801f16 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801f01:	8b 45 14             	mov    0x14(%ebp),%eax
  801f04:	8b 10                	mov    (%eax),%edx
  801f06:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f0b:	8d 40 04             	lea    0x4(%eax),%eax
  801f0e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801f11:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801f16:	83 ec 0c             	sub    $0xc,%esp
  801f19:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801f1d:	57                   	push   %edi
  801f1e:	ff 75 e0             	pushl  -0x20(%ebp)
  801f21:	50                   	push   %eax
  801f22:	51                   	push   %ecx
  801f23:	52                   	push   %edx
  801f24:	89 da                	mov    %ebx,%edx
  801f26:	89 f0                	mov    %esi,%eax
  801f28:	e8 f1 fa ff ff       	call   801a1e <printnum>
			break;
  801f2d:	83 c4 20             	add    $0x20,%esp
  801f30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f33:	e9 f5 fb ff ff       	jmp    801b2d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f38:	83 ec 08             	sub    $0x8,%esp
  801f3b:	53                   	push   %ebx
  801f3c:	52                   	push   %edx
  801f3d:	ff d6                	call   *%esi
			break;
  801f3f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f45:	e9 e3 fb ff ff       	jmp    801b2d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f4a:	83 ec 08             	sub    $0x8,%esp
  801f4d:	53                   	push   %ebx
  801f4e:	6a 25                	push   $0x25
  801f50:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	eb 03                	jmp    801f5a <vprintfmt+0x453>
  801f57:	83 ef 01             	sub    $0x1,%edi
  801f5a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f5e:	75 f7                	jne    801f57 <vprintfmt+0x450>
  801f60:	e9 c8 fb ff ff       	jmp    801b2d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5e                   	pop    %esi
  801f6a:	5f                   	pop    %edi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	83 ec 18             	sub    $0x18,%esp
  801f73:	8b 45 08             	mov    0x8(%ebp),%eax
  801f76:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f79:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f7c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f80:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	74 26                	je     801fb4 <vsnprintf+0x47>
  801f8e:	85 d2                	test   %edx,%edx
  801f90:	7e 22                	jle    801fb4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f92:	ff 75 14             	pushl  0x14(%ebp)
  801f95:	ff 75 10             	pushl  0x10(%ebp)
  801f98:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f9b:	50                   	push   %eax
  801f9c:	68 cd 1a 80 00       	push   $0x801acd
  801fa1:	e8 61 fb ff ff       	call   801b07 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801fa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801fa9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801faf:	83 c4 10             	add    $0x10,%esp
  801fb2:	eb 05                	jmp    801fb9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801fb4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801fb9:	c9                   	leave  
  801fba:	c3                   	ret    

00801fbb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801fc1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801fc4:	50                   	push   %eax
  801fc5:	ff 75 10             	pushl  0x10(%ebp)
  801fc8:	ff 75 0c             	pushl  0xc(%ebp)
  801fcb:	ff 75 08             	pushl  0x8(%ebp)
  801fce:	e8 9a ff ff ff       	call   801f6d <vsnprintf>
	va_end(ap);

	return rc;
}
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe0:	eb 03                	jmp    801fe5 <strlen+0x10>
		n++;
  801fe2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801fe5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801fe9:	75 f7                	jne    801fe2 <strlen+0xd>
		n++;
	return n;
}
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    

00801fed <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ff6:	ba 00 00 00 00       	mov    $0x0,%edx
  801ffb:	eb 03                	jmp    802000 <strnlen+0x13>
		n++;
  801ffd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802000:	39 c2                	cmp    %eax,%edx
  802002:	74 08                	je     80200c <strnlen+0x1f>
  802004:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  802008:	75 f3                	jne    801ffd <strnlen+0x10>
  80200a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    

0080200e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	53                   	push   %ebx
  802012:	8b 45 08             	mov    0x8(%ebp),%eax
  802015:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802018:	89 c2                	mov    %eax,%edx
  80201a:	83 c2 01             	add    $0x1,%edx
  80201d:	83 c1 01             	add    $0x1,%ecx
  802020:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  802024:	88 5a ff             	mov    %bl,-0x1(%edx)
  802027:	84 db                	test   %bl,%bl
  802029:	75 ef                	jne    80201a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80202b:	5b                   	pop    %ebx
  80202c:	5d                   	pop    %ebp
  80202d:	c3                   	ret    

0080202e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	53                   	push   %ebx
  802032:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802035:	53                   	push   %ebx
  802036:	e8 9a ff ff ff       	call   801fd5 <strlen>
  80203b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80203e:	ff 75 0c             	pushl  0xc(%ebp)
  802041:	01 d8                	add    %ebx,%eax
  802043:	50                   	push   %eax
  802044:	e8 c5 ff ff ff       	call   80200e <strcpy>
	return dst;
}
  802049:	89 d8                	mov    %ebx,%eax
  80204b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80204e:	c9                   	leave  
  80204f:	c3                   	ret    

00802050 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	56                   	push   %esi
  802054:	53                   	push   %ebx
  802055:	8b 75 08             	mov    0x8(%ebp),%esi
  802058:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80205b:	89 f3                	mov    %esi,%ebx
  80205d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802060:	89 f2                	mov    %esi,%edx
  802062:	eb 0f                	jmp    802073 <strncpy+0x23>
		*dst++ = *src;
  802064:	83 c2 01             	add    $0x1,%edx
  802067:	0f b6 01             	movzbl (%ecx),%eax
  80206a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80206d:	80 39 01             	cmpb   $0x1,(%ecx)
  802070:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802073:	39 da                	cmp    %ebx,%edx
  802075:	75 ed                	jne    802064 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802077:	89 f0                	mov    %esi,%eax
  802079:	5b                   	pop    %ebx
  80207a:	5e                   	pop    %esi
  80207b:	5d                   	pop    %ebp
  80207c:	c3                   	ret    

0080207d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	56                   	push   %esi
  802081:	53                   	push   %ebx
  802082:	8b 75 08             	mov    0x8(%ebp),%esi
  802085:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802088:	8b 55 10             	mov    0x10(%ebp),%edx
  80208b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80208d:	85 d2                	test   %edx,%edx
  80208f:	74 21                	je     8020b2 <strlcpy+0x35>
  802091:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802095:	89 f2                	mov    %esi,%edx
  802097:	eb 09                	jmp    8020a2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802099:	83 c2 01             	add    $0x1,%edx
  80209c:	83 c1 01             	add    $0x1,%ecx
  80209f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8020a2:	39 c2                	cmp    %eax,%edx
  8020a4:	74 09                	je     8020af <strlcpy+0x32>
  8020a6:	0f b6 19             	movzbl (%ecx),%ebx
  8020a9:	84 db                	test   %bl,%bl
  8020ab:	75 ec                	jne    802099 <strlcpy+0x1c>
  8020ad:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8020af:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8020b2:	29 f0                	sub    %esi,%eax
}
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8020c1:	eb 06                	jmp    8020c9 <strcmp+0x11>
		p++, q++;
  8020c3:	83 c1 01             	add    $0x1,%ecx
  8020c6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8020c9:	0f b6 01             	movzbl (%ecx),%eax
  8020cc:	84 c0                	test   %al,%al
  8020ce:	74 04                	je     8020d4 <strcmp+0x1c>
  8020d0:	3a 02                	cmp    (%edx),%al
  8020d2:	74 ef                	je     8020c3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8020d4:	0f b6 c0             	movzbl %al,%eax
  8020d7:	0f b6 12             	movzbl (%edx),%edx
  8020da:	29 d0                	sub    %edx,%eax
}
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    

008020de <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	53                   	push   %ebx
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e8:	89 c3                	mov    %eax,%ebx
  8020ea:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8020ed:	eb 06                	jmp    8020f5 <strncmp+0x17>
		n--, p++, q++;
  8020ef:	83 c0 01             	add    $0x1,%eax
  8020f2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8020f5:	39 d8                	cmp    %ebx,%eax
  8020f7:	74 15                	je     80210e <strncmp+0x30>
  8020f9:	0f b6 08             	movzbl (%eax),%ecx
  8020fc:	84 c9                	test   %cl,%cl
  8020fe:	74 04                	je     802104 <strncmp+0x26>
  802100:	3a 0a                	cmp    (%edx),%cl
  802102:	74 eb                	je     8020ef <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802104:	0f b6 00             	movzbl (%eax),%eax
  802107:	0f b6 12             	movzbl (%edx),%edx
  80210a:	29 d0                	sub    %edx,%eax
  80210c:	eb 05                	jmp    802113 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80210e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802113:	5b                   	pop    %ebx
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    

00802116 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	8b 45 08             	mov    0x8(%ebp),%eax
  80211c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802120:	eb 07                	jmp    802129 <strchr+0x13>
		if (*s == c)
  802122:	38 ca                	cmp    %cl,%dl
  802124:	74 0f                	je     802135 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802126:	83 c0 01             	add    $0x1,%eax
  802129:	0f b6 10             	movzbl (%eax),%edx
  80212c:	84 d2                	test   %dl,%dl
  80212e:	75 f2                	jne    802122 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802130:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802135:	5d                   	pop    %ebp
  802136:	c3                   	ret    

00802137 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	8b 45 08             	mov    0x8(%ebp),%eax
  80213d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802141:	eb 03                	jmp    802146 <strfind+0xf>
  802143:	83 c0 01             	add    $0x1,%eax
  802146:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802149:	38 ca                	cmp    %cl,%dl
  80214b:	74 04                	je     802151 <strfind+0x1a>
  80214d:	84 d2                	test   %dl,%dl
  80214f:	75 f2                	jne    802143 <strfind+0xc>
			break;
	return (char *) s;
}
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    

00802153 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	57                   	push   %edi
  802157:	56                   	push   %esi
  802158:	53                   	push   %ebx
  802159:	8b 7d 08             	mov    0x8(%ebp),%edi
  80215c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80215f:	85 c9                	test   %ecx,%ecx
  802161:	74 36                	je     802199 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802163:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802169:	75 28                	jne    802193 <memset+0x40>
  80216b:	f6 c1 03             	test   $0x3,%cl
  80216e:	75 23                	jne    802193 <memset+0x40>
		c &= 0xFF;
  802170:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802174:	89 d3                	mov    %edx,%ebx
  802176:	c1 e3 08             	shl    $0x8,%ebx
  802179:	89 d6                	mov    %edx,%esi
  80217b:	c1 e6 18             	shl    $0x18,%esi
  80217e:	89 d0                	mov    %edx,%eax
  802180:	c1 e0 10             	shl    $0x10,%eax
  802183:	09 f0                	or     %esi,%eax
  802185:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  802187:	89 d8                	mov    %ebx,%eax
  802189:	09 d0                	or     %edx,%eax
  80218b:	c1 e9 02             	shr    $0x2,%ecx
  80218e:	fc                   	cld    
  80218f:	f3 ab                	rep stos %eax,%es:(%edi)
  802191:	eb 06                	jmp    802199 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802193:	8b 45 0c             	mov    0xc(%ebp),%eax
  802196:	fc                   	cld    
  802197:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802199:	89 f8                	mov    %edi,%eax
  80219b:	5b                   	pop    %ebx
  80219c:	5e                   	pop    %esi
  80219d:	5f                   	pop    %edi
  80219e:	5d                   	pop    %ebp
  80219f:	c3                   	ret    

008021a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	57                   	push   %edi
  8021a4:	56                   	push   %esi
  8021a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8021ae:	39 c6                	cmp    %eax,%esi
  8021b0:	73 35                	jae    8021e7 <memmove+0x47>
  8021b2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8021b5:	39 d0                	cmp    %edx,%eax
  8021b7:	73 2e                	jae    8021e7 <memmove+0x47>
		s += n;
		d += n;
  8021b9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021bc:	89 d6                	mov    %edx,%esi
  8021be:	09 fe                	or     %edi,%esi
  8021c0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8021c6:	75 13                	jne    8021db <memmove+0x3b>
  8021c8:	f6 c1 03             	test   $0x3,%cl
  8021cb:	75 0e                	jne    8021db <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8021cd:	83 ef 04             	sub    $0x4,%edi
  8021d0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8021d3:	c1 e9 02             	shr    $0x2,%ecx
  8021d6:	fd                   	std    
  8021d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021d9:	eb 09                	jmp    8021e4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021db:	83 ef 01             	sub    $0x1,%edi
  8021de:	8d 72 ff             	lea    -0x1(%edx),%esi
  8021e1:	fd                   	std    
  8021e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021e4:	fc                   	cld    
  8021e5:	eb 1d                	jmp    802204 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021e7:	89 f2                	mov    %esi,%edx
  8021e9:	09 c2                	or     %eax,%edx
  8021eb:	f6 c2 03             	test   $0x3,%dl
  8021ee:	75 0f                	jne    8021ff <memmove+0x5f>
  8021f0:	f6 c1 03             	test   $0x3,%cl
  8021f3:	75 0a                	jne    8021ff <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8021f5:	c1 e9 02             	shr    $0x2,%ecx
  8021f8:	89 c7                	mov    %eax,%edi
  8021fa:	fc                   	cld    
  8021fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021fd:	eb 05                	jmp    802204 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021ff:	89 c7                	mov    %eax,%edi
  802201:	fc                   	cld    
  802202:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    

00802208 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80220b:	ff 75 10             	pushl  0x10(%ebp)
  80220e:	ff 75 0c             	pushl  0xc(%ebp)
  802211:	ff 75 08             	pushl  0x8(%ebp)
  802214:	e8 87 ff ff ff       	call   8021a0 <memmove>
}
  802219:	c9                   	leave  
  80221a:	c3                   	ret    

0080221b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	56                   	push   %esi
  80221f:	53                   	push   %ebx
  802220:	8b 45 08             	mov    0x8(%ebp),%eax
  802223:	8b 55 0c             	mov    0xc(%ebp),%edx
  802226:	89 c6                	mov    %eax,%esi
  802228:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80222b:	eb 1a                	jmp    802247 <memcmp+0x2c>
		if (*s1 != *s2)
  80222d:	0f b6 08             	movzbl (%eax),%ecx
  802230:	0f b6 1a             	movzbl (%edx),%ebx
  802233:	38 d9                	cmp    %bl,%cl
  802235:	74 0a                	je     802241 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802237:	0f b6 c1             	movzbl %cl,%eax
  80223a:	0f b6 db             	movzbl %bl,%ebx
  80223d:	29 d8                	sub    %ebx,%eax
  80223f:	eb 0f                	jmp    802250 <memcmp+0x35>
		s1++, s2++;
  802241:	83 c0 01             	add    $0x1,%eax
  802244:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802247:	39 f0                	cmp    %esi,%eax
  802249:	75 e2                	jne    80222d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80224b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    

00802254 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	53                   	push   %ebx
  802258:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80225b:	89 c1                	mov    %eax,%ecx
  80225d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802260:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802264:	eb 0a                	jmp    802270 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802266:	0f b6 10             	movzbl (%eax),%edx
  802269:	39 da                	cmp    %ebx,%edx
  80226b:	74 07                	je     802274 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80226d:	83 c0 01             	add    $0x1,%eax
  802270:	39 c8                	cmp    %ecx,%eax
  802272:	72 f2                	jb     802266 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802274:	5b                   	pop    %ebx
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    

00802277 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	57                   	push   %edi
  80227b:	56                   	push   %esi
  80227c:	53                   	push   %ebx
  80227d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802280:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802283:	eb 03                	jmp    802288 <strtol+0x11>
		s++;
  802285:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802288:	0f b6 01             	movzbl (%ecx),%eax
  80228b:	3c 20                	cmp    $0x20,%al
  80228d:	74 f6                	je     802285 <strtol+0xe>
  80228f:	3c 09                	cmp    $0x9,%al
  802291:	74 f2                	je     802285 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802293:	3c 2b                	cmp    $0x2b,%al
  802295:	75 0a                	jne    8022a1 <strtol+0x2a>
		s++;
  802297:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80229a:	bf 00 00 00 00       	mov    $0x0,%edi
  80229f:	eb 11                	jmp    8022b2 <strtol+0x3b>
  8022a1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8022a6:	3c 2d                	cmp    $0x2d,%al
  8022a8:	75 08                	jne    8022b2 <strtol+0x3b>
		s++, neg = 1;
  8022aa:	83 c1 01             	add    $0x1,%ecx
  8022ad:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022b2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8022b8:	75 15                	jne    8022cf <strtol+0x58>
  8022ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8022bd:	75 10                	jne    8022cf <strtol+0x58>
  8022bf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8022c3:	75 7c                	jne    802341 <strtol+0xca>
		s += 2, base = 16;
  8022c5:	83 c1 02             	add    $0x2,%ecx
  8022c8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8022cd:	eb 16                	jmp    8022e5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8022cf:	85 db                	test   %ebx,%ebx
  8022d1:	75 12                	jne    8022e5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8022d3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022d8:	80 39 30             	cmpb   $0x30,(%ecx)
  8022db:	75 08                	jne    8022e5 <strtol+0x6e>
		s++, base = 8;
  8022dd:	83 c1 01             	add    $0x1,%ecx
  8022e0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8022e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ea:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022ed:	0f b6 11             	movzbl (%ecx),%edx
  8022f0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8022f3:	89 f3                	mov    %esi,%ebx
  8022f5:	80 fb 09             	cmp    $0x9,%bl
  8022f8:	77 08                	ja     802302 <strtol+0x8b>
			dig = *s - '0';
  8022fa:	0f be d2             	movsbl %dl,%edx
  8022fd:	83 ea 30             	sub    $0x30,%edx
  802300:	eb 22                	jmp    802324 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  802302:	8d 72 9f             	lea    -0x61(%edx),%esi
  802305:	89 f3                	mov    %esi,%ebx
  802307:	80 fb 19             	cmp    $0x19,%bl
  80230a:	77 08                	ja     802314 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80230c:	0f be d2             	movsbl %dl,%edx
  80230f:	83 ea 57             	sub    $0x57,%edx
  802312:	eb 10                	jmp    802324 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  802314:	8d 72 bf             	lea    -0x41(%edx),%esi
  802317:	89 f3                	mov    %esi,%ebx
  802319:	80 fb 19             	cmp    $0x19,%bl
  80231c:	77 16                	ja     802334 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80231e:	0f be d2             	movsbl %dl,%edx
  802321:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  802324:	3b 55 10             	cmp    0x10(%ebp),%edx
  802327:	7d 0b                	jge    802334 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802329:	83 c1 01             	add    $0x1,%ecx
  80232c:	0f af 45 10          	imul   0x10(%ebp),%eax
  802330:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802332:	eb b9                	jmp    8022ed <strtol+0x76>

	if (endptr)
  802334:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802338:	74 0d                	je     802347 <strtol+0xd0>
		*endptr = (char *) s;
  80233a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80233d:	89 0e                	mov    %ecx,(%esi)
  80233f:	eb 06                	jmp    802347 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802341:	85 db                	test   %ebx,%ebx
  802343:	74 98                	je     8022dd <strtol+0x66>
  802345:	eb 9e                	jmp    8022e5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802347:	89 c2                	mov    %eax,%edx
  802349:	f7 da                	neg    %edx
  80234b:	85 ff                	test   %edi,%edi
  80234d:	0f 45 c2             	cmovne %edx,%eax
}
  802350:	5b                   	pop    %ebx
  802351:	5e                   	pop    %esi
  802352:	5f                   	pop    %edi
  802353:	5d                   	pop    %ebp
  802354:	c3                   	ret    

00802355 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802355:	55                   	push   %ebp
  802356:	89 e5                	mov    %esp,%ebp
  802358:	57                   	push   %edi
  802359:	56                   	push   %esi
  80235a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80235b:	b8 00 00 00 00       	mov    $0x0,%eax
  802360:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802363:	8b 55 08             	mov    0x8(%ebp),%edx
  802366:	89 c3                	mov    %eax,%ebx
  802368:	89 c7                	mov    %eax,%edi
  80236a:	89 c6                	mov    %eax,%esi
  80236c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80236e:	5b                   	pop    %ebx
  80236f:	5e                   	pop    %esi
  802370:	5f                   	pop    %edi
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    

00802373 <sys_cgetc>:

int
sys_cgetc(void)
{
  802373:	55                   	push   %ebp
  802374:	89 e5                	mov    %esp,%ebp
  802376:	57                   	push   %edi
  802377:	56                   	push   %esi
  802378:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802379:	ba 00 00 00 00       	mov    $0x0,%edx
  80237e:	b8 01 00 00 00       	mov    $0x1,%eax
  802383:	89 d1                	mov    %edx,%ecx
  802385:	89 d3                	mov    %edx,%ebx
  802387:	89 d7                	mov    %edx,%edi
  802389:	89 d6                	mov    %edx,%esi
  80238b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    

00802392 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	57                   	push   %edi
  802396:	56                   	push   %esi
  802397:	53                   	push   %ebx
  802398:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80239b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8023a0:	b8 03 00 00 00       	mov    $0x3,%eax
  8023a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8023a8:	89 cb                	mov    %ecx,%ebx
  8023aa:	89 cf                	mov    %ecx,%edi
  8023ac:	89 ce                	mov    %ecx,%esi
  8023ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	7e 17                	jle    8023cb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8023b4:	83 ec 0c             	sub    $0xc,%esp
  8023b7:	50                   	push   %eax
  8023b8:	6a 03                	push   $0x3
  8023ba:	68 9f 3f 80 00       	push   $0x803f9f
  8023bf:	6a 23                	push   $0x23
  8023c1:	68 bc 3f 80 00       	push   $0x803fbc
  8023c6:	e8 66 f5 ff ff       	call   801931 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8023cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ce:	5b                   	pop    %ebx
  8023cf:	5e                   	pop    %esi
  8023d0:	5f                   	pop    %edi
  8023d1:	5d                   	pop    %ebp
  8023d2:	c3                   	ret    

008023d3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8023d3:	55                   	push   %ebp
  8023d4:	89 e5                	mov    %esp,%ebp
  8023d6:	57                   	push   %edi
  8023d7:	56                   	push   %esi
  8023d8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8023de:	b8 02 00 00 00       	mov    $0x2,%eax
  8023e3:	89 d1                	mov    %edx,%ecx
  8023e5:	89 d3                	mov    %edx,%ebx
  8023e7:	89 d7                	mov    %edx,%edi
  8023e9:	89 d6                	mov    %edx,%esi
  8023eb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5f                   	pop    %edi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    

008023f2 <sys_yield>:

void
sys_yield(void)
{
  8023f2:	55                   	push   %ebp
  8023f3:	89 e5                	mov    %esp,%ebp
  8023f5:	57                   	push   %edi
  8023f6:	56                   	push   %esi
  8023f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8023fd:	b8 0b 00 00 00       	mov    $0xb,%eax
  802402:	89 d1                	mov    %edx,%ecx
  802404:	89 d3                	mov    %edx,%ebx
  802406:	89 d7                	mov    %edx,%edi
  802408:	89 d6                	mov    %edx,%esi
  80240a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80240c:	5b                   	pop    %ebx
  80240d:	5e                   	pop    %esi
  80240e:	5f                   	pop    %edi
  80240f:	5d                   	pop    %ebp
  802410:	c3                   	ret    

00802411 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802411:	55                   	push   %ebp
  802412:	89 e5                	mov    %esp,%ebp
  802414:	57                   	push   %edi
  802415:	56                   	push   %esi
  802416:	53                   	push   %ebx
  802417:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80241a:	be 00 00 00 00       	mov    $0x0,%esi
  80241f:	b8 04 00 00 00       	mov    $0x4,%eax
  802424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802427:	8b 55 08             	mov    0x8(%ebp),%edx
  80242a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80242d:	89 f7                	mov    %esi,%edi
  80242f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802431:	85 c0                	test   %eax,%eax
  802433:	7e 17                	jle    80244c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802435:	83 ec 0c             	sub    $0xc,%esp
  802438:	50                   	push   %eax
  802439:	6a 04                	push   $0x4
  80243b:	68 9f 3f 80 00       	push   $0x803f9f
  802440:	6a 23                	push   $0x23
  802442:	68 bc 3f 80 00       	push   $0x803fbc
  802447:	e8 e5 f4 ff ff       	call   801931 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80244c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80244f:	5b                   	pop    %ebx
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    

00802454 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	57                   	push   %edi
  802458:	56                   	push   %esi
  802459:	53                   	push   %ebx
  80245a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80245d:	b8 05 00 00 00       	mov    $0x5,%eax
  802462:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802465:	8b 55 08             	mov    0x8(%ebp),%edx
  802468:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80246b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80246e:	8b 75 18             	mov    0x18(%ebp),%esi
  802471:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802473:	85 c0                	test   %eax,%eax
  802475:	7e 17                	jle    80248e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802477:	83 ec 0c             	sub    $0xc,%esp
  80247a:	50                   	push   %eax
  80247b:	6a 05                	push   $0x5
  80247d:	68 9f 3f 80 00       	push   $0x803f9f
  802482:	6a 23                	push   $0x23
  802484:	68 bc 3f 80 00       	push   $0x803fbc
  802489:	e8 a3 f4 ff ff       	call   801931 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80248e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802491:	5b                   	pop    %ebx
  802492:	5e                   	pop    %esi
  802493:	5f                   	pop    %edi
  802494:	5d                   	pop    %ebp
  802495:	c3                   	ret    

00802496 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802496:	55                   	push   %ebp
  802497:	89 e5                	mov    %esp,%ebp
  802499:	57                   	push   %edi
  80249a:	56                   	push   %esi
  80249b:	53                   	push   %ebx
  80249c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80249f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8024a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8024af:	89 df                	mov    %ebx,%edi
  8024b1:	89 de                	mov    %ebx,%esi
  8024b3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024b5:	85 c0                	test   %eax,%eax
  8024b7:	7e 17                	jle    8024d0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024b9:	83 ec 0c             	sub    $0xc,%esp
  8024bc:	50                   	push   %eax
  8024bd:	6a 06                	push   $0x6
  8024bf:	68 9f 3f 80 00       	push   $0x803f9f
  8024c4:	6a 23                	push   $0x23
  8024c6:	68 bc 3f 80 00       	push   $0x803fbc
  8024cb:	e8 61 f4 ff ff       	call   801931 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8024d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d3:	5b                   	pop    %ebx
  8024d4:	5e                   	pop    %esi
  8024d5:	5f                   	pop    %edi
  8024d6:	5d                   	pop    %ebp
  8024d7:	c3                   	ret    

008024d8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024d8:	55                   	push   %ebp
  8024d9:	89 e5                	mov    %esp,%ebp
  8024db:	57                   	push   %edi
  8024dc:	56                   	push   %esi
  8024dd:	53                   	push   %ebx
  8024de:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024e6:	b8 08 00 00 00       	mov    $0x8,%eax
  8024eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8024f1:	89 df                	mov    %ebx,%edi
  8024f3:	89 de                	mov    %ebx,%esi
  8024f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	7e 17                	jle    802512 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024fb:	83 ec 0c             	sub    $0xc,%esp
  8024fe:	50                   	push   %eax
  8024ff:	6a 08                	push   $0x8
  802501:	68 9f 3f 80 00       	push   $0x803f9f
  802506:	6a 23                	push   $0x23
  802508:	68 bc 3f 80 00       	push   $0x803fbc
  80250d:	e8 1f f4 ff ff       	call   801931 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802512:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802515:	5b                   	pop    %ebx
  802516:	5e                   	pop    %esi
  802517:	5f                   	pop    %edi
  802518:	5d                   	pop    %ebp
  802519:	c3                   	ret    

0080251a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80251a:	55                   	push   %ebp
  80251b:	89 e5                	mov    %esp,%ebp
  80251d:	57                   	push   %edi
  80251e:	56                   	push   %esi
  80251f:	53                   	push   %ebx
  802520:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802523:	bb 00 00 00 00       	mov    $0x0,%ebx
  802528:	b8 09 00 00 00       	mov    $0x9,%eax
  80252d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802530:	8b 55 08             	mov    0x8(%ebp),%edx
  802533:	89 df                	mov    %ebx,%edi
  802535:	89 de                	mov    %ebx,%esi
  802537:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802539:	85 c0                	test   %eax,%eax
  80253b:	7e 17                	jle    802554 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80253d:	83 ec 0c             	sub    $0xc,%esp
  802540:	50                   	push   %eax
  802541:	6a 09                	push   $0x9
  802543:	68 9f 3f 80 00       	push   $0x803f9f
  802548:	6a 23                	push   $0x23
  80254a:	68 bc 3f 80 00       	push   $0x803fbc
  80254f:	e8 dd f3 ff ff       	call   801931 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802554:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802557:	5b                   	pop    %ebx
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    

0080255c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80255c:	55                   	push   %ebp
  80255d:	89 e5                	mov    %esp,%ebp
  80255f:	57                   	push   %edi
  802560:	56                   	push   %esi
  802561:	53                   	push   %ebx
  802562:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802565:	bb 00 00 00 00       	mov    $0x0,%ebx
  80256a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80256f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802572:	8b 55 08             	mov    0x8(%ebp),%edx
  802575:	89 df                	mov    %ebx,%edi
  802577:	89 de                	mov    %ebx,%esi
  802579:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80257b:	85 c0                	test   %eax,%eax
  80257d:	7e 17                	jle    802596 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80257f:	83 ec 0c             	sub    $0xc,%esp
  802582:	50                   	push   %eax
  802583:	6a 0a                	push   $0xa
  802585:	68 9f 3f 80 00       	push   $0x803f9f
  80258a:	6a 23                	push   $0x23
  80258c:	68 bc 3f 80 00       	push   $0x803fbc
  802591:	e8 9b f3 ff ff       	call   801931 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802596:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802599:	5b                   	pop    %ebx
  80259a:	5e                   	pop    %esi
  80259b:	5f                   	pop    %edi
  80259c:	5d                   	pop    %ebp
  80259d:	c3                   	ret    

0080259e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80259e:	55                   	push   %ebp
  80259f:	89 e5                	mov    %esp,%ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025a4:	be 00 00 00 00       	mov    $0x0,%esi
  8025a9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8025ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8025b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025b7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025ba:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8025bc:	5b                   	pop    %ebx
  8025bd:	5e                   	pop    %esi
  8025be:	5f                   	pop    %edi
  8025bf:	5d                   	pop    %ebp
  8025c0:	c3                   	ret    

008025c1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8025c1:	55                   	push   %ebp
  8025c2:	89 e5                	mov    %esp,%ebp
  8025c4:	57                   	push   %edi
  8025c5:	56                   	push   %esi
  8025c6:	53                   	push   %ebx
  8025c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025cf:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8025d7:	89 cb                	mov    %ecx,%ebx
  8025d9:	89 cf                	mov    %ecx,%edi
  8025db:	89 ce                	mov    %ecx,%esi
  8025dd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025df:	85 c0                	test   %eax,%eax
  8025e1:	7e 17                	jle    8025fa <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025e3:	83 ec 0c             	sub    $0xc,%esp
  8025e6:	50                   	push   %eax
  8025e7:	6a 0d                	push   $0xd
  8025e9:	68 9f 3f 80 00       	push   $0x803f9f
  8025ee:	6a 23                	push   $0x23
  8025f0:	68 bc 3f 80 00       	push   $0x803fbc
  8025f5:	e8 37 f3 ff ff       	call   801931 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8025fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    

00802602 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802602:	55                   	push   %ebp
  802603:	89 e5                	mov    %esp,%ebp
  802605:	53                   	push   %ebx
  802606:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802609:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802610:	75 28                	jne    80263a <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  802612:	e8 bc fd ff ff       	call   8023d3 <sys_getenvid>
  802617:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  802619:	83 ec 04             	sub    $0x4,%esp
  80261c:	6a 07                	push   $0x7
  80261e:	68 00 f0 bf ee       	push   $0xeebff000
  802623:	50                   	push   %eax
  802624:	e8 e8 fd ff ff       	call   802411 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  802629:	83 c4 08             	add    $0x8,%esp
  80262c:	68 47 26 80 00       	push   $0x802647
  802631:	53                   	push   %ebx
  802632:	e8 25 ff ff ff       	call   80255c <sys_env_set_pgfault_upcall>
  802637:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80263a:	8b 45 08             	mov    0x8(%ebp),%eax
  80263d:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  802642:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802645:	c9                   	leave  
  802646:	c3                   	ret    

00802647 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  802647:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802648:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  80264d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80264f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  802652:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  802654:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  802658:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  80265c:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  80265d:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  80265f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  802664:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  802665:	58                   	pop    %eax
	popal 				// pop utf_regs 
  802666:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  802667:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  80266a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  80266b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80266c:	c3                   	ret    

0080266d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80266d:	55                   	push   %ebp
  80266e:	89 e5                	mov    %esp,%ebp
  802670:	56                   	push   %esi
  802671:	53                   	push   %ebx
  802672:	8b 75 08             	mov    0x8(%ebp),%esi
  802675:	8b 45 0c             	mov    0xc(%ebp),%eax
  802678:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  80267b:	85 c0                	test   %eax,%eax
  80267d:	74 0e                	je     80268d <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  80267f:	83 ec 0c             	sub    $0xc,%esp
  802682:	50                   	push   %eax
  802683:	e8 39 ff ff ff       	call   8025c1 <sys_ipc_recv>
  802688:	83 c4 10             	add    $0x10,%esp
  80268b:	eb 0d                	jmp    80269a <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  80268d:	83 ec 0c             	sub    $0xc,%esp
  802690:	6a ff                	push   $0xffffffff
  802692:	e8 2a ff ff ff       	call   8025c1 <sys_ipc_recv>
  802697:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  80269a:	85 c0                	test   %eax,%eax
  80269c:	79 16                	jns    8026b4 <ipc_recv+0x47>

		if (from_env_store != NULL)
  80269e:	85 f6                	test   %esi,%esi
  8026a0:	74 06                	je     8026a8 <ipc_recv+0x3b>
			*from_env_store = 0;
  8026a2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  8026a8:	85 db                	test   %ebx,%ebx
  8026aa:	74 2c                	je     8026d8 <ipc_recv+0x6b>
			*perm_store = 0;
  8026ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026b2:	eb 24                	jmp    8026d8 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  8026b4:	85 f6                	test   %esi,%esi
  8026b6:	74 0a                	je     8026c2 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  8026b8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026bd:	8b 40 74             	mov    0x74(%eax),%eax
  8026c0:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  8026c2:	85 db                	test   %ebx,%ebx
  8026c4:	74 0a                	je     8026d0 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  8026c6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026cb:	8b 40 78             	mov    0x78(%eax),%eax
  8026ce:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8026d0:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026d5:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8026d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026db:	5b                   	pop    %ebx
  8026dc:	5e                   	pop    %esi
  8026dd:	5d                   	pop    %ebp
  8026de:	c3                   	ret    

008026df <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026df:	55                   	push   %ebp
  8026e0:	89 e5                	mov    %esp,%ebp
  8026e2:	57                   	push   %edi
  8026e3:	56                   	push   %esi
  8026e4:	53                   	push   %ebx
  8026e5:	83 ec 0c             	sub    $0xc,%esp
  8026e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  8026f1:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  8026f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8026f8:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8026fb:	ff 75 14             	pushl  0x14(%ebp)
  8026fe:	53                   	push   %ebx
  8026ff:	56                   	push   %esi
  802700:	57                   	push   %edi
  802701:	e8 98 fe ff ff       	call   80259e <sys_ipc_try_send>
		if (r >= 0)
  802706:	83 c4 10             	add    $0x10,%esp
  802709:	85 c0                	test   %eax,%eax
  80270b:	79 1e                	jns    80272b <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  80270d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802710:	74 12                	je     802724 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  802712:	50                   	push   %eax
  802713:	68 ca 3f 80 00       	push   $0x803fca
  802718:	6a 49                	push   $0x49
  80271a:	68 dd 3f 80 00       	push   $0x803fdd
  80271f:	e8 0d f2 ff ff       	call   801931 <_panic>
	
		sys_yield();
  802724:	e8 c9 fc ff ff       	call   8023f2 <sys_yield>
	}
  802729:	eb d0                	jmp    8026fb <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  80272b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80272e:	5b                   	pop    %ebx
  80272f:	5e                   	pop    %esi
  802730:	5f                   	pop    %edi
  802731:	5d                   	pop    %ebp
  802732:	c3                   	ret    

00802733 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802733:	55                   	push   %ebp
  802734:	89 e5                	mov    %esp,%ebp
  802736:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802739:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80273e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802741:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802747:	8b 52 50             	mov    0x50(%edx),%edx
  80274a:	39 ca                	cmp    %ecx,%edx
  80274c:	75 0d                	jne    80275b <ipc_find_env+0x28>
			return envs[i].env_id;
  80274e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802751:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802756:	8b 40 48             	mov    0x48(%eax),%eax
  802759:	eb 0f                	jmp    80276a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80275b:	83 c0 01             	add    $0x1,%eax
  80275e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802763:	75 d9                	jne    80273e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802765:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80276a:	5d                   	pop    %ebp
  80276b:	c3                   	ret    

0080276c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80276c:	55                   	push   %ebp
  80276d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80276f:	8b 45 08             	mov    0x8(%ebp),%eax
  802772:	05 00 00 00 30       	add    $0x30000000,%eax
  802777:	c1 e8 0c             	shr    $0xc,%eax
}
  80277a:	5d                   	pop    %ebp
  80277b:	c3                   	ret    

0080277c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80277c:	55                   	push   %ebp
  80277d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80277f:	8b 45 08             	mov    0x8(%ebp),%eax
  802782:	05 00 00 00 30       	add    $0x30000000,%eax
  802787:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80278c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802791:	5d                   	pop    %ebp
  802792:	c3                   	ret    

00802793 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802793:	55                   	push   %ebp
  802794:	89 e5                	mov    %esp,%ebp
  802796:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802799:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80279e:	89 c2                	mov    %eax,%edx
  8027a0:	c1 ea 16             	shr    $0x16,%edx
  8027a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8027aa:	f6 c2 01             	test   $0x1,%dl
  8027ad:	74 11                	je     8027c0 <fd_alloc+0x2d>
  8027af:	89 c2                	mov    %eax,%edx
  8027b1:	c1 ea 0c             	shr    $0xc,%edx
  8027b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8027bb:	f6 c2 01             	test   $0x1,%dl
  8027be:	75 09                	jne    8027c9 <fd_alloc+0x36>
			*fd_store = fd;
  8027c0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8027c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8027c7:	eb 17                	jmp    8027e0 <fd_alloc+0x4d>
  8027c9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8027ce:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8027d3:	75 c9                	jne    80279e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8027d5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8027db:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8027e0:	5d                   	pop    %ebp
  8027e1:	c3                   	ret    

008027e2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8027e2:	55                   	push   %ebp
  8027e3:	89 e5                	mov    %esp,%ebp
  8027e5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8027e8:	83 f8 1f             	cmp    $0x1f,%eax
  8027eb:	77 36                	ja     802823 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8027ed:	c1 e0 0c             	shl    $0xc,%eax
  8027f0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8027f5:	89 c2                	mov    %eax,%edx
  8027f7:	c1 ea 16             	shr    $0x16,%edx
  8027fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802801:	f6 c2 01             	test   $0x1,%dl
  802804:	74 24                	je     80282a <fd_lookup+0x48>
  802806:	89 c2                	mov    %eax,%edx
  802808:	c1 ea 0c             	shr    $0xc,%edx
  80280b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802812:	f6 c2 01             	test   $0x1,%dl
  802815:	74 1a                	je     802831 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80281a:	89 02                	mov    %eax,(%edx)
	return 0;
  80281c:	b8 00 00 00 00       	mov    $0x0,%eax
  802821:	eb 13                	jmp    802836 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802823:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802828:	eb 0c                	jmp    802836 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80282a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80282f:	eb 05                	jmp    802836 <fd_lookup+0x54>
  802831:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802836:	5d                   	pop    %ebp
  802837:	c3                   	ret    

00802838 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802838:	55                   	push   %ebp
  802839:	89 e5                	mov    %esp,%ebp
  80283b:	83 ec 08             	sub    $0x8,%esp
  80283e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802841:	ba 68 40 80 00       	mov    $0x804068,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802846:	eb 13                	jmp    80285b <dev_lookup+0x23>
  802848:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80284b:	39 08                	cmp    %ecx,(%eax)
  80284d:	75 0c                	jne    80285b <dev_lookup+0x23>
			*dev = devtab[i];
  80284f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802852:	89 01                	mov    %eax,(%ecx)
			return 0;
  802854:	b8 00 00 00 00       	mov    $0x0,%eax
  802859:	eb 2e                	jmp    802889 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80285b:	8b 02                	mov    (%edx),%eax
  80285d:	85 c0                	test   %eax,%eax
  80285f:	75 e7                	jne    802848 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802861:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802866:	8b 40 48             	mov    0x48(%eax),%eax
  802869:	83 ec 04             	sub    $0x4,%esp
  80286c:	51                   	push   %ecx
  80286d:	50                   	push   %eax
  80286e:	68 e8 3f 80 00       	push   $0x803fe8
  802873:	e8 92 f1 ff ff       	call   801a0a <cprintf>
	*dev = 0;
  802878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80287b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802881:	83 c4 10             	add    $0x10,%esp
  802884:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802889:	c9                   	leave  
  80288a:	c3                   	ret    

0080288b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80288b:	55                   	push   %ebp
  80288c:	89 e5                	mov    %esp,%ebp
  80288e:	56                   	push   %esi
  80288f:	53                   	push   %ebx
  802890:	83 ec 10             	sub    $0x10,%esp
  802893:	8b 75 08             	mov    0x8(%ebp),%esi
  802896:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802899:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80289c:	50                   	push   %eax
  80289d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8028a3:	c1 e8 0c             	shr    $0xc,%eax
  8028a6:	50                   	push   %eax
  8028a7:	e8 36 ff ff ff       	call   8027e2 <fd_lookup>
  8028ac:	83 c4 08             	add    $0x8,%esp
  8028af:	85 c0                	test   %eax,%eax
  8028b1:	78 05                	js     8028b8 <fd_close+0x2d>
	    || fd != fd2)
  8028b3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8028b6:	74 0c                	je     8028c4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8028b8:	84 db                	test   %bl,%bl
  8028ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8028bf:	0f 44 c2             	cmove  %edx,%eax
  8028c2:	eb 41                	jmp    802905 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8028c4:	83 ec 08             	sub    $0x8,%esp
  8028c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028ca:	50                   	push   %eax
  8028cb:	ff 36                	pushl  (%esi)
  8028cd:	e8 66 ff ff ff       	call   802838 <dev_lookup>
  8028d2:	89 c3                	mov    %eax,%ebx
  8028d4:	83 c4 10             	add    $0x10,%esp
  8028d7:	85 c0                	test   %eax,%eax
  8028d9:	78 1a                	js     8028f5 <fd_close+0x6a>
		if (dev->dev_close)
  8028db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028de:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8028e1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8028e6:	85 c0                	test   %eax,%eax
  8028e8:	74 0b                	je     8028f5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8028ea:	83 ec 0c             	sub    $0xc,%esp
  8028ed:	56                   	push   %esi
  8028ee:	ff d0                	call   *%eax
  8028f0:	89 c3                	mov    %eax,%ebx
  8028f2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8028f5:	83 ec 08             	sub    $0x8,%esp
  8028f8:	56                   	push   %esi
  8028f9:	6a 00                	push   $0x0
  8028fb:	e8 96 fb ff ff       	call   802496 <sys_page_unmap>
	return r;
  802900:	83 c4 10             	add    $0x10,%esp
  802903:	89 d8                	mov    %ebx,%eax
}
  802905:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802908:	5b                   	pop    %ebx
  802909:	5e                   	pop    %esi
  80290a:	5d                   	pop    %ebp
  80290b:	c3                   	ret    

0080290c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80290c:	55                   	push   %ebp
  80290d:	89 e5                	mov    %esp,%ebp
  80290f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802912:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802915:	50                   	push   %eax
  802916:	ff 75 08             	pushl  0x8(%ebp)
  802919:	e8 c4 fe ff ff       	call   8027e2 <fd_lookup>
  80291e:	83 c4 08             	add    $0x8,%esp
  802921:	85 c0                	test   %eax,%eax
  802923:	78 10                	js     802935 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802925:	83 ec 08             	sub    $0x8,%esp
  802928:	6a 01                	push   $0x1
  80292a:	ff 75 f4             	pushl  -0xc(%ebp)
  80292d:	e8 59 ff ff ff       	call   80288b <fd_close>
  802932:	83 c4 10             	add    $0x10,%esp
}
  802935:	c9                   	leave  
  802936:	c3                   	ret    

00802937 <close_all>:

void
close_all(void)
{
  802937:	55                   	push   %ebp
  802938:	89 e5                	mov    %esp,%ebp
  80293a:	53                   	push   %ebx
  80293b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80293e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802943:	83 ec 0c             	sub    $0xc,%esp
  802946:	53                   	push   %ebx
  802947:	e8 c0 ff ff ff       	call   80290c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80294c:	83 c3 01             	add    $0x1,%ebx
  80294f:	83 c4 10             	add    $0x10,%esp
  802952:	83 fb 20             	cmp    $0x20,%ebx
  802955:	75 ec                	jne    802943 <close_all+0xc>
		close(i);
}
  802957:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80295a:	c9                   	leave  
  80295b:	c3                   	ret    

0080295c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80295c:	55                   	push   %ebp
  80295d:	89 e5                	mov    %esp,%ebp
  80295f:	57                   	push   %edi
  802960:	56                   	push   %esi
  802961:	53                   	push   %ebx
  802962:	83 ec 2c             	sub    $0x2c,%esp
  802965:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802968:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80296b:	50                   	push   %eax
  80296c:	ff 75 08             	pushl  0x8(%ebp)
  80296f:	e8 6e fe ff ff       	call   8027e2 <fd_lookup>
  802974:	83 c4 08             	add    $0x8,%esp
  802977:	85 c0                	test   %eax,%eax
  802979:	0f 88 c1 00 00 00    	js     802a40 <dup+0xe4>
		return r;
	close(newfdnum);
  80297f:	83 ec 0c             	sub    $0xc,%esp
  802982:	56                   	push   %esi
  802983:	e8 84 ff ff ff       	call   80290c <close>

	newfd = INDEX2FD(newfdnum);
  802988:	89 f3                	mov    %esi,%ebx
  80298a:	c1 e3 0c             	shl    $0xc,%ebx
  80298d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802993:	83 c4 04             	add    $0x4,%esp
  802996:	ff 75 e4             	pushl  -0x1c(%ebp)
  802999:	e8 de fd ff ff       	call   80277c <fd2data>
  80299e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8029a0:	89 1c 24             	mov    %ebx,(%esp)
  8029a3:	e8 d4 fd ff ff       	call   80277c <fd2data>
  8029a8:	83 c4 10             	add    $0x10,%esp
  8029ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8029ae:	89 f8                	mov    %edi,%eax
  8029b0:	c1 e8 16             	shr    $0x16,%eax
  8029b3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029ba:	a8 01                	test   $0x1,%al
  8029bc:	74 37                	je     8029f5 <dup+0x99>
  8029be:	89 f8                	mov    %edi,%eax
  8029c0:	c1 e8 0c             	shr    $0xc,%eax
  8029c3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029ca:	f6 c2 01             	test   $0x1,%dl
  8029cd:	74 26                	je     8029f5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8029cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029d6:	83 ec 0c             	sub    $0xc,%esp
  8029d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8029de:	50                   	push   %eax
  8029df:	ff 75 d4             	pushl  -0x2c(%ebp)
  8029e2:	6a 00                	push   $0x0
  8029e4:	57                   	push   %edi
  8029e5:	6a 00                	push   $0x0
  8029e7:	e8 68 fa ff ff       	call   802454 <sys_page_map>
  8029ec:	89 c7                	mov    %eax,%edi
  8029ee:	83 c4 20             	add    $0x20,%esp
  8029f1:	85 c0                	test   %eax,%eax
  8029f3:	78 2e                	js     802a23 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8029f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8029f8:	89 d0                	mov    %edx,%eax
  8029fa:	c1 e8 0c             	shr    $0xc,%eax
  8029fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a04:	83 ec 0c             	sub    $0xc,%esp
  802a07:	25 07 0e 00 00       	and    $0xe07,%eax
  802a0c:	50                   	push   %eax
  802a0d:	53                   	push   %ebx
  802a0e:	6a 00                	push   $0x0
  802a10:	52                   	push   %edx
  802a11:	6a 00                	push   $0x0
  802a13:	e8 3c fa ff ff       	call   802454 <sys_page_map>
  802a18:	89 c7                	mov    %eax,%edi
  802a1a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802a1d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a1f:	85 ff                	test   %edi,%edi
  802a21:	79 1d                	jns    802a40 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802a23:	83 ec 08             	sub    $0x8,%esp
  802a26:	53                   	push   %ebx
  802a27:	6a 00                	push   $0x0
  802a29:	e8 68 fa ff ff       	call   802496 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802a2e:	83 c4 08             	add    $0x8,%esp
  802a31:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a34:	6a 00                	push   $0x0
  802a36:	e8 5b fa ff ff       	call   802496 <sys_page_unmap>
	return r;
  802a3b:	83 c4 10             	add    $0x10,%esp
  802a3e:	89 f8                	mov    %edi,%eax
}
  802a40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a43:	5b                   	pop    %ebx
  802a44:	5e                   	pop    %esi
  802a45:	5f                   	pop    %edi
  802a46:	5d                   	pop    %ebp
  802a47:	c3                   	ret    

00802a48 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802a48:	55                   	push   %ebp
  802a49:	89 e5                	mov    %esp,%ebp
  802a4b:	53                   	push   %ebx
  802a4c:	83 ec 14             	sub    $0x14,%esp
  802a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802a52:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a55:	50                   	push   %eax
  802a56:	53                   	push   %ebx
  802a57:	e8 86 fd ff ff       	call   8027e2 <fd_lookup>
  802a5c:	83 c4 08             	add    $0x8,%esp
  802a5f:	89 c2                	mov    %eax,%edx
  802a61:	85 c0                	test   %eax,%eax
  802a63:	78 6d                	js     802ad2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802a65:	83 ec 08             	sub    $0x8,%esp
  802a68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a6b:	50                   	push   %eax
  802a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a6f:	ff 30                	pushl  (%eax)
  802a71:	e8 c2 fd ff ff       	call   802838 <dev_lookup>
  802a76:	83 c4 10             	add    $0x10,%esp
  802a79:	85 c0                	test   %eax,%eax
  802a7b:	78 4c                	js     802ac9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802a7d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a80:	8b 42 08             	mov    0x8(%edx),%eax
  802a83:	83 e0 03             	and    $0x3,%eax
  802a86:	83 f8 01             	cmp    $0x1,%eax
  802a89:	75 21                	jne    802aac <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802a8b:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802a90:	8b 40 48             	mov    0x48(%eax),%eax
  802a93:	83 ec 04             	sub    $0x4,%esp
  802a96:	53                   	push   %ebx
  802a97:	50                   	push   %eax
  802a98:	68 2c 40 80 00       	push   $0x80402c
  802a9d:	e8 68 ef ff ff       	call   801a0a <cprintf>
		return -E_INVAL;
  802aa2:	83 c4 10             	add    $0x10,%esp
  802aa5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802aaa:	eb 26                	jmp    802ad2 <read+0x8a>
	}
	if (!dev->dev_read)
  802aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802aaf:	8b 40 08             	mov    0x8(%eax),%eax
  802ab2:	85 c0                	test   %eax,%eax
  802ab4:	74 17                	je     802acd <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802ab6:	83 ec 04             	sub    $0x4,%esp
  802ab9:	ff 75 10             	pushl  0x10(%ebp)
  802abc:	ff 75 0c             	pushl  0xc(%ebp)
  802abf:	52                   	push   %edx
  802ac0:	ff d0                	call   *%eax
  802ac2:	89 c2                	mov    %eax,%edx
  802ac4:	83 c4 10             	add    $0x10,%esp
  802ac7:	eb 09                	jmp    802ad2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ac9:	89 c2                	mov    %eax,%edx
  802acb:	eb 05                	jmp    802ad2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802acd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802ad2:	89 d0                	mov    %edx,%eax
  802ad4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ad7:	c9                   	leave  
  802ad8:	c3                   	ret    

00802ad9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802ad9:	55                   	push   %ebp
  802ada:	89 e5                	mov    %esp,%ebp
  802adc:	57                   	push   %edi
  802add:	56                   	push   %esi
  802ade:	53                   	push   %ebx
  802adf:	83 ec 0c             	sub    $0xc,%esp
  802ae2:	8b 7d 08             	mov    0x8(%ebp),%edi
  802ae5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802ae8:	bb 00 00 00 00       	mov    $0x0,%ebx
  802aed:	eb 21                	jmp    802b10 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802aef:	83 ec 04             	sub    $0x4,%esp
  802af2:	89 f0                	mov    %esi,%eax
  802af4:	29 d8                	sub    %ebx,%eax
  802af6:	50                   	push   %eax
  802af7:	89 d8                	mov    %ebx,%eax
  802af9:	03 45 0c             	add    0xc(%ebp),%eax
  802afc:	50                   	push   %eax
  802afd:	57                   	push   %edi
  802afe:	e8 45 ff ff ff       	call   802a48 <read>
		if (m < 0)
  802b03:	83 c4 10             	add    $0x10,%esp
  802b06:	85 c0                	test   %eax,%eax
  802b08:	78 10                	js     802b1a <readn+0x41>
			return m;
		if (m == 0)
  802b0a:	85 c0                	test   %eax,%eax
  802b0c:	74 0a                	je     802b18 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b0e:	01 c3                	add    %eax,%ebx
  802b10:	39 f3                	cmp    %esi,%ebx
  802b12:	72 db                	jb     802aef <readn+0x16>
  802b14:	89 d8                	mov    %ebx,%eax
  802b16:	eb 02                	jmp    802b1a <readn+0x41>
  802b18:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b1d:	5b                   	pop    %ebx
  802b1e:	5e                   	pop    %esi
  802b1f:	5f                   	pop    %edi
  802b20:	5d                   	pop    %ebp
  802b21:	c3                   	ret    

00802b22 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802b22:	55                   	push   %ebp
  802b23:	89 e5                	mov    %esp,%ebp
  802b25:	53                   	push   %ebx
  802b26:	83 ec 14             	sub    $0x14,%esp
  802b29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b2f:	50                   	push   %eax
  802b30:	53                   	push   %ebx
  802b31:	e8 ac fc ff ff       	call   8027e2 <fd_lookup>
  802b36:	83 c4 08             	add    $0x8,%esp
  802b39:	89 c2                	mov    %eax,%edx
  802b3b:	85 c0                	test   %eax,%eax
  802b3d:	78 68                	js     802ba7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b3f:	83 ec 08             	sub    $0x8,%esp
  802b42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b45:	50                   	push   %eax
  802b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b49:	ff 30                	pushl  (%eax)
  802b4b:	e8 e8 fc ff ff       	call   802838 <dev_lookup>
  802b50:	83 c4 10             	add    $0x10,%esp
  802b53:	85 c0                	test   %eax,%eax
  802b55:	78 47                	js     802b9e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b5a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802b5e:	75 21                	jne    802b81 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802b60:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b65:	8b 40 48             	mov    0x48(%eax),%eax
  802b68:	83 ec 04             	sub    $0x4,%esp
  802b6b:	53                   	push   %ebx
  802b6c:	50                   	push   %eax
  802b6d:	68 48 40 80 00       	push   $0x804048
  802b72:	e8 93 ee ff ff       	call   801a0a <cprintf>
		return -E_INVAL;
  802b77:	83 c4 10             	add    $0x10,%esp
  802b7a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802b7f:	eb 26                	jmp    802ba7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802b81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802b84:	8b 52 0c             	mov    0xc(%edx),%edx
  802b87:	85 d2                	test   %edx,%edx
  802b89:	74 17                	je     802ba2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802b8b:	83 ec 04             	sub    $0x4,%esp
  802b8e:	ff 75 10             	pushl  0x10(%ebp)
  802b91:	ff 75 0c             	pushl  0xc(%ebp)
  802b94:	50                   	push   %eax
  802b95:	ff d2                	call   *%edx
  802b97:	89 c2                	mov    %eax,%edx
  802b99:	83 c4 10             	add    $0x10,%esp
  802b9c:	eb 09                	jmp    802ba7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b9e:	89 c2                	mov    %eax,%edx
  802ba0:	eb 05                	jmp    802ba7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802ba2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802ba7:	89 d0                	mov    %edx,%eax
  802ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bac:	c9                   	leave  
  802bad:	c3                   	ret    

00802bae <seek>:

int
seek(int fdnum, off_t offset)
{
  802bae:	55                   	push   %ebp
  802baf:	89 e5                	mov    %esp,%ebp
  802bb1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802bb4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802bb7:	50                   	push   %eax
  802bb8:	ff 75 08             	pushl  0x8(%ebp)
  802bbb:	e8 22 fc ff ff       	call   8027e2 <fd_lookup>
  802bc0:	83 c4 08             	add    $0x8,%esp
  802bc3:	85 c0                	test   %eax,%eax
  802bc5:	78 0e                	js     802bd5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802bc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802bca:	8b 55 0c             	mov    0xc(%ebp),%edx
  802bcd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802bd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bd5:	c9                   	leave  
  802bd6:	c3                   	ret    

00802bd7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802bd7:	55                   	push   %ebp
  802bd8:	89 e5                	mov    %esp,%ebp
  802bda:	53                   	push   %ebx
  802bdb:	83 ec 14             	sub    $0x14,%esp
  802bde:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802be1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802be4:	50                   	push   %eax
  802be5:	53                   	push   %ebx
  802be6:	e8 f7 fb ff ff       	call   8027e2 <fd_lookup>
  802beb:	83 c4 08             	add    $0x8,%esp
  802bee:	89 c2                	mov    %eax,%edx
  802bf0:	85 c0                	test   %eax,%eax
  802bf2:	78 65                	js     802c59 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bf4:	83 ec 08             	sub    $0x8,%esp
  802bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bfa:	50                   	push   %eax
  802bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bfe:	ff 30                	pushl  (%eax)
  802c00:	e8 33 fc ff ff       	call   802838 <dev_lookup>
  802c05:	83 c4 10             	add    $0x10,%esp
  802c08:	85 c0                	test   %eax,%eax
  802c0a:	78 44                	js     802c50 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c0f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c13:	75 21                	jne    802c36 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802c15:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802c1a:	8b 40 48             	mov    0x48(%eax),%eax
  802c1d:	83 ec 04             	sub    $0x4,%esp
  802c20:	53                   	push   %ebx
  802c21:	50                   	push   %eax
  802c22:	68 08 40 80 00       	push   $0x804008
  802c27:	e8 de ed ff ff       	call   801a0a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802c2c:	83 c4 10             	add    $0x10,%esp
  802c2f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c34:	eb 23                	jmp    802c59 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802c36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c39:	8b 52 18             	mov    0x18(%edx),%edx
  802c3c:	85 d2                	test   %edx,%edx
  802c3e:	74 14                	je     802c54 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802c40:	83 ec 08             	sub    $0x8,%esp
  802c43:	ff 75 0c             	pushl  0xc(%ebp)
  802c46:	50                   	push   %eax
  802c47:	ff d2                	call   *%edx
  802c49:	89 c2                	mov    %eax,%edx
  802c4b:	83 c4 10             	add    $0x10,%esp
  802c4e:	eb 09                	jmp    802c59 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c50:	89 c2                	mov    %eax,%edx
  802c52:	eb 05                	jmp    802c59 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802c54:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802c59:	89 d0                	mov    %edx,%eax
  802c5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c5e:	c9                   	leave  
  802c5f:	c3                   	ret    

00802c60 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802c60:	55                   	push   %ebp
  802c61:	89 e5                	mov    %esp,%ebp
  802c63:	53                   	push   %ebx
  802c64:	83 ec 14             	sub    $0x14,%esp
  802c67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c6d:	50                   	push   %eax
  802c6e:	ff 75 08             	pushl  0x8(%ebp)
  802c71:	e8 6c fb ff ff       	call   8027e2 <fd_lookup>
  802c76:	83 c4 08             	add    $0x8,%esp
  802c79:	89 c2                	mov    %eax,%edx
  802c7b:	85 c0                	test   %eax,%eax
  802c7d:	78 58                	js     802cd7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c7f:	83 ec 08             	sub    $0x8,%esp
  802c82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c85:	50                   	push   %eax
  802c86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c89:	ff 30                	pushl  (%eax)
  802c8b:	e8 a8 fb ff ff       	call   802838 <dev_lookup>
  802c90:	83 c4 10             	add    $0x10,%esp
  802c93:	85 c0                	test   %eax,%eax
  802c95:	78 37                	js     802cce <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c9a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802c9e:	74 32                	je     802cd2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802ca0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802ca3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802caa:	00 00 00 
	stat->st_isdir = 0;
  802cad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802cb4:	00 00 00 
	stat->st_dev = dev;
  802cb7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802cbd:	83 ec 08             	sub    $0x8,%esp
  802cc0:	53                   	push   %ebx
  802cc1:	ff 75 f0             	pushl  -0x10(%ebp)
  802cc4:	ff 50 14             	call   *0x14(%eax)
  802cc7:	89 c2                	mov    %eax,%edx
  802cc9:	83 c4 10             	add    $0x10,%esp
  802ccc:	eb 09                	jmp    802cd7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cce:	89 c2                	mov    %eax,%edx
  802cd0:	eb 05                	jmp    802cd7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802cd2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802cd7:	89 d0                	mov    %edx,%eax
  802cd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cdc:	c9                   	leave  
  802cdd:	c3                   	ret    

00802cde <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802cde:	55                   	push   %ebp
  802cdf:	89 e5                	mov    %esp,%ebp
  802ce1:	56                   	push   %esi
  802ce2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802ce3:	83 ec 08             	sub    $0x8,%esp
  802ce6:	6a 00                	push   $0x0
  802ce8:	ff 75 08             	pushl  0x8(%ebp)
  802ceb:	e8 e3 01 00 00       	call   802ed3 <open>
  802cf0:	89 c3                	mov    %eax,%ebx
  802cf2:	83 c4 10             	add    $0x10,%esp
  802cf5:	85 c0                	test   %eax,%eax
  802cf7:	78 1b                	js     802d14 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802cf9:	83 ec 08             	sub    $0x8,%esp
  802cfc:	ff 75 0c             	pushl  0xc(%ebp)
  802cff:	50                   	push   %eax
  802d00:	e8 5b ff ff ff       	call   802c60 <fstat>
  802d05:	89 c6                	mov    %eax,%esi
	close(fd);
  802d07:	89 1c 24             	mov    %ebx,(%esp)
  802d0a:	e8 fd fb ff ff       	call   80290c <close>
	return r;
  802d0f:	83 c4 10             	add    $0x10,%esp
  802d12:	89 f0                	mov    %esi,%eax
}
  802d14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d17:	5b                   	pop    %ebx
  802d18:	5e                   	pop    %esi
  802d19:	5d                   	pop    %ebp
  802d1a:	c3                   	ret    

00802d1b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802d1b:	55                   	push   %ebp
  802d1c:	89 e5                	mov    %esp,%ebp
  802d1e:	56                   	push   %esi
  802d1f:	53                   	push   %ebx
  802d20:	89 c6                	mov    %eax,%esi
  802d22:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802d24:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802d2b:	75 12                	jne    802d3f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802d2d:	83 ec 0c             	sub    $0xc,%esp
  802d30:	6a 01                	push   $0x1
  802d32:	e8 fc f9 ff ff       	call   802733 <ipc_find_env>
  802d37:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802d3c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802d3f:	6a 07                	push   $0x7
  802d41:	68 00 b0 80 00       	push   $0x80b000
  802d46:	56                   	push   %esi
  802d47:	ff 35 00 a0 80 00    	pushl  0x80a000
  802d4d:	e8 8d f9 ff ff       	call   8026df <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802d52:	83 c4 0c             	add    $0xc,%esp
  802d55:	6a 00                	push   $0x0
  802d57:	53                   	push   %ebx
  802d58:	6a 00                	push   $0x0
  802d5a:	e8 0e f9 ff ff       	call   80266d <ipc_recv>
}
  802d5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d62:	5b                   	pop    %ebx
  802d63:	5e                   	pop    %esi
  802d64:	5d                   	pop    %ebp
  802d65:	c3                   	ret    

00802d66 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802d66:	55                   	push   %ebp
  802d67:	89 e5                	mov    %esp,%ebp
  802d69:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  802d6f:	8b 40 0c             	mov    0xc(%eax),%eax
  802d72:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d7a:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  802d84:	b8 02 00 00 00       	mov    $0x2,%eax
  802d89:	e8 8d ff ff ff       	call   802d1b <fsipc>
}
  802d8e:	c9                   	leave  
  802d8f:	c3                   	ret    

00802d90 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802d90:	55                   	push   %ebp
  802d91:	89 e5                	mov    %esp,%ebp
  802d93:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802d96:	8b 45 08             	mov    0x8(%ebp),%eax
  802d99:	8b 40 0c             	mov    0xc(%eax),%eax
  802d9c:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802da1:	ba 00 00 00 00       	mov    $0x0,%edx
  802da6:	b8 06 00 00 00       	mov    $0x6,%eax
  802dab:	e8 6b ff ff ff       	call   802d1b <fsipc>
}
  802db0:	c9                   	leave  
  802db1:	c3                   	ret    

00802db2 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802db2:	55                   	push   %ebp
  802db3:	89 e5                	mov    %esp,%ebp
  802db5:	53                   	push   %ebx
  802db6:	83 ec 04             	sub    $0x4,%esp
  802db9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  802dbf:	8b 40 0c             	mov    0xc(%eax),%eax
  802dc2:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802dc7:	ba 00 00 00 00       	mov    $0x0,%edx
  802dcc:	b8 05 00 00 00       	mov    $0x5,%eax
  802dd1:	e8 45 ff ff ff       	call   802d1b <fsipc>
  802dd6:	85 c0                	test   %eax,%eax
  802dd8:	78 2c                	js     802e06 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802dda:	83 ec 08             	sub    $0x8,%esp
  802ddd:	68 00 b0 80 00       	push   $0x80b000
  802de2:	53                   	push   %ebx
  802de3:	e8 26 f2 ff ff       	call   80200e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802de8:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802ded:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802df3:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802df8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802dfe:	83 c4 10             	add    $0x10,%esp
  802e01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e09:	c9                   	leave  
  802e0a:	c3                   	ret    

00802e0b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802e0b:	55                   	push   %ebp
  802e0c:	89 e5                	mov    %esp,%ebp
  802e0e:	83 ec 0c             	sub    $0xc,%esp
  802e11:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  802e14:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802e19:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802e1e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802e21:	8b 55 08             	mov    0x8(%ebp),%edx
  802e24:	8b 52 0c             	mov    0xc(%edx),%edx
  802e27:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802e2d:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802e32:	50                   	push   %eax
  802e33:	ff 75 0c             	pushl  0xc(%ebp)
  802e36:	68 08 b0 80 00       	push   $0x80b008
  802e3b:	e8 60 f3 ff ff       	call   8021a0 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  802e40:	ba 00 00 00 00       	mov    $0x0,%edx
  802e45:	b8 04 00 00 00       	mov    $0x4,%eax
  802e4a:	e8 cc fe ff ff       	call   802d1b <fsipc>
}
  802e4f:	c9                   	leave  
  802e50:	c3                   	ret    

00802e51 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802e51:	55                   	push   %ebp
  802e52:	89 e5                	mov    %esp,%ebp
  802e54:	56                   	push   %esi
  802e55:	53                   	push   %ebx
  802e56:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802e59:	8b 45 08             	mov    0x8(%ebp),%eax
  802e5c:	8b 40 0c             	mov    0xc(%eax),%eax
  802e5f:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802e64:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802e6a:	ba 00 00 00 00       	mov    $0x0,%edx
  802e6f:	b8 03 00 00 00       	mov    $0x3,%eax
  802e74:	e8 a2 fe ff ff       	call   802d1b <fsipc>
  802e79:	89 c3                	mov    %eax,%ebx
  802e7b:	85 c0                	test   %eax,%eax
  802e7d:	78 4b                	js     802eca <devfile_read+0x79>
		return r;
	assert(r <= n);
  802e7f:	39 c6                	cmp    %eax,%esi
  802e81:	73 16                	jae    802e99 <devfile_read+0x48>
  802e83:	68 78 40 80 00       	push   $0x804078
  802e88:	68 7d 37 80 00       	push   $0x80377d
  802e8d:	6a 7c                	push   $0x7c
  802e8f:	68 7f 40 80 00       	push   $0x80407f
  802e94:	e8 98 ea ff ff       	call   801931 <_panic>
	assert(r <= PGSIZE);
  802e99:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802e9e:	7e 16                	jle    802eb6 <devfile_read+0x65>
  802ea0:	68 8a 40 80 00       	push   $0x80408a
  802ea5:	68 7d 37 80 00       	push   $0x80377d
  802eaa:	6a 7d                	push   $0x7d
  802eac:	68 7f 40 80 00       	push   $0x80407f
  802eb1:	e8 7b ea ff ff       	call   801931 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802eb6:	83 ec 04             	sub    $0x4,%esp
  802eb9:	50                   	push   %eax
  802eba:	68 00 b0 80 00       	push   $0x80b000
  802ebf:	ff 75 0c             	pushl  0xc(%ebp)
  802ec2:	e8 d9 f2 ff ff       	call   8021a0 <memmove>
	return r;
  802ec7:	83 c4 10             	add    $0x10,%esp
}
  802eca:	89 d8                	mov    %ebx,%eax
  802ecc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ecf:	5b                   	pop    %ebx
  802ed0:	5e                   	pop    %esi
  802ed1:	5d                   	pop    %ebp
  802ed2:	c3                   	ret    

00802ed3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802ed3:	55                   	push   %ebp
  802ed4:	89 e5                	mov    %esp,%ebp
  802ed6:	53                   	push   %ebx
  802ed7:	83 ec 20             	sub    $0x20,%esp
  802eda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802edd:	53                   	push   %ebx
  802ede:	e8 f2 f0 ff ff       	call   801fd5 <strlen>
  802ee3:	83 c4 10             	add    $0x10,%esp
  802ee6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802eeb:	7f 67                	jg     802f54 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802eed:	83 ec 0c             	sub    $0xc,%esp
  802ef0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ef3:	50                   	push   %eax
  802ef4:	e8 9a f8 ff ff       	call   802793 <fd_alloc>
  802ef9:	83 c4 10             	add    $0x10,%esp
		return r;
  802efc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802efe:	85 c0                	test   %eax,%eax
  802f00:	78 57                	js     802f59 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802f02:	83 ec 08             	sub    $0x8,%esp
  802f05:	53                   	push   %ebx
  802f06:	68 00 b0 80 00       	push   $0x80b000
  802f0b:	e8 fe f0 ff ff       	call   80200e <strcpy>
	fsipcbuf.open.req_omode = mode;
  802f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f13:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802f18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f1b:	b8 01 00 00 00       	mov    $0x1,%eax
  802f20:	e8 f6 fd ff ff       	call   802d1b <fsipc>
  802f25:	89 c3                	mov    %eax,%ebx
  802f27:	83 c4 10             	add    $0x10,%esp
  802f2a:	85 c0                	test   %eax,%eax
  802f2c:	79 14                	jns    802f42 <open+0x6f>
		fd_close(fd, 0);
  802f2e:	83 ec 08             	sub    $0x8,%esp
  802f31:	6a 00                	push   $0x0
  802f33:	ff 75 f4             	pushl  -0xc(%ebp)
  802f36:	e8 50 f9 ff ff       	call   80288b <fd_close>
		return r;
  802f3b:	83 c4 10             	add    $0x10,%esp
  802f3e:	89 da                	mov    %ebx,%edx
  802f40:	eb 17                	jmp    802f59 <open+0x86>
	}

	return fd2num(fd);
  802f42:	83 ec 0c             	sub    $0xc,%esp
  802f45:	ff 75 f4             	pushl  -0xc(%ebp)
  802f48:	e8 1f f8 ff ff       	call   80276c <fd2num>
  802f4d:	89 c2                	mov    %eax,%edx
  802f4f:	83 c4 10             	add    $0x10,%esp
  802f52:	eb 05                	jmp    802f59 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802f54:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802f59:	89 d0                	mov    %edx,%eax
  802f5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f5e:	c9                   	leave  
  802f5f:	c3                   	ret    

00802f60 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802f60:	55                   	push   %ebp
  802f61:	89 e5                	mov    %esp,%ebp
  802f63:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802f66:	ba 00 00 00 00       	mov    $0x0,%edx
  802f6b:	b8 08 00 00 00       	mov    $0x8,%eax
  802f70:	e8 a6 fd ff ff       	call   802d1b <fsipc>
}
  802f75:	c9                   	leave  
  802f76:	c3                   	ret    

00802f77 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f77:	55                   	push   %ebp
  802f78:	89 e5                	mov    %esp,%ebp
  802f7a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f7d:	89 d0                	mov    %edx,%eax
  802f7f:	c1 e8 16             	shr    $0x16,%eax
  802f82:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802f89:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f8e:	f6 c1 01             	test   $0x1,%cl
  802f91:	74 1d                	je     802fb0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802f93:	c1 ea 0c             	shr    $0xc,%edx
  802f96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802f9d:	f6 c2 01             	test   $0x1,%dl
  802fa0:	74 0e                	je     802fb0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802fa2:	c1 ea 0c             	shr    $0xc,%edx
  802fa5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802fac:	ef 
  802fad:	0f b7 c0             	movzwl %ax,%eax
}
  802fb0:	5d                   	pop    %ebp
  802fb1:	c3                   	ret    

00802fb2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802fb2:	55                   	push   %ebp
  802fb3:	89 e5                	mov    %esp,%ebp
  802fb5:	56                   	push   %esi
  802fb6:	53                   	push   %ebx
  802fb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802fba:	83 ec 0c             	sub    $0xc,%esp
  802fbd:	ff 75 08             	pushl  0x8(%ebp)
  802fc0:	e8 b7 f7 ff ff       	call   80277c <fd2data>
  802fc5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802fc7:	83 c4 08             	add    $0x8,%esp
  802fca:	68 96 40 80 00       	push   $0x804096
  802fcf:	53                   	push   %ebx
  802fd0:	e8 39 f0 ff ff       	call   80200e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802fd5:	8b 46 04             	mov    0x4(%esi),%eax
  802fd8:	2b 06                	sub    (%esi),%eax
  802fda:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802fe0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802fe7:	00 00 00 
	stat->st_dev = &devpipe;
  802fea:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  802ff1:	90 80 00 
	return 0;
}
  802ff4:	b8 00 00 00 00       	mov    $0x0,%eax
  802ff9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ffc:	5b                   	pop    %ebx
  802ffd:	5e                   	pop    %esi
  802ffe:	5d                   	pop    %ebp
  802fff:	c3                   	ret    

00803000 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803000:	55                   	push   %ebp
  803001:	89 e5                	mov    %esp,%ebp
  803003:	53                   	push   %ebx
  803004:	83 ec 0c             	sub    $0xc,%esp
  803007:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80300a:	53                   	push   %ebx
  80300b:	6a 00                	push   $0x0
  80300d:	e8 84 f4 ff ff       	call   802496 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803012:	89 1c 24             	mov    %ebx,(%esp)
  803015:	e8 62 f7 ff ff       	call   80277c <fd2data>
  80301a:	83 c4 08             	add    $0x8,%esp
  80301d:	50                   	push   %eax
  80301e:	6a 00                	push   $0x0
  803020:	e8 71 f4 ff ff       	call   802496 <sys_page_unmap>
}
  803025:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803028:	c9                   	leave  
  803029:	c3                   	ret    

0080302a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80302a:	55                   	push   %ebp
  80302b:	89 e5                	mov    %esp,%ebp
  80302d:	57                   	push   %edi
  80302e:	56                   	push   %esi
  80302f:	53                   	push   %ebx
  803030:	83 ec 1c             	sub    $0x1c,%esp
  803033:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803036:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803038:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80303d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  803040:	83 ec 0c             	sub    $0xc,%esp
  803043:	ff 75 e0             	pushl  -0x20(%ebp)
  803046:	e8 2c ff ff ff       	call   802f77 <pageref>
  80304b:	89 c3                	mov    %eax,%ebx
  80304d:	89 3c 24             	mov    %edi,(%esp)
  803050:	e8 22 ff ff ff       	call   802f77 <pageref>
  803055:	83 c4 10             	add    $0x10,%esp
  803058:	39 c3                	cmp    %eax,%ebx
  80305a:	0f 94 c1             	sete   %cl
  80305d:	0f b6 c9             	movzbl %cl,%ecx
  803060:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  803063:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803069:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80306c:	39 ce                	cmp    %ecx,%esi
  80306e:	74 1b                	je     80308b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  803070:	39 c3                	cmp    %eax,%ebx
  803072:	75 c4                	jne    803038 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803074:	8b 42 58             	mov    0x58(%edx),%eax
  803077:	ff 75 e4             	pushl  -0x1c(%ebp)
  80307a:	50                   	push   %eax
  80307b:	56                   	push   %esi
  80307c:	68 9d 40 80 00       	push   $0x80409d
  803081:	e8 84 e9 ff ff       	call   801a0a <cprintf>
  803086:	83 c4 10             	add    $0x10,%esp
  803089:	eb ad                	jmp    803038 <_pipeisclosed+0xe>
	}
}
  80308b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80308e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803091:	5b                   	pop    %ebx
  803092:	5e                   	pop    %esi
  803093:	5f                   	pop    %edi
  803094:	5d                   	pop    %ebp
  803095:	c3                   	ret    

00803096 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803096:	55                   	push   %ebp
  803097:	89 e5                	mov    %esp,%ebp
  803099:	57                   	push   %edi
  80309a:	56                   	push   %esi
  80309b:	53                   	push   %ebx
  80309c:	83 ec 28             	sub    $0x28,%esp
  80309f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8030a2:	56                   	push   %esi
  8030a3:	e8 d4 f6 ff ff       	call   80277c <fd2data>
  8030a8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030aa:	83 c4 10             	add    $0x10,%esp
  8030ad:	bf 00 00 00 00       	mov    $0x0,%edi
  8030b2:	eb 4b                	jmp    8030ff <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8030b4:	89 da                	mov    %ebx,%edx
  8030b6:	89 f0                	mov    %esi,%eax
  8030b8:	e8 6d ff ff ff       	call   80302a <_pipeisclosed>
  8030bd:	85 c0                	test   %eax,%eax
  8030bf:	75 48                	jne    803109 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8030c1:	e8 2c f3 ff ff       	call   8023f2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8030c6:	8b 43 04             	mov    0x4(%ebx),%eax
  8030c9:	8b 0b                	mov    (%ebx),%ecx
  8030cb:	8d 51 20             	lea    0x20(%ecx),%edx
  8030ce:	39 d0                	cmp    %edx,%eax
  8030d0:	73 e2                	jae    8030b4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8030d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030d5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8030d9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8030dc:	89 c2                	mov    %eax,%edx
  8030de:	c1 fa 1f             	sar    $0x1f,%edx
  8030e1:	89 d1                	mov    %edx,%ecx
  8030e3:	c1 e9 1b             	shr    $0x1b,%ecx
  8030e6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8030e9:	83 e2 1f             	and    $0x1f,%edx
  8030ec:	29 ca                	sub    %ecx,%edx
  8030ee:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8030f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8030f6:	83 c0 01             	add    $0x1,%eax
  8030f9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030fc:	83 c7 01             	add    $0x1,%edi
  8030ff:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803102:	75 c2                	jne    8030c6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803104:	8b 45 10             	mov    0x10(%ebp),%eax
  803107:	eb 05                	jmp    80310e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803109:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80310e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803111:	5b                   	pop    %ebx
  803112:	5e                   	pop    %esi
  803113:	5f                   	pop    %edi
  803114:	5d                   	pop    %ebp
  803115:	c3                   	ret    

00803116 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803116:	55                   	push   %ebp
  803117:	89 e5                	mov    %esp,%ebp
  803119:	57                   	push   %edi
  80311a:	56                   	push   %esi
  80311b:	53                   	push   %ebx
  80311c:	83 ec 18             	sub    $0x18,%esp
  80311f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803122:	57                   	push   %edi
  803123:	e8 54 f6 ff ff       	call   80277c <fd2data>
  803128:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80312a:	83 c4 10             	add    $0x10,%esp
  80312d:	bb 00 00 00 00       	mov    $0x0,%ebx
  803132:	eb 3d                	jmp    803171 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803134:	85 db                	test   %ebx,%ebx
  803136:	74 04                	je     80313c <devpipe_read+0x26>
				return i;
  803138:	89 d8                	mov    %ebx,%eax
  80313a:	eb 44                	jmp    803180 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80313c:	89 f2                	mov    %esi,%edx
  80313e:	89 f8                	mov    %edi,%eax
  803140:	e8 e5 fe ff ff       	call   80302a <_pipeisclosed>
  803145:	85 c0                	test   %eax,%eax
  803147:	75 32                	jne    80317b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803149:	e8 a4 f2 ff ff       	call   8023f2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80314e:	8b 06                	mov    (%esi),%eax
  803150:	3b 46 04             	cmp    0x4(%esi),%eax
  803153:	74 df                	je     803134 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803155:	99                   	cltd   
  803156:	c1 ea 1b             	shr    $0x1b,%edx
  803159:	01 d0                	add    %edx,%eax
  80315b:	83 e0 1f             	and    $0x1f,%eax
  80315e:	29 d0                	sub    %edx,%eax
  803160:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803168:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80316b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80316e:	83 c3 01             	add    $0x1,%ebx
  803171:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803174:	75 d8                	jne    80314e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803176:	8b 45 10             	mov    0x10(%ebp),%eax
  803179:	eb 05                	jmp    803180 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80317b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803183:	5b                   	pop    %ebx
  803184:	5e                   	pop    %esi
  803185:	5f                   	pop    %edi
  803186:	5d                   	pop    %ebp
  803187:	c3                   	ret    

00803188 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803188:	55                   	push   %ebp
  803189:	89 e5                	mov    %esp,%ebp
  80318b:	56                   	push   %esi
  80318c:	53                   	push   %ebx
  80318d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803190:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803193:	50                   	push   %eax
  803194:	e8 fa f5 ff ff       	call   802793 <fd_alloc>
  803199:	83 c4 10             	add    $0x10,%esp
  80319c:	89 c2                	mov    %eax,%edx
  80319e:	85 c0                	test   %eax,%eax
  8031a0:	0f 88 2c 01 00 00    	js     8032d2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031a6:	83 ec 04             	sub    $0x4,%esp
  8031a9:	68 07 04 00 00       	push   $0x407
  8031ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8031b1:	6a 00                	push   $0x0
  8031b3:	e8 59 f2 ff ff       	call   802411 <sys_page_alloc>
  8031b8:	83 c4 10             	add    $0x10,%esp
  8031bb:	89 c2                	mov    %eax,%edx
  8031bd:	85 c0                	test   %eax,%eax
  8031bf:	0f 88 0d 01 00 00    	js     8032d2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8031c5:	83 ec 0c             	sub    $0xc,%esp
  8031c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031cb:	50                   	push   %eax
  8031cc:	e8 c2 f5 ff ff       	call   802793 <fd_alloc>
  8031d1:	89 c3                	mov    %eax,%ebx
  8031d3:	83 c4 10             	add    $0x10,%esp
  8031d6:	85 c0                	test   %eax,%eax
  8031d8:	0f 88 e2 00 00 00    	js     8032c0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031de:	83 ec 04             	sub    $0x4,%esp
  8031e1:	68 07 04 00 00       	push   $0x407
  8031e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8031e9:	6a 00                	push   $0x0
  8031eb:	e8 21 f2 ff ff       	call   802411 <sys_page_alloc>
  8031f0:	89 c3                	mov    %eax,%ebx
  8031f2:	83 c4 10             	add    $0x10,%esp
  8031f5:	85 c0                	test   %eax,%eax
  8031f7:	0f 88 c3 00 00 00    	js     8032c0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8031fd:	83 ec 0c             	sub    $0xc,%esp
  803200:	ff 75 f4             	pushl  -0xc(%ebp)
  803203:	e8 74 f5 ff ff       	call   80277c <fd2data>
  803208:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80320a:	83 c4 0c             	add    $0xc,%esp
  80320d:	68 07 04 00 00       	push   $0x407
  803212:	50                   	push   %eax
  803213:	6a 00                	push   $0x0
  803215:	e8 f7 f1 ff ff       	call   802411 <sys_page_alloc>
  80321a:	89 c3                	mov    %eax,%ebx
  80321c:	83 c4 10             	add    $0x10,%esp
  80321f:	85 c0                	test   %eax,%eax
  803221:	0f 88 89 00 00 00    	js     8032b0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803227:	83 ec 0c             	sub    $0xc,%esp
  80322a:	ff 75 f0             	pushl  -0x10(%ebp)
  80322d:	e8 4a f5 ff ff       	call   80277c <fd2data>
  803232:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803239:	50                   	push   %eax
  80323a:	6a 00                	push   $0x0
  80323c:	56                   	push   %esi
  80323d:	6a 00                	push   $0x0
  80323f:	e8 10 f2 ff ff       	call   802454 <sys_page_map>
  803244:	89 c3                	mov    %eax,%ebx
  803246:	83 c4 20             	add    $0x20,%esp
  803249:	85 c0                	test   %eax,%eax
  80324b:	78 55                	js     8032a2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80324d:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803253:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803256:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80325b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803262:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803268:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80326b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80326d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803270:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803277:	83 ec 0c             	sub    $0xc,%esp
  80327a:	ff 75 f4             	pushl  -0xc(%ebp)
  80327d:	e8 ea f4 ff ff       	call   80276c <fd2num>
  803282:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803285:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803287:	83 c4 04             	add    $0x4,%esp
  80328a:	ff 75 f0             	pushl  -0x10(%ebp)
  80328d:	e8 da f4 ff ff       	call   80276c <fd2num>
  803292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803295:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803298:	83 c4 10             	add    $0x10,%esp
  80329b:	ba 00 00 00 00       	mov    $0x0,%edx
  8032a0:	eb 30                	jmp    8032d2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8032a2:	83 ec 08             	sub    $0x8,%esp
  8032a5:	56                   	push   %esi
  8032a6:	6a 00                	push   $0x0
  8032a8:	e8 e9 f1 ff ff       	call   802496 <sys_page_unmap>
  8032ad:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8032b0:	83 ec 08             	sub    $0x8,%esp
  8032b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8032b6:	6a 00                	push   $0x0
  8032b8:	e8 d9 f1 ff ff       	call   802496 <sys_page_unmap>
  8032bd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8032c0:	83 ec 08             	sub    $0x8,%esp
  8032c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8032c6:	6a 00                	push   $0x0
  8032c8:	e8 c9 f1 ff ff       	call   802496 <sys_page_unmap>
  8032cd:	83 c4 10             	add    $0x10,%esp
  8032d0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8032d2:	89 d0                	mov    %edx,%eax
  8032d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032d7:	5b                   	pop    %ebx
  8032d8:	5e                   	pop    %esi
  8032d9:	5d                   	pop    %ebp
  8032da:	c3                   	ret    

008032db <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8032db:	55                   	push   %ebp
  8032dc:	89 e5                	mov    %esp,%ebp
  8032de:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8032e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032e4:	50                   	push   %eax
  8032e5:	ff 75 08             	pushl  0x8(%ebp)
  8032e8:	e8 f5 f4 ff ff       	call   8027e2 <fd_lookup>
  8032ed:	83 c4 10             	add    $0x10,%esp
  8032f0:	85 c0                	test   %eax,%eax
  8032f2:	78 18                	js     80330c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8032f4:	83 ec 0c             	sub    $0xc,%esp
  8032f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8032fa:	e8 7d f4 ff ff       	call   80277c <fd2data>
	return _pipeisclosed(fd, p);
  8032ff:	89 c2                	mov    %eax,%edx
  803301:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803304:	e8 21 fd ff ff       	call   80302a <_pipeisclosed>
  803309:	83 c4 10             	add    $0x10,%esp
}
  80330c:	c9                   	leave  
  80330d:	c3                   	ret    

0080330e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80330e:	55                   	push   %ebp
  80330f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803311:	b8 00 00 00 00       	mov    $0x0,%eax
  803316:	5d                   	pop    %ebp
  803317:	c3                   	ret    

00803318 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803318:	55                   	push   %ebp
  803319:	89 e5                	mov    %esp,%ebp
  80331b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80331e:	68 b5 40 80 00       	push   $0x8040b5
  803323:	ff 75 0c             	pushl  0xc(%ebp)
  803326:	e8 e3 ec ff ff       	call   80200e <strcpy>
	return 0;
}
  80332b:	b8 00 00 00 00       	mov    $0x0,%eax
  803330:	c9                   	leave  
  803331:	c3                   	ret    

00803332 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803332:	55                   	push   %ebp
  803333:	89 e5                	mov    %esp,%ebp
  803335:	57                   	push   %edi
  803336:	56                   	push   %esi
  803337:	53                   	push   %ebx
  803338:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80333e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803343:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803349:	eb 2d                	jmp    803378 <devcons_write+0x46>
		m = n - tot;
  80334b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80334e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803350:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803353:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803358:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80335b:	83 ec 04             	sub    $0x4,%esp
  80335e:	53                   	push   %ebx
  80335f:	03 45 0c             	add    0xc(%ebp),%eax
  803362:	50                   	push   %eax
  803363:	57                   	push   %edi
  803364:	e8 37 ee ff ff       	call   8021a0 <memmove>
		sys_cputs(buf, m);
  803369:	83 c4 08             	add    $0x8,%esp
  80336c:	53                   	push   %ebx
  80336d:	57                   	push   %edi
  80336e:	e8 e2 ef ff ff       	call   802355 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803373:	01 de                	add    %ebx,%esi
  803375:	83 c4 10             	add    $0x10,%esp
  803378:	89 f0                	mov    %esi,%eax
  80337a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80337d:	72 cc                	jb     80334b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80337f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803382:	5b                   	pop    %ebx
  803383:	5e                   	pop    %esi
  803384:	5f                   	pop    %edi
  803385:	5d                   	pop    %ebp
  803386:	c3                   	ret    

00803387 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803387:	55                   	push   %ebp
  803388:	89 e5                	mov    %esp,%ebp
  80338a:	83 ec 08             	sub    $0x8,%esp
  80338d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803392:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803396:	74 2a                	je     8033c2 <devcons_read+0x3b>
  803398:	eb 05                	jmp    80339f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80339a:	e8 53 f0 ff ff       	call   8023f2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80339f:	e8 cf ef ff ff       	call   802373 <sys_cgetc>
  8033a4:	85 c0                	test   %eax,%eax
  8033a6:	74 f2                	je     80339a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8033a8:	85 c0                	test   %eax,%eax
  8033aa:	78 16                	js     8033c2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8033ac:	83 f8 04             	cmp    $0x4,%eax
  8033af:	74 0c                	je     8033bd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8033b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8033b4:	88 02                	mov    %al,(%edx)
	return 1;
  8033b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8033bb:	eb 05                	jmp    8033c2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8033bd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8033c2:	c9                   	leave  
  8033c3:	c3                   	ret    

008033c4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8033c4:	55                   	push   %ebp
  8033c5:	89 e5                	mov    %esp,%ebp
  8033c7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8033ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8033cd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8033d0:	6a 01                	push   $0x1
  8033d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8033d5:	50                   	push   %eax
  8033d6:	e8 7a ef ff ff       	call   802355 <sys_cputs>
}
  8033db:	83 c4 10             	add    $0x10,%esp
  8033de:	c9                   	leave  
  8033df:	c3                   	ret    

008033e0 <getchar>:

int
getchar(void)
{
  8033e0:	55                   	push   %ebp
  8033e1:	89 e5                	mov    %esp,%ebp
  8033e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8033e6:	6a 01                	push   $0x1
  8033e8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8033eb:	50                   	push   %eax
  8033ec:	6a 00                	push   $0x0
  8033ee:	e8 55 f6 ff ff       	call   802a48 <read>
	if (r < 0)
  8033f3:	83 c4 10             	add    $0x10,%esp
  8033f6:	85 c0                	test   %eax,%eax
  8033f8:	78 0f                	js     803409 <getchar+0x29>
		return r;
	if (r < 1)
  8033fa:	85 c0                	test   %eax,%eax
  8033fc:	7e 06                	jle    803404 <getchar+0x24>
		return -E_EOF;
	return c;
  8033fe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803402:	eb 05                	jmp    803409 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803404:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803409:	c9                   	leave  
  80340a:	c3                   	ret    

0080340b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80340b:	55                   	push   %ebp
  80340c:	89 e5                	mov    %esp,%ebp
  80340e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803411:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803414:	50                   	push   %eax
  803415:	ff 75 08             	pushl  0x8(%ebp)
  803418:	e8 c5 f3 ff ff       	call   8027e2 <fd_lookup>
  80341d:	83 c4 10             	add    $0x10,%esp
  803420:	85 c0                	test   %eax,%eax
  803422:	78 11                	js     803435 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803424:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803427:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80342d:	39 10                	cmp    %edx,(%eax)
  80342f:	0f 94 c0             	sete   %al
  803432:	0f b6 c0             	movzbl %al,%eax
}
  803435:	c9                   	leave  
  803436:	c3                   	ret    

00803437 <opencons>:

int
opencons(void)
{
  803437:	55                   	push   %ebp
  803438:	89 e5                	mov    %esp,%ebp
  80343a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80343d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803440:	50                   	push   %eax
  803441:	e8 4d f3 ff ff       	call   802793 <fd_alloc>
  803446:	83 c4 10             	add    $0x10,%esp
		return r;
  803449:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80344b:	85 c0                	test   %eax,%eax
  80344d:	78 3e                	js     80348d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80344f:	83 ec 04             	sub    $0x4,%esp
  803452:	68 07 04 00 00       	push   $0x407
  803457:	ff 75 f4             	pushl  -0xc(%ebp)
  80345a:	6a 00                	push   $0x0
  80345c:	e8 b0 ef ff ff       	call   802411 <sys_page_alloc>
  803461:	83 c4 10             	add    $0x10,%esp
		return r;
  803464:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803466:	85 c0                	test   %eax,%eax
  803468:	78 23                	js     80348d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80346a:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803470:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803473:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803475:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803478:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80347f:	83 ec 0c             	sub    $0xc,%esp
  803482:	50                   	push   %eax
  803483:	e8 e4 f2 ff ff       	call   80276c <fd2num>
  803488:	89 c2                	mov    %eax,%edx
  80348a:	83 c4 10             	add    $0x10,%esp
}
  80348d:	89 d0                	mov    %edx,%eax
  80348f:	c9                   	leave  
  803490:	c3                   	ret    
  803491:	66 90                	xchg   %ax,%ax
  803493:	66 90                	xchg   %ax,%ax
  803495:	66 90                	xchg   %ax,%ax
  803497:	66 90                	xchg   %ax,%ax
  803499:	66 90                	xchg   %ax,%ax
  80349b:	66 90                	xchg   %ax,%ax
  80349d:	66 90                	xchg   %ax,%ax
  80349f:	90                   	nop

008034a0 <__udivdi3>:
  8034a0:	55                   	push   %ebp
  8034a1:	57                   	push   %edi
  8034a2:	56                   	push   %esi
  8034a3:	53                   	push   %ebx
  8034a4:	83 ec 1c             	sub    $0x1c,%esp
  8034a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8034ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8034af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8034b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8034b7:	85 f6                	test   %esi,%esi
  8034b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8034bd:	89 ca                	mov    %ecx,%edx
  8034bf:	89 f8                	mov    %edi,%eax
  8034c1:	75 3d                	jne    803500 <__udivdi3+0x60>
  8034c3:	39 cf                	cmp    %ecx,%edi
  8034c5:	0f 87 c5 00 00 00    	ja     803590 <__udivdi3+0xf0>
  8034cb:	85 ff                	test   %edi,%edi
  8034cd:	89 fd                	mov    %edi,%ebp
  8034cf:	75 0b                	jne    8034dc <__udivdi3+0x3c>
  8034d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8034d6:	31 d2                	xor    %edx,%edx
  8034d8:	f7 f7                	div    %edi
  8034da:	89 c5                	mov    %eax,%ebp
  8034dc:	89 c8                	mov    %ecx,%eax
  8034de:	31 d2                	xor    %edx,%edx
  8034e0:	f7 f5                	div    %ebp
  8034e2:	89 c1                	mov    %eax,%ecx
  8034e4:	89 d8                	mov    %ebx,%eax
  8034e6:	89 cf                	mov    %ecx,%edi
  8034e8:	f7 f5                	div    %ebp
  8034ea:	89 c3                	mov    %eax,%ebx
  8034ec:	89 d8                	mov    %ebx,%eax
  8034ee:	89 fa                	mov    %edi,%edx
  8034f0:	83 c4 1c             	add    $0x1c,%esp
  8034f3:	5b                   	pop    %ebx
  8034f4:	5e                   	pop    %esi
  8034f5:	5f                   	pop    %edi
  8034f6:	5d                   	pop    %ebp
  8034f7:	c3                   	ret    
  8034f8:	90                   	nop
  8034f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803500:	39 ce                	cmp    %ecx,%esi
  803502:	77 74                	ja     803578 <__udivdi3+0xd8>
  803504:	0f bd fe             	bsr    %esi,%edi
  803507:	83 f7 1f             	xor    $0x1f,%edi
  80350a:	0f 84 98 00 00 00    	je     8035a8 <__udivdi3+0x108>
  803510:	bb 20 00 00 00       	mov    $0x20,%ebx
  803515:	89 f9                	mov    %edi,%ecx
  803517:	89 c5                	mov    %eax,%ebp
  803519:	29 fb                	sub    %edi,%ebx
  80351b:	d3 e6                	shl    %cl,%esi
  80351d:	89 d9                	mov    %ebx,%ecx
  80351f:	d3 ed                	shr    %cl,%ebp
  803521:	89 f9                	mov    %edi,%ecx
  803523:	d3 e0                	shl    %cl,%eax
  803525:	09 ee                	or     %ebp,%esi
  803527:	89 d9                	mov    %ebx,%ecx
  803529:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80352d:	89 d5                	mov    %edx,%ebp
  80352f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803533:	d3 ed                	shr    %cl,%ebp
  803535:	89 f9                	mov    %edi,%ecx
  803537:	d3 e2                	shl    %cl,%edx
  803539:	89 d9                	mov    %ebx,%ecx
  80353b:	d3 e8                	shr    %cl,%eax
  80353d:	09 c2                	or     %eax,%edx
  80353f:	89 d0                	mov    %edx,%eax
  803541:	89 ea                	mov    %ebp,%edx
  803543:	f7 f6                	div    %esi
  803545:	89 d5                	mov    %edx,%ebp
  803547:	89 c3                	mov    %eax,%ebx
  803549:	f7 64 24 0c          	mull   0xc(%esp)
  80354d:	39 d5                	cmp    %edx,%ebp
  80354f:	72 10                	jb     803561 <__udivdi3+0xc1>
  803551:	8b 74 24 08          	mov    0x8(%esp),%esi
  803555:	89 f9                	mov    %edi,%ecx
  803557:	d3 e6                	shl    %cl,%esi
  803559:	39 c6                	cmp    %eax,%esi
  80355b:	73 07                	jae    803564 <__udivdi3+0xc4>
  80355d:	39 d5                	cmp    %edx,%ebp
  80355f:	75 03                	jne    803564 <__udivdi3+0xc4>
  803561:	83 eb 01             	sub    $0x1,%ebx
  803564:	31 ff                	xor    %edi,%edi
  803566:	89 d8                	mov    %ebx,%eax
  803568:	89 fa                	mov    %edi,%edx
  80356a:	83 c4 1c             	add    $0x1c,%esp
  80356d:	5b                   	pop    %ebx
  80356e:	5e                   	pop    %esi
  80356f:	5f                   	pop    %edi
  803570:	5d                   	pop    %ebp
  803571:	c3                   	ret    
  803572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803578:	31 ff                	xor    %edi,%edi
  80357a:	31 db                	xor    %ebx,%ebx
  80357c:	89 d8                	mov    %ebx,%eax
  80357e:	89 fa                	mov    %edi,%edx
  803580:	83 c4 1c             	add    $0x1c,%esp
  803583:	5b                   	pop    %ebx
  803584:	5e                   	pop    %esi
  803585:	5f                   	pop    %edi
  803586:	5d                   	pop    %ebp
  803587:	c3                   	ret    
  803588:	90                   	nop
  803589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803590:	89 d8                	mov    %ebx,%eax
  803592:	f7 f7                	div    %edi
  803594:	31 ff                	xor    %edi,%edi
  803596:	89 c3                	mov    %eax,%ebx
  803598:	89 d8                	mov    %ebx,%eax
  80359a:	89 fa                	mov    %edi,%edx
  80359c:	83 c4 1c             	add    $0x1c,%esp
  80359f:	5b                   	pop    %ebx
  8035a0:	5e                   	pop    %esi
  8035a1:	5f                   	pop    %edi
  8035a2:	5d                   	pop    %ebp
  8035a3:	c3                   	ret    
  8035a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035a8:	39 ce                	cmp    %ecx,%esi
  8035aa:	72 0c                	jb     8035b8 <__udivdi3+0x118>
  8035ac:	31 db                	xor    %ebx,%ebx
  8035ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8035b2:	0f 87 34 ff ff ff    	ja     8034ec <__udivdi3+0x4c>
  8035b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8035bd:	e9 2a ff ff ff       	jmp    8034ec <__udivdi3+0x4c>
  8035c2:	66 90                	xchg   %ax,%ax
  8035c4:	66 90                	xchg   %ax,%ax
  8035c6:	66 90                	xchg   %ax,%ax
  8035c8:	66 90                	xchg   %ax,%ax
  8035ca:	66 90                	xchg   %ax,%ax
  8035cc:	66 90                	xchg   %ax,%ax
  8035ce:	66 90                	xchg   %ax,%ax

008035d0 <__umoddi3>:
  8035d0:	55                   	push   %ebp
  8035d1:	57                   	push   %edi
  8035d2:	56                   	push   %esi
  8035d3:	53                   	push   %ebx
  8035d4:	83 ec 1c             	sub    $0x1c,%esp
  8035d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8035db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8035df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8035e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8035e7:	85 d2                	test   %edx,%edx
  8035e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8035ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8035f1:	89 f3                	mov    %esi,%ebx
  8035f3:	89 3c 24             	mov    %edi,(%esp)
  8035f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8035fa:	75 1c                	jne    803618 <__umoddi3+0x48>
  8035fc:	39 f7                	cmp    %esi,%edi
  8035fe:	76 50                	jbe    803650 <__umoddi3+0x80>
  803600:	89 c8                	mov    %ecx,%eax
  803602:	89 f2                	mov    %esi,%edx
  803604:	f7 f7                	div    %edi
  803606:	89 d0                	mov    %edx,%eax
  803608:	31 d2                	xor    %edx,%edx
  80360a:	83 c4 1c             	add    $0x1c,%esp
  80360d:	5b                   	pop    %ebx
  80360e:	5e                   	pop    %esi
  80360f:	5f                   	pop    %edi
  803610:	5d                   	pop    %ebp
  803611:	c3                   	ret    
  803612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803618:	39 f2                	cmp    %esi,%edx
  80361a:	89 d0                	mov    %edx,%eax
  80361c:	77 52                	ja     803670 <__umoddi3+0xa0>
  80361e:	0f bd ea             	bsr    %edx,%ebp
  803621:	83 f5 1f             	xor    $0x1f,%ebp
  803624:	75 5a                	jne    803680 <__umoddi3+0xb0>
  803626:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80362a:	0f 82 e0 00 00 00    	jb     803710 <__umoddi3+0x140>
  803630:	39 0c 24             	cmp    %ecx,(%esp)
  803633:	0f 86 d7 00 00 00    	jbe    803710 <__umoddi3+0x140>
  803639:	8b 44 24 08          	mov    0x8(%esp),%eax
  80363d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803641:	83 c4 1c             	add    $0x1c,%esp
  803644:	5b                   	pop    %ebx
  803645:	5e                   	pop    %esi
  803646:	5f                   	pop    %edi
  803647:	5d                   	pop    %ebp
  803648:	c3                   	ret    
  803649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803650:	85 ff                	test   %edi,%edi
  803652:	89 fd                	mov    %edi,%ebp
  803654:	75 0b                	jne    803661 <__umoddi3+0x91>
  803656:	b8 01 00 00 00       	mov    $0x1,%eax
  80365b:	31 d2                	xor    %edx,%edx
  80365d:	f7 f7                	div    %edi
  80365f:	89 c5                	mov    %eax,%ebp
  803661:	89 f0                	mov    %esi,%eax
  803663:	31 d2                	xor    %edx,%edx
  803665:	f7 f5                	div    %ebp
  803667:	89 c8                	mov    %ecx,%eax
  803669:	f7 f5                	div    %ebp
  80366b:	89 d0                	mov    %edx,%eax
  80366d:	eb 99                	jmp    803608 <__umoddi3+0x38>
  80366f:	90                   	nop
  803670:	89 c8                	mov    %ecx,%eax
  803672:	89 f2                	mov    %esi,%edx
  803674:	83 c4 1c             	add    $0x1c,%esp
  803677:	5b                   	pop    %ebx
  803678:	5e                   	pop    %esi
  803679:	5f                   	pop    %edi
  80367a:	5d                   	pop    %ebp
  80367b:	c3                   	ret    
  80367c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803680:	8b 34 24             	mov    (%esp),%esi
  803683:	bf 20 00 00 00       	mov    $0x20,%edi
  803688:	89 e9                	mov    %ebp,%ecx
  80368a:	29 ef                	sub    %ebp,%edi
  80368c:	d3 e0                	shl    %cl,%eax
  80368e:	89 f9                	mov    %edi,%ecx
  803690:	89 f2                	mov    %esi,%edx
  803692:	d3 ea                	shr    %cl,%edx
  803694:	89 e9                	mov    %ebp,%ecx
  803696:	09 c2                	or     %eax,%edx
  803698:	89 d8                	mov    %ebx,%eax
  80369a:	89 14 24             	mov    %edx,(%esp)
  80369d:	89 f2                	mov    %esi,%edx
  80369f:	d3 e2                	shl    %cl,%edx
  8036a1:	89 f9                	mov    %edi,%ecx
  8036a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8036a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8036ab:	d3 e8                	shr    %cl,%eax
  8036ad:	89 e9                	mov    %ebp,%ecx
  8036af:	89 c6                	mov    %eax,%esi
  8036b1:	d3 e3                	shl    %cl,%ebx
  8036b3:	89 f9                	mov    %edi,%ecx
  8036b5:	89 d0                	mov    %edx,%eax
  8036b7:	d3 e8                	shr    %cl,%eax
  8036b9:	89 e9                	mov    %ebp,%ecx
  8036bb:	09 d8                	or     %ebx,%eax
  8036bd:	89 d3                	mov    %edx,%ebx
  8036bf:	89 f2                	mov    %esi,%edx
  8036c1:	f7 34 24             	divl   (%esp)
  8036c4:	89 d6                	mov    %edx,%esi
  8036c6:	d3 e3                	shl    %cl,%ebx
  8036c8:	f7 64 24 04          	mull   0x4(%esp)
  8036cc:	39 d6                	cmp    %edx,%esi
  8036ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8036d2:	89 d1                	mov    %edx,%ecx
  8036d4:	89 c3                	mov    %eax,%ebx
  8036d6:	72 08                	jb     8036e0 <__umoddi3+0x110>
  8036d8:	75 11                	jne    8036eb <__umoddi3+0x11b>
  8036da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8036de:	73 0b                	jae    8036eb <__umoddi3+0x11b>
  8036e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8036e4:	1b 14 24             	sbb    (%esp),%edx
  8036e7:	89 d1                	mov    %edx,%ecx
  8036e9:	89 c3                	mov    %eax,%ebx
  8036eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8036ef:	29 da                	sub    %ebx,%edx
  8036f1:	19 ce                	sbb    %ecx,%esi
  8036f3:	89 f9                	mov    %edi,%ecx
  8036f5:	89 f0                	mov    %esi,%eax
  8036f7:	d3 e0                	shl    %cl,%eax
  8036f9:	89 e9                	mov    %ebp,%ecx
  8036fb:	d3 ea                	shr    %cl,%edx
  8036fd:	89 e9                	mov    %ebp,%ecx
  8036ff:	d3 ee                	shr    %cl,%esi
  803701:	09 d0                	or     %edx,%eax
  803703:	89 f2                	mov    %esi,%edx
  803705:	83 c4 1c             	add    $0x1c,%esp
  803708:	5b                   	pop    %ebx
  803709:	5e                   	pop    %esi
  80370a:	5f                   	pop    %edi
  80370b:	5d                   	pop    %ebp
  80370c:	c3                   	ret    
  80370d:	8d 76 00             	lea    0x0(%esi),%esi
  803710:	29 f9                	sub    %edi,%ecx
  803712:	19 d6                	sbb    %edx,%esi
  803714:	89 74 24 04          	mov    %esi,0x4(%esp)
  803718:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80371c:	e9 18 ff ff ff       	jmp    803639 <__umoddi3+0x69>
