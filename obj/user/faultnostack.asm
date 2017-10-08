
obj/user/faultnostack.debug：     文件格式 elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ad 04 00 00       	call   800552 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 ca 1e 80 00       	push   $0x801eca
  80011e:	6a 23                	push   $0x23
  800120:	68 e7 1e 80 00       	push   $0x801ee7
  800125:	e8 47 0f 00 00       	call   801071 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 ca 1e 80 00       	push   $0x801eca
  80019f:	6a 23                	push   $0x23
  8001a1:	68 e7 1e 80 00       	push   $0x801ee7
  8001a6:	e8 c6 0e 00 00       	call   801071 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 ca 1e 80 00       	push   $0x801eca
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 e7 1e 80 00       	push   $0x801ee7
  8001e8:	e8 84 0e 00 00       	call   801071 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 ca 1e 80 00       	push   $0x801eca
  800223:	6a 23                	push   $0x23
  800225:	68 e7 1e 80 00       	push   $0x801ee7
  80022a:	e8 42 0e 00 00       	call   801071 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 ca 1e 80 00       	push   $0x801eca
  800265:	6a 23                	push   $0x23
  800267:	68 e7 1e 80 00       	push   $0x801ee7
  80026c:	e8 00 0e 00 00       	call   801071 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 ca 1e 80 00       	push   $0x801eca
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 e7 1e 80 00       	push   $0x801ee7
  8002ae:	e8 be 0d 00 00       	call   801071 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 ca 1e 80 00       	push   $0x801eca
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 e7 1e 80 00       	push   $0x801ee7
  8002f0:	e8 7c 0d 00 00       	call   801071 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 ca 1e 80 00       	push   $0x801eca
  80034d:	6a 23                	push   $0x23
  80034f:	68 e7 1e 80 00       	push   $0x801ee7
  800354:	e8 18 0d 00 00       	call   801071 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  80036c:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  80036e:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  800372:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  800376:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  800377:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  800379:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  80037e:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  80037f:	58                   	pop    %eax
	popal 				// pop utf_regs 
  800380:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  800381:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  800384:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  800385:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800386:	c3                   	ret    

00800387 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	05 00 00 00 30       	add    $0x30000000,%eax
  800392:	c1 e8 0c             	shr    $0xc,%eax
}
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	c1 ea 16             	shr    $0x16,%edx
  8003be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c5:	f6 c2 01             	test   $0x1,%dl
  8003c8:	74 11                	je     8003db <fd_alloc+0x2d>
  8003ca:	89 c2                	mov    %eax,%edx
  8003cc:	c1 ea 0c             	shr    $0xc,%edx
  8003cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d6:	f6 c2 01             	test   $0x1,%dl
  8003d9:	75 09                	jne    8003e4 <fd_alloc+0x36>
			*fd_store = fd;
  8003db:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e2:	eb 17                	jmp    8003fb <fd_alloc+0x4d>
  8003e4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ee:	75 c9                	jne    8003b9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800403:	83 f8 1f             	cmp    $0x1f,%eax
  800406:	77 36                	ja     80043e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800408:	c1 e0 0c             	shl    $0xc,%eax
  80040b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 16             	shr    $0x16,%edx
  800415:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	74 24                	je     800445 <fd_lookup+0x48>
  800421:	89 c2                	mov    %eax,%edx
  800423:	c1 ea 0c             	shr    $0xc,%edx
  800426:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042d:	f6 c2 01             	test   $0x1,%dl
  800430:	74 1a                	je     80044c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800432:	8b 55 0c             	mov    0xc(%ebp),%edx
  800435:	89 02                	mov    %eax,(%edx)
	return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 13                	jmp    800451 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800443:	eb 0c                	jmp    800451 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044a:	eb 05                	jmp    800451 <fd_lookup+0x54>
  80044c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800451:	5d                   	pop    %ebp
  800452:	c3                   	ret    

00800453 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045c:	ba 74 1f 80 00       	mov    $0x801f74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	eb 13                	jmp    800476 <dev_lookup+0x23>
  800463:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800466:	39 08                	cmp    %ecx,(%eax)
  800468:	75 0c                	jne    800476 <dev_lookup+0x23>
			*dev = devtab[i];
  80046a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	eb 2e                	jmp    8004a4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800476:	8b 02                	mov    (%edx),%eax
  800478:	85 c0                	test   %eax,%eax
  80047a:	75 e7                	jne    800463 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047c:	a1 04 40 80 00       	mov    0x804004,%eax
  800481:	8b 40 48             	mov    0x48(%eax),%eax
  800484:	83 ec 04             	sub    $0x4,%esp
  800487:	51                   	push   %ecx
  800488:	50                   	push   %eax
  800489:	68 f8 1e 80 00       	push   $0x801ef8
  80048e:	e8 b7 0c 00 00       	call   80114a <cprintf>
	*dev = 0;
  800493:	8b 45 0c             	mov    0xc(%ebp),%eax
  800496:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	56                   	push   %esi
  8004aa:	53                   	push   %ebx
  8004ab:	83 ec 10             	sub    $0x10,%esp
  8004ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b7:	50                   	push   %eax
  8004b8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004be:	c1 e8 0c             	shr    $0xc,%eax
  8004c1:	50                   	push   %eax
  8004c2:	e8 36 ff ff ff       	call   8003fd <fd_lookup>
  8004c7:	83 c4 08             	add    $0x8,%esp
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	78 05                	js     8004d3 <fd_close+0x2d>
	    || fd != fd2)
  8004ce:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004d1:	74 0c                	je     8004df <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d3:	84 db                	test   %bl,%bl
  8004d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004da:	0f 44 c2             	cmove  %edx,%eax
  8004dd:	eb 41                	jmp    800520 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e5:	50                   	push   %eax
  8004e6:	ff 36                	pushl  (%esi)
  8004e8:	e8 66 ff ff ff       	call   800453 <dev_lookup>
  8004ed:	89 c3                	mov    %eax,%ebx
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	85 c0                	test   %eax,%eax
  8004f4:	78 1a                	js     800510 <fd_close+0x6a>
		if (dev->dev_close)
  8004f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004fc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800501:	85 c0                	test   %eax,%eax
  800503:	74 0b                	je     800510 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800505:	83 ec 0c             	sub    $0xc,%esp
  800508:	56                   	push   %esi
  800509:	ff d0                	call   *%eax
  80050b:	89 c3                	mov    %eax,%ebx
  80050d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	56                   	push   %esi
  800514:	6a 00                	push   $0x0
  800516:	e8 da fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	89 d8                	mov    %ebx,%eax
}
  800520:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800523:	5b                   	pop    %ebx
  800524:	5e                   	pop    %esi
  800525:	5d                   	pop    %ebp
  800526:	c3                   	ret    

00800527 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800530:	50                   	push   %eax
  800531:	ff 75 08             	pushl  0x8(%ebp)
  800534:	e8 c4 fe ff ff       	call   8003fd <fd_lookup>
  800539:	83 c4 08             	add    $0x8,%esp
  80053c:	85 c0                	test   %eax,%eax
  80053e:	78 10                	js     800550 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	6a 01                	push   $0x1
  800545:	ff 75 f4             	pushl  -0xc(%ebp)
  800548:	e8 59 ff ff ff       	call   8004a6 <fd_close>
  80054d:	83 c4 10             	add    $0x10,%esp
}
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <close_all>:

void
close_all(void)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	53                   	push   %ebx
  800556:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800559:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	53                   	push   %ebx
  800562:	e8 c0 ff ff ff       	call   800527 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800567:	83 c3 01             	add    $0x1,%ebx
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	83 fb 20             	cmp    $0x20,%ebx
  800570:	75 ec                	jne    80055e <close_all+0xc>
		close(i);
}
  800572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800575:	c9                   	leave  
  800576:	c3                   	ret    

00800577 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	57                   	push   %edi
  80057b:	56                   	push   %esi
  80057c:	53                   	push   %ebx
  80057d:	83 ec 2c             	sub    $0x2c,%esp
  800580:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800583:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800586:	50                   	push   %eax
  800587:	ff 75 08             	pushl  0x8(%ebp)
  80058a:	e8 6e fe ff ff       	call   8003fd <fd_lookup>
  80058f:	83 c4 08             	add    $0x8,%esp
  800592:	85 c0                	test   %eax,%eax
  800594:	0f 88 c1 00 00 00    	js     80065b <dup+0xe4>
		return r;
	close(newfdnum);
  80059a:	83 ec 0c             	sub    $0xc,%esp
  80059d:	56                   	push   %esi
  80059e:	e8 84 ff ff ff       	call   800527 <close>

	newfd = INDEX2FD(newfdnum);
  8005a3:	89 f3                	mov    %esi,%ebx
  8005a5:	c1 e3 0c             	shl    $0xc,%ebx
  8005a8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ae:	83 c4 04             	add    $0x4,%esp
  8005b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b4:	e8 de fd ff ff       	call   800397 <fd2data>
  8005b9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005bb:	89 1c 24             	mov    %ebx,(%esp)
  8005be:	e8 d4 fd ff ff       	call   800397 <fd2data>
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c9:	89 f8                	mov    %edi,%eax
  8005cb:	c1 e8 16             	shr    $0x16,%eax
  8005ce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d5:	a8 01                	test   $0x1,%al
  8005d7:	74 37                	je     800610 <dup+0x99>
  8005d9:	89 f8                	mov    %edi,%eax
  8005db:	c1 e8 0c             	shr    $0xc,%eax
  8005de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e5:	f6 c2 01             	test   $0x1,%dl
  8005e8:	74 26                	je     800610 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f9:	50                   	push   %eax
  8005fa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fd:	6a 00                	push   $0x0
  8005ff:	57                   	push   %edi
  800600:	6a 00                	push   $0x0
  800602:	e8 ac fb ff ff       	call   8001b3 <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
  80060c:	85 c0                	test   %eax,%eax
  80060e:	78 2e                	js     80063e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800610:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800613:	89 d0                	mov    %edx,%eax
  800615:	c1 e8 0c             	shr    $0xc,%eax
  800618:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061f:	83 ec 0c             	sub    $0xc,%esp
  800622:	25 07 0e 00 00       	and    $0xe07,%eax
  800627:	50                   	push   %eax
  800628:	53                   	push   %ebx
  800629:	6a 00                	push   $0x0
  80062b:	52                   	push   %edx
  80062c:	6a 00                	push   $0x0
  80062e:	e8 80 fb ff ff       	call   8001b3 <sys_page_map>
  800633:	89 c7                	mov    %eax,%edi
  800635:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800638:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063a:	85 ff                	test   %edi,%edi
  80063c:	79 1d                	jns    80065b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	53                   	push   %ebx
  800642:	6a 00                	push   $0x0
  800644:	e8 ac fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064f:	6a 00                	push   $0x0
  800651:	e8 9f fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	89 f8                	mov    %edi,%eax
}
  80065b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	5f                   	pop    %edi
  800661:	5d                   	pop    %ebp
  800662:	c3                   	ret    

00800663 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
  800666:	53                   	push   %ebx
  800667:	83 ec 14             	sub    $0x14,%esp
  80066a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800670:	50                   	push   %eax
  800671:	53                   	push   %ebx
  800672:	e8 86 fd ff ff       	call   8003fd <fd_lookup>
  800677:	83 c4 08             	add    $0x8,%esp
  80067a:	89 c2                	mov    %eax,%edx
  80067c:	85 c0                	test   %eax,%eax
  80067e:	78 6d                	js     8006ed <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800686:	50                   	push   %eax
  800687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80068a:	ff 30                	pushl  (%eax)
  80068c:	e8 c2 fd ff ff       	call   800453 <dev_lookup>
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	85 c0                	test   %eax,%eax
  800696:	78 4c                	js     8006e4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800698:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80069b:	8b 42 08             	mov    0x8(%edx),%eax
  80069e:	83 e0 03             	and    $0x3,%eax
  8006a1:	83 f8 01             	cmp    $0x1,%eax
  8006a4:	75 21                	jne    8006c7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8006ab:	8b 40 48             	mov    0x48(%eax),%eax
  8006ae:	83 ec 04             	sub    $0x4,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	50                   	push   %eax
  8006b3:	68 39 1f 80 00       	push   $0x801f39
  8006b8:	e8 8d 0a 00 00       	call   80114a <cprintf>
		return -E_INVAL;
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c5:	eb 26                	jmp    8006ed <read+0x8a>
	}
	if (!dev->dev_read)
  8006c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ca:	8b 40 08             	mov    0x8(%eax),%eax
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	74 17                	je     8006e8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d1:	83 ec 04             	sub    $0x4,%esp
  8006d4:	ff 75 10             	pushl  0x10(%ebp)
  8006d7:	ff 75 0c             	pushl  0xc(%ebp)
  8006da:	52                   	push   %edx
  8006db:	ff d0                	call   *%eax
  8006dd:	89 c2                	mov    %eax,%edx
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	eb 09                	jmp    8006ed <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	eb 05                	jmp    8006ed <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ed:	89 d0                	mov    %edx,%eax
  8006ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 0c             	sub    $0xc,%esp
  8006fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800700:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800703:	bb 00 00 00 00       	mov    $0x0,%ebx
  800708:	eb 21                	jmp    80072b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80070a:	83 ec 04             	sub    $0x4,%esp
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	29 d8                	sub    %ebx,%eax
  800711:	50                   	push   %eax
  800712:	89 d8                	mov    %ebx,%eax
  800714:	03 45 0c             	add    0xc(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	57                   	push   %edi
  800719:	e8 45 ff ff ff       	call   800663 <read>
		if (m < 0)
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	85 c0                	test   %eax,%eax
  800723:	78 10                	js     800735 <readn+0x41>
			return m;
		if (m == 0)
  800725:	85 c0                	test   %eax,%eax
  800727:	74 0a                	je     800733 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800729:	01 c3                	add    %eax,%ebx
  80072b:	39 f3                	cmp    %esi,%ebx
  80072d:	72 db                	jb     80070a <readn+0x16>
  80072f:	89 d8                	mov    %ebx,%eax
  800731:	eb 02                	jmp    800735 <readn+0x41>
  800733:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800735:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800738:	5b                   	pop    %ebx
  800739:	5e                   	pop    %esi
  80073a:	5f                   	pop    %edi
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	53                   	push   %ebx
  800741:	83 ec 14             	sub    $0x14,%esp
  800744:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800747:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80074a:	50                   	push   %eax
  80074b:	53                   	push   %ebx
  80074c:	e8 ac fc ff ff       	call   8003fd <fd_lookup>
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	89 c2                	mov    %eax,%edx
  800756:	85 c0                	test   %eax,%eax
  800758:	78 68                	js     8007c2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800760:	50                   	push   %eax
  800761:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800764:	ff 30                	pushl  (%eax)
  800766:	e8 e8 fc ff ff       	call   800453 <dev_lookup>
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	85 c0                	test   %eax,%eax
  800770:	78 47                	js     8007b9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800775:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800779:	75 21                	jne    80079c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80077b:	a1 04 40 80 00       	mov    0x804004,%eax
  800780:	8b 40 48             	mov    0x48(%eax),%eax
  800783:	83 ec 04             	sub    $0x4,%esp
  800786:	53                   	push   %ebx
  800787:	50                   	push   %eax
  800788:	68 55 1f 80 00       	push   $0x801f55
  80078d:	e8 b8 09 00 00       	call   80114a <cprintf>
		return -E_INVAL;
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80079a:	eb 26                	jmp    8007c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079f:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a2:	85 d2                	test   %edx,%edx
  8007a4:	74 17                	je     8007bd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a6:	83 ec 04             	sub    $0x4,%esp
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	50                   	push   %eax
  8007b0:	ff d2                	call   *%edx
  8007b2:	89 c2                	mov    %eax,%edx
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	eb 09                	jmp    8007c2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b9:	89 c2                	mov    %eax,%edx
  8007bb:	eb 05                	jmp    8007c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c2:	89 d0                	mov    %edx,%eax
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d2:	50                   	push   %eax
  8007d3:	ff 75 08             	pushl  0x8(%ebp)
  8007d6:	e8 22 fc ff ff       	call   8003fd <fd_lookup>
  8007db:	83 c4 08             	add    $0x8,%esp
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 0e                	js     8007f0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 14             	sub    $0x14,%esp
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ff:	50                   	push   %eax
  800800:	53                   	push   %ebx
  800801:	e8 f7 fb ff ff       	call   8003fd <fd_lookup>
  800806:	83 c4 08             	add    $0x8,%esp
  800809:	89 c2                	mov    %eax,%edx
  80080b:	85 c0                	test   %eax,%eax
  80080d:	78 65                	js     800874 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800815:	50                   	push   %eax
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	ff 30                	pushl  (%eax)
  80081b:	e8 33 fc ff ff       	call   800453 <dev_lookup>
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	85 c0                	test   %eax,%eax
  800825:	78 44                	js     80086b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800827:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082e:	75 21                	jne    800851 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800830:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800835:	8b 40 48             	mov    0x48(%eax),%eax
  800838:	83 ec 04             	sub    $0x4,%esp
  80083b:	53                   	push   %ebx
  80083c:	50                   	push   %eax
  80083d:	68 18 1f 80 00       	push   $0x801f18
  800842:	e8 03 09 00 00       	call   80114a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084f:	eb 23                	jmp    800874 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800851:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800854:	8b 52 18             	mov    0x18(%edx),%edx
  800857:	85 d2                	test   %edx,%edx
  800859:	74 14                	je     80086f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	50                   	push   %eax
  800862:	ff d2                	call   *%edx
  800864:	89 c2                	mov    %eax,%edx
  800866:	83 c4 10             	add    $0x10,%esp
  800869:	eb 09                	jmp    800874 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	eb 05                	jmp    800874 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800874:	89 d0                	mov    %edx,%eax
  800876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	83 ec 14             	sub    $0x14,%esp
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800885:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800888:	50                   	push   %eax
  800889:	ff 75 08             	pushl  0x8(%ebp)
  80088c:	e8 6c fb ff ff       	call   8003fd <fd_lookup>
  800891:	83 c4 08             	add    $0x8,%esp
  800894:	89 c2                	mov    %eax,%edx
  800896:	85 c0                	test   %eax,%eax
  800898:	78 58                	js     8008f2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a0:	50                   	push   %eax
  8008a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a4:	ff 30                	pushl  (%eax)
  8008a6:	e8 a8 fb ff ff       	call   800453 <dev_lookup>
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 37                	js     8008e9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b9:	74 32                	je     8008ed <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c5:	00 00 00 
	stat->st_isdir = 0;
  8008c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cf:	00 00 00 
	stat->st_dev = dev;
  8008d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	53                   	push   %ebx
  8008dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8008df:	ff 50 14             	call   *0x14(%eax)
  8008e2:	89 c2                	mov    %eax,%edx
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	eb 09                	jmp    8008f2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e9:	89 c2                	mov    %eax,%edx
  8008eb:	eb 05                	jmp    8008f2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    

008008f9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	6a 00                	push   $0x0
  800903:	ff 75 08             	pushl  0x8(%ebp)
  800906:	e8 e3 01 00 00       	call   800aee <open>
  80090b:	89 c3                	mov    %eax,%ebx
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	85 c0                	test   %eax,%eax
  800912:	78 1b                	js     80092f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	ff 75 0c             	pushl  0xc(%ebp)
  80091a:	50                   	push   %eax
  80091b:	e8 5b ff ff ff       	call   80087b <fstat>
  800920:	89 c6                	mov    %eax,%esi
	close(fd);
  800922:	89 1c 24             	mov    %ebx,(%esp)
  800925:	e8 fd fb ff ff       	call   800527 <close>
	return r;
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	89 f0                	mov    %esi,%eax
}
  80092f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	89 c6                	mov    %eax,%esi
  80093d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800946:	75 12                	jne    80095a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800948:	83 ec 0c             	sub    $0xc,%esp
  80094b:	6a 01                	push   $0x1
  80094d:	e8 4e 12 00 00       	call   801ba0 <ipc_find_env>
  800952:	a3 00 40 80 00       	mov    %eax,0x804000
  800957:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80095a:	6a 07                	push   $0x7
  80095c:	68 00 50 80 00       	push   $0x805000
  800961:	56                   	push   %esi
  800962:	ff 35 00 40 80 00    	pushl  0x804000
  800968:	e8 df 11 00 00       	call   801b4c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096d:	83 c4 0c             	add    $0xc,%esp
  800970:	6a 00                	push   $0x0
  800972:	53                   	push   %ebx
  800973:	6a 00                	push   $0x0
  800975:	e8 60 11 00 00       	call   801ada <ipc_recv>
}
  80097a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 40 0c             	mov    0xc(%eax),%eax
  80098d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
  800995:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
  80099f:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a4:	e8 8d ff ff ff       	call   800936 <fsipc>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c6:	e8 6b ff ff ff       	call   800936 <fsipc>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	53                   	push   %ebx
  8009d1:	83 ec 04             	sub    $0x4,%esp
  8009d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 40 0c             	mov    0xc(%eax),%eax
  8009dd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ec:	e8 45 ff ff ff       	call   800936 <fsipc>
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	78 2c                	js     800a21 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f5:	83 ec 08             	sub    $0x8,%esp
  8009f8:	68 00 50 80 00       	push   $0x805000
  8009fd:	53                   	push   %ebx
  8009fe:	e8 4b 0d 00 00       	call   80174e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a03:	a1 80 50 80 00       	mov    0x805080,%eax
  800a08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a13:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a19:	83 c4 10             	add    $0x10,%esp
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	83 ec 0c             	sub    $0xc,%esp
  800a2c:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a2f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a34:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a39:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a42:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a48:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a4d:	50                   	push   %eax
  800a4e:	ff 75 0c             	pushl  0xc(%ebp)
  800a51:	68 08 50 80 00       	push   $0x805008
  800a56:	e8 85 0e 00 00       	call   8018e0 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  800a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a60:	b8 04 00 00 00       	mov    $0x4,%eax
  800a65:	e8 cc fe ff ff       	call   800936 <fsipc>
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 40 0c             	mov    0xc(%eax),%eax
  800a7a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	e8 a2 fe ff ff       	call   800936 <fsipc>
  800a94:	89 c3                	mov    %eax,%ebx
  800a96:	85 c0                	test   %eax,%eax
  800a98:	78 4b                	js     800ae5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a9a:	39 c6                	cmp    %eax,%esi
  800a9c:	73 16                	jae    800ab4 <devfile_read+0x48>
  800a9e:	68 84 1f 80 00       	push   $0x801f84
  800aa3:	68 8b 1f 80 00       	push   $0x801f8b
  800aa8:	6a 7c                	push   $0x7c
  800aaa:	68 a0 1f 80 00       	push   $0x801fa0
  800aaf:	e8 bd 05 00 00       	call   801071 <_panic>
	assert(r <= PGSIZE);
  800ab4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab9:	7e 16                	jle    800ad1 <devfile_read+0x65>
  800abb:	68 ab 1f 80 00       	push   $0x801fab
  800ac0:	68 8b 1f 80 00       	push   $0x801f8b
  800ac5:	6a 7d                	push   $0x7d
  800ac7:	68 a0 1f 80 00       	push   $0x801fa0
  800acc:	e8 a0 05 00 00       	call   801071 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad1:	83 ec 04             	sub    $0x4,%esp
  800ad4:	50                   	push   %eax
  800ad5:	68 00 50 80 00       	push   $0x805000
  800ada:	ff 75 0c             	pushl  0xc(%ebp)
  800add:	e8 fe 0d 00 00       	call   8018e0 <memmove>
	return r;
  800ae2:	83 c4 10             	add    $0x10,%esp
}
  800ae5:	89 d8                	mov    %ebx,%eax
  800ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	53                   	push   %ebx
  800af2:	83 ec 20             	sub    $0x20,%esp
  800af5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af8:	53                   	push   %ebx
  800af9:	e8 17 0c 00 00       	call   801715 <strlen>
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b06:	7f 67                	jg     800b6f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b08:	83 ec 0c             	sub    $0xc,%esp
  800b0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0e:	50                   	push   %eax
  800b0f:	e8 9a f8 ff ff       	call   8003ae <fd_alloc>
  800b14:	83 c4 10             	add    $0x10,%esp
		return r;
  800b17:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	78 57                	js     800b74 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b1d:	83 ec 08             	sub    $0x8,%esp
  800b20:	53                   	push   %ebx
  800b21:	68 00 50 80 00       	push   $0x805000
  800b26:	e8 23 0c 00 00       	call   80174e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b33:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b36:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3b:	e8 f6 fd ff ff       	call   800936 <fsipc>
  800b40:	89 c3                	mov    %eax,%ebx
  800b42:	83 c4 10             	add    $0x10,%esp
  800b45:	85 c0                	test   %eax,%eax
  800b47:	79 14                	jns    800b5d <open+0x6f>
		fd_close(fd, 0);
  800b49:	83 ec 08             	sub    $0x8,%esp
  800b4c:	6a 00                	push   $0x0
  800b4e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b51:	e8 50 f9 ff ff       	call   8004a6 <fd_close>
		return r;
  800b56:	83 c4 10             	add    $0x10,%esp
  800b59:	89 da                	mov    %ebx,%edx
  800b5b:	eb 17                	jmp    800b74 <open+0x86>
	}

	return fd2num(fd);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	ff 75 f4             	pushl  -0xc(%ebp)
  800b63:	e8 1f f8 ff ff       	call   800387 <fd2num>
  800b68:	89 c2                	mov    %eax,%edx
  800b6a:	83 c4 10             	add    $0x10,%esp
  800b6d:	eb 05                	jmp    800b74 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b6f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b74:	89 d0                	mov    %edx,%eax
  800b76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 08 00 00 00       	mov    $0x8,%eax
  800b8b:	e8 a6 fd ff ff       	call   800936 <fsipc>
}
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	ff 75 08             	pushl  0x8(%ebp)
  800ba0:	e8 f2 f7 ff ff       	call   800397 <fd2data>
  800ba5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ba7:	83 c4 08             	add    $0x8,%esp
  800baa:	68 b7 1f 80 00       	push   $0x801fb7
  800baf:	53                   	push   %ebx
  800bb0:	e8 99 0b 00 00       	call   80174e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bb5:	8b 46 04             	mov    0x4(%esi),%eax
  800bb8:	2b 06                	sub    (%esi),%eax
  800bba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bc0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bc7:	00 00 00 
	stat->st_dev = &devpipe;
  800bca:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bd1:	30 80 00 
	return 0;
}
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bea:	53                   	push   %ebx
  800beb:	6a 00                	push   $0x0
  800bed:	e8 03 f6 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bf2:	89 1c 24             	mov    %ebx,(%esp)
  800bf5:	e8 9d f7 ff ff       	call   800397 <fd2data>
  800bfa:	83 c4 08             	add    $0x8,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 00                	push   $0x0
  800c00:	e8 f0 f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800c05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 1c             	sub    $0x1c,%esp
  800c13:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c16:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c18:	a1 04 40 80 00       	mov    0x804004,%eax
  800c1d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	ff 75 e0             	pushl  -0x20(%ebp)
  800c26:	e8 ae 0f 00 00       	call   801bd9 <pageref>
  800c2b:	89 c3                	mov    %eax,%ebx
  800c2d:	89 3c 24             	mov    %edi,(%esp)
  800c30:	e8 a4 0f 00 00       	call   801bd9 <pageref>
  800c35:	83 c4 10             	add    $0x10,%esp
  800c38:	39 c3                	cmp    %eax,%ebx
  800c3a:	0f 94 c1             	sete   %cl
  800c3d:	0f b6 c9             	movzbl %cl,%ecx
  800c40:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c43:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c49:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c4c:	39 ce                	cmp    %ecx,%esi
  800c4e:	74 1b                	je     800c6b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c50:	39 c3                	cmp    %eax,%ebx
  800c52:	75 c4                	jne    800c18 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c54:	8b 42 58             	mov    0x58(%edx),%eax
  800c57:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c5a:	50                   	push   %eax
  800c5b:	56                   	push   %esi
  800c5c:	68 be 1f 80 00       	push   $0x801fbe
  800c61:	e8 e4 04 00 00       	call   80114a <cprintf>
  800c66:	83 c4 10             	add    $0x10,%esp
  800c69:	eb ad                	jmp    800c18 <_pipeisclosed+0xe>
	}
}
  800c6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 28             	sub    $0x28,%esp
  800c7f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c82:	56                   	push   %esi
  800c83:	e8 0f f7 ff ff       	call   800397 <fd2data>
  800c88:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c8a:	83 c4 10             	add    $0x10,%esp
  800c8d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c92:	eb 4b                	jmp    800cdf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c94:	89 da                	mov    %ebx,%edx
  800c96:	89 f0                	mov    %esi,%eax
  800c98:	e8 6d ff ff ff       	call   800c0a <_pipeisclosed>
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	75 48                	jne    800ce9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ca1:	e8 ab f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ca6:	8b 43 04             	mov    0x4(%ebx),%eax
  800ca9:	8b 0b                	mov    (%ebx),%ecx
  800cab:	8d 51 20             	lea    0x20(%ecx),%edx
  800cae:	39 d0                	cmp    %edx,%eax
  800cb0:	73 e2                	jae    800c94 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cbc:	89 c2                	mov    %eax,%edx
  800cbe:	c1 fa 1f             	sar    $0x1f,%edx
  800cc1:	89 d1                	mov    %edx,%ecx
  800cc3:	c1 e9 1b             	shr    $0x1b,%ecx
  800cc6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc9:	83 e2 1f             	and    $0x1f,%edx
  800ccc:	29 ca                	sub    %ecx,%edx
  800cce:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cd2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cd6:	83 c0 01             	add    $0x1,%eax
  800cd9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cdc:	83 c7 01             	add    $0x1,%edi
  800cdf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce2:	75 c2                	jne    800ca6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ce4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce7:	eb 05                	jmp    800cee <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 18             	sub    $0x18,%esp
  800cff:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d02:	57                   	push   %edi
  800d03:	e8 8f f6 ff ff       	call   800397 <fd2data>
  800d08:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0a:	83 c4 10             	add    $0x10,%esp
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	eb 3d                	jmp    800d51 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d14:	85 db                	test   %ebx,%ebx
  800d16:	74 04                	je     800d1c <devpipe_read+0x26>
				return i;
  800d18:	89 d8                	mov    %ebx,%eax
  800d1a:	eb 44                	jmp    800d60 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d1c:	89 f2                	mov    %esi,%edx
  800d1e:	89 f8                	mov    %edi,%eax
  800d20:	e8 e5 fe ff ff       	call   800c0a <_pipeisclosed>
  800d25:	85 c0                	test   %eax,%eax
  800d27:	75 32                	jne    800d5b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d29:	e8 23 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d2e:	8b 06                	mov    (%esi),%eax
  800d30:	3b 46 04             	cmp    0x4(%esi),%eax
  800d33:	74 df                	je     800d14 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d35:	99                   	cltd   
  800d36:	c1 ea 1b             	shr    $0x1b,%edx
  800d39:	01 d0                	add    %edx,%eax
  800d3b:	83 e0 1f             	and    $0x1f,%eax
  800d3e:	29 d0                	sub    %edx,%eax
  800d40:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d4b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d4e:	83 c3 01             	add    $0x1,%ebx
  800d51:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d54:	75 d8                	jne    800d2e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d56:	8b 45 10             	mov    0x10(%ebp),%eax
  800d59:	eb 05                	jmp    800d60 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d5b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d73:	50                   	push   %eax
  800d74:	e8 35 f6 ff ff       	call   8003ae <fd_alloc>
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	89 c2                	mov    %eax,%edx
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	0f 88 2c 01 00 00    	js     800eb2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	68 07 04 00 00       	push   $0x407
  800d8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d91:	6a 00                	push   $0x0
  800d93:	e8 d8 f3 ff ff       	call   800170 <sys_page_alloc>
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	89 c2                	mov    %eax,%edx
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	0f 88 0d 01 00 00    	js     800eb2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dab:	50                   	push   %eax
  800dac:	e8 fd f5 ff ff       	call   8003ae <fd_alloc>
  800db1:	89 c3                	mov    %eax,%ebx
  800db3:	83 c4 10             	add    $0x10,%esp
  800db6:	85 c0                	test   %eax,%eax
  800db8:	0f 88 e2 00 00 00    	js     800ea0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbe:	83 ec 04             	sub    $0x4,%esp
  800dc1:	68 07 04 00 00       	push   $0x407
  800dc6:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc9:	6a 00                	push   $0x0
  800dcb:	e8 a0 f3 ff ff       	call   800170 <sys_page_alloc>
  800dd0:	89 c3                	mov    %eax,%ebx
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	0f 88 c3 00 00 00    	js     800ea0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ddd:	83 ec 0c             	sub    $0xc,%esp
  800de0:	ff 75 f4             	pushl  -0xc(%ebp)
  800de3:	e8 af f5 ff ff       	call   800397 <fd2data>
  800de8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dea:	83 c4 0c             	add    $0xc,%esp
  800ded:	68 07 04 00 00       	push   $0x407
  800df2:	50                   	push   %eax
  800df3:	6a 00                	push   $0x0
  800df5:	e8 76 f3 ff ff       	call   800170 <sys_page_alloc>
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	0f 88 89 00 00 00    	js     800e90 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0d:	e8 85 f5 ff ff       	call   800397 <fd2data>
  800e12:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e19:	50                   	push   %eax
  800e1a:	6a 00                	push   $0x0
  800e1c:	56                   	push   %esi
  800e1d:	6a 00                	push   $0x0
  800e1f:	e8 8f f3 ff ff       	call   8001b3 <sys_page_map>
  800e24:	89 c3                	mov    %eax,%ebx
  800e26:	83 c4 20             	add    $0x20,%esp
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	78 55                	js     800e82 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e36:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e42:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e50:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e57:	83 ec 0c             	sub    $0xc,%esp
  800e5a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5d:	e8 25 f5 ff ff       	call   800387 <fd2num>
  800e62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e65:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e67:	83 c4 04             	add    $0x4,%esp
  800e6a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6d:	e8 15 f5 ff ff       	call   800387 <fd2num>
  800e72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e75:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	eb 30                	jmp    800eb2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	56                   	push   %esi
  800e86:	6a 00                	push   $0x0
  800e88:	e8 68 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e8d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e90:	83 ec 08             	sub    $0x8,%esp
  800e93:	ff 75 f0             	pushl  -0x10(%ebp)
  800e96:	6a 00                	push   $0x0
  800e98:	e8 58 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e9d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ea0:	83 ec 08             	sub    $0x8,%esp
  800ea3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 48 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eb2:	89 d0                	mov    %edx,%eax
  800eb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec4:	50                   	push   %eax
  800ec5:	ff 75 08             	pushl  0x8(%ebp)
  800ec8:	e8 30 f5 ff ff       	call   8003fd <fd_lookup>
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	78 18                	js     800eec <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ed4:	83 ec 0c             	sub    $0xc,%esp
  800ed7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eda:	e8 b8 f4 ff ff       	call   800397 <fd2data>
	return _pipeisclosed(fd, p);
  800edf:	89 c2                	mov    %eax,%edx
  800ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee4:	e8 21 fd ff ff       	call   800c0a <_pipeisclosed>
  800ee9:	83 c4 10             	add    $0x10,%esp
}
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800efe:	68 d6 1f 80 00       	push   $0x801fd6
  800f03:	ff 75 0c             	pushl  0xc(%ebp)
  800f06:	e8 43 08 00 00       	call   80174e <strcpy>
	return 0;
}
  800f0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f10:	c9                   	leave  
  800f11:	c3                   	ret    

00800f12 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f23:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f29:	eb 2d                	jmp    800f58 <devcons_write+0x46>
		m = n - tot;
  800f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f30:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f33:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f38:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f3b:	83 ec 04             	sub    $0x4,%esp
  800f3e:	53                   	push   %ebx
  800f3f:	03 45 0c             	add    0xc(%ebp),%eax
  800f42:	50                   	push   %eax
  800f43:	57                   	push   %edi
  800f44:	e8 97 09 00 00       	call   8018e0 <memmove>
		sys_cputs(buf, m);
  800f49:	83 c4 08             	add    $0x8,%esp
  800f4c:	53                   	push   %ebx
  800f4d:	57                   	push   %edi
  800f4e:	e8 61 f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f53:	01 de                	add    %ebx,%esi
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	89 f0                	mov    %esi,%eax
  800f5a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f5d:	72 cc                	jb     800f2b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f62:	5b                   	pop    %ebx
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 08             	sub    $0x8,%esp
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f76:	74 2a                	je     800fa2 <devcons_read+0x3b>
  800f78:	eb 05                	jmp    800f7f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f7a:	e8 d2 f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f7f:	e8 4e f1 ff ff       	call   8000d2 <sys_cgetc>
  800f84:	85 c0                	test   %eax,%eax
  800f86:	74 f2                	je     800f7a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	78 16                	js     800fa2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f8c:	83 f8 04             	cmp    $0x4,%eax
  800f8f:	74 0c                	je     800f9d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f94:	88 02                	mov    %al,(%edx)
	return 1;
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	eb 05                	jmp    800fa2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800faa:	8b 45 08             	mov    0x8(%ebp),%eax
  800fad:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fb0:	6a 01                	push   $0x1
  800fb2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb5:	50                   	push   %eax
  800fb6:	e8 f9 f0 ff ff       	call   8000b4 <sys_cputs>
}
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <getchar>:

int
getchar(void)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fc6:	6a 01                	push   $0x1
  800fc8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 90 f6 ff ff       	call   800663 <read>
	if (r < 0)
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 0f                	js     800fe9 <getchar+0x29>
		return r;
	if (r < 1)
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	7e 06                	jle    800fe4 <getchar+0x24>
		return -E_EOF;
	return c;
  800fde:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fe2:	eb 05                	jmp    800fe9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fe4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	ff 75 08             	pushl  0x8(%ebp)
  800ff8:	e8 00 f4 ff ff       	call   8003fd <fd_lookup>
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	78 11                	js     801015 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801004:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801007:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100d:	39 10                	cmp    %edx,(%eax)
  80100f:	0f 94 c0             	sete   %al
  801012:	0f b6 c0             	movzbl %al,%eax
}
  801015:	c9                   	leave  
  801016:	c3                   	ret    

00801017 <opencons>:

int
opencons(void)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80101d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801020:	50                   	push   %eax
  801021:	e8 88 f3 ff ff       	call   8003ae <fd_alloc>
  801026:	83 c4 10             	add    $0x10,%esp
		return r;
  801029:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	78 3e                	js     80106d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	68 07 04 00 00       	push   $0x407
  801037:	ff 75 f4             	pushl  -0xc(%ebp)
  80103a:	6a 00                	push   $0x0
  80103c:	e8 2f f1 ff ff       	call   800170 <sys_page_alloc>
  801041:	83 c4 10             	add    $0x10,%esp
		return r;
  801044:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801046:	85 c0                	test   %eax,%eax
  801048:	78 23                	js     80106d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80104a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801050:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801053:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801058:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	50                   	push   %eax
  801063:	e8 1f f3 ff ff       	call   800387 <fd2num>
  801068:	89 c2                	mov    %eax,%edx
  80106a:	83 c4 10             	add    $0x10,%esp
}
  80106d:	89 d0                	mov    %edx,%eax
  80106f:	c9                   	leave  
  801070:	c3                   	ret    

00801071 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801076:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801079:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80107f:	e8 ae f0 ff ff       	call   800132 <sys_getenvid>
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	ff 75 0c             	pushl  0xc(%ebp)
  80108a:	ff 75 08             	pushl  0x8(%ebp)
  80108d:	56                   	push   %esi
  80108e:	50                   	push   %eax
  80108f:	68 e4 1f 80 00       	push   $0x801fe4
  801094:	e8 b1 00 00 00       	call   80114a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801099:	83 c4 18             	add    $0x18,%esp
  80109c:	53                   	push   %ebx
  80109d:	ff 75 10             	pushl  0x10(%ebp)
  8010a0:	e8 54 00 00 00       	call   8010f9 <vcprintf>
	cprintf("\n");
  8010a5:	c7 04 24 cf 1f 80 00 	movl   $0x801fcf,(%esp)
  8010ac:	e8 99 00 00 00       	call   80114a <cprintf>
  8010b1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010b4:	cc                   	int3   
  8010b5:	eb fd                	jmp    8010b4 <_panic+0x43>

008010b7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	53                   	push   %ebx
  8010bb:	83 ec 04             	sub    $0x4,%esp
  8010be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c1:	8b 13                	mov    (%ebx),%edx
  8010c3:	8d 42 01             	lea    0x1(%edx),%eax
  8010c6:	89 03                	mov    %eax,(%ebx)
  8010c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010cf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010d4:	75 1a                	jne    8010f0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	68 ff 00 00 00       	push   $0xff
  8010de:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e1:	50                   	push   %eax
  8010e2:	e8 cd ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8010e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ed:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010f0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f7:	c9                   	leave  
  8010f8:	c3                   	ret    

008010f9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801102:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801109:	00 00 00 
	b.cnt = 0;
  80110c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801113:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801116:	ff 75 0c             	pushl  0xc(%ebp)
  801119:	ff 75 08             	pushl  0x8(%ebp)
  80111c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801122:	50                   	push   %eax
  801123:	68 b7 10 80 00       	push   $0x8010b7
  801128:	e8 1a 01 00 00       	call   801247 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80112d:	83 c4 08             	add    $0x8,%esp
  801130:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801136:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80113c:	50                   	push   %eax
  80113d:	e8 72 ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801142:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801148:	c9                   	leave  
  801149:	c3                   	ret    

0080114a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801150:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801153:	50                   	push   %eax
  801154:	ff 75 08             	pushl  0x8(%ebp)
  801157:	e8 9d ff ff ff       	call   8010f9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80115c:	c9                   	leave  
  80115d:	c3                   	ret    

0080115e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	83 ec 1c             	sub    $0x1c,%esp
  801167:	89 c7                	mov    %eax,%edi
  801169:	89 d6                	mov    %edx,%esi
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
  80116e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801171:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801174:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801177:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80117a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801182:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801185:	39 d3                	cmp    %edx,%ebx
  801187:	72 05                	jb     80118e <printnum+0x30>
  801189:	39 45 10             	cmp    %eax,0x10(%ebp)
  80118c:	77 45                	ja     8011d3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80118e:	83 ec 0c             	sub    $0xc,%esp
  801191:	ff 75 18             	pushl  0x18(%ebp)
  801194:	8b 45 14             	mov    0x14(%ebp),%eax
  801197:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80119a:	53                   	push   %ebx
  80119b:	ff 75 10             	pushl  0x10(%ebp)
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011aa:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ad:	e8 6e 0a 00 00       	call   801c20 <__udivdi3>
  8011b2:	83 c4 18             	add    $0x18,%esp
  8011b5:	52                   	push   %edx
  8011b6:	50                   	push   %eax
  8011b7:	89 f2                	mov    %esi,%edx
  8011b9:	89 f8                	mov    %edi,%eax
  8011bb:	e8 9e ff ff ff       	call   80115e <printnum>
  8011c0:	83 c4 20             	add    $0x20,%esp
  8011c3:	eb 18                	jmp    8011dd <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	56                   	push   %esi
  8011c9:	ff 75 18             	pushl  0x18(%ebp)
  8011cc:	ff d7                	call   *%edi
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	eb 03                	jmp    8011d6 <printnum+0x78>
  8011d3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011d6:	83 eb 01             	sub    $0x1,%ebx
  8011d9:	85 db                	test   %ebx,%ebx
  8011db:	7f e8                	jg     8011c5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	56                   	push   %esi
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f0:	e8 5b 0b 00 00       	call   801d50 <__umoddi3>
  8011f5:	83 c4 14             	add    $0x14,%esp
  8011f8:	0f be 80 07 20 80 00 	movsbl 0x802007(%eax),%eax
  8011ff:	50                   	push   %eax
  801200:	ff d7                	call   *%edi
}
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801213:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801217:	8b 10                	mov    (%eax),%edx
  801219:	3b 50 04             	cmp    0x4(%eax),%edx
  80121c:	73 0a                	jae    801228 <sprintputch+0x1b>
		*b->buf++ = ch;
  80121e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801221:	89 08                	mov    %ecx,(%eax)
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	88 02                	mov    %al,(%edx)
}
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801230:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801233:	50                   	push   %eax
  801234:	ff 75 10             	pushl  0x10(%ebp)
  801237:	ff 75 0c             	pushl  0xc(%ebp)
  80123a:	ff 75 08             	pushl  0x8(%ebp)
  80123d:	e8 05 00 00 00       	call   801247 <vprintfmt>
	va_end(ap);
}
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	57                   	push   %edi
  80124b:	56                   	push   %esi
  80124c:	53                   	push   %ebx
  80124d:	83 ec 2c             	sub    $0x2c,%esp
  801250:	8b 75 08             	mov    0x8(%ebp),%esi
  801253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801256:	8b 7d 10             	mov    0x10(%ebp),%edi
  801259:	eb 12                	jmp    80126d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80125b:	85 c0                	test   %eax,%eax
  80125d:	0f 84 42 04 00 00    	je     8016a5 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	53                   	push   %ebx
  801267:	50                   	push   %eax
  801268:	ff d6                	call   *%esi
  80126a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80126d:	83 c7 01             	add    $0x1,%edi
  801270:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801274:	83 f8 25             	cmp    $0x25,%eax
  801277:	75 e2                	jne    80125b <vprintfmt+0x14>
  801279:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80127d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801284:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80128b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801292:	b9 00 00 00 00       	mov    $0x0,%ecx
  801297:	eb 07                	jmp    8012a0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801299:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80129c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	8d 47 01             	lea    0x1(%edi),%eax
  8012a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a6:	0f b6 07             	movzbl (%edi),%eax
  8012a9:	0f b6 d0             	movzbl %al,%edx
  8012ac:	83 e8 23             	sub    $0x23,%eax
  8012af:	3c 55                	cmp    $0x55,%al
  8012b1:	0f 87 d3 03 00 00    	ja     80168a <vprintfmt+0x443>
  8012b7:	0f b6 c0             	movzbl %al,%eax
  8012ba:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  8012c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012c4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012c8:	eb d6                	jmp    8012a0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012d8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012dc:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012df:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012e2:	83 f9 09             	cmp    $0x9,%ecx
  8012e5:	77 3f                	ja     801326 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012e7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012ea:	eb e9                	jmp    8012d5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ef:	8b 00                	mov    (%eax),%eax
  8012f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f7:	8d 40 04             	lea    0x4(%eax),%eax
  8012fa:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801300:	eb 2a                	jmp    80132c <vprintfmt+0xe5>
  801302:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801305:	85 c0                	test   %eax,%eax
  801307:	ba 00 00 00 00       	mov    $0x0,%edx
  80130c:	0f 49 d0             	cmovns %eax,%edx
  80130f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801315:	eb 89                	jmp    8012a0 <vprintfmt+0x59>
  801317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80131a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801321:	e9 7a ff ff ff       	jmp    8012a0 <vprintfmt+0x59>
  801326:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801329:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80132c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801330:	0f 89 6a ff ff ff    	jns    8012a0 <vprintfmt+0x59>
				width = precision, precision = -1;
  801336:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801339:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801343:	e9 58 ff ff ff       	jmp    8012a0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801348:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80134e:	e9 4d ff ff ff       	jmp    8012a0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801353:	8b 45 14             	mov    0x14(%ebp),%eax
  801356:	8d 78 04             	lea    0x4(%eax),%edi
  801359:	83 ec 08             	sub    $0x8,%esp
  80135c:	53                   	push   %ebx
  80135d:	ff 30                	pushl  (%eax)
  80135f:	ff d6                	call   *%esi
			break;
  801361:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801364:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80136a:	e9 fe fe ff ff       	jmp    80126d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80136f:	8b 45 14             	mov    0x14(%ebp),%eax
  801372:	8d 78 04             	lea    0x4(%eax),%edi
  801375:	8b 00                	mov    (%eax),%eax
  801377:	99                   	cltd   
  801378:	31 d0                	xor    %edx,%eax
  80137a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80137c:	83 f8 0f             	cmp    $0xf,%eax
  80137f:	7f 0b                	jg     80138c <vprintfmt+0x145>
  801381:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  801388:	85 d2                	test   %edx,%edx
  80138a:	75 1b                	jne    8013a7 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80138c:	50                   	push   %eax
  80138d:	68 1f 20 80 00       	push   $0x80201f
  801392:	53                   	push   %ebx
  801393:	56                   	push   %esi
  801394:	e8 91 fe ff ff       	call   80122a <printfmt>
  801399:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80139c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a2:	e9 c6 fe ff ff       	jmp    80126d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013a7:	52                   	push   %edx
  8013a8:	68 9d 1f 80 00       	push   $0x801f9d
  8013ad:	53                   	push   %ebx
  8013ae:	56                   	push   %esi
  8013af:	e8 76 fe ff ff       	call   80122a <printfmt>
  8013b4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013b7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013bd:	e9 ab fe ff ff       	jmp    80126d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c5:	83 c0 04             	add    $0x4,%eax
  8013c8:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8013cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ce:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013d0:	85 ff                	test   %edi,%edi
  8013d2:	b8 18 20 80 00       	mov    $0x802018,%eax
  8013d7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013de:	0f 8e 94 00 00 00    	jle    801478 <vprintfmt+0x231>
  8013e4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013e8:	0f 84 98 00 00 00    	je     801486 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013f4:	57                   	push   %edi
  8013f5:	e8 33 03 00 00       	call   80172d <strnlen>
  8013fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013fd:	29 c1                	sub    %eax,%ecx
  8013ff:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801402:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801405:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801409:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80140c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80140f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801411:	eb 0f                	jmp    801422 <vprintfmt+0x1db>
					putch(padc, putdat);
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	53                   	push   %ebx
  801417:	ff 75 e0             	pushl  -0x20(%ebp)
  80141a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80141c:	83 ef 01             	sub    $0x1,%edi
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	85 ff                	test   %edi,%edi
  801424:	7f ed                	jg     801413 <vprintfmt+0x1cc>
  801426:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801429:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80142c:	85 c9                	test   %ecx,%ecx
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
  801433:	0f 49 c1             	cmovns %ecx,%eax
  801436:	29 c1                	sub    %eax,%ecx
  801438:	89 75 08             	mov    %esi,0x8(%ebp)
  80143b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80143e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801441:	89 cb                	mov    %ecx,%ebx
  801443:	eb 4d                	jmp    801492 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801445:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801449:	74 1b                	je     801466 <vprintfmt+0x21f>
  80144b:	0f be c0             	movsbl %al,%eax
  80144e:	83 e8 20             	sub    $0x20,%eax
  801451:	83 f8 5e             	cmp    $0x5e,%eax
  801454:	76 10                	jbe    801466 <vprintfmt+0x21f>
					putch('?', putdat);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	ff 75 0c             	pushl  0xc(%ebp)
  80145c:	6a 3f                	push   $0x3f
  80145e:	ff 55 08             	call   *0x8(%ebp)
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	eb 0d                	jmp    801473 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	ff 75 0c             	pushl  0xc(%ebp)
  80146c:	52                   	push   %edx
  80146d:	ff 55 08             	call   *0x8(%ebp)
  801470:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801473:	83 eb 01             	sub    $0x1,%ebx
  801476:	eb 1a                	jmp    801492 <vprintfmt+0x24b>
  801478:	89 75 08             	mov    %esi,0x8(%ebp)
  80147b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80147e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801481:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801484:	eb 0c                	jmp    801492 <vprintfmt+0x24b>
  801486:	89 75 08             	mov    %esi,0x8(%ebp)
  801489:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80148c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80148f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801492:	83 c7 01             	add    $0x1,%edi
  801495:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801499:	0f be d0             	movsbl %al,%edx
  80149c:	85 d2                	test   %edx,%edx
  80149e:	74 23                	je     8014c3 <vprintfmt+0x27c>
  8014a0:	85 f6                	test   %esi,%esi
  8014a2:	78 a1                	js     801445 <vprintfmt+0x1fe>
  8014a4:	83 ee 01             	sub    $0x1,%esi
  8014a7:	79 9c                	jns    801445 <vprintfmt+0x1fe>
  8014a9:	89 df                	mov    %ebx,%edi
  8014ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b1:	eb 18                	jmp    8014cb <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014b3:	83 ec 08             	sub    $0x8,%esp
  8014b6:	53                   	push   %ebx
  8014b7:	6a 20                	push   $0x20
  8014b9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014bb:	83 ef 01             	sub    $0x1,%edi
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	eb 08                	jmp    8014cb <vprintfmt+0x284>
  8014c3:	89 df                	mov    %ebx,%edi
  8014c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014cb:	85 ff                	test   %edi,%edi
  8014cd:	7f e4                	jg     8014b3 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014cf:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014d2:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014d8:	e9 90 fd ff ff       	jmp    80126d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014dd:	83 f9 01             	cmp    $0x1,%ecx
  8014e0:	7e 19                	jle    8014fb <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e5:	8b 50 04             	mov    0x4(%eax),%edx
  8014e8:	8b 00                	mov    (%eax),%eax
  8014ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f3:	8d 40 08             	lea    0x8(%eax),%eax
  8014f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f9:	eb 38                	jmp    801533 <vprintfmt+0x2ec>
	else if (lflag)
  8014fb:	85 c9                	test   %ecx,%ecx
  8014fd:	74 1b                	je     80151a <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801502:	8b 00                	mov    (%eax),%eax
  801504:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801507:	89 c1                	mov    %eax,%ecx
  801509:	c1 f9 1f             	sar    $0x1f,%ecx
  80150c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80150f:	8b 45 14             	mov    0x14(%ebp),%eax
  801512:	8d 40 04             	lea    0x4(%eax),%eax
  801515:	89 45 14             	mov    %eax,0x14(%ebp)
  801518:	eb 19                	jmp    801533 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80151a:	8b 45 14             	mov    0x14(%ebp),%eax
  80151d:	8b 00                	mov    (%eax),%eax
  80151f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801522:	89 c1                	mov    %eax,%ecx
  801524:	c1 f9 1f             	sar    $0x1f,%ecx
  801527:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80152a:	8b 45 14             	mov    0x14(%ebp),%eax
  80152d:	8d 40 04             	lea    0x4(%eax),%eax
  801530:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801533:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801536:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801539:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80153e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801542:	0f 89 0e 01 00 00    	jns    801656 <vprintfmt+0x40f>
				putch('-', putdat);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	53                   	push   %ebx
  80154c:	6a 2d                	push   $0x2d
  80154e:	ff d6                	call   *%esi
				num = -(long long) num;
  801550:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801553:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801556:	f7 da                	neg    %edx
  801558:	83 d1 00             	adc    $0x0,%ecx
  80155b:	f7 d9                	neg    %ecx
  80155d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801560:	b8 0a 00 00 00       	mov    $0xa,%eax
  801565:	e9 ec 00 00 00       	jmp    801656 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80156a:	83 f9 01             	cmp    $0x1,%ecx
  80156d:	7e 18                	jle    801587 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80156f:	8b 45 14             	mov    0x14(%ebp),%eax
  801572:	8b 10                	mov    (%eax),%edx
  801574:	8b 48 04             	mov    0x4(%eax),%ecx
  801577:	8d 40 08             	lea    0x8(%eax),%eax
  80157a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80157d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801582:	e9 cf 00 00 00       	jmp    801656 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801587:	85 c9                	test   %ecx,%ecx
  801589:	74 1a                	je     8015a5 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80158b:	8b 45 14             	mov    0x14(%ebp),%eax
  80158e:	8b 10                	mov    (%eax),%edx
  801590:	b9 00 00 00 00       	mov    $0x0,%ecx
  801595:	8d 40 04             	lea    0x4(%eax),%eax
  801598:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80159b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015a0:	e9 b1 00 00 00       	jmp    801656 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8015a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a8:	8b 10                	mov    (%eax),%edx
  8015aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015af:	8d 40 04             	lea    0x4(%eax),%eax
  8015b2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8015b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015ba:	e9 97 00 00 00       	jmp    801656 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	53                   	push   %ebx
  8015c3:	6a 58                	push   $0x58
  8015c5:	ff d6                	call   *%esi
			putch('X', putdat);
  8015c7:	83 c4 08             	add    $0x8,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	6a 58                	push   $0x58
  8015cd:	ff d6                	call   *%esi
			putch('X', putdat);
  8015cf:	83 c4 08             	add    $0x8,%esp
  8015d2:	53                   	push   %ebx
  8015d3:	6a 58                	push   $0x58
  8015d5:	ff d6                	call   *%esi
			break;
  8015d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015dd:	e9 8b fc ff ff       	jmp    80126d <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	53                   	push   %ebx
  8015e6:	6a 30                	push   $0x30
  8015e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8015ea:	83 c4 08             	add    $0x8,%esp
  8015ed:	53                   	push   %ebx
  8015ee:	6a 78                	push   $0x78
  8015f0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f5:	8b 10                	mov    (%eax),%edx
  8015f7:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015fc:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015ff:	8d 40 04             	lea    0x4(%eax),%eax
  801602:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801605:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80160a:	eb 4a                	jmp    801656 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80160c:	83 f9 01             	cmp    $0x1,%ecx
  80160f:	7e 15                	jle    801626 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801611:	8b 45 14             	mov    0x14(%ebp),%eax
  801614:	8b 10                	mov    (%eax),%edx
  801616:	8b 48 04             	mov    0x4(%eax),%ecx
  801619:	8d 40 08             	lea    0x8(%eax),%eax
  80161c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80161f:	b8 10 00 00 00       	mov    $0x10,%eax
  801624:	eb 30                	jmp    801656 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801626:	85 c9                	test   %ecx,%ecx
  801628:	74 17                	je     801641 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80162a:	8b 45 14             	mov    0x14(%ebp),%eax
  80162d:	8b 10                	mov    (%eax),%edx
  80162f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801634:	8d 40 04             	lea    0x4(%eax),%eax
  801637:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80163a:	b8 10 00 00 00       	mov    $0x10,%eax
  80163f:	eb 15                	jmp    801656 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801641:	8b 45 14             	mov    0x14(%ebp),%eax
  801644:	8b 10                	mov    (%eax),%edx
  801646:	b9 00 00 00 00       	mov    $0x0,%ecx
  80164b:	8d 40 04             	lea    0x4(%eax),%eax
  80164e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801651:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80165d:	57                   	push   %edi
  80165e:	ff 75 e0             	pushl  -0x20(%ebp)
  801661:	50                   	push   %eax
  801662:	51                   	push   %ecx
  801663:	52                   	push   %edx
  801664:	89 da                	mov    %ebx,%edx
  801666:	89 f0                	mov    %esi,%eax
  801668:	e8 f1 fa ff ff       	call   80115e <printnum>
			break;
  80166d:	83 c4 20             	add    $0x20,%esp
  801670:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801673:	e9 f5 fb ff ff       	jmp    80126d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801678:	83 ec 08             	sub    $0x8,%esp
  80167b:	53                   	push   %ebx
  80167c:	52                   	push   %edx
  80167d:	ff d6                	call   *%esi
			break;
  80167f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801682:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801685:	e9 e3 fb ff ff       	jmp    80126d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	53                   	push   %ebx
  80168e:	6a 25                	push   $0x25
  801690:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	eb 03                	jmp    80169a <vprintfmt+0x453>
  801697:	83 ef 01             	sub    $0x1,%edi
  80169a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80169e:	75 f7                	jne    801697 <vprintfmt+0x450>
  8016a0:	e9 c8 fb ff ff       	jmp    80126d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5f                   	pop    %edi
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	83 ec 18             	sub    $0x18,%esp
  8016b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	74 26                	je     8016f4 <vsnprintf+0x47>
  8016ce:	85 d2                	test   %edx,%edx
  8016d0:	7e 22                	jle    8016f4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016d2:	ff 75 14             	pushl  0x14(%ebp)
  8016d5:	ff 75 10             	pushl  0x10(%ebp)
  8016d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016db:	50                   	push   %eax
  8016dc:	68 0d 12 80 00       	push   $0x80120d
  8016e1:	e8 61 fb ff ff       	call   801247 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	eb 05                	jmp    8016f9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801701:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801704:	50                   	push   %eax
  801705:	ff 75 10             	pushl  0x10(%ebp)
  801708:	ff 75 0c             	pushl  0xc(%ebp)
  80170b:	ff 75 08             	pushl  0x8(%ebp)
  80170e:	e8 9a ff ff ff       	call   8016ad <vsnprintf>
	va_end(ap);

	return rc;
}
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80171b:	b8 00 00 00 00       	mov    $0x0,%eax
  801720:	eb 03                	jmp    801725 <strlen+0x10>
		n++;
  801722:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801725:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801729:	75 f7                	jne    801722 <strlen+0xd>
		n++;
	return n;
}
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801733:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801736:	ba 00 00 00 00       	mov    $0x0,%edx
  80173b:	eb 03                	jmp    801740 <strnlen+0x13>
		n++;
  80173d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801740:	39 c2                	cmp    %eax,%edx
  801742:	74 08                	je     80174c <strnlen+0x1f>
  801744:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801748:	75 f3                	jne    80173d <strnlen+0x10>
  80174a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	53                   	push   %ebx
  801752:	8b 45 08             	mov    0x8(%ebp),%eax
  801755:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801758:	89 c2                	mov    %eax,%edx
  80175a:	83 c2 01             	add    $0x1,%edx
  80175d:	83 c1 01             	add    $0x1,%ecx
  801760:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801764:	88 5a ff             	mov    %bl,-0x1(%edx)
  801767:	84 db                	test   %bl,%bl
  801769:	75 ef                	jne    80175a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80176b:	5b                   	pop    %ebx
  80176c:	5d                   	pop    %ebp
  80176d:	c3                   	ret    

0080176e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	53                   	push   %ebx
  801772:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801775:	53                   	push   %ebx
  801776:	e8 9a ff ff ff       	call   801715 <strlen>
  80177b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80177e:	ff 75 0c             	pushl  0xc(%ebp)
  801781:	01 d8                	add    %ebx,%eax
  801783:	50                   	push   %eax
  801784:	e8 c5 ff ff ff       	call   80174e <strcpy>
	return dst;
}
  801789:	89 d8                	mov    %ebx,%eax
  80178b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	8b 75 08             	mov    0x8(%ebp),%esi
  801798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179b:	89 f3                	mov    %esi,%ebx
  80179d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017a0:	89 f2                	mov    %esi,%edx
  8017a2:	eb 0f                	jmp    8017b3 <strncpy+0x23>
		*dst++ = *src;
  8017a4:	83 c2 01             	add    $0x1,%edx
  8017a7:	0f b6 01             	movzbl (%ecx),%eax
  8017aa:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017ad:	80 39 01             	cmpb   $0x1,(%ecx)
  8017b0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017b3:	39 da                	cmp    %ebx,%edx
  8017b5:	75 ed                	jne    8017a4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017b7:	89 f0                	mov    %esi,%eax
  8017b9:	5b                   	pop    %ebx
  8017ba:	5e                   	pop    %esi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	56                   	push   %esi
  8017c1:	53                   	push   %ebx
  8017c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c8:	8b 55 10             	mov    0x10(%ebp),%edx
  8017cb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017cd:	85 d2                	test   %edx,%edx
  8017cf:	74 21                	je     8017f2 <strlcpy+0x35>
  8017d1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017d5:	89 f2                	mov    %esi,%edx
  8017d7:	eb 09                	jmp    8017e2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017d9:	83 c2 01             	add    $0x1,%edx
  8017dc:	83 c1 01             	add    $0x1,%ecx
  8017df:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017e2:	39 c2                	cmp    %eax,%edx
  8017e4:	74 09                	je     8017ef <strlcpy+0x32>
  8017e6:	0f b6 19             	movzbl (%ecx),%ebx
  8017e9:	84 db                	test   %bl,%bl
  8017eb:	75 ec                	jne    8017d9 <strlcpy+0x1c>
  8017ed:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017ef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017f2:	29 f0                	sub    %esi,%eax
}
  8017f4:	5b                   	pop    %ebx
  8017f5:	5e                   	pop    %esi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801801:	eb 06                	jmp    801809 <strcmp+0x11>
		p++, q++;
  801803:	83 c1 01             	add    $0x1,%ecx
  801806:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801809:	0f b6 01             	movzbl (%ecx),%eax
  80180c:	84 c0                	test   %al,%al
  80180e:	74 04                	je     801814 <strcmp+0x1c>
  801810:	3a 02                	cmp    (%edx),%al
  801812:	74 ef                	je     801803 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801814:	0f b6 c0             	movzbl %al,%eax
  801817:	0f b6 12             	movzbl (%edx),%edx
  80181a:	29 d0                	sub    %edx,%eax
}
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	53                   	push   %ebx
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	8b 55 0c             	mov    0xc(%ebp),%edx
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80182d:	eb 06                	jmp    801835 <strncmp+0x17>
		n--, p++, q++;
  80182f:	83 c0 01             	add    $0x1,%eax
  801832:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801835:	39 d8                	cmp    %ebx,%eax
  801837:	74 15                	je     80184e <strncmp+0x30>
  801839:	0f b6 08             	movzbl (%eax),%ecx
  80183c:	84 c9                	test   %cl,%cl
  80183e:	74 04                	je     801844 <strncmp+0x26>
  801840:	3a 0a                	cmp    (%edx),%cl
  801842:	74 eb                	je     80182f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801844:	0f b6 00             	movzbl (%eax),%eax
  801847:	0f b6 12             	movzbl (%edx),%edx
  80184a:	29 d0                	sub    %edx,%eax
  80184c:	eb 05                	jmp    801853 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80184e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801853:	5b                   	pop    %ebx
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	8b 45 08             	mov    0x8(%ebp),%eax
  80185c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801860:	eb 07                	jmp    801869 <strchr+0x13>
		if (*s == c)
  801862:	38 ca                	cmp    %cl,%dl
  801864:	74 0f                	je     801875 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801866:	83 c0 01             	add    $0x1,%eax
  801869:	0f b6 10             	movzbl (%eax),%edx
  80186c:	84 d2                	test   %dl,%dl
  80186e:	75 f2                	jne    801862 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801881:	eb 03                	jmp    801886 <strfind+0xf>
  801883:	83 c0 01             	add    $0x1,%eax
  801886:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801889:	38 ca                	cmp    %cl,%dl
  80188b:	74 04                	je     801891 <strfind+0x1a>
  80188d:	84 d2                	test   %dl,%dl
  80188f:	75 f2                	jne    801883 <strfind+0xc>
			break;
	return (char *) s;
}
  801891:	5d                   	pop    %ebp
  801892:	c3                   	ret    

00801893 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	57                   	push   %edi
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	8b 7d 08             	mov    0x8(%ebp),%edi
  80189c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80189f:	85 c9                	test   %ecx,%ecx
  8018a1:	74 36                	je     8018d9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018a3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018a9:	75 28                	jne    8018d3 <memset+0x40>
  8018ab:	f6 c1 03             	test   $0x3,%cl
  8018ae:	75 23                	jne    8018d3 <memset+0x40>
		c &= 0xFF;
  8018b0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018b4:	89 d3                	mov    %edx,%ebx
  8018b6:	c1 e3 08             	shl    $0x8,%ebx
  8018b9:	89 d6                	mov    %edx,%esi
  8018bb:	c1 e6 18             	shl    $0x18,%esi
  8018be:	89 d0                	mov    %edx,%eax
  8018c0:	c1 e0 10             	shl    $0x10,%eax
  8018c3:	09 f0                	or     %esi,%eax
  8018c5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018c7:	89 d8                	mov    %ebx,%eax
  8018c9:	09 d0                	or     %edx,%eax
  8018cb:	c1 e9 02             	shr    $0x2,%ecx
  8018ce:	fc                   	cld    
  8018cf:	f3 ab                	rep stos %eax,%es:(%edi)
  8018d1:	eb 06                	jmp    8018d9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d6:	fc                   	cld    
  8018d7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018d9:	89 f8                	mov    %edi,%eax
  8018db:	5b                   	pop    %ebx
  8018dc:	5e                   	pop    %esi
  8018dd:	5f                   	pop    %edi
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	57                   	push   %edi
  8018e4:	56                   	push   %esi
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ee:	39 c6                	cmp    %eax,%esi
  8018f0:	73 35                	jae    801927 <memmove+0x47>
  8018f2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018f5:	39 d0                	cmp    %edx,%eax
  8018f7:	73 2e                	jae    801927 <memmove+0x47>
		s += n;
		d += n;
  8018f9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018fc:	89 d6                	mov    %edx,%esi
  8018fe:	09 fe                	or     %edi,%esi
  801900:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801906:	75 13                	jne    80191b <memmove+0x3b>
  801908:	f6 c1 03             	test   $0x3,%cl
  80190b:	75 0e                	jne    80191b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80190d:	83 ef 04             	sub    $0x4,%edi
  801910:	8d 72 fc             	lea    -0x4(%edx),%esi
  801913:	c1 e9 02             	shr    $0x2,%ecx
  801916:	fd                   	std    
  801917:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801919:	eb 09                	jmp    801924 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80191b:	83 ef 01             	sub    $0x1,%edi
  80191e:	8d 72 ff             	lea    -0x1(%edx),%esi
  801921:	fd                   	std    
  801922:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801924:	fc                   	cld    
  801925:	eb 1d                	jmp    801944 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801927:	89 f2                	mov    %esi,%edx
  801929:	09 c2                	or     %eax,%edx
  80192b:	f6 c2 03             	test   $0x3,%dl
  80192e:	75 0f                	jne    80193f <memmove+0x5f>
  801930:	f6 c1 03             	test   $0x3,%cl
  801933:	75 0a                	jne    80193f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801935:	c1 e9 02             	shr    $0x2,%ecx
  801938:	89 c7                	mov    %eax,%edi
  80193a:	fc                   	cld    
  80193b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80193d:	eb 05                	jmp    801944 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80193f:	89 c7                	mov    %eax,%edi
  801941:	fc                   	cld    
  801942:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801944:	5e                   	pop    %esi
  801945:	5f                   	pop    %edi
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80194b:	ff 75 10             	pushl  0x10(%ebp)
  80194e:	ff 75 0c             	pushl  0xc(%ebp)
  801951:	ff 75 08             	pushl  0x8(%ebp)
  801954:	e8 87 ff ff ff       	call   8018e0 <memmove>
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	8b 45 08             	mov    0x8(%ebp),%eax
  801963:	8b 55 0c             	mov    0xc(%ebp),%edx
  801966:	89 c6                	mov    %eax,%esi
  801968:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80196b:	eb 1a                	jmp    801987 <memcmp+0x2c>
		if (*s1 != *s2)
  80196d:	0f b6 08             	movzbl (%eax),%ecx
  801970:	0f b6 1a             	movzbl (%edx),%ebx
  801973:	38 d9                	cmp    %bl,%cl
  801975:	74 0a                	je     801981 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801977:	0f b6 c1             	movzbl %cl,%eax
  80197a:	0f b6 db             	movzbl %bl,%ebx
  80197d:	29 d8                	sub    %ebx,%eax
  80197f:	eb 0f                	jmp    801990 <memcmp+0x35>
		s1++, s2++;
  801981:	83 c0 01             	add    $0x1,%eax
  801984:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801987:	39 f0                	cmp    %esi,%eax
  801989:	75 e2                	jne    80196d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80198b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801990:	5b                   	pop    %ebx
  801991:	5e                   	pop    %esi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	53                   	push   %ebx
  801998:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80199b:	89 c1                	mov    %eax,%ecx
  80199d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8019a0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019a4:	eb 0a                	jmp    8019b0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019a6:	0f b6 10             	movzbl (%eax),%edx
  8019a9:	39 da                	cmp    %ebx,%edx
  8019ab:	74 07                	je     8019b4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019ad:	83 c0 01             	add    $0x1,%eax
  8019b0:	39 c8                	cmp    %ecx,%eax
  8019b2:	72 f2                	jb     8019a6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019b4:	5b                   	pop    %ebx
  8019b5:	5d                   	pop    %ebp
  8019b6:	c3                   	ret    

008019b7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	57                   	push   %edi
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019c3:	eb 03                	jmp    8019c8 <strtol+0x11>
		s++;
  8019c5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019c8:	0f b6 01             	movzbl (%ecx),%eax
  8019cb:	3c 20                	cmp    $0x20,%al
  8019cd:	74 f6                	je     8019c5 <strtol+0xe>
  8019cf:	3c 09                	cmp    $0x9,%al
  8019d1:	74 f2                	je     8019c5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019d3:	3c 2b                	cmp    $0x2b,%al
  8019d5:	75 0a                	jne    8019e1 <strtol+0x2a>
		s++;
  8019d7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019da:	bf 00 00 00 00       	mov    $0x0,%edi
  8019df:	eb 11                	jmp    8019f2 <strtol+0x3b>
  8019e1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019e6:	3c 2d                	cmp    $0x2d,%al
  8019e8:	75 08                	jne    8019f2 <strtol+0x3b>
		s++, neg = 1;
  8019ea:	83 c1 01             	add    $0x1,%ecx
  8019ed:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019f2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019f8:	75 15                	jne    801a0f <strtol+0x58>
  8019fa:	80 39 30             	cmpb   $0x30,(%ecx)
  8019fd:	75 10                	jne    801a0f <strtol+0x58>
  8019ff:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a03:	75 7c                	jne    801a81 <strtol+0xca>
		s += 2, base = 16;
  801a05:	83 c1 02             	add    $0x2,%ecx
  801a08:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a0d:	eb 16                	jmp    801a25 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a0f:	85 db                	test   %ebx,%ebx
  801a11:	75 12                	jne    801a25 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a13:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a18:	80 39 30             	cmpb   $0x30,(%ecx)
  801a1b:	75 08                	jne    801a25 <strtol+0x6e>
		s++, base = 8;
  801a1d:	83 c1 01             	add    $0x1,%ecx
  801a20:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a25:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a2d:	0f b6 11             	movzbl (%ecx),%edx
  801a30:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a33:	89 f3                	mov    %esi,%ebx
  801a35:	80 fb 09             	cmp    $0x9,%bl
  801a38:	77 08                	ja     801a42 <strtol+0x8b>
			dig = *s - '0';
  801a3a:	0f be d2             	movsbl %dl,%edx
  801a3d:	83 ea 30             	sub    $0x30,%edx
  801a40:	eb 22                	jmp    801a64 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a42:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a45:	89 f3                	mov    %esi,%ebx
  801a47:	80 fb 19             	cmp    $0x19,%bl
  801a4a:	77 08                	ja     801a54 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a4c:	0f be d2             	movsbl %dl,%edx
  801a4f:	83 ea 57             	sub    $0x57,%edx
  801a52:	eb 10                	jmp    801a64 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a54:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a57:	89 f3                	mov    %esi,%ebx
  801a59:	80 fb 19             	cmp    $0x19,%bl
  801a5c:	77 16                	ja     801a74 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a5e:	0f be d2             	movsbl %dl,%edx
  801a61:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a64:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a67:	7d 0b                	jge    801a74 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a69:	83 c1 01             	add    $0x1,%ecx
  801a6c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a70:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a72:	eb b9                	jmp    801a2d <strtol+0x76>

	if (endptr)
  801a74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a78:	74 0d                	je     801a87 <strtol+0xd0>
		*endptr = (char *) s;
  801a7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7d:	89 0e                	mov    %ecx,(%esi)
  801a7f:	eb 06                	jmp    801a87 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a81:	85 db                	test   %ebx,%ebx
  801a83:	74 98                	je     801a1d <strtol+0x66>
  801a85:	eb 9e                	jmp    801a25 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a87:	89 c2                	mov    %eax,%edx
  801a89:	f7 da                	neg    %edx
  801a8b:	85 ff                	test   %edi,%edi
  801a8d:	0f 45 c2             	cmovne %edx,%eax
}
  801a90:	5b                   	pop    %ebx
  801a91:	5e                   	pop    %esi
  801a92:	5f                   	pop    %edi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    

00801a95 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	53                   	push   %ebx
  801a99:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a9c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801aa3:	75 28                	jne    801acd <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801aa5:	e8 88 e6 ff ff       	call   800132 <sys_getenvid>
  801aaa:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801aac:	83 ec 04             	sub    $0x4,%esp
  801aaf:	6a 07                	push   $0x7
  801ab1:	68 00 f0 bf ee       	push   $0xeebff000
  801ab6:	50                   	push   %eax
  801ab7:	e8 b4 e6 ff ff       	call   800170 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801abc:	83 c4 08             	add    $0x8,%esp
  801abf:	68 61 03 80 00       	push   $0x800361
  801ac4:	53                   	push   %ebx
  801ac5:	e8 f1 e7 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801aca:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801acd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad0:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ad5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
  801adf:	8b 75 08             	mov    0x8(%ebp),%esi
  801ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	74 0e                	je     801afa <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801aec:	83 ec 0c             	sub    $0xc,%esp
  801aef:	50                   	push   %eax
  801af0:	e8 2b e8 ff ff       	call   800320 <sys_ipc_recv>
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	eb 0d                	jmp    801b07 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	6a ff                	push   $0xffffffff
  801aff:	e8 1c e8 ff ff       	call   800320 <sys_ipc_recv>
  801b04:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801b07:	85 c0                	test   %eax,%eax
  801b09:	79 16                	jns    801b21 <ipc_recv+0x47>

		if (from_env_store != NULL)
  801b0b:	85 f6                	test   %esi,%esi
  801b0d:	74 06                	je     801b15 <ipc_recv+0x3b>
			*from_env_store = 0;
  801b0f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801b15:	85 db                	test   %ebx,%ebx
  801b17:	74 2c                	je     801b45 <ipc_recv+0x6b>
			*perm_store = 0;
  801b19:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b1f:	eb 24                	jmp    801b45 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801b21:	85 f6                	test   %esi,%esi
  801b23:	74 0a                	je     801b2f <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801b25:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2a:	8b 40 74             	mov    0x74(%eax),%eax
  801b2d:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801b2f:	85 db                	test   %ebx,%ebx
  801b31:	74 0a                	je     801b3d <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801b33:	a1 04 40 80 00       	mov    0x804004,%eax
  801b38:	8b 40 78             	mov    0x78(%eax),%eax
  801b3b:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b3d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b42:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801b45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	57                   	push   %edi
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	83 ec 0c             	sub    $0xc,%esp
  801b55:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b58:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801b5e:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801b60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b65:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b68:	ff 75 14             	pushl  0x14(%ebp)
  801b6b:	53                   	push   %ebx
  801b6c:	56                   	push   %esi
  801b6d:	57                   	push   %edi
  801b6e:	e8 8a e7 ff ff       	call   8002fd <sys_ipc_try_send>
		if (r >= 0)
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	85 c0                	test   %eax,%eax
  801b78:	79 1e                	jns    801b98 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801b7a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b7d:	74 12                	je     801b91 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801b7f:	50                   	push   %eax
  801b80:	68 00 23 80 00       	push   $0x802300
  801b85:	6a 49                	push   $0x49
  801b87:	68 13 23 80 00       	push   $0x802313
  801b8c:	e8 e0 f4 ff ff       	call   801071 <_panic>
	
		sys_yield();
  801b91:	e8 bb e5 ff ff       	call   800151 <sys_yield>
	}
  801b96:	eb d0                	jmp    801b68 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9b:	5b                   	pop    %ebx
  801b9c:	5e                   	pop    %esi
  801b9d:	5f                   	pop    %edi
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ba6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bab:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bae:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bb4:	8b 52 50             	mov    0x50(%edx),%edx
  801bb7:	39 ca                	cmp    %ecx,%edx
  801bb9:	75 0d                	jne    801bc8 <ipc_find_env+0x28>
			return envs[i].env_id;
  801bbb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bbe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bc3:	8b 40 48             	mov    0x48(%eax),%eax
  801bc6:	eb 0f                	jmp    801bd7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bc8:	83 c0 01             	add    $0x1,%eax
  801bcb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bd0:	75 d9                	jne    801bab <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bd7:	5d                   	pop    %ebp
  801bd8:	c3                   	ret    

00801bd9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bdf:	89 d0                	mov    %edx,%eax
  801be1:	c1 e8 16             	shr    $0x16,%eax
  801be4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801beb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bf0:	f6 c1 01             	test   $0x1,%cl
  801bf3:	74 1d                	je     801c12 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bf5:	c1 ea 0c             	shr    $0xc,%edx
  801bf8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bff:	f6 c2 01             	test   $0x1,%dl
  801c02:	74 0e                	je     801c12 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c04:	c1 ea 0c             	shr    $0xc,%edx
  801c07:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c0e:	ef 
  801c0f:	0f b7 c0             	movzwl %ax,%eax
}
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    
  801c14:	66 90                	xchg   %ax,%ax
  801c16:	66 90                	xchg   %ax,%ax
  801c18:	66 90                	xchg   %ax,%ax
  801c1a:	66 90                	xchg   %ax,%ax
  801c1c:	66 90                	xchg   %ax,%ax
  801c1e:	66 90                	xchg   %ax,%ax

00801c20 <__udivdi3>:
  801c20:	55                   	push   %ebp
  801c21:	57                   	push   %edi
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 1c             	sub    $0x1c,%esp
  801c27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c37:	85 f6                	test   %esi,%esi
  801c39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c3d:	89 ca                	mov    %ecx,%edx
  801c3f:	89 f8                	mov    %edi,%eax
  801c41:	75 3d                	jne    801c80 <__udivdi3+0x60>
  801c43:	39 cf                	cmp    %ecx,%edi
  801c45:	0f 87 c5 00 00 00    	ja     801d10 <__udivdi3+0xf0>
  801c4b:	85 ff                	test   %edi,%edi
  801c4d:	89 fd                	mov    %edi,%ebp
  801c4f:	75 0b                	jne    801c5c <__udivdi3+0x3c>
  801c51:	b8 01 00 00 00       	mov    $0x1,%eax
  801c56:	31 d2                	xor    %edx,%edx
  801c58:	f7 f7                	div    %edi
  801c5a:	89 c5                	mov    %eax,%ebp
  801c5c:	89 c8                	mov    %ecx,%eax
  801c5e:	31 d2                	xor    %edx,%edx
  801c60:	f7 f5                	div    %ebp
  801c62:	89 c1                	mov    %eax,%ecx
  801c64:	89 d8                	mov    %ebx,%eax
  801c66:	89 cf                	mov    %ecx,%edi
  801c68:	f7 f5                	div    %ebp
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	89 fa                	mov    %edi,%edx
  801c70:	83 c4 1c             	add    $0x1c,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	90                   	nop
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	39 ce                	cmp    %ecx,%esi
  801c82:	77 74                	ja     801cf8 <__udivdi3+0xd8>
  801c84:	0f bd fe             	bsr    %esi,%edi
  801c87:	83 f7 1f             	xor    $0x1f,%edi
  801c8a:	0f 84 98 00 00 00    	je     801d28 <__udivdi3+0x108>
  801c90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	89 c5                	mov    %eax,%ebp
  801c99:	29 fb                	sub    %edi,%ebx
  801c9b:	d3 e6                	shl    %cl,%esi
  801c9d:	89 d9                	mov    %ebx,%ecx
  801c9f:	d3 ed                	shr    %cl,%ebp
  801ca1:	89 f9                	mov    %edi,%ecx
  801ca3:	d3 e0                	shl    %cl,%eax
  801ca5:	09 ee                	or     %ebp,%esi
  801ca7:	89 d9                	mov    %ebx,%ecx
  801ca9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cad:	89 d5                	mov    %edx,%ebp
  801caf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cb3:	d3 ed                	shr    %cl,%ebp
  801cb5:	89 f9                	mov    %edi,%ecx
  801cb7:	d3 e2                	shl    %cl,%edx
  801cb9:	89 d9                	mov    %ebx,%ecx
  801cbb:	d3 e8                	shr    %cl,%eax
  801cbd:	09 c2                	or     %eax,%edx
  801cbf:	89 d0                	mov    %edx,%eax
  801cc1:	89 ea                	mov    %ebp,%edx
  801cc3:	f7 f6                	div    %esi
  801cc5:	89 d5                	mov    %edx,%ebp
  801cc7:	89 c3                	mov    %eax,%ebx
  801cc9:	f7 64 24 0c          	mull   0xc(%esp)
  801ccd:	39 d5                	cmp    %edx,%ebp
  801ccf:	72 10                	jb     801ce1 <__udivdi3+0xc1>
  801cd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	d3 e6                	shl    %cl,%esi
  801cd9:	39 c6                	cmp    %eax,%esi
  801cdb:	73 07                	jae    801ce4 <__udivdi3+0xc4>
  801cdd:	39 d5                	cmp    %edx,%ebp
  801cdf:	75 03                	jne    801ce4 <__udivdi3+0xc4>
  801ce1:	83 eb 01             	sub    $0x1,%ebx
  801ce4:	31 ff                	xor    %edi,%edi
  801ce6:	89 d8                	mov    %ebx,%eax
  801ce8:	89 fa                	mov    %edi,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	31 ff                	xor    %edi,%edi
  801cfa:	31 db                	xor    %ebx,%ebx
  801cfc:	89 d8                	mov    %ebx,%eax
  801cfe:	89 fa                	mov    %edi,%edx
  801d00:	83 c4 1c             	add    $0x1c,%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    
  801d08:	90                   	nop
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 d8                	mov    %ebx,%eax
  801d12:	f7 f7                	div    %edi
  801d14:	31 ff                	xor    %edi,%edi
  801d16:	89 c3                	mov    %eax,%ebx
  801d18:	89 d8                	mov    %ebx,%eax
  801d1a:	89 fa                	mov    %edi,%edx
  801d1c:	83 c4 1c             	add    $0x1c,%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5f                   	pop    %edi
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    
  801d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d28:	39 ce                	cmp    %ecx,%esi
  801d2a:	72 0c                	jb     801d38 <__udivdi3+0x118>
  801d2c:	31 db                	xor    %ebx,%ebx
  801d2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d32:	0f 87 34 ff ff ff    	ja     801c6c <__udivdi3+0x4c>
  801d38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d3d:	e9 2a ff ff ff       	jmp    801c6c <__udivdi3+0x4c>
  801d42:	66 90                	xchg   %ax,%ax
  801d44:	66 90                	xchg   %ax,%ax
  801d46:	66 90                	xchg   %ax,%ax
  801d48:	66 90                	xchg   %ax,%ax
  801d4a:	66 90                	xchg   %ax,%ax
  801d4c:	66 90                	xchg   %ax,%ax
  801d4e:	66 90                	xchg   %ax,%ax

00801d50 <__umoddi3>:
  801d50:	55                   	push   %ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 1c             	sub    $0x1c,%esp
  801d57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d67:	85 d2                	test   %edx,%edx
  801d69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d71:	89 f3                	mov    %esi,%ebx
  801d73:	89 3c 24             	mov    %edi,(%esp)
  801d76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d7a:	75 1c                	jne    801d98 <__umoddi3+0x48>
  801d7c:	39 f7                	cmp    %esi,%edi
  801d7e:	76 50                	jbe    801dd0 <__umoddi3+0x80>
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	f7 f7                	div    %edi
  801d86:	89 d0                	mov    %edx,%eax
  801d88:	31 d2                	xor    %edx,%edx
  801d8a:	83 c4 1c             	add    $0x1c,%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5f                   	pop    %edi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    
  801d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d98:	39 f2                	cmp    %esi,%edx
  801d9a:	89 d0                	mov    %edx,%eax
  801d9c:	77 52                	ja     801df0 <__umoddi3+0xa0>
  801d9e:	0f bd ea             	bsr    %edx,%ebp
  801da1:	83 f5 1f             	xor    $0x1f,%ebp
  801da4:	75 5a                	jne    801e00 <__umoddi3+0xb0>
  801da6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801daa:	0f 82 e0 00 00 00    	jb     801e90 <__umoddi3+0x140>
  801db0:	39 0c 24             	cmp    %ecx,(%esp)
  801db3:	0f 86 d7 00 00 00    	jbe    801e90 <__umoddi3+0x140>
  801db9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dc1:	83 c4 1c             	add    $0x1c,%esp
  801dc4:	5b                   	pop    %ebx
  801dc5:	5e                   	pop    %esi
  801dc6:	5f                   	pop    %edi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    
  801dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	85 ff                	test   %edi,%edi
  801dd2:	89 fd                	mov    %edi,%ebp
  801dd4:	75 0b                	jne    801de1 <__umoddi3+0x91>
  801dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ddb:	31 d2                	xor    %edx,%edx
  801ddd:	f7 f7                	div    %edi
  801ddf:	89 c5                	mov    %eax,%ebp
  801de1:	89 f0                	mov    %esi,%eax
  801de3:	31 d2                	xor    %edx,%edx
  801de5:	f7 f5                	div    %ebp
  801de7:	89 c8                	mov    %ecx,%eax
  801de9:	f7 f5                	div    %ebp
  801deb:	89 d0                	mov    %edx,%eax
  801ded:	eb 99                	jmp    801d88 <__umoddi3+0x38>
  801def:	90                   	nop
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	83 c4 1c             	add    $0x1c,%esp
  801df7:	5b                   	pop    %ebx
  801df8:	5e                   	pop    %esi
  801df9:	5f                   	pop    %edi
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    
  801dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e00:	8b 34 24             	mov    (%esp),%esi
  801e03:	bf 20 00 00 00       	mov    $0x20,%edi
  801e08:	89 e9                	mov    %ebp,%ecx
  801e0a:	29 ef                	sub    %ebp,%edi
  801e0c:	d3 e0                	shl    %cl,%eax
  801e0e:	89 f9                	mov    %edi,%ecx
  801e10:	89 f2                	mov    %esi,%edx
  801e12:	d3 ea                	shr    %cl,%edx
  801e14:	89 e9                	mov    %ebp,%ecx
  801e16:	09 c2                	or     %eax,%edx
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	89 14 24             	mov    %edx,(%esp)
  801e1d:	89 f2                	mov    %esi,%edx
  801e1f:	d3 e2                	shl    %cl,%edx
  801e21:	89 f9                	mov    %edi,%ecx
  801e23:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e2b:	d3 e8                	shr    %cl,%eax
  801e2d:	89 e9                	mov    %ebp,%ecx
  801e2f:	89 c6                	mov    %eax,%esi
  801e31:	d3 e3                	shl    %cl,%ebx
  801e33:	89 f9                	mov    %edi,%ecx
  801e35:	89 d0                	mov    %edx,%eax
  801e37:	d3 e8                	shr    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	09 d8                	or     %ebx,%eax
  801e3d:	89 d3                	mov    %edx,%ebx
  801e3f:	89 f2                	mov    %esi,%edx
  801e41:	f7 34 24             	divl   (%esp)
  801e44:	89 d6                	mov    %edx,%esi
  801e46:	d3 e3                	shl    %cl,%ebx
  801e48:	f7 64 24 04          	mull   0x4(%esp)
  801e4c:	39 d6                	cmp    %edx,%esi
  801e4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e52:	89 d1                	mov    %edx,%ecx
  801e54:	89 c3                	mov    %eax,%ebx
  801e56:	72 08                	jb     801e60 <__umoddi3+0x110>
  801e58:	75 11                	jne    801e6b <__umoddi3+0x11b>
  801e5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e5e:	73 0b                	jae    801e6b <__umoddi3+0x11b>
  801e60:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e64:	1b 14 24             	sbb    (%esp),%edx
  801e67:	89 d1                	mov    %edx,%ecx
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e6f:	29 da                	sub    %ebx,%edx
  801e71:	19 ce                	sbb    %ecx,%esi
  801e73:	89 f9                	mov    %edi,%ecx
  801e75:	89 f0                	mov    %esi,%eax
  801e77:	d3 e0                	shl    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	d3 ea                	shr    %cl,%edx
  801e7d:	89 e9                	mov    %ebp,%ecx
  801e7f:	d3 ee                	shr    %cl,%esi
  801e81:	09 d0                	or     %edx,%eax
  801e83:	89 f2                	mov    %esi,%edx
  801e85:	83 c4 1c             	add    $0x1c,%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5f                   	pop    %edi
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    
  801e8d:	8d 76 00             	lea    0x0(%esi),%esi
  801e90:	29 f9                	sub    %edi,%ecx
  801e92:	19 d6                	sbb    %edx,%esi
  801e94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e9c:	e9 18 ff ff ff       	jmp    801db9 <__umoddi3+0x69>
