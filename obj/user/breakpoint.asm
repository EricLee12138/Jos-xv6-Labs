
obj/user/breakpoint.debug：     文件格式 elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 87 04 00 00       	call   800511 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 2a 1e 80 00       	push   $0x801e2a
  800103:	6a 23                	push   $0x23
  800105:	68 47 1e 80 00       	push   $0x801e47
  80010a:	e8 21 0f 00 00       	call   801030 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 2a 1e 80 00       	push   $0x801e2a
  800184:	6a 23                	push   $0x23
  800186:	68 47 1e 80 00       	push   $0x801e47
  80018b:	e8 a0 0e 00 00       	call   801030 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 2a 1e 80 00       	push   $0x801e2a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 47 1e 80 00       	push   $0x801e47
  8001cd:	e8 5e 0e 00 00       	call   801030 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 2a 1e 80 00       	push   $0x801e2a
  800208:	6a 23                	push   $0x23
  80020a:	68 47 1e 80 00       	push   $0x801e47
  80020f:	e8 1c 0e 00 00       	call   801030 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 2a 1e 80 00       	push   $0x801e2a
  80024a:	6a 23                	push   $0x23
  80024c:	68 47 1e 80 00       	push   $0x801e47
  800251:	e8 da 0d 00 00       	call   801030 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 2a 1e 80 00       	push   $0x801e2a
  80028c:	6a 23                	push   $0x23
  80028e:	68 47 1e 80 00       	push   $0x801e47
  800293:	e8 98 0d 00 00       	call   801030 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 2a 1e 80 00       	push   $0x801e2a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 47 1e 80 00       	push   $0x801e47
  8002d5:	e8 56 0d 00 00       	call   801030 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 2a 1e 80 00       	push   $0x801e2a
  800332:	6a 23                	push   $0x23
  800334:	68 47 1e 80 00       	push   $0x801e47
  800339:	e8 f2 0c 00 00       	call   801030 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 11                	je     80039a <fd_alloc+0x2d>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	75 09                	jne    8003a3 <fd_alloc+0x36>
			*fd_store = fd;
  80039a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039c:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a1:	eb 17                	jmp    8003ba <fd_alloc+0x4d>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 c9                	jne    800378 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	eb 13                	jmp    800410 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb 0c                	jmp    800410 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb 05                	jmp    800410 <fd_lookup+0x54>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba d4 1e 80 00       	mov    $0x801ed4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	eb 13                	jmp    800435 <dev_lookup+0x23>
  800422:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	75 0c                	jne    800435 <dev_lookup+0x23>
			*dev = devtab[i];
  800429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 2e                	jmp    800463 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 e7                	jne    800422 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 04 40 80 00       	mov    0x804004,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 58 1e 80 00       	push   $0x801e58
  80044d:	e8 b7 0c 00 00       	call   801109 <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 10             	sub    $0x10,%esp
  80046d:	8b 75 08             	mov    0x8(%ebp),%esi
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800476:	50                   	push   %eax
  800477:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047d:	c1 e8 0c             	shr    $0xc,%eax
  800480:	50                   	push   %eax
  800481:	e8 36 ff ff ff       	call   8003bc <fd_lookup>
  800486:	83 c4 08             	add    $0x8,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	78 05                	js     800492 <fd_close+0x2d>
	    || fd != fd2)
  80048d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800490:	74 0c                	je     80049e <fd_close+0x39>
		return (must_exist ? r : 0);
  800492:	84 db                	test   %bl,%bl
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
  800499:	0f 44 c2             	cmove  %edx,%eax
  80049c:	eb 41                	jmp    8004df <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a4:	50                   	push   %eax
  8004a5:	ff 36                	pushl  (%esi)
  8004a7:	e8 66 ff ff ff       	call   800412 <dev_lookup>
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 1a                	js     8004cf <fd_close+0x6a>
		if (dev->dev_close)
  8004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	74 0b                	je     8004cf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c4:	83 ec 0c             	sub    $0xc,%esp
  8004c7:	56                   	push   %esi
  8004c8:	ff d0                	call   *%eax
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	56                   	push   %esi
  8004d3:	6a 00                	push   $0x0
  8004d5:	e8 00 fd ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	89 d8                	mov    %ebx,%eax
}
  8004df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e2:	5b                   	pop    %ebx
  8004e3:	5e                   	pop    %esi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 c4 fe ff ff       	call   8003bc <fd_lookup>
  8004f8:	83 c4 08             	add    $0x8,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 10                	js     80050f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	6a 01                	push   $0x1
  800504:	ff 75 f4             	pushl  -0xc(%ebp)
  800507:	e8 59 ff ff ff       	call   800465 <fd_close>
  80050c:	83 c4 10             	add    $0x10,%esp
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <close_all>:

void
close_all(void)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	53                   	push   %ebx
  800515:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800518:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	53                   	push   %ebx
  800521:	e8 c0 ff ff ff       	call   8004e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	83 c3 01             	add    $0x1,%ebx
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	83 fb 20             	cmp    $0x20,%ebx
  80052f:	75 ec                	jne    80051d <close_all+0xc>
		close(i);
}
  800531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 2c             	sub    $0x2c,%esp
  80053f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800542:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 6e fe ff ff       	call   8003bc <fd_lookup>
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	0f 88 c1 00 00 00    	js     80061a <dup+0xe4>
		return r;
	close(newfdnum);
  800559:	83 ec 0c             	sub    $0xc,%esp
  80055c:	56                   	push   %esi
  80055d:	e8 84 ff ff ff       	call   8004e6 <close>

	newfd = INDEX2FD(newfdnum);
  800562:	89 f3                	mov    %esi,%ebx
  800564:	c1 e3 0c             	shl    $0xc,%ebx
  800567:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056d:	83 c4 04             	add    $0x4,%esp
  800570:	ff 75 e4             	pushl  -0x1c(%ebp)
  800573:	e8 de fd ff ff       	call   800356 <fd2data>
  800578:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 d4 fd ff ff       	call   800356 <fd2data>
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800588:	89 f8                	mov    %edi,%eax
  80058a:	c1 e8 16             	shr    $0x16,%eax
  80058d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800594:	a8 01                	test   $0x1,%al
  800596:	74 37                	je     8005cf <dup+0x99>
  800598:	89 f8                	mov    %edi,%eax
  80059a:	c1 e8 0c             	shr    $0xc,%eax
  80059d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a4:	f6 c2 01             	test   $0x1,%dl
  8005a7:	74 26                	je     8005cf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b8:	50                   	push   %eax
  8005b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bc:	6a 00                	push   $0x0
  8005be:	57                   	push   %edi
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 d2 fb ff ff       	call   800198 <sys_page_map>
  8005c6:	89 c7                	mov    %eax,%edi
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 2e                	js     8005fd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d2:	89 d0                	mov    %edx,%eax
  8005d4:	c1 e8 0c             	shr    $0xc,%eax
  8005d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e6:	50                   	push   %eax
  8005e7:	53                   	push   %ebx
  8005e8:	6a 00                	push   $0x0
  8005ea:	52                   	push   %edx
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 a6 fb ff ff       	call   800198 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	79 1d                	jns    80061a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 00                	push   $0x0
  800603:	e8 d2 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800608:	83 c4 08             	add    $0x8,%esp
  80060b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060e:	6a 00                	push   $0x0
  800610:	e8 c5 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	89 f8                	mov    %edi,%eax
}
  80061a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	53                   	push   %ebx
  800626:	83 ec 14             	sub    $0x14,%esp
  800629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062f:	50                   	push   %eax
  800630:	53                   	push   %ebx
  800631:	e8 86 fd ff ff       	call   8003bc <fd_lookup>
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	89 c2                	mov    %eax,%edx
  80063b:	85 c0                	test   %eax,%eax
  80063d:	78 6d                	js     8006ac <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800649:	ff 30                	pushl  (%eax)
  80064b:	e8 c2 fd ff ff       	call   800412 <dev_lookup>
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	85 c0                	test   %eax,%eax
  800655:	78 4c                	js     8006a3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800657:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065a:	8b 42 08             	mov    0x8(%edx),%eax
  80065d:	83 e0 03             	and    $0x3,%eax
  800660:	83 f8 01             	cmp    $0x1,%eax
  800663:	75 21                	jne    800686 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800665:	a1 04 40 80 00       	mov    0x804004,%eax
  80066a:	8b 40 48             	mov    0x48(%eax),%eax
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	53                   	push   %ebx
  800671:	50                   	push   %eax
  800672:	68 99 1e 80 00       	push   $0x801e99
  800677:	e8 8d 0a 00 00       	call   801109 <cprintf>
		return -E_INVAL;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800684:	eb 26                	jmp    8006ac <read+0x8a>
	}
	if (!dev->dev_read)
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	8b 40 08             	mov    0x8(%eax),%eax
  80068c:	85 c0                	test   %eax,%eax
  80068e:	74 17                	je     8006a7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800690:	83 ec 04             	sub    $0x4,%esp
  800693:	ff 75 10             	pushl  0x10(%ebp)
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	52                   	push   %edx
  80069a:	ff d0                	call   *%eax
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb 09                	jmp    8006ac <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a3:	89 c2                	mov    %eax,%edx
  8006a5:	eb 05                	jmp    8006ac <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ac:	89 d0                	mov    %edx,%eax
  8006ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	57                   	push   %edi
  8006b7:	56                   	push   %esi
  8006b8:	53                   	push   %ebx
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	eb 21                	jmp    8006ea <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	29 d8                	sub    %ebx,%eax
  8006d0:	50                   	push   %eax
  8006d1:	89 d8                	mov    %ebx,%eax
  8006d3:	03 45 0c             	add    0xc(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	57                   	push   %edi
  8006d8:	e8 45 ff ff ff       	call   800622 <read>
		if (m < 0)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 10                	js     8006f4 <readn+0x41>
			return m;
		if (m == 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 0a                	je     8006f2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e8:	01 c3                	add    %eax,%ebx
  8006ea:	39 f3                	cmp    %esi,%ebx
  8006ec:	72 db                	jb     8006c9 <readn+0x16>
  8006ee:	89 d8                	mov    %ebx,%eax
  8006f0:	eb 02                	jmp    8006f4 <readn+0x41>
  8006f2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ac fc ff ff       	call   8003bc <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	89 c2                	mov    %eax,%edx
  800715:	85 c0                	test   %eax,%eax
  800717:	78 68                	js     800781 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800723:	ff 30                	pushl  (%eax)
  800725:	e8 e8 fc ff ff       	call   800412 <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 47                	js     800778 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800738:	75 21                	jne    80075b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 04 40 80 00       	mov    0x804004,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	53                   	push   %ebx
  800746:	50                   	push   %eax
  800747:	68 b5 1e 80 00       	push   $0x801eb5
  80074c:	e8 b8 09 00 00       	call   801109 <cprintf>
		return -E_INVAL;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800759:	eb 26                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075e:	8b 52 0c             	mov    0xc(%edx),%edx
  800761:	85 d2                	test   %edx,%edx
  800763:	74 17                	je     80077c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800765:	83 ec 04             	sub    $0x4,%esp
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	50                   	push   %eax
  80076f:	ff d2                	call   *%edx
  800771:	89 c2                	mov    %eax,%edx
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 09                	jmp    800781 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800778:	89 c2                	mov    %eax,%edx
  80077a:	eb 05                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800781:	89 d0                	mov    %edx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <seek>:

int
seek(int fdnum, off_t offset)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	ff 75 08             	pushl  0x8(%ebp)
  800795:	e8 22 fc ff ff       	call   8003bc <fd_lookup>
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 0e                	js     8007af <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 14             	sub    $0x14,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	53                   	push   %ebx
  8007c0:	e8 f7 fb ff ff       	call   8003bc <fd_lookup>
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 65                	js     800833 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	ff 30                	pushl  (%eax)
  8007da:	e8 33 fc ff ff       	call   800412 <dev_lookup>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 44                	js     80082a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ed:	75 21                	jne    800810 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ef:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 78 1e 80 00       	push   $0x801e78
  800801:	e8 03 09 00 00       	call   801109 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080e:	eb 23                	jmp    800833 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800810:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800813:	8b 52 18             	mov    0x18(%edx),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	74 14                	je     80082e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	50                   	push   %eax
  800821:	ff d2                	call   *%edx
  800823:	89 c2                	mov    %eax,%edx
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 09                	jmp    800833 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	eb 05                	jmp    800833 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800833:	89 d0                	mov    %edx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 6c fb ff ff       	call   8003bc <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	89 c2                	mov    %eax,%edx
  800855:	85 c0                	test   %eax,%eax
  800857:	78 58                	js     8008b1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800863:	ff 30                	pushl  (%eax)
  800865:	e8 a8 fb ff ff       	call   800412 <dev_lookup>
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	85 c0                	test   %eax,%eax
  80086f:	78 37                	js     8008a8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800874:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800878:	74 32                	je     8008ac <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800884:	00 00 00 
	stat->st_isdir = 0;
  800887:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088e:	00 00 00 
	stat->st_dev = dev;
  800891:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	ff 75 f0             	pushl  -0x10(%ebp)
  80089e:	ff 50 14             	call   *0x14(%eax)
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 09                	jmp    8008b1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 05                	jmp    8008b1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	6a 00                	push   $0x0
  8008c2:	ff 75 08             	pushl  0x8(%ebp)
  8008c5:	e8 e3 01 00 00       	call   800aad <open>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 1b                	js     8008ee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	50                   	push   %eax
  8008da:	e8 5b ff ff ff       	call   80083a <fstat>
  8008df:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 fd fb ff ff       	call   8004e6 <close>
	return r;
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	89 f0                	mov    %esi,%eax
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	89 c6                	mov    %eax,%esi
  8008fc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800905:	75 12                	jne    800919 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 09 12 00 00       	call   801b1a <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800919:	6a 07                	push   $0x7
  80091b:	68 00 50 80 00       	push   $0x805000
  800920:	56                   	push   %esi
  800921:	ff 35 00 40 80 00    	pushl  0x804000
  800927:	e8 9a 11 00 00       	call   801ac6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092c:	83 c4 0c             	add    $0xc,%esp
  80092f:	6a 00                	push   $0x0
  800931:	53                   	push   %ebx
  800932:	6a 00                	push   $0x0
  800934:	e8 1b 11 00 00       	call   801a54 <ipc_recv>
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 40 0c             	mov    0xc(%eax),%eax
  80094c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 02 00 00 00       	mov    $0x2,%eax
  800963:	e8 8d ff ff ff       	call   8008f5 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 40 0c             	mov    0xc(%eax),%eax
  800976:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	b8 06 00 00 00       	mov    $0x6,%eax
  800985:	e8 6b ff ff ff       	call   8008f5 <fsipc>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	83 ec 04             	sub    $0x4,%esp
  800993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ab:	e8 45 ff ff ff       	call   8008f5 <fsipc>
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	78 2c                	js     8009e0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	68 00 50 80 00       	push   $0x805000
  8009bc:	53                   	push   %ebx
  8009bd:	e8 4b 0d 00 00       	call   80170d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cd:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	83 ec 0c             	sub    $0xc,%esp
  8009eb:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009ee:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009f3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009f8:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fe:	8b 52 0c             	mov    0xc(%edx),%edx
  800a01:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a07:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a0c:	50                   	push   %eax
  800a0d:	ff 75 0c             	pushl  0xc(%ebp)
  800a10:	68 08 50 80 00       	push   $0x805008
  800a15:	e8 85 0e 00 00       	call   80189f <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a24:	e8 cc fe ff ff       	call   8008f5 <fsipc>
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 40 0c             	mov    0xc(%eax),%eax
  800a39:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4e:	e8 a2 fe ff ff       	call   8008f5 <fsipc>
  800a53:	89 c3                	mov    %eax,%ebx
  800a55:	85 c0                	test   %eax,%eax
  800a57:	78 4b                	js     800aa4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a59:	39 c6                	cmp    %eax,%esi
  800a5b:	73 16                	jae    800a73 <devfile_read+0x48>
  800a5d:	68 e4 1e 80 00       	push   $0x801ee4
  800a62:	68 eb 1e 80 00       	push   $0x801eeb
  800a67:	6a 7c                	push   $0x7c
  800a69:	68 00 1f 80 00       	push   $0x801f00
  800a6e:	e8 bd 05 00 00       	call   801030 <_panic>
	assert(r <= PGSIZE);
  800a73:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a78:	7e 16                	jle    800a90 <devfile_read+0x65>
  800a7a:	68 0b 1f 80 00       	push   $0x801f0b
  800a7f:	68 eb 1e 80 00       	push   $0x801eeb
  800a84:	6a 7d                	push   $0x7d
  800a86:	68 00 1f 80 00       	push   $0x801f00
  800a8b:	e8 a0 05 00 00       	call   801030 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a90:	83 ec 04             	sub    $0x4,%esp
  800a93:	50                   	push   %eax
  800a94:	68 00 50 80 00       	push   $0x805000
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	e8 fe 0d 00 00       	call   80189f <memmove>
	return r;
  800aa1:	83 c4 10             	add    $0x10,%esp
}
  800aa4:	89 d8                	mov    %ebx,%eax
  800aa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 20             	sub    $0x20,%esp
  800ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ab7:	53                   	push   %ebx
  800ab8:	e8 17 0c 00 00       	call   8016d4 <strlen>
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac5:	7f 67                	jg     800b2e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acd:	50                   	push   %eax
  800ace:	e8 9a f8 ff ff       	call   80036d <fd_alloc>
  800ad3:	83 c4 10             	add    $0x10,%esp
		return r;
  800ad6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	78 57                	js     800b33 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	53                   	push   %ebx
  800ae0:	68 00 50 80 00       	push   $0x805000
  800ae5:	e8 23 0c 00 00       	call   80170d <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	e8 f6 fd ff ff       	call   8008f5 <fsipc>
  800aff:	89 c3                	mov    %eax,%ebx
  800b01:	83 c4 10             	add    $0x10,%esp
  800b04:	85 c0                	test   %eax,%eax
  800b06:	79 14                	jns    800b1c <open+0x6f>
		fd_close(fd, 0);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	6a 00                	push   $0x0
  800b0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b10:	e8 50 f9 ff ff       	call   800465 <fd_close>
		return r;
  800b15:	83 c4 10             	add    $0x10,%esp
  800b18:	89 da                	mov    %ebx,%edx
  800b1a:	eb 17                	jmp    800b33 <open+0x86>
	}

	return fd2num(fd);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b22:	e8 1f f8 ff ff       	call   800346 <fd2num>
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	83 c4 10             	add    $0x10,%esp
  800b2c:	eb 05                	jmp    800b33 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b2e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b33:	89 d0                	mov    %edx,%eax
  800b35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4a:	e8 a6 fd ff ff       	call   8008f5 <fsipc>
}
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	ff 75 08             	pushl  0x8(%ebp)
  800b5f:	e8 f2 f7 ff ff       	call   800356 <fd2data>
  800b64:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b66:	83 c4 08             	add    $0x8,%esp
  800b69:	68 17 1f 80 00       	push   $0x801f17
  800b6e:	53                   	push   %ebx
  800b6f:	e8 99 0b 00 00       	call   80170d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b74:	8b 46 04             	mov    0x4(%esi),%eax
  800b77:	2b 06                	sub    (%esi),%eax
  800b79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b7f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b86:	00 00 00 
	stat->st_dev = &devpipe;
  800b89:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b90:	30 80 00 
	return 0;
}
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba9:	53                   	push   %ebx
  800baa:	6a 00                	push   $0x0
  800bac:	e8 29 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb1:	89 1c 24             	mov    %ebx,(%esp)
  800bb4:	e8 9d f7 ff ff       	call   800356 <fd2data>
  800bb9:	83 c4 08             	add    $0x8,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 00                	push   $0x0
  800bbf:	e8 16 f6 ff ff       	call   8001da <sys_page_unmap>
}
  800bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 1c             	sub    $0x1c,%esp
  800bd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bd5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bd7:	a1 04 40 80 00       	mov    0x804004,%eax
  800bdc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	ff 75 e0             	pushl  -0x20(%ebp)
  800be5:	e8 69 0f 00 00       	call   801b53 <pageref>
  800bea:	89 c3                	mov    %eax,%ebx
  800bec:	89 3c 24             	mov    %edi,(%esp)
  800bef:	e8 5f 0f 00 00       	call   801b53 <pageref>
  800bf4:	83 c4 10             	add    $0x10,%esp
  800bf7:	39 c3                	cmp    %eax,%ebx
  800bf9:	0f 94 c1             	sete   %cl
  800bfc:	0f b6 c9             	movzbl %cl,%ecx
  800bff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c02:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c08:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0b:	39 ce                	cmp    %ecx,%esi
  800c0d:	74 1b                	je     800c2a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c0f:	39 c3                	cmp    %eax,%ebx
  800c11:	75 c4                	jne    800bd7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c13:	8b 42 58             	mov    0x58(%edx),%eax
  800c16:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c19:	50                   	push   %eax
  800c1a:	56                   	push   %esi
  800c1b:	68 1e 1f 80 00       	push   $0x801f1e
  800c20:	e8 e4 04 00 00       	call   801109 <cprintf>
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	eb ad                	jmp    800bd7 <_pipeisclosed+0xe>
	}
}
  800c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 28             	sub    $0x28,%esp
  800c3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c41:	56                   	push   %esi
  800c42:	e8 0f f7 ff ff       	call   800356 <fd2data>
  800c47:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c51:	eb 4b                	jmp    800c9e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c53:	89 da                	mov    %ebx,%edx
  800c55:	89 f0                	mov    %esi,%eax
  800c57:	e8 6d ff ff ff       	call   800bc9 <_pipeisclosed>
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	75 48                	jne    800ca8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c60:	e8 d1 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c65:	8b 43 04             	mov    0x4(%ebx),%eax
  800c68:	8b 0b                	mov    (%ebx),%ecx
  800c6a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6d:	39 d0                	cmp    %edx,%eax
  800c6f:	73 e2                	jae    800c53 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c78:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	c1 fa 1f             	sar    $0x1f,%edx
  800c80:	89 d1                	mov    %edx,%ecx
  800c82:	c1 e9 1b             	shr    $0x1b,%ecx
  800c85:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c88:	83 e2 1f             	and    $0x1f,%edx
  800c8b:	29 ca                	sub    %ecx,%edx
  800c8d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c95:	83 c0 01             	add    $0x1,%eax
  800c98:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9b:	83 c7 01             	add    $0x1,%edi
  800c9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca1:	75 c2                	jne    800c65 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca6:	eb 05                	jmp    800cad <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 18             	sub    $0x18,%esp
  800cbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc1:	57                   	push   %edi
  800cc2:	e8 8f f6 ff ff       	call   800356 <fd2data>
  800cc7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc9:	83 c4 10             	add    $0x10,%esp
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	eb 3d                	jmp    800d10 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd3:	85 db                	test   %ebx,%ebx
  800cd5:	74 04                	je     800cdb <devpipe_read+0x26>
				return i;
  800cd7:	89 d8                	mov    %ebx,%eax
  800cd9:	eb 44                	jmp    800d1f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	89 f8                	mov    %edi,%eax
  800cdf:	e8 e5 fe ff ff       	call   800bc9 <_pipeisclosed>
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	75 32                	jne    800d1a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ce8:	e8 49 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ced:	8b 06                	mov    (%esi),%eax
  800cef:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf2:	74 df                	je     800cd3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf4:	99                   	cltd   
  800cf5:	c1 ea 1b             	shr    $0x1b,%edx
  800cf8:	01 d0                	add    %edx,%eax
  800cfa:	83 e0 1f             	and    $0x1f,%eax
  800cfd:	29 d0                	sub    %edx,%eax
  800cff:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d0a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0d:	83 c3 01             	add    $0x1,%ebx
  800d10:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d13:	75 d8                	jne    800ced <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d15:	8b 45 10             	mov    0x10(%ebp),%eax
  800d18:	eb 05                	jmp    800d1f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d32:	50                   	push   %eax
  800d33:	e8 35 f6 ff ff       	call   80036d <fd_alloc>
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	0f 88 2c 01 00 00    	js     800e71 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d45:	83 ec 04             	sub    $0x4,%esp
  800d48:	68 07 04 00 00       	push   $0x407
  800d4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d50:	6a 00                	push   $0x0
  800d52:	e8 fe f3 ff ff       	call   800155 <sys_page_alloc>
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	89 c2                	mov    %eax,%edx
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	0f 88 0d 01 00 00    	js     800e71 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6a:	50                   	push   %eax
  800d6b:	e8 fd f5 ff ff       	call   80036d <fd_alloc>
  800d70:	89 c3                	mov    %eax,%ebx
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	85 c0                	test   %eax,%eax
  800d77:	0f 88 e2 00 00 00    	js     800e5f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7d:	83 ec 04             	sub    $0x4,%esp
  800d80:	68 07 04 00 00       	push   $0x407
  800d85:	ff 75 f0             	pushl  -0x10(%ebp)
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 c6 f3 ff ff       	call   800155 <sys_page_alloc>
  800d8f:	89 c3                	mov    %eax,%ebx
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	0f 88 c3 00 00 00    	js     800e5f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800da2:	e8 af f5 ff ff       	call   800356 <fd2data>
  800da7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da9:	83 c4 0c             	add    $0xc,%esp
  800dac:	68 07 04 00 00       	push   $0x407
  800db1:	50                   	push   %eax
  800db2:	6a 00                	push   $0x0
  800db4:	e8 9c f3 ff ff       	call   800155 <sys_page_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 89 00 00 00    	js     800e4f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcc:	e8 85 f5 ff ff       	call   800356 <fd2data>
  800dd1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd8:	50                   	push   %eax
  800dd9:	6a 00                	push   $0x0
  800ddb:	56                   	push   %esi
  800ddc:	6a 00                	push   $0x0
  800dde:	e8 b5 f3 ff ff       	call   800198 <sys_page_map>
  800de3:	89 c3                	mov    %eax,%ebx
  800de5:	83 c4 20             	add    $0x20,%esp
  800de8:	85 c0                	test   %eax,%eax
  800dea:	78 55                	js     800e41 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e01:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1c:	e8 25 f5 ff ff       	call   800346 <fd2num>
  800e21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e26:	83 c4 04             	add    $0x4,%esp
  800e29:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2c:	e8 15 f5 ff ff       	call   800346 <fd2num>
  800e31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e37:	83 c4 10             	add    $0x10,%esp
  800e3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3f:	eb 30                	jmp    800e71 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	56                   	push   %esi
  800e45:	6a 00                	push   $0x0
  800e47:	e8 8e f3 ff ff       	call   8001da <sys_page_unmap>
  800e4c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	ff 75 f0             	pushl  -0x10(%ebp)
  800e55:	6a 00                	push   $0x0
  800e57:	e8 7e f3 ff ff       	call   8001da <sys_page_unmap>
  800e5c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	ff 75 f4             	pushl  -0xc(%ebp)
  800e65:	6a 00                	push   $0x0
  800e67:	e8 6e f3 ff ff       	call   8001da <sys_page_unmap>
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e71:	89 d0                	mov    %edx,%eax
  800e73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e83:	50                   	push   %eax
  800e84:	ff 75 08             	pushl  0x8(%ebp)
  800e87:	e8 30 f5 ff ff       	call   8003bc <fd_lookup>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 18                	js     800eab <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	ff 75 f4             	pushl  -0xc(%ebp)
  800e99:	e8 b8 f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800e9e:	89 c2                	mov    %eax,%edx
  800ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea3:	e8 21 fd ff ff       	call   800bc9 <_pipeisclosed>
  800ea8:	83 c4 10             	add    $0x10,%esp
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ebd:	68 36 1f 80 00       	push   $0x801f36
  800ec2:	ff 75 0c             	pushl  0xc(%ebp)
  800ec5:	e8 43 08 00 00       	call   80170d <strcpy>
	return 0;
}
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	57                   	push   %edi
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
  800ed7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800edd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee8:	eb 2d                	jmp    800f17 <devcons_write+0x46>
		m = n - tot;
  800eea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eed:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800eef:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ef7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efa:	83 ec 04             	sub    $0x4,%esp
  800efd:	53                   	push   %ebx
  800efe:	03 45 0c             	add    0xc(%ebp),%eax
  800f01:	50                   	push   %eax
  800f02:	57                   	push   %edi
  800f03:	e8 97 09 00 00       	call   80189f <memmove>
		sys_cputs(buf, m);
  800f08:	83 c4 08             	add    $0x8,%esp
  800f0b:	53                   	push   %ebx
  800f0c:	57                   	push   %edi
  800f0d:	e8 87 f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f12:	01 de                	add    %ebx,%esi
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	89 f0                	mov    %esi,%eax
  800f19:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1c:	72 cc                	jb     800eea <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 08             	sub    $0x8,%esp
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f35:	74 2a                	je     800f61 <devcons_read+0x3b>
  800f37:	eb 05                	jmp    800f3e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f39:	e8 f8 f1 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f3e:	e8 74 f1 ff ff       	call   8000b7 <sys_cgetc>
  800f43:	85 c0                	test   %eax,%eax
  800f45:	74 f2                	je     800f39 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 16                	js     800f61 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f4b:	83 f8 04             	cmp    $0x4,%eax
  800f4e:	74 0c                	je     800f5c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f53:	88 02                	mov    %al,(%edx)
	return 1;
  800f55:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5a:	eb 05                	jmp    800f61 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f6f:	6a 01                	push   $0x1
  800f71:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	e8 1f f1 ff ff       	call   800099 <sys_cputs>
}
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <getchar>:

int
getchar(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f85:	6a 01                	push   $0x1
  800f87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8a:	50                   	push   %eax
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 90 f6 ff ff       	call   800622 <read>
	if (r < 0)
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 0f                	js     800fa8 <getchar+0x29>
		return r;
	if (r < 1)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	7e 06                	jle    800fa3 <getchar+0x24>
		return -E_EOF;
	return c;
  800f9d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa1:	eb 05                	jmp    800fa8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	ff 75 08             	pushl  0x8(%ebp)
  800fb7:	e8 00 f4 ff ff       	call   8003bc <fd_lookup>
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 11                	js     800fd4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcc:	39 10                	cmp    %edx,(%eax)
  800fce:	0f 94 c0             	sete   %al
  800fd1:	0f b6 c0             	movzbl %al,%eax
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <opencons>:

int
opencons(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	e8 88 f3 ff ff       	call   80036d <fd_alloc>
  800fe5:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 3e                	js     80102c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 07 04 00 00       	push   $0x407
  800ff6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 55 f1 ff ff       	call   800155 <sys_page_alloc>
  801000:	83 c4 10             	add    $0x10,%esp
		return r;
  801003:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	78 23                	js     80102c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801009:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801012:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801017:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	50                   	push   %eax
  801022:	e8 1f f3 ff ff       	call   800346 <fd2num>
  801027:	89 c2                	mov    %eax,%edx
  801029:	83 c4 10             	add    $0x10,%esp
}
  80102c:	89 d0                	mov    %edx,%eax
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801035:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801038:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103e:	e8 d4 f0 ff ff       	call   800117 <sys_getenvid>
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	ff 75 0c             	pushl  0xc(%ebp)
  801049:	ff 75 08             	pushl  0x8(%ebp)
  80104c:	56                   	push   %esi
  80104d:	50                   	push   %eax
  80104e:	68 44 1f 80 00       	push   $0x801f44
  801053:	e8 b1 00 00 00       	call   801109 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801058:	83 c4 18             	add    $0x18,%esp
  80105b:	53                   	push   %ebx
  80105c:	ff 75 10             	pushl  0x10(%ebp)
  80105f:	e8 54 00 00 00       	call   8010b8 <vcprintf>
	cprintf("\n");
  801064:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  80106b:	e8 99 00 00 00       	call   801109 <cprintf>
  801070:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801073:	cc                   	int3   
  801074:	eb fd                	jmp    801073 <_panic+0x43>

00801076 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	53                   	push   %ebx
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801080:	8b 13                	mov    (%ebx),%edx
  801082:	8d 42 01             	lea    0x1(%edx),%eax
  801085:	89 03                	mov    %eax,(%ebx)
  801087:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801093:	75 1a                	jne    8010af <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	68 ff 00 00 00       	push   $0xff
  80109d:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a0:	50                   	push   %eax
  8010a1:	e8 f3 ef ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8010a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ac:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c8:	00 00 00 
	b.cnt = 0;
  8010cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d5:	ff 75 0c             	pushl  0xc(%ebp)
  8010d8:	ff 75 08             	pushl  0x8(%ebp)
  8010db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e1:	50                   	push   %eax
  8010e2:	68 76 10 80 00       	push   $0x801076
  8010e7:	e8 1a 01 00 00       	call   801206 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ec:	83 c4 08             	add    $0x8,%esp
  8010ef:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fb:	50                   	push   %eax
  8010fc:	e8 98 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  801101:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80110f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801112:	50                   	push   %eax
  801113:	ff 75 08             	pushl  0x8(%ebp)
  801116:	e8 9d ff ff ff       	call   8010b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    

0080111d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	57                   	push   %edi
  801121:	56                   	push   %esi
  801122:	53                   	push   %ebx
  801123:	83 ec 1c             	sub    $0x1c,%esp
  801126:	89 c7                	mov    %eax,%edi
  801128:	89 d6                	mov    %edx,%esi
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801130:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801133:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801136:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801139:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801141:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801144:	39 d3                	cmp    %edx,%ebx
  801146:	72 05                	jb     80114d <printnum+0x30>
  801148:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114b:	77 45                	ja     801192 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114d:	83 ec 0c             	sub    $0xc,%esp
  801150:	ff 75 18             	pushl  0x18(%ebp)
  801153:	8b 45 14             	mov    0x14(%ebp),%eax
  801156:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801159:	53                   	push   %ebx
  80115a:	ff 75 10             	pushl  0x10(%ebp)
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	ff 75 e4             	pushl  -0x1c(%ebp)
  801163:	ff 75 e0             	pushl  -0x20(%ebp)
  801166:	ff 75 dc             	pushl  -0x24(%ebp)
  801169:	ff 75 d8             	pushl  -0x28(%ebp)
  80116c:	e8 1f 0a 00 00       	call   801b90 <__udivdi3>
  801171:	83 c4 18             	add    $0x18,%esp
  801174:	52                   	push   %edx
  801175:	50                   	push   %eax
  801176:	89 f2                	mov    %esi,%edx
  801178:	89 f8                	mov    %edi,%eax
  80117a:	e8 9e ff ff ff       	call   80111d <printnum>
  80117f:	83 c4 20             	add    $0x20,%esp
  801182:	eb 18                	jmp    80119c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	56                   	push   %esi
  801188:	ff 75 18             	pushl  0x18(%ebp)
  80118b:	ff d7                	call   *%edi
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	eb 03                	jmp    801195 <printnum+0x78>
  801192:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801195:	83 eb 01             	sub    $0x1,%ebx
  801198:	85 db                	test   %ebx,%ebx
  80119a:	7f e8                	jg     801184 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	56                   	push   %esi
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8011af:	e8 0c 0b 00 00       	call   801cc0 <__umoddi3>
  8011b4:	83 c4 14             	add    $0x14,%esp
  8011b7:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011be:	50                   	push   %eax
  8011bf:	ff d7                	call   *%edi
}
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5f                   	pop    %edi
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011d6:	8b 10                	mov    (%eax),%edx
  8011d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8011db:	73 0a                	jae    8011e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e0:	89 08                	mov    %ecx,(%eax)
  8011e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e5:	88 02                	mov    %al,(%edx)
}
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f2:	50                   	push   %eax
  8011f3:	ff 75 10             	pushl  0x10(%ebp)
  8011f6:	ff 75 0c             	pushl  0xc(%ebp)
  8011f9:	ff 75 08             	pushl  0x8(%ebp)
  8011fc:	e8 05 00 00 00       	call   801206 <vprintfmt>
	va_end(ap);
}
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	c9                   	leave  
  801205:	c3                   	ret    

00801206 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	57                   	push   %edi
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 2c             	sub    $0x2c,%esp
  80120f:	8b 75 08             	mov    0x8(%ebp),%esi
  801212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801215:	8b 7d 10             	mov    0x10(%ebp),%edi
  801218:	eb 12                	jmp    80122c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80121a:	85 c0                	test   %eax,%eax
  80121c:	0f 84 42 04 00 00    	je     801664 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	53                   	push   %ebx
  801226:	50                   	push   %eax
  801227:	ff d6                	call   *%esi
  801229:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80122c:	83 c7 01             	add    $0x1,%edi
  80122f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801233:	83 f8 25             	cmp    $0x25,%eax
  801236:	75 e2                	jne    80121a <vprintfmt+0x14>
  801238:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80123c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801243:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80124a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801251:	b9 00 00 00 00       	mov    $0x0,%ecx
  801256:	eb 07                	jmp    80125f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801258:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80125b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125f:	8d 47 01             	lea    0x1(%edi),%eax
  801262:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801265:	0f b6 07             	movzbl (%edi),%eax
  801268:	0f b6 d0             	movzbl %al,%edx
  80126b:	83 e8 23             	sub    $0x23,%eax
  80126e:	3c 55                	cmp    $0x55,%al
  801270:	0f 87 d3 03 00 00    	ja     801649 <vprintfmt+0x443>
  801276:	0f b6 c0             	movzbl %al,%eax
  801279:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  801280:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801283:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801287:	eb d6                	jmp    80125f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801289:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80128c:	b8 00 00 00 00       	mov    $0x0,%eax
  801291:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801294:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801297:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80129b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80129e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012a1:	83 f9 09             	cmp    $0x9,%ecx
  8012a4:	77 3f                	ja     8012e5 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012a9:	eb e9                	jmp    801294 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ae:	8b 00                	mov    (%eax),%eax
  8012b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b6:	8d 40 04             	lea    0x4(%eax),%eax
  8012b9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012bf:	eb 2a                	jmp    8012eb <vprintfmt+0xe5>
  8012c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cb:	0f 49 d0             	cmovns %eax,%edx
  8012ce:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d4:	eb 89                	jmp    80125f <vprintfmt+0x59>
  8012d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012d9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012e0:	e9 7a ff ff ff       	jmp    80125f <vprintfmt+0x59>
  8012e5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012e8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012ef:	0f 89 6a ff ff ff    	jns    80125f <vprintfmt+0x59>
				width = precision, precision = -1;
  8012f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801302:	e9 58 ff ff ff       	jmp    80125f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801307:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80130d:	e9 4d ff ff ff       	jmp    80125f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801312:	8b 45 14             	mov    0x14(%ebp),%eax
  801315:	8d 78 04             	lea    0x4(%eax),%edi
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	53                   	push   %ebx
  80131c:	ff 30                	pushl  (%eax)
  80131e:	ff d6                	call   *%esi
			break;
  801320:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801323:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801329:	e9 fe fe ff ff       	jmp    80122c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80132e:	8b 45 14             	mov    0x14(%ebp),%eax
  801331:	8d 78 04             	lea    0x4(%eax),%edi
  801334:	8b 00                	mov    (%eax),%eax
  801336:	99                   	cltd   
  801337:	31 d0                	xor    %edx,%eax
  801339:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80133b:	83 f8 0f             	cmp    $0xf,%eax
  80133e:	7f 0b                	jg     80134b <vprintfmt+0x145>
  801340:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  801347:	85 d2                	test   %edx,%edx
  801349:	75 1b                	jne    801366 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80134b:	50                   	push   %eax
  80134c:	68 7f 1f 80 00       	push   $0x801f7f
  801351:	53                   	push   %ebx
  801352:	56                   	push   %esi
  801353:	e8 91 fe ff ff       	call   8011e9 <printfmt>
  801358:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80135b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801361:	e9 c6 fe ff ff       	jmp    80122c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801366:	52                   	push   %edx
  801367:	68 fd 1e 80 00       	push   $0x801efd
  80136c:	53                   	push   %ebx
  80136d:	56                   	push   %esi
  80136e:	e8 76 fe ff ff       	call   8011e9 <printfmt>
  801373:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801376:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80137c:	e9 ab fe ff ff       	jmp    80122c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801381:	8b 45 14             	mov    0x14(%ebp),%eax
  801384:	83 c0 04             	add    $0x4,%eax
  801387:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80138a:	8b 45 14             	mov    0x14(%ebp),%eax
  80138d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80138f:	85 ff                	test   %edi,%edi
  801391:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  801396:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801399:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80139d:	0f 8e 94 00 00 00    	jle    801437 <vprintfmt+0x231>
  8013a3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013a7:	0f 84 98 00 00 00    	je     801445 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b3:	57                   	push   %edi
  8013b4:	e8 33 03 00 00       	call   8016ec <strnlen>
  8013b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013bc:	29 c1                	sub    %eax,%ecx
  8013be:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013c1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013c4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013cb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013ce:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d0:	eb 0f                	jmp    8013e1 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	53                   	push   %ebx
  8013d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8013d9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013db:	83 ef 01             	sub    $0x1,%edi
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	85 ff                	test   %edi,%edi
  8013e3:	7f ed                	jg     8013d2 <vprintfmt+0x1cc>
  8013e5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013e8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013eb:	85 c9                	test   %ecx,%ecx
  8013ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f2:	0f 49 c1             	cmovns %ecx,%eax
  8013f5:	29 c1                	sub    %eax,%ecx
  8013f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8013fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801400:	89 cb                	mov    %ecx,%ebx
  801402:	eb 4d                	jmp    801451 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801404:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801408:	74 1b                	je     801425 <vprintfmt+0x21f>
  80140a:	0f be c0             	movsbl %al,%eax
  80140d:	83 e8 20             	sub    $0x20,%eax
  801410:	83 f8 5e             	cmp    $0x5e,%eax
  801413:	76 10                	jbe    801425 <vprintfmt+0x21f>
					putch('?', putdat);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	ff 75 0c             	pushl  0xc(%ebp)
  80141b:	6a 3f                	push   $0x3f
  80141d:	ff 55 08             	call   *0x8(%ebp)
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	eb 0d                	jmp    801432 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	ff 75 0c             	pushl  0xc(%ebp)
  80142b:	52                   	push   %edx
  80142c:	ff 55 08             	call   *0x8(%ebp)
  80142f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801432:	83 eb 01             	sub    $0x1,%ebx
  801435:	eb 1a                	jmp    801451 <vprintfmt+0x24b>
  801437:	89 75 08             	mov    %esi,0x8(%ebp)
  80143a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80143d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801440:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801443:	eb 0c                	jmp    801451 <vprintfmt+0x24b>
  801445:	89 75 08             	mov    %esi,0x8(%ebp)
  801448:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80144e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801451:	83 c7 01             	add    $0x1,%edi
  801454:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801458:	0f be d0             	movsbl %al,%edx
  80145b:	85 d2                	test   %edx,%edx
  80145d:	74 23                	je     801482 <vprintfmt+0x27c>
  80145f:	85 f6                	test   %esi,%esi
  801461:	78 a1                	js     801404 <vprintfmt+0x1fe>
  801463:	83 ee 01             	sub    $0x1,%esi
  801466:	79 9c                	jns    801404 <vprintfmt+0x1fe>
  801468:	89 df                	mov    %ebx,%edi
  80146a:	8b 75 08             	mov    0x8(%ebp),%esi
  80146d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801470:	eb 18                	jmp    80148a <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	53                   	push   %ebx
  801476:	6a 20                	push   $0x20
  801478:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80147a:	83 ef 01             	sub    $0x1,%edi
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	eb 08                	jmp    80148a <vprintfmt+0x284>
  801482:	89 df                	mov    %ebx,%edi
  801484:	8b 75 08             	mov    0x8(%ebp),%esi
  801487:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80148a:	85 ff                	test   %edi,%edi
  80148c:	7f e4                	jg     801472 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80148e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801491:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801497:	e9 90 fd ff ff       	jmp    80122c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80149c:	83 f9 01             	cmp    $0x1,%ecx
  80149f:	7e 19                	jle    8014ba <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a4:	8b 50 04             	mov    0x4(%eax),%edx
  8014a7:	8b 00                	mov    (%eax),%eax
  8014a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014af:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b2:	8d 40 08             	lea    0x8(%eax),%eax
  8014b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8014b8:	eb 38                	jmp    8014f2 <vprintfmt+0x2ec>
	else if (lflag)
  8014ba:	85 c9                	test   %ecx,%ecx
  8014bc:	74 1b                	je     8014d9 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014be:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c1:	8b 00                	mov    (%eax),%eax
  8014c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c6:	89 c1                	mov    %eax,%ecx
  8014c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8014cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d1:	8d 40 04             	lea    0x4(%eax),%eax
  8014d4:	89 45 14             	mov    %eax,0x14(%ebp)
  8014d7:	eb 19                	jmp    8014f2 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014dc:	8b 00                	mov    (%eax),%eax
  8014de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e1:	89 c1                	mov    %eax,%ecx
  8014e3:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ec:	8d 40 04             	lea    0x4(%eax),%eax
  8014ef:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014f2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014f5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014f8:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801501:	0f 89 0e 01 00 00    	jns    801615 <vprintfmt+0x40f>
				putch('-', putdat);
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	53                   	push   %ebx
  80150b:	6a 2d                	push   $0x2d
  80150d:	ff d6                	call   *%esi
				num = -(long long) num;
  80150f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801512:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801515:	f7 da                	neg    %edx
  801517:	83 d1 00             	adc    $0x0,%ecx
  80151a:	f7 d9                	neg    %ecx
  80151c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80151f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801524:	e9 ec 00 00 00       	jmp    801615 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801529:	83 f9 01             	cmp    $0x1,%ecx
  80152c:	7e 18                	jle    801546 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80152e:	8b 45 14             	mov    0x14(%ebp),%eax
  801531:	8b 10                	mov    (%eax),%edx
  801533:	8b 48 04             	mov    0x4(%eax),%ecx
  801536:	8d 40 08             	lea    0x8(%eax),%eax
  801539:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80153c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801541:	e9 cf 00 00 00       	jmp    801615 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801546:	85 c9                	test   %ecx,%ecx
  801548:	74 1a                	je     801564 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80154a:	8b 45 14             	mov    0x14(%ebp),%eax
  80154d:	8b 10                	mov    (%eax),%edx
  80154f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801554:	8d 40 04             	lea    0x4(%eax),%eax
  801557:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80155a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80155f:	e9 b1 00 00 00       	jmp    801615 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801564:	8b 45 14             	mov    0x14(%ebp),%eax
  801567:	8b 10                	mov    (%eax),%edx
  801569:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156e:	8d 40 04             	lea    0x4(%eax),%eax
  801571:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801574:	b8 0a 00 00 00       	mov    $0xa,%eax
  801579:	e9 97 00 00 00       	jmp    801615 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	53                   	push   %ebx
  801582:	6a 58                	push   $0x58
  801584:	ff d6                	call   *%esi
			putch('X', putdat);
  801586:	83 c4 08             	add    $0x8,%esp
  801589:	53                   	push   %ebx
  80158a:	6a 58                	push   $0x58
  80158c:	ff d6                	call   *%esi
			putch('X', putdat);
  80158e:	83 c4 08             	add    $0x8,%esp
  801591:	53                   	push   %ebx
  801592:	6a 58                	push   $0x58
  801594:	ff d6                	call   *%esi
			break;
  801596:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80159c:	e9 8b fc ff ff       	jmp    80122c <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	6a 30                	push   $0x30
  8015a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	6a 78                	push   $0x78
  8015af:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b4:	8b 10                	mov    (%eax),%edx
  8015b6:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015bb:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015be:	8d 40 04             	lea    0x4(%eax),%eax
  8015c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015c9:	eb 4a                	jmp    801615 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015cb:	83 f9 01             	cmp    $0x1,%ecx
  8015ce:	7e 15                	jle    8015e5 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d3:	8b 10                	mov    (%eax),%edx
  8015d5:	8b 48 04             	mov    0x4(%eax),%ecx
  8015d8:	8d 40 08             	lea    0x8(%eax),%eax
  8015db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015de:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e3:	eb 30                	jmp    801615 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015e5:	85 c9                	test   %ecx,%ecx
  8015e7:	74 17                	je     801600 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ec:	8b 10                	mov    (%eax),%edx
  8015ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f3:	8d 40 04             	lea    0x4(%eax),%eax
  8015f6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015f9:	b8 10 00 00 00       	mov    $0x10,%eax
  8015fe:	eb 15                	jmp    801615 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801600:	8b 45 14             	mov    0x14(%ebp),%eax
  801603:	8b 10                	mov    (%eax),%edx
  801605:	b9 00 00 00 00       	mov    $0x0,%ecx
  80160a:	8d 40 04             	lea    0x4(%eax),%eax
  80160d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801610:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801615:	83 ec 0c             	sub    $0xc,%esp
  801618:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80161c:	57                   	push   %edi
  80161d:	ff 75 e0             	pushl  -0x20(%ebp)
  801620:	50                   	push   %eax
  801621:	51                   	push   %ecx
  801622:	52                   	push   %edx
  801623:	89 da                	mov    %ebx,%edx
  801625:	89 f0                	mov    %esi,%eax
  801627:	e8 f1 fa ff ff       	call   80111d <printnum>
			break;
  80162c:	83 c4 20             	add    $0x20,%esp
  80162f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801632:	e9 f5 fb ff ff       	jmp    80122c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	53                   	push   %ebx
  80163b:	52                   	push   %edx
  80163c:	ff d6                	call   *%esi
			break;
  80163e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801644:	e9 e3 fb ff ff       	jmp    80122c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	53                   	push   %ebx
  80164d:	6a 25                	push   $0x25
  80164f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	eb 03                	jmp    801659 <vprintfmt+0x453>
  801656:	83 ef 01             	sub    $0x1,%edi
  801659:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80165d:	75 f7                	jne    801656 <vprintfmt+0x450>
  80165f:	e9 c8 fb ff ff       	jmp    80122c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5f                   	pop    %edi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 18             	sub    $0x18,%esp
  801672:	8b 45 08             	mov    0x8(%ebp),%eax
  801675:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801678:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80167b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80167f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801682:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801689:	85 c0                	test   %eax,%eax
  80168b:	74 26                	je     8016b3 <vsnprintf+0x47>
  80168d:	85 d2                	test   %edx,%edx
  80168f:	7e 22                	jle    8016b3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801691:	ff 75 14             	pushl  0x14(%ebp)
  801694:	ff 75 10             	pushl  0x10(%ebp)
  801697:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80169a:	50                   	push   %eax
  80169b:	68 cc 11 80 00       	push   $0x8011cc
  8016a0:	e8 61 fb ff ff       	call   801206 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016a8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	eb 05                	jmp    8016b8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016c0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016c3:	50                   	push   %eax
  8016c4:	ff 75 10             	pushl  0x10(%ebp)
  8016c7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ca:	ff 75 08             	pushl  0x8(%ebp)
  8016cd:	e8 9a ff ff ff       	call   80166c <vsnprintf>
	va_end(ap);

	return rc;
}
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016da:	b8 00 00 00 00       	mov    $0x0,%eax
  8016df:	eb 03                	jmp    8016e4 <strlen+0x10>
		n++;
  8016e1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016e8:	75 f7                	jne    8016e1 <strlen+0xd>
		n++;
	return n;
}
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    

008016ec <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fa:	eb 03                	jmp    8016ff <strnlen+0x13>
		n++;
  8016fc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ff:	39 c2                	cmp    %eax,%edx
  801701:	74 08                	je     80170b <strnlen+0x1f>
  801703:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801707:	75 f3                	jne    8016fc <strnlen+0x10>
  801709:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	53                   	push   %ebx
  801711:	8b 45 08             	mov    0x8(%ebp),%eax
  801714:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801717:	89 c2                	mov    %eax,%edx
  801719:	83 c2 01             	add    $0x1,%edx
  80171c:	83 c1 01             	add    $0x1,%ecx
  80171f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801723:	88 5a ff             	mov    %bl,-0x1(%edx)
  801726:	84 db                	test   %bl,%bl
  801728:	75 ef                	jne    801719 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80172a:	5b                   	pop    %ebx
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	53                   	push   %ebx
  801731:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801734:	53                   	push   %ebx
  801735:	e8 9a ff ff ff       	call   8016d4 <strlen>
  80173a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	01 d8                	add    %ebx,%eax
  801742:	50                   	push   %eax
  801743:	e8 c5 ff ff ff       	call   80170d <strcpy>
	return dst;
}
  801748:	89 d8                	mov    %ebx,%eax
  80174a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
  801754:	8b 75 08             	mov    0x8(%ebp),%esi
  801757:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175a:	89 f3                	mov    %esi,%ebx
  80175c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80175f:	89 f2                	mov    %esi,%edx
  801761:	eb 0f                	jmp    801772 <strncpy+0x23>
		*dst++ = *src;
  801763:	83 c2 01             	add    $0x1,%edx
  801766:	0f b6 01             	movzbl (%ecx),%eax
  801769:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80176c:	80 39 01             	cmpb   $0x1,(%ecx)
  80176f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801772:	39 da                	cmp    %ebx,%edx
  801774:	75 ed                	jne    801763 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801776:	89 f0                	mov    %esi,%eax
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	56                   	push   %esi
  801780:	53                   	push   %ebx
  801781:	8b 75 08             	mov    0x8(%ebp),%esi
  801784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801787:	8b 55 10             	mov    0x10(%ebp),%edx
  80178a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80178c:	85 d2                	test   %edx,%edx
  80178e:	74 21                	je     8017b1 <strlcpy+0x35>
  801790:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801794:	89 f2                	mov    %esi,%edx
  801796:	eb 09                	jmp    8017a1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801798:	83 c2 01             	add    $0x1,%edx
  80179b:	83 c1 01             	add    $0x1,%ecx
  80179e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017a1:	39 c2                	cmp    %eax,%edx
  8017a3:	74 09                	je     8017ae <strlcpy+0x32>
  8017a5:	0f b6 19             	movzbl (%ecx),%ebx
  8017a8:	84 db                	test   %bl,%bl
  8017aa:	75 ec                	jne    801798 <strlcpy+0x1c>
  8017ac:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017ae:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017b1:	29 f0                	sub    %esi,%eax
}
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017c0:	eb 06                	jmp    8017c8 <strcmp+0x11>
		p++, q++;
  8017c2:	83 c1 01             	add    $0x1,%ecx
  8017c5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017c8:	0f b6 01             	movzbl (%ecx),%eax
  8017cb:	84 c0                	test   %al,%al
  8017cd:	74 04                	je     8017d3 <strcmp+0x1c>
  8017cf:	3a 02                	cmp    (%edx),%al
  8017d1:	74 ef                	je     8017c2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d3:	0f b6 c0             	movzbl %al,%eax
  8017d6:	0f b6 12             	movzbl (%edx),%edx
  8017d9:	29 d0                	sub    %edx,%eax
}
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	53                   	push   %ebx
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e7:	89 c3                	mov    %eax,%ebx
  8017e9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ec:	eb 06                	jmp    8017f4 <strncmp+0x17>
		n--, p++, q++;
  8017ee:	83 c0 01             	add    $0x1,%eax
  8017f1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017f4:	39 d8                	cmp    %ebx,%eax
  8017f6:	74 15                	je     80180d <strncmp+0x30>
  8017f8:	0f b6 08             	movzbl (%eax),%ecx
  8017fb:	84 c9                	test   %cl,%cl
  8017fd:	74 04                	je     801803 <strncmp+0x26>
  8017ff:	3a 0a                	cmp    (%edx),%cl
  801801:	74 eb                	je     8017ee <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801803:	0f b6 00             	movzbl (%eax),%eax
  801806:	0f b6 12             	movzbl (%edx),%edx
  801809:	29 d0                	sub    %edx,%eax
  80180b:	eb 05                	jmp    801812 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80180d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801812:	5b                   	pop    %ebx
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    

00801815 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181f:	eb 07                	jmp    801828 <strchr+0x13>
		if (*s == c)
  801821:	38 ca                	cmp    %cl,%dl
  801823:	74 0f                	je     801834 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801825:	83 c0 01             	add    $0x1,%eax
  801828:	0f b6 10             	movzbl (%eax),%edx
  80182b:	84 d2                	test   %dl,%dl
  80182d:	75 f2                	jne    801821 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80182f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    

00801836 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	8b 45 08             	mov    0x8(%ebp),%eax
  80183c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801840:	eb 03                	jmp    801845 <strfind+0xf>
  801842:	83 c0 01             	add    $0x1,%eax
  801845:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801848:	38 ca                	cmp    %cl,%dl
  80184a:	74 04                	je     801850 <strfind+0x1a>
  80184c:	84 d2                	test   %dl,%dl
  80184e:	75 f2                	jne    801842 <strfind+0xc>
			break;
	return (char *) s;
}
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    

00801852 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	57                   	push   %edi
  801856:	56                   	push   %esi
  801857:	53                   	push   %ebx
  801858:	8b 7d 08             	mov    0x8(%ebp),%edi
  80185b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80185e:	85 c9                	test   %ecx,%ecx
  801860:	74 36                	je     801898 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801862:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801868:	75 28                	jne    801892 <memset+0x40>
  80186a:	f6 c1 03             	test   $0x3,%cl
  80186d:	75 23                	jne    801892 <memset+0x40>
		c &= 0xFF;
  80186f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801873:	89 d3                	mov    %edx,%ebx
  801875:	c1 e3 08             	shl    $0x8,%ebx
  801878:	89 d6                	mov    %edx,%esi
  80187a:	c1 e6 18             	shl    $0x18,%esi
  80187d:	89 d0                	mov    %edx,%eax
  80187f:	c1 e0 10             	shl    $0x10,%eax
  801882:	09 f0                	or     %esi,%eax
  801884:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801886:	89 d8                	mov    %ebx,%eax
  801888:	09 d0                	or     %edx,%eax
  80188a:	c1 e9 02             	shr    $0x2,%ecx
  80188d:	fc                   	cld    
  80188e:	f3 ab                	rep stos %eax,%es:(%edi)
  801890:	eb 06                	jmp    801898 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801892:	8b 45 0c             	mov    0xc(%ebp),%eax
  801895:	fc                   	cld    
  801896:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801898:	89 f8                	mov    %edi,%eax
  80189a:	5b                   	pop    %ebx
  80189b:	5e                   	pop    %esi
  80189c:	5f                   	pop    %edi
  80189d:	5d                   	pop    %ebp
  80189e:	c3                   	ret    

0080189f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	57                   	push   %edi
  8018a3:	56                   	push   %esi
  8018a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ad:	39 c6                	cmp    %eax,%esi
  8018af:	73 35                	jae    8018e6 <memmove+0x47>
  8018b1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018b4:	39 d0                	cmp    %edx,%eax
  8018b6:	73 2e                	jae    8018e6 <memmove+0x47>
		s += n;
		d += n;
  8018b8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bb:	89 d6                	mov    %edx,%esi
  8018bd:	09 fe                	or     %edi,%esi
  8018bf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018c5:	75 13                	jne    8018da <memmove+0x3b>
  8018c7:	f6 c1 03             	test   $0x3,%cl
  8018ca:	75 0e                	jne    8018da <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018cc:	83 ef 04             	sub    $0x4,%edi
  8018cf:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d2:	c1 e9 02             	shr    $0x2,%ecx
  8018d5:	fd                   	std    
  8018d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d8:	eb 09                	jmp    8018e3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018da:	83 ef 01             	sub    $0x1,%edi
  8018dd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018e0:	fd                   	std    
  8018e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018e3:	fc                   	cld    
  8018e4:	eb 1d                	jmp    801903 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e6:	89 f2                	mov    %esi,%edx
  8018e8:	09 c2                	or     %eax,%edx
  8018ea:	f6 c2 03             	test   $0x3,%dl
  8018ed:	75 0f                	jne    8018fe <memmove+0x5f>
  8018ef:	f6 c1 03             	test   $0x3,%cl
  8018f2:	75 0a                	jne    8018fe <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018f4:	c1 e9 02             	shr    $0x2,%ecx
  8018f7:	89 c7                	mov    %eax,%edi
  8018f9:	fc                   	cld    
  8018fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018fc:	eb 05                	jmp    801903 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018fe:	89 c7                	mov    %eax,%edi
  801900:	fc                   	cld    
  801901:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801903:	5e                   	pop    %esi
  801904:	5f                   	pop    %edi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80190a:	ff 75 10             	pushl  0x10(%ebp)
  80190d:	ff 75 0c             	pushl  0xc(%ebp)
  801910:	ff 75 08             	pushl  0x8(%ebp)
  801913:	e8 87 ff ff ff       	call   80189f <memmove>
}
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	56                   	push   %esi
  80191e:	53                   	push   %ebx
  80191f:	8b 45 08             	mov    0x8(%ebp),%eax
  801922:	8b 55 0c             	mov    0xc(%ebp),%edx
  801925:	89 c6                	mov    %eax,%esi
  801927:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80192a:	eb 1a                	jmp    801946 <memcmp+0x2c>
		if (*s1 != *s2)
  80192c:	0f b6 08             	movzbl (%eax),%ecx
  80192f:	0f b6 1a             	movzbl (%edx),%ebx
  801932:	38 d9                	cmp    %bl,%cl
  801934:	74 0a                	je     801940 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801936:	0f b6 c1             	movzbl %cl,%eax
  801939:	0f b6 db             	movzbl %bl,%ebx
  80193c:	29 d8                	sub    %ebx,%eax
  80193e:	eb 0f                	jmp    80194f <memcmp+0x35>
		s1++, s2++;
  801940:	83 c0 01             	add    $0x1,%eax
  801943:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801946:	39 f0                	cmp    %esi,%eax
  801948:	75 e2                	jne    80192c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80194a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5d                   	pop    %ebp
  801952:	c3                   	ret    

00801953 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	53                   	push   %ebx
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80195a:	89 c1                	mov    %eax,%ecx
  80195c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80195f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801963:	eb 0a                	jmp    80196f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801965:	0f b6 10             	movzbl (%eax),%edx
  801968:	39 da                	cmp    %ebx,%edx
  80196a:	74 07                	je     801973 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196c:	83 c0 01             	add    $0x1,%eax
  80196f:	39 c8                	cmp    %ecx,%eax
  801971:	72 f2                	jb     801965 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801973:	5b                   	pop    %ebx
  801974:	5d                   	pop    %ebp
  801975:	c3                   	ret    

00801976 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	57                   	push   %edi
  80197a:	56                   	push   %esi
  80197b:	53                   	push   %ebx
  80197c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80197f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801982:	eb 03                	jmp    801987 <strtol+0x11>
		s++;
  801984:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801987:	0f b6 01             	movzbl (%ecx),%eax
  80198a:	3c 20                	cmp    $0x20,%al
  80198c:	74 f6                	je     801984 <strtol+0xe>
  80198e:	3c 09                	cmp    $0x9,%al
  801990:	74 f2                	je     801984 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801992:	3c 2b                	cmp    $0x2b,%al
  801994:	75 0a                	jne    8019a0 <strtol+0x2a>
		s++;
  801996:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801999:	bf 00 00 00 00       	mov    $0x0,%edi
  80199e:	eb 11                	jmp    8019b1 <strtol+0x3b>
  8019a0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019a5:	3c 2d                	cmp    $0x2d,%al
  8019a7:	75 08                	jne    8019b1 <strtol+0x3b>
		s++, neg = 1;
  8019a9:	83 c1 01             	add    $0x1,%ecx
  8019ac:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019b7:	75 15                	jne    8019ce <strtol+0x58>
  8019b9:	80 39 30             	cmpb   $0x30,(%ecx)
  8019bc:	75 10                	jne    8019ce <strtol+0x58>
  8019be:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c2:	75 7c                	jne    801a40 <strtol+0xca>
		s += 2, base = 16;
  8019c4:	83 c1 02             	add    $0x2,%ecx
  8019c7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019cc:	eb 16                	jmp    8019e4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019ce:	85 db                	test   %ebx,%ebx
  8019d0:	75 12                	jne    8019e4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019d2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019d7:	80 39 30             	cmpb   $0x30,(%ecx)
  8019da:	75 08                	jne    8019e4 <strtol+0x6e>
		s++, base = 8;
  8019dc:	83 c1 01             	add    $0x1,%ecx
  8019df:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ec:	0f b6 11             	movzbl (%ecx),%edx
  8019ef:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f2:	89 f3                	mov    %esi,%ebx
  8019f4:	80 fb 09             	cmp    $0x9,%bl
  8019f7:	77 08                	ja     801a01 <strtol+0x8b>
			dig = *s - '0';
  8019f9:	0f be d2             	movsbl %dl,%edx
  8019fc:	83 ea 30             	sub    $0x30,%edx
  8019ff:	eb 22                	jmp    801a23 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a01:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a04:	89 f3                	mov    %esi,%ebx
  801a06:	80 fb 19             	cmp    $0x19,%bl
  801a09:	77 08                	ja     801a13 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a0b:	0f be d2             	movsbl %dl,%edx
  801a0e:	83 ea 57             	sub    $0x57,%edx
  801a11:	eb 10                	jmp    801a23 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a13:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a16:	89 f3                	mov    %esi,%ebx
  801a18:	80 fb 19             	cmp    $0x19,%bl
  801a1b:	77 16                	ja     801a33 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a1d:	0f be d2             	movsbl %dl,%edx
  801a20:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a23:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a26:	7d 0b                	jge    801a33 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a28:	83 c1 01             	add    $0x1,%ecx
  801a2b:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a2f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a31:	eb b9                	jmp    8019ec <strtol+0x76>

	if (endptr)
  801a33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a37:	74 0d                	je     801a46 <strtol+0xd0>
		*endptr = (char *) s;
  801a39:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3c:	89 0e                	mov    %ecx,(%esi)
  801a3e:	eb 06                	jmp    801a46 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a40:	85 db                	test   %ebx,%ebx
  801a42:	74 98                	je     8019dc <strtol+0x66>
  801a44:	eb 9e                	jmp    8019e4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a46:	89 c2                	mov    %eax,%edx
  801a48:	f7 da                	neg    %edx
  801a4a:	85 ff                	test   %edi,%edi
  801a4c:	0f 45 c2             	cmovne %edx,%eax
}
  801a4f:	5b                   	pop    %ebx
  801a50:	5e                   	pop    %esi
  801a51:	5f                   	pop    %edi
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801a62:	85 c0                	test   %eax,%eax
  801a64:	74 0e                	je     801a74 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	50                   	push   %eax
  801a6a:	e8 96 e8 ff ff       	call   800305 <sys_ipc_recv>
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	eb 0d                	jmp    801a81 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801a74:	83 ec 0c             	sub    $0xc,%esp
  801a77:	6a ff                	push   $0xffffffff
  801a79:	e8 87 e8 ff ff       	call   800305 <sys_ipc_recv>
  801a7e:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801a81:	85 c0                	test   %eax,%eax
  801a83:	79 16                	jns    801a9b <ipc_recv+0x47>

		if (from_env_store != NULL)
  801a85:	85 f6                	test   %esi,%esi
  801a87:	74 06                	je     801a8f <ipc_recv+0x3b>
			*from_env_store = 0;
  801a89:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801a8f:	85 db                	test   %ebx,%ebx
  801a91:	74 2c                	je     801abf <ipc_recv+0x6b>
			*perm_store = 0;
  801a93:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a99:	eb 24                	jmp    801abf <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801a9b:	85 f6                	test   %esi,%esi
  801a9d:	74 0a                	je     801aa9 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801a9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa4:	8b 40 74             	mov    0x74(%eax),%eax
  801aa7:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801aa9:	85 db                	test   %ebx,%ebx
  801aab:	74 0a                	je     801ab7 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801aad:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab2:	8b 40 78             	mov    0x78(%eax),%eax
  801ab5:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801ab7:	a1 04 40 80 00       	mov    0x804004,%eax
  801abc:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac2:	5b                   	pop    %ebx
  801ac3:	5e                   	pop    %esi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	57                   	push   %edi
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801ad8:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801ada:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801adf:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ae2:	ff 75 14             	pushl  0x14(%ebp)
  801ae5:	53                   	push   %ebx
  801ae6:	56                   	push   %esi
  801ae7:	57                   	push   %edi
  801ae8:	e8 f5 e7 ff ff       	call   8002e2 <sys_ipc_try_send>
		if (r >= 0)
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	85 c0                	test   %eax,%eax
  801af2:	79 1e                	jns    801b12 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801af4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af7:	74 12                	je     801b0b <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801af9:	50                   	push   %eax
  801afa:	68 60 22 80 00       	push   $0x802260
  801aff:	6a 49                	push   $0x49
  801b01:	68 73 22 80 00       	push   $0x802273
  801b06:	e8 25 f5 ff ff       	call   801030 <_panic>
	
		sys_yield();
  801b0b:	e8 26 e6 ff ff       	call   800136 <sys_yield>
	}
  801b10:	eb d0                	jmp    801ae2 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801b12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5f                   	pop    %edi
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b25:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b28:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b2e:	8b 52 50             	mov    0x50(%edx),%edx
  801b31:	39 ca                	cmp    %ecx,%edx
  801b33:	75 0d                	jne    801b42 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b35:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b38:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b3d:	8b 40 48             	mov    0x48(%eax),%eax
  801b40:	eb 0f                	jmp    801b51 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b42:	83 c0 01             	add    $0x1,%eax
  801b45:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4a:	75 d9                	jne    801b25 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b59:	89 d0                	mov    %edx,%eax
  801b5b:	c1 e8 16             	shr    $0x16,%eax
  801b5e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6a:	f6 c1 01             	test   $0x1,%cl
  801b6d:	74 1d                	je     801b8c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b6f:	c1 ea 0c             	shr    $0xc,%edx
  801b72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b79:	f6 c2 01             	test   $0x1,%dl
  801b7c:	74 0e                	je     801b8c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7e:	c1 ea 0c             	shr    $0xc,%edx
  801b81:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b88:	ef 
  801b89:	0f b7 c0             	movzwl %ax,%eax
}
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    
  801b8e:	66 90                	xchg   %ax,%ax

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ba7:	85 f6                	test   %esi,%esi
  801ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bad:	89 ca                	mov    %ecx,%edx
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	75 3d                	jne    801bf0 <__udivdi3+0x60>
  801bb3:	39 cf                	cmp    %ecx,%edi
  801bb5:	0f 87 c5 00 00 00    	ja     801c80 <__udivdi3+0xf0>
  801bbb:	85 ff                	test   %edi,%edi
  801bbd:	89 fd                	mov    %edi,%ebp
  801bbf:	75 0b                	jne    801bcc <__udivdi3+0x3c>
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	31 d2                	xor    %edx,%edx
  801bc8:	f7 f7                	div    %edi
  801bca:	89 c5                	mov    %eax,%ebp
  801bcc:	89 c8                	mov    %ecx,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f5                	div    %ebp
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	89 cf                	mov    %ecx,%edi
  801bd8:	f7 f5                	div    %ebp
  801bda:	89 c3                	mov    %eax,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	39 ce                	cmp    %ecx,%esi
  801bf2:	77 74                	ja     801c68 <__udivdi3+0xd8>
  801bf4:	0f bd fe             	bsr    %esi,%edi
  801bf7:	83 f7 1f             	xor    $0x1f,%edi
  801bfa:	0f 84 98 00 00 00    	je     801c98 <__udivdi3+0x108>
  801c00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	89 c5                	mov    %eax,%ebp
  801c09:	29 fb                	sub    %edi,%ebx
  801c0b:	d3 e6                	shl    %cl,%esi
  801c0d:	89 d9                	mov    %ebx,%ecx
  801c0f:	d3 ed                	shr    %cl,%ebp
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e0                	shl    %cl,%eax
  801c15:	09 ee                	or     %ebp,%esi
  801c17:	89 d9                	mov    %ebx,%ecx
  801c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1d:	89 d5                	mov    %edx,%ebp
  801c1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c23:	d3 ed                	shr    %cl,%ebp
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	d3 e2                	shl    %cl,%edx
  801c29:	89 d9                	mov    %ebx,%ecx
  801c2b:	d3 e8                	shr    %cl,%eax
  801c2d:	09 c2                	or     %eax,%edx
  801c2f:	89 d0                	mov    %edx,%eax
  801c31:	89 ea                	mov    %ebp,%edx
  801c33:	f7 f6                	div    %esi
  801c35:	89 d5                	mov    %edx,%ebp
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	f7 64 24 0c          	mull   0xc(%esp)
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	72 10                	jb     801c51 <__udivdi3+0xc1>
  801c41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e6                	shl    %cl,%esi
  801c49:	39 c6                	cmp    %eax,%esi
  801c4b:	73 07                	jae    801c54 <__udivdi3+0xc4>
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	75 03                	jne    801c54 <__udivdi3+0xc4>
  801c51:	83 eb 01             	sub    $0x1,%ebx
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 d8                	mov    %ebx,%eax
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	31 ff                	xor    %edi,%edi
  801c6a:	31 db                	xor    %ebx,%ebx
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
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	f7 f7                	div    %edi
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	89 fa                	mov    %edi,%edx
  801c8c:	83 c4 1c             	add    $0x1c,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
  801c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c98:	39 ce                	cmp    %ecx,%esi
  801c9a:	72 0c                	jb     801ca8 <__udivdi3+0x118>
  801c9c:	31 db                	xor    %ebx,%ebx
  801c9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ca2:	0f 87 34 ff ff ff    	ja     801bdc <__udivdi3+0x4c>
  801ca8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cad:	e9 2a ff ff ff       	jmp    801bdc <__udivdi3+0x4c>
  801cb2:	66 90                	xchg   %ax,%ax
  801cb4:	66 90                	xchg   %ax,%ax
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ccb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 d2                	test   %edx,%edx
  801cd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ce1:	89 f3                	mov    %esi,%ebx
  801ce3:	89 3c 24             	mov    %edi,(%esp)
  801ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cea:	75 1c                	jne    801d08 <__umoddi3+0x48>
  801cec:	39 f7                	cmp    %esi,%edi
  801cee:	76 50                	jbe    801d40 <__umoddi3+0x80>
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	f7 f7                	div    %edi
  801cf6:	89 d0                	mov    %edx,%eax
  801cf8:	31 d2                	xor    %edx,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	39 f2                	cmp    %esi,%edx
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	77 52                	ja     801d60 <__umoddi3+0xa0>
  801d0e:	0f bd ea             	bsr    %edx,%ebp
  801d11:	83 f5 1f             	xor    $0x1f,%ebp
  801d14:	75 5a                	jne    801d70 <__umoddi3+0xb0>
  801d16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d1a:	0f 82 e0 00 00 00    	jb     801e00 <__umoddi3+0x140>
  801d20:	39 0c 24             	cmp    %ecx,(%esp)
  801d23:	0f 86 d7 00 00 00    	jbe    801e00 <__umoddi3+0x140>
  801d29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	85 ff                	test   %edi,%edi
  801d42:	89 fd                	mov    %edi,%ebp
  801d44:	75 0b                	jne    801d51 <__umoddi3+0x91>
  801d46:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4b:	31 d2                	xor    %edx,%edx
  801d4d:	f7 f7                	div    %edi
  801d4f:	89 c5                	mov    %eax,%ebp
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	f7 f5                	div    %ebp
  801d57:	89 c8                	mov    %ecx,%eax
  801d59:	f7 f5                	div    %ebp
  801d5b:	89 d0                	mov    %edx,%eax
  801d5d:	eb 99                	jmp    801cf8 <__umoddi3+0x38>
  801d5f:	90                   	nop
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 1c             	add    $0x1c,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	8b 34 24             	mov    (%esp),%esi
  801d73:	bf 20 00 00 00       	mov    $0x20,%edi
  801d78:	89 e9                	mov    %ebp,%ecx
  801d7a:	29 ef                	sub    %ebp,%edi
  801d7c:	d3 e0                	shl    %cl,%eax
  801d7e:	89 f9                	mov    %edi,%ecx
  801d80:	89 f2                	mov    %esi,%edx
  801d82:	d3 ea                	shr    %cl,%edx
  801d84:	89 e9                	mov    %ebp,%ecx
  801d86:	09 c2                	or     %eax,%edx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 14 24             	mov    %edx,(%esp)
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	d3 e2                	shl    %cl,%edx
  801d91:	89 f9                	mov    %edi,%ecx
  801d93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d9b:	d3 e8                	shr    %cl,%eax
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	d3 e3                	shl    %cl,%ebx
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 d0                	mov    %edx,%eax
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	09 d8                	or     %ebx,%eax
  801dad:	89 d3                	mov    %edx,%ebx
  801daf:	89 f2                	mov    %esi,%edx
  801db1:	f7 34 24             	divl   (%esp)
  801db4:	89 d6                	mov    %edx,%esi
  801db6:	d3 e3                	shl    %cl,%ebx
  801db8:	f7 64 24 04          	mull   0x4(%esp)
  801dbc:	39 d6                	cmp    %edx,%esi
  801dbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc2:	89 d1                	mov    %edx,%ecx
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	72 08                	jb     801dd0 <__umoddi3+0x110>
  801dc8:	75 11                	jne    801ddb <__umoddi3+0x11b>
  801dca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dce:	73 0b                	jae    801ddb <__umoddi3+0x11b>
  801dd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dd4:	1b 14 24             	sbb    (%esp),%edx
  801dd7:	89 d1                	mov    %edx,%ecx
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ddf:	29 da                	sub    %ebx,%edx
  801de1:	19 ce                	sbb    %ecx,%esi
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 f0                	mov    %esi,%eax
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	d3 ea                	shr    %cl,%edx
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	d3 ee                	shr    %cl,%esi
  801df1:	09 d0                	or     %edx,%eax
  801df3:	89 f2                	mov    %esi,%edx
  801df5:	83 c4 1c             	add    $0x1c,%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	29 f9                	sub    %edi,%ecx
  801e02:	19 d6                	sbb    %edx,%esi
  801e04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e0c:	e9 18 ff ff ff       	jmp    801d29 <__umoddi3+0x69>
