
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 7e 20 f0 00 	cmpl   $0x0,0xf0207e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 7e 20 f0    	mov    %esi,0xf0207e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 89 5b 00 00       	call   f0105bea <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 80 62 10 f0       	push   $0xf0106280
f010006d:	e8 32 36 00 00       	call   f01036a4 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 02 36 00 00       	call   f010367e <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 7d 6b 10 f0 	movl   $0xf0106b7d,(%esp)
f0100083:	e8 1c 36 00 00       	call   f01036a4 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 9a 08 00 00       	call   f010092f <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:

static void boot_aps(void);

void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 90 24 f0       	mov    $0xf0249008,%eax
f01000a6:	2d d0 68 20 f0       	sub    $0xf02068d0,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 d0 68 20 f0       	push   $0xf02068d0
f01000b3:	e8 11 55 00 00       	call   f01055c9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 88 05 00 00       	call   f0100645 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 ec 62 10 f0       	push   $0xf01062ec
f01000ca:	e8 d5 35 00 00       	call   f01036a4 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 f1 11 00 00       	call   f01012c5 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 54 2e 00 00       	call   f0102f2d <env_init>
	trap_init();
f01000d9:	e8 c0 36 00 00       	call   f010379e <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 fd 57 00 00       	call   f01058e0 <mp_init>
	lapic_init();
f01000e3:	e8 1d 5b 00 00       	call   f0105c05 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 de 34 00 00       	call   f01035cb <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000f4:	e8 5f 5d 00 00       	call   f0105e58 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 7e 20 f0 07 	cmpl   $0x7,0xf0207e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 a4 62 10 f0       	push   $0xf01062a4
f010010f:	6a 5d                	push   $0x5d
f0100111:	68 07 63 10 f0       	push   $0xf0106307
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 46 58 10 f0       	mov    $0xf0105846,%eax
f0100123:	2d cc 57 10 f0       	sub    $0xf01057cc,%eax
f0100128:	50                   	push   %eax
f0100129:	68 cc 57 10 f0       	push   $0xf01057cc
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 de 54 00 00       	call   f0105616 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 80 20 f0       	mov    $0xf0208020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 a3 5a 00 00       	call   f0105bea <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 80 20 f0       	add    $0xf0208020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 80 20 f0       	sub    $0xf0208020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 10 21 f0       	add    $0xf0211000,%eax
f010016b:	a3 84 7e 20 f0       	mov    %eax,0xf0207e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 d2 5b 00 00       	call   f0105d53 <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 83 20 f0 74 	imul   $0x74,0xf02083c4,%eax
f0100196:	05 20 80 20 f0       	add    $0xf0208020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 34 6c 1c f0       	push   $0xf01c6c34
f01001a9:	e8 34 2f 00 00       	call   f01030e2 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 dc 6b 1f f0       	push   $0xf01f6bdc
f01001b8:	e8 25 2f 00 00       	call   f01030e2 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 27 04 00 00       	call   f01005e9 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001c2:	e8 f5 42 00 00       	call   f01044bc <sched_yield>

f01001c7 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001c7:	55                   	push   %ebp
f01001c8:	89 e5                	mov    %esp,%ebp
f01001ca:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001cd:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 12                	ja     f01001eb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 c8 62 10 f0       	push   $0xf01062c8
f01001df:	6a 74                	push   $0x74
f01001e1:	68 07 63 10 f0       	push   $0xf0106307
f01001e6:	e8 55 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f3:	e8 f2 59 00 00       	call   f0105bea <cpunum>
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	50                   	push   %eax
f01001fc:	68 13 63 10 f0       	push   $0xf0106313
f0100201:	e8 9e 34 00 00       	call   f01036a4 <cprintf>

	lapic_init();
f0100206:	e8 fa 59 00 00       	call   f0105c05 <lapic_init>
	env_init_percpu();
f010020b:	e8 ed 2c 00 00       	call   f0102efd <env_init_percpu>
	trap_init_percpu();
f0100210:	e8 a3 34 00 00       	call   f01036b8 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100215:	e8 d0 59 00 00       	call   f0105bea <cpunum>
f010021a:	6b d0 74             	imul   $0x74,%eax,%edx
f010021d:	81 c2 20 80 20 f0    	add    $0xf0208020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100223:	b8 01 00 00 00       	mov    $0x1,%eax
f0100228:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022c:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100233:	e8 20 5c 00 00       	call   f0105e58 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100238:	e8 7f 42 00 00       	call   f01044bc <sched_yield>

f010023d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010023d:	55                   	push   %ebp
f010023e:	89 e5                	mov    %esp,%ebp
f0100240:	53                   	push   %ebx
f0100241:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100244:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100247:	ff 75 0c             	pushl  0xc(%ebp)
f010024a:	ff 75 08             	pushl  0x8(%ebp)
f010024d:	68 29 63 10 f0       	push   $0xf0106329
f0100252:	e8 4d 34 00 00       	call   f01036a4 <cprintf>
	vcprintf(fmt, ap);
f0100257:	83 c4 08             	add    $0x8,%esp
f010025a:	53                   	push   %ebx
f010025b:	ff 75 10             	pushl  0x10(%ebp)
f010025e:	e8 1b 34 00 00       	call   f010367e <vcprintf>
	cprintf("\n");
f0100263:	c7 04 24 7d 6b 10 f0 	movl   $0xf0106b7d,(%esp)
f010026a:	e8 35 34 00 00       	call   f01036a4 <cprintf>
	va_end(ap);
}
f010026f:	83 c4 10             	add    $0x10,%esp
f0100272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100275:	c9                   	leave  
f0100276:	c3                   	ret    

f0100277 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100277:	55                   	push   %ebp
f0100278:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010027a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010027f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100280:	a8 01                	test   $0x1,%al
f0100282:	74 0b                	je     f010028f <serial_proc_data+0x18>
f0100284:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100289:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010028a:	0f b6 c0             	movzbl %al,%eax
f010028d:	eb 05                	jmp    f0100294 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010028f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100294:	5d                   	pop    %ebp
f0100295:	c3                   	ret    

f0100296 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100296:	55                   	push   %ebp
f0100297:	89 e5                	mov    %esp,%ebp
f0100299:	53                   	push   %ebx
f010029a:	83 ec 04             	sub    $0x4,%esp
f010029d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010029f:	eb 2b                	jmp    f01002cc <cons_intr+0x36>
		if (c == 0)
f01002a1:	85 c0                	test   %eax,%eax
f01002a3:	74 27                	je     f01002cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a5:	8b 0d 24 72 20 f0    	mov    0xf0207224,%ecx
f01002ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01002ae:	89 15 24 72 20 f0    	mov    %edx,0xf0207224
f01002b4:	88 81 20 70 20 f0    	mov    %al,-0xfdf8fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c0:	75 0a                	jne    f01002cc <cons_intr+0x36>
			cons.wpos = 0;
f01002c2:	c7 05 24 72 20 f0 00 	movl   $0x0,0xf0207224
f01002c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002cc:	ff d3                	call   *%ebx
f01002ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002d1:	75 ce                	jne    f01002a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002d3:	83 c4 04             	add    $0x4,%esp
f01002d6:	5b                   	pop    %ebx
f01002d7:	5d                   	pop    %ebp
f01002d8:	c3                   	ret    

f01002d9 <kbd_proc_data>:
f01002d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01002de:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002df:	a8 01                	test   $0x1,%al
f01002e1:	0f 84 f0 00 00 00    	je     f01003d7 <kbd_proc_data+0xfe>
f01002e7:	ba 60 00 00 00       	mov    $0x60,%edx
f01002ec:	ec                   	in     (%dx),%al
f01002ed:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002ef:	3c e0                	cmp    $0xe0,%al
f01002f1:	75 0d                	jne    f0100300 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002f3:	83 0d 00 70 20 f0 40 	orl    $0x40,0xf0207000
		return 0;
f01002fa:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002ff:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100300:	55                   	push   %ebp
f0100301:	89 e5                	mov    %esp,%ebp
f0100303:	53                   	push   %ebx
f0100304:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100307:	84 c0                	test   %al,%al
f0100309:	79 36                	jns    f0100341 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010030b:	8b 0d 00 70 20 f0    	mov    0xf0207000,%ecx
f0100311:	89 cb                	mov    %ecx,%ebx
f0100313:	83 e3 40             	and    $0x40,%ebx
f0100316:	83 e0 7f             	and    $0x7f,%eax
f0100319:	85 db                	test   %ebx,%ebx
f010031b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031e:	0f b6 d2             	movzbl %dl,%edx
f0100321:	0f b6 82 a0 64 10 f0 	movzbl -0xfef9b60(%edx),%eax
f0100328:	83 c8 40             	or     $0x40,%eax
f010032b:	0f b6 c0             	movzbl %al,%eax
f010032e:	f7 d0                	not    %eax
f0100330:	21 c8                	and    %ecx,%eax
f0100332:	a3 00 70 20 f0       	mov    %eax,0xf0207000
		return 0;
f0100337:	b8 00 00 00 00       	mov    $0x0,%eax
f010033c:	e9 9e 00 00 00       	jmp    f01003df <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100341:	8b 0d 00 70 20 f0    	mov    0xf0207000,%ecx
f0100347:	f6 c1 40             	test   $0x40,%cl
f010034a:	74 0e                	je     f010035a <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010034c:	83 c8 80             	or     $0xffffff80,%eax
f010034f:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100351:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100354:	89 0d 00 70 20 f0    	mov    %ecx,0xf0207000
	}

	shift |= shiftcode[data];
f010035a:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010035d:	0f b6 82 a0 64 10 f0 	movzbl -0xfef9b60(%edx),%eax
f0100364:	0b 05 00 70 20 f0    	or     0xf0207000,%eax
f010036a:	0f b6 8a a0 63 10 f0 	movzbl -0xfef9c60(%edx),%ecx
f0100371:	31 c8                	xor    %ecx,%eax
f0100373:	a3 00 70 20 f0       	mov    %eax,0xf0207000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100378:	89 c1                	mov    %eax,%ecx
f010037a:	83 e1 03             	and    $0x3,%ecx
f010037d:	8b 0c 8d 80 63 10 f0 	mov    -0xfef9c80(,%ecx,4),%ecx
f0100384:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100388:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010038b:	a8 08                	test   $0x8,%al
f010038d:	74 1b                	je     f01003aa <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010038f:	89 da                	mov    %ebx,%edx
f0100391:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100394:	83 f9 19             	cmp    $0x19,%ecx
f0100397:	77 05                	ja     f010039e <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100399:	83 eb 20             	sub    $0x20,%ebx
f010039c:	eb 0c                	jmp    f01003aa <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010039e:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003a1:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003a4:	83 fa 19             	cmp    $0x19,%edx
f01003a7:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003aa:	f7 d0                	not    %eax
f01003ac:	a8 06                	test   $0x6,%al
f01003ae:	75 2d                	jne    f01003dd <kbd_proc_data+0x104>
f01003b0:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003b6:	75 25                	jne    f01003dd <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003b8:	83 ec 0c             	sub    $0xc,%esp
f01003bb:	68 43 63 10 f0       	push   $0xf0106343
f01003c0:	e8 df 32 00 00       	call   f01036a4 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c5:	ba 92 00 00 00       	mov    $0x92,%edx
f01003ca:	b8 03 00 00 00       	mov    $0x3,%eax
f01003cf:	ee                   	out    %al,(%dx)
f01003d0:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d3:	89 d8                	mov    %ebx,%eax
f01003d5:	eb 08                	jmp    f01003df <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003dc:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003dd:	89 d8                	mov    %ebx,%eax
}
f01003df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003e2:	c9                   	leave  
f01003e3:	c3                   	ret    

f01003e4 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003e4:	55                   	push   %ebp
f01003e5:	89 e5                	mov    %esp,%ebp
f01003e7:	57                   	push   %edi
f01003e8:	56                   	push   %esi
f01003e9:	53                   	push   %ebx
f01003ea:	83 ec 1c             	sub    $0x1c,%esp
f01003ed:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003ef:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f4:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003fe:	eb 09                	jmp    f0100409 <cons_putc+0x25>
f0100400:	89 ca                	mov    %ecx,%edx
f0100402:	ec                   	in     (%dx),%al
f0100403:	ec                   	in     (%dx),%al
f0100404:	ec                   	in     (%dx),%al
f0100405:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100406:	83 c3 01             	add    $0x1,%ebx
f0100409:	89 f2                	mov    %esi,%edx
f010040b:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010040c:	a8 20                	test   $0x20,%al
f010040e:	75 08                	jne    f0100418 <cons_putc+0x34>
f0100410:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100416:	7e e8                	jle    f0100400 <cons_putc+0x1c>
f0100418:	89 f8                	mov    %edi,%eax
f010041a:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100422:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100423:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100428:	be 79 03 00 00       	mov    $0x379,%esi
f010042d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100432:	eb 09                	jmp    f010043d <cons_putc+0x59>
f0100434:	89 ca                	mov    %ecx,%edx
f0100436:	ec                   	in     (%dx),%al
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	ec                   	in     (%dx),%al
f010043a:	83 c3 01             	add    $0x1,%ebx
f010043d:	89 f2                	mov    %esi,%edx
f010043f:	ec                   	in     (%dx),%al
f0100440:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100446:	7f 04                	jg     f010044c <cons_putc+0x68>
f0100448:	84 c0                	test   %al,%al
f010044a:	79 e8                	jns    f0100434 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100451:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100455:	ee                   	out    %al,(%dx)
f0100456:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010045b:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100460:	ee                   	out    %al,(%dx)
f0100461:	b8 08 00 00 00       	mov    $0x8,%eax
f0100466:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100467:	89 fa                	mov    %edi,%edx
f0100469:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010046f:	89 f8                	mov    %edi,%eax
f0100471:	80 cc 07             	or     $0x7,%ah
f0100474:	85 d2                	test   %edx,%edx
f0100476:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100479:	89 f8                	mov    %edi,%eax
f010047b:	0f b6 c0             	movzbl %al,%eax
f010047e:	83 f8 09             	cmp    $0x9,%eax
f0100481:	74 74                	je     f01004f7 <cons_putc+0x113>
f0100483:	83 f8 09             	cmp    $0x9,%eax
f0100486:	7f 0a                	jg     f0100492 <cons_putc+0xae>
f0100488:	83 f8 08             	cmp    $0x8,%eax
f010048b:	74 14                	je     f01004a1 <cons_putc+0xbd>
f010048d:	e9 99 00 00 00       	jmp    f010052b <cons_putc+0x147>
f0100492:	83 f8 0a             	cmp    $0xa,%eax
f0100495:	74 3a                	je     f01004d1 <cons_putc+0xed>
f0100497:	83 f8 0d             	cmp    $0xd,%eax
f010049a:	74 3d                	je     f01004d9 <cons_putc+0xf5>
f010049c:	e9 8a 00 00 00       	jmp    f010052b <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004a1:	0f b7 05 28 72 20 f0 	movzwl 0xf0207228,%eax
f01004a8:	66 85 c0             	test   %ax,%ax
f01004ab:	0f 84 e6 00 00 00    	je     f0100597 <cons_putc+0x1b3>
			crt_pos--;
f01004b1:	83 e8 01             	sub    $0x1,%eax
f01004b4:	66 a3 28 72 20 f0    	mov    %ax,0xf0207228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ba:	0f b7 c0             	movzwl %ax,%eax
f01004bd:	66 81 e7 00 ff       	and    $0xff00,%di
f01004c2:	83 cf 20             	or     $0x20,%edi
f01004c5:	8b 15 2c 72 20 f0    	mov    0xf020722c,%edx
f01004cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004cf:	eb 78                	jmp    f0100549 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004d1:	66 83 05 28 72 20 f0 	addw   $0x50,0xf0207228
f01004d8:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d9:	0f b7 05 28 72 20 f0 	movzwl 0xf0207228,%eax
f01004e0:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e6:	c1 e8 16             	shr    $0x16,%eax
f01004e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004ec:	c1 e0 04             	shl    $0x4,%eax
f01004ef:	66 a3 28 72 20 f0    	mov    %ax,0xf0207228
f01004f5:	eb 52                	jmp    f0100549 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fc:	e8 e3 fe ff ff       	call   f01003e4 <cons_putc>
		cons_putc(' ');
f0100501:	b8 20 00 00 00       	mov    $0x20,%eax
f0100506:	e8 d9 fe ff ff       	call   f01003e4 <cons_putc>
		cons_putc(' ');
f010050b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100510:	e8 cf fe ff ff       	call   f01003e4 <cons_putc>
		cons_putc(' ');
f0100515:	b8 20 00 00 00       	mov    $0x20,%eax
f010051a:	e8 c5 fe ff ff       	call   f01003e4 <cons_putc>
		cons_putc(' ');
f010051f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100524:	e8 bb fe ff ff       	call   f01003e4 <cons_putc>
f0100529:	eb 1e                	jmp    f0100549 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010052b:	0f b7 05 28 72 20 f0 	movzwl 0xf0207228,%eax
f0100532:	8d 50 01             	lea    0x1(%eax),%edx
f0100535:	66 89 15 28 72 20 f0 	mov    %dx,0xf0207228
f010053c:	0f b7 c0             	movzwl %ax,%eax
f010053f:	8b 15 2c 72 20 f0    	mov    0xf020722c,%edx
f0100545:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100549:	66 81 3d 28 72 20 f0 	cmpw   $0x7cf,0xf0207228
f0100550:	cf 07 
f0100552:	76 43                	jbe    f0100597 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100554:	a1 2c 72 20 f0       	mov    0xf020722c,%eax
f0100559:	83 ec 04             	sub    $0x4,%esp
f010055c:	68 00 0f 00 00       	push   $0xf00
f0100561:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100567:	52                   	push   %edx
f0100568:	50                   	push   %eax
f0100569:	e8 a8 50 00 00       	call   f0105616 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010056e:	8b 15 2c 72 20 f0    	mov    0xf020722c,%edx
f0100574:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010057a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100580:	83 c4 10             	add    $0x10,%esp
f0100583:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100588:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010058b:	39 d0                	cmp    %edx,%eax
f010058d:	75 f4                	jne    f0100583 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010058f:	66 83 2d 28 72 20 f0 	subw   $0x50,0xf0207228
f0100596:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100597:	8b 0d 30 72 20 f0    	mov    0xf0207230,%ecx
f010059d:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005a2:	89 ca                	mov    %ecx,%edx
f01005a4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005a5:	0f b7 1d 28 72 20 f0 	movzwl 0xf0207228,%ebx
f01005ac:	8d 71 01             	lea    0x1(%ecx),%esi
f01005af:	89 d8                	mov    %ebx,%eax
f01005b1:	66 c1 e8 08          	shr    $0x8,%ax
f01005b5:	89 f2                	mov    %esi,%edx
f01005b7:	ee                   	out    %al,(%dx)
f01005b8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bd:	89 ca                	mov    %ecx,%edx
f01005bf:	ee                   	out    %al,(%dx)
f01005c0:	89 d8                	mov    %ebx,%eax
f01005c2:	89 f2                	mov    %esi,%edx
f01005c4:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005c8:	5b                   	pop    %ebx
f01005c9:	5e                   	pop    %esi
f01005ca:	5f                   	pop    %edi
f01005cb:	5d                   	pop    %ebp
f01005cc:	c3                   	ret    

f01005cd <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005cd:	80 3d 34 72 20 f0 00 	cmpb   $0x0,0xf0207234
f01005d4:	74 11                	je     f01005e7 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005d6:	55                   	push   %ebp
f01005d7:	89 e5                	mov    %esp,%ebp
f01005d9:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005dc:	b8 77 02 10 f0       	mov    $0xf0100277,%eax
f01005e1:	e8 b0 fc ff ff       	call   f0100296 <cons_intr>
}
f01005e6:	c9                   	leave  
f01005e7:	f3 c3                	repz ret 

f01005e9 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005e9:	55                   	push   %ebp
f01005ea:	89 e5                	mov    %esp,%ebp
f01005ec:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005ef:	b8 d9 02 10 f0       	mov    $0xf01002d9,%eax
f01005f4:	e8 9d fc ff ff       	call   f0100296 <cons_intr>
}
f01005f9:	c9                   	leave  
f01005fa:	c3                   	ret    

f01005fb <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005fb:	55                   	push   %ebp
f01005fc:	89 e5                	mov    %esp,%ebp
f01005fe:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100601:	e8 c7 ff ff ff       	call   f01005cd <serial_intr>
	kbd_intr();
f0100606:	e8 de ff ff ff       	call   f01005e9 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010060b:	a1 20 72 20 f0       	mov    0xf0207220,%eax
f0100610:	3b 05 24 72 20 f0    	cmp    0xf0207224,%eax
f0100616:	74 26                	je     f010063e <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100618:	8d 50 01             	lea    0x1(%eax),%edx
f010061b:	89 15 20 72 20 f0    	mov    %edx,0xf0207220
f0100621:	0f b6 88 20 70 20 f0 	movzbl -0xfdf8fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100628:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010062a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100630:	75 11                	jne    f0100643 <cons_getc+0x48>
			cons.rpos = 0;
f0100632:	c7 05 20 72 20 f0 00 	movl   $0x0,0xf0207220
f0100639:	00 00 00 
f010063c:	eb 05                	jmp    f0100643 <cons_getc+0x48>
		return c;
	}
	return 0;
f010063e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    

f0100645 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100645:	55                   	push   %ebp
f0100646:	89 e5                	mov    %esp,%ebp
f0100648:	57                   	push   %edi
f0100649:	56                   	push   %esi
f010064a:	53                   	push   %ebx
f010064b:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010064e:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100655:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010065c:	5a a5 
	if (*cp != 0xA55A) {
f010065e:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100665:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100669:	74 11                	je     f010067c <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010066b:	c7 05 30 72 20 f0 b4 	movl   $0x3b4,0xf0207230
f0100672:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100675:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010067a:	eb 16                	jmp    f0100692 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010067c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100683:	c7 05 30 72 20 f0 d4 	movl   $0x3d4,0xf0207230
f010068a:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010068d:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100692:	8b 3d 30 72 20 f0    	mov    0xf0207230,%edi
f0100698:	b8 0e 00 00 00       	mov    $0xe,%eax
f010069d:	89 fa                	mov    %edi,%edx
f010069f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006a0:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a3:	89 da                	mov    %ebx,%edx
f01006a5:	ec                   	in     (%dx),%al
f01006a6:	0f b6 c8             	movzbl %al,%ecx
f01006a9:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ac:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006b1:	89 fa                	mov    %edi,%edx
f01006b3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b4:	89 da                	mov    %ebx,%edx
f01006b6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006b7:	89 35 2c 72 20 f0    	mov    %esi,0xf020722c
	crt_pos = pos;
f01006bd:	0f b6 c0             	movzbl %al,%eax
f01006c0:	09 c8                	or     %ecx,%eax
f01006c2:	66 a3 28 72 20 f0    	mov    %ax,0xf0207228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006c8:	e8 1c ff ff ff       	call   f01005e9 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006cd:	83 ec 0c             	sub    $0xc,%esp
f01006d0:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006d7:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006dc:	50                   	push   %eax
f01006dd:	e8 71 2e 00 00       	call   f0103553 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e2:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ec:	89 f2                	mov    %esi,%edx
f01006ee:	ee                   	out    %al,(%dx)
f01006ef:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006f4:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f9:	ee                   	out    %al,(%dx)
f01006fa:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006ff:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100704:	89 da                	mov    %ebx,%edx
f0100706:	ee                   	out    %al,(%dx)
f0100707:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010070c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100711:	ee                   	out    %al,(%dx)
f0100712:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100717:	b8 03 00 00 00       	mov    $0x3,%eax
f010071c:	ee                   	out    %al,(%dx)
f010071d:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100722:	b8 00 00 00 00       	mov    $0x0,%eax
f0100727:	ee                   	out    %al,(%dx)
f0100728:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010072d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100732:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100733:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100738:	ec                   	in     (%dx),%al
f0100739:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010073b:	83 c4 10             	add    $0x10,%esp
f010073e:	3c ff                	cmp    $0xff,%al
f0100740:	0f 95 05 34 72 20 f0 	setne  0xf0207234
f0100747:	89 f2                	mov    %esi,%edx
f0100749:	ec                   	in     (%dx),%al
f010074a:	89 da                	mov    %ebx,%edx
f010074c:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010074d:	80 f9 ff             	cmp    $0xff,%cl
f0100750:	74 21                	je     f0100773 <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100752:	83 ec 0c             	sub    $0xc,%esp
f0100755:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010075c:	25 ef ff 00 00       	and    $0xffef,%eax
f0100761:	50                   	push   %eax
f0100762:	e8 ec 2d 00 00       	call   f0103553 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100767:	83 c4 10             	add    $0x10,%esp
f010076a:	80 3d 34 72 20 f0 00 	cmpb   $0x0,0xf0207234
f0100771:	75 10                	jne    f0100783 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100773:	83 ec 0c             	sub    $0xc,%esp
f0100776:	68 4f 63 10 f0       	push   $0xf010634f
f010077b:	e8 24 2f 00 00       	call   f01036a4 <cprintf>
f0100780:	83 c4 10             	add    $0x10,%esp
}
f0100783:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100786:	5b                   	pop    %ebx
f0100787:	5e                   	pop    %esi
f0100788:	5f                   	pop    %edi
f0100789:	5d                   	pop    %ebp
f010078a:	c3                   	ret    

f010078b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010078b:	55                   	push   %ebp
f010078c:	89 e5                	mov    %esp,%ebp
f010078e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100791:	8b 45 08             	mov    0x8(%ebp),%eax
f0100794:	e8 4b fc ff ff       	call   f01003e4 <cons_putc>
}
f0100799:	c9                   	leave  
f010079a:	c3                   	ret    

f010079b <getchar>:

int
getchar(void)
{
f010079b:	55                   	push   %ebp
f010079c:	89 e5                	mov    %esp,%ebp
f010079e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007a1:	e8 55 fe ff ff       	call   f01005fb <cons_getc>
f01007a6:	85 c0                	test   %eax,%eax
f01007a8:	74 f7                	je     f01007a1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007aa:	c9                   	leave  
f01007ab:	c3                   	ret    

f01007ac <iscons>:

int
iscons(int fdnum)
{
f01007ac:	55                   	push   %ebp
f01007ad:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007af:	b8 01 00 00 00       	mov    $0x1,%eax
f01007b4:	5d                   	pop    %ebp
f01007b5:	c3                   	ret    

f01007b6 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007b6:	55                   	push   %ebp
f01007b7:	89 e5                	mov    %esp,%ebp
f01007b9:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007bc:	68 a0 65 10 f0       	push   $0xf01065a0
f01007c1:	68 be 65 10 f0       	push   $0xf01065be
f01007c6:	68 c3 65 10 f0       	push   $0xf01065c3
f01007cb:	e8 d4 2e 00 00       	call   f01036a4 <cprintf>
f01007d0:	83 c4 0c             	add    $0xc,%esp
f01007d3:	68 64 66 10 f0       	push   $0xf0106664
f01007d8:	68 cc 65 10 f0       	push   $0xf01065cc
f01007dd:	68 c3 65 10 f0       	push   $0xf01065c3
f01007e2:	e8 bd 2e 00 00       	call   f01036a4 <cprintf>
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	68 8c 66 10 f0       	push   $0xf010668c
f01007ef:	68 d5 65 10 f0       	push   $0xf01065d5
f01007f4:	68 c3 65 10 f0       	push   $0xf01065c3
f01007f9:	e8 a6 2e 00 00       	call   f01036a4 <cprintf>
	return 0;
}
f01007fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100803:	c9                   	leave  
f0100804:	c3                   	ret    

f0100805 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100805:	55                   	push   %ebp
f0100806:	89 e5                	mov    %esp,%ebp
f0100808:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080b:	68 df 65 10 f0       	push   $0xf01065df
f0100810:	e8 8f 2e 00 00       	call   f01036a4 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100815:	83 c4 08             	add    $0x8,%esp
f0100818:	68 0c 00 10 00       	push   $0x10000c
f010081d:	68 b4 66 10 f0       	push   $0xf01066b4
f0100822:	e8 7d 2e 00 00       	call   f01036a4 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100827:	83 c4 0c             	add    $0xc,%esp
f010082a:	68 0c 00 10 00       	push   $0x10000c
f010082f:	68 0c 00 10 f0       	push   $0xf010000c
f0100834:	68 dc 66 10 f0       	push   $0xf01066dc
f0100839:	e8 66 2e 00 00       	call   f01036a4 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	68 71 62 10 00       	push   $0x106271
f0100846:	68 71 62 10 f0       	push   $0xf0106271
f010084b:	68 00 67 10 f0       	push   $0xf0106700
f0100850:	e8 4f 2e 00 00       	call   f01036a4 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	68 d0 68 20 00       	push   $0x2068d0
f010085d:	68 d0 68 20 f0       	push   $0xf02068d0
f0100862:	68 24 67 10 f0       	push   $0xf0106724
f0100867:	e8 38 2e 00 00       	call   f01036a4 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	68 08 90 24 00       	push   $0x249008
f0100874:	68 08 90 24 f0       	push   $0xf0249008
f0100879:	68 48 67 10 f0       	push   $0xf0106748
f010087e:	e8 21 2e 00 00       	call   f01036a4 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100883:	b8 07 94 24 f0       	mov    $0xf0249407,%eax
f0100888:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088d:	83 c4 08             	add    $0x8,%esp
f0100890:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100895:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010089b:	85 c0                	test   %eax,%eax
f010089d:	0f 48 c2             	cmovs  %edx,%eax
f01008a0:	c1 f8 0a             	sar    $0xa,%eax
f01008a3:	50                   	push   %eax
f01008a4:	68 6c 67 10 f0       	push   $0xf010676c
f01008a9:	e8 f6 2d 00 00       	call   f01036a4 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b3:	c9                   	leave  
f01008b4:	c3                   	ret    

f01008b5 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b5:	55                   	push   %ebp
f01008b6:	89 e5                	mov    %esp,%ebp
f01008b8:	56                   	push   %esi
f01008b9:	53                   	push   %ebx
f01008ba:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008bd:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	int *ebp = (int *)read_ebp();

	cprintf("Stack backtrace:\n");
f01008bf:	68 f8 65 10 f0       	push   $0xf01065f8
f01008c4:	e8 db 2d 00 00       	call   f01036a4 <cprintf>
	
	while ((int)ebp != 0x0) {
f01008c9:	83 c4 10             	add    $0x10,%esp
				*(ebp + 5),
				*(ebp + 6));

		// Display more detailed information
		struct Eipdebuginfo info;
		debuginfo_eip(*(ebp + 1), &info);
f01008cc:	8d 75 e0             	lea    -0x20(%ebp),%esi
	// Your code here.
	int *ebp = (int *)read_ebp();

	cprintf("Stack backtrace:\n");
	
	while ((int)ebp != 0x0) {
f01008cf:	eb 4e                	jmp    f010091f <mon_backtrace+0x6a>

		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",
f01008d1:	ff 73 18             	pushl  0x18(%ebx)
f01008d4:	ff 73 14             	pushl  0x14(%ebx)
f01008d7:	ff 73 10             	pushl  0x10(%ebx)
f01008da:	ff 73 0c             	pushl  0xc(%ebx)
f01008dd:	ff 73 08             	pushl  0x8(%ebx)
f01008e0:	ff 73 04             	pushl  0x4(%ebx)
f01008e3:	53                   	push   %ebx
f01008e4:	68 98 67 10 f0       	push   $0xf0106798
f01008e9:	e8 b6 2d 00 00       	call   f01036a4 <cprintf>
				*(ebp + 5),
				*(ebp + 6));

		// Display more detailed information
		struct Eipdebuginfo info;
		debuginfo_eip(*(ebp + 1), &info);
f01008ee:	83 c4 18             	add    $0x18,%esp
f01008f1:	56                   	push   %esi
f01008f2:	ff 73 04             	pushl  0x4(%ebx)
f01008f5:	e8 d9 42 00 00       	call   f0104bd3 <debuginfo_eip>
		cprintf("%s: %.*s + %d (at row %d)\n",
f01008fa:	83 c4 08             	add    $0x8,%esp
f01008fd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100900:	8b 43 04             	mov    0x4(%ebx),%eax
f0100903:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100906:	50                   	push   %eax
f0100907:	ff 75 e8             	pushl  -0x18(%ebp)
f010090a:	ff 75 ec             	pushl  -0x14(%ebp)
f010090d:	ff 75 e0             	pushl  -0x20(%ebp)
f0100910:	68 0a 66 10 f0       	push   $0xf010660a
f0100915:	e8 8a 2d 00 00       	call   f01036a4 <cprintf>
				info.eip_fn_namelen,
				info.eip_fn_name,
				*(ebp + 1) - info.eip_fn_addr,
				info.eip_line);
		
		ebp = (int *)(*ebp);
f010091a:	8b 1b                	mov    (%ebx),%ebx
f010091c:	83 c4 20             	add    $0x20,%esp
	// Your code here.
	int *ebp = (int *)read_ebp();

	cprintf("Stack backtrace:\n");
	
	while ((int)ebp != 0x0) {
f010091f:	85 db                	test   %ebx,%ebx
f0100921:	75 ae                	jne    f01008d1 <mon_backtrace+0x1c>
				info.eip_line);
		
		ebp = (int *)(*ebp);
	}
	return 0;
}
f0100923:	b8 00 00 00 00       	mov    $0x0,%eax
f0100928:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010092b:	5b                   	pop    %ebx
f010092c:	5e                   	pop    %esi
f010092d:	5d                   	pop    %ebp
f010092e:	c3                   	ret    

f010092f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010092f:	55                   	push   %ebp
f0100930:	89 e5                	mov    %esp,%ebp
f0100932:	57                   	push   %edi
f0100933:	56                   	push   %esi
f0100934:	53                   	push   %ebx
f0100935:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100938:	68 cc 67 10 f0       	push   $0xf01067cc
f010093d:	e8 62 2d 00 00       	call   f01036a4 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100942:	c7 04 24 f0 67 10 f0 	movl   $0xf01067f0,(%esp)
f0100949:	e8 56 2d 00 00       	call   f01036a4 <cprintf>

	if (tf != NULL)
f010094e:	83 c4 10             	add    $0x10,%esp
f0100951:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100955:	74 0e                	je     f0100965 <monitor+0x36>
		print_trapframe(tf);
f0100957:	83 ec 0c             	sub    $0xc,%esp
f010095a:	ff 75 08             	pushl  0x8(%ebp)
f010095d:	e8 b8 34 00 00       	call   f0103e1a <print_trapframe>
f0100962:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100965:	83 ec 0c             	sub    $0xc,%esp
f0100968:	68 25 66 10 f0       	push   $0xf0106625
f010096d:	e8 e8 49 00 00       	call   f010535a <readline>
f0100972:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100974:	83 c4 10             	add    $0x10,%esp
f0100977:	85 c0                	test   %eax,%eax
f0100979:	74 ea                	je     f0100965 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010097b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100982:	be 00 00 00 00       	mov    $0x0,%esi
f0100987:	eb 0a                	jmp    f0100993 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100989:	c6 03 00             	movb   $0x0,(%ebx)
f010098c:	89 f7                	mov    %esi,%edi
f010098e:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100991:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100993:	0f b6 03             	movzbl (%ebx),%eax
f0100996:	84 c0                	test   %al,%al
f0100998:	74 63                	je     f01009fd <monitor+0xce>
f010099a:	83 ec 08             	sub    $0x8,%esp
f010099d:	0f be c0             	movsbl %al,%eax
f01009a0:	50                   	push   %eax
f01009a1:	68 29 66 10 f0       	push   $0xf0106629
f01009a6:	e8 e1 4b 00 00       	call   f010558c <strchr>
f01009ab:	83 c4 10             	add    $0x10,%esp
f01009ae:	85 c0                	test   %eax,%eax
f01009b0:	75 d7                	jne    f0100989 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009b2:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009b5:	74 46                	je     f01009fd <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009b7:	83 fe 0f             	cmp    $0xf,%esi
f01009ba:	75 14                	jne    f01009d0 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009bc:	83 ec 08             	sub    $0x8,%esp
f01009bf:	6a 10                	push   $0x10
f01009c1:	68 2e 66 10 f0       	push   $0xf010662e
f01009c6:	e8 d9 2c 00 00       	call   f01036a4 <cprintf>
f01009cb:	83 c4 10             	add    $0x10,%esp
f01009ce:	eb 95                	jmp    f0100965 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009d0:	8d 7e 01             	lea    0x1(%esi),%edi
f01009d3:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009d7:	eb 03                	jmp    f01009dc <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009d9:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009dc:	0f b6 03             	movzbl (%ebx),%eax
f01009df:	84 c0                	test   %al,%al
f01009e1:	74 ae                	je     f0100991 <monitor+0x62>
f01009e3:	83 ec 08             	sub    $0x8,%esp
f01009e6:	0f be c0             	movsbl %al,%eax
f01009e9:	50                   	push   %eax
f01009ea:	68 29 66 10 f0       	push   $0xf0106629
f01009ef:	e8 98 4b 00 00       	call   f010558c <strchr>
f01009f4:	83 c4 10             	add    $0x10,%esp
f01009f7:	85 c0                	test   %eax,%eax
f01009f9:	74 de                	je     f01009d9 <monitor+0xaa>
f01009fb:	eb 94                	jmp    f0100991 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009fd:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a04:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a05:	85 f6                	test   %esi,%esi
f0100a07:	0f 84 58 ff ff ff    	je     f0100965 <monitor+0x36>
f0100a0d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a12:	83 ec 08             	sub    $0x8,%esp
f0100a15:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a18:	ff 34 85 20 68 10 f0 	pushl  -0xfef97e0(,%eax,4)
f0100a1f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a22:	e8 07 4b 00 00       	call   f010552e <strcmp>
f0100a27:	83 c4 10             	add    $0x10,%esp
f0100a2a:	85 c0                	test   %eax,%eax
f0100a2c:	75 21                	jne    f0100a4f <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a2e:	83 ec 04             	sub    $0x4,%esp
f0100a31:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a34:	ff 75 08             	pushl  0x8(%ebp)
f0100a37:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a3a:	52                   	push   %edx
f0100a3b:	56                   	push   %esi
f0100a3c:	ff 14 85 28 68 10 f0 	call   *-0xfef97d8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a43:	83 c4 10             	add    $0x10,%esp
f0100a46:	85 c0                	test   %eax,%eax
f0100a48:	78 25                	js     f0100a6f <monitor+0x140>
f0100a4a:	e9 16 ff ff ff       	jmp    f0100965 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a4f:	83 c3 01             	add    $0x1,%ebx
f0100a52:	83 fb 03             	cmp    $0x3,%ebx
f0100a55:	75 bb                	jne    f0100a12 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a57:	83 ec 08             	sub    $0x8,%esp
f0100a5a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a5d:	68 4b 66 10 f0       	push   $0xf010664b
f0100a62:	e8 3d 2c 00 00       	call   f01036a4 <cprintf>
f0100a67:	83 c4 10             	add    $0x10,%esp
f0100a6a:	e9 f6 fe ff ff       	jmp    f0100965 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a72:	5b                   	pop    %ebx
f0100a73:	5e                   	pop    %esi
f0100a74:	5f                   	pop    %edi
f0100a75:	5d                   	pop    %ebp
f0100a76:	c3                   	ret    

f0100a77 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a77:	55                   	push   %ebp
f0100a78:	89 e5                	mov    %esp,%ebp
f0100a7a:	53                   	push   %ebx
f0100a7b:	83 ec 04             	sub    $0x4,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a7e:	83 3d 38 72 20 f0 00 	cmpl   $0x0,0xf0207238
f0100a85:	75 11                	jne    f0100a98 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a87:	ba 07 a0 24 f0       	mov    $0xf024a007,%edx
f0100a8c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a92:	89 15 38 72 20 f0    	mov    %edx,0xf0207238

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	result = nextfree;
f0100a98:	8b 1d 38 72 20 f0    	mov    0xf0207238,%ebx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100a9e:	8d 94 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edx
f0100aa5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aab:	89 15 38 72 20 f0    	mov    %edx,0xf0207238
	if((uint32_t) nextfree - KERNBASE > npages * PGSIZE)
f0100ab1:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100ab7:	8b 0d 88 7e 20 f0    	mov    0xf0207e88,%ecx
f0100abd:	c1 e1 0c             	shl    $0xc,%ecx
f0100ac0:	39 ca                	cmp    %ecx,%edx
f0100ac2:	76 14                	jbe    f0100ad8 <boot_alloc+0x61>
		panic("Out of memory!\n");
f0100ac4:	83 ec 04             	sub    $0x4,%esp
f0100ac7:	68 44 68 10 f0       	push   $0xf0106844
f0100acc:	6a 6a                	push   $0x6a
f0100ace:	68 54 68 10 f0       	push   $0xf0106854
f0100ad3:	e8 68 f5 ff ff       	call   f0100040 <_panic>
	return result;
}
f0100ad8:	89 d8                	mov    %ebx,%eax
f0100ada:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100add:	c9                   	leave  
f0100ade:	c3                   	ret    

f0100adf <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100adf:	89 d1                	mov    %edx,%ecx
f0100ae1:	c1 e9 16             	shr    $0x16,%ecx
f0100ae4:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ae7:	a8 01                	test   $0x1,%al
f0100ae9:	74 52                	je     f0100b3d <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100aeb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100af0:	89 c1                	mov    %eax,%ecx
f0100af2:	c1 e9 0c             	shr    $0xc,%ecx
f0100af5:	3b 0d 88 7e 20 f0    	cmp    0xf0207e88,%ecx
f0100afb:	72 1b                	jb     f0100b18 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100afd:	55                   	push   %ebp
f0100afe:	89 e5                	mov    %esp,%ebp
f0100b00:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b03:	50                   	push   %eax
f0100b04:	68 a4 62 10 f0       	push   $0xf01062a4
f0100b09:	68 8d 03 00 00       	push   $0x38d
f0100b0e:	68 54 68 10 f0       	push   $0xf0106854
f0100b13:	e8 28 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b18:	c1 ea 0c             	shr    $0xc,%edx
f0100b1b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b21:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b28:	89 c2                	mov    %eax,%edx
f0100b2a:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b2d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b32:	85 d2                	test   %edx,%edx
f0100b34:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b39:	0f 44 c2             	cmove  %edx,%eax
f0100b3c:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b42:	c3                   	ret    

f0100b43 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b43:	55                   	push   %ebp
f0100b44:	89 e5                	mov    %esp,%ebp
f0100b46:	57                   	push   %edi
f0100b47:	56                   	push   %esi
f0100b48:	53                   	push   %ebx
f0100b49:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b4c:	84 c0                	test   %al,%al
f0100b4e:	0f 85 91 02 00 00    	jne    f0100de5 <check_page_free_list+0x2a2>
f0100b54:	e9 9e 02 00 00       	jmp    f0100df7 <check_page_free_list+0x2b4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b59:	83 ec 04             	sub    $0x4,%esp
f0100b5c:	68 b0 6b 10 f0       	push   $0xf0106bb0
f0100b61:	68 c2 02 00 00       	push   $0x2c2
f0100b66:	68 54 68 10 f0       	push   $0xf0106854
f0100b6b:	e8 d0 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b70:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b73:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b76:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b79:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b7c:	89 c2                	mov    %eax,%edx
f0100b7e:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0100b84:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b8a:	0f 95 c2             	setne  %dl
f0100b8d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b90:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b94:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b96:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b9a:	8b 00                	mov    (%eax),%eax
f0100b9c:	85 c0                	test   %eax,%eax
f0100b9e:	75 dc                	jne    f0100b7c <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ba0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ba3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ba9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bac:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100baf:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bb4:	a3 40 72 20 f0       	mov    %eax,0xf0207240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bb9:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bbe:	8b 1d 40 72 20 f0    	mov    0xf0207240,%ebx
f0100bc4:	eb 53                	jmp    f0100c19 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bc6:	89 d8                	mov    %ebx,%eax
f0100bc8:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0100bce:	c1 f8 03             	sar    $0x3,%eax
f0100bd1:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bd4:	89 c2                	mov    %eax,%edx
f0100bd6:	c1 ea 16             	shr    $0x16,%edx
f0100bd9:	39 f2                	cmp    %esi,%edx
f0100bdb:	73 3a                	jae    f0100c17 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bdd:	89 c2                	mov    %eax,%edx
f0100bdf:	c1 ea 0c             	shr    $0xc,%edx
f0100be2:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0100be8:	72 12                	jb     f0100bfc <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bea:	50                   	push   %eax
f0100beb:	68 a4 62 10 f0       	push   $0xf01062a4
f0100bf0:	6a 58                	push   $0x58
f0100bf2:	68 60 68 10 f0       	push   $0xf0106860
f0100bf7:	e8 44 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bfc:	83 ec 04             	sub    $0x4,%esp
f0100bff:	68 80 00 00 00       	push   $0x80
f0100c04:	68 97 00 00 00       	push   $0x97
f0100c09:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c0e:	50                   	push   %eax
f0100c0f:	e8 b5 49 00 00       	call   f01055c9 <memset>
f0100c14:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c17:	8b 1b                	mov    (%ebx),%ebx
f0100c19:	85 db                	test   %ebx,%ebx
f0100c1b:	75 a9                	jne    f0100bc6 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c1d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c22:	e8 50 fe ff ff       	call   f0100a77 <boot_alloc>
f0100c27:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c2a:	8b 15 40 72 20 f0    	mov    0xf0207240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c30:	8b 0d 90 7e 20 f0    	mov    0xf0207e90,%ecx
		assert(pp < pages + npages);
f0100c36:	a1 88 7e 20 f0       	mov    0xf0207e88,%eax
f0100c3b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c3e:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c41:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c44:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c47:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c4c:	e9 52 01 00 00       	jmp    f0100da3 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c51:	39 ca                	cmp    %ecx,%edx
f0100c53:	73 19                	jae    f0100c6e <check_page_free_list+0x12b>
f0100c55:	68 6e 68 10 f0       	push   $0xf010686e
f0100c5a:	68 7a 68 10 f0       	push   $0xf010687a
f0100c5f:	68 dc 02 00 00       	push   $0x2dc
f0100c64:	68 54 68 10 f0       	push   $0xf0106854
f0100c69:	e8 d2 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c6e:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c71:	72 19                	jb     f0100c8c <check_page_free_list+0x149>
f0100c73:	68 8f 68 10 f0       	push   $0xf010688f
f0100c78:	68 7a 68 10 f0       	push   $0xf010687a
f0100c7d:	68 dd 02 00 00       	push   $0x2dd
f0100c82:	68 54 68 10 f0       	push   $0xf0106854
f0100c87:	e8 b4 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c8c:	89 d0                	mov    %edx,%eax
f0100c8e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c91:	a8 07                	test   $0x7,%al
f0100c93:	74 19                	je     f0100cae <check_page_free_list+0x16b>
f0100c95:	68 d4 6b 10 f0       	push   $0xf0106bd4
f0100c9a:	68 7a 68 10 f0       	push   $0xf010687a
f0100c9f:	68 de 02 00 00       	push   $0x2de
f0100ca4:	68 54 68 10 f0       	push   $0xf0106854
f0100ca9:	e8 92 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cae:	c1 f8 03             	sar    $0x3,%eax
f0100cb1:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cb4:	85 c0                	test   %eax,%eax
f0100cb6:	75 19                	jne    f0100cd1 <check_page_free_list+0x18e>
f0100cb8:	68 a3 68 10 f0       	push   $0xf01068a3
f0100cbd:	68 7a 68 10 f0       	push   $0xf010687a
f0100cc2:	68 e1 02 00 00       	push   $0x2e1
f0100cc7:	68 54 68 10 f0       	push   $0xf0106854
f0100ccc:	e8 6f f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cd1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cd6:	75 19                	jne    f0100cf1 <check_page_free_list+0x1ae>
f0100cd8:	68 b4 68 10 f0       	push   $0xf01068b4
f0100cdd:	68 7a 68 10 f0       	push   $0xf010687a
f0100ce2:	68 e2 02 00 00       	push   $0x2e2
f0100ce7:	68 54 68 10 f0       	push   $0xf0106854
f0100cec:	e8 4f f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cf1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cf6:	75 19                	jne    f0100d11 <check_page_free_list+0x1ce>
f0100cf8:	68 08 6c 10 f0       	push   $0xf0106c08
f0100cfd:	68 7a 68 10 f0       	push   $0xf010687a
f0100d02:	68 e3 02 00 00       	push   $0x2e3
f0100d07:	68 54 68 10 f0       	push   $0xf0106854
f0100d0c:	e8 2f f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d11:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d16:	75 19                	jne    f0100d31 <check_page_free_list+0x1ee>
f0100d18:	68 cd 68 10 f0       	push   $0xf01068cd
f0100d1d:	68 7a 68 10 f0       	push   $0xf010687a
f0100d22:	68 e4 02 00 00       	push   $0x2e4
f0100d27:	68 54 68 10 f0       	push   $0xf0106854
f0100d2c:	e8 0f f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d31:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d36:	0f 86 de 00 00 00    	jbe    f0100e1a <check_page_free_list+0x2d7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d3c:	89 c7                	mov    %eax,%edi
f0100d3e:	c1 ef 0c             	shr    $0xc,%edi
f0100d41:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d44:	77 12                	ja     f0100d58 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d46:	50                   	push   %eax
f0100d47:	68 a4 62 10 f0       	push   $0xf01062a4
f0100d4c:	6a 58                	push   $0x58
f0100d4e:	68 60 68 10 f0       	push   $0xf0106860
f0100d53:	e8 e8 f2 ff ff       	call   f0100040 <_panic>
f0100d58:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d5e:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d61:	0f 86 a7 00 00 00    	jbe    f0100e0e <check_page_free_list+0x2cb>
f0100d67:	68 2c 6c 10 f0       	push   $0xf0106c2c
f0100d6c:	68 7a 68 10 f0       	push   $0xf010687a
f0100d71:	68 e5 02 00 00       	push   $0x2e5
f0100d76:	68 54 68 10 f0       	push   $0xf0106854
f0100d7b:	e8 c0 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d80:	68 e7 68 10 f0       	push   $0xf01068e7
f0100d85:	68 7a 68 10 f0       	push   $0xf010687a
f0100d8a:	68 e7 02 00 00       	push   $0x2e7
f0100d8f:	68 54 68 10 f0       	push   $0xf0106854
f0100d94:	e8 a7 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d99:	83 c6 01             	add    $0x1,%esi
f0100d9c:	eb 03                	jmp    f0100da1 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100d9e:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100da1:	8b 12                	mov    (%edx),%edx
f0100da3:	85 d2                	test   %edx,%edx
f0100da5:	0f 85 a6 fe ff ff    	jne    f0100c51 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100dab:	85 f6                	test   %esi,%esi
f0100dad:	7f 19                	jg     f0100dc8 <check_page_free_list+0x285>
f0100daf:	68 04 69 10 f0       	push   $0xf0106904
f0100db4:	68 7a 68 10 f0       	push   $0xf010687a
f0100db9:	68 ef 02 00 00       	push   $0x2ef
f0100dbe:	68 54 68 10 f0       	push   $0xf0106854
f0100dc3:	e8 78 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100dc8:	85 db                	test   %ebx,%ebx
f0100dca:	7f 5e                	jg     f0100e2a <check_page_free_list+0x2e7>
f0100dcc:	68 16 69 10 f0       	push   $0xf0106916
f0100dd1:	68 7a 68 10 f0       	push   $0xf010687a
f0100dd6:	68 f0 02 00 00       	push   $0x2f0
f0100ddb:	68 54 68 10 f0       	push   $0xf0106854
f0100de0:	e8 5b f2 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100de5:	a1 40 72 20 f0       	mov    0xf0207240,%eax
f0100dea:	85 c0                	test   %eax,%eax
f0100dec:	0f 85 7e fd ff ff    	jne    f0100b70 <check_page_free_list+0x2d>
f0100df2:	e9 62 fd ff ff       	jmp    f0100b59 <check_page_free_list+0x16>
f0100df7:	83 3d 40 72 20 f0 00 	cmpl   $0x0,0xf0207240
f0100dfe:	0f 84 55 fd ff ff    	je     f0100b59 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e04:	be 00 04 00 00       	mov    $0x400,%esi
f0100e09:	e9 b0 fd ff ff       	jmp    f0100bbe <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e0e:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e13:	75 89                	jne    f0100d9e <check_page_free_list+0x25b>
f0100e15:	e9 66 ff ff ff       	jmp    f0100d80 <check_page_free_list+0x23d>
f0100e1a:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e1f:	0f 85 74 ff ff ff    	jne    f0100d99 <check_page_free_list+0x256>
f0100e25:	e9 56 ff ff ff       	jmp    f0100d80 <check_page_free_list+0x23d>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e2d:	5b                   	pop    %ebx
f0100e2e:	5e                   	pop    %esi
f0100e2f:	5f                   	pop    %edi
f0100e30:	5d                   	pop    %ebp
f0100e31:	c3                   	ret    

f0100e32 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e32:	55                   	push   %ebp
f0100e33:	89 e5                	mov    %esp,%ebp
f0100e35:	57                   	push   %edi
f0100e36:	56                   	push   %esi
f0100e37:	53                   	push   %ebx
f0100e38:	83 ec 0c             	sub    $0xc,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
f0100e3b:	c7 05 40 72 20 f0 00 	movl   $0x0,0xf0207240
f0100e42:	00 00 00 
	//num_extmem_alloc 
	uint32_t num_extmem_alloc = ((uint32_t) boot_alloc(0) - KERNBASE) / PGSIZE;
f0100e45:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e4a:	e8 28 fc ff ff       	call   f0100a77 <boot_alloc>
			pages[i].pp_link = NULL;
			continue;
		}
		else if (i == MPENTRY_PADDR / PGSIZE)
			continue;
		else if (i >= npages_basemem && i < npages_basemem + num_iohole + num_extmem_alloc) {
f0100e4f:	8b 1d 44 72 20 f0    	mov    0xf0207244,%ebx
f0100e55:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e5a:	c1 e8 0c             	shr    $0xc,%eax
f0100e5d:	8d 74 03 60          	lea    0x60(%ebx,%eax,1),%esi
	//num_extmem_alloc 
	uint32_t num_extmem_alloc = ((uint32_t) boot_alloc(0) - KERNBASE) / PGSIZE;
	//num_iohole 
	uint32_t num_iohole = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;

	for (i = 0; i < npages; i++) {
f0100e61:	bf 00 00 00 00       	mov    $0x0,%edi
f0100e66:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e6b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e70:	eb 63                	jmp    f0100ed5 <page_init+0xa3>
		if (i == 0) {
f0100e72:	85 c0                	test   %eax,%eax
f0100e74:	75 14                	jne    f0100e8a <page_init+0x58>
			pages[i].pp_ref = 1;
f0100e76:	8b 15 90 7e 20 f0    	mov    0xf0207e90,%edx
f0100e7c:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100e82:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
			continue;
f0100e88:	eb 48                	jmp    f0100ed2 <page_init+0xa0>
		}
		else if (i == MPENTRY_PADDR / PGSIZE)
f0100e8a:	83 f8 07             	cmp    $0x7,%eax
f0100e8d:	74 43                	je     f0100ed2 <page_init+0xa0>
			continue;
		else if (i >= npages_basemem && i < npages_basemem + num_iohole + num_extmem_alloc) {
f0100e8f:	39 d8                	cmp    %ebx,%eax
f0100e91:	72 1b                	jb     f0100eae <page_init+0x7c>
f0100e93:	39 f0                	cmp    %esi,%eax
f0100e95:	73 17                	jae    f0100eae <page_init+0x7c>
			pages[i].pp_ref = 1;
f0100e97:	8b 15 90 7e 20 f0    	mov    0xf0207e90,%edx
f0100e9d:	8d 14 c2             	lea    (%edx,%eax,8),%edx
f0100ea0:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100ea6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
			continue;
f0100eac:	eb 24                	jmp    f0100ed2 <page_init+0xa0>
f0100eae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		}
		else {
			pages[i].pp_ref = 0;
f0100eb5:	89 d7                	mov    %edx,%edi
f0100eb7:	03 3d 90 7e 20 f0    	add    0xf0207e90,%edi
f0100ebd:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100ec3:	89 0f                	mov    %ecx,(%edi)
			page_free_list = &pages[i];
f0100ec5:	89 d1                	mov    %edx,%ecx
f0100ec7:	03 0d 90 7e 20 f0    	add    0xf0207e90,%ecx
f0100ecd:	bf 01 00 00 00       	mov    $0x1,%edi
	//num_extmem_alloc 
	uint32_t num_extmem_alloc = ((uint32_t) boot_alloc(0) - KERNBASE) / PGSIZE;
	//num_iohole 
	uint32_t num_iohole = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;

	for (i = 0; i < npages; i++) {
f0100ed2:	83 c0 01             	add    $0x1,%eax
f0100ed5:	3b 05 88 7e 20 f0    	cmp    0xf0207e88,%eax
f0100edb:	72 95                	jb     f0100e72 <page_init+0x40>
f0100edd:	89 f8                	mov    %edi,%eax
f0100edf:	84 c0                	test   %al,%al
f0100ee1:	74 06                	je     f0100ee9 <page_init+0xb7>
f0100ee3:	89 0d 40 72 20 f0    	mov    %ecx,0xf0207240
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100ee9:	83 c4 0c             	add    $0xc,%esp
f0100eec:	5b                   	pop    %ebx
f0100eed:	5e                   	pop    %esi
f0100eee:	5f                   	pop    %edi
f0100eef:	5d                   	pop    %ebp
f0100ef0:	c3                   	ret    

f0100ef1 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ef1:	55                   	push   %ebp
f0100ef2:	89 e5                	mov    %esp,%ebp
f0100ef4:	53                   	push   %ebx
f0100ef5:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo *result;
	if (page_free_list == NULL)
f0100ef8:	8b 1d 40 72 20 f0    	mov    0xf0207240,%ebx
f0100efe:	85 db                	test   %ebx,%ebx
f0100f00:	74 58                	je     f0100f5a <page_alloc+0x69>
		return NULL;

	result = page_free_list;
	page_free_list = page_free_list->pp_link;
f0100f02:	8b 03                	mov    (%ebx),%eax
f0100f04:	a3 40 72 20 f0       	mov    %eax,0xf0207240
	result->pp_link = NULL;
f0100f09:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO)
f0100f0f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f13:	74 45                	je     f0100f5a <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f15:	89 d8                	mov    %ebx,%eax
f0100f17:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0100f1d:	c1 f8 03             	sar    $0x3,%eax
f0100f20:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f23:	89 c2                	mov    %eax,%edx
f0100f25:	c1 ea 0c             	shr    $0xc,%edx
f0100f28:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0100f2e:	72 12                	jb     f0100f42 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f30:	50                   	push   %eax
f0100f31:	68 a4 62 10 f0       	push   $0xf01062a4
f0100f36:	6a 58                	push   $0x58
f0100f38:	68 60 68 10 f0       	push   $0xf0106860
f0100f3d:	e8 fe f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(result), 0, PGSIZE);
f0100f42:	83 ec 04             	sub    $0x4,%esp
f0100f45:	68 00 10 00 00       	push   $0x1000
f0100f4a:	6a 00                	push   $0x0
f0100f4c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f51:	50                   	push   %eax
f0100f52:	e8 72 46 00 00       	call   f01055c9 <memset>
f0100f57:	83 c4 10             	add    $0x10,%esp
	return result;
}
f0100f5a:	89 d8                	mov    %ebx,%eax
f0100f5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f5f:	c9                   	leave  
f0100f60:	c3                   	ret    

f0100f61 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f61:	55                   	push   %ebp
f0100f62:	89 e5                	mov    %esp,%ebp
f0100f64:	83 ec 08             	sub    $0x8,%esp
f0100f67:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	assert(pp->pp_ref == 0);
f0100f6a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f6f:	74 19                	je     f0100f8a <page_free+0x29>
f0100f71:	68 27 69 10 f0       	push   $0xf0106927
f0100f76:	68 7a 68 10 f0       	push   $0xf010687a
f0100f7b:	68 78 01 00 00       	push   $0x178
f0100f80:	68 54 68 10 f0       	push   $0xf0106854
f0100f85:	e8 b6 f0 ff ff       	call   f0100040 <_panic>
	assert(pp->pp_link == NULL);
f0100f8a:	83 38 00             	cmpl   $0x0,(%eax)
f0100f8d:	74 19                	je     f0100fa8 <page_free+0x47>
f0100f8f:	68 37 69 10 f0       	push   $0xf0106937
f0100f94:	68 7a 68 10 f0       	push   $0xf010687a
f0100f99:	68 79 01 00 00       	push   $0x179
f0100f9e:	68 54 68 10 f0       	push   $0xf0106854
f0100fa3:	e8 98 f0 ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f0100fa8:	8b 15 40 72 20 f0    	mov    0xf0207240,%edx
f0100fae:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100fb0:	a3 40 72 20 f0       	mov    %eax,0xf0207240
}
f0100fb5:	c9                   	leave  
f0100fb6:	c3                   	ret    

f0100fb7 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100fb7:	55                   	push   %ebp
f0100fb8:	89 e5                	mov    %esp,%ebp
f0100fba:	83 ec 08             	sub    $0x8,%esp
f0100fbd:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fc0:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fc4:	83 e8 01             	sub    $0x1,%eax
f0100fc7:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fcb:	66 85 c0             	test   %ax,%ax
f0100fce:	75 0c                	jne    f0100fdc <page_decref+0x25>
		page_free(pp);
f0100fd0:	83 ec 0c             	sub    $0xc,%esp
f0100fd3:	52                   	push   %edx
f0100fd4:	e8 88 ff ff ff       	call   f0100f61 <page_free>
f0100fd9:	83 c4 10             	add    $0x10,%esp
}
f0100fdc:	c9                   	leave  
f0100fdd:	c3                   	ret    

f0100fde <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{	
f0100fde:	55                   	push   %ebp
f0100fdf:	89 e5                	mov    %esp,%ebp
f0100fe1:	56                   	push   %esi
f0100fe2:	53                   	push   %ebx
f0100fe3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fe6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	assert(pgdir != NULL);
f0100fe9:	85 c0                	test   %eax,%eax
f0100feb:	75 19                	jne    f0101006 <pgdir_walk+0x28>
f0100fed:	68 4b 69 10 f0       	push   $0xf010694b
f0100ff2:	68 7a 68 10 f0       	push   $0xf010687a
f0100ff7:	68 a3 01 00 00       	push   $0x1a3
f0100ffc:	68 54 68 10 f0       	push   $0xf0106854
f0101001:	e8 3a f0 ff ff       	call   f0100040 <_panic>
	pde_t *pg_dir_entry = NULL;
	pte_t *pg_table = NULL;
	struct PageInfo *new_page = NULL;
	
	pg_dir_entry = &pgdir[PDX(va)];
f0101006:	89 da                	mov    %ebx,%edx
f0101008:	c1 ea 16             	shr    $0x16,%edx
f010100b:	8d 34 90             	lea    (%eax,%edx,4),%esi
       	if (!(*pg_dir_entry & PTE_P)) {
f010100e:	f6 06 01             	testb  $0x1,(%esi)
f0101011:	75 2d                	jne    f0101040 <pgdir_walk+0x62>
		if (!create)
f0101013:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101017:	74 62                	je     f010107b <pgdir_walk+0x9d>
			return NULL;
		else {
			new_page = page_alloc(ALLOC_ZERO);
f0101019:	83 ec 0c             	sub    $0xc,%esp
f010101c:	6a 01                	push   $0x1
f010101e:	e8 ce fe ff ff       	call   f0100ef1 <page_alloc>
			if (new_page == NULL)
f0101023:	83 c4 10             	add    $0x10,%esp
f0101026:	85 c0                	test   %eax,%eax
f0101028:	74 58                	je     f0101082 <pgdir_walk+0xa4>
				return NULL;
			new_page->pp_ref++;
f010102a:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			*pg_dir_entry = (page2pa(new_page) | PTE_P |PTE_W | PTE_U);
f010102f:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0101035:	c1 f8 03             	sar    $0x3,%eax
f0101038:	c1 e0 0c             	shl    $0xc,%eax
f010103b:	83 c8 07             	or     $0x7,%eax
f010103e:	89 06                	mov    %eax,(%esi)
		}
	}

	pg_table = KADDR(PTE_ADDR(*pg_dir_entry));
f0101040:	8b 06                	mov    (%esi),%eax
f0101042:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101047:	89 c2                	mov    %eax,%edx
f0101049:	c1 ea 0c             	shr    $0xc,%edx
f010104c:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0101052:	72 15                	jb     f0101069 <pgdir_walk+0x8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101054:	50                   	push   %eax
f0101055:	68 a4 62 10 f0       	push   $0xf01062a4
f010105a:	68 b5 01 00 00       	push   $0x1b5
f010105f:	68 54 68 10 f0       	push   $0xf0106854
f0101064:	e8 d7 ef ff ff       	call   f0100040 <_panic>
	return &pg_table[PTX(va)];
f0101069:	c1 eb 0a             	shr    $0xa,%ebx
f010106c:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101072:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101079:	eb 0c                	jmp    f0101087 <pgdir_walk+0xa9>
	struct PageInfo *new_page = NULL;
	
	pg_dir_entry = &pgdir[PDX(va)];
       	if (!(*pg_dir_entry & PTE_P)) {
		if (!create)
			return NULL;
f010107b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101080:	eb 05                	jmp    f0101087 <pgdir_walk+0xa9>
		else {
			new_page = page_alloc(ALLOC_ZERO);
			if (new_page == NULL)
				return NULL;
f0101082:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}

	pg_table = KADDR(PTE_ADDR(*pg_dir_entry));
	return &pg_table[PTX(va)];
}
f0101087:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010108a:	5b                   	pop    %ebx
f010108b:	5e                   	pop    %esi
f010108c:	5d                   	pop    %ebp
f010108d:	c3                   	ret    

f010108e <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010108e:	55                   	push   %ebp
f010108f:	89 e5                	mov    %esp,%ebp
f0101091:	57                   	push   %edi
f0101092:	56                   	push   %esi
f0101093:	53                   	push   %ebx
f0101094:	83 ec 1c             	sub    $0x1c,%esp
f0101097:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010109a:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t i;
	pte_t *pg_table_entry = NULL;
	uint32_t page_num = size / PGSIZE;
f010109d:	c1 e9 0c             	shr    $0xc,%ecx
f01010a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

	for (i = 0; i < page_num; i++) {
f01010a3:	89 c3                	mov    %eax,%ebx
f01010a5:	be 00 00 00 00       	mov    $0x0,%esi
		pg_table_entry = pgdir_walk(pgdir, (void *) va, 1);
f01010aa:	89 d7                	mov    %edx,%edi
f01010ac:	29 c7                	sub    %eax,%edi
		assert(pg_table_entry != NULL);
		*pg_table_entry = pa | perm | PTE_P;
f01010ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010b1:	83 c8 01             	or     $0x1,%eax
f01010b4:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	uint32_t i;
	pte_t *pg_table_entry = NULL;
	uint32_t page_num = size / PGSIZE;

	for (i = 0; i < page_num; i++) {
f01010b7:	eb 41                	jmp    f01010fa <boot_map_region+0x6c>
		pg_table_entry = pgdir_walk(pgdir, (void *) va, 1);
f01010b9:	83 ec 04             	sub    $0x4,%esp
f01010bc:	6a 01                	push   $0x1
f01010be:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01010c1:	50                   	push   %eax
f01010c2:	ff 75 e0             	pushl  -0x20(%ebp)
f01010c5:	e8 14 ff ff ff       	call   f0100fde <pgdir_walk>
		assert(pg_table_entry != NULL);
f01010ca:	83 c4 10             	add    $0x10,%esp
f01010cd:	85 c0                	test   %eax,%eax
f01010cf:	75 19                	jne    f01010ea <boot_map_region+0x5c>
f01010d1:	68 59 69 10 f0       	push   $0xf0106959
f01010d6:	68 7a 68 10 f0       	push   $0xf010687a
f01010db:	68 cd 01 00 00       	push   $0x1cd
f01010e0:	68 54 68 10 f0       	push   $0xf0106854
f01010e5:	e8 56 ef ff ff       	call   f0100040 <_panic>
		*pg_table_entry = pa | perm | PTE_P;
f01010ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010ed:	09 da                	or     %ebx,%edx
f01010ef:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
		pa += PGSIZE;
f01010f1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	uint32_t i;
	pte_t *pg_table_entry = NULL;
	uint32_t page_num = size / PGSIZE;

	for (i = 0; i < page_num; i++) {
f01010f7:	83 c6 01             	add    $0x1,%esi
f01010fa:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01010fd:	75 ba                	jne    f01010b9 <boot_map_region+0x2b>
		assert(pg_table_entry != NULL);
		*pg_table_entry = pa | perm | PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f01010ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101102:	5b                   	pop    %ebx
f0101103:	5e                   	pop    %esi
f0101104:	5f                   	pop    %edi
f0101105:	5d                   	pop    %ebp
f0101106:	c3                   	ret    

f0101107 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101107:	55                   	push   %ebp
f0101108:	89 e5                	mov    %esp,%ebp
f010110a:	53                   	push   %ebx
f010110b:	83 ec 08             	sub    $0x8,%esp
f010110e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *entry = NULL;
	struct PageInfo *ret = NULL;
	
	entry = pgdir_walk(pgdir, va, 0);
f0101111:	6a 00                	push   $0x0
f0101113:	ff 75 0c             	pushl  0xc(%ebp)
f0101116:	ff 75 08             	pushl  0x8(%ebp)
f0101119:	e8 c0 fe ff ff       	call   f0100fde <pgdir_walk>
	if (entry == NULL)
f010111e:	83 c4 10             	add    $0x10,%esp
f0101121:	85 c0                	test   %eax,%eax
f0101123:	74 38                	je     f010115d <page_lookup+0x56>
f0101125:	89 c1                	mov    %eax,%ecx
		return NULL;
	if (!(*entry & PTE_P))
f0101127:	8b 10                	mov    (%eax),%edx
f0101129:	f6 c2 01             	test   $0x1,%dl
f010112c:	74 36                	je     f0101164 <page_lookup+0x5d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010112e:	c1 ea 0c             	shr    $0xc,%edx
f0101131:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0101137:	72 14                	jb     f010114d <page_lookup+0x46>
		panic("pa2page called with invalid pa");
f0101139:	83 ec 04             	sub    $0x4,%esp
f010113c:	68 74 6c 10 f0       	push   $0xf0106c74
f0101141:	6a 51                	push   $0x51
f0101143:	68 60 68 10 f0       	push   $0xf0106860
f0101148:	e8 f3 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010114d:	a1 90 7e 20 f0       	mov    0xf0207e90,%eax
f0101152:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return NULL;

	ret = pa2page(PTE_ADDR(*entry));
	if (pte_store != NULL)
f0101155:	85 db                	test   %ebx,%ebx
f0101157:	74 10                	je     f0101169 <page_lookup+0x62>
		*pte_store = entry;
f0101159:	89 0b                	mov    %ecx,(%ebx)
f010115b:	eb 0c                	jmp    f0101169 <page_lookup+0x62>
	pte_t *entry = NULL;
	struct PageInfo *ret = NULL;
	
	entry = pgdir_walk(pgdir, va, 0);
	if (entry == NULL)
		return NULL;
f010115d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101162:	eb 05                	jmp    f0101169 <page_lookup+0x62>
	if (!(*entry & PTE_P))
		return NULL;
f0101164:	b8 00 00 00 00       	mov    $0x0,%eax
	ret = pa2page(PTE_ADDR(*entry));
	if (pte_store != NULL)
		*pte_store = entry;

	return ret;
}
f0101169:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010116c:	c9                   	leave  
f010116d:	c3                   	ret    

f010116e <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010116e:	55                   	push   %ebp
f010116f:	89 e5                	mov    %esp,%ebp
f0101171:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101174:	e8 71 4a 00 00       	call   f0105bea <cpunum>
f0101179:	6b c0 74             	imul   $0x74,%eax,%eax
f010117c:	83 b8 28 80 20 f0 00 	cmpl   $0x0,-0xfdf7fd8(%eax)
f0101183:	74 16                	je     f010119b <tlb_invalidate+0x2d>
f0101185:	e8 60 4a 00 00       	call   f0105bea <cpunum>
f010118a:	6b c0 74             	imul   $0x74,%eax,%eax
f010118d:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0101193:	8b 55 08             	mov    0x8(%ebp),%edx
f0101196:	39 50 60             	cmp    %edx,0x60(%eax)
f0101199:	75 06                	jne    f01011a1 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010119b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010119e:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011a1:	c9                   	leave  
f01011a2:	c3                   	ret    

f01011a3 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011a3:	55                   	push   %ebp
f01011a4:	89 e5                	mov    %esp,%ebp
f01011a6:	56                   	push   %esi
f01011a7:	53                   	push   %ebx
f01011a8:	83 ec 14             	sub    $0x14,%esp
f01011ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011ae:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *entry = NULL;
f01011b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *page = page_lookup(pgdir, va, &entry);
f01011b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011bb:	50                   	push   %eax
f01011bc:	56                   	push   %esi
f01011bd:	53                   	push   %ebx
f01011be:	e8 44 ff ff ff       	call   f0101107 <page_lookup>

	if (page == NULL)
f01011c3:	83 c4 10             	add    $0x10,%esp
f01011c6:	85 c0                	test   %eax,%eax
f01011c8:	74 1f                	je     f01011e9 <page_remove+0x46>
		return;

	page_decref(page);
f01011ca:	83 ec 0c             	sub    $0xc,%esp
f01011cd:	50                   	push   %eax
f01011ce:	e8 e4 fd ff ff       	call   f0100fb7 <page_decref>
	tlb_invalidate(pgdir, va);
f01011d3:	83 c4 08             	add    $0x8,%esp
f01011d6:	56                   	push   %esi
f01011d7:	53                   	push   %ebx
f01011d8:	e8 91 ff ff ff       	call   f010116e <tlb_invalidate>
	*entry = 0;
f01011dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01011e6:	83 c4 10             	add    $0x10,%esp
}
f01011e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011ec:	5b                   	pop    %ebx
f01011ed:	5e                   	pop    %esi
f01011ee:	5d                   	pop    %ebp
f01011ef:	c3                   	ret    

f01011f0 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01011f0:	55                   	push   %ebp
f01011f1:	89 e5                	mov    %esp,%ebp
f01011f3:	57                   	push   %edi
f01011f4:	56                   	push   %esi
f01011f5:	53                   	push   %ebx
f01011f6:	83 ec 10             	sub    $0x10,%esp
f01011f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011fc:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *entry = NULL;
	entry = pgdir_walk(pgdir, va, 1);
f01011ff:	6a 01                	push   $0x1
f0101201:	57                   	push   %edi
f0101202:	ff 75 08             	pushl  0x8(%ebp)
f0101205:	e8 d4 fd ff ff       	call   f0100fde <pgdir_walk>
	
	if (entry == NULL)
f010120a:	83 c4 10             	add    $0x10,%esp
f010120d:	85 c0                	test   %eax,%eax
f010120f:	74 44                	je     f0101255 <page_insert+0x65>
f0101211:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	pp->pp_ref++;
f0101213:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if(*entry & PTE_P) {
f0101218:	f6 00 01             	testb  $0x1,(%eax)
f010121b:	74 1b                	je     f0101238 <page_insert+0x48>
		tlb_invalidate(pgdir, va);
f010121d:	83 ec 08             	sub    $0x8,%esp
f0101220:	57                   	push   %edi
f0101221:	ff 75 08             	pushl  0x8(%ebp)
f0101224:	e8 45 ff ff ff       	call   f010116e <tlb_invalidate>
		page_remove(pgdir, va);
f0101229:	83 c4 08             	add    $0x8,%esp
f010122c:	57                   	push   %edi
f010122d:	ff 75 08             	pushl  0x8(%ebp)
f0101230:	e8 6e ff ff ff       	call   f01011a3 <page_remove>
f0101235:	83 c4 10             	add    $0x10,%esp
	}

	*entry = (page2pa(pp) | perm | PTE_P);
f0101238:	2b 1d 90 7e 20 f0    	sub    0xf0207e90,%ebx
f010123e:	c1 fb 03             	sar    $0x3,%ebx
f0101241:	c1 e3 0c             	shl    $0xc,%ebx
f0101244:	8b 45 14             	mov    0x14(%ebp),%eax
f0101247:	83 c8 01             	or     $0x1,%eax
f010124a:	09 c3                	or     %eax,%ebx
f010124c:	89 1e                	mov    %ebx,(%esi)

	return 0;
f010124e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101253:	eb 05                	jmp    f010125a <page_insert+0x6a>
{
	pte_t *entry = NULL;
	entry = pgdir_walk(pgdir, va, 1);
	
	if (entry == NULL)
		return -E_NO_MEM;
f0101255:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}

	*entry = (page2pa(pp) | perm | PTE_P);

	return 0;
}
f010125a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010125d:	5b                   	pop    %ebx
f010125e:	5e                   	pop    %esi
f010125f:	5f                   	pop    %edi
f0101260:	5d                   	pop    %ebp
f0101261:	c3                   	ret    

f0101262 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101262:	55                   	push   %ebp
f0101263:	89 e5                	mov    %esp,%ebp
f0101265:	56                   	push   %esi
f0101266:	53                   	push   %ebx
	// Where to start the next region.  Initially, this is the
	// beginning of the MMIO region.  Because this is static, its
	// value will be preserved between calls to mmio_map_region
	// (just like nextfree in boot_alloc).
	static uintptr_t base = MMIOBASE;
	void *ret = (void *)base;
f0101267:	8b 35 00 03 12 f0    	mov    0xf0120300,%esi
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f010126d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101270:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101276:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size > MMIOLIM || base + size < base)
f010127c:	89 f0                	mov    %esi,%eax
f010127e:	01 d8                	add    %ebx,%eax
f0101280:	72 07                	jb     f0101289 <mmio_map_region+0x27>
f0101282:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101287:	76 17                	jbe    f01012a0 <mmio_map_region+0x3e>
		panic("mmio_map_region: reservation overflow\n");
f0101289:	83 ec 04             	sub    $0x4,%esp
f010128c:	68 94 6c 10 f0       	push   $0xf0106c94
f0101291:	68 6a 02 00 00       	push   $0x26a
f0101296:	68 54 68 10 f0       	push   $0xf0106854
f010129b:	e8 a0 ed ff ff       	call   f0100040 <_panic>

	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f01012a0:	83 ec 08             	sub    $0x8,%esp
f01012a3:	6a 1a                	push   $0x1a
f01012a5:	ff 75 08             	pushl  0x8(%ebp)
f01012a8:	89 d9                	mov    %ebx,%ecx
f01012aa:	89 f2                	mov    %esi,%edx
f01012ac:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f01012b1:	e8 d8 fd ff ff       	call   f010108e <boot_map_region>
	base += size;
f01012b6:	01 1d 00 03 12 f0    	add    %ebx,0xf0120300

	return ret;
	//panic("mmio_map_region not implemented");
}
f01012bc:	89 f0                	mov    %esi,%eax
f01012be:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012c1:	5b                   	pop    %ebx
f01012c2:	5e                   	pop    %esi
f01012c3:	5d                   	pop    %ebp
f01012c4:	c3                   	ret    

f01012c5 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01012c5:	55                   	push   %ebp
f01012c6:	89 e5                	mov    %esp,%ebp
f01012c8:	57                   	push   %edi
f01012c9:	56                   	push   %esi
f01012ca:	53                   	push   %ebx
f01012cb:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012ce:	6a 15                	push   $0x15
f01012d0:	e8 50 22 00 00       	call   f0103525 <mc146818_read>
f01012d5:	89 c3                	mov    %eax,%ebx
f01012d7:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01012de:	e8 42 22 00 00       	call   f0103525 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01012e3:	c1 e0 08             	shl    $0x8,%eax
f01012e6:	09 d8                	or     %ebx,%eax
f01012e8:	c1 e0 0a             	shl    $0xa,%eax
f01012eb:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012f1:	85 c0                	test   %eax,%eax
f01012f3:	0f 48 c2             	cmovs  %edx,%eax
f01012f6:	c1 f8 0c             	sar    $0xc,%eax
f01012f9:	a3 44 72 20 f0       	mov    %eax,0xf0207244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012fe:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101305:	e8 1b 22 00 00       	call   f0103525 <mc146818_read>
f010130a:	89 c3                	mov    %eax,%ebx
f010130c:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101313:	e8 0d 22 00 00       	call   f0103525 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101318:	c1 e0 08             	shl    $0x8,%eax
f010131b:	09 d8                	or     %ebx,%eax
f010131d:	c1 e0 0a             	shl    $0xa,%eax
f0101320:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101326:	83 c4 10             	add    $0x10,%esp
f0101329:	85 c0                	test   %eax,%eax
f010132b:	0f 48 c2             	cmovs  %edx,%eax
f010132e:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101331:	85 c0                	test   %eax,%eax
f0101333:	74 0e                	je     f0101343 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101335:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010133b:	89 15 88 7e 20 f0    	mov    %edx,0xf0207e88
f0101341:	eb 0c                	jmp    f010134f <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101343:	8b 15 44 72 20 f0    	mov    0xf0207244,%edx
f0101349:	89 15 88 7e 20 f0    	mov    %edx,0xf0207e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010134f:	c1 e0 0c             	shl    $0xc,%eax
f0101352:	c1 e8 0a             	shr    $0xa,%eax
f0101355:	50                   	push   %eax
f0101356:	a1 44 72 20 f0       	mov    0xf0207244,%eax
f010135b:	c1 e0 0c             	shl    $0xc,%eax
f010135e:	c1 e8 0a             	shr    $0xa,%eax
f0101361:	50                   	push   %eax
f0101362:	a1 88 7e 20 f0       	mov    0xf0207e88,%eax
f0101367:	c1 e0 0c             	shl    $0xc,%eax
f010136a:	c1 e8 0a             	shr    $0xa,%eax
f010136d:	50                   	push   %eax
f010136e:	68 bc 6c 10 f0       	push   $0xf0106cbc
f0101373:	e8 2c 23 00 00       	call   f01036a4 <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101378:	b8 00 10 00 00       	mov    $0x1000,%eax
f010137d:	e8 f5 f6 ff ff       	call   f0100a77 <boot_alloc>
f0101382:	a3 8c 7e 20 f0       	mov    %eax,0xf0207e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101387:	83 c4 0c             	add    $0xc,%esp
f010138a:	68 00 10 00 00       	push   $0x1000
f010138f:	6a 00                	push   $0x0
f0101391:	50                   	push   %eax
f0101392:	e8 32 42 00 00       	call   f01055c9 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101397:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010139c:	83 c4 10             	add    $0x10,%esp
f010139f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013a4:	77 15                	ja     f01013bb <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013a6:	50                   	push   %eax
f01013a7:	68 c8 62 10 f0       	push   $0xf01062c8
f01013ac:	68 8d 00 00 00       	push   $0x8d
f01013b1:	68 54 68 10 f0       	push   $0xf0106854
f01013b6:	e8 85 ec ff ff       	call   f0100040 <_panic>
f01013bb:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013c1:	83 ca 05             	or     $0x5,%edx
f01013c4:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	pages = (struct PageInfo*) boot_alloc(npages * sizeof(struct PageInfo));
f01013ca:	a1 88 7e 20 f0       	mov    0xf0207e88,%eax
f01013cf:	c1 e0 03             	shl    $0x3,%eax
f01013d2:	e8 a0 f6 ff ff       	call   f0100a77 <boot_alloc>
f01013d7:	a3 90 7e 20 f0       	mov    %eax,0xf0207e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013dc:	83 ec 04             	sub    $0x4,%esp
f01013df:	8b 0d 88 7e 20 f0    	mov    0xf0207e88,%ecx
f01013e5:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013ec:	52                   	push   %edx
f01013ed:	6a 00                	push   $0x0
f01013ef:	50                   	push   %eax
f01013f0:	e8 d4 41 00 00       	call   f01055c9 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f01013f5:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013fa:	e8 78 f6 ff ff       	call   f0100a77 <boot_alloc>
f01013ff:	a3 48 72 20 f0       	mov    %eax,0xf0207248
	memset(envs, 0, NENV * sizeof(struct Env));
f0101404:	83 c4 0c             	add    $0xc,%esp
f0101407:	68 00 f0 01 00       	push   $0x1f000
f010140c:	6a 00                	push   $0x0
f010140e:	50                   	push   %eax
f010140f:	e8 b5 41 00 00       	call   f01055c9 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101414:	e8 19 fa ff ff       	call   f0100e32 <page_init>

	check_page_free_list(1);
f0101419:	b8 01 00 00 00       	mov    $0x1,%eax
f010141e:	e8 20 f7 ff ff       	call   f0100b43 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101423:	83 c4 10             	add    $0x10,%esp
f0101426:	83 3d 90 7e 20 f0 00 	cmpl   $0x0,0xf0207e90
f010142d:	75 17                	jne    f0101446 <mem_init+0x181>
		panic("'pages' is a null pointer!");
f010142f:	83 ec 04             	sub    $0x4,%esp
f0101432:	68 70 69 10 f0       	push   $0xf0106970
f0101437:	68 01 03 00 00       	push   $0x301
f010143c:	68 54 68 10 f0       	push   $0xf0106854
f0101441:	e8 fa eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101446:	a1 40 72 20 f0       	mov    0xf0207240,%eax
f010144b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101450:	eb 05                	jmp    f0101457 <mem_init+0x192>
		++nfree;
f0101452:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101455:	8b 00                	mov    (%eax),%eax
f0101457:	85 c0                	test   %eax,%eax
f0101459:	75 f7                	jne    f0101452 <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010145b:	83 ec 0c             	sub    $0xc,%esp
f010145e:	6a 00                	push   $0x0
f0101460:	e8 8c fa ff ff       	call   f0100ef1 <page_alloc>
f0101465:	89 c7                	mov    %eax,%edi
f0101467:	83 c4 10             	add    $0x10,%esp
f010146a:	85 c0                	test   %eax,%eax
f010146c:	75 19                	jne    f0101487 <mem_init+0x1c2>
f010146e:	68 8b 69 10 f0       	push   $0xf010698b
f0101473:	68 7a 68 10 f0       	push   $0xf010687a
f0101478:	68 09 03 00 00       	push   $0x309
f010147d:	68 54 68 10 f0       	push   $0xf0106854
f0101482:	e8 b9 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101487:	83 ec 0c             	sub    $0xc,%esp
f010148a:	6a 00                	push   $0x0
f010148c:	e8 60 fa ff ff       	call   f0100ef1 <page_alloc>
f0101491:	89 c6                	mov    %eax,%esi
f0101493:	83 c4 10             	add    $0x10,%esp
f0101496:	85 c0                	test   %eax,%eax
f0101498:	75 19                	jne    f01014b3 <mem_init+0x1ee>
f010149a:	68 a1 69 10 f0       	push   $0xf01069a1
f010149f:	68 7a 68 10 f0       	push   $0xf010687a
f01014a4:	68 0a 03 00 00       	push   $0x30a
f01014a9:	68 54 68 10 f0       	push   $0xf0106854
f01014ae:	e8 8d eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01014b3:	83 ec 0c             	sub    $0xc,%esp
f01014b6:	6a 00                	push   $0x0
f01014b8:	e8 34 fa ff ff       	call   f0100ef1 <page_alloc>
f01014bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014c0:	83 c4 10             	add    $0x10,%esp
f01014c3:	85 c0                	test   %eax,%eax
f01014c5:	75 19                	jne    f01014e0 <mem_init+0x21b>
f01014c7:	68 b7 69 10 f0       	push   $0xf01069b7
f01014cc:	68 7a 68 10 f0       	push   $0xf010687a
f01014d1:	68 0b 03 00 00       	push   $0x30b
f01014d6:	68 54 68 10 f0       	push   $0xf0106854
f01014db:	e8 60 eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014e0:	39 f7                	cmp    %esi,%edi
f01014e2:	75 19                	jne    f01014fd <mem_init+0x238>
f01014e4:	68 cd 69 10 f0       	push   $0xf01069cd
f01014e9:	68 7a 68 10 f0       	push   $0xf010687a
f01014ee:	68 0e 03 00 00       	push   $0x30e
f01014f3:	68 54 68 10 f0       	push   $0xf0106854
f01014f8:	e8 43 eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101500:	39 c6                	cmp    %eax,%esi
f0101502:	74 04                	je     f0101508 <mem_init+0x243>
f0101504:	39 c7                	cmp    %eax,%edi
f0101506:	75 19                	jne    f0101521 <mem_init+0x25c>
f0101508:	68 f8 6c 10 f0       	push   $0xf0106cf8
f010150d:	68 7a 68 10 f0       	push   $0xf010687a
f0101512:	68 0f 03 00 00       	push   $0x30f
f0101517:	68 54 68 10 f0       	push   $0xf0106854
f010151c:	e8 1f eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101521:	8b 0d 90 7e 20 f0    	mov    0xf0207e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101527:	8b 15 88 7e 20 f0    	mov    0xf0207e88,%edx
f010152d:	c1 e2 0c             	shl    $0xc,%edx
f0101530:	89 f8                	mov    %edi,%eax
f0101532:	29 c8                	sub    %ecx,%eax
f0101534:	c1 f8 03             	sar    $0x3,%eax
f0101537:	c1 e0 0c             	shl    $0xc,%eax
f010153a:	39 d0                	cmp    %edx,%eax
f010153c:	72 19                	jb     f0101557 <mem_init+0x292>
f010153e:	68 df 69 10 f0       	push   $0xf01069df
f0101543:	68 7a 68 10 f0       	push   $0xf010687a
f0101548:	68 10 03 00 00       	push   $0x310
f010154d:	68 54 68 10 f0       	push   $0xf0106854
f0101552:	e8 e9 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101557:	89 f0                	mov    %esi,%eax
f0101559:	29 c8                	sub    %ecx,%eax
f010155b:	c1 f8 03             	sar    $0x3,%eax
f010155e:	c1 e0 0c             	shl    $0xc,%eax
f0101561:	39 c2                	cmp    %eax,%edx
f0101563:	77 19                	ja     f010157e <mem_init+0x2b9>
f0101565:	68 fc 69 10 f0       	push   $0xf01069fc
f010156a:	68 7a 68 10 f0       	push   $0xf010687a
f010156f:	68 11 03 00 00       	push   $0x311
f0101574:	68 54 68 10 f0       	push   $0xf0106854
f0101579:	e8 c2 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010157e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101581:	29 c8                	sub    %ecx,%eax
f0101583:	c1 f8 03             	sar    $0x3,%eax
f0101586:	c1 e0 0c             	shl    $0xc,%eax
f0101589:	39 c2                	cmp    %eax,%edx
f010158b:	77 19                	ja     f01015a6 <mem_init+0x2e1>
f010158d:	68 19 6a 10 f0       	push   $0xf0106a19
f0101592:	68 7a 68 10 f0       	push   $0xf010687a
f0101597:	68 12 03 00 00       	push   $0x312
f010159c:	68 54 68 10 f0       	push   $0xf0106854
f01015a1:	e8 9a ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01015a6:	a1 40 72 20 f0       	mov    0xf0207240,%eax
f01015ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01015ae:	c7 05 40 72 20 f0 00 	movl   $0x0,0xf0207240
f01015b5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01015b8:	83 ec 0c             	sub    $0xc,%esp
f01015bb:	6a 00                	push   $0x0
f01015bd:	e8 2f f9 ff ff       	call   f0100ef1 <page_alloc>
f01015c2:	83 c4 10             	add    $0x10,%esp
f01015c5:	85 c0                	test   %eax,%eax
f01015c7:	74 19                	je     f01015e2 <mem_init+0x31d>
f01015c9:	68 36 6a 10 f0       	push   $0xf0106a36
f01015ce:	68 7a 68 10 f0       	push   $0xf010687a
f01015d3:	68 19 03 00 00       	push   $0x319
f01015d8:	68 54 68 10 f0       	push   $0xf0106854
f01015dd:	e8 5e ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015e2:	83 ec 0c             	sub    $0xc,%esp
f01015e5:	57                   	push   %edi
f01015e6:	e8 76 f9 ff ff       	call   f0100f61 <page_free>
	page_free(pp1);
f01015eb:	89 34 24             	mov    %esi,(%esp)
f01015ee:	e8 6e f9 ff ff       	call   f0100f61 <page_free>
	page_free(pp2);
f01015f3:	83 c4 04             	add    $0x4,%esp
f01015f6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015f9:	e8 63 f9 ff ff       	call   f0100f61 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101605:	e8 e7 f8 ff ff       	call   f0100ef1 <page_alloc>
f010160a:	89 c6                	mov    %eax,%esi
f010160c:	83 c4 10             	add    $0x10,%esp
f010160f:	85 c0                	test   %eax,%eax
f0101611:	75 19                	jne    f010162c <mem_init+0x367>
f0101613:	68 8b 69 10 f0       	push   $0xf010698b
f0101618:	68 7a 68 10 f0       	push   $0xf010687a
f010161d:	68 20 03 00 00       	push   $0x320
f0101622:	68 54 68 10 f0       	push   $0xf0106854
f0101627:	e8 14 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010162c:	83 ec 0c             	sub    $0xc,%esp
f010162f:	6a 00                	push   $0x0
f0101631:	e8 bb f8 ff ff       	call   f0100ef1 <page_alloc>
f0101636:	89 c7                	mov    %eax,%edi
f0101638:	83 c4 10             	add    $0x10,%esp
f010163b:	85 c0                	test   %eax,%eax
f010163d:	75 19                	jne    f0101658 <mem_init+0x393>
f010163f:	68 a1 69 10 f0       	push   $0xf01069a1
f0101644:	68 7a 68 10 f0       	push   $0xf010687a
f0101649:	68 21 03 00 00       	push   $0x321
f010164e:	68 54 68 10 f0       	push   $0xf0106854
f0101653:	e8 e8 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101658:	83 ec 0c             	sub    $0xc,%esp
f010165b:	6a 00                	push   $0x0
f010165d:	e8 8f f8 ff ff       	call   f0100ef1 <page_alloc>
f0101662:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101665:	83 c4 10             	add    $0x10,%esp
f0101668:	85 c0                	test   %eax,%eax
f010166a:	75 19                	jne    f0101685 <mem_init+0x3c0>
f010166c:	68 b7 69 10 f0       	push   $0xf01069b7
f0101671:	68 7a 68 10 f0       	push   $0xf010687a
f0101676:	68 22 03 00 00       	push   $0x322
f010167b:	68 54 68 10 f0       	push   $0xf0106854
f0101680:	e8 bb e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101685:	39 fe                	cmp    %edi,%esi
f0101687:	75 19                	jne    f01016a2 <mem_init+0x3dd>
f0101689:	68 cd 69 10 f0       	push   $0xf01069cd
f010168e:	68 7a 68 10 f0       	push   $0xf010687a
f0101693:	68 24 03 00 00       	push   $0x324
f0101698:	68 54 68 10 f0       	push   $0xf0106854
f010169d:	e8 9e e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016a5:	39 c7                	cmp    %eax,%edi
f01016a7:	74 04                	je     f01016ad <mem_init+0x3e8>
f01016a9:	39 c6                	cmp    %eax,%esi
f01016ab:	75 19                	jne    f01016c6 <mem_init+0x401>
f01016ad:	68 f8 6c 10 f0       	push   $0xf0106cf8
f01016b2:	68 7a 68 10 f0       	push   $0xf010687a
f01016b7:	68 25 03 00 00       	push   $0x325
f01016bc:	68 54 68 10 f0       	push   $0xf0106854
f01016c1:	e8 7a e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01016c6:	83 ec 0c             	sub    $0xc,%esp
f01016c9:	6a 00                	push   $0x0
f01016cb:	e8 21 f8 ff ff       	call   f0100ef1 <page_alloc>
f01016d0:	83 c4 10             	add    $0x10,%esp
f01016d3:	85 c0                	test   %eax,%eax
f01016d5:	74 19                	je     f01016f0 <mem_init+0x42b>
f01016d7:	68 36 6a 10 f0       	push   $0xf0106a36
f01016dc:	68 7a 68 10 f0       	push   $0xf010687a
f01016e1:	68 26 03 00 00       	push   $0x326
f01016e6:	68 54 68 10 f0       	push   $0xf0106854
f01016eb:	e8 50 e9 ff ff       	call   f0100040 <_panic>
f01016f0:	89 f0                	mov    %esi,%eax
f01016f2:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f01016f8:	c1 f8 03             	sar    $0x3,%eax
f01016fb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016fe:	89 c2                	mov    %eax,%edx
f0101700:	c1 ea 0c             	shr    $0xc,%edx
f0101703:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0101709:	72 12                	jb     f010171d <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010170b:	50                   	push   %eax
f010170c:	68 a4 62 10 f0       	push   $0xf01062a4
f0101711:	6a 58                	push   $0x58
f0101713:	68 60 68 10 f0       	push   $0xf0106860
f0101718:	e8 23 e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010171d:	83 ec 04             	sub    $0x4,%esp
f0101720:	68 00 10 00 00       	push   $0x1000
f0101725:	6a 01                	push   $0x1
f0101727:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010172c:	50                   	push   %eax
f010172d:	e8 97 3e 00 00       	call   f01055c9 <memset>
	page_free(pp0);
f0101732:	89 34 24             	mov    %esi,(%esp)
f0101735:	e8 27 f8 ff ff       	call   f0100f61 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010173a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101741:	e8 ab f7 ff ff       	call   f0100ef1 <page_alloc>
f0101746:	83 c4 10             	add    $0x10,%esp
f0101749:	85 c0                	test   %eax,%eax
f010174b:	75 19                	jne    f0101766 <mem_init+0x4a1>
f010174d:	68 45 6a 10 f0       	push   $0xf0106a45
f0101752:	68 7a 68 10 f0       	push   $0xf010687a
f0101757:	68 2b 03 00 00       	push   $0x32b
f010175c:	68 54 68 10 f0       	push   $0xf0106854
f0101761:	e8 da e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101766:	39 c6                	cmp    %eax,%esi
f0101768:	74 19                	je     f0101783 <mem_init+0x4be>
f010176a:	68 63 6a 10 f0       	push   $0xf0106a63
f010176f:	68 7a 68 10 f0       	push   $0xf010687a
f0101774:	68 2c 03 00 00       	push   $0x32c
f0101779:	68 54 68 10 f0       	push   $0xf0106854
f010177e:	e8 bd e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101783:	89 f0                	mov    %esi,%eax
f0101785:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f010178b:	c1 f8 03             	sar    $0x3,%eax
f010178e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101791:	89 c2                	mov    %eax,%edx
f0101793:	c1 ea 0c             	shr    $0xc,%edx
f0101796:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f010179c:	72 12                	jb     f01017b0 <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010179e:	50                   	push   %eax
f010179f:	68 a4 62 10 f0       	push   $0xf01062a4
f01017a4:	6a 58                	push   $0x58
f01017a6:	68 60 68 10 f0       	push   $0xf0106860
f01017ab:	e8 90 e8 ff ff       	call   f0100040 <_panic>
f01017b0:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01017b6:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01017bc:	80 38 00             	cmpb   $0x0,(%eax)
f01017bf:	74 19                	je     f01017da <mem_init+0x515>
f01017c1:	68 73 6a 10 f0       	push   $0xf0106a73
f01017c6:	68 7a 68 10 f0       	push   $0xf010687a
f01017cb:	68 2f 03 00 00       	push   $0x32f
f01017d0:	68 54 68 10 f0       	push   $0xf0106854
f01017d5:	e8 66 e8 ff ff       	call   f0100040 <_panic>
f01017da:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017dd:	39 d0                	cmp    %edx,%eax
f01017df:	75 db                	jne    f01017bc <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017e4:	a3 40 72 20 f0       	mov    %eax,0xf0207240

	// free the pages we took
	page_free(pp0);
f01017e9:	83 ec 0c             	sub    $0xc,%esp
f01017ec:	56                   	push   %esi
f01017ed:	e8 6f f7 ff ff       	call   f0100f61 <page_free>
	page_free(pp1);
f01017f2:	89 3c 24             	mov    %edi,(%esp)
f01017f5:	e8 67 f7 ff ff       	call   f0100f61 <page_free>
	page_free(pp2);
f01017fa:	83 c4 04             	add    $0x4,%esp
f01017fd:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101800:	e8 5c f7 ff ff       	call   f0100f61 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101805:	a1 40 72 20 f0       	mov    0xf0207240,%eax
f010180a:	83 c4 10             	add    $0x10,%esp
f010180d:	eb 05                	jmp    f0101814 <mem_init+0x54f>
		--nfree;
f010180f:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101812:	8b 00                	mov    (%eax),%eax
f0101814:	85 c0                	test   %eax,%eax
f0101816:	75 f7                	jne    f010180f <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f0101818:	85 db                	test   %ebx,%ebx
f010181a:	74 19                	je     f0101835 <mem_init+0x570>
f010181c:	68 7d 6a 10 f0       	push   $0xf0106a7d
f0101821:	68 7a 68 10 f0       	push   $0xf010687a
f0101826:	68 3c 03 00 00       	push   $0x33c
f010182b:	68 54 68 10 f0       	push   $0xf0106854
f0101830:	e8 0b e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101835:	83 ec 0c             	sub    $0xc,%esp
f0101838:	68 18 6d 10 f0       	push   $0xf0106d18
f010183d:	e8 62 1e 00 00       	call   f01036a4 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101842:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101849:	e8 a3 f6 ff ff       	call   f0100ef1 <page_alloc>
f010184e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101851:	83 c4 10             	add    $0x10,%esp
f0101854:	85 c0                	test   %eax,%eax
f0101856:	75 19                	jne    f0101871 <mem_init+0x5ac>
f0101858:	68 8b 69 10 f0       	push   $0xf010698b
f010185d:	68 7a 68 10 f0       	push   $0xf010687a
f0101862:	68 a2 03 00 00       	push   $0x3a2
f0101867:	68 54 68 10 f0       	push   $0xf0106854
f010186c:	e8 cf e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101871:	83 ec 0c             	sub    $0xc,%esp
f0101874:	6a 00                	push   $0x0
f0101876:	e8 76 f6 ff ff       	call   f0100ef1 <page_alloc>
f010187b:	89 c3                	mov    %eax,%ebx
f010187d:	83 c4 10             	add    $0x10,%esp
f0101880:	85 c0                	test   %eax,%eax
f0101882:	75 19                	jne    f010189d <mem_init+0x5d8>
f0101884:	68 a1 69 10 f0       	push   $0xf01069a1
f0101889:	68 7a 68 10 f0       	push   $0xf010687a
f010188e:	68 a3 03 00 00       	push   $0x3a3
f0101893:	68 54 68 10 f0       	push   $0xf0106854
f0101898:	e8 a3 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010189d:	83 ec 0c             	sub    $0xc,%esp
f01018a0:	6a 00                	push   $0x0
f01018a2:	e8 4a f6 ff ff       	call   f0100ef1 <page_alloc>
f01018a7:	89 c6                	mov    %eax,%esi
f01018a9:	83 c4 10             	add    $0x10,%esp
f01018ac:	85 c0                	test   %eax,%eax
f01018ae:	75 19                	jne    f01018c9 <mem_init+0x604>
f01018b0:	68 b7 69 10 f0       	push   $0xf01069b7
f01018b5:	68 7a 68 10 f0       	push   $0xf010687a
f01018ba:	68 a4 03 00 00       	push   $0x3a4
f01018bf:	68 54 68 10 f0       	push   $0xf0106854
f01018c4:	e8 77 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018c9:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01018cc:	75 19                	jne    f01018e7 <mem_init+0x622>
f01018ce:	68 cd 69 10 f0       	push   $0xf01069cd
f01018d3:	68 7a 68 10 f0       	push   $0xf010687a
f01018d8:	68 a7 03 00 00       	push   $0x3a7
f01018dd:	68 54 68 10 f0       	push   $0xf0106854
f01018e2:	e8 59 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018e7:	39 c3                	cmp    %eax,%ebx
f01018e9:	74 05                	je     f01018f0 <mem_init+0x62b>
f01018eb:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018ee:	75 19                	jne    f0101909 <mem_init+0x644>
f01018f0:	68 f8 6c 10 f0       	push   $0xf0106cf8
f01018f5:	68 7a 68 10 f0       	push   $0xf010687a
f01018fa:	68 a8 03 00 00       	push   $0x3a8
f01018ff:	68 54 68 10 f0       	push   $0xf0106854
f0101904:	e8 37 e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101909:	a1 40 72 20 f0       	mov    0xf0207240,%eax
f010190e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101911:	c7 05 40 72 20 f0 00 	movl   $0x0,0xf0207240
f0101918:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010191b:	83 ec 0c             	sub    $0xc,%esp
f010191e:	6a 00                	push   $0x0
f0101920:	e8 cc f5 ff ff       	call   f0100ef1 <page_alloc>
f0101925:	83 c4 10             	add    $0x10,%esp
f0101928:	85 c0                	test   %eax,%eax
f010192a:	74 19                	je     f0101945 <mem_init+0x680>
f010192c:	68 36 6a 10 f0       	push   $0xf0106a36
f0101931:	68 7a 68 10 f0       	push   $0xf010687a
f0101936:	68 af 03 00 00       	push   $0x3af
f010193b:	68 54 68 10 f0       	push   $0xf0106854
f0101940:	e8 fb e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101945:	83 ec 04             	sub    $0x4,%esp
f0101948:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010194b:	50                   	push   %eax
f010194c:	6a 00                	push   $0x0
f010194e:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101954:	e8 ae f7 ff ff       	call   f0101107 <page_lookup>
f0101959:	83 c4 10             	add    $0x10,%esp
f010195c:	85 c0                	test   %eax,%eax
f010195e:	74 19                	je     f0101979 <mem_init+0x6b4>
f0101960:	68 38 6d 10 f0       	push   $0xf0106d38
f0101965:	68 7a 68 10 f0       	push   $0xf010687a
f010196a:	68 b2 03 00 00       	push   $0x3b2
f010196f:	68 54 68 10 f0       	push   $0xf0106854
f0101974:	e8 c7 e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101979:	6a 02                	push   $0x2
f010197b:	6a 00                	push   $0x0
f010197d:	53                   	push   %ebx
f010197e:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101984:	e8 67 f8 ff ff       	call   f01011f0 <page_insert>
f0101989:	83 c4 10             	add    $0x10,%esp
f010198c:	85 c0                	test   %eax,%eax
f010198e:	78 19                	js     f01019a9 <mem_init+0x6e4>
f0101990:	68 70 6d 10 f0       	push   $0xf0106d70
f0101995:	68 7a 68 10 f0       	push   $0xf010687a
f010199a:	68 b5 03 00 00       	push   $0x3b5
f010199f:	68 54 68 10 f0       	push   $0xf0106854
f01019a4:	e8 97 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019a9:	83 ec 0c             	sub    $0xc,%esp
f01019ac:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019af:	e8 ad f5 ff ff       	call   f0100f61 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019b4:	6a 02                	push   $0x2
f01019b6:	6a 00                	push   $0x0
f01019b8:	53                   	push   %ebx
f01019b9:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f01019bf:	e8 2c f8 ff ff       	call   f01011f0 <page_insert>
f01019c4:	83 c4 20             	add    $0x20,%esp
f01019c7:	85 c0                	test   %eax,%eax
f01019c9:	74 19                	je     f01019e4 <mem_init+0x71f>
f01019cb:	68 a0 6d 10 f0       	push   $0xf0106da0
f01019d0:	68 7a 68 10 f0       	push   $0xf010687a
f01019d5:	68 b9 03 00 00       	push   $0x3b9
f01019da:	68 54 68 10 f0       	push   $0xf0106854
f01019df:	e8 5c e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019e4:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019ea:	a1 90 7e 20 f0       	mov    0xf0207e90,%eax
f01019ef:	89 c1                	mov    %eax,%ecx
f01019f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019f4:	8b 17                	mov    (%edi),%edx
f01019f6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019ff:	29 c8                	sub    %ecx,%eax
f0101a01:	c1 f8 03             	sar    $0x3,%eax
f0101a04:	c1 e0 0c             	shl    $0xc,%eax
f0101a07:	39 c2                	cmp    %eax,%edx
f0101a09:	74 19                	je     f0101a24 <mem_init+0x75f>
f0101a0b:	68 d0 6d 10 f0       	push   $0xf0106dd0
f0101a10:	68 7a 68 10 f0       	push   $0xf010687a
f0101a15:	68 ba 03 00 00       	push   $0x3ba
f0101a1a:	68 54 68 10 f0       	push   $0xf0106854
f0101a1f:	e8 1c e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a24:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a29:	89 f8                	mov    %edi,%eax
f0101a2b:	e8 af f0 ff ff       	call   f0100adf <check_va2pa>
f0101a30:	89 da                	mov    %ebx,%edx
f0101a32:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a35:	c1 fa 03             	sar    $0x3,%edx
f0101a38:	c1 e2 0c             	shl    $0xc,%edx
f0101a3b:	39 d0                	cmp    %edx,%eax
f0101a3d:	74 19                	je     f0101a58 <mem_init+0x793>
f0101a3f:	68 f8 6d 10 f0       	push   $0xf0106df8
f0101a44:	68 7a 68 10 f0       	push   $0xf010687a
f0101a49:	68 bb 03 00 00       	push   $0x3bb
f0101a4e:	68 54 68 10 f0       	push   $0xf0106854
f0101a53:	e8 e8 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101a58:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a5d:	74 19                	je     f0101a78 <mem_init+0x7b3>
f0101a5f:	68 88 6a 10 f0       	push   $0xf0106a88
f0101a64:	68 7a 68 10 f0       	push   $0xf010687a
f0101a69:	68 bc 03 00 00       	push   $0x3bc
f0101a6e:	68 54 68 10 f0       	push   $0xf0106854
f0101a73:	e8 c8 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a7b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a80:	74 19                	je     f0101a9b <mem_init+0x7d6>
f0101a82:	68 99 6a 10 f0       	push   $0xf0106a99
f0101a87:	68 7a 68 10 f0       	push   $0xf010687a
f0101a8c:	68 bd 03 00 00       	push   $0x3bd
f0101a91:	68 54 68 10 f0       	push   $0xf0106854
f0101a96:	e8 a5 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a9b:	6a 02                	push   $0x2
f0101a9d:	68 00 10 00 00       	push   $0x1000
f0101aa2:	56                   	push   %esi
f0101aa3:	57                   	push   %edi
f0101aa4:	e8 47 f7 ff ff       	call   f01011f0 <page_insert>
f0101aa9:	83 c4 10             	add    $0x10,%esp
f0101aac:	85 c0                	test   %eax,%eax
f0101aae:	74 19                	je     f0101ac9 <mem_init+0x804>
f0101ab0:	68 28 6e 10 f0       	push   $0xf0106e28
f0101ab5:	68 7a 68 10 f0       	push   $0xf010687a
f0101aba:	68 c0 03 00 00       	push   $0x3c0
f0101abf:	68 54 68 10 f0       	push   $0xf0106854
f0101ac4:	e8 77 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ac9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ace:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f0101ad3:	e8 07 f0 ff ff       	call   f0100adf <check_va2pa>
f0101ad8:	89 f2                	mov    %esi,%edx
f0101ada:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0101ae0:	c1 fa 03             	sar    $0x3,%edx
f0101ae3:	c1 e2 0c             	shl    $0xc,%edx
f0101ae6:	39 d0                	cmp    %edx,%eax
f0101ae8:	74 19                	je     f0101b03 <mem_init+0x83e>
f0101aea:	68 64 6e 10 f0       	push   $0xf0106e64
f0101aef:	68 7a 68 10 f0       	push   $0xf010687a
f0101af4:	68 c1 03 00 00       	push   $0x3c1
f0101af9:	68 54 68 10 f0       	push   $0xf0106854
f0101afe:	e8 3d e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b03:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b08:	74 19                	je     f0101b23 <mem_init+0x85e>
f0101b0a:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0101b0f:	68 7a 68 10 f0       	push   $0xf010687a
f0101b14:	68 c2 03 00 00       	push   $0x3c2
f0101b19:	68 54 68 10 f0       	push   $0xf0106854
f0101b1e:	e8 1d e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b23:	83 ec 0c             	sub    $0xc,%esp
f0101b26:	6a 00                	push   $0x0
f0101b28:	e8 c4 f3 ff ff       	call   f0100ef1 <page_alloc>
f0101b2d:	83 c4 10             	add    $0x10,%esp
f0101b30:	85 c0                	test   %eax,%eax
f0101b32:	74 19                	je     f0101b4d <mem_init+0x888>
f0101b34:	68 36 6a 10 f0       	push   $0xf0106a36
f0101b39:	68 7a 68 10 f0       	push   $0xf010687a
f0101b3e:	68 c5 03 00 00       	push   $0x3c5
f0101b43:	68 54 68 10 f0       	push   $0xf0106854
f0101b48:	e8 f3 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b4d:	6a 02                	push   $0x2
f0101b4f:	68 00 10 00 00       	push   $0x1000
f0101b54:	56                   	push   %esi
f0101b55:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101b5b:	e8 90 f6 ff ff       	call   f01011f0 <page_insert>
f0101b60:	83 c4 10             	add    $0x10,%esp
f0101b63:	85 c0                	test   %eax,%eax
f0101b65:	74 19                	je     f0101b80 <mem_init+0x8bb>
f0101b67:	68 28 6e 10 f0       	push   $0xf0106e28
f0101b6c:	68 7a 68 10 f0       	push   $0xf010687a
f0101b71:	68 c8 03 00 00       	push   $0x3c8
f0101b76:	68 54 68 10 f0       	push   $0xf0106854
f0101b7b:	e8 c0 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b80:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b85:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f0101b8a:	e8 50 ef ff ff       	call   f0100adf <check_va2pa>
f0101b8f:	89 f2                	mov    %esi,%edx
f0101b91:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0101b97:	c1 fa 03             	sar    $0x3,%edx
f0101b9a:	c1 e2 0c             	shl    $0xc,%edx
f0101b9d:	39 d0                	cmp    %edx,%eax
f0101b9f:	74 19                	je     f0101bba <mem_init+0x8f5>
f0101ba1:	68 64 6e 10 f0       	push   $0xf0106e64
f0101ba6:	68 7a 68 10 f0       	push   $0xf010687a
f0101bab:	68 c9 03 00 00       	push   $0x3c9
f0101bb0:	68 54 68 10 f0       	push   $0xf0106854
f0101bb5:	e8 86 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101bba:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bbf:	74 19                	je     f0101bda <mem_init+0x915>
f0101bc1:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0101bc6:	68 7a 68 10 f0       	push   $0xf010687a
f0101bcb:	68 ca 03 00 00       	push   $0x3ca
f0101bd0:	68 54 68 10 f0       	push   $0xf0106854
f0101bd5:	e8 66 e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101bda:	83 ec 0c             	sub    $0xc,%esp
f0101bdd:	6a 00                	push   $0x0
f0101bdf:	e8 0d f3 ff ff       	call   f0100ef1 <page_alloc>
f0101be4:	83 c4 10             	add    $0x10,%esp
f0101be7:	85 c0                	test   %eax,%eax
f0101be9:	74 19                	je     f0101c04 <mem_init+0x93f>
f0101beb:	68 36 6a 10 f0       	push   $0xf0106a36
f0101bf0:	68 7a 68 10 f0       	push   $0xf010687a
f0101bf5:	68 ce 03 00 00       	push   $0x3ce
f0101bfa:	68 54 68 10 f0       	push   $0xf0106854
f0101bff:	e8 3c e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c04:	8b 15 8c 7e 20 f0    	mov    0xf0207e8c,%edx
f0101c0a:	8b 02                	mov    (%edx),%eax
f0101c0c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c11:	89 c1                	mov    %eax,%ecx
f0101c13:	c1 e9 0c             	shr    $0xc,%ecx
f0101c16:	3b 0d 88 7e 20 f0    	cmp    0xf0207e88,%ecx
f0101c1c:	72 15                	jb     f0101c33 <mem_init+0x96e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c1e:	50                   	push   %eax
f0101c1f:	68 a4 62 10 f0       	push   $0xf01062a4
f0101c24:	68 d1 03 00 00       	push   $0x3d1
f0101c29:	68 54 68 10 f0       	push   $0xf0106854
f0101c2e:	e8 0d e4 ff ff       	call   f0100040 <_panic>
f0101c33:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c3b:	83 ec 04             	sub    $0x4,%esp
f0101c3e:	6a 00                	push   $0x0
f0101c40:	68 00 10 00 00       	push   $0x1000
f0101c45:	52                   	push   %edx
f0101c46:	e8 93 f3 ff ff       	call   f0100fde <pgdir_walk>
f0101c4b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c4e:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c51:	83 c4 10             	add    $0x10,%esp
f0101c54:	39 d0                	cmp    %edx,%eax
f0101c56:	74 19                	je     f0101c71 <mem_init+0x9ac>
f0101c58:	68 94 6e 10 f0       	push   $0xf0106e94
f0101c5d:	68 7a 68 10 f0       	push   $0xf010687a
f0101c62:	68 d2 03 00 00       	push   $0x3d2
f0101c67:	68 54 68 10 f0       	push   $0xf0106854
f0101c6c:	e8 cf e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c71:	6a 06                	push   $0x6
f0101c73:	68 00 10 00 00       	push   $0x1000
f0101c78:	56                   	push   %esi
f0101c79:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101c7f:	e8 6c f5 ff ff       	call   f01011f0 <page_insert>
f0101c84:	83 c4 10             	add    $0x10,%esp
f0101c87:	85 c0                	test   %eax,%eax
f0101c89:	74 19                	je     f0101ca4 <mem_init+0x9df>
f0101c8b:	68 d4 6e 10 f0       	push   $0xf0106ed4
f0101c90:	68 7a 68 10 f0       	push   $0xf010687a
f0101c95:	68 d5 03 00 00       	push   $0x3d5
f0101c9a:	68 54 68 10 f0       	push   $0xf0106854
f0101c9f:	e8 9c e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ca4:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
f0101caa:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101caf:	89 f8                	mov    %edi,%eax
f0101cb1:	e8 29 ee ff ff       	call   f0100adf <check_va2pa>
f0101cb6:	89 f2                	mov    %esi,%edx
f0101cb8:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0101cbe:	c1 fa 03             	sar    $0x3,%edx
f0101cc1:	c1 e2 0c             	shl    $0xc,%edx
f0101cc4:	39 d0                	cmp    %edx,%eax
f0101cc6:	74 19                	je     f0101ce1 <mem_init+0xa1c>
f0101cc8:	68 64 6e 10 f0       	push   $0xf0106e64
f0101ccd:	68 7a 68 10 f0       	push   $0xf010687a
f0101cd2:	68 d6 03 00 00       	push   $0x3d6
f0101cd7:	68 54 68 10 f0       	push   $0xf0106854
f0101cdc:	e8 5f e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ce1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ce6:	74 19                	je     f0101d01 <mem_init+0xa3c>
f0101ce8:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0101ced:	68 7a 68 10 f0       	push   $0xf010687a
f0101cf2:	68 d7 03 00 00       	push   $0x3d7
f0101cf7:	68 54 68 10 f0       	push   $0xf0106854
f0101cfc:	e8 3f e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d01:	83 ec 04             	sub    $0x4,%esp
f0101d04:	6a 00                	push   $0x0
f0101d06:	68 00 10 00 00       	push   $0x1000
f0101d0b:	57                   	push   %edi
f0101d0c:	e8 cd f2 ff ff       	call   f0100fde <pgdir_walk>
f0101d11:	83 c4 10             	add    $0x10,%esp
f0101d14:	f6 00 04             	testb  $0x4,(%eax)
f0101d17:	75 19                	jne    f0101d32 <mem_init+0xa6d>
f0101d19:	68 14 6f 10 f0       	push   $0xf0106f14
f0101d1e:	68 7a 68 10 f0       	push   $0xf010687a
f0101d23:	68 d8 03 00 00       	push   $0x3d8
f0101d28:	68 54 68 10 f0       	push   $0xf0106854
f0101d2d:	e8 0e e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d32:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f0101d37:	f6 00 04             	testb  $0x4,(%eax)
f0101d3a:	75 19                	jne    f0101d55 <mem_init+0xa90>
f0101d3c:	68 bb 6a 10 f0       	push   $0xf0106abb
f0101d41:	68 7a 68 10 f0       	push   $0xf010687a
f0101d46:	68 d9 03 00 00       	push   $0x3d9
f0101d4b:	68 54 68 10 f0       	push   $0xf0106854
f0101d50:	e8 eb e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d55:	6a 02                	push   $0x2
f0101d57:	68 00 10 00 00       	push   $0x1000
f0101d5c:	56                   	push   %esi
f0101d5d:	50                   	push   %eax
f0101d5e:	e8 8d f4 ff ff       	call   f01011f0 <page_insert>
f0101d63:	83 c4 10             	add    $0x10,%esp
f0101d66:	85 c0                	test   %eax,%eax
f0101d68:	74 19                	je     f0101d83 <mem_init+0xabe>
f0101d6a:	68 28 6e 10 f0       	push   $0xf0106e28
f0101d6f:	68 7a 68 10 f0       	push   $0xf010687a
f0101d74:	68 dc 03 00 00       	push   $0x3dc
f0101d79:	68 54 68 10 f0       	push   $0xf0106854
f0101d7e:	e8 bd e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d83:	83 ec 04             	sub    $0x4,%esp
f0101d86:	6a 00                	push   $0x0
f0101d88:	68 00 10 00 00       	push   $0x1000
f0101d8d:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101d93:	e8 46 f2 ff ff       	call   f0100fde <pgdir_walk>
f0101d98:	83 c4 10             	add    $0x10,%esp
f0101d9b:	f6 00 02             	testb  $0x2,(%eax)
f0101d9e:	75 19                	jne    f0101db9 <mem_init+0xaf4>
f0101da0:	68 48 6f 10 f0       	push   $0xf0106f48
f0101da5:	68 7a 68 10 f0       	push   $0xf010687a
f0101daa:	68 dd 03 00 00       	push   $0x3dd
f0101daf:	68 54 68 10 f0       	push   $0xf0106854
f0101db4:	e8 87 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101db9:	83 ec 04             	sub    $0x4,%esp
f0101dbc:	6a 00                	push   $0x0
f0101dbe:	68 00 10 00 00       	push   $0x1000
f0101dc3:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101dc9:	e8 10 f2 ff ff       	call   f0100fde <pgdir_walk>
f0101dce:	83 c4 10             	add    $0x10,%esp
f0101dd1:	f6 00 04             	testb  $0x4,(%eax)
f0101dd4:	74 19                	je     f0101def <mem_init+0xb2a>
f0101dd6:	68 7c 6f 10 f0       	push   $0xf0106f7c
f0101ddb:	68 7a 68 10 f0       	push   $0xf010687a
f0101de0:	68 de 03 00 00       	push   $0x3de
f0101de5:	68 54 68 10 f0       	push   $0xf0106854
f0101dea:	e8 51 e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101def:	6a 02                	push   $0x2
f0101df1:	68 00 00 40 00       	push   $0x400000
f0101df6:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101df9:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101dff:	e8 ec f3 ff ff       	call   f01011f0 <page_insert>
f0101e04:	83 c4 10             	add    $0x10,%esp
f0101e07:	85 c0                	test   %eax,%eax
f0101e09:	78 19                	js     f0101e24 <mem_init+0xb5f>
f0101e0b:	68 b4 6f 10 f0       	push   $0xf0106fb4
f0101e10:	68 7a 68 10 f0       	push   $0xf010687a
f0101e15:	68 e1 03 00 00       	push   $0x3e1
f0101e1a:	68 54 68 10 f0       	push   $0xf0106854
f0101e1f:	e8 1c e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e24:	6a 02                	push   $0x2
f0101e26:	68 00 10 00 00       	push   $0x1000
f0101e2b:	53                   	push   %ebx
f0101e2c:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101e32:	e8 b9 f3 ff ff       	call   f01011f0 <page_insert>
f0101e37:	83 c4 10             	add    $0x10,%esp
f0101e3a:	85 c0                	test   %eax,%eax
f0101e3c:	74 19                	je     f0101e57 <mem_init+0xb92>
f0101e3e:	68 ec 6f 10 f0       	push   $0xf0106fec
f0101e43:	68 7a 68 10 f0       	push   $0xf010687a
f0101e48:	68 e4 03 00 00       	push   $0x3e4
f0101e4d:	68 54 68 10 f0       	push   $0xf0106854
f0101e52:	e8 e9 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e57:	83 ec 04             	sub    $0x4,%esp
f0101e5a:	6a 00                	push   $0x0
f0101e5c:	68 00 10 00 00       	push   $0x1000
f0101e61:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101e67:	e8 72 f1 ff ff       	call   f0100fde <pgdir_walk>
f0101e6c:	83 c4 10             	add    $0x10,%esp
f0101e6f:	f6 00 04             	testb  $0x4,(%eax)
f0101e72:	74 19                	je     f0101e8d <mem_init+0xbc8>
f0101e74:	68 7c 6f 10 f0       	push   $0xf0106f7c
f0101e79:	68 7a 68 10 f0       	push   $0xf010687a
f0101e7e:	68 e5 03 00 00       	push   $0x3e5
f0101e83:	68 54 68 10 f0       	push   $0xf0106854
f0101e88:	e8 b3 e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e8d:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
f0101e93:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e98:	89 f8                	mov    %edi,%eax
f0101e9a:	e8 40 ec ff ff       	call   f0100adf <check_va2pa>
f0101e9f:	89 c1                	mov    %eax,%ecx
f0101ea1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ea4:	89 d8                	mov    %ebx,%eax
f0101ea6:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0101eac:	c1 f8 03             	sar    $0x3,%eax
f0101eaf:	c1 e0 0c             	shl    $0xc,%eax
f0101eb2:	39 c1                	cmp    %eax,%ecx
f0101eb4:	74 19                	je     f0101ecf <mem_init+0xc0a>
f0101eb6:	68 28 70 10 f0       	push   $0xf0107028
f0101ebb:	68 7a 68 10 f0       	push   $0xf010687a
f0101ec0:	68 e8 03 00 00       	push   $0x3e8
f0101ec5:	68 54 68 10 f0       	push   $0xf0106854
f0101eca:	e8 71 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ecf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ed4:	89 f8                	mov    %edi,%eax
f0101ed6:	e8 04 ec ff ff       	call   f0100adf <check_va2pa>
f0101edb:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ede:	74 19                	je     f0101ef9 <mem_init+0xc34>
f0101ee0:	68 54 70 10 f0       	push   $0xf0107054
f0101ee5:	68 7a 68 10 f0       	push   $0xf010687a
f0101eea:	68 e9 03 00 00       	push   $0x3e9
f0101eef:	68 54 68 10 f0       	push   $0xf0106854
f0101ef4:	e8 47 e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ef9:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101efe:	74 19                	je     f0101f19 <mem_init+0xc54>
f0101f00:	68 d1 6a 10 f0       	push   $0xf0106ad1
f0101f05:	68 7a 68 10 f0       	push   $0xf010687a
f0101f0a:	68 eb 03 00 00       	push   $0x3eb
f0101f0f:	68 54 68 10 f0       	push   $0xf0106854
f0101f14:	e8 27 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f19:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f1e:	74 19                	je     f0101f39 <mem_init+0xc74>
f0101f20:	68 e2 6a 10 f0       	push   $0xf0106ae2
f0101f25:	68 7a 68 10 f0       	push   $0xf010687a
f0101f2a:	68 ec 03 00 00       	push   $0x3ec
f0101f2f:	68 54 68 10 f0       	push   $0xf0106854
f0101f34:	e8 07 e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f39:	83 ec 0c             	sub    $0xc,%esp
f0101f3c:	6a 00                	push   $0x0
f0101f3e:	e8 ae ef ff ff       	call   f0100ef1 <page_alloc>
f0101f43:	83 c4 10             	add    $0x10,%esp
f0101f46:	85 c0                	test   %eax,%eax
f0101f48:	74 04                	je     f0101f4e <mem_init+0xc89>
f0101f4a:	39 c6                	cmp    %eax,%esi
f0101f4c:	74 19                	je     f0101f67 <mem_init+0xca2>
f0101f4e:	68 84 70 10 f0       	push   $0xf0107084
f0101f53:	68 7a 68 10 f0       	push   $0xf010687a
f0101f58:	68 ef 03 00 00       	push   $0x3ef
f0101f5d:	68 54 68 10 f0       	push   $0xf0106854
f0101f62:	e8 d9 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f67:	83 ec 08             	sub    $0x8,%esp
f0101f6a:	6a 00                	push   $0x0
f0101f6c:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101f72:	e8 2c f2 ff ff       	call   f01011a3 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f77:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
f0101f7d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f82:	89 f8                	mov    %edi,%eax
f0101f84:	e8 56 eb ff ff       	call   f0100adf <check_va2pa>
f0101f89:	83 c4 10             	add    $0x10,%esp
f0101f8c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f8f:	74 19                	je     f0101faa <mem_init+0xce5>
f0101f91:	68 a8 70 10 f0       	push   $0xf01070a8
f0101f96:	68 7a 68 10 f0       	push   $0xf010687a
f0101f9b:	68 f3 03 00 00       	push   $0x3f3
f0101fa0:	68 54 68 10 f0       	push   $0xf0106854
f0101fa5:	e8 96 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101faa:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101faf:	89 f8                	mov    %edi,%eax
f0101fb1:	e8 29 eb ff ff       	call   f0100adf <check_va2pa>
f0101fb6:	89 da                	mov    %ebx,%edx
f0101fb8:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0101fbe:	c1 fa 03             	sar    $0x3,%edx
f0101fc1:	c1 e2 0c             	shl    $0xc,%edx
f0101fc4:	39 d0                	cmp    %edx,%eax
f0101fc6:	74 19                	je     f0101fe1 <mem_init+0xd1c>
f0101fc8:	68 54 70 10 f0       	push   $0xf0107054
f0101fcd:	68 7a 68 10 f0       	push   $0xf010687a
f0101fd2:	68 f4 03 00 00       	push   $0x3f4
f0101fd7:	68 54 68 10 f0       	push   $0xf0106854
f0101fdc:	e8 5f e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101fe1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fe6:	74 19                	je     f0102001 <mem_init+0xd3c>
f0101fe8:	68 88 6a 10 f0       	push   $0xf0106a88
f0101fed:	68 7a 68 10 f0       	push   $0xf010687a
f0101ff2:	68 f5 03 00 00       	push   $0x3f5
f0101ff7:	68 54 68 10 f0       	push   $0xf0106854
f0101ffc:	e8 3f e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102001:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102006:	74 19                	je     f0102021 <mem_init+0xd5c>
f0102008:	68 e2 6a 10 f0       	push   $0xf0106ae2
f010200d:	68 7a 68 10 f0       	push   $0xf010687a
f0102012:	68 f6 03 00 00       	push   $0x3f6
f0102017:	68 54 68 10 f0       	push   $0xf0106854
f010201c:	e8 1f e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102021:	6a 00                	push   $0x0
f0102023:	68 00 10 00 00       	push   $0x1000
f0102028:	53                   	push   %ebx
f0102029:	57                   	push   %edi
f010202a:	e8 c1 f1 ff ff       	call   f01011f0 <page_insert>
f010202f:	83 c4 10             	add    $0x10,%esp
f0102032:	85 c0                	test   %eax,%eax
f0102034:	74 19                	je     f010204f <mem_init+0xd8a>
f0102036:	68 cc 70 10 f0       	push   $0xf01070cc
f010203b:	68 7a 68 10 f0       	push   $0xf010687a
f0102040:	68 f9 03 00 00       	push   $0x3f9
f0102045:	68 54 68 10 f0       	push   $0xf0106854
f010204a:	e8 f1 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010204f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102054:	75 19                	jne    f010206f <mem_init+0xdaa>
f0102056:	68 f3 6a 10 f0       	push   $0xf0106af3
f010205b:	68 7a 68 10 f0       	push   $0xf010687a
f0102060:	68 fa 03 00 00       	push   $0x3fa
f0102065:	68 54 68 10 f0       	push   $0xf0106854
f010206a:	e8 d1 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010206f:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102072:	74 19                	je     f010208d <mem_init+0xdc8>
f0102074:	68 ff 6a 10 f0       	push   $0xf0106aff
f0102079:	68 7a 68 10 f0       	push   $0xf010687a
f010207e:	68 fb 03 00 00       	push   $0x3fb
f0102083:	68 54 68 10 f0       	push   $0xf0106854
f0102088:	e8 b3 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010208d:	83 ec 08             	sub    $0x8,%esp
f0102090:	68 00 10 00 00       	push   $0x1000
f0102095:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f010209b:	e8 03 f1 ff ff       	call   f01011a3 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020a0:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
f01020a6:	ba 00 00 00 00       	mov    $0x0,%edx
f01020ab:	89 f8                	mov    %edi,%eax
f01020ad:	e8 2d ea ff ff       	call   f0100adf <check_va2pa>
f01020b2:	83 c4 10             	add    $0x10,%esp
f01020b5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020b8:	74 19                	je     f01020d3 <mem_init+0xe0e>
f01020ba:	68 a8 70 10 f0       	push   $0xf01070a8
f01020bf:	68 7a 68 10 f0       	push   $0xf010687a
f01020c4:	68 ff 03 00 00       	push   $0x3ff
f01020c9:	68 54 68 10 f0       	push   $0xf0106854
f01020ce:	e8 6d df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01020d3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020d8:	89 f8                	mov    %edi,%eax
f01020da:	e8 00 ea ff ff       	call   f0100adf <check_va2pa>
f01020df:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020e2:	74 19                	je     f01020fd <mem_init+0xe38>
f01020e4:	68 04 71 10 f0       	push   $0xf0107104
f01020e9:	68 7a 68 10 f0       	push   $0xf010687a
f01020ee:	68 00 04 00 00       	push   $0x400
f01020f3:	68 54 68 10 f0       	push   $0xf0106854
f01020f8:	e8 43 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01020fd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102102:	74 19                	je     f010211d <mem_init+0xe58>
f0102104:	68 14 6b 10 f0       	push   $0xf0106b14
f0102109:	68 7a 68 10 f0       	push   $0xf010687a
f010210e:	68 01 04 00 00       	push   $0x401
f0102113:	68 54 68 10 f0       	push   $0xf0106854
f0102118:	e8 23 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010211d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102122:	74 19                	je     f010213d <mem_init+0xe78>
f0102124:	68 e2 6a 10 f0       	push   $0xf0106ae2
f0102129:	68 7a 68 10 f0       	push   $0xf010687a
f010212e:	68 02 04 00 00       	push   $0x402
f0102133:	68 54 68 10 f0       	push   $0xf0106854
f0102138:	e8 03 df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010213d:	83 ec 0c             	sub    $0xc,%esp
f0102140:	6a 00                	push   $0x0
f0102142:	e8 aa ed ff ff       	call   f0100ef1 <page_alloc>
f0102147:	83 c4 10             	add    $0x10,%esp
f010214a:	39 c3                	cmp    %eax,%ebx
f010214c:	75 04                	jne    f0102152 <mem_init+0xe8d>
f010214e:	85 c0                	test   %eax,%eax
f0102150:	75 19                	jne    f010216b <mem_init+0xea6>
f0102152:	68 2c 71 10 f0       	push   $0xf010712c
f0102157:	68 7a 68 10 f0       	push   $0xf010687a
f010215c:	68 05 04 00 00       	push   $0x405
f0102161:	68 54 68 10 f0       	push   $0xf0106854
f0102166:	e8 d5 de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010216b:	83 ec 0c             	sub    $0xc,%esp
f010216e:	6a 00                	push   $0x0
f0102170:	e8 7c ed ff ff       	call   f0100ef1 <page_alloc>
f0102175:	83 c4 10             	add    $0x10,%esp
f0102178:	85 c0                	test   %eax,%eax
f010217a:	74 19                	je     f0102195 <mem_init+0xed0>
f010217c:	68 36 6a 10 f0       	push   $0xf0106a36
f0102181:	68 7a 68 10 f0       	push   $0xf010687a
f0102186:	68 08 04 00 00       	push   $0x408
f010218b:	68 54 68 10 f0       	push   $0xf0106854
f0102190:	e8 ab de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102195:	8b 0d 8c 7e 20 f0    	mov    0xf0207e8c,%ecx
f010219b:	8b 11                	mov    (%ecx),%edx
f010219d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021a6:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f01021ac:	c1 f8 03             	sar    $0x3,%eax
f01021af:	c1 e0 0c             	shl    $0xc,%eax
f01021b2:	39 c2                	cmp    %eax,%edx
f01021b4:	74 19                	je     f01021cf <mem_init+0xf0a>
f01021b6:	68 d0 6d 10 f0       	push   $0xf0106dd0
f01021bb:	68 7a 68 10 f0       	push   $0xf010687a
f01021c0:	68 0b 04 00 00       	push   $0x40b
f01021c5:	68 54 68 10 f0       	push   $0xf0106854
f01021ca:	e8 71 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01021cf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01021d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021d8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021dd:	74 19                	je     f01021f8 <mem_init+0xf33>
f01021df:	68 99 6a 10 f0       	push   $0xf0106a99
f01021e4:	68 7a 68 10 f0       	push   $0xf010687a
f01021e9:	68 0d 04 00 00       	push   $0x40d
f01021ee:	68 54 68 10 f0       	push   $0xf0106854
f01021f3:	e8 48 de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01021f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021fb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102201:	83 ec 0c             	sub    $0xc,%esp
f0102204:	50                   	push   %eax
f0102205:	e8 57 ed ff ff       	call   f0100f61 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010220a:	83 c4 0c             	add    $0xc,%esp
f010220d:	6a 01                	push   $0x1
f010220f:	68 00 10 40 00       	push   $0x401000
f0102214:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f010221a:	e8 bf ed ff ff       	call   f0100fde <pgdir_walk>
f010221f:	89 c7                	mov    %eax,%edi
f0102221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102224:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f0102229:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010222c:	8b 40 04             	mov    0x4(%eax),%eax
f010222f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102234:	8b 0d 88 7e 20 f0    	mov    0xf0207e88,%ecx
f010223a:	89 c2                	mov    %eax,%edx
f010223c:	c1 ea 0c             	shr    $0xc,%edx
f010223f:	83 c4 10             	add    $0x10,%esp
f0102242:	39 ca                	cmp    %ecx,%edx
f0102244:	72 15                	jb     f010225b <mem_init+0xf96>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102246:	50                   	push   %eax
f0102247:	68 a4 62 10 f0       	push   $0xf01062a4
f010224c:	68 14 04 00 00       	push   $0x414
f0102251:	68 54 68 10 f0       	push   $0xf0106854
f0102256:	e8 e5 dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010225b:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102260:	39 c7                	cmp    %eax,%edi
f0102262:	74 19                	je     f010227d <mem_init+0xfb8>
f0102264:	68 25 6b 10 f0       	push   $0xf0106b25
f0102269:	68 7a 68 10 f0       	push   $0xf010687a
f010226e:	68 15 04 00 00       	push   $0x415
f0102273:	68 54 68 10 f0       	push   $0xf0106854
f0102278:	e8 c3 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010227d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102280:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102287:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010228a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102290:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0102296:	c1 f8 03             	sar    $0x3,%eax
f0102299:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010229c:	89 c2                	mov    %eax,%edx
f010229e:	c1 ea 0c             	shr    $0xc,%edx
f01022a1:	39 d1                	cmp    %edx,%ecx
f01022a3:	77 12                	ja     f01022b7 <mem_init+0xff2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022a5:	50                   	push   %eax
f01022a6:	68 a4 62 10 f0       	push   $0xf01062a4
f01022ab:	6a 58                	push   $0x58
f01022ad:	68 60 68 10 f0       	push   $0xf0106860
f01022b2:	e8 89 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01022b7:	83 ec 04             	sub    $0x4,%esp
f01022ba:	68 00 10 00 00       	push   $0x1000
f01022bf:	68 ff 00 00 00       	push   $0xff
f01022c4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01022c9:	50                   	push   %eax
f01022ca:	e8 fa 32 00 00       	call   f01055c9 <memset>
	page_free(pp0);
f01022cf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01022d2:	89 3c 24             	mov    %edi,(%esp)
f01022d5:	e8 87 ec ff ff       	call   f0100f61 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01022da:	83 c4 0c             	add    $0xc,%esp
f01022dd:	6a 01                	push   $0x1
f01022df:	6a 00                	push   $0x0
f01022e1:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f01022e7:	e8 f2 ec ff ff       	call   f0100fde <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022ec:	89 fa                	mov    %edi,%edx
f01022ee:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f01022f4:	c1 fa 03             	sar    $0x3,%edx
f01022f7:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022fa:	89 d0                	mov    %edx,%eax
f01022fc:	c1 e8 0c             	shr    $0xc,%eax
f01022ff:	83 c4 10             	add    $0x10,%esp
f0102302:	3b 05 88 7e 20 f0    	cmp    0xf0207e88,%eax
f0102308:	72 12                	jb     f010231c <mem_init+0x1057>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010230a:	52                   	push   %edx
f010230b:	68 a4 62 10 f0       	push   $0xf01062a4
f0102310:	6a 58                	push   $0x58
f0102312:	68 60 68 10 f0       	push   $0xf0106860
f0102317:	e8 24 dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010231c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102322:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102325:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010232b:	f6 00 01             	testb  $0x1,(%eax)
f010232e:	74 19                	je     f0102349 <mem_init+0x1084>
f0102330:	68 3d 6b 10 f0       	push   $0xf0106b3d
f0102335:	68 7a 68 10 f0       	push   $0xf010687a
f010233a:	68 1f 04 00 00       	push   $0x41f
f010233f:	68 54 68 10 f0       	push   $0xf0106854
f0102344:	e8 f7 dc ff ff       	call   f0100040 <_panic>
f0102349:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010234c:	39 d0                	cmp    %edx,%eax
f010234e:	75 db                	jne    f010232b <mem_init+0x1066>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102350:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f0102355:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010235b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010235e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102364:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102367:	89 0d 40 72 20 f0    	mov    %ecx,0xf0207240

	// free the pages we took
	page_free(pp0);
f010236d:	83 ec 0c             	sub    $0xc,%esp
f0102370:	50                   	push   %eax
f0102371:	e8 eb eb ff ff       	call   f0100f61 <page_free>
	page_free(pp1);
f0102376:	89 1c 24             	mov    %ebx,(%esp)
f0102379:	e8 e3 eb ff ff       	call   f0100f61 <page_free>
	page_free(pp2);
f010237e:	89 34 24             	mov    %esi,(%esp)
f0102381:	e8 db eb ff ff       	call   f0100f61 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102386:	83 c4 08             	add    $0x8,%esp
f0102389:	68 01 10 00 00       	push   $0x1001
f010238e:	6a 00                	push   $0x0
f0102390:	e8 cd ee ff ff       	call   f0101262 <mmio_map_region>
f0102395:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102397:	83 c4 08             	add    $0x8,%esp
f010239a:	68 00 10 00 00       	push   $0x1000
f010239f:	6a 00                	push   $0x0
f01023a1:	e8 bc ee ff ff       	call   f0101262 <mmio_map_region>
f01023a6:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01023a8:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01023ae:	83 c4 10             	add    $0x10,%esp
f01023b1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01023b7:	76 07                	jbe    f01023c0 <mem_init+0x10fb>
f01023b9:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01023be:	76 19                	jbe    f01023d9 <mem_init+0x1114>
f01023c0:	68 50 71 10 f0       	push   $0xf0107150
f01023c5:	68 7a 68 10 f0       	push   $0xf010687a
f01023ca:	68 2f 04 00 00       	push   $0x42f
f01023cf:	68 54 68 10 f0       	push   $0xf0106854
f01023d4:	e8 67 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01023d9:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01023df:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01023e5:	77 08                	ja     f01023ef <mem_init+0x112a>
f01023e7:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01023ed:	77 19                	ja     f0102408 <mem_init+0x1143>
f01023ef:	68 78 71 10 f0       	push   $0xf0107178
f01023f4:	68 7a 68 10 f0       	push   $0xf010687a
f01023f9:	68 30 04 00 00       	push   $0x430
f01023fe:	68 54 68 10 f0       	push   $0xf0106854
f0102403:	e8 38 dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102408:	89 da                	mov    %ebx,%edx
f010240a:	09 f2                	or     %esi,%edx
f010240c:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102412:	74 19                	je     f010242d <mem_init+0x1168>
f0102414:	68 a0 71 10 f0       	push   $0xf01071a0
f0102419:	68 7a 68 10 f0       	push   $0xf010687a
f010241e:	68 32 04 00 00       	push   $0x432
f0102423:	68 54 68 10 f0       	push   $0xf0106854
f0102428:	e8 13 dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010242d:	39 c6                	cmp    %eax,%esi
f010242f:	73 19                	jae    f010244a <mem_init+0x1185>
f0102431:	68 54 6b 10 f0       	push   $0xf0106b54
f0102436:	68 7a 68 10 f0       	push   $0xf010687a
f010243b:	68 34 04 00 00       	push   $0x434
f0102440:	68 54 68 10 f0       	push   $0xf0106854
f0102445:	e8 f6 db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010244a:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
f0102450:	89 da                	mov    %ebx,%edx
f0102452:	89 f8                	mov    %edi,%eax
f0102454:	e8 86 e6 ff ff       	call   f0100adf <check_va2pa>
f0102459:	85 c0                	test   %eax,%eax
f010245b:	74 19                	je     f0102476 <mem_init+0x11b1>
f010245d:	68 c8 71 10 f0       	push   $0xf01071c8
f0102462:	68 7a 68 10 f0       	push   $0xf010687a
f0102467:	68 36 04 00 00       	push   $0x436
f010246c:	68 54 68 10 f0       	push   $0xf0106854
f0102471:	e8 ca db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102476:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010247c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010247f:	89 c2                	mov    %eax,%edx
f0102481:	89 f8                	mov    %edi,%eax
f0102483:	e8 57 e6 ff ff       	call   f0100adf <check_va2pa>
f0102488:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010248d:	74 19                	je     f01024a8 <mem_init+0x11e3>
f010248f:	68 ec 71 10 f0       	push   $0xf01071ec
f0102494:	68 7a 68 10 f0       	push   $0xf010687a
f0102499:	68 37 04 00 00       	push   $0x437
f010249e:	68 54 68 10 f0       	push   $0xf0106854
f01024a3:	e8 98 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01024a8:	89 f2                	mov    %esi,%edx
f01024aa:	89 f8                	mov    %edi,%eax
f01024ac:	e8 2e e6 ff ff       	call   f0100adf <check_va2pa>
f01024b1:	85 c0                	test   %eax,%eax
f01024b3:	74 19                	je     f01024ce <mem_init+0x1209>
f01024b5:	68 1c 72 10 f0       	push   $0xf010721c
f01024ba:	68 7a 68 10 f0       	push   $0xf010687a
f01024bf:	68 38 04 00 00       	push   $0x438
f01024c4:	68 54 68 10 f0       	push   $0xf0106854
f01024c9:	e8 72 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01024ce:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01024d4:	89 f8                	mov    %edi,%eax
f01024d6:	e8 04 e6 ff ff       	call   f0100adf <check_va2pa>
f01024db:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024de:	74 19                	je     f01024f9 <mem_init+0x1234>
f01024e0:	68 40 72 10 f0       	push   $0xf0107240
f01024e5:	68 7a 68 10 f0       	push   $0xf010687a
f01024ea:	68 39 04 00 00       	push   $0x439
f01024ef:	68 54 68 10 f0       	push   $0xf0106854
f01024f4:	e8 47 db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024f9:	83 ec 04             	sub    $0x4,%esp
f01024fc:	6a 00                	push   $0x0
f01024fe:	53                   	push   %ebx
f01024ff:	57                   	push   %edi
f0102500:	e8 d9 ea ff ff       	call   f0100fde <pgdir_walk>
f0102505:	83 c4 10             	add    $0x10,%esp
f0102508:	f6 00 1a             	testb  $0x1a,(%eax)
f010250b:	75 19                	jne    f0102526 <mem_init+0x1261>
f010250d:	68 6c 72 10 f0       	push   $0xf010726c
f0102512:	68 7a 68 10 f0       	push   $0xf010687a
f0102517:	68 3b 04 00 00       	push   $0x43b
f010251c:	68 54 68 10 f0       	push   $0xf0106854
f0102521:	e8 1a db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102526:	83 ec 04             	sub    $0x4,%esp
f0102529:	6a 00                	push   $0x0
f010252b:	53                   	push   %ebx
f010252c:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102532:	e8 a7 ea ff ff       	call   f0100fde <pgdir_walk>
f0102537:	8b 00                	mov    (%eax),%eax
f0102539:	83 c4 10             	add    $0x10,%esp
f010253c:	83 e0 04             	and    $0x4,%eax
f010253f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102542:	74 19                	je     f010255d <mem_init+0x1298>
f0102544:	68 b0 72 10 f0       	push   $0xf01072b0
f0102549:	68 7a 68 10 f0       	push   $0xf010687a
f010254e:	68 3c 04 00 00       	push   $0x43c
f0102553:	68 54 68 10 f0       	push   $0xf0106854
f0102558:	e8 e3 da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010255d:	83 ec 04             	sub    $0x4,%esp
f0102560:	6a 00                	push   $0x0
f0102562:	53                   	push   %ebx
f0102563:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102569:	e8 70 ea ff ff       	call   f0100fde <pgdir_walk>
f010256e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102574:	83 c4 0c             	add    $0xc,%esp
f0102577:	6a 00                	push   $0x0
f0102579:	ff 75 d4             	pushl  -0x2c(%ebp)
f010257c:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102582:	e8 57 ea ff ff       	call   f0100fde <pgdir_walk>
f0102587:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010258d:	83 c4 0c             	add    $0xc,%esp
f0102590:	6a 00                	push   $0x0
f0102592:	56                   	push   %esi
f0102593:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102599:	e8 40 ea ff ff       	call   f0100fde <pgdir_walk>
f010259e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01025a4:	c7 04 24 66 6b 10 f0 	movl   $0xf0106b66,(%esp)
f01025ab:	e8 f4 10 00 00       	call   f01036a4 <cprintf>
	// Map 'pages' read-only by the user at linear address UPAGES
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f01025b0:	a1 90 7e 20 f0       	mov    0xf0207e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025b5:	83 c4 10             	add    $0x10,%esp
f01025b8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025bd:	77 15                	ja     f01025d4 <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025bf:	50                   	push   %eax
f01025c0:	68 c8 62 10 f0       	push   $0xf01062c8
f01025c5:	68 b2 00 00 00       	push   $0xb2
f01025ca:	68 54 68 10 f0       	push   $0xf0106854
f01025cf:	e8 6c da ff ff       	call   f0100040 <_panic>
f01025d4:	83 ec 08             	sub    $0x8,%esp
f01025d7:	6a 04                	push   $0x4
f01025d9:	05 00 00 00 10       	add    $0x10000000,%eax
f01025de:	50                   	push   %eax
f01025df:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01025e4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025e9:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f01025ee:	e8 9b ea ff ff       	call   f010108e <boot_map_region>
	// Map the 'envs' array read-only by the user at linear address UENVS
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01025f3:	a1 48 72 20 f0       	mov    0xf0207248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025f8:	83 c4 10             	add    $0x10,%esp
f01025fb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102600:	77 15                	ja     f0102617 <mem_init+0x1352>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102602:	50                   	push   %eax
f0102603:	68 c8 62 10 f0       	push   $0xf01062c8
f0102608:	68 ba 00 00 00       	push   $0xba
f010260d:	68 54 68 10 f0       	push   $0xf0106854
f0102612:	e8 29 da ff ff       	call   f0100040 <_panic>
f0102617:	83 ec 08             	sub    $0x8,%esp
f010261a:	6a 04                	push   $0x4
f010261c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102621:	50                   	push   %eax
f0102622:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102627:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010262c:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f0102631:	e8 58 ea ff ff       	call   f010108e <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102636:	83 c4 10             	add    $0x10,%esp
f0102639:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f010263e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102643:	77 15                	ja     f010265a <mem_init+0x1395>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102645:	50                   	push   %eax
f0102646:	68 c8 62 10 f0       	push   $0xf01062c8
f010264b:	68 c6 00 00 00       	push   $0xc6
f0102650:	68 54 68 10 f0       	push   $0xf0106854
f0102655:	e8 e6 d9 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010265a:	83 ec 08             	sub    $0x8,%esp
f010265d:	6a 02                	push   $0x2
f010265f:	68 00 60 11 00       	push   $0x116000
f0102664:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102669:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010266e:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f0102673:	e8 16 ea ff ff       	call   f010108e <boot_map_region>
	// Ie.  the VA range [KERNBASE, 2^32) should map to
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f0102678:	83 c4 08             	add    $0x8,%esp
f010267b:	6a 02                	push   $0x2
f010267d:	6a 00                	push   $0x0
f010267f:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102684:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102689:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f010268e:	e8 fb e9 ff ff       	call   f010108e <boot_map_region>
f0102693:	c7 45 c4 00 90 20 f0 	movl   $0xf0209000,-0x3c(%ebp)
f010269a:	83 c4 10             	add    $0x10,%esp
f010269d:	bb 00 90 20 f0       	mov    $0xf0209000,%ebx
f01026a2:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026a7:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01026ad:	77 15                	ja     f01026c4 <mem_init+0x13ff>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026af:	53                   	push   %ebx
f01026b0:	68 c8 62 10 f0       	push   $0xf01062c8
f01026b5:	68 0c 01 00 00       	push   $0x10c
f01026ba:	68 54 68 10 f0       	push   $0xf0106854
f01026bf:	e8 7c d9 ff ff       	call   f0100040 <_panic>
	int i;
	uintptr_t kstacktop_i;

	for (i = 0; i < NCPU; i++) {
		kstacktop_i = KSTACKTOP - i * (KSTKGAP + KSTKSIZE);
		boot_map_region(kern_pgdir,
f01026c4:	83 ec 08             	sub    $0x8,%esp
f01026c7:	6a 03                	push   $0x3
f01026c9:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01026cf:	50                   	push   %eax
f01026d0:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026d5:	89 f2                	mov    %esi,%edx
f01026d7:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f01026dc:	e8 ad e9 ff ff       	call   f010108e <boot_map_region>
f01026e1:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01026e7:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:
	int i;
	uintptr_t kstacktop_i;

	for (i = 0; i < NCPU; i++) {
f01026ed:	83 c4 10             	add    $0x10,%esp
f01026f0:	b8 00 90 24 f0       	mov    $0xf0249000,%eax
f01026f5:	39 d8                	cmp    %ebx,%eax
f01026f7:	75 ae                	jne    f01026a7 <mem_init+0x13e2>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026f9:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026ff:	a1 88 7e 20 f0       	mov    0xf0207e88,%eax
f0102704:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102707:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010270e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102713:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102716:	8b 35 90 7e 20 f0    	mov    0xf0207e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010271c:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010271f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102724:	eb 55                	jmp    f010277b <mem_init+0x14b6>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102726:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010272c:	89 f8                	mov    %edi,%eax
f010272e:	e8 ac e3 ff ff       	call   f0100adf <check_va2pa>
f0102733:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010273a:	77 15                	ja     f0102751 <mem_init+0x148c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010273c:	56                   	push   %esi
f010273d:	68 c8 62 10 f0       	push   $0xf01062c8
f0102742:	68 54 03 00 00       	push   $0x354
f0102747:	68 54 68 10 f0       	push   $0xf0106854
f010274c:	e8 ef d8 ff ff       	call   f0100040 <_panic>
f0102751:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102758:	39 c2                	cmp    %eax,%edx
f010275a:	74 19                	je     f0102775 <mem_init+0x14b0>
f010275c:	68 e4 72 10 f0       	push   $0xf01072e4
f0102761:	68 7a 68 10 f0       	push   $0xf010687a
f0102766:	68 54 03 00 00       	push   $0x354
f010276b:	68 54 68 10 f0       	push   $0xf0106854
f0102770:	e8 cb d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102775:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010277b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010277e:	77 a6                	ja     f0102726 <mem_init+0x1461>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102780:	8b 35 48 72 20 f0    	mov    0xf0207248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102786:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102789:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010278e:	89 da                	mov    %ebx,%edx
f0102790:	89 f8                	mov    %edi,%eax
f0102792:	e8 48 e3 ff ff       	call   f0100adf <check_va2pa>
f0102797:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010279e:	77 15                	ja     f01027b5 <mem_init+0x14f0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027a0:	56                   	push   %esi
f01027a1:	68 c8 62 10 f0       	push   $0xf01062c8
f01027a6:	68 59 03 00 00       	push   $0x359
f01027ab:	68 54 68 10 f0       	push   $0xf0106854
f01027b0:	e8 8b d8 ff ff       	call   f0100040 <_panic>
f01027b5:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01027bc:	39 d0                	cmp    %edx,%eax
f01027be:	74 19                	je     f01027d9 <mem_init+0x1514>
f01027c0:	68 18 73 10 f0       	push   $0xf0107318
f01027c5:	68 7a 68 10 f0       	push   $0xf010687a
f01027ca:	68 59 03 00 00       	push   $0x359
f01027cf:	68 54 68 10 f0       	push   $0xf0106854
f01027d4:	e8 67 d8 ff ff       	call   f0100040 <_panic>
f01027d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027df:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01027e5:	75 a7                	jne    f010278e <mem_init+0x14c9>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027e7:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01027ea:	c1 e6 0c             	shl    $0xc,%esi
f01027ed:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027f2:	eb 30                	jmp    f0102824 <mem_init+0x155f>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027f4:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01027fa:	89 f8                	mov    %edi,%eax
f01027fc:	e8 de e2 ff ff       	call   f0100adf <check_va2pa>
f0102801:	39 c3                	cmp    %eax,%ebx
f0102803:	74 19                	je     f010281e <mem_init+0x1559>
f0102805:	68 4c 73 10 f0       	push   $0xf010734c
f010280a:	68 7a 68 10 f0       	push   $0xf010687a
f010280f:	68 5d 03 00 00       	push   $0x35d
f0102814:	68 54 68 10 f0       	push   $0xf0106854
f0102819:	e8 22 d8 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010281e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102824:	39 f3                	cmp    %esi,%ebx
f0102826:	72 cc                	jb     f01027f4 <mem_init+0x152f>
f0102828:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010282d:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102830:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102833:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102836:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f010283c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010283f:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102841:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102844:	05 00 80 00 20       	add    $0x20008000,%eax
f0102849:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010284c:	89 da                	mov    %ebx,%edx
f010284e:	89 f8                	mov    %edi,%eax
f0102850:	e8 8a e2 ff ff       	call   f0100adf <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102855:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010285b:	77 15                	ja     f0102872 <mem_init+0x15ad>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010285d:	56                   	push   %esi
f010285e:	68 c8 62 10 f0       	push   $0xf01062c8
f0102863:	68 65 03 00 00       	push   $0x365
f0102868:	68 54 68 10 f0       	push   $0xf0106854
f010286d:	e8 ce d7 ff ff       	call   f0100040 <_panic>
f0102872:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102875:	8d 94 0b 00 90 20 f0 	lea    -0xfdf7000(%ebx,%ecx,1),%edx
f010287c:	39 d0                	cmp    %edx,%eax
f010287e:	74 19                	je     f0102899 <mem_init+0x15d4>
f0102880:	68 74 73 10 f0       	push   $0xf0107374
f0102885:	68 7a 68 10 f0       	push   $0xf010687a
f010288a:	68 65 03 00 00       	push   $0x365
f010288f:	68 54 68 10 f0       	push   $0xf0106854
f0102894:	e8 a7 d7 ff ff       	call   f0100040 <_panic>
f0102899:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010289f:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f01028a2:	75 a8                	jne    f010284c <mem_init+0x1587>
f01028a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028a7:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01028ad:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028b0:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01028b2:	89 da                	mov    %ebx,%edx
f01028b4:	89 f8                	mov    %edi,%eax
f01028b6:	e8 24 e2 ff ff       	call   f0100adf <check_va2pa>
f01028bb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028be:	74 19                	je     f01028d9 <mem_init+0x1614>
f01028c0:	68 bc 73 10 f0       	push   $0xf01073bc
f01028c5:	68 7a 68 10 f0       	push   $0xf010687a
f01028ca:	68 67 03 00 00       	push   $0x367
f01028cf:	68 54 68 10 f0       	push   $0xf0106854
f01028d4:	e8 67 d7 ff ff       	call   f0100040 <_panic>
f01028d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01028df:	39 de                	cmp    %ebx,%esi
f01028e1:	75 cf                	jne    f01028b2 <mem_init+0x15ed>
f01028e3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01028e6:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01028ed:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01028f4:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01028fa:	81 fe 00 90 24 f0    	cmp    $0xf0249000,%esi
f0102900:	0f 85 2d ff ff ff    	jne    f0102833 <mem_init+0x156e>
f0102906:	b8 00 00 00 00       	mov    $0x0,%eax
f010290b:	eb 2a                	jmp    f0102937 <mem_init+0x1672>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010290d:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102913:	83 fa 04             	cmp    $0x4,%edx
f0102916:	77 1f                	ja     f0102937 <mem_init+0x1672>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102918:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010291c:	75 7e                	jne    f010299c <mem_init+0x16d7>
f010291e:	68 7f 6b 10 f0       	push   $0xf0106b7f
f0102923:	68 7a 68 10 f0       	push   $0xf010687a
f0102928:	68 72 03 00 00       	push   $0x372
f010292d:	68 54 68 10 f0       	push   $0xf0106854
f0102932:	e8 09 d7 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102937:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010293c:	76 3f                	jbe    f010297d <mem_init+0x16b8>
				assert(pgdir[i] & PTE_P);
f010293e:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102941:	f6 c2 01             	test   $0x1,%dl
f0102944:	75 19                	jne    f010295f <mem_init+0x169a>
f0102946:	68 7f 6b 10 f0       	push   $0xf0106b7f
f010294b:	68 7a 68 10 f0       	push   $0xf010687a
f0102950:	68 76 03 00 00       	push   $0x376
f0102955:	68 54 68 10 f0       	push   $0xf0106854
f010295a:	e8 e1 d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010295f:	f6 c2 02             	test   $0x2,%dl
f0102962:	75 38                	jne    f010299c <mem_init+0x16d7>
f0102964:	68 90 6b 10 f0       	push   $0xf0106b90
f0102969:	68 7a 68 10 f0       	push   $0xf010687a
f010296e:	68 77 03 00 00       	push   $0x377
f0102973:	68 54 68 10 f0       	push   $0xf0106854
f0102978:	e8 c3 d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f010297d:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102981:	74 19                	je     f010299c <mem_init+0x16d7>
f0102983:	68 a1 6b 10 f0       	push   $0xf0106ba1
f0102988:	68 7a 68 10 f0       	push   $0xf010687a
f010298d:	68 79 03 00 00       	push   $0x379
f0102992:	68 54 68 10 f0       	push   $0xf0106854
f0102997:	e8 a4 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010299c:	83 c0 01             	add    $0x1,%eax
f010299f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01029a4:	0f 86 63 ff ff ff    	jbe    f010290d <mem_init+0x1648>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01029aa:	83 ec 0c             	sub    $0xc,%esp
f01029ad:	68 e0 73 10 f0       	push   $0xf01073e0
f01029b2:	e8 ed 0c 00 00       	call   f01036a4 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01029b7:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029bc:	83 c4 10             	add    $0x10,%esp
f01029bf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029c4:	77 15                	ja     f01029db <mem_init+0x1716>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029c6:	50                   	push   %eax
f01029c7:	68 c8 62 10 f0       	push   $0xf01062c8
f01029cc:	68 df 00 00 00       	push   $0xdf
f01029d1:	68 54 68 10 f0       	push   $0xf0106854
f01029d6:	e8 65 d6 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029db:	05 00 00 00 10       	add    $0x10000000,%eax
f01029e0:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01029e8:	e8 56 e1 ff ff       	call   f0100b43 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01029ed:	0f 20 c0             	mov    %cr0,%eax
f01029f0:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01029f3:	0d 23 00 05 80       	or     $0x80050023,%eax
f01029f8:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029fb:	83 ec 0c             	sub    $0xc,%esp
f01029fe:	6a 00                	push   $0x0
f0102a00:	e8 ec e4 ff ff       	call   f0100ef1 <page_alloc>
f0102a05:	89 c3                	mov    %eax,%ebx
f0102a07:	83 c4 10             	add    $0x10,%esp
f0102a0a:	85 c0                	test   %eax,%eax
f0102a0c:	75 19                	jne    f0102a27 <mem_init+0x1762>
f0102a0e:	68 8b 69 10 f0       	push   $0xf010698b
f0102a13:	68 7a 68 10 f0       	push   $0xf010687a
f0102a18:	68 51 04 00 00       	push   $0x451
f0102a1d:	68 54 68 10 f0       	push   $0xf0106854
f0102a22:	e8 19 d6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a27:	83 ec 0c             	sub    $0xc,%esp
f0102a2a:	6a 00                	push   $0x0
f0102a2c:	e8 c0 e4 ff ff       	call   f0100ef1 <page_alloc>
f0102a31:	89 c7                	mov    %eax,%edi
f0102a33:	83 c4 10             	add    $0x10,%esp
f0102a36:	85 c0                	test   %eax,%eax
f0102a38:	75 19                	jne    f0102a53 <mem_init+0x178e>
f0102a3a:	68 a1 69 10 f0       	push   $0xf01069a1
f0102a3f:	68 7a 68 10 f0       	push   $0xf010687a
f0102a44:	68 52 04 00 00       	push   $0x452
f0102a49:	68 54 68 10 f0       	push   $0xf0106854
f0102a4e:	e8 ed d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a53:	83 ec 0c             	sub    $0xc,%esp
f0102a56:	6a 00                	push   $0x0
f0102a58:	e8 94 e4 ff ff       	call   f0100ef1 <page_alloc>
f0102a5d:	89 c6                	mov    %eax,%esi
f0102a5f:	83 c4 10             	add    $0x10,%esp
f0102a62:	85 c0                	test   %eax,%eax
f0102a64:	75 19                	jne    f0102a7f <mem_init+0x17ba>
f0102a66:	68 b7 69 10 f0       	push   $0xf01069b7
f0102a6b:	68 7a 68 10 f0       	push   $0xf010687a
f0102a70:	68 53 04 00 00       	push   $0x453
f0102a75:	68 54 68 10 f0       	push   $0xf0106854
f0102a7a:	e8 c1 d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102a7f:	83 ec 0c             	sub    $0xc,%esp
f0102a82:	53                   	push   %ebx
f0102a83:	e8 d9 e4 ff ff       	call   f0100f61 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a88:	89 f8                	mov    %edi,%eax
f0102a8a:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0102a90:	c1 f8 03             	sar    $0x3,%eax
f0102a93:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a96:	89 c2                	mov    %eax,%edx
f0102a98:	c1 ea 0c             	shr    $0xc,%edx
f0102a9b:	83 c4 10             	add    $0x10,%esp
f0102a9e:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0102aa4:	72 12                	jb     f0102ab8 <mem_init+0x17f3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102aa6:	50                   	push   %eax
f0102aa7:	68 a4 62 10 f0       	push   $0xf01062a4
f0102aac:	6a 58                	push   $0x58
f0102aae:	68 60 68 10 f0       	push   $0xf0106860
f0102ab3:	e8 88 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ab8:	83 ec 04             	sub    $0x4,%esp
f0102abb:	68 00 10 00 00       	push   $0x1000
f0102ac0:	6a 01                	push   $0x1
f0102ac2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ac7:	50                   	push   %eax
f0102ac8:	e8 fc 2a 00 00       	call   f01055c9 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102acd:	89 f0                	mov    %esi,%eax
f0102acf:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0102ad5:	c1 f8 03             	sar    $0x3,%eax
f0102ad8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102adb:	89 c2                	mov    %eax,%edx
f0102add:	c1 ea 0c             	shr    $0xc,%edx
f0102ae0:	83 c4 10             	add    $0x10,%esp
f0102ae3:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0102ae9:	72 12                	jb     f0102afd <mem_init+0x1838>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102aeb:	50                   	push   %eax
f0102aec:	68 a4 62 10 f0       	push   $0xf01062a4
f0102af1:	6a 58                	push   $0x58
f0102af3:	68 60 68 10 f0       	push   $0xf0106860
f0102af8:	e8 43 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102afd:	83 ec 04             	sub    $0x4,%esp
f0102b00:	68 00 10 00 00       	push   $0x1000
f0102b05:	6a 02                	push   $0x2
f0102b07:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b0c:	50                   	push   %eax
f0102b0d:	e8 b7 2a 00 00       	call   f01055c9 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b12:	6a 02                	push   $0x2
f0102b14:	68 00 10 00 00       	push   $0x1000
f0102b19:	57                   	push   %edi
f0102b1a:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102b20:	e8 cb e6 ff ff       	call   f01011f0 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b25:	83 c4 20             	add    $0x20,%esp
f0102b28:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b2d:	74 19                	je     f0102b48 <mem_init+0x1883>
f0102b2f:	68 88 6a 10 f0       	push   $0xf0106a88
f0102b34:	68 7a 68 10 f0       	push   $0xf010687a
f0102b39:	68 58 04 00 00       	push   $0x458
f0102b3e:	68 54 68 10 f0       	push   $0xf0106854
f0102b43:	e8 f8 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b48:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b4f:	01 01 01 
f0102b52:	74 19                	je     f0102b6d <mem_init+0x18a8>
f0102b54:	68 00 74 10 f0       	push   $0xf0107400
f0102b59:	68 7a 68 10 f0       	push   $0xf010687a
f0102b5e:	68 59 04 00 00       	push   $0x459
f0102b63:	68 54 68 10 f0       	push   $0xf0106854
f0102b68:	e8 d3 d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b6d:	6a 02                	push   $0x2
f0102b6f:	68 00 10 00 00       	push   $0x1000
f0102b74:	56                   	push   %esi
f0102b75:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102b7b:	e8 70 e6 ff ff       	call   f01011f0 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b80:	83 c4 10             	add    $0x10,%esp
f0102b83:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b8a:	02 02 02 
f0102b8d:	74 19                	je     f0102ba8 <mem_init+0x18e3>
f0102b8f:	68 24 74 10 f0       	push   $0xf0107424
f0102b94:	68 7a 68 10 f0       	push   $0xf010687a
f0102b99:	68 5b 04 00 00       	push   $0x45b
f0102b9e:	68 54 68 10 f0       	push   $0xf0106854
f0102ba3:	e8 98 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102ba8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102bad:	74 19                	je     f0102bc8 <mem_init+0x1903>
f0102baf:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0102bb4:	68 7a 68 10 f0       	push   $0xf010687a
f0102bb9:	68 5c 04 00 00       	push   $0x45c
f0102bbe:	68 54 68 10 f0       	push   $0xf0106854
f0102bc3:	e8 78 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102bc8:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bcd:	74 19                	je     f0102be8 <mem_init+0x1923>
f0102bcf:	68 14 6b 10 f0       	push   $0xf0106b14
f0102bd4:	68 7a 68 10 f0       	push   $0xf010687a
f0102bd9:	68 5d 04 00 00       	push   $0x45d
f0102bde:	68 54 68 10 f0       	push   $0xf0106854
f0102be3:	e8 58 d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102be8:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bef:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bf2:	89 f0                	mov    %esi,%eax
f0102bf4:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0102bfa:	c1 f8 03             	sar    $0x3,%eax
f0102bfd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c00:	89 c2                	mov    %eax,%edx
f0102c02:	c1 ea 0c             	shr    $0xc,%edx
f0102c05:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0102c0b:	72 12                	jb     f0102c1f <mem_init+0x195a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c0d:	50                   	push   %eax
f0102c0e:	68 a4 62 10 f0       	push   $0xf01062a4
f0102c13:	6a 58                	push   $0x58
f0102c15:	68 60 68 10 f0       	push   $0xf0106860
f0102c1a:	e8 21 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c1f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c26:	03 03 03 
f0102c29:	74 19                	je     f0102c44 <mem_init+0x197f>
f0102c2b:	68 48 74 10 f0       	push   $0xf0107448
f0102c30:	68 7a 68 10 f0       	push   $0xf010687a
f0102c35:	68 5f 04 00 00       	push   $0x45f
f0102c3a:	68 54 68 10 f0       	push   $0xf0106854
f0102c3f:	e8 fc d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c44:	83 ec 08             	sub    $0x8,%esp
f0102c47:	68 00 10 00 00       	push   $0x1000
f0102c4c:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102c52:	e8 4c e5 ff ff       	call   f01011a3 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c57:	83 c4 10             	add    $0x10,%esp
f0102c5a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c5f:	74 19                	je     f0102c7a <mem_init+0x19b5>
f0102c61:	68 e2 6a 10 f0       	push   $0xf0106ae2
f0102c66:	68 7a 68 10 f0       	push   $0xf010687a
f0102c6b:	68 61 04 00 00       	push   $0x461
f0102c70:	68 54 68 10 f0       	push   $0xf0106854
f0102c75:	e8 c6 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c7a:	8b 0d 8c 7e 20 f0    	mov    0xf0207e8c,%ecx
f0102c80:	8b 11                	mov    (%ecx),%edx
f0102c82:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102c88:	89 d8                	mov    %ebx,%eax
f0102c8a:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0102c90:	c1 f8 03             	sar    $0x3,%eax
f0102c93:	c1 e0 0c             	shl    $0xc,%eax
f0102c96:	39 c2                	cmp    %eax,%edx
f0102c98:	74 19                	je     f0102cb3 <mem_init+0x19ee>
f0102c9a:	68 d0 6d 10 f0       	push   $0xf0106dd0
f0102c9f:	68 7a 68 10 f0       	push   $0xf010687a
f0102ca4:	68 64 04 00 00       	push   $0x464
f0102ca9:	68 54 68 10 f0       	push   $0xf0106854
f0102cae:	e8 8d d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102cb3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102cb9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cbe:	74 19                	je     f0102cd9 <mem_init+0x1a14>
f0102cc0:	68 99 6a 10 f0       	push   $0xf0106a99
f0102cc5:	68 7a 68 10 f0       	push   $0xf010687a
f0102cca:	68 66 04 00 00       	push   $0x466
f0102ccf:	68 54 68 10 f0       	push   $0xf0106854
f0102cd4:	e8 67 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102cd9:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102cdf:	83 ec 0c             	sub    $0xc,%esp
f0102ce2:	53                   	push   %ebx
f0102ce3:	e8 79 e2 ff ff       	call   f0100f61 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ce8:	c7 04 24 74 74 10 f0 	movl   $0xf0107474,(%esp)
f0102cef:	e8 b0 09 00 00       	call   f01036a4 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102cf4:	83 c4 10             	add    $0x10,%esp
f0102cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cfa:	5b                   	pop    %ebx
f0102cfb:	5e                   	pop    %esi
f0102cfc:	5f                   	pop    %edi
f0102cfd:	5d                   	pop    %ebp
f0102cfe:	c3                   	ret    

f0102cff <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102cff:	55                   	push   %ebp
f0102d00:	89 e5                	mov    %esp,%ebp
f0102d02:	57                   	push   %edi
f0102d03:	56                   	push   %esi
f0102d04:	53                   	push   %ebx
f0102d05:	83 ec 1c             	sub    $0x1c,%esp
f0102d08:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102d0b:	8b 75 14             	mov    0x14(%ebp),%esi
	char *start, *end;
	pte_t *cur;

	start = end = NULL;
	start = ROUNDDOWN((char *)va, PGSIZE);
f0102d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d16:	89 c3                	mov    %eax,%ebx
f0102d18:	89 45 e0             	mov    %eax,-0x20(%ebp)
	end = ROUNDUP((char *)(va + len), PGSIZE);
f0102d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d1e:	03 45 10             	add    0x10(%ebp),%eax
f0102d21:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102d26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	cur = NULL;
	for (; start < end; start += PGSIZE) {
f0102d2e:	eb 4e                	jmp    f0102d7e <user_mem_check+0x7f>
		cur = pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102d30:	83 ec 04             	sub    $0x4,%esp
f0102d33:	6a 00                	push   $0x0
f0102d35:	53                   	push   %ebx
f0102d36:	ff 77 60             	pushl  0x60(%edi)
f0102d39:	e8 a0 e2 ff ff       	call   f0100fde <pgdir_walk>
		if ((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
f0102d3e:	89 da                	mov    %ebx,%edx
f0102d40:	83 c4 10             	add    $0x10,%esp
f0102d43:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0102d49:	77 0c                	ja     f0102d57 <user_mem_check+0x58>
f0102d4b:	85 c0                	test   %eax,%eax
f0102d4d:	74 08                	je     f0102d57 <user_mem_check+0x58>
f0102d4f:	89 f1                	mov    %esi,%ecx
f0102d51:	23 08                	and    (%eax),%ecx
f0102d53:	39 ce                	cmp    %ecx,%esi
f0102d55:	74 21                	je     f0102d78 <user_mem_check+0x79>
			if (start == ROUNDDOWN((char *)va, PGSIZE)) 
f0102d57:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102d5a:	75 0f                	jne    f0102d6b <user_mem_check+0x6c>
				user_mem_check_addr = (uintptr_t)va;
f0102d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d5f:	a3 3c 72 20 f0       	mov    %eax,0xf020723c
			else
				user_mem_check_addr = (uintptr_t)start;
			return -E_FAULT;
f0102d64:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d69:	eb 1d                	jmp    f0102d88 <user_mem_check+0x89>
		cur = pgdir_walk(env->env_pgdir, (void *)start, 0);
		if ((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
			if (start == ROUNDDOWN((char *)va, PGSIZE)) 
				user_mem_check_addr = (uintptr_t)va;
			else
				user_mem_check_addr = (uintptr_t)start;
f0102d6b:	89 15 3c 72 20 f0    	mov    %edx,0xf020723c
			return -E_FAULT;
f0102d71:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d76:	eb 10                	jmp    f0102d88 <user_mem_check+0x89>
	start = end = NULL;
	start = ROUNDDOWN((char *)va, PGSIZE);
	end = ROUNDUP((char *)(va + len), PGSIZE);
	
	cur = NULL;
	for (; start < end; start += PGSIZE) {
f0102d78:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d7e:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102d81:	72 ad                	jb     f0102d30 <user_mem_check+0x31>
				user_mem_check_addr = (uintptr_t)start;
			return -E_FAULT;
		}
	}	
	
	return 0;
f0102d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d8b:	5b                   	pop    %ebx
f0102d8c:	5e                   	pop    %esi
f0102d8d:	5f                   	pop    %edi
f0102d8e:	5d                   	pop    %ebp
f0102d8f:	c3                   	ret    

f0102d90 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102d90:	55                   	push   %ebp
f0102d91:	89 e5                	mov    %esp,%ebp
f0102d93:	53                   	push   %ebx
f0102d94:	83 ec 04             	sub    $0x4,%esp
f0102d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102d9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d9d:	83 c8 04             	or     $0x4,%eax
f0102da0:	50                   	push   %eax
f0102da1:	ff 75 10             	pushl  0x10(%ebp)
f0102da4:	ff 75 0c             	pushl  0xc(%ebp)
f0102da7:	53                   	push   %ebx
f0102da8:	e8 52 ff ff ff       	call   f0102cff <user_mem_check>
f0102dad:	83 c4 10             	add    $0x10,%esp
f0102db0:	85 c0                	test   %eax,%eax
f0102db2:	79 21                	jns    f0102dd5 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102db4:	83 ec 04             	sub    $0x4,%esp
f0102db7:	ff 35 3c 72 20 f0    	pushl  0xf020723c
f0102dbd:	ff 73 48             	pushl  0x48(%ebx)
f0102dc0:	68 a0 74 10 f0       	push   $0xf01074a0
f0102dc5:	e8 da 08 00 00       	call   f01036a4 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102dca:	89 1c 24             	mov    %ebx,(%esp)
f0102dcd:	e8 e2 05 00 00       	call   f01033b4 <env_destroy>
f0102dd2:	83 c4 10             	add    $0x10,%esp
	}
}
f0102dd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102dd8:	c9                   	leave  
f0102dd9:	c3                   	ret    

f0102dda <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102dda:	55                   	push   %ebp
f0102ddb:	89 e5                	mov    %esp,%ebp
f0102ddd:	57                   	push   %edi
f0102dde:	56                   	push   %esi
f0102ddf:	53                   	push   %ebx
f0102de0:	83 ec 0c             	sub    $0xc,%esp
f0102de3:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	
	void *start = (void *) ROUNDDOWN((uint32_t)va, PGSIZE);
f0102de5:	89 d3                	mov    %edx,%ebx
f0102de7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    void *end = (void *) ROUNDUP((uint32_t)va + len, PGSIZE);
f0102ded:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102df4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    int r;

    for (void *i = start; i < end; i += PGSIZE) {		// **LIRONGJIA**
f0102dfa:	eb 58                	jmp    f0102e54 <region_alloc+0x7a>
        struct PageInfo *p = page_alloc(0);				// Allocate a page.
f0102dfc:	83 ec 0c             	sub    $0xc,%esp
f0102dff:	6a 00                	push   $0x0
f0102e01:	e8 eb e0 ff ff       	call   f0100ef1 <page_alloc>
        if(p == NULL)									//
f0102e06:	83 c4 10             	add    $0x10,%esp
f0102e09:	85 c0                	test   %eax,%eax
f0102e0b:	75 17                	jne    f0102e24 <region_alloc+0x4a>
            panic("region alloc, allocation failed.");	//
f0102e0d:	83 ec 04             	sub    $0x4,%esp
f0102e10:	68 d8 74 10 f0       	push   $0xf01074d8
f0102e15:	68 49 01 00 00       	push   $0x149
f0102e1a:	68 8c 75 10 f0       	push   $0xf010758c
f0102e1f:	e8 1c d2 ff ff       	call   f0100040 <_panic>
														//
        r = page_insert (e->env_pgdir,					// Insert the page
f0102e24:	6a 06                	push   $0x6
f0102e26:	53                   	push   %ebx
f0102e27:	50                   	push   %eax
f0102e28:	ff 77 60             	pushl  0x60(%edi)
f0102e2b:	e8 c0 e3 ff ff       	call   f01011f0 <page_insert>
						p,								// into env_pgdir.
						i,								// 
						PTE_W | PTE_U);					// Writable by U&K.
        if(r != 0)										// *************
f0102e30:	83 c4 10             	add    $0x10,%esp
f0102e33:	85 c0                	test   %eax,%eax
f0102e35:	74 17                	je     f0102e4e <region_alloc+0x74>
            panic("region alloc error");
f0102e37:	83 ec 04             	sub    $0x4,%esp
f0102e3a:	68 97 75 10 f0       	push   $0xf0107597
f0102e3f:	68 50 01 00 00       	push   $0x150
f0102e44:	68 8c 75 10 f0       	push   $0xf010758c
f0102e49:	e8 f2 d1 ff ff       	call   f0100040 <_panic>
	
	void *start = (void *) ROUNDDOWN((uint32_t)va, PGSIZE);
    void *end = (void *) ROUNDUP((uint32_t)va + len, PGSIZE);
    int r;

    for (void *i = start; i < end; i += PGSIZE) {		// **LIRONGJIA**
f0102e4e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e54:	39 f3                	cmp    %esi,%ebx
f0102e56:	72 a4                	jb     f0102dfc <region_alloc+0x22>
						i,								// 
						PTE_W | PTE_U);					// Writable by U&K.
        if(r != 0)										// *************
            panic("region alloc error");
    }
}
f0102e58:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e5b:	5b                   	pop    %ebx
f0102e5c:	5e                   	pop    %esi
f0102e5d:	5f                   	pop    %edi
f0102e5e:	5d                   	pop    %ebp
f0102e5f:	c3                   	ret    

f0102e60 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e60:	55                   	push   %ebp
f0102e61:	89 e5                	mov    %esp,%ebp
f0102e63:	56                   	push   %esi
f0102e64:	53                   	push   %ebx
f0102e65:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e68:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e6b:	85 c0                	test   %eax,%eax
f0102e6d:	75 1a                	jne    f0102e89 <envid2env+0x29>
		*env_store = curenv;
f0102e6f:	e8 76 2d 00 00       	call   f0105bea <cpunum>
f0102e74:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e77:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0102e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e80:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e82:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e87:	eb 70                	jmp    f0102ef9 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e89:	89 c3                	mov    %eax,%ebx
f0102e8b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102e91:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102e94:	03 1d 48 72 20 f0    	add    0xf0207248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e9a:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102e9e:	74 05                	je     f0102ea5 <envid2env+0x45>
f0102ea0:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102ea3:	74 10                	je     f0102eb5 <envid2env+0x55>
		*env_store = 0;
f0102ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ea8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102eae:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eb3:	eb 44                	jmp    f0102ef9 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102eb5:	84 d2                	test   %dl,%dl
f0102eb7:	74 36                	je     f0102eef <envid2env+0x8f>
f0102eb9:	e8 2c 2d 00 00       	call   f0105bea <cpunum>
f0102ebe:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ec1:	3b 98 28 80 20 f0    	cmp    -0xfdf7fd8(%eax),%ebx
f0102ec7:	74 26                	je     f0102eef <envid2env+0x8f>
f0102ec9:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102ecc:	e8 19 2d 00 00       	call   f0105bea <cpunum>
f0102ed1:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ed4:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0102eda:	3b 70 48             	cmp    0x48(%eax),%esi
f0102edd:	74 10                	je     f0102eef <envid2env+0x8f>
		*env_store = 0;
f0102edf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ee2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ee8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eed:	eb 0a                	jmp    f0102ef9 <envid2env+0x99>
	}

	*env_store = e;
f0102eef:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ef2:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ef9:	5b                   	pop    %ebx
f0102efa:	5e                   	pop    %esi
f0102efb:	5d                   	pop    %ebp
f0102efc:	c3                   	ret    

f0102efd <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102efd:	55                   	push   %ebp
f0102efe:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102f00:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0102f05:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102f08:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f0d:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102f0f:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102f11:	b8 10 00 00 00       	mov    $0x10,%eax
f0102f16:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102f18:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102f1a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f1c:	ea 23 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f23
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f23:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f28:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f2b:	5d                   	pop    %ebp
f0102f2c:	c3                   	ret    

f0102f2d <env_init>:
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}*/
void
env_init(void)
{
f0102f2d:	55                   	push   %ebp
f0102f2e:	89 e5                	mov    %esp,%ebp
f0102f30:	56                   	push   %esi
f0102f31:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL;
	for (int i = NENV - 1; i >= 0; i--) {
		envs[i].env_status = ENV_FREE;
f0102f32:	8b 35 48 72 20 f0    	mov    0xf0207248,%esi
f0102f38:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f3e:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f41:	ba 00 00 00 00       	mov    $0x0,%edx
f0102f46:	89 c1                	mov    %eax,%ecx
f0102f48:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0102f4f:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102f56:	89 50 44             	mov    %edx,0x44(%eax)
f0102f59:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0102f5c:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL;
	for (int i = NENV - 1; i >= 0; i--) {
f0102f5e:	39 d8                	cmp    %ebx,%eax
f0102f60:	75 e4                	jne    f0102f46 <env_init+0x19>
f0102f62:	89 35 4c 72 20 f0    	mov    %esi,0xf020724c
			envs[i].env_link = &envs[i + 1];
	}
	env_free_list = &envs[0];*/

	// Per-CPU part of the initialization
	env_init_percpu();
f0102f68:	e8 90 ff ff ff       	call   f0102efd <env_init_percpu>
}
f0102f6d:	5b                   	pop    %ebx
f0102f6e:	5e                   	pop    %esi
f0102f6f:	5d                   	pop    %ebp
f0102f70:	c3                   	ret    

f0102f71 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f71:	55                   	push   %ebp
f0102f72:	89 e5                	mov    %esp,%ebp
f0102f74:	53                   	push   %ebx
f0102f75:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f78:	8b 1d 4c 72 20 f0    	mov    0xf020724c,%ebx
f0102f7e:	85 db                	test   %ebx,%ebx
f0102f80:	0f 84 4b 01 00 00    	je     f01030d1 <env_alloc+0x160>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f86:	83 ec 0c             	sub    $0xc,%esp
f0102f89:	6a 01                	push   $0x1
f0102f8b:	e8 61 df ff ff       	call   f0100ef1 <page_alloc>
f0102f90:	83 c4 10             	add    $0x10,%esp
f0102f93:	85 c0                	test   %eax,%eax
f0102f95:	0f 84 3d 01 00 00    	je     f01030d8 <env_alloc+0x167>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f9b:	89 c2                	mov    %eax,%edx
f0102f9d:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0102fa3:	c1 fa 03             	sar    $0x3,%edx
f0102fa6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fa9:	89 d1                	mov    %edx,%ecx
f0102fab:	c1 e9 0c             	shr    $0xc,%ecx
f0102fae:	3b 0d 88 7e 20 f0    	cmp    0xf0207e88,%ecx
f0102fb4:	72 12                	jb     f0102fc8 <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fb6:	52                   	push   %edx
f0102fb7:	68 a4 62 10 f0       	push   $0xf01062a4
f0102fbc:	6a 58                	push   $0x58
f0102fbe:	68 60 68 10 f0       	push   $0xf0106860
f0102fc3:	e8 78 d0 ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *) page2kva(p);
f0102fc8:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102fce:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f0102fd1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0102fd6:	b8 00 00 00 00       	mov    $0x0,%eax

	// Map the directory below UTOP.
    for(i = 0; i < PDX(UTOP); i++) {
        e->env_pgdir[i] = 0;        
f0102fdb:	8b 53 60             	mov    0x60(%ebx),%edx
f0102fde:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0102fe5:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *) page2kva(p);
	p->pp_ref++;

	// Map the directory below UTOP.
    for(i = 0; i < PDX(UTOP); i++) {
f0102fe8:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0102fed:	75 ec                	jne    f0102fdb <env_alloc+0x6a>
        e->env_pgdir[i] = 0;        
    }

    // Map the directory above UTOP ?? Why and what is NPDENTRIES
    for(i = PDX(UTOP); i < NPDENTRIES; i++) {
        e->env_pgdir[i] = kern_pgdir[i];
f0102fef:	8b 15 8c 7e 20 f0    	mov    0xf0207e8c,%edx
f0102ff5:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102ff8:	8b 53 60             	mov    0x60(%ebx),%edx
f0102ffb:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102ffe:	83 c0 04             	add    $0x4,%eax
    for(i = 0; i < PDX(UTOP); i++) {
        e->env_pgdir[i] = 0;        
    }

    // Map the directory above UTOP ?? Why and what is NPDENTRIES
    for(i = PDX(UTOP); i < NPDENTRIES; i++) {
f0103001:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103006:	75 e7                	jne    f0102fef <env_alloc+0x7e>
        e->env_pgdir[i] = kern_pgdir[i];
    }

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103008:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010300b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103010:	77 15                	ja     f0103027 <env_alloc+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103012:	50                   	push   %eax
f0103013:	68 c8 62 10 f0       	push   $0xf01062c8
f0103018:	68 e1 00 00 00       	push   $0xe1
f010301d:	68 8c 75 10 f0       	push   $0xf010758c
f0103022:	e8 19 d0 ff ff       	call   f0100040 <_panic>
f0103027:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010302d:	83 ca 05             	or     $0x5,%edx
f0103030:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103036:	8b 43 48             	mov    0x48(%ebx),%eax
f0103039:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010303e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103043:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103048:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010304b:	89 da                	mov    %ebx,%edx
f010304d:	2b 15 48 72 20 f0    	sub    0xf0207248,%edx
f0103053:	c1 fa 02             	sar    $0x2,%edx
f0103056:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010305c:	09 d0                	or     %edx,%eax
f010305e:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103061:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103064:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103067:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010306e:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103075:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010307c:	83 ec 04             	sub    $0x4,%esp
f010307f:	6a 44                	push   $0x44
f0103081:	6a 00                	push   $0x0
f0103083:	53                   	push   %ebx
f0103084:	e8 40 25 00 00       	call   f01055c9 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103089:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010308f:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103095:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010309b:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01030a2:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01030a8:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01030af:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01030b6:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01030ba:	8b 43 44             	mov    0x44(%ebx),%eax
f01030bd:	a3 4c 72 20 f0       	mov    %eax,0xf020724c
	*newenv_store = e;
f01030c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01030c5:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01030c7:	83 c4 10             	add    $0x10,%esp
f01030ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01030cf:	eb 0c                	jmp    f01030dd <env_alloc+0x16c>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01030d1:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01030d6:	eb 05                	jmp    f01030dd <env_alloc+0x16c>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01030d8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01030dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030e0:	c9                   	leave  
f01030e1:	c3                   	ret    

f01030e2 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01030e2:	55                   	push   %ebp
f01030e3:	89 e5                	mov    %esp,%ebp
f01030e5:	57                   	push   %edi
f01030e6:	56                   	push   %esi
f01030e7:	53                   	push   %ebx
f01030e8:	83 ec 34             	sub    $0x34,%esp
f01030eb:	8b 7d 08             	mov    0x8(%ebp),%edi

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	struct Env *e;
    int rc;
    if((rc = env_alloc(&e, 0)) != 0) {
f01030ee:	6a 00                	push   $0x0
f01030f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01030f3:	50                   	push   %eax
f01030f4:	e8 78 fe ff ff       	call   f0102f71 <env_alloc>
f01030f9:	83 c4 10             	add    $0x10,%esp
f01030fc:	85 c0                	test   %eax,%eax
f01030fe:	74 17                	je     f0103117 <env_create+0x35>
        panic("env_create failed: env_alloc failed.\n");
f0103100:	83 ec 04             	sub    $0x4,%esp
f0103103:	68 fc 74 10 f0       	push   $0xf01074fc
f0103108:	68 c0 01 00 00       	push   $0x1c0
f010310d:	68 8c 75 10 f0       	push   $0xf010758c
f0103112:	e8 29 cf ff ff       	call   f0100040 <_panic>
    }

    load_icode(e, binary);
f0103117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010311a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.

	struct Elf* header = (struct Elf*)binary;
    
    if(header->e_magic != ELF_MAGIC) {
f010311d:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103123:	74 17                	je     f010313c <env_create+0x5a>
        panic("load_icode failed: The binary we load is not elf.\n");
f0103125:	83 ec 04             	sub    $0x4,%esp
f0103128:	68 24 75 10 f0       	push   $0xf0107524
f010312d:	68 93 01 00 00       	push   $0x193
f0103132:	68 8c 75 10 f0       	push   $0xf010758c
f0103137:	e8 04 cf ff ff       	call   f0100040 <_panic>
    }

    if(header->e_entry == 0){
f010313c:	8b 47 18             	mov    0x18(%edi),%eax
f010313f:	85 c0                	test   %eax,%eax
f0103141:	75 17                	jne    f010315a <env_create+0x78>
        panic("load_icode failed: The elf file can't be excuterd.\n");
f0103143:	83 ec 04             	sub    $0x4,%esp
f0103146:	68 58 75 10 f0       	push   $0xf0107558
f010314b:	68 97 01 00 00       	push   $0x197
f0103150:	68 8c 75 10 f0       	push   $0xf010758c
f0103155:	e8 e6 ce ff ff       	call   f0100040 <_panic>
    }

    e->env_tf.tf_eip = header->e_entry;
f010315a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010315d:	89 41 30             	mov    %eax,0x30(%ecx)

    lcr3(PADDR(e->env_pgdir));   //?????
f0103160:	8b 41 60             	mov    0x60(%ecx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103163:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103168:	77 15                	ja     f010317f <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010316a:	50                   	push   %eax
f010316b:	68 c8 62 10 f0       	push   $0xf01062c8
f0103170:	68 9c 01 00 00       	push   $0x19c
f0103175:	68 8c 75 10 f0       	push   $0xf010758c
f010317a:	e8 c1 ce ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010317f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103184:	0f 22 d8             	mov    %eax,%cr3

    struct Proghdr *ph, *eph;
    ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
f0103187:	89 fb                	mov    %edi,%ebx
f0103189:	03 5f 1c             	add    0x1c(%edi),%ebx
    eph = ph + header->e_phnum;
f010318c:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103190:	c1 e6 05             	shl    $0x5,%esi
f0103193:	01 de                	add    %ebx,%esi
f0103195:	eb 44                	jmp    f01031db <env_create+0xf9>
    for(; ph < eph; ph++) {
        if(ph->p_type == ELF_PROG_LOAD) {
f0103197:	83 3b 01             	cmpl   $0x1,(%ebx)
f010319a:	75 3c                	jne    f01031d8 <env_create+0xf6>
            if(ph->p_memsz - ph->p_filesz < 0) {
                panic("load icode failed : p_memsz < p_filesz.\n");
            }

            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010319c:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010319f:	8b 53 08             	mov    0x8(%ebx),%edx
f01031a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031a5:	e8 30 fc ff ff       	call   f0102dda <region_alloc>
            memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01031aa:	83 ec 04             	sub    $0x4,%esp
f01031ad:	ff 73 10             	pushl  0x10(%ebx)
f01031b0:	89 f8                	mov    %edi,%eax
f01031b2:	03 43 04             	add    0x4(%ebx),%eax
f01031b5:	50                   	push   %eax
f01031b6:	ff 73 08             	pushl  0x8(%ebx)
f01031b9:	e8 58 24 00 00       	call   f0105616 <memmove>
            memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01031be:	8b 43 10             	mov    0x10(%ebx),%eax
f01031c1:	83 c4 0c             	add    $0xc,%esp
f01031c4:	8b 53 14             	mov    0x14(%ebx),%edx
f01031c7:	29 c2                	sub    %eax,%edx
f01031c9:	52                   	push   %edx
f01031ca:	6a 00                	push   $0x0
f01031cc:	03 43 08             	add    0x8(%ebx),%eax
f01031cf:	50                   	push   %eax
f01031d0:	e8 f4 23 00 00       	call   f01055c9 <memset>
f01031d5:	83 c4 10             	add    $0x10,%esp
    lcr3(PADDR(e->env_pgdir));   //?????

    struct Proghdr *ph, *eph;
    ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
    eph = ph + header->e_phnum;
    for(; ph < eph; ph++) {
f01031d8:	83 c3 20             	add    $0x20,%ebx
f01031db:	39 de                	cmp    %ebx,%esi
f01031dd:	77 b8                	ja     f0103197 <env_create+0xb5>
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
            memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
        }
    }
	region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f01031df:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01031e4:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01031e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031ec:	e8 e9 fb ff ff       	call   f0102dda <region_alloc>
    if((rc = env_alloc(&e, 0)) != 0) {
        panic("env_create failed: env_alloc failed.\n");
    }

    load_icode(e, binary);
    e->env_type = type;
f01031f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01031f7:	89 78 50             	mov    %edi,0x50(%eax)

	if (e->env_type == ENV_TYPE_FS){
f01031fa:	83 ff 01             	cmp    $0x1,%edi
f01031fd:	75 07                	jne    f0103206 <env_create+0x124>
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
f01031ff:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
}
f0103206:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103209:	5b                   	pop    %ebx
f010320a:	5e                   	pop    %esi
f010320b:	5f                   	pop    %edi
f010320c:	5d                   	pop    %ebp
f010320d:	c3                   	ret    

f010320e <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010320e:	55                   	push   %ebp
f010320f:	89 e5                	mov    %esp,%ebp
f0103211:	57                   	push   %edi
f0103212:	56                   	push   %esi
f0103213:	53                   	push   %ebx
f0103214:	83 ec 1c             	sub    $0x1c,%esp
f0103217:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010321a:	e8 cb 29 00 00       	call   f0105bea <cpunum>
f010321f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103222:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103229:	39 b8 28 80 20 f0    	cmp    %edi,-0xfdf7fd8(%eax)
f010322f:	75 30                	jne    f0103261 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f0103231:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103236:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010323b:	77 15                	ja     f0103252 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010323d:	50                   	push   %eax
f010323e:	68 c8 62 10 f0       	push   $0xf01062c8
f0103243:	68 d9 01 00 00       	push   $0x1d9
f0103248:	68 8c 75 10 f0       	push   $0xf010758c
f010324d:	e8 ee cd ff ff       	call   f0100040 <_panic>
f0103252:	05 00 00 00 10       	add    $0x10000000,%eax
f0103257:	0f 22 d8             	mov    %eax,%cr3
f010325a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103261:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103264:	89 d0                	mov    %edx,%eax
f0103266:	c1 e0 02             	shl    $0x2,%eax
f0103269:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010326c:	8b 47 60             	mov    0x60(%edi),%eax
f010326f:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103272:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103278:	0f 84 a8 00 00 00    	je     f0103326 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010327e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103284:	89 f0                	mov    %esi,%eax
f0103286:	c1 e8 0c             	shr    $0xc,%eax
f0103289:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010328c:	39 05 88 7e 20 f0    	cmp    %eax,0xf0207e88
f0103292:	77 15                	ja     f01032a9 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103294:	56                   	push   %esi
f0103295:	68 a4 62 10 f0       	push   $0xf01062a4
f010329a:	68 e8 01 00 00       	push   $0x1e8
f010329f:	68 8c 75 10 f0       	push   $0xf010758c
f01032a4:	e8 97 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032ac:	c1 e0 16             	shl    $0x16,%eax
f01032af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032b2:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01032b7:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01032be:	01 
f01032bf:	74 17                	je     f01032d8 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032c1:	83 ec 08             	sub    $0x8,%esp
f01032c4:	89 d8                	mov    %ebx,%eax
f01032c6:	c1 e0 0c             	shl    $0xc,%eax
f01032c9:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01032cc:	50                   	push   %eax
f01032cd:	ff 77 60             	pushl  0x60(%edi)
f01032d0:	e8 ce de ff ff       	call   f01011a3 <page_remove>
f01032d5:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032d8:	83 c3 01             	add    $0x1,%ebx
f01032db:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01032e1:	75 d4                	jne    f01032b7 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01032e3:	8b 47 60             	mov    0x60(%edi),%eax
f01032e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032e9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01032f3:	3b 05 88 7e 20 f0    	cmp    0xf0207e88,%eax
f01032f9:	72 14                	jb     f010330f <env_free+0x101>
		panic("pa2page called with invalid pa");
f01032fb:	83 ec 04             	sub    $0x4,%esp
f01032fe:	68 74 6c 10 f0       	push   $0xf0106c74
f0103303:	6a 51                	push   $0x51
f0103305:	68 60 68 10 f0       	push   $0xf0106860
f010330a:	e8 31 cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f010330f:	83 ec 0c             	sub    $0xc,%esp
f0103312:	a1 90 7e 20 f0       	mov    0xf0207e90,%eax
f0103317:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010331a:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010331d:	50                   	push   %eax
f010331e:	e8 94 dc ff ff       	call   f0100fb7 <page_decref>
f0103323:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103326:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010332a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010332d:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103332:	0f 85 29 ff ff ff    	jne    f0103261 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103338:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010333b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103340:	77 15                	ja     f0103357 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103342:	50                   	push   %eax
f0103343:	68 c8 62 10 f0       	push   $0xf01062c8
f0103348:	68 f6 01 00 00       	push   $0x1f6
f010334d:	68 8c 75 10 f0       	push   $0xf010758c
f0103352:	e8 e9 cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103357:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010335e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103363:	c1 e8 0c             	shr    $0xc,%eax
f0103366:	3b 05 88 7e 20 f0    	cmp    0xf0207e88,%eax
f010336c:	72 14                	jb     f0103382 <env_free+0x174>
		panic("pa2page called with invalid pa");
f010336e:	83 ec 04             	sub    $0x4,%esp
f0103371:	68 74 6c 10 f0       	push   $0xf0106c74
f0103376:	6a 51                	push   $0x51
f0103378:	68 60 68 10 f0       	push   $0xf0106860
f010337d:	e8 be cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103382:	83 ec 0c             	sub    $0xc,%esp
f0103385:	8b 15 90 7e 20 f0    	mov    0xf0207e90,%edx
f010338b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010338e:	50                   	push   %eax
f010338f:	e8 23 dc ff ff       	call   f0100fb7 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103394:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010339b:	a1 4c 72 20 f0       	mov    0xf020724c,%eax
f01033a0:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01033a3:	89 3d 4c 72 20 f0    	mov    %edi,0xf020724c
}
f01033a9:	83 c4 10             	add    $0x10,%esp
f01033ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033af:	5b                   	pop    %ebx
f01033b0:	5e                   	pop    %esi
f01033b1:	5f                   	pop    %edi
f01033b2:	5d                   	pop    %ebp
f01033b3:	c3                   	ret    

f01033b4 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01033b4:	55                   	push   %ebp
f01033b5:	89 e5                	mov    %esp,%ebp
f01033b7:	53                   	push   %ebx
f01033b8:	83 ec 04             	sub    $0x4,%esp
f01033bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01033be:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01033c2:	75 19                	jne    f01033dd <env_destroy+0x29>
f01033c4:	e8 21 28 00 00       	call   f0105bea <cpunum>
f01033c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01033cc:	3b 98 28 80 20 f0    	cmp    -0xfdf7fd8(%eax),%ebx
f01033d2:	74 09                	je     f01033dd <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01033d4:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01033db:	eb 33                	jmp    f0103410 <env_destroy+0x5c>
	}

	env_free(e);
f01033dd:	83 ec 0c             	sub    $0xc,%esp
f01033e0:	53                   	push   %ebx
f01033e1:	e8 28 fe ff ff       	call   f010320e <env_free>

	if (curenv == e) {
f01033e6:	e8 ff 27 00 00       	call   f0105bea <cpunum>
f01033eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01033ee:	83 c4 10             	add    $0x10,%esp
f01033f1:	3b 98 28 80 20 f0    	cmp    -0xfdf7fd8(%eax),%ebx
f01033f7:	75 17                	jne    f0103410 <env_destroy+0x5c>
		curenv = NULL;
f01033f9:	e8 ec 27 00 00       	call   f0105bea <cpunum>
f01033fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103401:	c7 80 28 80 20 f0 00 	movl   $0x0,-0xfdf7fd8(%eax)
f0103408:	00 00 00 
		sched_yield();
f010340b:	e8 ac 10 00 00       	call   f01044bc <sched_yield>
	}
}
f0103410:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103413:	c9                   	leave  
f0103414:	c3                   	ret    

f0103415 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103415:	55                   	push   %ebp
f0103416:	89 e5                	mov    %esp,%ebp
f0103418:	53                   	push   %ebx
f0103419:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010341c:	e8 c9 27 00 00       	call   f0105bea <cpunum>
f0103421:	6b c0 74             	imul   $0x74,%eax,%eax
f0103424:	8b 98 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%ebx
f010342a:	e8 bb 27 00 00       	call   f0105bea <cpunum>
f010342f:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103432:	8b 65 08             	mov    0x8(%ebp),%esp
f0103435:	61                   	popa   
f0103436:	07                   	pop    %es
f0103437:	1f                   	pop    %ds
f0103438:	83 c4 08             	add    $0x8,%esp
f010343b:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010343c:	83 ec 04             	sub    $0x4,%esp
f010343f:	68 aa 75 10 f0       	push   $0xf01075aa
f0103444:	68 2c 02 00 00       	push   $0x22c
f0103449:	68 8c 75 10 f0       	push   $0xf010758c
f010344e:	e8 ed cb ff ff       	call   f0100040 <_panic>

f0103453 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103453:	55                   	push   %ebp
f0103454:	89 e5                	mov    %esp,%ebp
f0103456:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING) {
f0103459:	e8 8c 27 00 00       	call   f0105bea <cpunum>
f010345e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103461:	83 b8 28 80 20 f0 00 	cmpl   $0x0,-0xfdf7fd8(%eax)
f0103468:	74 29                	je     f0103493 <env_run+0x40>
f010346a:	e8 7b 27 00 00       	call   f0105bea <cpunum>
f010346f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103472:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103478:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010347c:	75 15                	jne    f0103493 <env_run+0x40>
        curenv->env_status = ENV_RUNNABLE;
f010347e:	e8 67 27 00 00       	call   f0105bea <cpunum>
f0103483:	6b c0 74             	imul   $0x74,%eax,%eax
f0103486:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f010348c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    }

    curenv = e;
f0103493:	e8 52 27 00 00       	call   f0105bea <cpunum>
f0103498:	6b c0 74             	imul   $0x74,%eax,%eax
f010349b:	8b 55 08             	mov    0x8(%ebp),%edx
f010349e:	89 90 28 80 20 f0    	mov    %edx,-0xfdf7fd8(%eax)
    curenv->env_status = ENV_RUNNING;
f01034a4:	e8 41 27 00 00       	call   f0105bea <cpunum>
f01034a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ac:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f01034b2:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f01034b9:	e8 2c 27 00 00       	call   f0105bea <cpunum>
f01034be:	6b c0 74             	imul   $0x74,%eax,%eax
f01034c1:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f01034c7:	83 40 58 01          	addl   $0x1,0x58(%eax)
    lcr3(PADDR(curenv->env_pgdir));
f01034cb:	e8 1a 27 00 00       	call   f0105bea <cpunum>
f01034d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d3:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f01034d9:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034e1:	77 15                	ja     f01034f8 <env_run+0xa5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034e3:	50                   	push   %eax
f01034e4:	68 c8 62 10 f0       	push   $0xf01062c8
f01034e9:	68 51 02 00 00       	push   $0x251
f01034ee:	68 8c 75 10 f0       	push   $0xf010758c
f01034f3:	e8 48 cb ff ff       	call   f0100040 <_panic>
f01034f8:	05 00 00 00 10       	add    $0x10000000,%eax
f01034fd:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103500:	83 ec 0c             	sub    $0xc,%esp
f0103503:	68 c0 03 12 f0       	push   $0xf01203c0
f0103508:	e8 e8 29 00 00       	call   f0105ef5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010350d:	f3 90                	pause  

	unlock_kernel();
    env_pop_tf(&curenv->env_tf);
f010350f:	e8 d6 26 00 00       	call   f0105bea <cpunum>
f0103514:	83 c4 04             	add    $0x4,%esp
f0103517:	6b c0 74             	imul   $0x74,%eax,%eax
f010351a:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0103520:	e8 f0 fe ff ff       	call   f0103415 <env_pop_tf>

f0103525 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103525:	55                   	push   %ebp
f0103526:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103528:	ba 70 00 00 00       	mov    $0x70,%edx
f010352d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103530:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103531:	ba 71 00 00 00       	mov    $0x71,%edx
f0103536:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103537:	0f b6 c0             	movzbl %al,%eax
}
f010353a:	5d                   	pop    %ebp
f010353b:	c3                   	ret    

f010353c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010353c:	55                   	push   %ebp
f010353d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010353f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103544:	8b 45 08             	mov    0x8(%ebp),%eax
f0103547:	ee                   	out    %al,(%dx)
f0103548:	ba 71 00 00 00       	mov    $0x71,%edx
f010354d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103550:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103551:	5d                   	pop    %ebp
f0103552:	c3                   	ret    

f0103553 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103553:	55                   	push   %ebp
f0103554:	89 e5                	mov    %esp,%ebp
f0103556:	56                   	push   %esi
f0103557:	53                   	push   %ebx
f0103558:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010355b:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103561:	80 3d 50 72 20 f0 00 	cmpb   $0x0,0xf0207250
f0103568:	74 5a                	je     f01035c4 <irq_setmask_8259A+0x71>
f010356a:	89 c6                	mov    %eax,%esi
f010356c:	ba 21 00 00 00       	mov    $0x21,%edx
f0103571:	ee                   	out    %al,(%dx)
f0103572:	66 c1 e8 08          	shr    $0x8,%ax
f0103576:	ba a1 00 00 00       	mov    $0xa1,%edx
f010357b:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010357c:	83 ec 0c             	sub    $0xc,%esp
f010357f:	68 b6 75 10 f0       	push   $0xf01075b6
f0103584:	e8 1b 01 00 00       	call   f01036a4 <cprintf>
f0103589:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010358c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103591:	0f b7 f6             	movzwl %si,%esi
f0103594:	f7 d6                	not    %esi
f0103596:	0f a3 de             	bt     %ebx,%esi
f0103599:	73 11                	jae    f01035ac <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010359b:	83 ec 08             	sub    $0x8,%esp
f010359e:	53                   	push   %ebx
f010359f:	68 2b 7a 10 f0       	push   $0xf0107a2b
f01035a4:	e8 fb 00 00 00       	call   f01036a4 <cprintf>
f01035a9:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01035ac:	83 c3 01             	add    $0x1,%ebx
f01035af:	83 fb 10             	cmp    $0x10,%ebx
f01035b2:	75 e2                	jne    f0103596 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01035b4:	83 ec 0c             	sub    $0xc,%esp
f01035b7:	68 7d 6b 10 f0       	push   $0xf0106b7d
f01035bc:	e8 e3 00 00 00       	call   f01036a4 <cprintf>
f01035c1:	83 c4 10             	add    $0x10,%esp
}
f01035c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01035c7:	5b                   	pop    %ebx
f01035c8:	5e                   	pop    %esi
f01035c9:	5d                   	pop    %ebp
f01035ca:	c3                   	ret    

f01035cb <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01035cb:	c6 05 50 72 20 f0 01 	movb   $0x1,0xf0207250
f01035d2:	ba 21 00 00 00       	mov    $0x21,%edx
f01035d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01035dc:	ee                   	out    %al,(%dx)
f01035dd:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035e2:	ee                   	out    %al,(%dx)
f01035e3:	ba 20 00 00 00       	mov    $0x20,%edx
f01035e8:	b8 11 00 00 00       	mov    $0x11,%eax
f01035ed:	ee                   	out    %al,(%dx)
f01035ee:	ba 21 00 00 00       	mov    $0x21,%edx
f01035f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01035f8:	ee                   	out    %al,(%dx)
f01035f9:	b8 04 00 00 00       	mov    $0x4,%eax
f01035fe:	ee                   	out    %al,(%dx)
f01035ff:	b8 03 00 00 00       	mov    $0x3,%eax
f0103604:	ee                   	out    %al,(%dx)
f0103605:	ba a0 00 00 00       	mov    $0xa0,%edx
f010360a:	b8 11 00 00 00       	mov    $0x11,%eax
f010360f:	ee                   	out    %al,(%dx)
f0103610:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103615:	b8 28 00 00 00       	mov    $0x28,%eax
f010361a:	ee                   	out    %al,(%dx)
f010361b:	b8 02 00 00 00       	mov    $0x2,%eax
f0103620:	ee                   	out    %al,(%dx)
f0103621:	b8 01 00 00 00       	mov    $0x1,%eax
f0103626:	ee                   	out    %al,(%dx)
f0103627:	ba 20 00 00 00       	mov    $0x20,%edx
f010362c:	b8 68 00 00 00       	mov    $0x68,%eax
f0103631:	ee                   	out    %al,(%dx)
f0103632:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103637:	ee                   	out    %al,(%dx)
f0103638:	ba a0 00 00 00       	mov    $0xa0,%edx
f010363d:	b8 68 00 00 00       	mov    $0x68,%eax
f0103642:	ee                   	out    %al,(%dx)
f0103643:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103648:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103649:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103650:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103654:	74 13                	je     f0103669 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103656:	55                   	push   %ebp
f0103657:	89 e5                	mov    %esp,%ebp
f0103659:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f010365c:	0f b7 c0             	movzwl %ax,%eax
f010365f:	50                   	push   %eax
f0103660:	e8 ee fe ff ff       	call   f0103553 <irq_setmask_8259A>
f0103665:	83 c4 10             	add    $0x10,%esp
}
f0103668:	c9                   	leave  
f0103669:	f3 c3                	repz ret 

f010366b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010366b:	55                   	push   %ebp
f010366c:	89 e5                	mov    %esp,%ebp
f010366e:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103671:	ff 75 08             	pushl  0x8(%ebp)
f0103674:	e8 12 d1 ff ff       	call   f010078b <cputchar>
	*cnt++;
}
f0103679:	83 c4 10             	add    $0x10,%esp
f010367c:	c9                   	leave  
f010367d:	c3                   	ret    

f010367e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010367e:	55                   	push   %ebp
f010367f:	89 e5                	mov    %esp,%ebp
f0103681:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103684:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010368b:	ff 75 0c             	pushl  0xc(%ebp)
f010368e:	ff 75 08             	pushl  0x8(%ebp)
f0103691:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103694:	50                   	push   %eax
f0103695:	68 6b 36 10 f0       	push   $0xf010366b
f010369a:	e8 ed 17 00 00       	call   f0104e8c <vprintfmt>
	return cnt;
}
f010369f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01036a2:	c9                   	leave  
f01036a3:	c3                   	ret    

f01036a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01036a4:	55                   	push   %ebp
f01036a5:	89 e5                	mov    %esp,%ebp
f01036a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01036aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01036ad:	50                   	push   %eax
f01036ae:	ff 75 08             	pushl  0x8(%ebp)
f01036b1:	e8 c8 ff ff ff       	call   f010367e <vcprintf>
	va_end(ap);

	return cnt;
}
f01036b6:	c9                   	leave  
f01036b7:	c3                   	ret    

f01036b8 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01036b8:	55                   	push   %ebp
f01036b9:	89 e5                	mov    %esp,%ebp
f01036bb:	57                   	push   %edi
f01036bc:	56                   	push   %esi
f01036bd:	53                   	push   %ebx
f01036be:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpunum() * (KSTKGAP + KSTKSIZE);
f01036c1:	e8 24 25 00 00       	call   f0105bea <cpunum>
f01036c6:	89 c3                	mov    %eax,%ebx
f01036c8:	e8 1d 25 00 00       	call   f0105bea <cpunum>
f01036cd:	6b db 74             	imul   $0x74,%ebx,%ebx
f01036d0:	c1 e0 10             	shl    $0x10,%eax
f01036d3:	89 c2                	mov    %eax,%edx
f01036d5:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f01036da:	29 d0                	sub    %edx,%eax
f01036dc:	89 83 30 80 20 f0    	mov    %eax,-0xfdf7fd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01036e2:	e8 03 25 00 00       	call   f0105bea <cpunum>
f01036e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ea:	66 c7 80 34 80 20 f0 	movw   $0x10,-0xfdf7fcc(%eax)
f01036f1:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f01036f3:	e8 f2 24 00 00       	call   f0105bea <cpunum>
f01036f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01036fb:	0f b6 98 20 80 20 f0 	movzbl -0xfdf7fe0(%eax),%ebx
f0103702:	83 c3 05             	add    $0x5,%ebx
f0103705:	e8 e0 24 00 00       	call   f0105bea <cpunum>
f010370a:	89 c7                	mov    %eax,%edi
f010370c:	e8 d9 24 00 00       	call   f0105bea <cpunum>
f0103711:	89 c6                	mov    %eax,%esi
f0103713:	e8 d2 24 00 00       	call   f0105bea <cpunum>
f0103718:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f010371f:	f0 67 00 
f0103722:	6b ff 74             	imul   $0x74,%edi,%edi
f0103725:	81 c7 2c 80 20 f0    	add    $0xf020802c,%edi
f010372b:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f0103732:	f0 
f0103733:	6b d6 74             	imul   $0x74,%esi,%edx
f0103736:	81 c2 2c 80 20 f0    	add    $0xf020802c,%edx
f010373c:	c1 ea 10             	shr    $0x10,%edx
f010373f:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103746:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f010374d:	99 
f010374e:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f0103755:	40 
f0103756:	6b c0 74             	imul   $0x74,%eax,%eax
f0103759:	05 2c 80 20 f0       	add    $0xf020802c,%eax
f010375e:	c1 e8 18             	shr    $0x18,%eax
f0103761:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0103768:	e8 7d 24 00 00       	call   f0105bea <cpunum>
f010376d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103770:	0f b6 80 20 80 20 f0 	movzbl -0xfdf7fe0(%eax),%eax
f0103777:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f010377e:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + sizeof(struct Segdesc) * cpunum());
f010377f:	e8 66 24 00 00       	call   f0105bea <cpunum>
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103784:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f010378b:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010378e:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103793:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103796:	83 c4 0c             	add    $0xc,%esp
f0103799:	5b                   	pop    %ebx
f010379a:	5e                   	pop    %esi
f010379b:	5f                   	pop    %edi
f010379c:	5d                   	pop    %ebp
f010379d:	c3                   	ret    

f010379e <trap_init>:
	return "(unknown trap)";
}

void
trap_init(void)
{
f010379e:	55                   	push   %ebp
f010379f:	89 e5                	mov    %esp,%ebp
f01037a1:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 		0, GD_KT, t_divide, 	0);
f01037a4:	b8 de 42 10 f0       	mov    $0xf01042de,%eax
f01037a9:	66 a3 60 72 20 f0    	mov    %ax,0xf0207260
f01037af:	66 c7 05 62 72 20 f0 	movw   $0x8,0xf0207262
f01037b6:	08 00 
f01037b8:	c6 05 64 72 20 f0 00 	movb   $0x0,0xf0207264
f01037bf:	c6 05 65 72 20 f0 8e 	movb   $0x8e,0xf0207265
f01037c6:	c1 e8 10             	shr    $0x10,%eax
f01037c9:	66 a3 66 72 20 f0    	mov    %ax,0xf0207266
	SETGATE(idt[T_DEBUG], 		0, GD_KT, t_debug, 		0);
f01037cf:	b8 e8 42 10 f0       	mov    $0xf01042e8,%eax
f01037d4:	66 a3 68 72 20 f0    	mov    %ax,0xf0207268
f01037da:	66 c7 05 6a 72 20 f0 	movw   $0x8,0xf020726a
f01037e1:	08 00 
f01037e3:	c6 05 6c 72 20 f0 00 	movb   $0x0,0xf020726c
f01037ea:	c6 05 6d 72 20 f0 8e 	movb   $0x8e,0xf020726d
f01037f1:	c1 e8 10             	shr    $0x10,%eax
f01037f4:	66 a3 6e 72 20 f0    	mov    %ax,0xf020726e
	SETGATE(idt[T_NMI], 		0, GD_KT, t_nmi, 		0);
f01037fa:	b8 f2 42 10 f0       	mov    $0xf01042f2,%eax
f01037ff:	66 a3 70 72 20 f0    	mov    %ax,0xf0207270
f0103805:	66 c7 05 72 72 20 f0 	movw   $0x8,0xf0207272
f010380c:	08 00 
f010380e:	c6 05 74 72 20 f0 00 	movb   $0x0,0xf0207274
f0103815:	c6 05 75 72 20 f0 8e 	movb   $0x8e,0xf0207275
f010381c:	c1 e8 10             	shr    $0x10,%eax
f010381f:	66 a3 76 72 20 f0    	mov    %ax,0xf0207276
	SETGATE(idt[T_BRKPT], 		0, GD_KT, t_brkpt, 		3);
f0103825:	b8 fc 42 10 f0       	mov    $0xf01042fc,%eax
f010382a:	66 a3 78 72 20 f0    	mov    %ax,0xf0207278
f0103830:	66 c7 05 7a 72 20 f0 	movw   $0x8,0xf020727a
f0103837:	08 00 
f0103839:	c6 05 7c 72 20 f0 00 	movb   $0x0,0xf020727c
f0103840:	c6 05 7d 72 20 f0 ee 	movb   $0xee,0xf020727d
f0103847:	c1 e8 10             	shr    $0x10,%eax
f010384a:	66 a3 7e 72 20 f0    	mov    %ax,0xf020727e
	SETGATE(idt[T_OFLOW], 		0, GD_KT, t_oflow, 		0);
f0103850:	b8 06 43 10 f0       	mov    $0xf0104306,%eax
f0103855:	66 a3 80 72 20 f0    	mov    %ax,0xf0207280
f010385b:	66 c7 05 82 72 20 f0 	movw   $0x8,0xf0207282
f0103862:	08 00 
f0103864:	c6 05 84 72 20 f0 00 	movb   $0x0,0xf0207284
f010386b:	c6 05 85 72 20 f0 8e 	movb   $0x8e,0xf0207285
f0103872:	c1 e8 10             	shr    $0x10,%eax
f0103875:	66 a3 86 72 20 f0    	mov    %ax,0xf0207286
	SETGATE(idt[T_BOUND], 		0, GD_KT, t_bound, 		0);
f010387b:	b8 10 43 10 f0       	mov    $0xf0104310,%eax
f0103880:	66 a3 88 72 20 f0    	mov    %ax,0xf0207288
f0103886:	66 c7 05 8a 72 20 f0 	movw   $0x8,0xf020728a
f010388d:	08 00 
f010388f:	c6 05 8c 72 20 f0 00 	movb   $0x0,0xf020728c
f0103896:	c6 05 8d 72 20 f0 8e 	movb   $0x8e,0xf020728d
f010389d:	c1 e8 10             	shr    $0x10,%eax
f01038a0:	66 a3 8e 72 20 f0    	mov    %ax,0xf020728e
	SETGATE(idt[T_ILLOP], 		0, GD_KT, t_illop, 		0);
f01038a6:	b8 1a 43 10 f0       	mov    $0xf010431a,%eax
f01038ab:	66 a3 90 72 20 f0    	mov    %ax,0xf0207290
f01038b1:	66 c7 05 92 72 20 f0 	movw   $0x8,0xf0207292
f01038b8:	08 00 
f01038ba:	c6 05 94 72 20 f0 00 	movb   $0x0,0xf0207294
f01038c1:	c6 05 95 72 20 f0 8e 	movb   $0x8e,0xf0207295
f01038c8:	c1 e8 10             	shr    $0x10,%eax
f01038cb:	66 a3 96 72 20 f0    	mov    %ax,0xf0207296
	SETGATE(idt[T_DEVICE],		0, GD_KT, t_device, 	0);
f01038d1:	b8 24 43 10 f0       	mov    $0xf0104324,%eax
f01038d6:	66 a3 98 72 20 f0    	mov    %ax,0xf0207298
f01038dc:	66 c7 05 9a 72 20 f0 	movw   $0x8,0xf020729a
f01038e3:	08 00 
f01038e5:	c6 05 9c 72 20 f0 00 	movb   $0x0,0xf020729c
f01038ec:	c6 05 9d 72 20 f0 8e 	movb   $0x8e,0xf020729d
f01038f3:	c1 e8 10             	shr    $0x10,%eax
f01038f6:	66 a3 9e 72 20 f0    	mov    %ax,0xf020729e
	SETGATE(idt[T_DBLFLT], 		0, GD_KT, t_dblflt, 	0);
f01038fc:	b8 2e 43 10 f0       	mov    $0xf010432e,%eax
f0103901:	66 a3 a0 72 20 f0    	mov    %ax,0xf02072a0
f0103907:	66 c7 05 a2 72 20 f0 	movw   $0x8,0xf02072a2
f010390e:	08 00 
f0103910:	c6 05 a4 72 20 f0 00 	movb   $0x0,0xf02072a4
f0103917:	c6 05 a5 72 20 f0 8e 	movb   $0x8e,0xf02072a5
f010391e:	c1 e8 10             	shr    $0x10,%eax
f0103921:	66 a3 a6 72 20 f0    	mov    %ax,0xf02072a6
	SETGATE(idt[T_TSS], 		0, GD_KT, t_tss, 		0);
f0103927:	b8 36 43 10 f0       	mov    $0xf0104336,%eax
f010392c:	66 a3 b0 72 20 f0    	mov    %ax,0xf02072b0
f0103932:	66 c7 05 b2 72 20 f0 	movw   $0x8,0xf02072b2
f0103939:	08 00 
f010393b:	c6 05 b4 72 20 f0 00 	movb   $0x0,0xf02072b4
f0103942:	c6 05 b5 72 20 f0 8e 	movb   $0x8e,0xf02072b5
f0103949:	c1 e8 10             	shr    $0x10,%eax
f010394c:	66 a3 b6 72 20 f0    	mov    %ax,0xf02072b6
	SETGATE(idt[T_SEGNP], 		0, GD_KT, t_segnp, 		0);
f0103952:	b8 3e 43 10 f0       	mov    $0xf010433e,%eax
f0103957:	66 a3 b8 72 20 f0    	mov    %ax,0xf02072b8
f010395d:	66 c7 05 ba 72 20 f0 	movw   $0x8,0xf02072ba
f0103964:	08 00 
f0103966:	c6 05 bc 72 20 f0 00 	movb   $0x0,0xf02072bc
f010396d:	c6 05 bd 72 20 f0 8e 	movb   $0x8e,0xf02072bd
f0103974:	c1 e8 10             	shr    $0x10,%eax
f0103977:	66 a3 be 72 20 f0    	mov    %ax,0xf02072be
	SETGATE(idt[T_STACK], 		0, GD_KT, t_stack, 		0);
f010397d:	b8 46 43 10 f0       	mov    $0xf0104346,%eax
f0103982:	66 a3 c0 72 20 f0    	mov    %ax,0xf02072c0
f0103988:	66 c7 05 c2 72 20 f0 	movw   $0x8,0xf02072c2
f010398f:	08 00 
f0103991:	c6 05 c4 72 20 f0 00 	movb   $0x0,0xf02072c4
f0103998:	c6 05 c5 72 20 f0 8e 	movb   $0x8e,0xf02072c5
f010399f:	c1 e8 10             	shr    $0x10,%eax
f01039a2:	66 a3 c6 72 20 f0    	mov    %ax,0xf02072c6
	SETGATE(idt[T_GPFLT], 		0, GD_KT, t_gpflt, 		0);
f01039a8:	b8 4e 43 10 f0       	mov    $0xf010434e,%eax
f01039ad:	66 a3 c8 72 20 f0    	mov    %ax,0xf02072c8
f01039b3:	66 c7 05 ca 72 20 f0 	movw   $0x8,0xf02072ca
f01039ba:	08 00 
f01039bc:	c6 05 cc 72 20 f0 00 	movb   $0x0,0xf02072cc
f01039c3:	c6 05 cd 72 20 f0 8e 	movb   $0x8e,0xf02072cd
f01039ca:	c1 e8 10             	shr    $0x10,%eax
f01039cd:	66 a3 ce 72 20 f0    	mov    %ax,0xf02072ce
	SETGATE(idt[T_PGFLT], 		0, GD_KT, t_pgflt, 		0);
f01039d3:	b8 56 43 10 f0       	mov    $0xf0104356,%eax
f01039d8:	66 a3 d0 72 20 f0    	mov    %ax,0xf02072d0
f01039de:	66 c7 05 d2 72 20 f0 	movw   $0x8,0xf02072d2
f01039e5:	08 00 
f01039e7:	c6 05 d4 72 20 f0 00 	movb   $0x0,0xf02072d4
f01039ee:	c6 05 d5 72 20 f0 8e 	movb   $0x8e,0xf02072d5
f01039f5:	c1 e8 10             	shr    $0x10,%eax
f01039f8:	66 a3 d6 72 20 f0    	mov    %ax,0xf02072d6
	SETGATE(idt[T_FPERR], 		0, GD_KT, t_fperr, 		0);
f01039fe:	b8 5a 43 10 f0       	mov    $0xf010435a,%eax
f0103a03:	66 a3 e0 72 20 f0    	mov    %ax,0xf02072e0
f0103a09:	66 c7 05 e2 72 20 f0 	movw   $0x8,0xf02072e2
f0103a10:	08 00 
f0103a12:	c6 05 e4 72 20 f0 00 	movb   $0x0,0xf02072e4
f0103a19:	c6 05 e5 72 20 f0 8e 	movb   $0x8e,0xf02072e5
f0103a20:	c1 e8 10             	shr    $0x10,%eax
f0103a23:	66 a3 e6 72 20 f0    	mov    %ax,0xf02072e6
	SETGATE(idt[T_ALIGN], 		0, GD_KT, t_align, 		0);
f0103a29:	b8 60 43 10 f0       	mov    $0xf0104360,%eax
f0103a2e:	66 a3 e8 72 20 f0    	mov    %ax,0xf02072e8
f0103a34:	66 c7 05 ea 72 20 f0 	movw   $0x8,0xf02072ea
f0103a3b:	08 00 
f0103a3d:	c6 05 ec 72 20 f0 00 	movb   $0x0,0xf02072ec
f0103a44:	c6 05 ed 72 20 f0 8e 	movb   $0x8e,0xf02072ed
f0103a4b:	c1 e8 10             	shr    $0x10,%eax
f0103a4e:	66 a3 ee 72 20 f0    	mov    %ax,0xf02072ee
	SETGATE(idt[T_MCHK], 		0, GD_KT, t_mchk, 		0);
f0103a54:	b8 64 43 10 f0       	mov    $0xf0104364,%eax
f0103a59:	66 a3 f0 72 20 f0    	mov    %ax,0xf02072f0
f0103a5f:	66 c7 05 f2 72 20 f0 	movw   $0x8,0xf02072f2
f0103a66:	08 00 
f0103a68:	c6 05 f4 72 20 f0 00 	movb   $0x0,0xf02072f4
f0103a6f:	c6 05 f5 72 20 f0 8e 	movb   $0x8e,0xf02072f5
f0103a76:	c1 e8 10             	shr    $0x10,%eax
f0103a79:	66 a3 f6 72 20 f0    	mov    %ax,0xf02072f6
	SETGATE(idt[T_SIMDERR], 	0, GD_KT, t_simderr,	0);
f0103a7f:	b8 6a 43 10 f0       	mov    $0xf010436a,%eax
f0103a84:	66 a3 f8 72 20 f0    	mov    %ax,0xf02072f8
f0103a8a:	66 c7 05 fa 72 20 f0 	movw   $0x8,0xf02072fa
f0103a91:	08 00 
f0103a93:	c6 05 fc 72 20 f0 00 	movb   $0x0,0xf02072fc
f0103a9a:	c6 05 fd 72 20 f0 8e 	movb   $0x8e,0xf02072fd
f0103aa1:	c1 e8 10             	shr    $0x10,%eax
f0103aa4:	66 a3 fe 72 20 f0    	mov    %ax,0xf02072fe

	SETGATE(idt[T_SYSCALL], 	0, GD_KT, t_syscall, 	3);
f0103aaa:	b8 70 43 10 f0       	mov    $0xf0104370,%eax
f0103aaf:	66 a3 e0 73 20 f0    	mov    %ax,0xf02073e0
f0103ab5:	66 c7 05 e2 73 20 f0 	movw   $0x8,0xf02073e2
f0103abc:	08 00 
f0103abe:	c6 05 e4 73 20 f0 00 	movb   $0x0,0xf02073e4
f0103ac5:	c6 05 e5 73 20 f0 ee 	movb   $0xee,0xf02073e5
f0103acc:	c1 e8 10             	shr    $0x10,%eax
f0103acf:	66 a3 e6 73 20 f0    	mov    %ax,0xf02073e6
	
	SETGATE(idt[IRQ_OFFSET + 0], 	0, GD_KT, t_irq0, 	0);
f0103ad5:	b8 76 43 10 f0       	mov    $0xf0104376,%eax
f0103ada:	66 a3 60 73 20 f0    	mov    %ax,0xf0207360
f0103ae0:	66 c7 05 62 73 20 f0 	movw   $0x8,0xf0207362
f0103ae7:	08 00 
f0103ae9:	c6 05 64 73 20 f0 00 	movb   $0x0,0xf0207364
f0103af0:	c6 05 65 73 20 f0 8e 	movb   $0x8e,0xf0207365
f0103af7:	c1 e8 10             	shr    $0x10,%eax
f0103afa:	66 a3 66 73 20 f0    	mov    %ax,0xf0207366
	SETGATE(idt[IRQ_OFFSET + 1], 	0, GD_KT, t_irq1, 	0);
f0103b00:	b8 7c 43 10 f0       	mov    $0xf010437c,%eax
f0103b05:	66 a3 68 73 20 f0    	mov    %ax,0xf0207368
f0103b0b:	66 c7 05 6a 73 20 f0 	movw   $0x8,0xf020736a
f0103b12:	08 00 
f0103b14:	c6 05 6c 73 20 f0 00 	movb   $0x0,0xf020736c
f0103b1b:	c6 05 6d 73 20 f0 8e 	movb   $0x8e,0xf020736d
f0103b22:	c1 e8 10             	shr    $0x10,%eax
f0103b25:	66 a3 6e 73 20 f0    	mov    %ax,0xf020736e
	SETGATE(idt[IRQ_OFFSET + 2], 	0, GD_KT, t_irq2, 	0);
f0103b2b:	b8 82 43 10 f0       	mov    $0xf0104382,%eax
f0103b30:	66 a3 70 73 20 f0    	mov    %ax,0xf0207370
f0103b36:	66 c7 05 72 73 20 f0 	movw   $0x8,0xf0207372
f0103b3d:	08 00 
f0103b3f:	c6 05 74 73 20 f0 00 	movb   $0x0,0xf0207374
f0103b46:	c6 05 75 73 20 f0 8e 	movb   $0x8e,0xf0207375
f0103b4d:	c1 e8 10             	shr    $0x10,%eax
f0103b50:	66 a3 76 73 20 f0    	mov    %ax,0xf0207376
	SETGATE(idt[IRQ_OFFSET + 3], 	0, GD_KT, t_irq3, 	0);
f0103b56:	b8 88 43 10 f0       	mov    $0xf0104388,%eax
f0103b5b:	66 a3 78 73 20 f0    	mov    %ax,0xf0207378
f0103b61:	66 c7 05 7a 73 20 f0 	movw   $0x8,0xf020737a
f0103b68:	08 00 
f0103b6a:	c6 05 7c 73 20 f0 00 	movb   $0x0,0xf020737c
f0103b71:	c6 05 7d 73 20 f0 8e 	movb   $0x8e,0xf020737d
f0103b78:	c1 e8 10             	shr    $0x10,%eax
f0103b7b:	66 a3 7e 73 20 f0    	mov    %ax,0xf020737e
	SETGATE(idt[IRQ_OFFSET + 4], 	0, GD_KT, t_irq4, 	0);
f0103b81:	b8 8e 43 10 f0       	mov    $0xf010438e,%eax
f0103b86:	66 a3 80 73 20 f0    	mov    %ax,0xf0207380
f0103b8c:	66 c7 05 82 73 20 f0 	movw   $0x8,0xf0207382
f0103b93:	08 00 
f0103b95:	c6 05 84 73 20 f0 00 	movb   $0x0,0xf0207384
f0103b9c:	c6 05 85 73 20 f0 8e 	movb   $0x8e,0xf0207385
f0103ba3:	c1 e8 10             	shr    $0x10,%eax
f0103ba6:	66 a3 86 73 20 f0    	mov    %ax,0xf0207386
	SETGATE(idt[IRQ_OFFSET + 5], 	0, GD_KT, t_irq5, 	0);
f0103bac:	b8 94 43 10 f0       	mov    $0xf0104394,%eax
f0103bb1:	66 a3 88 73 20 f0    	mov    %ax,0xf0207388
f0103bb7:	66 c7 05 8a 73 20 f0 	movw   $0x8,0xf020738a
f0103bbe:	08 00 
f0103bc0:	c6 05 8c 73 20 f0 00 	movb   $0x0,0xf020738c
f0103bc7:	c6 05 8d 73 20 f0 8e 	movb   $0x8e,0xf020738d
f0103bce:	c1 e8 10             	shr    $0x10,%eax
f0103bd1:	66 a3 8e 73 20 f0    	mov    %ax,0xf020738e
	SETGATE(idt[IRQ_OFFSET + 6],	0, GD_KT, t_irq6, 	0);
f0103bd7:	b8 9a 43 10 f0       	mov    $0xf010439a,%eax
f0103bdc:	66 a3 90 73 20 f0    	mov    %ax,0xf0207390
f0103be2:	66 c7 05 92 73 20 f0 	movw   $0x8,0xf0207392
f0103be9:	08 00 
f0103beb:	c6 05 94 73 20 f0 00 	movb   $0x0,0xf0207394
f0103bf2:	c6 05 95 73 20 f0 8e 	movb   $0x8e,0xf0207395
f0103bf9:	c1 e8 10             	shr    $0x10,%eax
f0103bfc:	66 a3 96 73 20 f0    	mov    %ax,0xf0207396
	SETGATE(idt[IRQ_OFFSET + 7],	0, GD_KT, t_irq7, 	0);
f0103c02:	b8 a0 43 10 f0       	mov    $0xf01043a0,%eax
f0103c07:	66 a3 98 73 20 f0    	mov    %ax,0xf0207398
f0103c0d:	66 c7 05 9a 73 20 f0 	movw   $0x8,0xf020739a
f0103c14:	08 00 
f0103c16:	c6 05 9c 73 20 f0 00 	movb   $0x0,0xf020739c
f0103c1d:	c6 05 9d 73 20 f0 8e 	movb   $0x8e,0xf020739d
f0103c24:	c1 e8 10             	shr    $0x10,%eax
f0103c27:	66 a3 9e 73 20 f0    	mov    %ax,0xf020739e
	SETGATE(idt[IRQ_OFFSET + 8],	0, GD_KT, t_irq8, 	0);
f0103c2d:	b8 a6 43 10 f0       	mov    $0xf01043a6,%eax
f0103c32:	66 a3 a0 73 20 f0    	mov    %ax,0xf02073a0
f0103c38:	66 c7 05 a2 73 20 f0 	movw   $0x8,0xf02073a2
f0103c3f:	08 00 
f0103c41:	c6 05 a4 73 20 f0 00 	movb   $0x0,0xf02073a4
f0103c48:	c6 05 a5 73 20 f0 8e 	movb   $0x8e,0xf02073a5
f0103c4f:	c1 e8 10             	shr    $0x10,%eax
f0103c52:	66 a3 a6 73 20 f0    	mov    %ax,0xf02073a6
	SETGATE(idt[IRQ_OFFSET + 9],	0, GD_KT, t_irq9, 	0);
f0103c58:	b8 ac 43 10 f0       	mov    $0xf01043ac,%eax
f0103c5d:	66 a3 a8 73 20 f0    	mov    %ax,0xf02073a8
f0103c63:	66 c7 05 aa 73 20 f0 	movw   $0x8,0xf02073aa
f0103c6a:	08 00 
f0103c6c:	c6 05 ac 73 20 f0 00 	movb   $0x0,0xf02073ac
f0103c73:	c6 05 ad 73 20 f0 8e 	movb   $0x8e,0xf02073ad
f0103c7a:	c1 e8 10             	shr    $0x10,%eax
f0103c7d:	66 a3 ae 73 20 f0    	mov    %ax,0xf02073ae
	SETGATE(idt[IRQ_OFFSET + 10], 	0, GD_KT, t_irq10, 	0);
f0103c83:	b8 b2 43 10 f0       	mov    $0xf01043b2,%eax
f0103c88:	66 a3 b0 73 20 f0    	mov    %ax,0xf02073b0
f0103c8e:	66 c7 05 b2 73 20 f0 	movw   $0x8,0xf02073b2
f0103c95:	08 00 
f0103c97:	c6 05 b4 73 20 f0 00 	movb   $0x0,0xf02073b4
f0103c9e:	c6 05 b5 73 20 f0 8e 	movb   $0x8e,0xf02073b5
f0103ca5:	c1 e8 10             	shr    $0x10,%eax
f0103ca8:	66 a3 b6 73 20 f0    	mov    %ax,0xf02073b6
	SETGATE(idt[IRQ_OFFSET + 11], 	0, GD_KT, t_irq11, 	0);
f0103cae:	b8 b8 43 10 f0       	mov    $0xf01043b8,%eax
f0103cb3:	66 a3 b8 73 20 f0    	mov    %ax,0xf02073b8
f0103cb9:	66 c7 05 ba 73 20 f0 	movw   $0x8,0xf02073ba
f0103cc0:	08 00 
f0103cc2:	c6 05 bc 73 20 f0 00 	movb   $0x0,0xf02073bc
f0103cc9:	c6 05 bd 73 20 f0 8e 	movb   $0x8e,0xf02073bd
f0103cd0:	c1 e8 10             	shr    $0x10,%eax
f0103cd3:	66 a3 be 73 20 f0    	mov    %ax,0xf02073be
	SETGATE(idt[IRQ_OFFSET + 12], 	0, GD_KT, t_irq12, 	0);
f0103cd9:	b8 be 43 10 f0       	mov    $0xf01043be,%eax
f0103cde:	66 a3 c0 73 20 f0    	mov    %ax,0xf02073c0
f0103ce4:	66 c7 05 c2 73 20 f0 	movw   $0x8,0xf02073c2
f0103ceb:	08 00 
f0103ced:	c6 05 c4 73 20 f0 00 	movb   $0x0,0xf02073c4
f0103cf4:	c6 05 c5 73 20 f0 8e 	movb   $0x8e,0xf02073c5
f0103cfb:	c1 e8 10             	shr    $0x10,%eax
f0103cfe:	66 a3 c6 73 20 f0    	mov    %ax,0xf02073c6
	SETGATE(idt[IRQ_OFFSET + 13], 	0, GD_KT, t_irq13, 	0);
f0103d04:	b8 c4 43 10 f0       	mov    $0xf01043c4,%eax
f0103d09:	66 a3 c8 73 20 f0    	mov    %ax,0xf02073c8
f0103d0f:	66 c7 05 ca 73 20 f0 	movw   $0x8,0xf02073ca
f0103d16:	08 00 
f0103d18:	c6 05 cc 73 20 f0 00 	movb   $0x0,0xf02073cc
f0103d1f:	c6 05 cd 73 20 f0 8e 	movb   $0x8e,0xf02073cd
f0103d26:	c1 e8 10             	shr    $0x10,%eax
f0103d29:	66 a3 ce 73 20 f0    	mov    %ax,0xf02073ce
	SETGATE(idt[IRQ_OFFSET + 14], 	0, GD_KT, t_irq14, 	0);
f0103d2f:	b8 ca 43 10 f0       	mov    $0xf01043ca,%eax
f0103d34:	66 a3 d0 73 20 f0    	mov    %ax,0xf02073d0
f0103d3a:	66 c7 05 d2 73 20 f0 	movw   $0x8,0xf02073d2
f0103d41:	08 00 
f0103d43:	c6 05 d4 73 20 f0 00 	movb   $0x0,0xf02073d4
f0103d4a:	c6 05 d5 73 20 f0 8e 	movb   $0x8e,0xf02073d5
f0103d51:	c1 e8 10             	shr    $0x10,%eax
f0103d54:	66 a3 d6 73 20 f0    	mov    %ax,0xf02073d6
	SETGATE(idt[IRQ_OFFSET + 15], 	0, GD_KT, t_irq15, 	0);
f0103d5a:	b8 d0 43 10 f0       	mov    $0xf01043d0,%eax
f0103d5f:	66 a3 d8 73 20 f0    	mov    %ax,0xf02073d8
f0103d65:	66 c7 05 da 73 20 f0 	movw   $0x8,0xf02073da
f0103d6c:	08 00 
f0103d6e:	c6 05 dc 73 20 f0 00 	movb   $0x0,0xf02073dc
f0103d75:	c6 05 dd 73 20 f0 8e 	movb   $0x8e,0xf02073dd
f0103d7c:	c1 e8 10             	shr    $0x10,%eax
f0103d7f:	66 a3 de 73 20 f0    	mov    %ax,0xf02073de

	// Per-CPU setup 
	trap_init_percpu();
f0103d85:	e8 2e f9 ff ff       	call   f01036b8 <trap_init_percpu>
}
f0103d8a:	c9                   	leave  
f0103d8b:	c3                   	ret    

f0103d8c <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d8c:	55                   	push   %ebp
f0103d8d:	89 e5                	mov    %esp,%ebp
f0103d8f:	53                   	push   %ebx
f0103d90:	83 ec 0c             	sub    $0xc,%esp
f0103d93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d96:	ff 33                	pushl  (%ebx)
f0103d98:	68 ca 75 10 f0       	push   $0xf01075ca
f0103d9d:	e8 02 f9 ff ff       	call   f01036a4 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103da2:	83 c4 08             	add    $0x8,%esp
f0103da5:	ff 73 04             	pushl  0x4(%ebx)
f0103da8:	68 d9 75 10 f0       	push   $0xf01075d9
f0103dad:	e8 f2 f8 ff ff       	call   f01036a4 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103db2:	83 c4 08             	add    $0x8,%esp
f0103db5:	ff 73 08             	pushl  0x8(%ebx)
f0103db8:	68 e8 75 10 f0       	push   $0xf01075e8
f0103dbd:	e8 e2 f8 ff ff       	call   f01036a4 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103dc2:	83 c4 08             	add    $0x8,%esp
f0103dc5:	ff 73 0c             	pushl  0xc(%ebx)
f0103dc8:	68 f7 75 10 f0       	push   $0xf01075f7
f0103dcd:	e8 d2 f8 ff ff       	call   f01036a4 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103dd2:	83 c4 08             	add    $0x8,%esp
f0103dd5:	ff 73 10             	pushl  0x10(%ebx)
f0103dd8:	68 06 76 10 f0       	push   $0xf0107606
f0103ddd:	e8 c2 f8 ff ff       	call   f01036a4 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103de2:	83 c4 08             	add    $0x8,%esp
f0103de5:	ff 73 14             	pushl  0x14(%ebx)
f0103de8:	68 15 76 10 f0       	push   $0xf0107615
f0103ded:	e8 b2 f8 ff ff       	call   f01036a4 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103df2:	83 c4 08             	add    $0x8,%esp
f0103df5:	ff 73 18             	pushl  0x18(%ebx)
f0103df8:	68 24 76 10 f0       	push   $0xf0107624
f0103dfd:	e8 a2 f8 ff ff       	call   f01036a4 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e02:	83 c4 08             	add    $0x8,%esp
f0103e05:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e08:	68 33 76 10 f0       	push   $0xf0107633
f0103e0d:	e8 92 f8 ff ff       	call   f01036a4 <cprintf>
}
f0103e12:	83 c4 10             	add    $0x10,%esp
f0103e15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e18:	c9                   	leave  
f0103e19:	c3                   	ret    

f0103e1a <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e1a:	55                   	push   %ebp
f0103e1b:	89 e5                	mov    %esp,%ebp
f0103e1d:	56                   	push   %esi
f0103e1e:	53                   	push   %ebx
f0103e1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e22:	e8 c3 1d 00 00       	call   f0105bea <cpunum>
f0103e27:	83 ec 04             	sub    $0x4,%esp
f0103e2a:	50                   	push   %eax
f0103e2b:	53                   	push   %ebx
f0103e2c:	68 97 76 10 f0       	push   $0xf0107697
f0103e31:	e8 6e f8 ff ff       	call   f01036a4 <cprintf>
	print_regs(&tf->tf_regs);
f0103e36:	89 1c 24             	mov    %ebx,(%esp)
f0103e39:	e8 4e ff ff ff       	call   f0103d8c <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e3e:	83 c4 08             	add    $0x8,%esp
f0103e41:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e45:	50                   	push   %eax
f0103e46:	68 b5 76 10 f0       	push   $0xf01076b5
f0103e4b:	e8 54 f8 ff ff       	call   f01036a4 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e50:	83 c4 08             	add    $0x8,%esp
f0103e53:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e57:	50                   	push   %eax
f0103e58:	68 c8 76 10 f0       	push   $0xf01076c8
f0103e5d:	e8 42 f8 ff ff       	call   f01036a4 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e62:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103e65:	83 c4 10             	add    $0x10,%esp
f0103e68:	83 f8 13             	cmp    $0x13,%eax
f0103e6b:	77 09                	ja     f0103e76 <print_trapframe+0x5c>
		return excnames[trapno];
f0103e6d:	8b 14 85 40 79 10 f0 	mov    -0xfef86c0(,%eax,4),%edx
f0103e74:	eb 1f                	jmp    f0103e95 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103e76:	83 f8 30             	cmp    $0x30,%eax
f0103e79:	74 15                	je     f0103e90 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e7b:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103e7e:	83 fa 10             	cmp    $0x10,%edx
f0103e81:	b9 61 76 10 f0       	mov    $0xf0107661,%ecx
f0103e86:	ba 4e 76 10 f0       	mov    $0xf010764e,%edx
f0103e8b:	0f 43 d1             	cmovae %ecx,%edx
f0103e8e:	eb 05                	jmp    f0103e95 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103e90:	ba 42 76 10 f0       	mov    $0xf0107642,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e95:	83 ec 04             	sub    $0x4,%esp
f0103e98:	52                   	push   %edx
f0103e99:	50                   	push   %eax
f0103e9a:	68 db 76 10 f0       	push   $0xf01076db
f0103e9f:	e8 00 f8 ff ff       	call   f01036a4 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ea4:	83 c4 10             	add    $0x10,%esp
f0103ea7:	3b 1d 60 7a 20 f0    	cmp    0xf0207a60,%ebx
f0103ead:	75 1a                	jne    f0103ec9 <print_trapframe+0xaf>
f0103eaf:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103eb3:	75 14                	jne    f0103ec9 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103eb5:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103eb8:	83 ec 08             	sub    $0x8,%esp
f0103ebb:	50                   	push   %eax
f0103ebc:	68 ed 76 10 f0       	push   $0xf01076ed
f0103ec1:	e8 de f7 ff ff       	call   f01036a4 <cprintf>
f0103ec6:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103ec9:	83 ec 08             	sub    $0x8,%esp
f0103ecc:	ff 73 2c             	pushl  0x2c(%ebx)
f0103ecf:	68 fc 76 10 f0       	push   $0xf01076fc
f0103ed4:	e8 cb f7 ff ff       	call   f01036a4 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103ed9:	83 c4 10             	add    $0x10,%esp
f0103edc:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ee0:	75 49                	jne    f0103f2b <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103ee2:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103ee5:	89 c2                	mov    %eax,%edx
f0103ee7:	83 e2 01             	and    $0x1,%edx
f0103eea:	ba 7b 76 10 f0       	mov    $0xf010767b,%edx
f0103eef:	b9 70 76 10 f0       	mov    $0xf0107670,%ecx
f0103ef4:	0f 44 ca             	cmove  %edx,%ecx
f0103ef7:	89 c2                	mov    %eax,%edx
f0103ef9:	83 e2 02             	and    $0x2,%edx
f0103efc:	ba 8d 76 10 f0       	mov    $0xf010768d,%edx
f0103f01:	be 87 76 10 f0       	mov    $0xf0107687,%esi
f0103f06:	0f 45 d6             	cmovne %esi,%edx
f0103f09:	83 e0 04             	and    $0x4,%eax
f0103f0c:	be c7 77 10 f0       	mov    $0xf01077c7,%esi
f0103f11:	b8 92 76 10 f0       	mov    $0xf0107692,%eax
f0103f16:	0f 44 c6             	cmove  %esi,%eax
f0103f19:	51                   	push   %ecx
f0103f1a:	52                   	push   %edx
f0103f1b:	50                   	push   %eax
f0103f1c:	68 0a 77 10 f0       	push   $0xf010770a
f0103f21:	e8 7e f7 ff ff       	call   f01036a4 <cprintf>
f0103f26:	83 c4 10             	add    $0x10,%esp
f0103f29:	eb 10                	jmp    f0103f3b <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103f2b:	83 ec 0c             	sub    $0xc,%esp
f0103f2e:	68 7d 6b 10 f0       	push   $0xf0106b7d
f0103f33:	e8 6c f7 ff ff       	call   f01036a4 <cprintf>
f0103f38:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f3b:	83 ec 08             	sub    $0x8,%esp
f0103f3e:	ff 73 30             	pushl  0x30(%ebx)
f0103f41:	68 19 77 10 f0       	push   $0xf0107719
f0103f46:	e8 59 f7 ff ff       	call   f01036a4 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f4b:	83 c4 08             	add    $0x8,%esp
f0103f4e:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f52:	50                   	push   %eax
f0103f53:	68 28 77 10 f0       	push   $0xf0107728
f0103f58:	e8 47 f7 ff ff       	call   f01036a4 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f5d:	83 c4 08             	add    $0x8,%esp
f0103f60:	ff 73 38             	pushl  0x38(%ebx)
f0103f63:	68 3b 77 10 f0       	push   $0xf010773b
f0103f68:	e8 37 f7 ff ff       	call   f01036a4 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f6d:	83 c4 10             	add    $0x10,%esp
f0103f70:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f74:	74 25                	je     f0103f9b <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f76:	83 ec 08             	sub    $0x8,%esp
f0103f79:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f7c:	68 4a 77 10 f0       	push   $0xf010774a
f0103f81:	e8 1e f7 ff ff       	call   f01036a4 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f86:	83 c4 08             	add    $0x8,%esp
f0103f89:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f8d:	50                   	push   %eax
f0103f8e:	68 59 77 10 f0       	push   $0xf0107759
f0103f93:	e8 0c f7 ff ff       	call   f01036a4 <cprintf>
f0103f98:	83 c4 10             	add    $0x10,%esp
	}
}
f0103f9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f9e:	5b                   	pop    %ebx
f0103f9f:	5e                   	pop    %esi
f0103fa0:	5d                   	pop    %ebp
f0103fa1:	c3                   	ret    

f0103fa2 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103fa2:	55                   	push   %ebp
f0103fa3:	89 e5                	mov    %esp,%ebp
f0103fa5:	57                   	push   %edi
f0103fa6:	56                   	push   %esi
f0103fa7:	53                   	push   %ebx
f0103fa8:	83 ec 1c             	sub    $0x1c,%esp
f0103fab:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fae:	0f 20 d6             	mov    %cr2,%esi
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0103fb1:	e8 34 1c 00 00       	call   f0105bea <cpunum>
f0103fb6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb9:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103fbf:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103fc3:	0f 84 93 00 00 00    	je     f010405c <page_fault_handler+0xba>

		struct UTrapframe *utf;
		uintptr_t utfstart;

		if (tf->tf_esp <= UXSTACKTOP - 1 && 
f0103fc9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103fcc:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			tf->tf_esp >= UXSTACKTOP - PGSIZE)
			utfstart = tf->tf_esp - 32 / 8;
f0103fd2:	83 e8 04             	sub    $0x4,%eax
f0103fd5:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103fdb:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0103fe0:	0f 46 f8             	cmovbe %eax,%edi
		else
			utfstart = UXSTACKTOP;
			
		utf = (struct UTrapframe *)(utfstart - sizeof(struct UTrapframe));
f0103fe3:	8d 47 cc             	lea    -0x34(%edi),%eax
f0103fe6:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_U | PTE_W);
f0103fe9:	e8 fc 1b 00 00       	call   f0105bea <cpunum>
f0103fee:	6a 06                	push   $0x6
f0103ff0:	6a 34                	push   $0x34
f0103ff2:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103ff5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff8:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0103ffe:	e8 8d ed ff ff       	call   f0102d90 <user_mem_assert>

		utf->utf_fault_va 	= fault_va;
f0104003:	89 77 cc             	mov    %esi,-0x34(%edi)
		utf->utf_err 		= tf->tf_trapno;
f0104006:	8b 43 28             	mov    0x28(%ebx),%eax
f0104009:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010400c:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs 		= tf->tf_regs;
f010400f:	83 ef 2c             	sub    $0x2c,%edi
f0104012:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104017:	89 de                	mov    %ebx,%esi
f0104019:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip 		= tf->tf_eip;
f010401b:	8b 43 30             	mov    0x30(%ebx),%eax
f010401e:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags		= tf->tf_eflags;
f0104021:	8b 43 38             	mov    0x38(%ebx),%eax
f0104024:	89 d6                	mov    %edx,%esi
f0104026:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp 		= tf->tf_esp;
f0104029:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010402c:	89 42 30             	mov    %eax,0x30(%edx)

		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f010402f:	e8 b6 1b 00 00       	call   f0105bea <cpunum>
f0104034:	6b c0 74             	imul   $0x74,%eax,%eax
f0104037:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f010403d:	8b 40 64             	mov    0x64(%eax),%eax
f0104040:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uint32_t)utf;
f0104043:	89 73 3c             	mov    %esi,0x3c(%ebx)

		env_run(curenv);
f0104046:	e8 9f 1b 00 00       	call   f0105bea <cpunum>
f010404b:	83 c4 04             	add    $0x4,%esp
f010404e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104051:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0104057:	e8 f7 f3 ff ff       	call   f0103453 <env_run>
		
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010405c:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010405f:	e8 86 1b 00 00       	call   f0105bea <cpunum>
		env_run(curenv);
		
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104064:	57                   	push   %edi
f0104065:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104066:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);
		
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104069:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f010406f:	ff 70 48             	pushl  0x48(%eax)
f0104072:	68 14 79 10 f0       	push   $0xf0107914
f0104077:	e8 28 f6 ff ff       	call   f01036a4 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010407c:	89 1c 24             	mov    %ebx,(%esp)
f010407f:	e8 96 fd ff ff       	call   f0103e1a <print_trapframe>
	env_destroy(curenv);
f0104084:	e8 61 1b 00 00       	call   f0105bea <cpunum>
f0104089:	83 c4 04             	add    $0x4,%esp
f010408c:	6b c0 74             	imul   $0x74,%eax,%eax
f010408f:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0104095:	e8 1a f3 ff ff       	call   f01033b4 <env_destroy>
}
f010409a:	83 c4 10             	add    $0x10,%esp
f010409d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040a0:	5b                   	pop    %ebx
f01040a1:	5e                   	pop    %esi
f01040a2:	5f                   	pop    %edi
f01040a3:	5d                   	pop    %ebp
f01040a4:	c3                   	ret    

f01040a5 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01040a5:	55                   	push   %ebp
f01040a6:	89 e5                	mov    %esp,%ebp
f01040a8:	57                   	push   %edi
f01040a9:	56                   	push   %esi
f01040aa:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01040ad:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01040ae:	83 3d 80 7e 20 f0 00 	cmpl   $0x0,0xf0207e80
f01040b5:	74 01                	je     f01040b8 <trap+0x13>
		asm volatile("hlt");
f01040b7:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01040b8:	e8 2d 1b 00 00       	call   f0105bea <cpunum>
f01040bd:	6b d0 74             	imul   $0x74,%eax,%edx
f01040c0:	81 c2 20 80 20 f0    	add    $0xf0208020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01040c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01040cb:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01040cf:	83 f8 02             	cmp    $0x2,%eax
f01040d2:	75 10                	jne    f01040e4 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01040d4:	83 ec 0c             	sub    $0xc,%esp
f01040d7:	68 c0 03 12 f0       	push   $0xf01203c0
f01040dc:	e8 77 1d 00 00       	call   f0105e58 <spin_lock>
f01040e1:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01040e4:	9c                   	pushf  
f01040e5:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01040e6:	f6 c4 02             	test   $0x2,%ah
f01040e9:	74 19                	je     f0104104 <trap+0x5f>
f01040eb:	68 6c 77 10 f0       	push   $0xf010776c
f01040f0:	68 7a 68 10 f0       	push   $0xf010687a
f01040f5:	68 45 01 00 00       	push   $0x145
f01040fa:	68 85 77 10 f0       	push   $0xf0107785
f01040ff:	e8 3c bf ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104104:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104108:	83 e0 03             	and    $0x3,%eax
f010410b:	66 83 f8 03          	cmp    $0x3,%ax
f010410f:	0f 85 a0 00 00 00    	jne    f01041b5 <trap+0x110>
f0104115:	83 ec 0c             	sub    $0xc,%esp
f0104118:	68 c0 03 12 f0       	push   $0xf01203c0
f010411d:	e8 36 1d 00 00       	call   f0105e58 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104122:	e8 c3 1a 00 00       	call   f0105bea <cpunum>
f0104127:	6b c0 74             	imul   $0x74,%eax,%eax
f010412a:	83 c4 10             	add    $0x10,%esp
f010412d:	83 b8 28 80 20 f0 00 	cmpl   $0x0,-0xfdf7fd8(%eax)
f0104134:	75 19                	jne    f010414f <trap+0xaa>
f0104136:	68 91 77 10 f0       	push   $0xf0107791
f010413b:	68 7a 68 10 f0       	push   $0xf010687a
f0104140:	68 4d 01 00 00       	push   $0x14d
f0104145:	68 85 77 10 f0       	push   $0xf0107785
f010414a:	e8 f1 be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010414f:	e8 96 1a 00 00       	call   f0105bea <cpunum>
f0104154:	6b c0 74             	imul   $0x74,%eax,%eax
f0104157:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f010415d:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104161:	75 2d                	jne    f0104190 <trap+0xeb>
			env_free(curenv);
f0104163:	e8 82 1a 00 00       	call   f0105bea <cpunum>
f0104168:	83 ec 0c             	sub    $0xc,%esp
f010416b:	6b c0 74             	imul   $0x74,%eax,%eax
f010416e:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0104174:	e8 95 f0 ff ff       	call   f010320e <env_free>
			curenv = NULL;
f0104179:	e8 6c 1a 00 00       	call   f0105bea <cpunum>
f010417e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104181:	c7 80 28 80 20 f0 00 	movl   $0x0,-0xfdf7fd8(%eax)
f0104188:	00 00 00 
			sched_yield();
f010418b:	e8 2c 03 00 00       	call   f01044bc <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104190:	e8 55 1a 00 00       	call   f0105bea <cpunum>
f0104195:	6b c0 74             	imul   $0x74,%eax,%eax
f0104198:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f010419e:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041a3:	89 c7                	mov    %eax,%edi
f01041a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01041a7:	e8 3e 1a 00 00       	call   f0105bea <cpunum>
f01041ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01041af:	8b b0 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01041b5:	89 35 60 7a 20 f0    	mov    %esi,0xf0207a60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno) {
f01041bb:	8b 46 28             	mov    0x28(%esi),%eax
f01041be:	83 f8 0e             	cmp    $0xe,%eax
f01041c1:	74 0c                	je     f01041cf <trap+0x12a>
f01041c3:	83 f8 30             	cmp    $0x30,%eax
f01041c6:	74 29                	je     f01041f1 <trap+0x14c>
f01041c8:	83 f8 03             	cmp    $0x3,%eax
f01041cb:	75 48                	jne    f0104215 <trap+0x170>
f01041cd:	eb 11                	jmp    f01041e0 <trap+0x13b>
			case T_PGFLT:
				page_fault_handler(tf);
f01041cf:	83 ec 0c             	sub    $0xc,%esp
f01041d2:	56                   	push   %esi
f01041d3:	e8 ca fd ff ff       	call   f0103fa2 <page_fault_handler>
f01041d8:	83 c4 10             	add    $0x10,%esp
f01041db:	e9 be 00 00 00       	jmp    f010429e <trap+0x1f9>
				return;
			case T_BRKPT:
				monitor(tf);
f01041e0:	83 ec 0c             	sub    $0xc,%esp
f01041e3:	56                   	push   %esi
f01041e4:	e8 46 c7 ff ff       	call   f010092f <monitor>
f01041e9:	83 c4 10             	add    $0x10,%esp
f01041ec:	e9 ad 00 00 00       	jmp    f010429e <trap+0x1f9>
				return;
			case T_SYSCALL:
				tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f01041f1:	83 ec 08             	sub    $0x8,%esp
f01041f4:	ff 76 04             	pushl  0x4(%esi)
f01041f7:	ff 36                	pushl  (%esi)
f01041f9:	ff 76 10             	pushl  0x10(%esi)
f01041fc:	ff 76 18             	pushl  0x18(%esi)
f01041ff:	ff 76 14             	pushl  0x14(%esi)
f0104202:	ff 76 1c             	pushl  0x1c(%esi)
f0104205:	e8 2f 03 00 00       	call   f0104539 <syscall>
f010420a:	89 46 1c             	mov    %eax,0x1c(%esi)
f010420d:	83 c4 20             	add    $0x20,%esp
f0104210:	e9 89 00 00 00       	jmp    f010429e <trap+0x1f9>
		}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104215:	83 f8 27             	cmp    $0x27,%eax
f0104218:	75 1a                	jne    f0104234 <trap+0x18f>
		cprintf("Spurious interrupt on irq 7\n");
f010421a:	83 ec 0c             	sub    $0xc,%esp
f010421d:	68 98 77 10 f0       	push   $0xf0107798
f0104222:	e8 7d f4 ff ff       	call   f01036a4 <cprintf>
		print_trapframe(tf);
f0104227:	89 34 24             	mov    %esi,(%esp)
f010422a:	e8 eb fb ff ff       	call   f0103e1a <print_trapframe>
f010422f:	83 c4 10             	add    $0x10,%esp
f0104232:	eb 6a                	jmp    f010429e <trap+0x1f9>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104234:	83 f8 20             	cmp    $0x20,%eax
f0104237:	75 0a                	jne    f0104243 <trap+0x19e>
		lapic_eoi();
f0104239:	e8 f7 1a 00 00       	call   f0105d35 <lapic_eoi>
		sched_yield();
f010423e:	e8 79 02 00 00       	call   f01044bc <sched_yield>
		return;
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f0104243:	83 f8 21             	cmp    $0x21,%eax
f0104246:	75 07                	jne    f010424f <trap+0x1aa>
		kbd_intr();
f0104248:	e8 9c c3 ff ff       	call   f01005e9 <kbd_intr>
f010424d:	eb 4f                	jmp    f010429e <trap+0x1f9>
		return;
	}

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f010424f:	83 f8 24             	cmp    $0x24,%eax
f0104252:	75 07                	jne    f010425b <trap+0x1b6>
		serial_intr();
f0104254:	e8 74 c3 ff ff       	call   f01005cd <serial_intr>
f0104259:	eb 43                	jmp    f010429e <trap+0x1f9>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010425b:	83 ec 0c             	sub    $0xc,%esp
f010425e:	56                   	push   %esi
f010425f:	e8 b6 fb ff ff       	call   f0103e1a <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104264:	83 c4 10             	add    $0x10,%esp
f0104267:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010426c:	75 17                	jne    f0104285 <trap+0x1e0>
		panic("unhandled trap in kernel");
f010426e:	83 ec 04             	sub    $0x4,%esp
f0104271:	68 b5 77 10 f0       	push   $0xf01077b5
f0104276:	68 2b 01 00 00       	push   $0x12b
f010427b:	68 85 77 10 f0       	push   $0xf0107785
f0104280:	e8 bb bd ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104285:	e8 60 19 00 00       	call   f0105bea <cpunum>
f010428a:	83 ec 0c             	sub    $0xc,%esp
f010428d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104290:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0104296:	e8 19 f1 ff ff       	call   f01033b4 <env_destroy>
f010429b:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010429e:	e8 47 19 00 00       	call   f0105bea <cpunum>
f01042a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01042a6:	83 b8 28 80 20 f0 00 	cmpl   $0x0,-0xfdf7fd8(%eax)
f01042ad:	74 2a                	je     f01042d9 <trap+0x234>
f01042af:	e8 36 19 00 00       	call   f0105bea <cpunum>
f01042b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b7:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f01042bd:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042c1:	75 16                	jne    f01042d9 <trap+0x234>
		env_run(curenv);
f01042c3:	e8 22 19 00 00       	call   f0105bea <cpunum>
f01042c8:	83 ec 0c             	sub    $0xc,%esp
f01042cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ce:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f01042d4:	e8 7a f1 ff ff       	call   f0103453 <env_run>
	else
		sched_yield();
f01042d9:	e8 de 01 00 00       	call   f01044bc <sched_yield>

f01042de <t_divide>:
	idt_entries:
.text
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE);
f01042de:	6a 00                	push   $0x0
f01042e0:	6a 00                	push   $0x0
f01042e2:	e9 ef 00 00 00       	jmp    f01043d6 <_alltraps>
f01042e7:	90                   	nop

f01042e8 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);
f01042e8:	6a 00                	push   $0x0
f01042ea:	6a 01                	push   $0x1
f01042ec:	e9 e5 00 00 00       	jmp    f01043d6 <_alltraps>
f01042f1:	90                   	nop

f01042f2 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);
f01042f2:	6a 00                	push   $0x0
f01042f4:	6a 02                	push   $0x2
f01042f6:	e9 db 00 00 00       	jmp    f01043d6 <_alltraps>
f01042fb:	90                   	nop

f01042fc <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT);
f01042fc:	6a 00                	push   $0x0
f01042fe:	6a 03                	push   $0x3
f0104300:	e9 d1 00 00 00       	jmp    f01043d6 <_alltraps>
f0104305:	90                   	nop

f0104306 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW);
f0104306:	6a 00                	push   $0x0
f0104308:	6a 04                	push   $0x4
f010430a:	e9 c7 00 00 00       	jmp    f01043d6 <_alltraps>
f010430f:	90                   	nop

f0104310 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND);
f0104310:	6a 00                	push   $0x0
f0104312:	6a 05                	push   $0x5
f0104314:	e9 bd 00 00 00       	jmp    f01043d6 <_alltraps>
f0104319:	90                   	nop

f010431a <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP);
f010431a:	6a 00                	push   $0x0
f010431c:	6a 06                	push   $0x6
f010431e:	e9 b3 00 00 00       	jmp    f01043d6 <_alltraps>
f0104323:	90                   	nop

f0104324 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE);
f0104324:	6a 00                	push   $0x0
f0104326:	6a 07                	push   $0x7
f0104328:	e9 a9 00 00 00       	jmp    f01043d6 <_alltraps>
f010432d:	90                   	nop

f010432e <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT);
f010432e:	6a 08                	push   $0x8
f0104330:	e9 a1 00 00 00       	jmp    f01043d6 <_alltraps>
f0104335:	90                   	nop

f0104336 <t_tss>:
TRAPHANDLER(t_tss, T_TSS);
f0104336:	6a 0a                	push   $0xa
f0104338:	e9 99 00 00 00       	jmp    f01043d6 <_alltraps>
f010433d:	90                   	nop

f010433e <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP);
f010433e:	6a 0b                	push   $0xb
f0104340:	e9 91 00 00 00       	jmp    f01043d6 <_alltraps>
f0104345:	90                   	nop

f0104346 <t_stack>:
TRAPHANDLER(t_stack, T_STACK);
f0104346:	6a 0c                	push   $0xc
f0104348:	e9 89 00 00 00       	jmp    f01043d6 <_alltraps>
f010434d:	90                   	nop

f010434e <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT);
f010434e:	6a 0d                	push   $0xd
f0104350:	e9 81 00 00 00       	jmp    f01043d6 <_alltraps>
f0104355:	90                   	nop

f0104356 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT);
f0104356:	6a 0e                	push   $0xe
f0104358:	eb 7c                	jmp    f01043d6 <_alltraps>

f010435a <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR);
f010435a:	6a 00                	push   $0x0
f010435c:	6a 10                	push   $0x10
f010435e:	eb 76                	jmp    f01043d6 <_alltraps>

f0104360 <t_align>:
TRAPHANDLER(t_align, T_ALIGN);
f0104360:	6a 11                	push   $0x11
f0104362:	eb 72                	jmp    f01043d6 <_alltraps>

f0104364 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK);
f0104364:	6a 00                	push   $0x0
f0104366:	6a 12                	push   $0x12
f0104368:	eb 6c                	jmp    f01043d6 <_alltraps>

f010436a <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR);
f010436a:	6a 00                	push   $0x0
f010436c:	6a 13                	push   $0x13
f010436e:	eb 66                	jmp    f01043d6 <_alltraps>

f0104370 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);
f0104370:	6a 00                	push   $0x0
f0104372:	6a 30                	push   $0x30
f0104374:	eb 60                	jmp    f01043d6 <_alltraps>

f0104376 <t_irq0>:

TRAPHANDLER_NOEC(t_irq0, IRQ_OFFSET + 0);
f0104376:	6a 00                	push   $0x0
f0104378:	6a 20                	push   $0x20
f010437a:	eb 5a                	jmp    f01043d6 <_alltraps>

f010437c <t_irq1>:
TRAPHANDLER_NOEC(t_irq1, IRQ_OFFSET + 1);
f010437c:	6a 00                	push   $0x0
f010437e:	6a 21                	push   $0x21
f0104380:	eb 54                	jmp    f01043d6 <_alltraps>

f0104382 <t_irq2>:
TRAPHANDLER_NOEC(t_irq2, IRQ_OFFSET + 2);
f0104382:	6a 00                	push   $0x0
f0104384:	6a 22                	push   $0x22
f0104386:	eb 4e                	jmp    f01043d6 <_alltraps>

f0104388 <t_irq3>:
TRAPHANDLER_NOEC(t_irq3, IRQ_OFFSET + 3);
f0104388:	6a 00                	push   $0x0
f010438a:	6a 23                	push   $0x23
f010438c:	eb 48                	jmp    f01043d6 <_alltraps>

f010438e <t_irq4>:
TRAPHANDLER_NOEC(t_irq4, IRQ_OFFSET + 4);
f010438e:	6a 00                	push   $0x0
f0104390:	6a 24                	push   $0x24
f0104392:	eb 42                	jmp    f01043d6 <_alltraps>

f0104394 <t_irq5>:
TRAPHANDLER_NOEC(t_irq5, IRQ_OFFSET + 5);
f0104394:	6a 00                	push   $0x0
f0104396:	6a 25                	push   $0x25
f0104398:	eb 3c                	jmp    f01043d6 <_alltraps>

f010439a <t_irq6>:
TRAPHANDLER_NOEC(t_irq6, IRQ_OFFSET + 6);
f010439a:	6a 00                	push   $0x0
f010439c:	6a 26                	push   $0x26
f010439e:	eb 36                	jmp    f01043d6 <_alltraps>

f01043a0 <t_irq7>:
TRAPHANDLER_NOEC(t_irq7, IRQ_OFFSET + 7);
f01043a0:	6a 00                	push   $0x0
f01043a2:	6a 27                	push   $0x27
f01043a4:	eb 30                	jmp    f01043d6 <_alltraps>

f01043a6 <t_irq8>:
TRAPHANDLER_NOEC(t_irq8, IRQ_OFFSET + 8);
f01043a6:	6a 00                	push   $0x0
f01043a8:	6a 28                	push   $0x28
f01043aa:	eb 2a                	jmp    f01043d6 <_alltraps>

f01043ac <t_irq9>:
TRAPHANDLER_NOEC(t_irq9, IRQ_OFFSET + 9);
f01043ac:	6a 00                	push   $0x0
f01043ae:	6a 29                	push   $0x29
f01043b0:	eb 24                	jmp    f01043d6 <_alltraps>

f01043b2 <t_irq10>:
TRAPHANDLER_NOEC(t_irq10, IRQ_OFFSET + 10);
f01043b2:	6a 00                	push   $0x0
f01043b4:	6a 2a                	push   $0x2a
f01043b6:	eb 1e                	jmp    f01043d6 <_alltraps>

f01043b8 <t_irq11>:
TRAPHANDLER_NOEC(t_irq11, IRQ_OFFSET + 11);
f01043b8:	6a 00                	push   $0x0
f01043ba:	6a 2b                	push   $0x2b
f01043bc:	eb 18                	jmp    f01043d6 <_alltraps>

f01043be <t_irq12>:
TRAPHANDLER_NOEC(t_irq12, IRQ_OFFSET + 12);
f01043be:	6a 00                	push   $0x0
f01043c0:	6a 2c                	push   $0x2c
f01043c2:	eb 12                	jmp    f01043d6 <_alltraps>

f01043c4 <t_irq13>:
TRAPHANDLER_NOEC(t_irq13, IRQ_OFFSET + 13);
f01043c4:	6a 00                	push   $0x0
f01043c6:	6a 2d                	push   $0x2d
f01043c8:	eb 0c                	jmp    f01043d6 <_alltraps>

f01043ca <t_irq14>:
TRAPHANDLER_NOEC(t_irq14, IRQ_OFFSET + 14);
f01043ca:	6a 00                	push   $0x0
f01043cc:	6a 2e                	push   $0x2e
f01043ce:	eb 06                	jmp    f01043d6 <_alltraps>

f01043d0 <t_irq15>:
TRAPHANDLER_NOEC(t_irq15, IRQ_OFFSET + 15);
f01043d0:	6a 00                	push   $0x0
f01043d2:	6a 2f                	push   $0x2f
f01043d4:	eb 00                	jmp    f01043d6 <_alltraps>

f01043d6 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
.text
_alltraps:
						// **LIRONGJIA**
	pushl %ds			// Push ds and es. Use pushal instruction
f01043d6:	1e                   	push   %ds
	pushl %es			// to fit into 'Trapframe' layout.
f01043d7:	06                   	push   %es
	pushal				// 
f01043d8:	60                   	pusha  
						//
	movl $GD_KD, %eax	// Load GD_KD into ds and es with the help
f01043d9:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds		// of eax.
f01043de:	8e d8                	mov    %eax,%ds
	movl %eax, %es		//
f01043e0:	8e c0                	mov    %eax,%es
						//
	push %esp			// Push esp.
f01043e2:	54                   	push   %esp
	call trap			// Call trap.
f01043e3:	e8 bd fc ff ff       	call   f01040a5 <trap>

f01043e8 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01043e8:	55                   	push   %ebp
f01043e9:	89 e5                	mov    %esp,%ebp
f01043eb:	83 ec 08             	sub    $0x8,%esp
f01043ee:	a1 48 72 20 f0       	mov    0xf0207248,%eax
f01043f3:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043f6:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01043fb:	8b 02                	mov    (%edx),%eax
f01043fd:	83 e8 01             	sub    $0x1,%eax
f0104400:	83 f8 02             	cmp    $0x2,%eax
f0104403:	76 10                	jbe    f0104415 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104405:	83 c1 01             	add    $0x1,%ecx
f0104408:	83 c2 7c             	add    $0x7c,%edx
f010440b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104411:	75 e8                	jne    f01043fb <sched_halt+0x13>
f0104413:	eb 08                	jmp    f010441d <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104415:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010441b:	75 1f                	jne    f010443c <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f010441d:	83 ec 0c             	sub    $0xc,%esp
f0104420:	68 90 79 10 f0       	push   $0xf0107990
f0104425:	e8 7a f2 ff ff       	call   f01036a4 <cprintf>
f010442a:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010442d:	83 ec 0c             	sub    $0xc,%esp
f0104430:	6a 00                	push   $0x0
f0104432:	e8 f8 c4 ff ff       	call   f010092f <monitor>
f0104437:	83 c4 10             	add    $0x10,%esp
f010443a:	eb f1                	jmp    f010442d <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010443c:	e8 a9 17 00 00       	call   f0105bea <cpunum>
f0104441:	6b c0 74             	imul   $0x74,%eax,%eax
f0104444:	c7 80 28 80 20 f0 00 	movl   $0x0,-0xfdf7fd8(%eax)
f010444b:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010444e:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104453:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104458:	77 12                	ja     f010446c <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010445a:	50                   	push   %eax
f010445b:	68 c8 62 10 f0       	push   $0xf01062c8
f0104460:	6a 4f                	push   $0x4f
f0104462:	68 b9 79 10 f0       	push   $0xf01079b9
f0104467:	e8 d4 bb ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010446c:	05 00 00 00 10       	add    $0x10000000,%eax
f0104471:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104474:	e8 71 17 00 00       	call   f0105bea <cpunum>
f0104479:	6b d0 74             	imul   $0x74,%eax,%edx
f010447c:	81 c2 20 80 20 f0    	add    $0xf0208020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104482:	b8 02 00 00 00       	mov    $0x2,%eax
f0104487:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010448b:	83 ec 0c             	sub    $0xc,%esp
f010448e:	68 c0 03 12 f0       	push   $0xf01203c0
f0104493:	e8 5d 1a 00 00       	call   f0105ef5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104498:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010449a:	e8 4b 17 00 00       	call   f0105bea <cpunum>
f010449f:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01044a2:	8b 80 30 80 20 f0    	mov    -0xfdf7fd0(%eax),%eax
f01044a8:	bd 00 00 00 00       	mov    $0x0,%ebp
f01044ad:	89 c4                	mov    %eax,%esp
f01044af:	6a 00                	push   $0x0
f01044b1:	6a 00                	push   $0x0
f01044b3:	fb                   	sti    
f01044b4:	f4                   	hlt    
f01044b5:	eb fd                	jmp    f01044b4 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01044b7:	83 c4 10             	add    $0x10,%esp
f01044ba:	c9                   	leave  
f01044bb:	c3                   	ret    

f01044bc <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01044bc:	55                   	push   %ebp
f01044bd:	89 e5                	mov    %esp,%ebp
f01044bf:	57                   	push   %edi
f01044c0:	56                   	push   %esi
f01044c1:	53                   	push   %ebx
f01044c2:	83 ec 0c             	sub    $0xc,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	idle = thiscpu->cpu_env;
f01044c5:	e8 20 17 00 00       	call   f0105bea <cpunum>
f01044ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01044cd:	8b b8 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%edi
	uint32_t start = ((idle != NULL) ? ENVX(idle->env_id) : 0);
f01044d3:	85 ff                	test   %edi,%edi
f01044d5:	74 0b                	je     f01044e2 <sched_yield+0x26>
f01044d7:	8b 4f 48             	mov    0x48(%edi),%ecx
f01044da:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f01044e0:	eb 05                	jmp    f01044e7 <sched_yield+0x2b>
f01044e2:	b9 00 00 00 00       	mov    $0x0,%ecx
	uint32_t i = start;
	
	while (true) {
		if (envs[i].env_status == ENV_RUNNABLE){
f01044e7:	8b 1d 48 72 20 f0    	mov    0xf0207248,%ebx
	// below to halt the cpu.

	// LAB 4: Your code here.
	idle = thiscpu->cpu_env;
	uint32_t start = ((idle != NULL) ? ENVX(idle->env_id) : 0);
	uint32_t i = start;
f01044ed:	89 c8                	mov    %ecx,%eax
	while (true) {
		if (envs[i].env_status == ENV_RUNNABLE){
			env_run(&envs[i]);
			return;
		}
		i = (i == NENV ? 0 : i + 1);
f01044ef:	be 00 00 00 00       	mov    $0x0,%esi
	idle = thiscpu->cpu_env;
	uint32_t start = ((idle != NULL) ? ENVX(idle->env_id) : 0);
	uint32_t i = start;
	
	while (true) {
		if (envs[i].env_status == ENV_RUNNABLE){
f01044f4:	6b d0 7c             	imul   $0x7c,%eax,%edx
f01044f7:	01 da                	add    %ebx,%edx
f01044f9:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f01044fd:	75 09                	jne    f0104508 <sched_yield+0x4c>
			env_run(&envs[i]);
f01044ff:	83 ec 0c             	sub    $0xc,%esp
f0104502:	52                   	push   %edx
f0104503:	e8 4b ef ff ff       	call   f0103453 <env_run>
			return;
		}
		i = (i == NENV ? 0 : i + 1);
f0104508:	8d 50 01             	lea    0x1(%eax),%edx
f010450b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104510:	89 d0                	mov    %edx,%eax
f0104512:	0f 44 c6             	cmove  %esi,%eax
		if (i == start)
f0104515:	39 c1                	cmp    %eax,%ecx
f0104517:	75 db                	jne    f01044f4 <sched_yield+0x38>
			break;
	}

	if (idle != NULL && idle->env_status == ENV_RUNNING) {
f0104519:	85 ff                	test   %edi,%edi
f010451b:	74 0f                	je     f010452c <sched_yield+0x70>
f010451d:	83 7f 54 03          	cmpl   $0x3,0x54(%edi)
f0104521:	75 09                	jne    f010452c <sched_yield+0x70>
		env_run(idle);
f0104523:	83 ec 0c             	sub    $0xc,%esp
f0104526:	57                   	push   %edi
f0104527:	e8 27 ef ff ff       	call   f0103453 <env_run>
		return;
	}

	// sched_halt never returns
	sched_halt();
f010452c:	e8 b7 fe ff ff       	call   f01043e8 <sched_halt>
}
f0104531:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104534:	5b                   	pop    %ebx
f0104535:	5e                   	pop    %esi
f0104536:	5f                   	pop    %edi
f0104537:	5d                   	pop    %ebp
f0104538:	c3                   	ret    

f0104539 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104539:	55                   	push   %ebp
f010453a:	89 e5                	mov    %esp,%ebp
f010453c:	57                   	push   %edi
f010453d:	56                   	push   %esi
f010453e:	53                   	push   %ebx
f010453f:	83 ec 1c             	sub    $0x1c,%esp
f0104542:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0104545:	83 f8 0d             	cmp    $0xd,%eax
f0104548:	0f 87 7b 05 00 00    	ja     f0104ac9 <syscall+0x590>
f010454e:	ff 24 85 cc 79 10 f0 	jmp    *-0xfef8634(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0104555:	e8 90 16 00 00       	call   f0105bea <cpunum>
f010455a:	6a 00                	push   $0x0
f010455c:	ff 75 10             	pushl  0x10(%ebp)
f010455f:	ff 75 0c             	pushl  0xc(%ebp)
f0104562:	6b c0 74             	imul   $0x74,%eax,%eax
f0104565:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f010456b:	e8 20 e8 ff ff       	call   f0102d90 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104570:	83 c4 0c             	add    $0xc,%esp
f0104573:	ff 75 0c             	pushl  0xc(%ebp)
f0104576:	ff 75 10             	pushl  0x10(%ebp)
f0104579:	68 c6 79 10 f0       	push   $0xf01079c6
f010457e:	e8 21 f1 ff ff       	call   f01036a4 <cprintf>
f0104583:	83 c4 10             	add    $0x10,%esp

	switch (syscallno) {

		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
f0104586:	b8 00 00 00 00       	mov    $0x0,%eax
f010458b:	e9 45 05 00 00       	jmp    f0104ad5 <syscall+0x59c>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104590:	e8 66 c0 ff ff       	call   f01005fb <cons_getc>
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
		
		case SYS_cgetc:
			return sys_cgetc();
f0104595:	e9 3b 05 00 00       	jmp    f0104ad5 <syscall+0x59c>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010459a:	e8 4b 16 00 00       	call   f0105bea <cpunum>
f010459f:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a2:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f01045a8:	8b 40 48             	mov    0x48(%eax),%eax
		
		case SYS_cgetc:
			return sys_cgetc();
		
		case SYS_getenvid:
			return sys_getenvid();
f01045ab:	e9 25 05 00 00       	jmp    f0104ad5 <syscall+0x59c>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01045b0:	83 ec 04             	sub    $0x4,%esp
f01045b3:	6a 01                	push   $0x1
f01045b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045b8:	50                   	push   %eax
f01045b9:	ff 75 0c             	pushl  0xc(%ebp)
f01045bc:	e8 9f e8 ff ff       	call   f0102e60 <envid2env>
f01045c1:	83 c4 10             	add    $0x10,%esp
f01045c4:	85 c0                	test   %eax,%eax
f01045c6:	0f 88 09 05 00 00    	js     f0104ad5 <syscall+0x59c>
		return r;
	env_destroy(e);
f01045cc:	83 ec 0c             	sub    $0xc,%esp
f01045cf:	ff 75 e4             	pushl  -0x1c(%ebp)
f01045d2:	e8 dd ed ff ff       	call   f01033b4 <env_destroy>
f01045d7:	83 c4 10             	add    $0x10,%esp
	return 0;
f01045da:	b8 00 00 00 00       	mov    $0x0,%eax
f01045df:	e9 f1 04 00 00       	jmp    f0104ad5 <syscall+0x59c>
	// LAB 4: Your code here.
	int ret;
	struct Env *env_store;
	struct PageInfo *pp;	
															// **LIRONGJIA**
	envid2env(envid, &env_store, 1);						//
f01045e4:	83 ec 04             	sub    $0x4,%esp
f01045e7:	6a 01                	push   $0x1
f01045e9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045ec:	50                   	push   %eax
f01045ed:	ff 75 0c             	pushl  0xc(%ebp)
f01045f0:	e8 6b e8 ff ff       	call   f0102e60 <envid2env>
	if (env_store == NULL)									// Fail on envid2env,
f01045f5:	83 c4 10             	add    $0x10,%esp
f01045f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01045fc:	74 5a                	je     f0104658 <syscall+0x11f>
		return -E_BAD_ENV;									// return -E_BAD_ENV.
															//
	if (va >= (void *)UTOP ||								// If va >= UTOP or
f01045fe:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104605:	77 5b                	ja     f0104662 <syscall+0x129>
f0104607:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010460e:	75 5c                	jne    f010466c <syscall+0x133>
		PGOFF(va) != 0)										// va is not page-aligned (???), 
		return -E_INVAL;									// return -E_INVAL.
															//
	if ((perm & PTE_U) == 0 ||								// PTE_U must be set.
f0104610:	8b 45 14             	mov    0x14(%ebp),%eax
f0104613:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104618:	83 f8 05             	cmp    $0x5,%eax
f010461b:	75 59                	jne    f0104676 <syscall+0x13d>
		(perm & PTE_P) == 0 ||								// PTE_P must be set.
		(perm & ~(PTE_P | PTE_U | PTE_AVAIL | PTE_W)) != 0)	// no other bits may be set ???,
		return -E_INVAL;									// otherwise, return -E_INVAL.
															//
	pp = page_alloc(1);										//
f010461d:	83 ec 0c             	sub    $0xc,%esp
f0104620:	6a 01                	push   $0x1
f0104622:	e8 ca c8 ff ff       	call   f0100ef1 <page_alloc>
f0104627:	89 c3                	mov    %eax,%ebx
	ret = page_insert(env_store->env_pgdir,					//
f0104629:	ff 75 14             	pushl  0x14(%ebp)
f010462c:	ff 75 10             	pushl  0x10(%ebp)
f010462f:	50                   	push   %eax
f0104630:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104633:	ff 70 60             	pushl  0x60(%eax)
f0104636:	e8 b5 cb ff ff       	call   f01011f0 <page_insert>
						pp,	va, perm);						//
	if (ret != 0) {											// Fail on page_insert,
f010463b:	83 c4 20             	add    $0x20,%esp
f010463e:	85 c0                	test   %eax,%eax
f0104640:	74 3e                	je     f0104680 <syscall+0x147>
		page_free(pp);										// free the page and
f0104642:	83 ec 0c             	sub    $0xc,%esp
f0104645:	53                   	push   %ebx
f0104646:	e8 16 c9 ff ff       	call   f0100f61 <page_free>
f010464b:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;									// return -E_NO_MEM.
f010464e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104653:	e9 7d 04 00 00       	jmp    f0104ad5 <syscall+0x59c>
	struct Env *env_store;
	struct PageInfo *pp;	
															// **LIRONGJIA**
	envid2env(envid, &env_store, 1);						//
	if (env_store == NULL)									// Fail on envid2env,
		return -E_BAD_ENV;									// return -E_BAD_ENV.
f0104658:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010465d:	e9 73 04 00 00       	jmp    f0104ad5 <syscall+0x59c>
															//
	if (va >= (void *)UTOP ||								// If va >= UTOP or
		PGOFF(va) != 0)										// va is not page-aligned (???), 
		return -E_INVAL;									// return -E_INVAL.
f0104662:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104667:	e9 69 04 00 00       	jmp    f0104ad5 <syscall+0x59c>
f010466c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104671:	e9 5f 04 00 00       	jmp    f0104ad5 <syscall+0x59c>
															//
	if ((perm & PTE_U) == 0 ||								// PTE_U must be set.
		(perm & PTE_P) == 0 ||								// PTE_P must be set.
		(perm & ~(PTE_P | PTE_U | PTE_AVAIL | PTE_W)) != 0)	// no other bits may be set ???,
		return -E_INVAL;									// otherwise, return -E_INVAL.
f0104676:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010467b:	e9 55 04 00 00       	jmp    f0104ad5 <syscall+0x59c>
	if (ret != 0) {											// Fail on page_insert,
		page_free(pp);										// free the page and
		return -E_NO_MEM;									// return -E_NO_MEM.
	}														// **************

	return 0;
f0104680:	b8 00 00 00 00       	mov    $0x0,%eax
		
		case SYS_env_destroy:
			return sys_env_destroy(a1);

		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104685:	e9 4b 04 00 00       	jmp    f0104ad5 <syscall+0x59c>
		
		case SYS_page_map:
			return sys_page_map((envid_t) a1, (void *)a2, (envid_t)a3, (void *)a4, (int) a5);
f010468a:	8b 5d 18             	mov    0x18(%ebp),%ebx
	struct Env *srcenv_store, *dstenv_store;
	struct PageInfo *pp;
	pte_t *pte_store;
	int ret;

	envid2env(srcenvid, &srcenv_store, 1);
f010468d:	83 ec 04             	sub    $0x4,%esp
f0104690:	6a 01                	push   $0x1
f0104692:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104695:	50                   	push   %eax
f0104696:	ff 75 0c             	pushl  0xc(%ebp)
f0104699:	e8 c2 e7 ff ff       	call   f0102e60 <envid2env>
	envid2env(dstenvid, &dstenv_store, 1);
f010469e:	83 c4 0c             	add    $0xc,%esp
f01046a1:	6a 01                	push   $0x1
f01046a3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01046a6:	50                   	push   %eax
f01046a7:	ff 75 14             	pushl  0x14(%ebp)
f01046aa:	e8 b1 e7 ff ff       	call   f0102e60 <envid2env>
	if (srcenv_store == NULL || dstenv_store == NULL)
f01046af:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046b2:	83 c4 10             	add    $0x10,%esp
f01046b5:	85 c0                	test   %eax,%eax
f01046b7:	0f 84 8c 00 00 00    	je     f0104749 <syscall+0x210>
f01046bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01046c1:	0f 84 8c 00 00 00    	je     f0104753 <syscall+0x21a>
		return -E_BAD_ENV;

	if (srcva >= (void *)UTOP || PGOFF(srcva) != 0||
f01046c7:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01046ce:	0f 87 89 00 00 00    	ja     f010475d <syscall+0x224>
f01046d4:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01046db:	0f 85 86 00 00 00    	jne    f0104767 <syscall+0x22e>
f01046e1:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01046e7:	77 7e                	ja     f0104767 <syscall+0x22e>
		dstva >= (void *)UTOP || PGOFF(dstva) != 0)
f01046e9:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01046f0:	75 7f                	jne    f0104771 <syscall+0x238>
		return -E_INVAL;

	pp = page_lookup(srcenv_store->env_pgdir, srcva, &pte_store);
f01046f2:	83 ec 04             	sub    $0x4,%esp
f01046f5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01046f8:	52                   	push   %edx
f01046f9:	ff 75 10             	pushl  0x10(%ebp)
f01046fc:	ff 70 60             	pushl  0x60(%eax)
f01046ff:	e8 03 ca ff ff       	call   f0101107 <page_lookup>
	if (pp == NULL)
f0104704:	83 c4 10             	add    $0x10,%esp
f0104707:	85 c0                	test   %eax,%eax
f0104709:	74 70                	je     f010477b <syscall+0x242>
		return -E_INVAL;

	if ((perm & PTE_U) == 0 ||							
f010470b:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010470e:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104714:	83 fa 05             	cmp    $0x5,%edx
f0104717:	75 6c                	jne    f0104785 <syscall+0x24c>
		(perm & PTE_P) == 0 ||							
		(perm & ~(PTE_P | PTE_U | PTE_AVAIL | PTE_W)) != 0)
		return -E_INVAL;

	if ((perm & PTE_W) && !(*pte_store & PTE_W))
f0104719:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010471d:	74 08                	je     f0104727 <syscall+0x1ee>
f010471f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104722:	f6 02 02             	testb  $0x2,(%edx)
f0104725:	74 68                	je     f010478f <syscall+0x256>
		return -E_INVAL;

	ret = page_insert(dstenv_store->env_pgdir, pp, dstva, perm);
f0104727:	ff 75 1c             	pushl  0x1c(%ebp)
f010472a:	53                   	push   %ebx
f010472b:	50                   	push   %eax
f010472c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010472f:	ff 70 60             	pushl  0x60(%eax)
f0104732:	e8 b9 ca ff ff       	call   f01011f0 <page_insert>
	if (ret != 0)
f0104737:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;

	return 0;
f010473a:	83 f8 01             	cmp    $0x1,%eax
f010473d:	19 c0                	sbb    %eax,%eax
f010473f:	f7 d0                	not    %eax
f0104741:	83 e0 fc             	and    $0xfffffffc,%eax
f0104744:	e9 8c 03 00 00       	jmp    f0104ad5 <syscall+0x59c>
	int ret;

	envid2env(srcenvid, &srcenv_store, 1);
	envid2env(dstenvid, &dstenv_store, 1);
	if (srcenv_store == NULL || dstenv_store == NULL)
		return -E_BAD_ENV;
f0104749:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010474e:	e9 82 03 00 00       	jmp    f0104ad5 <syscall+0x59c>
f0104753:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104758:	e9 78 03 00 00       	jmp    f0104ad5 <syscall+0x59c>

	if (srcva >= (void *)UTOP || PGOFF(srcva) != 0||
		dstva >= (void *)UTOP || PGOFF(dstva) != 0)
		return -E_INVAL;
f010475d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104762:	e9 6e 03 00 00       	jmp    f0104ad5 <syscall+0x59c>
f0104767:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010476c:	e9 64 03 00 00       	jmp    f0104ad5 <syscall+0x59c>
f0104771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104776:	e9 5a 03 00 00       	jmp    f0104ad5 <syscall+0x59c>

	pp = page_lookup(srcenv_store->env_pgdir, srcva, &pte_store);
	if (pp == NULL)
		return -E_INVAL;
f010477b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104780:	e9 50 03 00 00       	jmp    f0104ad5 <syscall+0x59c>

	if ((perm & PTE_U) == 0 ||							
		(perm & PTE_P) == 0 ||							
		(perm & ~(PTE_P | PTE_U | PTE_AVAIL | PTE_W)) != 0)
		return -E_INVAL;
f0104785:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010478a:	e9 46 03 00 00       	jmp    f0104ad5 <syscall+0x59c>

	if ((perm & PTE_W) && !(*pte_store & PTE_W))
		return -E_INVAL;
f010478f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104794:	e9 3c 03 00 00       	jmp    f0104ad5 <syscall+0x59c>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *env_store;

	envid2env(envid, &env_store, 1);
f0104799:	83 ec 04             	sub    $0x4,%esp
f010479c:	6a 01                	push   $0x1
f010479e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047a1:	50                   	push   %eax
f01047a2:	ff 75 0c             	pushl  0xc(%ebp)
f01047a5:	e8 b6 e6 ff ff       	call   f0102e60 <envid2env>
	if (env_store == NULL)
f01047aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047ad:	83 c4 10             	add    $0x10,%esp
f01047b0:	85 c0                	test   %eax,%eax
f01047b2:	74 2d                	je     f01047e1 <syscall+0x2a8>
		return -E_BAD_ENV;
	
    if (va >= (void*)UTOP || PGOFF(va) != 0)
f01047b4:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047bb:	77 2e                	ja     f01047eb <syscall+0x2b2>
f01047bd:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047c4:	75 2f                	jne    f01047f5 <syscall+0x2bc>
        return -E_INVAL;

    page_remove(env_store->env_pgdir, va);
f01047c6:	83 ec 08             	sub    $0x8,%esp
f01047c9:	ff 75 10             	pushl  0x10(%ebp)
f01047cc:	ff 70 60             	pushl  0x60(%eax)
f01047cf:	e8 cf c9 ff ff       	call   f01011a3 <page_remove>
f01047d4:	83 c4 10             	add    $0x10,%esp
    return 0;
f01047d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01047dc:	e9 f4 02 00 00       	jmp    f0104ad5 <syscall+0x59c>
	// LAB 4: Your code here.
	struct Env *env_store;

	envid2env(envid, &env_store, 1);
	if (env_store == NULL)
		return -E_BAD_ENV;
f01047e1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01047e6:	e9 ea 02 00 00       	jmp    f0104ad5 <syscall+0x59c>
	
    if (va >= (void*)UTOP || PGOFF(va) != 0)
        return -E_INVAL;
f01047eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047f0:	e9 e0 02 00 00       	jmp    f0104ad5 <syscall+0x59c>
f01047f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		
		case SYS_page_map:
			return sys_page_map((envid_t) a1, (void *)a2, (envid_t)a3, (void *)a4, (int) a5);

		case SYS_page_unmap:
			return sys_page_unmap((envid_t) a1, (void *)a2);
f01047fa:	e9 d6 02 00 00       	jmp    f0104ad5 <syscall+0x59c>

	// LAB 4: Your code here.
	int ret;
	struct Env *newenv_store;
	
	ret = env_alloc(&newenv_store, curenv->env_id);
f01047ff:	e8 e6 13 00 00       	call   f0105bea <cpunum>
f0104804:	83 ec 08             	sub    $0x8,%esp
f0104807:	6b c0 74             	imul   $0x74,%eax,%eax
f010480a:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0104810:	ff 70 48             	pushl  0x48(%eax)
f0104813:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104816:	50                   	push   %eax
f0104817:	e8 55 e7 ff ff       	call   f0102f71 <env_alloc>
	if (ret >= 0) {
f010481c:	83 c4 10             	add    $0x10,%esp
f010481f:	85 c0                	test   %eax,%eax
f0104821:	0f 88 ae 02 00 00    	js     f0104ad5 <syscall+0x59c>
		newenv_store->env_status = ENV_NOT_RUNNABLE;
f0104827:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010482a:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
		newenv_store->env_tf = curenv->env_tf;
f0104831:	e8 b4 13 00 00       	call   f0105bea <cpunum>
f0104836:	6b c0 74             	imul   $0x74,%eax,%eax
f0104839:	8b b0 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%esi
f010483f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104844:	89 df                	mov    %ebx,%edi
f0104846:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		newenv_store->env_tf.tf_regs.reg_eax = 0;
f0104848:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010484b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
		ret = newenv_store->env_id;
f0104852:	8b 40 48             	mov    0x48(%eax),%eax

		case SYS_page_unmap:
			return sys_page_unmap((envid_t) a1, (void *)a2);

		case SYS_exofork:
			return sys_exofork();
f0104855:	e9 7b 02 00 00       	jmp    f0104ad5 <syscall+0x59c>

	// LAB 4: Your code here.
	int ret;
	struct Env *env_store;
	
	envid2env(envid, &env_store, 1);
f010485a:	83 ec 04             	sub    $0x4,%esp
f010485d:	6a 01                	push   $0x1
f010485f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104862:	50                   	push   %eax
f0104863:	ff 75 0c             	pushl  0xc(%ebp)
f0104866:	e8 f5 e5 ff ff       	call   f0102e60 <envid2env>
												// **LIRONGJIA**
	if (env_store != NULL) {					// Succeed on envid2env.
f010486b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010486e:	83 c4 10             	add    $0x10,%esp
f0104871:	85 c0                	test   %eax,%eax
f0104873:	74 1b                	je     f0104890 <syscall+0x357>
		if (status == ENV_RUNNABLE ||			// 
f0104875:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104878:	8d 51 fe             	lea    -0x2(%ecx),%edx
f010487b:	f7 c2 fd ff ff ff    	test   $0xfffffffd,%edx
f0104881:	75 17                	jne    f010489a <syscall+0x361>
			status == ENV_NOT_RUNNABLE) {		// Valid status, return 0 and
			ret = 0;							// set status.
			env_store->env_status = status;	//
f0104883:	89 48 54             	mov    %ecx,0x54(%eax)
	envid2env(envid, &env_store, 1);
												// **LIRONGJIA**
	if (env_store != NULL) {					// Succeed on envid2env.
		if (status == ENV_RUNNABLE ||			// 
			status == ENV_NOT_RUNNABLE) {		// Valid status, return 0 and
			ret = 0;							// set status.
f0104886:	b8 00 00 00 00       	mov    $0x0,%eax
f010488b:	e9 45 02 00 00       	jmp    f0104ad5 <syscall+0x59c>
			env_store->env_status = status;	//
		}										//	
		else									// Invalid status, return -E_INVAL.
			ret = -E_INVAL;						// 
	} else										// Not Succeed on envid2env,
		ret = -E_BAD_ENV;						// return -E_BAD_ENV.
f0104890:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104895:	e9 3b 02 00 00       	jmp    f0104ad5 <syscall+0x59c>
			status == ENV_NOT_RUNNABLE) {		// Valid status, return 0 and
			ret = 0;							// set status.
			env_store->env_status = status;	//
		}										//	
		else									// Invalid status, return -E_INVAL.
			ret = -E_INVAL;						// 
f010489a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

		case SYS_exofork:
			return sys_exofork();

		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
f010489f:	e9 31 02 00 00       	jmp    f0104ad5 <syscall+0x59c>

		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f01048a4:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *env_store;

	envid2env(envid, &env_store, 1);
f01048a7:	83 ec 04             	sub    $0x4,%esp
f01048aa:	6a 01                	push   $0x1
f01048ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048af:	50                   	push   %eax
f01048b0:	ff 75 0c             	pushl  0xc(%ebp)
f01048b3:	e8 a8 e5 ff ff       	call   f0102e60 <envid2env>
	if (env_store == NULL)
f01048b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048bb:	83 c4 10             	add    $0x10,%esp
f01048be:	85 c0                	test   %eax,%eax
f01048c0:	74 13                	je     f01048d5 <syscall+0x39c>
		return -E_BAD_ENV;
	
	env_store->env_tf = *tf;
f01048c2:	b9 11 00 00 00       	mov    $0x11,%ecx
f01048c7:	89 c7                	mov    %eax,%edi
f01048c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return 0;
f01048cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01048d0:	e9 00 02 00 00       	jmp    f0104ad5 <syscall+0x59c>
	// address!
	struct Env *env_store;

	envid2env(envid, &env_store, 1);
	if (env_store == NULL)
		return -E_BAD_ENV;
f01048d5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax

		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);

		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f01048da:	e9 f6 01 00 00       	jmp    f0104ad5 <syscall+0x59c>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *env_store;
	
	envid2env(envid, &env_store, 1);
f01048df:	83 ec 04             	sub    $0x4,%esp
f01048e2:	6a 01                	push   $0x1
f01048e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048e7:	50                   	push   %eax
f01048e8:	ff 75 0c             	pushl  0xc(%ebp)
f01048eb:	e8 70 e5 ff ff       	call   f0102e60 <envid2env>
	if (env_store == NULL)
f01048f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048f3:	83 c4 10             	add    $0x10,%esp
f01048f6:	85 c0                	test   %eax,%eax
f01048f8:	74 10                	je     f010490a <syscall+0x3d1>
		return -E_BAD_ENV;
	
	env_store->env_pgfault_upcall = func;
f01048fa:	8b 7d 10             	mov    0x10(%ebp),%edi
f01048fd:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f0104900:	b8 00 00 00 00       	mov    $0x0,%eax
f0104905:	e9 cb 01 00 00       	jmp    f0104ad5 <syscall+0x59c>
	// LAB 4: Your code here.
	struct Env *env_store;
	
	envid2env(envid, &env_store, 1);
	if (env_store == NULL)
		return -E_BAD_ENV;
f010490a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax

		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2); 
f010490f:	e9 c1 01 00 00       	jmp    f0104ad5 <syscall+0x59c>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104914:	e8 a3 fb ff ff       	call   f01044bc <sched_yield>
	struct PageInfo *pp;
	pte_t *pte_store;
	int ret;
	unsigned to_perm = 0;

	envid2env(envid, &dstenv, 0);
f0104919:	83 ec 04             	sub    $0x4,%esp
f010491c:	6a 00                	push   $0x0
f010491e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104921:	50                   	push   %eax
f0104922:	ff 75 0c             	pushl  0xc(%ebp)
f0104925:	e8 36 e5 ff ff       	call   f0102e60 <envid2env>
	if (dstenv == NULL)
f010492a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010492d:	83 c4 10             	add    $0x10,%esp
f0104930:	85 c0                	test   %eax,%eax
f0104932:	0f 84 d5 00 00 00    	je     f0104a0d <syscall+0x4d4>
		return -E_BAD_ENV;

	if (!dstenv->env_ipc_recving)
f0104938:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010493c:	0f 84 d5 00 00 00    	je     f0104a17 <syscall+0x4de>
		return -E_IPC_NOT_RECV;

	if (srcva < (void *)UTOP) {
f0104942:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104949:	77 79                	ja     f01049c4 <syscall+0x48b>
		if (PGOFF(srcva))
f010494b:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104952:	0f 85 c9 00 00 00    	jne    f0104a21 <syscall+0x4e8>
			return -E_INVAL;

		if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0 ||							
f0104958:	8b 45 18             	mov    0x18(%ebp),%eax
f010495b:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104960:	83 f8 05             	cmp    $0x5,%eax
f0104963:	0f 85 c2 00 00 00    	jne    f0104a2b <syscall+0x4f2>
			(perm & ~(PTE_P | PTE_U | PTE_AVAIL | PTE_W)) != 0)
			return -E_INVAL;

		pp = page_lookup(curenv->env_pgdir, srcva, &pte_store);
f0104969:	e8 7c 12 00 00       	call   f0105bea <cpunum>
f010496e:	83 ec 04             	sub    $0x4,%esp
f0104971:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104974:	52                   	push   %edx
f0104975:	ff 75 14             	pushl  0x14(%ebp)
f0104978:	6b c0 74             	imul   $0x74,%eax,%eax
f010497b:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0104981:	ff 70 60             	pushl  0x60(%eax)
f0104984:	e8 7e c7 ff ff       	call   f0101107 <page_lookup>
		if (pp == NULL)
f0104989:	83 c4 10             	add    $0x10,%esp
f010498c:	85 c0                	test   %eax,%eax
f010498e:	0f 84 a1 00 00 00    	je     f0104a35 <syscall+0x4fc>
			return -E_INVAL;

		if ((perm & PTE_W) && !(*pte_store & PTE_W))
f0104994:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104998:	74 0c                	je     f01049a6 <syscall+0x46d>
f010499a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010499d:	f6 02 02             	testb  $0x2,(%edx)
f01049a0:	0f 84 99 00 00 00    	je     f0104a3f <syscall+0x506>
			return -E_INVAL;

		ret = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva, perm);
f01049a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01049a9:	ff 75 18             	pushl  0x18(%ebp)
f01049ac:	ff 72 6c             	pushl  0x6c(%edx)
f01049af:	50                   	push   %eax
f01049b0:	ff 72 60             	pushl  0x60(%edx)
f01049b3:	e8 38 c8 ff ff       	call   f01011f0 <page_insert>
		if (ret != 0)
f01049b8:	83 c4 10             	add    $0x10,%esp
f01049bb:	85 c0                	test   %eax,%eax
f01049bd:	74 0c                	je     f01049cb <syscall+0x492>
f01049bf:	e9 85 00 00 00       	jmp    f0104a49 <syscall+0x510>
	// LAB 4: Your code here.
	struct Env *dstenv;
	struct PageInfo *pp;
	pte_t *pte_store;
	int ret;
	unsigned to_perm = 0;
f01049c4:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
		if (ret != 0)
			return -E_NO_MEM;
		to_perm = perm;
	}

    dstenv->env_ipc_recving = false;	
f01049cb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01049ce:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	dstenv->env_ipc_from = curenv->env_id;
f01049d2:	e8 13 12 00 00       	call   f0105bea <cpunum>
f01049d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01049da:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f01049e0:	8b 40 48             	mov    0x48(%eax),%eax
f01049e3:	89 43 74             	mov    %eax,0x74(%ebx)
    dstenv->env_ipc_value = value;
f01049e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01049ec:	89 48 70             	mov    %ecx,0x70(%eax)
	dstenv->env_ipc_perm = to_perm;
f01049ef:	8b 7d 18             	mov    0x18(%ebp),%edi
f01049f2:	89 78 78             	mov    %edi,0x78(%eax)
	dstenv->env_status = ENV_RUNNABLE;
f01049f5:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	dstenv->env_tf.tf_regs.reg_eax = 0;
f01049fc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104a03:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a08:	e9 c8 00 00 00       	jmp    f0104ad5 <syscall+0x59c>
	int ret;
	unsigned to_perm = 0;

	envid2env(envid, &dstenv, 0);
	if (dstenv == NULL)
		return -E_BAD_ENV;
f0104a0d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104a12:	e9 be 00 00 00       	jmp    f0104ad5 <syscall+0x59c>

	if (!dstenv->env_ipc_recving)
		return -E_IPC_NOT_RECV;
f0104a17:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0104a1c:	e9 b4 00 00 00       	jmp    f0104ad5 <syscall+0x59c>

	if (srcva < (void *)UTOP) {
		if (PGOFF(srcva))
			return -E_INVAL;
f0104a21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a26:	e9 aa 00 00 00       	jmp    f0104ad5 <syscall+0x59c>

		if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0 ||							
			(perm & ~(PTE_P | PTE_U | PTE_AVAIL | PTE_W)) != 0)
			return -E_INVAL;
f0104a2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a30:	e9 a0 00 00 00       	jmp    f0104ad5 <syscall+0x59c>

		pp = page_lookup(curenv->env_pgdir, srcva, &pte_store);
		if (pp == NULL)
			return -E_INVAL;
f0104a35:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a3a:	e9 96 00 00 00       	jmp    f0104ad5 <syscall+0x59c>

		if ((perm & PTE_W) && !(*pte_store & PTE_W))
			return -E_INVAL;
f0104a3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a44:	e9 8c 00 00 00       	jmp    f0104ad5 <syscall+0x59c>

		ret = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva, perm);
		if (ret != 0)
			return -E_NO_MEM;
f0104a49:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		case SYS_yield:
			sys_yield();
			return 0;
		
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104a4e:	e9 82 00 00 00       	jmp    f0104ad5 <syscall+0x59c>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if (dstva < (void *)UTOP) {
f0104a53:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104a5a:	77 1d                	ja     f0104a79 <syscall+0x540>
		if (PGOFF(dstva) != 0)
f0104a5c:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104a63:	75 6b                	jne    f0104ad0 <syscall+0x597>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f0104a65:	e8 80 11 00 00       	call   f0105bea <cpunum>
f0104a6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a6d:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0104a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104a76:	89 48 6c             	mov    %ecx,0x6c(%eax)
	}

	curenv->env_ipc_recving = true;
f0104a79:	e8 6c 11 00 00       	call   f0105bea <cpunum>
f0104a7e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a81:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0104a87:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0104a8b:	e8 5a 11 00 00       	call   f0105bea <cpunum>
f0104a90:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a93:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0104a99:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    curenv->env_ipc_from = curenv->env_id;
f0104aa0:	e8 45 11 00 00       	call   f0105bea <cpunum>
f0104aa5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa8:	8b 98 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%ebx
f0104aae:	e8 37 11 00 00       	call   f0105bea <cpunum>
f0104ab3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab6:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0104abc:	8b 40 48             	mov    0x48(%eax),%eax
f0104abf:	89 43 74             	mov    %eax,0x74(%ebx)

	return 0;
f0104ac2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ac7:	eb 0c                	jmp    f0104ad5 <syscall+0x59c>

		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
				
		default:
			return -E_INVAL;
f0104ac9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ace:	eb 05                	jmp    f0104ad5 <syscall+0x59c>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if (dstva < (void *)UTOP) {
		if (PGOFF(dstva) != 0)
			return -E_INVAL;
f0104ad0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
				
		default:
			return -E_INVAL;

	}
}
f0104ad5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ad8:	5b                   	pop    %ebx
f0104ad9:	5e                   	pop    %esi
f0104ada:	5f                   	pop    %edi
f0104adb:	5d                   	pop    %ebp
f0104adc:	c3                   	ret    

f0104add <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104add:	55                   	push   %ebp
f0104ade:	89 e5                	mov    %esp,%ebp
f0104ae0:	57                   	push   %edi
f0104ae1:	56                   	push   %esi
f0104ae2:	53                   	push   %ebx
f0104ae3:	83 ec 14             	sub    $0x14,%esp
f0104ae6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ae9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104aec:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104aef:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104af2:	8b 1a                	mov    (%edx),%ebx
f0104af4:	8b 01                	mov    (%ecx),%eax
f0104af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104af9:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104b00:	eb 7f                	jmp    f0104b81 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b05:	01 d8                	add    %ebx,%eax
f0104b07:	89 c6                	mov    %eax,%esi
f0104b09:	c1 ee 1f             	shr    $0x1f,%esi
f0104b0c:	01 c6                	add    %eax,%esi
f0104b0e:	d1 fe                	sar    %esi
f0104b10:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104b13:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104b16:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104b19:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104b1b:	eb 03                	jmp    f0104b20 <stab_binsearch+0x43>
			m--;
f0104b1d:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104b20:	39 c3                	cmp    %eax,%ebx
f0104b22:	7f 0d                	jg     f0104b31 <stab_binsearch+0x54>
f0104b24:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104b28:	83 ea 0c             	sub    $0xc,%edx
f0104b2b:	39 f9                	cmp    %edi,%ecx
f0104b2d:	75 ee                	jne    f0104b1d <stab_binsearch+0x40>
f0104b2f:	eb 05                	jmp    f0104b36 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104b31:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104b34:	eb 4b                	jmp    f0104b81 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104b36:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b39:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104b3c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104b40:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104b43:	76 11                	jbe    f0104b56 <stab_binsearch+0x79>
			*region_left = m;
f0104b45:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104b48:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104b4a:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b4d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b54:	eb 2b                	jmp    f0104b81 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104b56:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104b59:	73 14                	jae    f0104b6f <stab_binsearch+0x92>
			*region_right = m - 1;
f0104b5b:	83 e8 01             	sub    $0x1,%eax
f0104b5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104b61:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b64:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b66:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b6d:	eb 12                	jmp    f0104b81 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104b6f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b72:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104b74:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104b78:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b7a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104b81:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104b84:	0f 8e 78 ff ff ff    	jle    f0104b02 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104b8a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104b8e:	75 0f                	jne    f0104b9f <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104b90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b93:	8b 00                	mov    (%eax),%eax
f0104b95:	83 e8 01             	sub    $0x1,%eax
f0104b98:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b9b:	89 06                	mov    %eax,(%esi)
f0104b9d:	eb 2c                	jmp    f0104bcb <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ba2:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104ba4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ba7:	8b 0e                	mov    (%esi),%ecx
f0104ba9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104bac:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104baf:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104bb2:	eb 03                	jmp    f0104bb7 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104bb4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104bb7:	39 c8                	cmp    %ecx,%eax
f0104bb9:	7e 0b                	jle    f0104bc6 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104bbb:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104bbf:	83 ea 0c             	sub    $0xc,%edx
f0104bc2:	39 df                	cmp    %ebx,%edi
f0104bc4:	75 ee                	jne    f0104bb4 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104bc6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104bc9:	89 06                	mov    %eax,(%esi)
	}
}
f0104bcb:	83 c4 14             	add    $0x14,%esp
f0104bce:	5b                   	pop    %ebx
f0104bcf:	5e                   	pop    %esi
f0104bd0:	5f                   	pop    %edi
f0104bd1:	5d                   	pop    %ebp
f0104bd2:	c3                   	ret    

f0104bd3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104bd3:	55                   	push   %ebp
f0104bd4:	89 e5                	mov    %esp,%ebp
f0104bd6:	57                   	push   %edi
f0104bd7:	56                   	push   %esi
f0104bd8:	53                   	push   %ebx
f0104bd9:	83 ec 2c             	sub    $0x2c,%esp
f0104bdc:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104bdf:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104be2:	c7 06 04 7a 10 f0    	movl   $0xf0107a04,(%esi)
	info->eip_line = 0;
f0104be8:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104bef:	c7 46 08 04 7a 10 f0 	movl   $0xf0107a04,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104bf6:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104bfd:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104c00:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104c07:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104c0d:	77 21                	ja     f0104c30 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104c0f:	a1 00 00 20 00       	mov    0x200000,%eax
f0104c14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104c17:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104c1c:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104c22:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104c25:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104c2b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104c2e:	eb 1a                	jmp    f0104c4a <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104c30:	c7 45 d0 7d 57 11 f0 	movl   $0xf011577d,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104c37:	c7 45 cc 79 20 11 f0 	movl   $0xf0112079,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104c3e:	b8 78 20 11 f0       	mov    $0xf0112078,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104c43:	c7 45 d4 b0 7f 10 f0 	movl   $0xf0107fb0,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104c4a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104c4d:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104c50:	0f 83 2b 01 00 00    	jae    f0104d81 <debuginfo_eip+0x1ae>
f0104c56:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104c5a:	0f 85 28 01 00 00    	jne    f0104d88 <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104c60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104c67:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104c6a:	29 d8                	sub    %ebx,%eax
f0104c6c:	c1 f8 02             	sar    $0x2,%eax
f0104c6f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104c75:	83 e8 01             	sub    $0x1,%eax
f0104c78:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104c7b:	57                   	push   %edi
f0104c7c:	6a 64                	push   $0x64
f0104c7e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104c81:	89 c1                	mov    %eax,%ecx
f0104c83:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c86:	89 d8                	mov    %ebx,%eax
f0104c88:	e8 50 fe ff ff       	call   f0104add <stab_binsearch>
	if (lfile == 0)
f0104c8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c90:	83 c4 08             	add    $0x8,%esp
f0104c93:	85 c0                	test   %eax,%eax
f0104c95:	0f 84 f4 00 00 00    	je     f0104d8f <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c9b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ca1:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104ca4:	57                   	push   %edi
f0104ca5:	6a 24                	push   $0x24
f0104ca7:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104caa:	89 c1                	mov    %eax,%ecx
f0104cac:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104caf:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104cb2:	89 d8                	mov    %ebx,%eax
f0104cb4:	e8 24 fe ff ff       	call   f0104add <stab_binsearch>

	if (lfun <= rfun) {
f0104cb9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104cbc:	83 c4 08             	add    $0x8,%esp
f0104cbf:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104cc2:	7f 24                	jg     f0104ce8 <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104cc4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104cc7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104cca:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104ccd:	8b 02                	mov    (%edx),%eax
f0104ccf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104cd2:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104cd5:	29 f9                	sub    %edi,%ecx
f0104cd7:	39 c8                	cmp    %ecx,%eax
f0104cd9:	73 05                	jae    f0104ce0 <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104cdb:	01 f8                	add    %edi,%eax
f0104cdd:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104ce0:	8b 42 08             	mov    0x8(%edx),%eax
f0104ce3:	89 46 10             	mov    %eax,0x10(%esi)
f0104ce6:	eb 06                	jmp    f0104cee <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104ce8:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104ceb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104cee:	83 ec 08             	sub    $0x8,%esp
f0104cf1:	6a 3a                	push   $0x3a
f0104cf3:	ff 76 08             	pushl  0x8(%esi)
f0104cf6:	e8 b2 08 00 00       	call   f01055ad <strfind>
f0104cfb:	2b 46 08             	sub    0x8(%esi),%eax
f0104cfe:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104d01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d04:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d07:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104d0a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104d0d:	83 c4 10             	add    $0x10,%esp
f0104d10:	eb 06                	jmp    f0104d18 <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104d12:	83 eb 01             	sub    $0x1,%ebx
f0104d15:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104d18:	39 fb                	cmp    %edi,%ebx
f0104d1a:	7c 2d                	jl     f0104d49 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0104d1c:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104d20:	80 fa 84             	cmp    $0x84,%dl
f0104d23:	74 0b                	je     f0104d30 <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104d25:	80 fa 64             	cmp    $0x64,%dl
f0104d28:	75 e8                	jne    f0104d12 <debuginfo_eip+0x13f>
f0104d2a:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104d2e:	74 e2                	je     f0104d12 <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104d30:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d33:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104d36:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104d39:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104d3c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104d3f:	29 f8                	sub    %edi,%eax
f0104d41:	39 c2                	cmp    %eax,%edx
f0104d43:	73 04                	jae    f0104d49 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104d45:	01 fa                	add    %edi,%edx
f0104d47:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d49:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104d4c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d4f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d54:	39 cb                	cmp    %ecx,%ebx
f0104d56:	7d 43                	jge    f0104d9b <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f0104d58:	8d 53 01             	lea    0x1(%ebx),%edx
f0104d5b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d5e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104d61:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104d64:	eb 07                	jmp    f0104d6d <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104d66:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104d6a:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104d6d:	39 ca                	cmp    %ecx,%edx
f0104d6f:	74 25                	je     f0104d96 <debuginfo_eip+0x1c3>
f0104d71:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104d74:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104d78:	74 ec                	je     f0104d66 <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d7f:	eb 1a                	jmp    f0104d9b <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104d81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d86:	eb 13                	jmp    f0104d9b <debuginfo_eip+0x1c8>
f0104d88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d8d:	eb 0c                	jmp    f0104d9b <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104d8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d94:	eb 05                	jmp    f0104d9b <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d96:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104d9e:	5b                   	pop    %ebx
f0104d9f:	5e                   	pop    %esi
f0104da0:	5f                   	pop    %edi
f0104da1:	5d                   	pop    %ebp
f0104da2:	c3                   	ret    

f0104da3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104da3:	55                   	push   %ebp
f0104da4:	89 e5                	mov    %esp,%ebp
f0104da6:	57                   	push   %edi
f0104da7:	56                   	push   %esi
f0104da8:	53                   	push   %ebx
f0104da9:	83 ec 1c             	sub    $0x1c,%esp
f0104dac:	89 c7                	mov    %eax,%edi
f0104dae:	89 d6                	mov    %edx,%esi
f0104db0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104db3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104db6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104db9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104dbc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104dc4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104dc7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104dca:	39 d3                	cmp    %edx,%ebx
f0104dcc:	72 05                	jb     f0104dd3 <printnum+0x30>
f0104dce:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104dd1:	77 45                	ja     f0104e18 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104dd3:	83 ec 0c             	sub    $0xc,%esp
f0104dd6:	ff 75 18             	pushl  0x18(%ebp)
f0104dd9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ddc:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104ddf:	53                   	push   %ebx
f0104de0:	ff 75 10             	pushl  0x10(%ebp)
f0104de3:	83 ec 08             	sub    $0x8,%esp
f0104de6:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104de9:	ff 75 e0             	pushl  -0x20(%ebp)
f0104dec:	ff 75 dc             	pushl  -0x24(%ebp)
f0104def:	ff 75 d8             	pushl  -0x28(%ebp)
f0104df2:	e8 f9 11 00 00       	call   f0105ff0 <__udivdi3>
f0104df7:	83 c4 18             	add    $0x18,%esp
f0104dfa:	52                   	push   %edx
f0104dfb:	50                   	push   %eax
f0104dfc:	89 f2                	mov    %esi,%edx
f0104dfe:	89 f8                	mov    %edi,%eax
f0104e00:	e8 9e ff ff ff       	call   f0104da3 <printnum>
f0104e05:	83 c4 20             	add    $0x20,%esp
f0104e08:	eb 18                	jmp    f0104e22 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104e0a:	83 ec 08             	sub    $0x8,%esp
f0104e0d:	56                   	push   %esi
f0104e0e:	ff 75 18             	pushl  0x18(%ebp)
f0104e11:	ff d7                	call   *%edi
f0104e13:	83 c4 10             	add    $0x10,%esp
f0104e16:	eb 03                	jmp    f0104e1b <printnum+0x78>
f0104e18:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104e1b:	83 eb 01             	sub    $0x1,%ebx
f0104e1e:	85 db                	test   %ebx,%ebx
f0104e20:	7f e8                	jg     f0104e0a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104e22:	83 ec 08             	sub    $0x8,%esp
f0104e25:	56                   	push   %esi
f0104e26:	83 ec 04             	sub    $0x4,%esp
f0104e29:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e2c:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e2f:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e32:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e35:	e8 e6 12 00 00       	call   f0106120 <__umoddi3>
f0104e3a:	83 c4 14             	add    $0x14,%esp
f0104e3d:	0f be 80 0e 7a 10 f0 	movsbl -0xfef85f2(%eax),%eax
f0104e44:	50                   	push   %eax
f0104e45:	ff d7                	call   *%edi
}
f0104e47:	83 c4 10             	add    $0x10,%esp
f0104e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e4d:	5b                   	pop    %ebx
f0104e4e:	5e                   	pop    %esi
f0104e4f:	5f                   	pop    %edi
f0104e50:	5d                   	pop    %ebp
f0104e51:	c3                   	ret    

f0104e52 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104e52:	55                   	push   %ebp
f0104e53:	89 e5                	mov    %esp,%ebp
f0104e55:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104e58:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104e5c:	8b 10                	mov    (%eax),%edx
f0104e5e:	3b 50 04             	cmp    0x4(%eax),%edx
f0104e61:	73 0a                	jae    f0104e6d <sprintputch+0x1b>
		*b->buf++ = ch;
f0104e63:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104e66:	89 08                	mov    %ecx,(%eax)
f0104e68:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e6b:	88 02                	mov    %al,(%edx)
}
f0104e6d:	5d                   	pop    %ebp
f0104e6e:	c3                   	ret    

f0104e6f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104e6f:	55                   	push   %ebp
f0104e70:	89 e5                	mov    %esp,%ebp
f0104e72:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104e75:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104e78:	50                   	push   %eax
f0104e79:	ff 75 10             	pushl  0x10(%ebp)
f0104e7c:	ff 75 0c             	pushl  0xc(%ebp)
f0104e7f:	ff 75 08             	pushl  0x8(%ebp)
f0104e82:	e8 05 00 00 00       	call   f0104e8c <vprintfmt>
	va_end(ap);
}
f0104e87:	83 c4 10             	add    $0x10,%esp
f0104e8a:	c9                   	leave  
f0104e8b:	c3                   	ret    

f0104e8c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104e8c:	55                   	push   %ebp
f0104e8d:	89 e5                	mov    %esp,%ebp
f0104e8f:	57                   	push   %edi
f0104e90:	56                   	push   %esi
f0104e91:	53                   	push   %ebx
f0104e92:	83 ec 2c             	sub    $0x2c,%esp
f0104e95:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e9b:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e9e:	eb 12                	jmp    f0104eb2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104ea0:	85 c0                	test   %eax,%eax
f0104ea2:	0f 84 42 04 00 00    	je     f01052ea <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f0104ea8:	83 ec 08             	sub    $0x8,%esp
f0104eab:	53                   	push   %ebx
f0104eac:	50                   	push   %eax
f0104ead:	ff d6                	call   *%esi
f0104eaf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104eb2:	83 c7 01             	add    $0x1,%edi
f0104eb5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104eb9:	83 f8 25             	cmp    $0x25,%eax
f0104ebc:	75 e2                	jne    f0104ea0 <vprintfmt+0x14>
f0104ebe:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104ec2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104ec9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104ed0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104ed7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104edc:	eb 07                	jmp    f0104ee5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ede:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104ee1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ee5:	8d 47 01             	lea    0x1(%edi),%eax
f0104ee8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104eeb:	0f b6 07             	movzbl (%edi),%eax
f0104eee:	0f b6 d0             	movzbl %al,%edx
f0104ef1:	83 e8 23             	sub    $0x23,%eax
f0104ef4:	3c 55                	cmp    $0x55,%al
f0104ef6:	0f 87 d3 03 00 00    	ja     f01052cf <vprintfmt+0x443>
f0104efc:	0f b6 c0             	movzbl %al,%eax
f0104eff:	ff 24 85 60 7b 10 f0 	jmp    *-0xfef84a0(,%eax,4)
f0104f06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104f09:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104f0d:	eb d6                	jmp    f0104ee5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f12:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f17:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104f1a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104f1d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104f21:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104f24:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104f27:	83 f9 09             	cmp    $0x9,%ecx
f0104f2a:	77 3f                	ja     f0104f6b <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104f2c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104f2f:	eb e9                	jmp    f0104f1a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104f31:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f34:	8b 00                	mov    (%eax),%eax
f0104f36:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104f39:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f3c:	8d 40 04             	lea    0x4(%eax),%eax
f0104f3f:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104f45:	eb 2a                	jmp    f0104f71 <vprintfmt+0xe5>
f0104f47:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f4a:	85 c0                	test   %eax,%eax
f0104f4c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f51:	0f 49 d0             	cmovns %eax,%edx
f0104f54:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f5a:	eb 89                	jmp    f0104ee5 <vprintfmt+0x59>
f0104f5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104f5f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104f66:	e9 7a ff ff ff       	jmp    f0104ee5 <vprintfmt+0x59>
f0104f6b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104f6e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104f71:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104f75:	0f 89 6a ff ff ff    	jns    f0104ee5 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104f7b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104f7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f81:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f88:	e9 58 ff ff ff       	jmp    f0104ee5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104f8d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104f93:	e9 4d ff ff ff       	jmp    f0104ee5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104f98:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f9b:	8d 78 04             	lea    0x4(%eax),%edi
f0104f9e:	83 ec 08             	sub    $0x8,%esp
f0104fa1:	53                   	push   %ebx
f0104fa2:	ff 30                	pushl  (%eax)
f0104fa4:	ff d6                	call   *%esi
			break;
f0104fa6:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104fa9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104faf:	e9 fe fe ff ff       	jmp    f0104eb2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104fb4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fb7:	8d 78 04             	lea    0x4(%eax),%edi
f0104fba:	8b 00                	mov    (%eax),%eax
f0104fbc:	99                   	cltd   
f0104fbd:	31 d0                	xor    %edx,%eax
f0104fbf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104fc1:	83 f8 0f             	cmp    $0xf,%eax
f0104fc4:	7f 0b                	jg     f0104fd1 <vprintfmt+0x145>
f0104fc6:	8b 14 85 c0 7c 10 f0 	mov    -0xfef8340(,%eax,4),%edx
f0104fcd:	85 d2                	test   %edx,%edx
f0104fcf:	75 1b                	jne    f0104fec <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0104fd1:	50                   	push   %eax
f0104fd2:	68 26 7a 10 f0       	push   $0xf0107a26
f0104fd7:	53                   	push   %ebx
f0104fd8:	56                   	push   %esi
f0104fd9:	e8 91 fe ff ff       	call   f0104e6f <printfmt>
f0104fde:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104fe1:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fe4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104fe7:	e9 c6 fe ff ff       	jmp    f0104eb2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104fec:	52                   	push   %edx
f0104fed:	68 8c 68 10 f0       	push   $0xf010688c
f0104ff2:	53                   	push   %ebx
f0104ff3:	56                   	push   %esi
f0104ff4:	e8 76 fe ff ff       	call   f0104e6f <printfmt>
f0104ff9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104ffc:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105002:	e9 ab fe ff ff       	jmp    f0104eb2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105007:	8b 45 14             	mov    0x14(%ebp),%eax
f010500a:	83 c0 04             	add    $0x4,%eax
f010500d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105010:	8b 45 14             	mov    0x14(%ebp),%eax
f0105013:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105015:	85 ff                	test   %edi,%edi
f0105017:	b8 1f 7a 10 f0       	mov    $0xf0107a1f,%eax
f010501c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010501f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105023:	0f 8e 94 00 00 00    	jle    f01050bd <vprintfmt+0x231>
f0105029:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010502d:	0f 84 98 00 00 00    	je     f01050cb <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105033:	83 ec 08             	sub    $0x8,%esp
f0105036:	ff 75 d0             	pushl  -0x30(%ebp)
f0105039:	57                   	push   %edi
f010503a:	e8 24 04 00 00       	call   f0105463 <strnlen>
f010503f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105042:	29 c1                	sub    %eax,%ecx
f0105044:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0105047:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010504a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010504e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105051:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105054:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105056:	eb 0f                	jmp    f0105067 <vprintfmt+0x1db>
					putch(padc, putdat);
f0105058:	83 ec 08             	sub    $0x8,%esp
f010505b:	53                   	push   %ebx
f010505c:	ff 75 e0             	pushl  -0x20(%ebp)
f010505f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105061:	83 ef 01             	sub    $0x1,%edi
f0105064:	83 c4 10             	add    $0x10,%esp
f0105067:	85 ff                	test   %edi,%edi
f0105069:	7f ed                	jg     f0105058 <vprintfmt+0x1cc>
f010506b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010506e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105071:	85 c9                	test   %ecx,%ecx
f0105073:	b8 00 00 00 00       	mov    $0x0,%eax
f0105078:	0f 49 c1             	cmovns %ecx,%eax
f010507b:	29 c1                	sub    %eax,%ecx
f010507d:	89 75 08             	mov    %esi,0x8(%ebp)
f0105080:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105083:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105086:	89 cb                	mov    %ecx,%ebx
f0105088:	eb 4d                	jmp    f01050d7 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010508a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010508e:	74 1b                	je     f01050ab <vprintfmt+0x21f>
f0105090:	0f be c0             	movsbl %al,%eax
f0105093:	83 e8 20             	sub    $0x20,%eax
f0105096:	83 f8 5e             	cmp    $0x5e,%eax
f0105099:	76 10                	jbe    f01050ab <vprintfmt+0x21f>
					putch('?', putdat);
f010509b:	83 ec 08             	sub    $0x8,%esp
f010509e:	ff 75 0c             	pushl  0xc(%ebp)
f01050a1:	6a 3f                	push   $0x3f
f01050a3:	ff 55 08             	call   *0x8(%ebp)
f01050a6:	83 c4 10             	add    $0x10,%esp
f01050a9:	eb 0d                	jmp    f01050b8 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f01050ab:	83 ec 08             	sub    $0x8,%esp
f01050ae:	ff 75 0c             	pushl  0xc(%ebp)
f01050b1:	52                   	push   %edx
f01050b2:	ff 55 08             	call   *0x8(%ebp)
f01050b5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01050b8:	83 eb 01             	sub    $0x1,%ebx
f01050bb:	eb 1a                	jmp    f01050d7 <vprintfmt+0x24b>
f01050bd:	89 75 08             	mov    %esi,0x8(%ebp)
f01050c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01050c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050c9:	eb 0c                	jmp    f01050d7 <vprintfmt+0x24b>
f01050cb:	89 75 08             	mov    %esi,0x8(%ebp)
f01050ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01050d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050d7:	83 c7 01             	add    $0x1,%edi
f01050da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01050de:	0f be d0             	movsbl %al,%edx
f01050e1:	85 d2                	test   %edx,%edx
f01050e3:	74 23                	je     f0105108 <vprintfmt+0x27c>
f01050e5:	85 f6                	test   %esi,%esi
f01050e7:	78 a1                	js     f010508a <vprintfmt+0x1fe>
f01050e9:	83 ee 01             	sub    $0x1,%esi
f01050ec:	79 9c                	jns    f010508a <vprintfmt+0x1fe>
f01050ee:	89 df                	mov    %ebx,%edi
f01050f0:	8b 75 08             	mov    0x8(%ebp),%esi
f01050f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050f6:	eb 18                	jmp    f0105110 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01050f8:	83 ec 08             	sub    $0x8,%esp
f01050fb:	53                   	push   %ebx
f01050fc:	6a 20                	push   $0x20
f01050fe:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105100:	83 ef 01             	sub    $0x1,%edi
f0105103:	83 c4 10             	add    $0x10,%esp
f0105106:	eb 08                	jmp    f0105110 <vprintfmt+0x284>
f0105108:	89 df                	mov    %ebx,%edi
f010510a:	8b 75 08             	mov    0x8(%ebp),%esi
f010510d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105110:	85 ff                	test   %edi,%edi
f0105112:	7f e4                	jg     f01050f8 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105114:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105117:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010511a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010511d:	e9 90 fd ff ff       	jmp    f0104eb2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105122:	83 f9 01             	cmp    $0x1,%ecx
f0105125:	7e 19                	jle    f0105140 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0105127:	8b 45 14             	mov    0x14(%ebp),%eax
f010512a:	8b 50 04             	mov    0x4(%eax),%edx
f010512d:	8b 00                	mov    (%eax),%eax
f010512f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105132:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105135:	8b 45 14             	mov    0x14(%ebp),%eax
f0105138:	8d 40 08             	lea    0x8(%eax),%eax
f010513b:	89 45 14             	mov    %eax,0x14(%ebp)
f010513e:	eb 38                	jmp    f0105178 <vprintfmt+0x2ec>
	else if (lflag)
f0105140:	85 c9                	test   %ecx,%ecx
f0105142:	74 1b                	je     f010515f <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0105144:	8b 45 14             	mov    0x14(%ebp),%eax
f0105147:	8b 00                	mov    (%eax),%eax
f0105149:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010514c:	89 c1                	mov    %eax,%ecx
f010514e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105151:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105154:	8b 45 14             	mov    0x14(%ebp),%eax
f0105157:	8d 40 04             	lea    0x4(%eax),%eax
f010515a:	89 45 14             	mov    %eax,0x14(%ebp)
f010515d:	eb 19                	jmp    f0105178 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f010515f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105162:	8b 00                	mov    (%eax),%eax
f0105164:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105167:	89 c1                	mov    %eax,%ecx
f0105169:	c1 f9 1f             	sar    $0x1f,%ecx
f010516c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010516f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105172:	8d 40 04             	lea    0x4(%eax),%eax
f0105175:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105178:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010517b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010517e:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105183:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105187:	0f 89 0e 01 00 00    	jns    f010529b <vprintfmt+0x40f>
				putch('-', putdat);
f010518d:	83 ec 08             	sub    $0x8,%esp
f0105190:	53                   	push   %ebx
f0105191:	6a 2d                	push   $0x2d
f0105193:	ff d6                	call   *%esi
				num = -(long long) num;
f0105195:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105198:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010519b:	f7 da                	neg    %edx
f010519d:	83 d1 00             	adc    $0x0,%ecx
f01051a0:	f7 d9                	neg    %ecx
f01051a2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01051a5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051aa:	e9 ec 00 00 00       	jmp    f010529b <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01051af:	83 f9 01             	cmp    $0x1,%ecx
f01051b2:	7e 18                	jle    f01051cc <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f01051b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01051b7:	8b 10                	mov    (%eax),%edx
f01051b9:	8b 48 04             	mov    0x4(%eax),%ecx
f01051bc:	8d 40 08             	lea    0x8(%eax),%eax
f01051bf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01051c2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051c7:	e9 cf 00 00 00       	jmp    f010529b <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f01051cc:	85 c9                	test   %ecx,%ecx
f01051ce:	74 1a                	je     f01051ea <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f01051d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01051d3:	8b 10                	mov    (%eax),%edx
f01051d5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051da:	8d 40 04             	lea    0x4(%eax),%eax
f01051dd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01051e0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051e5:	e9 b1 00 00 00       	jmp    f010529b <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01051ea:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ed:	8b 10                	mov    (%eax),%edx
f01051ef:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051f4:	8d 40 04             	lea    0x4(%eax),%eax
f01051f7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01051fa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051ff:	e9 97 00 00 00       	jmp    f010529b <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0105204:	83 ec 08             	sub    $0x8,%esp
f0105207:	53                   	push   %ebx
f0105208:	6a 58                	push   $0x58
f010520a:	ff d6                	call   *%esi
			putch('X', putdat);
f010520c:	83 c4 08             	add    $0x8,%esp
f010520f:	53                   	push   %ebx
f0105210:	6a 58                	push   $0x58
f0105212:	ff d6                	call   *%esi
			putch('X', putdat);
f0105214:	83 c4 08             	add    $0x8,%esp
f0105217:	53                   	push   %ebx
f0105218:	6a 58                	push   $0x58
f010521a:	ff d6                	call   *%esi
			break;
f010521c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010521f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0105222:	e9 8b fc ff ff       	jmp    f0104eb2 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0105227:	83 ec 08             	sub    $0x8,%esp
f010522a:	53                   	push   %ebx
f010522b:	6a 30                	push   $0x30
f010522d:	ff d6                	call   *%esi
			putch('x', putdat);
f010522f:	83 c4 08             	add    $0x8,%esp
f0105232:	53                   	push   %ebx
f0105233:	6a 78                	push   $0x78
f0105235:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105237:	8b 45 14             	mov    0x14(%ebp),%eax
f010523a:	8b 10                	mov    (%eax),%edx
f010523c:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105241:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105244:	8d 40 04             	lea    0x4(%eax),%eax
f0105247:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010524a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010524f:	eb 4a                	jmp    f010529b <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105251:	83 f9 01             	cmp    $0x1,%ecx
f0105254:	7e 15                	jle    f010526b <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0105256:	8b 45 14             	mov    0x14(%ebp),%eax
f0105259:	8b 10                	mov    (%eax),%edx
f010525b:	8b 48 04             	mov    0x4(%eax),%ecx
f010525e:	8d 40 08             	lea    0x8(%eax),%eax
f0105261:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105264:	b8 10 00 00 00       	mov    $0x10,%eax
f0105269:	eb 30                	jmp    f010529b <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010526b:	85 c9                	test   %ecx,%ecx
f010526d:	74 17                	je     f0105286 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f010526f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105272:	8b 10                	mov    (%eax),%edx
f0105274:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105279:	8d 40 04             	lea    0x4(%eax),%eax
f010527c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010527f:	b8 10 00 00 00       	mov    $0x10,%eax
f0105284:	eb 15                	jmp    f010529b <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0105286:	8b 45 14             	mov    0x14(%ebp),%eax
f0105289:	8b 10                	mov    (%eax),%edx
f010528b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105290:	8d 40 04             	lea    0x4(%eax),%eax
f0105293:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105296:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010529b:	83 ec 0c             	sub    $0xc,%esp
f010529e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01052a2:	57                   	push   %edi
f01052a3:	ff 75 e0             	pushl  -0x20(%ebp)
f01052a6:	50                   	push   %eax
f01052a7:	51                   	push   %ecx
f01052a8:	52                   	push   %edx
f01052a9:	89 da                	mov    %ebx,%edx
f01052ab:	89 f0                	mov    %esi,%eax
f01052ad:	e8 f1 fa ff ff       	call   f0104da3 <printnum>
			break;
f01052b2:	83 c4 20             	add    $0x20,%esp
f01052b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052b8:	e9 f5 fb ff ff       	jmp    f0104eb2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01052bd:	83 ec 08             	sub    $0x8,%esp
f01052c0:	53                   	push   %ebx
f01052c1:	52                   	push   %edx
f01052c2:	ff d6                	call   *%esi
			break;
f01052c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01052ca:	e9 e3 fb ff ff       	jmp    f0104eb2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01052cf:	83 ec 08             	sub    $0x8,%esp
f01052d2:	53                   	push   %ebx
f01052d3:	6a 25                	push   $0x25
f01052d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01052d7:	83 c4 10             	add    $0x10,%esp
f01052da:	eb 03                	jmp    f01052df <vprintfmt+0x453>
f01052dc:	83 ef 01             	sub    $0x1,%edi
f01052df:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01052e3:	75 f7                	jne    f01052dc <vprintfmt+0x450>
f01052e5:	e9 c8 fb ff ff       	jmp    f0104eb2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01052ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052ed:	5b                   	pop    %ebx
f01052ee:	5e                   	pop    %esi
f01052ef:	5f                   	pop    %edi
f01052f0:	5d                   	pop    %ebp
f01052f1:	c3                   	ret    

f01052f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01052f2:	55                   	push   %ebp
f01052f3:	89 e5                	mov    %esp,%ebp
f01052f5:	83 ec 18             	sub    $0x18,%esp
f01052f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01052fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01052fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105301:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105305:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105308:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010530f:	85 c0                	test   %eax,%eax
f0105311:	74 26                	je     f0105339 <vsnprintf+0x47>
f0105313:	85 d2                	test   %edx,%edx
f0105315:	7e 22                	jle    f0105339 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105317:	ff 75 14             	pushl  0x14(%ebp)
f010531a:	ff 75 10             	pushl  0x10(%ebp)
f010531d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105320:	50                   	push   %eax
f0105321:	68 52 4e 10 f0       	push   $0xf0104e52
f0105326:	e8 61 fb ff ff       	call   f0104e8c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010532b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010532e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105331:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105334:	83 c4 10             	add    $0x10,%esp
f0105337:	eb 05                	jmp    f010533e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010533e:	c9                   	leave  
f010533f:	c3                   	ret    

f0105340 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105340:	55                   	push   %ebp
f0105341:	89 e5                	mov    %esp,%ebp
f0105343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105346:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105349:	50                   	push   %eax
f010534a:	ff 75 10             	pushl  0x10(%ebp)
f010534d:	ff 75 0c             	pushl  0xc(%ebp)
f0105350:	ff 75 08             	pushl  0x8(%ebp)
f0105353:	e8 9a ff ff ff       	call   f01052f2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105358:	c9                   	leave  
f0105359:	c3                   	ret    

f010535a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010535a:	55                   	push   %ebp
f010535b:	89 e5                	mov    %esp,%ebp
f010535d:	57                   	push   %edi
f010535e:	56                   	push   %esi
f010535f:	53                   	push   %ebx
f0105360:	83 ec 0c             	sub    $0xc,%esp
f0105363:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105366:	85 c0                	test   %eax,%eax
f0105368:	74 11                	je     f010537b <readline+0x21>
		cprintf("%s", prompt);
f010536a:	83 ec 08             	sub    $0x8,%esp
f010536d:	50                   	push   %eax
f010536e:	68 8c 68 10 f0       	push   $0xf010688c
f0105373:	e8 2c e3 ff ff       	call   f01036a4 <cprintf>
f0105378:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f010537b:	83 ec 0c             	sub    $0xc,%esp
f010537e:	6a 00                	push   $0x0
f0105380:	e8 27 b4 ff ff       	call   f01007ac <iscons>
f0105385:	89 c7                	mov    %eax,%edi
f0105387:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f010538a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010538f:	e8 07 b4 ff ff       	call   f010079b <getchar>
f0105394:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105396:	85 c0                	test   %eax,%eax
f0105398:	79 29                	jns    f01053c3 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f010539a:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f010539f:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01053a2:	0f 84 9b 00 00 00    	je     f0105443 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01053a8:	83 ec 08             	sub    $0x8,%esp
f01053ab:	53                   	push   %ebx
f01053ac:	68 1f 7d 10 f0       	push   $0xf0107d1f
f01053b1:	e8 ee e2 ff ff       	call   f01036a4 <cprintf>
f01053b6:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01053b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01053be:	e9 80 00 00 00       	jmp    f0105443 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01053c3:	83 f8 08             	cmp    $0x8,%eax
f01053c6:	0f 94 c2             	sete   %dl
f01053c9:	83 f8 7f             	cmp    $0x7f,%eax
f01053cc:	0f 94 c0             	sete   %al
f01053cf:	08 c2                	or     %al,%dl
f01053d1:	74 1a                	je     f01053ed <readline+0x93>
f01053d3:	85 f6                	test   %esi,%esi
f01053d5:	7e 16                	jle    f01053ed <readline+0x93>
			if (echoing)
f01053d7:	85 ff                	test   %edi,%edi
f01053d9:	74 0d                	je     f01053e8 <readline+0x8e>
				cputchar('\b');
f01053db:	83 ec 0c             	sub    $0xc,%esp
f01053de:	6a 08                	push   $0x8
f01053e0:	e8 a6 b3 ff ff       	call   f010078b <cputchar>
f01053e5:	83 c4 10             	add    $0x10,%esp
			i--;
f01053e8:	83 ee 01             	sub    $0x1,%esi
f01053eb:	eb a2                	jmp    f010538f <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01053ed:	83 fb 1f             	cmp    $0x1f,%ebx
f01053f0:	7e 26                	jle    f0105418 <readline+0xbe>
f01053f2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01053f8:	7f 1e                	jg     f0105418 <readline+0xbe>
			if (echoing)
f01053fa:	85 ff                	test   %edi,%edi
f01053fc:	74 0c                	je     f010540a <readline+0xb0>
				cputchar(c);
f01053fe:	83 ec 0c             	sub    $0xc,%esp
f0105401:	53                   	push   %ebx
f0105402:	e8 84 b3 ff ff       	call   f010078b <cputchar>
f0105407:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010540a:	88 9e 80 7a 20 f0    	mov    %bl,-0xfdf8580(%esi)
f0105410:	8d 76 01             	lea    0x1(%esi),%esi
f0105413:	e9 77 ff ff ff       	jmp    f010538f <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105418:	83 fb 0a             	cmp    $0xa,%ebx
f010541b:	74 09                	je     f0105426 <readline+0xcc>
f010541d:	83 fb 0d             	cmp    $0xd,%ebx
f0105420:	0f 85 69 ff ff ff    	jne    f010538f <readline+0x35>
			if (echoing)
f0105426:	85 ff                	test   %edi,%edi
f0105428:	74 0d                	je     f0105437 <readline+0xdd>
				cputchar('\n');
f010542a:	83 ec 0c             	sub    $0xc,%esp
f010542d:	6a 0a                	push   $0xa
f010542f:	e8 57 b3 ff ff       	call   f010078b <cputchar>
f0105434:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105437:	c6 86 80 7a 20 f0 00 	movb   $0x0,-0xfdf8580(%esi)
			return buf;
f010543e:	b8 80 7a 20 f0       	mov    $0xf0207a80,%eax
		}
	}
}
f0105443:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105446:	5b                   	pop    %ebx
f0105447:	5e                   	pop    %esi
f0105448:	5f                   	pop    %edi
f0105449:	5d                   	pop    %ebp
f010544a:	c3                   	ret    

f010544b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010544b:	55                   	push   %ebp
f010544c:	89 e5                	mov    %esp,%ebp
f010544e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105451:	b8 00 00 00 00       	mov    $0x0,%eax
f0105456:	eb 03                	jmp    f010545b <strlen+0x10>
		n++;
f0105458:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010545b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010545f:	75 f7                	jne    f0105458 <strlen+0xd>
		n++;
	return n;
}
f0105461:	5d                   	pop    %ebp
f0105462:	c3                   	ret    

f0105463 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105463:	55                   	push   %ebp
f0105464:	89 e5                	mov    %esp,%ebp
f0105466:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105469:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010546c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105471:	eb 03                	jmp    f0105476 <strnlen+0x13>
		n++;
f0105473:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105476:	39 c2                	cmp    %eax,%edx
f0105478:	74 08                	je     f0105482 <strnlen+0x1f>
f010547a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010547e:	75 f3                	jne    f0105473 <strnlen+0x10>
f0105480:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105482:	5d                   	pop    %ebp
f0105483:	c3                   	ret    

f0105484 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105484:	55                   	push   %ebp
f0105485:	89 e5                	mov    %esp,%ebp
f0105487:	53                   	push   %ebx
f0105488:	8b 45 08             	mov    0x8(%ebp),%eax
f010548b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010548e:	89 c2                	mov    %eax,%edx
f0105490:	83 c2 01             	add    $0x1,%edx
f0105493:	83 c1 01             	add    $0x1,%ecx
f0105496:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010549a:	88 5a ff             	mov    %bl,-0x1(%edx)
f010549d:	84 db                	test   %bl,%bl
f010549f:	75 ef                	jne    f0105490 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01054a1:	5b                   	pop    %ebx
f01054a2:	5d                   	pop    %ebp
f01054a3:	c3                   	ret    

f01054a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01054a4:	55                   	push   %ebp
f01054a5:	89 e5                	mov    %esp,%ebp
f01054a7:	53                   	push   %ebx
f01054a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01054ab:	53                   	push   %ebx
f01054ac:	e8 9a ff ff ff       	call   f010544b <strlen>
f01054b1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01054b4:	ff 75 0c             	pushl  0xc(%ebp)
f01054b7:	01 d8                	add    %ebx,%eax
f01054b9:	50                   	push   %eax
f01054ba:	e8 c5 ff ff ff       	call   f0105484 <strcpy>
	return dst;
}
f01054bf:	89 d8                	mov    %ebx,%eax
f01054c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01054c4:	c9                   	leave  
f01054c5:	c3                   	ret    

f01054c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01054c6:	55                   	push   %ebp
f01054c7:	89 e5                	mov    %esp,%ebp
f01054c9:	56                   	push   %esi
f01054ca:	53                   	push   %ebx
f01054cb:	8b 75 08             	mov    0x8(%ebp),%esi
f01054ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01054d1:	89 f3                	mov    %esi,%ebx
f01054d3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054d6:	89 f2                	mov    %esi,%edx
f01054d8:	eb 0f                	jmp    f01054e9 <strncpy+0x23>
		*dst++ = *src;
f01054da:	83 c2 01             	add    $0x1,%edx
f01054dd:	0f b6 01             	movzbl (%ecx),%eax
f01054e0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01054e3:	80 39 01             	cmpb   $0x1,(%ecx)
f01054e6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054e9:	39 da                	cmp    %ebx,%edx
f01054eb:	75 ed                	jne    f01054da <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01054ed:	89 f0                	mov    %esi,%eax
f01054ef:	5b                   	pop    %ebx
f01054f0:	5e                   	pop    %esi
f01054f1:	5d                   	pop    %ebp
f01054f2:	c3                   	ret    

f01054f3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01054f3:	55                   	push   %ebp
f01054f4:	89 e5                	mov    %esp,%ebp
f01054f6:	56                   	push   %esi
f01054f7:	53                   	push   %ebx
f01054f8:	8b 75 08             	mov    0x8(%ebp),%esi
f01054fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01054fe:	8b 55 10             	mov    0x10(%ebp),%edx
f0105501:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105503:	85 d2                	test   %edx,%edx
f0105505:	74 21                	je     f0105528 <strlcpy+0x35>
f0105507:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010550b:	89 f2                	mov    %esi,%edx
f010550d:	eb 09                	jmp    f0105518 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010550f:	83 c2 01             	add    $0x1,%edx
f0105512:	83 c1 01             	add    $0x1,%ecx
f0105515:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105518:	39 c2                	cmp    %eax,%edx
f010551a:	74 09                	je     f0105525 <strlcpy+0x32>
f010551c:	0f b6 19             	movzbl (%ecx),%ebx
f010551f:	84 db                	test   %bl,%bl
f0105521:	75 ec                	jne    f010550f <strlcpy+0x1c>
f0105523:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105525:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105528:	29 f0                	sub    %esi,%eax
}
f010552a:	5b                   	pop    %ebx
f010552b:	5e                   	pop    %esi
f010552c:	5d                   	pop    %ebp
f010552d:	c3                   	ret    

f010552e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010552e:	55                   	push   %ebp
f010552f:	89 e5                	mov    %esp,%ebp
f0105531:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105534:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105537:	eb 06                	jmp    f010553f <strcmp+0x11>
		p++, q++;
f0105539:	83 c1 01             	add    $0x1,%ecx
f010553c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010553f:	0f b6 01             	movzbl (%ecx),%eax
f0105542:	84 c0                	test   %al,%al
f0105544:	74 04                	je     f010554a <strcmp+0x1c>
f0105546:	3a 02                	cmp    (%edx),%al
f0105548:	74 ef                	je     f0105539 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010554a:	0f b6 c0             	movzbl %al,%eax
f010554d:	0f b6 12             	movzbl (%edx),%edx
f0105550:	29 d0                	sub    %edx,%eax
}
f0105552:	5d                   	pop    %ebp
f0105553:	c3                   	ret    

f0105554 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105554:	55                   	push   %ebp
f0105555:	89 e5                	mov    %esp,%ebp
f0105557:	53                   	push   %ebx
f0105558:	8b 45 08             	mov    0x8(%ebp),%eax
f010555b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010555e:	89 c3                	mov    %eax,%ebx
f0105560:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105563:	eb 06                	jmp    f010556b <strncmp+0x17>
		n--, p++, q++;
f0105565:	83 c0 01             	add    $0x1,%eax
f0105568:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010556b:	39 d8                	cmp    %ebx,%eax
f010556d:	74 15                	je     f0105584 <strncmp+0x30>
f010556f:	0f b6 08             	movzbl (%eax),%ecx
f0105572:	84 c9                	test   %cl,%cl
f0105574:	74 04                	je     f010557a <strncmp+0x26>
f0105576:	3a 0a                	cmp    (%edx),%cl
f0105578:	74 eb                	je     f0105565 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010557a:	0f b6 00             	movzbl (%eax),%eax
f010557d:	0f b6 12             	movzbl (%edx),%edx
f0105580:	29 d0                	sub    %edx,%eax
f0105582:	eb 05                	jmp    f0105589 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105584:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105589:	5b                   	pop    %ebx
f010558a:	5d                   	pop    %ebp
f010558b:	c3                   	ret    

f010558c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010558c:	55                   	push   %ebp
f010558d:	89 e5                	mov    %esp,%ebp
f010558f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105592:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105596:	eb 07                	jmp    f010559f <strchr+0x13>
		if (*s == c)
f0105598:	38 ca                	cmp    %cl,%dl
f010559a:	74 0f                	je     f01055ab <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010559c:	83 c0 01             	add    $0x1,%eax
f010559f:	0f b6 10             	movzbl (%eax),%edx
f01055a2:	84 d2                	test   %dl,%dl
f01055a4:	75 f2                	jne    f0105598 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01055a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055ab:	5d                   	pop    %ebp
f01055ac:	c3                   	ret    

f01055ad <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01055ad:	55                   	push   %ebp
f01055ae:	89 e5                	mov    %esp,%ebp
f01055b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01055b3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055b7:	eb 03                	jmp    f01055bc <strfind+0xf>
f01055b9:	83 c0 01             	add    $0x1,%eax
f01055bc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01055bf:	38 ca                	cmp    %cl,%dl
f01055c1:	74 04                	je     f01055c7 <strfind+0x1a>
f01055c3:	84 d2                	test   %dl,%dl
f01055c5:	75 f2                	jne    f01055b9 <strfind+0xc>
			break;
	return (char *) s;
}
f01055c7:	5d                   	pop    %ebp
f01055c8:	c3                   	ret    

f01055c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01055c9:	55                   	push   %ebp
f01055ca:	89 e5                	mov    %esp,%ebp
f01055cc:	57                   	push   %edi
f01055cd:	56                   	push   %esi
f01055ce:	53                   	push   %ebx
f01055cf:	8b 7d 08             	mov    0x8(%ebp),%edi
f01055d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01055d5:	85 c9                	test   %ecx,%ecx
f01055d7:	74 36                	je     f010560f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01055d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01055df:	75 28                	jne    f0105609 <memset+0x40>
f01055e1:	f6 c1 03             	test   $0x3,%cl
f01055e4:	75 23                	jne    f0105609 <memset+0x40>
		c &= 0xFF;
f01055e6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01055ea:	89 d3                	mov    %edx,%ebx
f01055ec:	c1 e3 08             	shl    $0x8,%ebx
f01055ef:	89 d6                	mov    %edx,%esi
f01055f1:	c1 e6 18             	shl    $0x18,%esi
f01055f4:	89 d0                	mov    %edx,%eax
f01055f6:	c1 e0 10             	shl    $0x10,%eax
f01055f9:	09 f0                	or     %esi,%eax
f01055fb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01055fd:	89 d8                	mov    %ebx,%eax
f01055ff:	09 d0                	or     %edx,%eax
f0105601:	c1 e9 02             	shr    $0x2,%ecx
f0105604:	fc                   	cld    
f0105605:	f3 ab                	rep stos %eax,%es:(%edi)
f0105607:	eb 06                	jmp    f010560f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105609:	8b 45 0c             	mov    0xc(%ebp),%eax
f010560c:	fc                   	cld    
f010560d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010560f:	89 f8                	mov    %edi,%eax
f0105611:	5b                   	pop    %ebx
f0105612:	5e                   	pop    %esi
f0105613:	5f                   	pop    %edi
f0105614:	5d                   	pop    %ebp
f0105615:	c3                   	ret    

f0105616 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105616:	55                   	push   %ebp
f0105617:	89 e5                	mov    %esp,%ebp
f0105619:	57                   	push   %edi
f010561a:	56                   	push   %esi
f010561b:	8b 45 08             	mov    0x8(%ebp),%eax
f010561e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105621:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105624:	39 c6                	cmp    %eax,%esi
f0105626:	73 35                	jae    f010565d <memmove+0x47>
f0105628:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010562b:	39 d0                	cmp    %edx,%eax
f010562d:	73 2e                	jae    f010565d <memmove+0x47>
		s += n;
		d += n;
f010562f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105632:	89 d6                	mov    %edx,%esi
f0105634:	09 fe                	or     %edi,%esi
f0105636:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010563c:	75 13                	jne    f0105651 <memmove+0x3b>
f010563e:	f6 c1 03             	test   $0x3,%cl
f0105641:	75 0e                	jne    f0105651 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105643:	83 ef 04             	sub    $0x4,%edi
f0105646:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105649:	c1 e9 02             	shr    $0x2,%ecx
f010564c:	fd                   	std    
f010564d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010564f:	eb 09                	jmp    f010565a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105651:	83 ef 01             	sub    $0x1,%edi
f0105654:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105657:	fd                   	std    
f0105658:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010565a:	fc                   	cld    
f010565b:	eb 1d                	jmp    f010567a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010565d:	89 f2                	mov    %esi,%edx
f010565f:	09 c2                	or     %eax,%edx
f0105661:	f6 c2 03             	test   $0x3,%dl
f0105664:	75 0f                	jne    f0105675 <memmove+0x5f>
f0105666:	f6 c1 03             	test   $0x3,%cl
f0105669:	75 0a                	jne    f0105675 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010566b:	c1 e9 02             	shr    $0x2,%ecx
f010566e:	89 c7                	mov    %eax,%edi
f0105670:	fc                   	cld    
f0105671:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105673:	eb 05                	jmp    f010567a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105675:	89 c7                	mov    %eax,%edi
f0105677:	fc                   	cld    
f0105678:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010567a:	5e                   	pop    %esi
f010567b:	5f                   	pop    %edi
f010567c:	5d                   	pop    %ebp
f010567d:	c3                   	ret    

f010567e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010567e:	55                   	push   %ebp
f010567f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105681:	ff 75 10             	pushl  0x10(%ebp)
f0105684:	ff 75 0c             	pushl  0xc(%ebp)
f0105687:	ff 75 08             	pushl  0x8(%ebp)
f010568a:	e8 87 ff ff ff       	call   f0105616 <memmove>
}
f010568f:	c9                   	leave  
f0105690:	c3                   	ret    

f0105691 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105691:	55                   	push   %ebp
f0105692:	89 e5                	mov    %esp,%ebp
f0105694:	56                   	push   %esi
f0105695:	53                   	push   %ebx
f0105696:	8b 45 08             	mov    0x8(%ebp),%eax
f0105699:	8b 55 0c             	mov    0xc(%ebp),%edx
f010569c:	89 c6                	mov    %eax,%esi
f010569e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056a1:	eb 1a                	jmp    f01056bd <memcmp+0x2c>
		if (*s1 != *s2)
f01056a3:	0f b6 08             	movzbl (%eax),%ecx
f01056a6:	0f b6 1a             	movzbl (%edx),%ebx
f01056a9:	38 d9                	cmp    %bl,%cl
f01056ab:	74 0a                	je     f01056b7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01056ad:	0f b6 c1             	movzbl %cl,%eax
f01056b0:	0f b6 db             	movzbl %bl,%ebx
f01056b3:	29 d8                	sub    %ebx,%eax
f01056b5:	eb 0f                	jmp    f01056c6 <memcmp+0x35>
		s1++, s2++;
f01056b7:	83 c0 01             	add    $0x1,%eax
f01056ba:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056bd:	39 f0                	cmp    %esi,%eax
f01056bf:	75 e2                	jne    f01056a3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01056c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056c6:	5b                   	pop    %ebx
f01056c7:	5e                   	pop    %esi
f01056c8:	5d                   	pop    %ebp
f01056c9:	c3                   	ret    

f01056ca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01056ca:	55                   	push   %ebp
f01056cb:	89 e5                	mov    %esp,%ebp
f01056cd:	53                   	push   %ebx
f01056ce:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01056d1:	89 c1                	mov    %eax,%ecx
f01056d3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01056d6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01056da:	eb 0a                	jmp    f01056e6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01056dc:	0f b6 10             	movzbl (%eax),%edx
f01056df:	39 da                	cmp    %ebx,%edx
f01056e1:	74 07                	je     f01056ea <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01056e3:	83 c0 01             	add    $0x1,%eax
f01056e6:	39 c8                	cmp    %ecx,%eax
f01056e8:	72 f2                	jb     f01056dc <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01056ea:	5b                   	pop    %ebx
f01056eb:	5d                   	pop    %ebp
f01056ec:	c3                   	ret    

f01056ed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01056ed:	55                   	push   %ebp
f01056ee:	89 e5                	mov    %esp,%ebp
f01056f0:	57                   	push   %edi
f01056f1:	56                   	push   %esi
f01056f2:	53                   	push   %ebx
f01056f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01056f9:	eb 03                	jmp    f01056fe <strtol+0x11>
		s++;
f01056fb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01056fe:	0f b6 01             	movzbl (%ecx),%eax
f0105701:	3c 20                	cmp    $0x20,%al
f0105703:	74 f6                	je     f01056fb <strtol+0xe>
f0105705:	3c 09                	cmp    $0x9,%al
f0105707:	74 f2                	je     f01056fb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105709:	3c 2b                	cmp    $0x2b,%al
f010570b:	75 0a                	jne    f0105717 <strtol+0x2a>
		s++;
f010570d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105710:	bf 00 00 00 00       	mov    $0x0,%edi
f0105715:	eb 11                	jmp    f0105728 <strtol+0x3b>
f0105717:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010571c:	3c 2d                	cmp    $0x2d,%al
f010571e:	75 08                	jne    f0105728 <strtol+0x3b>
		s++, neg = 1;
f0105720:	83 c1 01             	add    $0x1,%ecx
f0105723:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105728:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010572e:	75 15                	jne    f0105745 <strtol+0x58>
f0105730:	80 39 30             	cmpb   $0x30,(%ecx)
f0105733:	75 10                	jne    f0105745 <strtol+0x58>
f0105735:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105739:	75 7c                	jne    f01057b7 <strtol+0xca>
		s += 2, base = 16;
f010573b:	83 c1 02             	add    $0x2,%ecx
f010573e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105743:	eb 16                	jmp    f010575b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105745:	85 db                	test   %ebx,%ebx
f0105747:	75 12                	jne    f010575b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105749:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010574e:	80 39 30             	cmpb   $0x30,(%ecx)
f0105751:	75 08                	jne    f010575b <strtol+0x6e>
		s++, base = 8;
f0105753:	83 c1 01             	add    $0x1,%ecx
f0105756:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010575b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105760:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105763:	0f b6 11             	movzbl (%ecx),%edx
f0105766:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105769:	89 f3                	mov    %esi,%ebx
f010576b:	80 fb 09             	cmp    $0x9,%bl
f010576e:	77 08                	ja     f0105778 <strtol+0x8b>
			dig = *s - '0';
f0105770:	0f be d2             	movsbl %dl,%edx
f0105773:	83 ea 30             	sub    $0x30,%edx
f0105776:	eb 22                	jmp    f010579a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105778:	8d 72 9f             	lea    -0x61(%edx),%esi
f010577b:	89 f3                	mov    %esi,%ebx
f010577d:	80 fb 19             	cmp    $0x19,%bl
f0105780:	77 08                	ja     f010578a <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105782:	0f be d2             	movsbl %dl,%edx
f0105785:	83 ea 57             	sub    $0x57,%edx
f0105788:	eb 10                	jmp    f010579a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010578a:	8d 72 bf             	lea    -0x41(%edx),%esi
f010578d:	89 f3                	mov    %esi,%ebx
f010578f:	80 fb 19             	cmp    $0x19,%bl
f0105792:	77 16                	ja     f01057aa <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105794:	0f be d2             	movsbl %dl,%edx
f0105797:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010579a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010579d:	7d 0b                	jge    f01057aa <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010579f:	83 c1 01             	add    $0x1,%ecx
f01057a2:	0f af 45 10          	imul   0x10(%ebp),%eax
f01057a6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01057a8:	eb b9                	jmp    f0105763 <strtol+0x76>

	if (endptr)
f01057aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01057ae:	74 0d                	je     f01057bd <strtol+0xd0>
		*endptr = (char *) s;
f01057b0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057b3:	89 0e                	mov    %ecx,(%esi)
f01057b5:	eb 06                	jmp    f01057bd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01057b7:	85 db                	test   %ebx,%ebx
f01057b9:	74 98                	je     f0105753 <strtol+0x66>
f01057bb:	eb 9e                	jmp    f010575b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01057bd:	89 c2                	mov    %eax,%edx
f01057bf:	f7 da                	neg    %edx
f01057c1:	85 ff                	test   %edi,%edi
f01057c3:	0f 45 c2             	cmovne %edx,%eax
}
f01057c6:	5b                   	pop    %ebx
f01057c7:	5e                   	pop    %esi
f01057c8:	5f                   	pop    %edi
f01057c9:	5d                   	pop    %ebp
f01057ca:	c3                   	ret    
f01057cb:	90                   	nop

f01057cc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01057cc:	fa                   	cli    

	xorw    %ax, %ax
f01057cd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01057cf:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01057d1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01057d3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01057d5:	0f 01 16             	lgdtl  (%esi)
f01057d8:	74 70                	je     f010584a <mpsearch1+0x3>
	movl    %cr0, %eax
f01057da:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01057dd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01057e1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01057e4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01057ea:	08 00                	or     %al,(%eax)

f01057ec <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01057ec:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01057f0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01057f2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01057f4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01057f6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01057fa:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01057fc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01057fe:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f0105803:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105806:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105809:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010580e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105811:	8b 25 84 7e 20 f0    	mov    0xf0207e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105817:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010581c:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f0105821:	ff d0                	call   *%eax

f0105823 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105823:	eb fe                	jmp    f0105823 <spin>
f0105825:	8d 76 00             	lea    0x0(%esi),%esi

f0105828 <gdt>:
	...
f0105830:	ff                   	(bad)  
f0105831:	ff 00                	incl   (%eax)
f0105833:	00 00                	add    %al,(%eax)
f0105835:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010583c:	00                   	.byte 0x0
f010583d:	92                   	xchg   %eax,%edx
f010583e:	cf                   	iret   
	...

f0105840 <gdtdesc>:
f0105840:	17                   	pop    %ss
f0105841:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105846 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105846:	90                   	nop

f0105847 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105847:	55                   	push   %ebp
f0105848:	89 e5                	mov    %esp,%ebp
f010584a:	57                   	push   %edi
f010584b:	56                   	push   %esi
f010584c:	53                   	push   %ebx
f010584d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105850:	8b 0d 88 7e 20 f0    	mov    0xf0207e88,%ecx
f0105856:	89 c3                	mov    %eax,%ebx
f0105858:	c1 eb 0c             	shr    $0xc,%ebx
f010585b:	39 cb                	cmp    %ecx,%ebx
f010585d:	72 12                	jb     f0105871 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010585f:	50                   	push   %eax
f0105860:	68 a4 62 10 f0       	push   $0xf01062a4
f0105865:	6a 57                	push   $0x57
f0105867:	68 bd 7e 10 f0       	push   $0xf0107ebd
f010586c:	e8 cf a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105871:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105877:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105879:	89 c2                	mov    %eax,%edx
f010587b:	c1 ea 0c             	shr    $0xc,%edx
f010587e:	39 ca                	cmp    %ecx,%edx
f0105880:	72 12                	jb     f0105894 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105882:	50                   	push   %eax
f0105883:	68 a4 62 10 f0       	push   $0xf01062a4
f0105888:	6a 57                	push   $0x57
f010588a:	68 bd 7e 10 f0       	push   $0xf0107ebd
f010588f:	e8 ac a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105894:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010589a:	eb 2f                	jmp    f01058cb <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010589c:	83 ec 04             	sub    $0x4,%esp
f010589f:	6a 04                	push   $0x4
f01058a1:	68 cd 7e 10 f0       	push   $0xf0107ecd
f01058a6:	53                   	push   %ebx
f01058a7:	e8 e5 fd ff ff       	call   f0105691 <memcmp>
f01058ac:	83 c4 10             	add    $0x10,%esp
f01058af:	85 c0                	test   %eax,%eax
f01058b1:	75 15                	jne    f01058c8 <mpsearch1+0x81>
f01058b3:	89 da                	mov    %ebx,%edx
f01058b5:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01058b8:	0f b6 0a             	movzbl (%edx),%ecx
f01058bb:	01 c8                	add    %ecx,%eax
f01058bd:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01058c0:	39 d7                	cmp    %edx,%edi
f01058c2:	75 f4                	jne    f01058b8 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058c4:	84 c0                	test   %al,%al
f01058c6:	74 0e                	je     f01058d6 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01058c8:	83 c3 10             	add    $0x10,%ebx
f01058cb:	39 f3                	cmp    %esi,%ebx
f01058cd:	72 cd                	jb     f010589c <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01058cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01058d4:	eb 02                	jmp    f01058d8 <mpsearch1+0x91>
f01058d6:	89 d8                	mov    %ebx,%eax
}
f01058d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058db:	5b                   	pop    %ebx
f01058dc:	5e                   	pop    %esi
f01058dd:	5f                   	pop    %edi
f01058de:	5d                   	pop    %ebp
f01058df:	c3                   	ret    

f01058e0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01058e0:	55                   	push   %ebp
f01058e1:	89 e5                	mov    %esp,%ebp
f01058e3:	57                   	push   %edi
f01058e4:	56                   	push   %esi
f01058e5:	53                   	push   %ebx
f01058e6:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01058e9:	c7 05 c0 83 20 f0 20 	movl   $0xf0208020,0xf02083c0
f01058f0:	80 20 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01058f3:	83 3d 88 7e 20 f0 00 	cmpl   $0x0,0xf0207e88
f01058fa:	75 16                	jne    f0105912 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01058fc:	68 00 04 00 00       	push   $0x400
f0105901:	68 a4 62 10 f0       	push   $0xf01062a4
f0105906:	6a 6f                	push   $0x6f
f0105908:	68 bd 7e 10 f0       	push   $0xf0107ebd
f010590d:	e8 2e a7 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105912:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105919:	85 c0                	test   %eax,%eax
f010591b:	74 16                	je     f0105933 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f010591d:	c1 e0 04             	shl    $0x4,%eax
f0105920:	ba 00 04 00 00       	mov    $0x400,%edx
f0105925:	e8 1d ff ff ff       	call   f0105847 <mpsearch1>
f010592a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010592d:	85 c0                	test   %eax,%eax
f010592f:	75 3c                	jne    f010596d <mp_init+0x8d>
f0105931:	eb 20                	jmp    f0105953 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105933:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010593a:	c1 e0 0a             	shl    $0xa,%eax
f010593d:	2d 00 04 00 00       	sub    $0x400,%eax
f0105942:	ba 00 04 00 00       	mov    $0x400,%edx
f0105947:	e8 fb fe ff ff       	call   f0105847 <mpsearch1>
f010594c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010594f:	85 c0                	test   %eax,%eax
f0105951:	75 1a                	jne    f010596d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105953:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105958:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010595d:	e8 e5 fe ff ff       	call   f0105847 <mpsearch1>
f0105962:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105965:	85 c0                	test   %eax,%eax
f0105967:	0f 84 5d 02 00 00    	je     f0105bca <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010596d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105970:	8b 70 04             	mov    0x4(%eax),%esi
f0105973:	85 f6                	test   %esi,%esi
f0105975:	74 06                	je     f010597d <mp_init+0x9d>
f0105977:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010597b:	74 15                	je     f0105992 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f010597d:	83 ec 0c             	sub    $0xc,%esp
f0105980:	68 30 7d 10 f0       	push   $0xf0107d30
f0105985:	e8 1a dd ff ff       	call   f01036a4 <cprintf>
f010598a:	83 c4 10             	add    $0x10,%esp
f010598d:	e9 38 02 00 00       	jmp    f0105bca <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105992:	89 f0                	mov    %esi,%eax
f0105994:	c1 e8 0c             	shr    $0xc,%eax
f0105997:	3b 05 88 7e 20 f0    	cmp    0xf0207e88,%eax
f010599d:	72 15                	jb     f01059b4 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010599f:	56                   	push   %esi
f01059a0:	68 a4 62 10 f0       	push   $0xf01062a4
f01059a5:	68 90 00 00 00       	push   $0x90
f01059aa:	68 bd 7e 10 f0       	push   $0xf0107ebd
f01059af:	e8 8c a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01059b4:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01059ba:	83 ec 04             	sub    $0x4,%esp
f01059bd:	6a 04                	push   $0x4
f01059bf:	68 d2 7e 10 f0       	push   $0xf0107ed2
f01059c4:	53                   	push   %ebx
f01059c5:	e8 c7 fc ff ff       	call   f0105691 <memcmp>
f01059ca:	83 c4 10             	add    $0x10,%esp
f01059cd:	85 c0                	test   %eax,%eax
f01059cf:	74 15                	je     f01059e6 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01059d1:	83 ec 0c             	sub    $0xc,%esp
f01059d4:	68 60 7d 10 f0       	push   $0xf0107d60
f01059d9:	e8 c6 dc ff ff       	call   f01036a4 <cprintf>
f01059de:	83 c4 10             	add    $0x10,%esp
f01059e1:	e9 e4 01 00 00       	jmp    f0105bca <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01059e6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01059ea:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01059ee:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01059f1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01059f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01059fb:	eb 0d                	jmp    f0105a0a <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01059fd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105a04:	f0 
f0105a05:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a07:	83 c0 01             	add    $0x1,%eax
f0105a0a:	39 c7                	cmp    %eax,%edi
f0105a0c:	75 ef                	jne    f01059fd <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105a0e:	84 d2                	test   %dl,%dl
f0105a10:	74 15                	je     f0105a27 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105a12:	83 ec 0c             	sub    $0xc,%esp
f0105a15:	68 94 7d 10 f0       	push   $0xf0107d94
f0105a1a:	e8 85 dc ff ff       	call   f01036a4 <cprintf>
f0105a1f:	83 c4 10             	add    $0x10,%esp
f0105a22:	e9 a3 01 00 00       	jmp    f0105bca <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105a27:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105a2b:	3c 01                	cmp    $0x1,%al
f0105a2d:	74 1d                	je     f0105a4c <mp_init+0x16c>
f0105a2f:	3c 04                	cmp    $0x4,%al
f0105a31:	74 19                	je     f0105a4c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105a33:	83 ec 08             	sub    $0x8,%esp
f0105a36:	0f b6 c0             	movzbl %al,%eax
f0105a39:	50                   	push   %eax
f0105a3a:	68 b8 7d 10 f0       	push   $0xf0107db8
f0105a3f:	e8 60 dc ff ff       	call   f01036a4 <cprintf>
f0105a44:	83 c4 10             	add    $0x10,%esp
f0105a47:	e9 7e 01 00 00       	jmp    f0105bca <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a4c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105a50:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a54:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a59:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105a5e:	01 ce                	add    %ecx,%esi
f0105a60:	eb 0d                	jmp    f0105a6f <mp_init+0x18f>
f0105a62:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105a69:	f0 
f0105a6a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a6c:	83 c0 01             	add    $0x1,%eax
f0105a6f:	39 c7                	cmp    %eax,%edi
f0105a71:	75 ef                	jne    f0105a62 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a73:	89 d0                	mov    %edx,%eax
f0105a75:	02 43 2a             	add    0x2a(%ebx),%al
f0105a78:	74 15                	je     f0105a8f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105a7a:	83 ec 0c             	sub    $0xc,%esp
f0105a7d:	68 d8 7d 10 f0       	push   $0xf0107dd8
f0105a82:	e8 1d dc ff ff       	call   f01036a4 <cprintf>
f0105a87:	83 c4 10             	add    $0x10,%esp
f0105a8a:	e9 3b 01 00 00       	jmp    f0105bca <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105a8f:	85 db                	test   %ebx,%ebx
f0105a91:	0f 84 33 01 00 00    	je     f0105bca <mp_init+0x2ea>
		return;
	ismp = 1;
f0105a97:	c7 05 00 80 20 f0 01 	movl   $0x1,0xf0208000
f0105a9e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105aa1:	8b 43 24             	mov    0x24(%ebx),%eax
f0105aa4:	a3 00 90 24 f0       	mov    %eax,0xf0249000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105aa9:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105aac:	be 00 00 00 00       	mov    $0x0,%esi
f0105ab1:	e9 85 00 00 00       	jmp    f0105b3b <mp_init+0x25b>
		switch (*p) {
f0105ab6:	0f b6 07             	movzbl (%edi),%eax
f0105ab9:	84 c0                	test   %al,%al
f0105abb:	74 06                	je     f0105ac3 <mp_init+0x1e3>
f0105abd:	3c 04                	cmp    $0x4,%al
f0105abf:	77 55                	ja     f0105b16 <mp_init+0x236>
f0105ac1:	eb 4e                	jmp    f0105b11 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105ac3:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105ac7:	74 11                	je     f0105ada <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105ac9:	6b 05 c4 83 20 f0 74 	imul   $0x74,0xf02083c4,%eax
f0105ad0:	05 20 80 20 f0       	add    $0xf0208020,%eax
f0105ad5:	a3 c0 83 20 f0       	mov    %eax,0xf02083c0
			if (ncpu < NCPU) {
f0105ada:	a1 c4 83 20 f0       	mov    0xf02083c4,%eax
f0105adf:	83 f8 07             	cmp    $0x7,%eax
f0105ae2:	7f 13                	jg     f0105af7 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105ae4:	6b d0 74             	imul   $0x74,%eax,%edx
f0105ae7:	88 82 20 80 20 f0    	mov    %al,-0xfdf7fe0(%edx)
				ncpu++;
f0105aed:	83 c0 01             	add    $0x1,%eax
f0105af0:	a3 c4 83 20 f0       	mov    %eax,0xf02083c4
f0105af5:	eb 15                	jmp    f0105b0c <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105af7:	83 ec 08             	sub    $0x8,%esp
f0105afa:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105afe:	50                   	push   %eax
f0105aff:	68 08 7e 10 f0       	push   $0xf0107e08
f0105b04:	e8 9b db ff ff       	call   f01036a4 <cprintf>
f0105b09:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105b0c:	83 c7 14             	add    $0x14,%edi
			continue;
f0105b0f:	eb 27                	jmp    f0105b38 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105b11:	83 c7 08             	add    $0x8,%edi
			continue;
f0105b14:	eb 22                	jmp    f0105b38 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b16:	83 ec 08             	sub    $0x8,%esp
f0105b19:	0f b6 c0             	movzbl %al,%eax
f0105b1c:	50                   	push   %eax
f0105b1d:	68 30 7e 10 f0       	push   $0xf0107e30
f0105b22:	e8 7d db ff ff       	call   f01036a4 <cprintf>
			ismp = 0;
f0105b27:	c7 05 00 80 20 f0 00 	movl   $0x0,0xf0208000
f0105b2e:	00 00 00 
			i = conf->entry;
f0105b31:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105b35:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b38:	83 c6 01             	add    $0x1,%esi
f0105b3b:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105b3f:	39 c6                	cmp    %eax,%esi
f0105b41:	0f 82 6f ff ff ff    	jb     f0105ab6 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105b47:	a1 c0 83 20 f0       	mov    0xf02083c0,%eax
f0105b4c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105b53:	83 3d 00 80 20 f0 00 	cmpl   $0x0,0xf0208000
f0105b5a:	75 26                	jne    f0105b82 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105b5c:	c7 05 c4 83 20 f0 01 	movl   $0x1,0xf02083c4
f0105b63:	00 00 00 
		lapicaddr = 0;
f0105b66:	c7 05 00 90 24 f0 00 	movl   $0x0,0xf0249000
f0105b6d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105b70:	83 ec 0c             	sub    $0xc,%esp
f0105b73:	68 50 7e 10 f0       	push   $0xf0107e50
f0105b78:	e8 27 db ff ff       	call   f01036a4 <cprintf>
		return;
f0105b7d:	83 c4 10             	add    $0x10,%esp
f0105b80:	eb 48                	jmp    f0105bca <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105b82:	83 ec 04             	sub    $0x4,%esp
f0105b85:	ff 35 c4 83 20 f0    	pushl  0xf02083c4
f0105b8b:	0f b6 00             	movzbl (%eax),%eax
f0105b8e:	50                   	push   %eax
f0105b8f:	68 d7 7e 10 f0       	push   $0xf0107ed7
f0105b94:	e8 0b db ff ff       	call   f01036a4 <cprintf>

	if (mp->imcrp) {
f0105b99:	83 c4 10             	add    $0x10,%esp
f0105b9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b9f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105ba3:	74 25                	je     f0105bca <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105ba5:	83 ec 0c             	sub    $0xc,%esp
f0105ba8:	68 7c 7e 10 f0       	push   $0xf0107e7c
f0105bad:	e8 f2 da ff ff       	call   f01036a4 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bb2:	ba 22 00 00 00       	mov    $0x22,%edx
f0105bb7:	b8 70 00 00 00       	mov    $0x70,%eax
f0105bbc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105bbd:	ba 23 00 00 00       	mov    $0x23,%edx
f0105bc2:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bc3:	83 c8 01             	or     $0x1,%eax
f0105bc6:	ee                   	out    %al,(%dx)
f0105bc7:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bcd:	5b                   	pop    %ebx
f0105bce:	5e                   	pop    %esi
f0105bcf:	5f                   	pop    %edi
f0105bd0:	5d                   	pop    %ebp
f0105bd1:	c3                   	ret    

f0105bd2 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105bd2:	55                   	push   %ebp
f0105bd3:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105bd5:	8b 0d 04 90 24 f0    	mov    0xf0249004,%ecx
f0105bdb:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105bde:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105be0:	a1 04 90 24 f0       	mov    0xf0249004,%eax
f0105be5:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105be8:	5d                   	pop    %ebp
f0105be9:	c3                   	ret    

f0105bea <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105bea:	55                   	push   %ebp
f0105beb:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105bed:	a1 04 90 24 f0       	mov    0xf0249004,%eax
f0105bf2:	85 c0                	test   %eax,%eax
f0105bf4:	74 08                	je     f0105bfe <cpunum+0x14>
		return lapic[ID] >> 24;
f0105bf6:	8b 40 20             	mov    0x20(%eax),%eax
f0105bf9:	c1 e8 18             	shr    $0x18,%eax
f0105bfc:	eb 05                	jmp    f0105c03 <cpunum+0x19>
	return 0;
f0105bfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c03:	5d                   	pop    %ebp
f0105c04:	c3                   	ret    

f0105c05 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105c05:	a1 00 90 24 f0       	mov    0xf0249000,%eax
f0105c0a:	85 c0                	test   %eax,%eax
f0105c0c:	0f 84 21 01 00 00    	je     f0105d33 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105c12:	55                   	push   %ebp
f0105c13:	89 e5                	mov    %esp,%ebp
f0105c15:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105c18:	68 00 10 00 00       	push   $0x1000
f0105c1d:	50                   	push   %eax
f0105c1e:	e8 3f b6 ff ff       	call   f0101262 <mmio_map_region>
f0105c23:	a3 04 90 24 f0       	mov    %eax,0xf0249004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105c28:	ba 27 01 00 00       	mov    $0x127,%edx
f0105c2d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105c32:	e8 9b ff ff ff       	call   f0105bd2 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105c37:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105c3c:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105c41:	e8 8c ff ff ff       	call   f0105bd2 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105c46:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105c4b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105c50:	e8 7d ff ff ff       	call   f0105bd2 <lapicw>
	lapicw(TICR, 10000000); 
f0105c55:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105c5a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105c5f:	e8 6e ff ff ff       	call   f0105bd2 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105c64:	e8 81 ff ff ff       	call   f0105bea <cpunum>
f0105c69:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c6c:	05 20 80 20 f0       	add    $0xf0208020,%eax
f0105c71:	83 c4 10             	add    $0x10,%esp
f0105c74:	39 05 c0 83 20 f0    	cmp    %eax,0xf02083c0
f0105c7a:	74 0f                	je     f0105c8b <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105c7c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c81:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105c86:	e8 47 ff ff ff       	call   f0105bd2 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105c8b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c90:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105c95:	e8 38 ff ff ff       	call   f0105bd2 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105c9a:	a1 04 90 24 f0       	mov    0xf0249004,%eax
f0105c9f:	8b 40 30             	mov    0x30(%eax),%eax
f0105ca2:	c1 e8 10             	shr    $0x10,%eax
f0105ca5:	3c 03                	cmp    $0x3,%al
f0105ca7:	76 0f                	jbe    f0105cb8 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105ca9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cae:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105cb3:	e8 1a ff ff ff       	call   f0105bd2 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105cb8:	ba 33 00 00 00       	mov    $0x33,%edx
f0105cbd:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105cc2:	e8 0b ff ff ff       	call   f0105bd2 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105cc7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ccc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105cd1:	e8 fc fe ff ff       	call   f0105bd2 <lapicw>
	lapicw(ESR, 0);
f0105cd6:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cdb:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ce0:	e8 ed fe ff ff       	call   f0105bd2 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105ce5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cea:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105cef:	e8 de fe ff ff       	call   f0105bd2 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105cf4:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cf9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105cfe:	e8 cf fe ff ff       	call   f0105bd2 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105d03:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105d08:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d0d:	e8 c0 fe ff ff       	call   f0105bd2 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105d12:	8b 15 04 90 24 f0    	mov    0xf0249004,%edx
f0105d18:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d1e:	f6 c4 10             	test   $0x10,%ah
f0105d21:	75 f5                	jne    f0105d18 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105d23:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d28:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d2d:	e8 a0 fe ff ff       	call   f0105bd2 <lapicw>
}
f0105d32:	c9                   	leave  
f0105d33:	f3 c3                	repz ret 

f0105d35 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105d35:	83 3d 04 90 24 f0 00 	cmpl   $0x0,0xf0249004
f0105d3c:	74 13                	je     f0105d51 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105d3e:	55                   	push   %ebp
f0105d3f:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105d41:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d46:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d4b:	e8 82 fe ff ff       	call   f0105bd2 <lapicw>
}
f0105d50:	5d                   	pop    %ebp
f0105d51:	f3 c3                	repz ret 

f0105d53 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105d53:	55                   	push   %ebp
f0105d54:	89 e5                	mov    %esp,%ebp
f0105d56:	56                   	push   %esi
f0105d57:	53                   	push   %ebx
f0105d58:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d5e:	ba 70 00 00 00       	mov    $0x70,%edx
f0105d63:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105d68:	ee                   	out    %al,(%dx)
f0105d69:	ba 71 00 00 00       	mov    $0x71,%edx
f0105d6e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d73:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d74:	83 3d 88 7e 20 f0 00 	cmpl   $0x0,0xf0207e88
f0105d7b:	75 19                	jne    f0105d96 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d7d:	68 67 04 00 00       	push   $0x467
f0105d82:	68 a4 62 10 f0       	push   $0xf01062a4
f0105d87:	68 98 00 00 00       	push   $0x98
f0105d8c:	68 f4 7e 10 f0       	push   $0xf0107ef4
f0105d91:	e8 aa a2 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105d96:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105d9d:	00 00 
	wrv[1] = addr >> 4;
f0105d9f:	89 d8                	mov    %ebx,%eax
f0105da1:	c1 e8 04             	shr    $0x4,%eax
f0105da4:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105daa:	c1 e6 18             	shl    $0x18,%esi
f0105dad:	89 f2                	mov    %esi,%edx
f0105daf:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105db4:	e8 19 fe ff ff       	call   f0105bd2 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105db9:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105dbe:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dc3:	e8 0a fe ff ff       	call   f0105bd2 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105dc8:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105dcd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dd2:	e8 fb fd ff ff       	call   f0105bd2 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105dd7:	c1 eb 0c             	shr    $0xc,%ebx
f0105dda:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ddd:	89 f2                	mov    %esi,%edx
f0105ddf:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105de4:	e8 e9 fd ff ff       	call   f0105bd2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105de9:	89 da                	mov    %ebx,%edx
f0105deb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105df0:	e8 dd fd ff ff       	call   f0105bd2 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105df5:	89 f2                	mov    %esi,%edx
f0105df7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105dfc:	e8 d1 fd ff ff       	call   f0105bd2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e01:	89 da                	mov    %ebx,%edx
f0105e03:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e08:	e8 c5 fd ff ff       	call   f0105bd2 <lapicw>
		microdelay(200);
	}
}
f0105e0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e10:	5b                   	pop    %ebx
f0105e11:	5e                   	pop    %esi
f0105e12:	5d                   	pop    %ebp
f0105e13:	c3                   	ret    

f0105e14 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105e14:	55                   	push   %ebp
f0105e15:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105e17:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e1a:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105e20:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e25:	e8 a8 fd ff ff       	call   f0105bd2 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105e2a:	8b 15 04 90 24 f0    	mov    0xf0249004,%edx
f0105e30:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e36:	f6 c4 10             	test   $0x10,%ah
f0105e39:	75 f5                	jne    f0105e30 <lapic_ipi+0x1c>
		;
}
f0105e3b:	5d                   	pop    %ebp
f0105e3c:	c3                   	ret    

f0105e3d <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105e3d:	55                   	push   %ebp
f0105e3e:	89 e5                	mov    %esp,%ebp
f0105e40:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105e43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105e49:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e4c:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105e4f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105e56:	5d                   	pop    %ebp
f0105e57:	c3                   	ret    

f0105e58 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105e58:	55                   	push   %ebp
f0105e59:	89 e5                	mov    %esp,%ebp
f0105e5b:	56                   	push   %esi
f0105e5c:	53                   	push   %ebx
f0105e5d:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e60:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105e63:	74 14                	je     f0105e79 <spin_lock+0x21>
f0105e65:	8b 73 08             	mov    0x8(%ebx),%esi
f0105e68:	e8 7d fd ff ff       	call   f0105bea <cpunum>
f0105e6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e70:	05 20 80 20 f0       	add    $0xf0208020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105e75:	39 c6                	cmp    %eax,%esi
f0105e77:	74 07                	je     f0105e80 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105e79:	ba 01 00 00 00       	mov    $0x1,%edx
f0105e7e:	eb 20                	jmp    f0105ea0 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105e80:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105e83:	e8 62 fd ff ff       	call   f0105bea <cpunum>
f0105e88:	83 ec 0c             	sub    $0xc,%esp
f0105e8b:	53                   	push   %ebx
f0105e8c:	50                   	push   %eax
f0105e8d:	68 04 7f 10 f0       	push   $0xf0107f04
f0105e92:	6a 41                	push   $0x41
f0105e94:	68 68 7f 10 f0       	push   $0xf0107f68
f0105e99:	e8 a2 a1 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105e9e:	f3 90                	pause  
f0105ea0:	89 d0                	mov    %edx,%eax
f0105ea2:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105ea5:	85 c0                	test   %eax,%eax
f0105ea7:	75 f5                	jne    f0105e9e <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105ea9:	e8 3c fd ff ff       	call   f0105bea <cpunum>
f0105eae:	6b c0 74             	imul   $0x74,%eax,%eax
f0105eb1:	05 20 80 20 f0       	add    $0xf0208020,%eax
f0105eb6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105eb9:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105ebc:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ebe:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ec3:	eb 0b                	jmp    f0105ed0 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105ec5:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105ec8:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105ecb:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ecd:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105ed0:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105ed6:	76 11                	jbe    f0105ee9 <spin_lock+0x91>
f0105ed8:	83 f8 09             	cmp    $0x9,%eax
f0105edb:	7e e8                	jle    f0105ec5 <spin_lock+0x6d>
f0105edd:	eb 0a                	jmp    f0105ee9 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105edf:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105ee6:	83 c0 01             	add    $0x1,%eax
f0105ee9:	83 f8 09             	cmp    $0x9,%eax
f0105eec:	7e f1                	jle    f0105edf <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105eee:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105ef1:	5b                   	pop    %ebx
f0105ef2:	5e                   	pop    %esi
f0105ef3:	5d                   	pop    %ebp
f0105ef4:	c3                   	ret    

f0105ef5 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105ef5:	55                   	push   %ebp
f0105ef6:	89 e5                	mov    %esp,%ebp
f0105ef8:	57                   	push   %edi
f0105ef9:	56                   	push   %esi
f0105efa:	53                   	push   %ebx
f0105efb:	83 ec 4c             	sub    $0x4c,%esp
f0105efe:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105f01:	83 3e 00             	cmpl   $0x0,(%esi)
f0105f04:	74 18                	je     f0105f1e <spin_unlock+0x29>
f0105f06:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105f09:	e8 dc fc ff ff       	call   f0105bea <cpunum>
f0105f0e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f11:	05 20 80 20 f0       	add    $0xf0208020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105f16:	39 c3                	cmp    %eax,%ebx
f0105f18:	0f 84 a5 00 00 00    	je     f0105fc3 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105f1e:	83 ec 04             	sub    $0x4,%esp
f0105f21:	6a 28                	push   $0x28
f0105f23:	8d 46 0c             	lea    0xc(%esi),%eax
f0105f26:	50                   	push   %eax
f0105f27:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105f2a:	53                   	push   %ebx
f0105f2b:	e8 e6 f6 ff ff       	call   f0105616 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105f30:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105f33:	0f b6 38             	movzbl (%eax),%edi
f0105f36:	8b 76 04             	mov    0x4(%esi),%esi
f0105f39:	e8 ac fc ff ff       	call   f0105bea <cpunum>
f0105f3e:	57                   	push   %edi
f0105f3f:	56                   	push   %esi
f0105f40:	50                   	push   %eax
f0105f41:	68 30 7f 10 f0       	push   $0xf0107f30
f0105f46:	e8 59 d7 ff ff       	call   f01036a4 <cprintf>
f0105f4b:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105f4e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105f51:	eb 54                	jmp    f0105fa7 <spin_unlock+0xb2>
f0105f53:	83 ec 08             	sub    $0x8,%esp
f0105f56:	57                   	push   %edi
f0105f57:	50                   	push   %eax
f0105f58:	e8 76 ec ff ff       	call   f0104bd3 <debuginfo_eip>
f0105f5d:	83 c4 10             	add    $0x10,%esp
f0105f60:	85 c0                	test   %eax,%eax
f0105f62:	78 27                	js     f0105f8b <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105f64:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105f66:	83 ec 04             	sub    $0x4,%esp
f0105f69:	89 c2                	mov    %eax,%edx
f0105f6b:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105f6e:	52                   	push   %edx
f0105f6f:	ff 75 b0             	pushl  -0x50(%ebp)
f0105f72:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105f75:	ff 75 ac             	pushl  -0x54(%ebp)
f0105f78:	ff 75 a8             	pushl  -0x58(%ebp)
f0105f7b:	50                   	push   %eax
f0105f7c:	68 78 7f 10 f0       	push   $0xf0107f78
f0105f81:	e8 1e d7 ff ff       	call   f01036a4 <cprintf>
f0105f86:	83 c4 20             	add    $0x20,%esp
f0105f89:	eb 12                	jmp    f0105f9d <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105f8b:	83 ec 08             	sub    $0x8,%esp
f0105f8e:	ff 36                	pushl  (%esi)
f0105f90:	68 8f 7f 10 f0       	push   $0xf0107f8f
f0105f95:	e8 0a d7 ff ff       	call   f01036a4 <cprintf>
f0105f9a:	83 c4 10             	add    $0x10,%esp
f0105f9d:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105fa0:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105fa3:	39 c3                	cmp    %eax,%ebx
f0105fa5:	74 08                	je     f0105faf <spin_unlock+0xba>
f0105fa7:	89 de                	mov    %ebx,%esi
f0105fa9:	8b 03                	mov    (%ebx),%eax
f0105fab:	85 c0                	test   %eax,%eax
f0105fad:	75 a4                	jne    f0105f53 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105faf:	83 ec 04             	sub    $0x4,%esp
f0105fb2:	68 97 7f 10 f0       	push   $0xf0107f97
f0105fb7:	6a 67                	push   $0x67
f0105fb9:	68 68 7f 10 f0       	push   $0xf0107f68
f0105fbe:	e8 7d a0 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105fc3:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105fca:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105fd1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fd6:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105fd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105fdc:	5b                   	pop    %ebx
f0105fdd:	5e                   	pop    %esi
f0105fde:	5f                   	pop    %edi
f0105fdf:	5d                   	pop    %ebp
f0105fe0:	c3                   	ret    
f0105fe1:	66 90                	xchg   %ax,%ax
f0105fe3:	66 90                	xchg   %ax,%ax
f0105fe5:	66 90                	xchg   %ax,%ax
f0105fe7:	66 90                	xchg   %ax,%ax
f0105fe9:	66 90                	xchg   %ax,%ax
f0105feb:	66 90                	xchg   %ax,%ax
f0105fed:	66 90                	xchg   %ax,%ax
f0105fef:	90                   	nop

f0105ff0 <__udivdi3>:
f0105ff0:	55                   	push   %ebp
f0105ff1:	57                   	push   %edi
f0105ff2:	56                   	push   %esi
f0105ff3:	53                   	push   %ebx
f0105ff4:	83 ec 1c             	sub    $0x1c,%esp
f0105ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106003:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106007:	85 f6                	test   %esi,%esi
f0106009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010600d:	89 ca                	mov    %ecx,%edx
f010600f:	89 f8                	mov    %edi,%eax
f0106011:	75 3d                	jne    f0106050 <__udivdi3+0x60>
f0106013:	39 cf                	cmp    %ecx,%edi
f0106015:	0f 87 c5 00 00 00    	ja     f01060e0 <__udivdi3+0xf0>
f010601b:	85 ff                	test   %edi,%edi
f010601d:	89 fd                	mov    %edi,%ebp
f010601f:	75 0b                	jne    f010602c <__udivdi3+0x3c>
f0106021:	b8 01 00 00 00       	mov    $0x1,%eax
f0106026:	31 d2                	xor    %edx,%edx
f0106028:	f7 f7                	div    %edi
f010602a:	89 c5                	mov    %eax,%ebp
f010602c:	89 c8                	mov    %ecx,%eax
f010602e:	31 d2                	xor    %edx,%edx
f0106030:	f7 f5                	div    %ebp
f0106032:	89 c1                	mov    %eax,%ecx
f0106034:	89 d8                	mov    %ebx,%eax
f0106036:	89 cf                	mov    %ecx,%edi
f0106038:	f7 f5                	div    %ebp
f010603a:	89 c3                	mov    %eax,%ebx
f010603c:	89 d8                	mov    %ebx,%eax
f010603e:	89 fa                	mov    %edi,%edx
f0106040:	83 c4 1c             	add    $0x1c,%esp
f0106043:	5b                   	pop    %ebx
f0106044:	5e                   	pop    %esi
f0106045:	5f                   	pop    %edi
f0106046:	5d                   	pop    %ebp
f0106047:	c3                   	ret    
f0106048:	90                   	nop
f0106049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106050:	39 ce                	cmp    %ecx,%esi
f0106052:	77 74                	ja     f01060c8 <__udivdi3+0xd8>
f0106054:	0f bd fe             	bsr    %esi,%edi
f0106057:	83 f7 1f             	xor    $0x1f,%edi
f010605a:	0f 84 98 00 00 00    	je     f01060f8 <__udivdi3+0x108>
f0106060:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106065:	89 f9                	mov    %edi,%ecx
f0106067:	89 c5                	mov    %eax,%ebp
f0106069:	29 fb                	sub    %edi,%ebx
f010606b:	d3 e6                	shl    %cl,%esi
f010606d:	89 d9                	mov    %ebx,%ecx
f010606f:	d3 ed                	shr    %cl,%ebp
f0106071:	89 f9                	mov    %edi,%ecx
f0106073:	d3 e0                	shl    %cl,%eax
f0106075:	09 ee                	or     %ebp,%esi
f0106077:	89 d9                	mov    %ebx,%ecx
f0106079:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010607d:	89 d5                	mov    %edx,%ebp
f010607f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106083:	d3 ed                	shr    %cl,%ebp
f0106085:	89 f9                	mov    %edi,%ecx
f0106087:	d3 e2                	shl    %cl,%edx
f0106089:	89 d9                	mov    %ebx,%ecx
f010608b:	d3 e8                	shr    %cl,%eax
f010608d:	09 c2                	or     %eax,%edx
f010608f:	89 d0                	mov    %edx,%eax
f0106091:	89 ea                	mov    %ebp,%edx
f0106093:	f7 f6                	div    %esi
f0106095:	89 d5                	mov    %edx,%ebp
f0106097:	89 c3                	mov    %eax,%ebx
f0106099:	f7 64 24 0c          	mull   0xc(%esp)
f010609d:	39 d5                	cmp    %edx,%ebp
f010609f:	72 10                	jb     f01060b1 <__udivdi3+0xc1>
f01060a1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01060a5:	89 f9                	mov    %edi,%ecx
f01060a7:	d3 e6                	shl    %cl,%esi
f01060a9:	39 c6                	cmp    %eax,%esi
f01060ab:	73 07                	jae    f01060b4 <__udivdi3+0xc4>
f01060ad:	39 d5                	cmp    %edx,%ebp
f01060af:	75 03                	jne    f01060b4 <__udivdi3+0xc4>
f01060b1:	83 eb 01             	sub    $0x1,%ebx
f01060b4:	31 ff                	xor    %edi,%edi
f01060b6:	89 d8                	mov    %ebx,%eax
f01060b8:	89 fa                	mov    %edi,%edx
f01060ba:	83 c4 1c             	add    $0x1c,%esp
f01060bd:	5b                   	pop    %ebx
f01060be:	5e                   	pop    %esi
f01060bf:	5f                   	pop    %edi
f01060c0:	5d                   	pop    %ebp
f01060c1:	c3                   	ret    
f01060c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01060c8:	31 ff                	xor    %edi,%edi
f01060ca:	31 db                	xor    %ebx,%ebx
f01060cc:	89 d8                	mov    %ebx,%eax
f01060ce:	89 fa                	mov    %edi,%edx
f01060d0:	83 c4 1c             	add    $0x1c,%esp
f01060d3:	5b                   	pop    %ebx
f01060d4:	5e                   	pop    %esi
f01060d5:	5f                   	pop    %edi
f01060d6:	5d                   	pop    %ebp
f01060d7:	c3                   	ret    
f01060d8:	90                   	nop
f01060d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01060e0:	89 d8                	mov    %ebx,%eax
f01060e2:	f7 f7                	div    %edi
f01060e4:	31 ff                	xor    %edi,%edi
f01060e6:	89 c3                	mov    %eax,%ebx
f01060e8:	89 d8                	mov    %ebx,%eax
f01060ea:	89 fa                	mov    %edi,%edx
f01060ec:	83 c4 1c             	add    $0x1c,%esp
f01060ef:	5b                   	pop    %ebx
f01060f0:	5e                   	pop    %esi
f01060f1:	5f                   	pop    %edi
f01060f2:	5d                   	pop    %ebp
f01060f3:	c3                   	ret    
f01060f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01060f8:	39 ce                	cmp    %ecx,%esi
f01060fa:	72 0c                	jb     f0106108 <__udivdi3+0x118>
f01060fc:	31 db                	xor    %ebx,%ebx
f01060fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106102:	0f 87 34 ff ff ff    	ja     f010603c <__udivdi3+0x4c>
f0106108:	bb 01 00 00 00       	mov    $0x1,%ebx
f010610d:	e9 2a ff ff ff       	jmp    f010603c <__udivdi3+0x4c>
f0106112:	66 90                	xchg   %ax,%ax
f0106114:	66 90                	xchg   %ax,%ax
f0106116:	66 90                	xchg   %ax,%ax
f0106118:	66 90                	xchg   %ax,%ax
f010611a:	66 90                	xchg   %ax,%ax
f010611c:	66 90                	xchg   %ax,%ax
f010611e:	66 90                	xchg   %ax,%ax

f0106120 <__umoddi3>:
f0106120:	55                   	push   %ebp
f0106121:	57                   	push   %edi
f0106122:	56                   	push   %esi
f0106123:	53                   	push   %ebx
f0106124:	83 ec 1c             	sub    $0x1c,%esp
f0106127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010612b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010612f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106133:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106137:	85 d2                	test   %edx,%edx
f0106139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010613d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106141:	89 f3                	mov    %esi,%ebx
f0106143:	89 3c 24             	mov    %edi,(%esp)
f0106146:	89 74 24 04          	mov    %esi,0x4(%esp)
f010614a:	75 1c                	jne    f0106168 <__umoddi3+0x48>
f010614c:	39 f7                	cmp    %esi,%edi
f010614e:	76 50                	jbe    f01061a0 <__umoddi3+0x80>
f0106150:	89 c8                	mov    %ecx,%eax
f0106152:	89 f2                	mov    %esi,%edx
f0106154:	f7 f7                	div    %edi
f0106156:	89 d0                	mov    %edx,%eax
f0106158:	31 d2                	xor    %edx,%edx
f010615a:	83 c4 1c             	add    $0x1c,%esp
f010615d:	5b                   	pop    %ebx
f010615e:	5e                   	pop    %esi
f010615f:	5f                   	pop    %edi
f0106160:	5d                   	pop    %ebp
f0106161:	c3                   	ret    
f0106162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106168:	39 f2                	cmp    %esi,%edx
f010616a:	89 d0                	mov    %edx,%eax
f010616c:	77 52                	ja     f01061c0 <__umoddi3+0xa0>
f010616e:	0f bd ea             	bsr    %edx,%ebp
f0106171:	83 f5 1f             	xor    $0x1f,%ebp
f0106174:	75 5a                	jne    f01061d0 <__umoddi3+0xb0>
f0106176:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010617a:	0f 82 e0 00 00 00    	jb     f0106260 <__umoddi3+0x140>
f0106180:	39 0c 24             	cmp    %ecx,(%esp)
f0106183:	0f 86 d7 00 00 00    	jbe    f0106260 <__umoddi3+0x140>
f0106189:	8b 44 24 08          	mov    0x8(%esp),%eax
f010618d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106191:	83 c4 1c             	add    $0x1c,%esp
f0106194:	5b                   	pop    %ebx
f0106195:	5e                   	pop    %esi
f0106196:	5f                   	pop    %edi
f0106197:	5d                   	pop    %ebp
f0106198:	c3                   	ret    
f0106199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061a0:	85 ff                	test   %edi,%edi
f01061a2:	89 fd                	mov    %edi,%ebp
f01061a4:	75 0b                	jne    f01061b1 <__umoddi3+0x91>
f01061a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01061ab:	31 d2                	xor    %edx,%edx
f01061ad:	f7 f7                	div    %edi
f01061af:	89 c5                	mov    %eax,%ebp
f01061b1:	89 f0                	mov    %esi,%eax
f01061b3:	31 d2                	xor    %edx,%edx
f01061b5:	f7 f5                	div    %ebp
f01061b7:	89 c8                	mov    %ecx,%eax
f01061b9:	f7 f5                	div    %ebp
f01061bb:	89 d0                	mov    %edx,%eax
f01061bd:	eb 99                	jmp    f0106158 <__umoddi3+0x38>
f01061bf:	90                   	nop
f01061c0:	89 c8                	mov    %ecx,%eax
f01061c2:	89 f2                	mov    %esi,%edx
f01061c4:	83 c4 1c             	add    $0x1c,%esp
f01061c7:	5b                   	pop    %ebx
f01061c8:	5e                   	pop    %esi
f01061c9:	5f                   	pop    %edi
f01061ca:	5d                   	pop    %ebp
f01061cb:	c3                   	ret    
f01061cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01061d0:	8b 34 24             	mov    (%esp),%esi
f01061d3:	bf 20 00 00 00       	mov    $0x20,%edi
f01061d8:	89 e9                	mov    %ebp,%ecx
f01061da:	29 ef                	sub    %ebp,%edi
f01061dc:	d3 e0                	shl    %cl,%eax
f01061de:	89 f9                	mov    %edi,%ecx
f01061e0:	89 f2                	mov    %esi,%edx
f01061e2:	d3 ea                	shr    %cl,%edx
f01061e4:	89 e9                	mov    %ebp,%ecx
f01061e6:	09 c2                	or     %eax,%edx
f01061e8:	89 d8                	mov    %ebx,%eax
f01061ea:	89 14 24             	mov    %edx,(%esp)
f01061ed:	89 f2                	mov    %esi,%edx
f01061ef:	d3 e2                	shl    %cl,%edx
f01061f1:	89 f9                	mov    %edi,%ecx
f01061f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01061f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01061fb:	d3 e8                	shr    %cl,%eax
f01061fd:	89 e9                	mov    %ebp,%ecx
f01061ff:	89 c6                	mov    %eax,%esi
f0106201:	d3 e3                	shl    %cl,%ebx
f0106203:	89 f9                	mov    %edi,%ecx
f0106205:	89 d0                	mov    %edx,%eax
f0106207:	d3 e8                	shr    %cl,%eax
f0106209:	89 e9                	mov    %ebp,%ecx
f010620b:	09 d8                	or     %ebx,%eax
f010620d:	89 d3                	mov    %edx,%ebx
f010620f:	89 f2                	mov    %esi,%edx
f0106211:	f7 34 24             	divl   (%esp)
f0106214:	89 d6                	mov    %edx,%esi
f0106216:	d3 e3                	shl    %cl,%ebx
f0106218:	f7 64 24 04          	mull   0x4(%esp)
f010621c:	39 d6                	cmp    %edx,%esi
f010621e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106222:	89 d1                	mov    %edx,%ecx
f0106224:	89 c3                	mov    %eax,%ebx
f0106226:	72 08                	jb     f0106230 <__umoddi3+0x110>
f0106228:	75 11                	jne    f010623b <__umoddi3+0x11b>
f010622a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010622e:	73 0b                	jae    f010623b <__umoddi3+0x11b>
f0106230:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106234:	1b 14 24             	sbb    (%esp),%edx
f0106237:	89 d1                	mov    %edx,%ecx
f0106239:	89 c3                	mov    %eax,%ebx
f010623b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010623f:	29 da                	sub    %ebx,%edx
f0106241:	19 ce                	sbb    %ecx,%esi
f0106243:	89 f9                	mov    %edi,%ecx
f0106245:	89 f0                	mov    %esi,%eax
f0106247:	d3 e0                	shl    %cl,%eax
f0106249:	89 e9                	mov    %ebp,%ecx
f010624b:	d3 ea                	shr    %cl,%edx
f010624d:	89 e9                	mov    %ebp,%ecx
f010624f:	d3 ee                	shr    %cl,%esi
f0106251:	09 d0                	or     %edx,%eax
f0106253:	89 f2                	mov    %esi,%edx
f0106255:	83 c4 1c             	add    $0x1c,%esp
f0106258:	5b                   	pop    %ebx
f0106259:	5e                   	pop    %esi
f010625a:	5f                   	pop    %edi
f010625b:	5d                   	pop    %ebp
f010625c:	c3                   	ret    
f010625d:	8d 76 00             	lea    0x0(%esi),%esi
f0106260:	29 f9                	sub    %edi,%ecx
f0106262:	19 d6                	sbb    %edx,%esi
f0106264:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010626c:	e9 18 ff ff ff       	jmp    f0106189 <__umoddi3+0x69>
