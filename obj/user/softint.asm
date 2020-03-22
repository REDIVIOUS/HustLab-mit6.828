
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	57                   	push   %edi
  80003e:	56                   	push   %esi
  80003f:	53                   	push   %ebx
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	e8 57 00 00 00       	call   80009f <__x86.get_pc_thunk.bx>
  800048:	81 c3 b8 1f 00 00    	add    $0x1fb8,%ebx
  80004e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800051:	c7 c6 2c 20 80 00    	mov    $0x80202c,%esi
  800057:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	thisenv = (struct Env*)(envs + ENVX(sys_getenvid())); //（为当前进程）初始化全局指针
  80005d:	e8 f4 00 00 00       	call   800156 <sys_getenvid>
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80006a:	c1 e0 05             	shl    $0x5,%eax
  80006d:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800073:	89 06                	mov    %eax,(%esi)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800079:	7e 08                	jle    800083 <libmain+0x49>
		binaryname = argv[0];
  80007b:	8b 07                	mov    (%edi),%eax
  80007d:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	57                   	push   %edi
  800087:	ff 75 08             	pushl  0x8(%ebp)
  80008a:	e8 a4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008f:	e8 0f 00 00 00       	call   8000a3 <exit>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5f                   	pop    %edi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    

0080009f <__x86.get_pc_thunk.bx>:
  80009f:	8b 1c 24             	mov    (%esp),%ebx
  8000a2:	c3                   	ret    

008000a3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	53                   	push   %ebx
  8000a7:	83 ec 10             	sub    $0x10,%esp
  8000aa:	e8 f0 ff ff ff       	call   80009f <__x86.get_pc_thunk.bx>
  8000af:	81 c3 51 1f 00 00    	add    $0x1f51,%ebx
	sys_env_destroy(0);
  8000b5:	6a 00                	push   $0x0
  8000b7:	e8 45 00 00 00       	call   800101 <sys_env_destroy>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d5:	89 c3                	mov    %eax,%ebx
  8000d7:	89 c7                	mov    %eax,%edi
  8000d9:	89 c6                	mov    %eax,%esi
  8000db:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f2:	89 d1                	mov    %edx,%ecx
  8000f4:	89 d3                	mov    %edx,%ebx
  8000f6:	89 d7                	mov    %edx,%edi
  8000f8:	89 d6                	mov    %edx,%esi
  8000fa:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	83 ec 1c             	sub    $0x1c,%esp
  80010a:	e8 66 00 00 00       	call   800175 <__x86.get_pc_thunk.ax>
  80010f:	05 f1 1e 00 00       	add    $0x1ef1,%eax
  800114:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800117:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	b8 03 00 00 00       	mov    $0x3,%eax
  800124:	89 cb                	mov    %ecx,%ebx
  800126:	89 cf                	mov    %ecx,%edi
  800128:	89 ce                	mov    %ecx,%esi
  80012a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012c:	85 c0                	test   %eax,%eax
  80012e:	7f 08                	jg     800138 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800133:	5b                   	pop    %ebx
  800134:	5e                   	pop    %esi
  800135:	5f                   	pop    %edi
  800136:	5d                   	pop    %ebp
  800137:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800138:	83 ec 0c             	sub    $0xc,%esp
  80013b:	50                   	push   %eax
  80013c:	6a 03                	push   $0x3
  80013e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800141:	8d 83 76 ee ff ff    	lea    -0x118a(%ebx),%eax
  800147:	50                   	push   %eax
  800148:	6a 23                	push   $0x23
  80014a:	8d 83 93 ee ff ff    	lea    -0x116d(%ebx),%eax
  800150:	50                   	push   %eax
  800151:	e8 23 00 00 00       	call   800179 <_panic>

00800156 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015c:	ba 00 00 00 00       	mov    $0x0,%edx
  800161:	b8 02 00 00 00       	mov    $0x2,%eax
  800166:	89 d1                	mov    %edx,%ecx
  800168:	89 d3                	mov    %edx,%ebx
  80016a:	89 d7                	mov    %edx,%edi
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    

00800175 <__x86.get_pc_thunk.ax>:
  800175:	8b 04 24             	mov    (%esp),%eax
  800178:	c3                   	ret    

00800179 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	e8 18 ff ff ff       	call   80009f <__x86.get_pc_thunk.bx>
  800187:	81 c3 79 1e 00 00    	add    $0x1e79,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800190:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800196:	8b 38                	mov    (%eax),%edi
  800198:	e8 b9 ff ff ff       	call   800156 <sys_getenvid>
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	57                   	push   %edi
  8001a7:	50                   	push   %eax
  8001a8:	8d 83 a4 ee ff ff    	lea    -0x115c(%ebx),%eax
  8001ae:	50                   	push   %eax
  8001af:	e8 d1 00 00 00       	call   800285 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b4:	83 c4 18             	add    $0x18,%esp
  8001b7:	56                   	push   %esi
  8001b8:	ff 75 10             	pushl  0x10(%ebp)
  8001bb:	e8 63 00 00 00       	call   800223 <vcprintf>
	cprintf("\n");
  8001c0:	8d 83 c8 ee ff ff    	lea    -0x1138(%ebx),%eax
  8001c6:	89 04 24             	mov    %eax,(%esp)
  8001c9:	e8 b7 00 00 00       	call   800285 <cprintf>
  8001ce:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d1:	cc                   	int3   
  8001d2:	eb fd                	jmp    8001d1 <_panic+0x58>

008001d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	e8 c1 fe ff ff       	call   80009f <__x86.get_pc_thunk.bx>
  8001de:	81 c3 22 1e 00 00    	add    $0x1e22,%ebx
  8001e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e7:	8b 16                	mov    (%esi),%edx
  8001e9:	8d 42 01             	lea    0x1(%edx),%eax
  8001ec:	89 06                	mov    %eax,(%esi)
  8001ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f1:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fa:	74 0b                	je     800207 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fc:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800200:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	68 ff 00 00 00       	push   $0xff
  80020f:	8d 46 08             	lea    0x8(%esi),%eax
  800212:	50                   	push   %eax
  800213:	e8 ac fe ff ff       	call   8000c4 <sys_cputs>
		b->idx = 0;
  800218:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	eb d9                	jmp    8001fc <putch+0x28>

00800223 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	53                   	push   %ebx
  800227:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022d:	e8 6d fe ff ff       	call   80009f <__x86.get_pc_thunk.bx>
  800232:	81 c3 ce 1d 00 00    	add    $0x1dce,%ebx
	struct printbuf b;

	b.idx = 0;
  800238:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023f:	00 00 00 
	b.cnt = 0;
  800242:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800249:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800258:	50                   	push   %eax
  800259:	8d 83 d4 e1 ff ff    	lea    -0x1e2c(%ebx),%eax
  80025f:	50                   	push   %eax
  800260:	e8 38 01 00 00       	call   80039d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800265:	83 c4 08             	add    $0x8,%esp
  800268:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800274:	50                   	push   %eax
  800275:	e8 4a fe ff ff       	call   8000c4 <sys_cputs>

	return b.cnt;
}
  80027a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800280:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028e:	50                   	push   %eax
  80028f:	ff 75 08             	pushl  0x8(%ebp)
  800292:	e8 8c ff ff ff       	call   800223 <vcprintf>
	va_end(ap);

	return cnt;
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	83 ec 2c             	sub    $0x2c,%esp
  8002a2:	e8 02 06 00 00       	call   8008a9 <__x86.get_pc_thunk.cx>
  8002a7:	81 c1 59 1d 00 00    	add    $0x1d59,%ecx
  8002ad:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002b0:	89 c7                	mov    %eax,%edi
  8002b2:	89 d6                	mov    %edx,%esi
  8002b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002bd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002cb:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002ce:	39 d3                	cmp    %edx,%ebx
  8002d0:	72 09                	jb     8002db <printnum+0x42>
  8002d2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d5:	0f 87 83 00 00 00    	ja     80035e <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	ff 75 18             	pushl  0x18(%ebp)
  8002e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e7:	53                   	push   %ebx
  8002e8:	ff 75 10             	pushl  0x10(%ebp)
  8002eb:	83 ec 08             	sub    $0x8,%esp
  8002ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002fa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002fd:	e8 2e 09 00 00       	call   800c30 <__udivdi3>
  800302:	83 c4 18             	add    $0x18,%esp
  800305:	52                   	push   %edx
  800306:	50                   	push   %eax
  800307:	89 f2                	mov    %esi,%edx
  800309:	89 f8                	mov    %edi,%eax
  80030b:	e8 89 ff ff ff       	call   800299 <printnum>
  800310:	83 c4 20             	add    $0x20,%esp
  800313:	eb 13                	jmp    800328 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	56                   	push   %esi
  800319:	ff 75 18             	pushl  0x18(%ebp)
  80031c:	ff d7                	call   *%edi
  80031e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800321:	83 eb 01             	sub    $0x1,%ebx
  800324:	85 db                	test   %ebx,%ebx
  800326:	7f ed                	jg     800315 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800328:	83 ec 08             	sub    $0x8,%esp
  80032b:	56                   	push   %esi
  80032c:	83 ec 04             	sub    $0x4,%esp
  80032f:	ff 75 dc             	pushl  -0x24(%ebp)
  800332:	ff 75 d8             	pushl  -0x28(%ebp)
  800335:	ff 75 d4             	pushl  -0x2c(%ebp)
  800338:	ff 75 d0             	pushl  -0x30(%ebp)
  80033b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80033e:	89 f3                	mov    %esi,%ebx
  800340:	e8 0b 0a 00 00       	call   800d50 <__umoddi3>
  800345:	83 c4 14             	add    $0x14,%esp
  800348:	0f be 84 06 ca ee ff 	movsbl -0x1136(%esi,%eax,1),%eax
  80034f:	ff 
  800350:	50                   	push   %eax
  800351:	ff d7                	call   *%edi
}
  800353:	83 c4 10             	add    $0x10,%esp
  800356:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800359:	5b                   	pop    %ebx
  80035a:	5e                   	pop    %esi
  80035b:	5f                   	pop    %edi
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    
  80035e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800361:	eb be                	jmp    800321 <printnum+0x88>

00800363 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800369:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	3b 50 04             	cmp    0x4(%eax),%edx
  800372:	73 0a                	jae    80037e <sprintputch+0x1b>
		*b->buf++ = ch;
  800374:	8d 4a 01             	lea    0x1(%edx),%ecx
  800377:	89 08                	mov    %ecx,(%eax)
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	88 02                	mov    %al,(%edx)
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <printfmt>:
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800386:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800389:	50                   	push   %eax
  80038a:	ff 75 10             	pushl  0x10(%ebp)
  80038d:	ff 75 0c             	pushl  0xc(%ebp)
  800390:	ff 75 08             	pushl  0x8(%ebp)
  800393:	e8 05 00 00 00       	call   80039d <vprintfmt>
}
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	c9                   	leave  
  80039c:	c3                   	ret    

0080039d <vprintfmt>:
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	57                   	push   %edi
  8003a1:	56                   	push   %esi
  8003a2:	53                   	push   %ebx
  8003a3:	83 ec 2c             	sub    $0x2c,%esp
  8003a6:	e8 f4 fc ff ff       	call   80009f <__x86.get_pc_thunk.bx>
  8003ab:	81 c3 55 1c 00 00    	add    $0x1c55,%ebx
  8003b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b7:	e9 c3 03 00 00       	jmp    80077f <.L35+0x48>
		padc = ' ';
  8003bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003c7:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003da:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8d 47 01             	lea    0x1(%edi),%eax
  8003e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e3:	0f b6 17             	movzbl (%edi),%edx
  8003e6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e9:	3c 55                	cmp    $0x55,%al
  8003eb:	0f 87 16 04 00 00    	ja     800807 <.L22>
  8003f1:	0f b6 c0             	movzbl %al,%eax
  8003f4:	89 d9                	mov    %ebx,%ecx
  8003f6:	03 8c 83 58 ef ff ff 	add    -0x10a8(%ebx,%eax,4),%ecx
  8003fd:	ff e1                	jmp    *%ecx

008003ff <.L69>:
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800402:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800406:	eb d5                	jmp    8003dd <vprintfmt+0x40>

00800408 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80040b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040f:	eb cc                	jmp    8003dd <vprintfmt+0x40>

00800411 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	0f b6 d2             	movzbl %dl,%edx
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800417:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80041c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800423:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800426:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800429:	83 f9 09             	cmp    $0x9,%ecx
  80042c:	77 55                	ja     800483 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80042e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800431:	eb e9                	jmp    80041c <.L29+0xb>

00800433 <.L26>:
			precision = va_arg(ap, int);
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8b 00                	mov    (%eax),%eax
  800438:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 40 04             	lea    0x4(%eax),%eax
  800441:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044b:	79 90                	jns    8003dd <vprintfmt+0x40>
				width = precision, precision = -1;
  80044d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800450:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800453:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80045a:	eb 81                	jmp    8003dd <vprintfmt+0x40>

0080045c <.L27>:
  80045c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	ba 00 00 00 00       	mov    $0x0,%edx
  800466:	0f 49 d0             	cmovns %eax,%edx
  800469:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046f:	e9 69 ff ff ff       	jmp    8003dd <vprintfmt+0x40>

00800474 <.L23>:
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800477:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047e:	e9 5a ff ff ff       	jmp    8003dd <vprintfmt+0x40>
  800483:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800486:	eb bf                	jmp    800447 <.L26+0x14>

00800488 <.L33>:
			lflag++;
  800488:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80048f:	e9 49 ff ff ff       	jmp    8003dd <vprintfmt+0x40>

00800494 <.L30>:
			putch(va_arg(ap, int), putdat);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 78 04             	lea    0x4(%eax),%edi
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	56                   	push   %esi
  80049e:	ff 30                	pushl  (%eax)
  8004a0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004a6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004a9:	e9 ce 02 00 00       	jmp    80077c <.L35+0x45>

008004ae <.L32>:
			err = va_arg(ap, int);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 78 04             	lea    0x4(%eax),%edi
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	99                   	cltd   
  8004b7:	31 d0                	xor    %edx,%eax
  8004b9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004bb:	83 f8 06             	cmp    $0x6,%eax
  8004be:	7f 27                	jg     8004e7 <.L32+0x39>
  8004c0:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004c7:	85 d2                	test   %edx,%edx
  8004c9:	74 1c                	je     8004e7 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004cb:	52                   	push   %edx
  8004cc:	8d 83 eb ee ff ff    	lea    -0x1115(%ebx),%eax
  8004d2:	50                   	push   %eax
  8004d3:	56                   	push   %esi
  8004d4:	ff 75 08             	pushl  0x8(%ebp)
  8004d7:	e8 a4 fe ff ff       	call   800380 <printfmt>
  8004dc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004df:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e2:	e9 95 02 00 00       	jmp    80077c <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004e7:	50                   	push   %eax
  8004e8:	8d 83 e2 ee ff ff    	lea    -0x111e(%ebx),%eax
  8004ee:	50                   	push   %eax
  8004ef:	56                   	push   %esi
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 88 fe ff ff       	call   800380 <printfmt>
  8004f8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fb:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004fe:	e9 79 02 00 00       	jmp    80077c <.L35+0x45>

00800503 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	83 c0 04             	add    $0x4,%eax
  800509:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800511:	85 ff                	test   %edi,%edi
  800513:	8d 83 db ee ff ff    	lea    -0x1125(%ebx),%eax
  800519:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800520:	0f 8e b5 00 00 00    	jle    8005db <.L36+0xd8>
  800526:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052a:	75 08                	jne    800534 <.L36+0x31>
  80052c:	89 75 0c             	mov    %esi,0xc(%ebp)
  80052f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800532:	eb 6d                	jmp    8005a1 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	ff 75 cc             	pushl  -0x34(%ebp)
  80053a:	57                   	push   %edi
  80053b:	e8 85 03 00 00       	call   8008c5 <strnlen>
  800540:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800543:	29 c2                	sub    %eax,%edx
  800545:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80054b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800552:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800555:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	eb 10                	jmp    800569 <.L36+0x66>
					putch(padc, putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	56                   	push   %esi
  80055d:	ff 75 e0             	pushl  -0x20(%ebp)
  800560:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	83 ef 01             	sub    $0x1,%edi
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	85 ff                	test   %edi,%edi
  80056b:	7f ec                	jg     800559 <.L36+0x56>
  80056d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800570:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800573:	85 d2                	test   %edx,%edx
  800575:	b8 00 00 00 00       	mov    $0x0,%eax
  80057a:	0f 49 c2             	cmovns %edx,%eax
  80057d:	29 c2                	sub    %eax,%edx
  80057f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800582:	89 75 0c             	mov    %esi,0xc(%ebp)
  800585:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800588:	eb 17                	jmp    8005a1 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  80058a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058e:	75 30                	jne    8005c0 <.L36+0xbd>
					putch(ch, putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	ff 75 0c             	pushl  0xc(%ebp)
  800596:	50                   	push   %eax
  800597:	ff 55 08             	call   *0x8(%ebp)
  80059a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005a1:	83 c7 01             	add    $0x1,%edi
  8005a4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a8:	0f be c2             	movsbl %dl,%eax
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	74 52                	je     800601 <.L36+0xfe>
  8005af:	85 f6                	test   %esi,%esi
  8005b1:	78 d7                	js     80058a <.L36+0x87>
  8005b3:	83 ee 01             	sub    $0x1,%esi
  8005b6:	79 d2                	jns    80058a <.L36+0x87>
  8005b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005bb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005be:	eb 32                	jmp    8005f2 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c0:	0f be d2             	movsbl %dl,%edx
  8005c3:	83 ea 20             	sub    $0x20,%edx
  8005c6:	83 fa 5e             	cmp    $0x5e,%edx
  8005c9:	76 c5                	jbe    800590 <.L36+0x8d>
					putch('?', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	ff 75 0c             	pushl  0xc(%ebp)
  8005d1:	6a 3f                	push   $0x3f
  8005d3:	ff 55 08             	call   *0x8(%ebp)
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	eb c2                	jmp    80059d <.L36+0x9a>
  8005db:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005de:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005e1:	eb be                	jmp    8005a1 <.L36+0x9e>
				putch(' ', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	56                   	push   %esi
  8005e7:	6a 20                	push   $0x20
  8005e9:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005ec:	83 ef 01             	sub    $0x1,%edi
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	85 ff                	test   %edi,%edi
  8005f4:	7f ed                	jg     8005e3 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fc:	e9 7b 01 00 00       	jmp    80077c <.L35+0x45>
  800601:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800604:	8b 75 0c             	mov    0xc(%ebp),%esi
  800607:	eb e9                	jmp    8005f2 <.L36+0xef>

00800609 <.L31>:
  800609:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80060c:	83 f9 01             	cmp    $0x1,%ecx
  80060f:	7e 40                	jle    800651 <.L31+0x48>
		return va_arg(*ap, long long);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8b 50 04             	mov    0x4(%eax),%edx
  800617:	8b 00                	mov    (%eax),%eax
  800619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 40 08             	lea    0x8(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800628:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062c:	79 55                	jns    800683 <.L31+0x7a>
				putch('-', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	56                   	push   %esi
  800632:	6a 2d                	push   $0x2d
  800634:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800637:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063d:	f7 da                	neg    %edx
  80063f:	83 d1 00             	adc    $0x0,%ecx
  800642:	f7 d9                	neg    %ecx
  800644:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064c:	e9 10 01 00 00       	jmp    800761 <.L35+0x2a>
	else if (lflag)
  800651:	85 c9                	test   %ecx,%ecx
  800653:	75 17                	jne    80066c <.L31+0x63>
		return va_arg(*ap, int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	99                   	cltd   
  80065e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 40 04             	lea    0x4(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
  80066a:	eb bc                	jmp    800628 <.L31+0x1f>
		return va_arg(*ap, long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	99                   	cltd   
  800675:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 40 04             	lea    0x4(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
  800681:	eb a5                	jmp    800628 <.L31+0x1f>
			num = getint(&ap, lflag);
  800683:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800686:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800689:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068e:	e9 ce 00 00 00       	jmp    800761 <.L35+0x2a>

00800693 <.L37>:
  800693:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800696:	83 f9 01             	cmp    $0x1,%ecx
  800699:	7e 18                	jle    8006b3 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a3:	8d 40 08             	lea    0x8(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ae:	e9 ae 00 00 00       	jmp    800761 <.L35+0x2a>
	else if (lflag)
  8006b3:	85 c9                	test   %ecx,%ecx
  8006b5:	75 1a                	jne    8006d1 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c1:	8d 40 04             	lea    0x4(%eax),%eax
  8006c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cc:	e9 90 00 00 00       	jmp    800761 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e6:	eb 79                	jmp    800761 <.L35+0x2a>

008006e8 <.L34>:
  8006e8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006eb:	83 f9 01             	cmp    $0x1,%ecx
  8006ee:	7e 15                	jle    800705 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 10                	mov    (%eax),%edx
  8006f5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f8:	8d 40 08             	lea    0x8(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006fe:	b8 08 00 00 00       	mov    $0x8,%eax
  800703:	eb 5c                	jmp    800761 <.L35+0x2a>
	else if (lflag)
  800705:	85 c9                	test   %ecx,%ecx
  800707:	75 17                	jne    800720 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8b 10                	mov    (%eax),%edx
  80070e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800713:	8d 40 04             	lea    0x4(%eax),%eax
  800716:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800719:	b8 08 00 00 00       	mov    $0x8,%eax
  80071e:	eb 41                	jmp    800761 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8b 10                	mov    (%eax),%edx
  800725:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072a:	8d 40 04             	lea    0x4(%eax),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800730:	b8 08 00 00 00       	mov    $0x8,%eax
  800735:	eb 2a                	jmp    800761 <.L35+0x2a>

00800737 <.L35>:
			putch('0', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	56                   	push   %esi
  80073b:	6a 30                	push   $0x30
  80073d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800740:	83 c4 08             	add    $0x8,%esp
  800743:	56                   	push   %esi
  800744:	6a 78                	push   $0x78
  800746:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8b 10                	mov    (%eax),%edx
  80074e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800753:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800756:	8d 40 04             	lea    0x4(%eax),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800761:	83 ec 0c             	sub    $0xc,%esp
  800764:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800768:	57                   	push   %edi
  800769:	ff 75 e0             	pushl  -0x20(%ebp)
  80076c:	50                   	push   %eax
  80076d:	51                   	push   %ecx
  80076e:	52                   	push   %edx
  80076f:	89 f2                	mov    %esi,%edx
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
  800774:	e8 20 fb ff ff       	call   800299 <printnum>
			break;
  800779:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80077c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80077f:	83 c7 01             	add    $0x1,%edi
  800782:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800786:	83 f8 25             	cmp    $0x25,%eax
  800789:	0f 84 2d fc ff ff    	je     8003bc <vprintfmt+0x1f>
			if (ch == '\0')
  80078f:	85 c0                	test   %eax,%eax
  800791:	0f 84 91 00 00 00    	je     800828 <.L22+0x21>
			putch(ch, putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	56                   	push   %esi
  80079b:	50                   	push   %eax
  80079c:	ff 55 08             	call   *0x8(%ebp)
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb db                	jmp    80077f <.L35+0x48>

008007a4 <.L38>:
  8007a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007a7:	83 f9 01             	cmp    $0x1,%ecx
  8007aa:	7e 15                	jle    8007c1 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	8b 10                	mov    (%eax),%edx
  8007b1:	8b 48 04             	mov    0x4(%eax),%ecx
  8007b4:	8d 40 08             	lea    0x8(%eax),%eax
  8007b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ba:	b8 10 00 00 00       	mov    $0x10,%eax
  8007bf:	eb a0                	jmp    800761 <.L35+0x2a>
	else if (lflag)
  8007c1:	85 c9                	test   %ecx,%ecx
  8007c3:	75 17                	jne    8007dc <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8b 10                	mov    (%eax),%edx
  8007ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cf:	8d 40 04             	lea    0x4(%eax),%eax
  8007d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d5:	b8 10 00 00 00       	mov    $0x10,%eax
  8007da:	eb 85                	jmp    800761 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8b 10                	mov    (%eax),%edx
  8007e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e6:	8d 40 04             	lea    0x4(%eax),%eax
  8007e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ec:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f1:	e9 6b ff ff ff       	jmp    800761 <.L35+0x2a>

008007f6 <.L25>:
			putch(ch, putdat);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	56                   	push   %esi
  8007fa:	6a 25                	push   $0x25
  8007fc:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	e9 75 ff ff ff       	jmp    80077c <.L35+0x45>

00800807 <.L22>:
			putch('%', putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	56                   	push   %esi
  80080b:	6a 25                	push   $0x25
  80080d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800810:	83 c4 10             	add    $0x10,%esp
  800813:	89 f8                	mov    %edi,%eax
  800815:	eb 03                	jmp    80081a <.L22+0x13>
  800817:	83 e8 01             	sub    $0x1,%eax
  80081a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80081e:	75 f7                	jne    800817 <.L22+0x10>
  800820:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800823:	e9 54 ff ff ff       	jmp    80077c <.L35+0x45>
}
  800828:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5f                   	pop    %edi
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	83 ec 14             	sub    $0x14,%esp
  800837:	e8 63 f8 ff ff       	call   80009f <__x86.get_pc_thunk.bx>
  80083c:	81 c3 c4 17 00 00    	add    $0x17c4,%ebx
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800848:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80084f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800852:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800859:	85 c0                	test   %eax,%eax
  80085b:	74 2b                	je     800888 <vsnprintf+0x58>
  80085d:	85 d2                	test   %edx,%edx
  80085f:	7e 27                	jle    800888 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800861:	ff 75 14             	pushl  0x14(%ebp)
  800864:	ff 75 10             	pushl  0x10(%ebp)
  800867:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086a:	50                   	push   %eax
  80086b:	8d 83 63 e3 ff ff    	lea    -0x1c9d(%ebx),%eax
  800871:	50                   	push   %eax
  800872:	e8 26 fb ff ff       	call   80039d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800877:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800880:	83 c4 10             	add    $0x10,%esp
}
  800883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800886:	c9                   	leave  
  800887:	c3                   	ret    
		return -E_INVAL;
  800888:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088d:	eb f4                	jmp    800883 <vsnprintf+0x53>

0080088f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800895:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800898:	50                   	push   %eax
  800899:	ff 75 10             	pushl  0x10(%ebp)
  80089c:	ff 75 0c             	pushl  0xc(%ebp)
  80089f:	ff 75 08             	pushl  0x8(%ebp)
  8008a2:	e8 89 ff ff ff       	call   800830 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <__x86.get_pc_thunk.cx>:
  8008a9:	8b 0c 24             	mov    (%esp),%ecx
  8008ac:	c3                   	ret    

008008ad <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b8:	eb 03                	jmp    8008bd <strlen+0x10>
		n++;
  8008ba:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008bd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c1:	75 f7                	jne    8008ba <strlen+0xd>
	return n;
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d3:	eb 03                	jmp    8008d8 <strnlen+0x13>
		n++;
  8008d5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d8:	39 d0                	cmp    %edx,%eax
  8008da:	74 06                	je     8008e2 <strnlen+0x1d>
  8008dc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e0:	75 f3                	jne    8008d5 <strnlen+0x10>
	return n;
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	53                   	push   %ebx
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ee:	89 c2                	mov    %eax,%edx
  8008f0:	83 c1 01             	add    $0x1,%ecx
  8008f3:	83 c2 01             	add    $0x1,%edx
  8008f6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008fa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fd:	84 db                	test   %bl,%bl
  8008ff:	75 ef                	jne    8008f0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800901:	5b                   	pop    %ebx
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090b:	53                   	push   %ebx
  80090c:	e8 9c ff ff ff       	call   8008ad <strlen>
  800911:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800914:	ff 75 0c             	pushl  0xc(%ebp)
  800917:	01 d8                	add    %ebx,%eax
  800919:	50                   	push   %eax
  80091a:	e8 c5 ff ff ff       	call   8008e4 <strcpy>
	return dst;
}
  80091f:	89 d8                	mov    %ebx,%eax
  800921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 75 08             	mov    0x8(%ebp),%esi
  80092e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800931:	89 f3                	mov    %esi,%ebx
  800933:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800936:	89 f2                	mov    %esi,%edx
  800938:	eb 0f                	jmp    800949 <strncpy+0x23>
		*dst++ = *src;
  80093a:	83 c2 01             	add    $0x1,%edx
  80093d:	0f b6 01             	movzbl (%ecx),%eax
  800940:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800943:	80 39 01             	cmpb   $0x1,(%ecx)
  800946:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800949:	39 da                	cmp    %ebx,%edx
  80094b:	75 ed                	jne    80093a <strncpy+0x14>
	}
	return ret;
}
  80094d:	89 f0                	mov    %esi,%eax
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 75 08             	mov    0x8(%ebp),%esi
  80095b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800961:	89 f0                	mov    %esi,%eax
  800963:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800967:	85 c9                	test   %ecx,%ecx
  800969:	75 0b                	jne    800976 <strlcpy+0x23>
  80096b:	eb 17                	jmp    800984 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096d:	83 c2 01             	add    $0x1,%edx
  800970:	83 c0 01             	add    $0x1,%eax
  800973:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800976:	39 d8                	cmp    %ebx,%eax
  800978:	74 07                	je     800981 <strlcpy+0x2e>
  80097a:	0f b6 0a             	movzbl (%edx),%ecx
  80097d:	84 c9                	test   %cl,%cl
  80097f:	75 ec                	jne    80096d <strlcpy+0x1a>
		*dst = '\0';
  800981:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800984:	29 f0                	sub    %esi,%eax
}
  800986:	5b                   	pop    %ebx
  800987:	5e                   	pop    %esi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800993:	eb 06                	jmp    80099b <strcmp+0x11>
		p++, q++;
  800995:	83 c1 01             	add    $0x1,%ecx
  800998:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80099b:	0f b6 01             	movzbl (%ecx),%eax
  80099e:	84 c0                	test   %al,%al
  8009a0:	74 04                	je     8009a6 <strcmp+0x1c>
  8009a2:	3a 02                	cmp    (%edx),%al
  8009a4:	74 ef                	je     800995 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a6:	0f b6 c0             	movzbl %al,%eax
  8009a9:	0f b6 12             	movzbl (%edx),%edx
  8009ac:	29 d0                	sub    %edx,%eax
}
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	53                   	push   %ebx
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ba:	89 c3                	mov    %eax,%ebx
  8009bc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009bf:	eb 06                	jmp    8009c7 <strncmp+0x17>
		n--, p++, q++;
  8009c1:	83 c0 01             	add    $0x1,%eax
  8009c4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c7:	39 d8                	cmp    %ebx,%eax
  8009c9:	74 16                	je     8009e1 <strncmp+0x31>
  8009cb:	0f b6 08             	movzbl (%eax),%ecx
  8009ce:	84 c9                	test   %cl,%cl
  8009d0:	74 04                	je     8009d6 <strncmp+0x26>
  8009d2:	3a 0a                	cmp    (%edx),%cl
  8009d4:	74 eb                	je     8009c1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d6:	0f b6 00             	movzbl (%eax),%eax
  8009d9:	0f b6 12             	movzbl (%edx),%edx
  8009dc:	29 d0                	sub    %edx,%eax
}
  8009de:	5b                   	pop    %ebx
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    
		return 0;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e6:	eb f6                	jmp    8009de <strncmp+0x2e>

008009e8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f2:	0f b6 10             	movzbl (%eax),%edx
  8009f5:	84 d2                	test   %dl,%dl
  8009f7:	74 09                	je     800a02 <strchr+0x1a>
		if (*s == c)
  8009f9:	38 ca                	cmp    %cl,%dl
  8009fb:	74 0a                	je     800a07 <strchr+0x1f>
	for (; *s; s++)
  8009fd:	83 c0 01             	add    $0x1,%eax
  800a00:	eb f0                	jmp    8009f2 <strchr+0xa>
			return (char *) s;
	return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a13:	eb 03                	jmp    800a18 <strfind+0xf>
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a1b:	38 ca                	cmp    %cl,%dl
  800a1d:	74 04                	je     800a23 <strfind+0x1a>
  800a1f:	84 d2                	test   %dl,%dl
  800a21:	75 f2                	jne    800a15 <strfind+0xc>
			break;
	return (char *) s;
}
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	57                   	push   %edi
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
  800a2b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a31:	85 c9                	test   %ecx,%ecx
  800a33:	74 13                	je     800a48 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3b:	75 05                	jne    800a42 <memset+0x1d>
  800a3d:	f6 c1 03             	test   $0x3,%cl
  800a40:	74 0d                	je     800a4f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a45:	fc                   	cld    
  800a46:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a48:	89 f8                	mov    %edi,%eax
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    
		c &= 0xFF;
  800a4f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a53:	89 d3                	mov    %edx,%ebx
  800a55:	c1 e3 08             	shl    $0x8,%ebx
  800a58:	89 d0                	mov    %edx,%eax
  800a5a:	c1 e0 18             	shl    $0x18,%eax
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	c1 e6 10             	shl    $0x10,%esi
  800a62:	09 f0                	or     %esi,%eax
  800a64:	09 c2                	or     %eax,%edx
  800a66:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a68:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a6b:	89 d0                	mov    %edx,%eax
  800a6d:	fc                   	cld    
  800a6e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a70:	eb d6                	jmp    800a48 <memset+0x23>

00800a72 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a80:	39 c6                	cmp    %eax,%esi
  800a82:	73 35                	jae    800ab9 <memmove+0x47>
  800a84:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a87:	39 c2                	cmp    %eax,%edx
  800a89:	76 2e                	jbe    800ab9 <memmove+0x47>
		s += n;
		d += n;
  800a8b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8e:	89 d6                	mov    %edx,%esi
  800a90:	09 fe                	or     %edi,%esi
  800a92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a98:	74 0c                	je     800aa6 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9a:	83 ef 01             	sub    $0x1,%edi
  800a9d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa0:	fd                   	std    
  800aa1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa3:	fc                   	cld    
  800aa4:	eb 21                	jmp    800ac7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	f6 c1 03             	test   $0x3,%cl
  800aa9:	75 ef                	jne    800a9a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aab:	83 ef 04             	sub    $0x4,%edi
  800aae:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab4:	fd                   	std    
  800ab5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab7:	eb ea                	jmp    800aa3 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab9:	89 f2                	mov    %esi,%edx
  800abb:	09 c2                	or     %eax,%edx
  800abd:	f6 c2 03             	test   $0x3,%dl
  800ac0:	74 09                	je     800acb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac2:	89 c7                	mov    %eax,%edi
  800ac4:	fc                   	cld    
  800ac5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acb:	f6 c1 03             	test   $0x3,%cl
  800ace:	75 f2                	jne    800ac2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	fc                   	cld    
  800ad6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad8:	eb ed                	jmp    800ac7 <memmove+0x55>

00800ada <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800add:	ff 75 10             	pushl  0x10(%ebp)
  800ae0:	ff 75 0c             	pushl  0xc(%ebp)
  800ae3:	ff 75 08             	pushl  0x8(%ebp)
  800ae6:	e8 87 ff ff ff       	call   800a72 <memmove>
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af8:	89 c6                	mov    %eax,%esi
  800afa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afd:	39 f0                	cmp    %esi,%eax
  800aff:	74 1c                	je     800b1d <memcmp+0x30>
		if (*s1 != *s2)
  800b01:	0f b6 08             	movzbl (%eax),%ecx
  800b04:	0f b6 1a             	movzbl (%edx),%ebx
  800b07:	38 d9                	cmp    %bl,%cl
  800b09:	75 08                	jne    800b13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b0b:	83 c0 01             	add    $0x1,%eax
  800b0e:	83 c2 01             	add    $0x1,%edx
  800b11:	eb ea                	jmp    800afd <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b13:	0f b6 c1             	movzbl %cl,%eax
  800b16:	0f b6 db             	movzbl %bl,%ebx
  800b19:	29 d8                	sub    %ebx,%eax
  800b1b:	eb 05                	jmp    800b22 <memcmp+0x35>
	}

	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b34:	39 d0                	cmp    %edx,%eax
  800b36:	73 09                	jae    800b41 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b38:	38 08                	cmp    %cl,(%eax)
  800b3a:	74 05                	je     800b41 <memfind+0x1b>
	for (; s < ends; s++)
  800b3c:	83 c0 01             	add    $0x1,%eax
  800b3f:	eb f3                	jmp    800b34 <memfind+0xe>
			break;
	return (void *) s;
}
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4f:	eb 03                	jmp    800b54 <strtol+0x11>
		s++;
  800b51:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b54:	0f b6 01             	movzbl (%ecx),%eax
  800b57:	3c 20                	cmp    $0x20,%al
  800b59:	74 f6                	je     800b51 <strtol+0xe>
  800b5b:	3c 09                	cmp    $0x9,%al
  800b5d:	74 f2                	je     800b51 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b5f:	3c 2b                	cmp    $0x2b,%al
  800b61:	74 2e                	je     800b91 <strtol+0x4e>
	int neg = 0;
  800b63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b68:	3c 2d                	cmp    $0x2d,%al
  800b6a:	74 2f                	je     800b9b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b72:	75 05                	jne    800b79 <strtol+0x36>
  800b74:	80 39 30             	cmpb   $0x30,(%ecx)
  800b77:	74 2c                	je     800ba5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b79:	85 db                	test   %ebx,%ebx
  800b7b:	75 0a                	jne    800b87 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b82:	80 39 30             	cmpb   $0x30,(%ecx)
  800b85:	74 28                	je     800baf <strtol+0x6c>
		base = 10;
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b8f:	eb 50                	jmp    800be1 <strtol+0x9e>
		s++;
  800b91:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b94:	bf 00 00 00 00       	mov    $0x0,%edi
  800b99:	eb d1                	jmp    800b6c <strtol+0x29>
		s++, neg = 1;
  800b9b:	83 c1 01             	add    $0x1,%ecx
  800b9e:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba3:	eb c7                	jmp    800b6c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba9:	74 0e                	je     800bb9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bab:	85 db                	test   %ebx,%ebx
  800bad:	75 d8                	jne    800b87 <strtol+0x44>
		s++, base = 8;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb7:	eb ce                	jmp    800b87 <strtol+0x44>
		s += 2, base = 16;
  800bb9:	83 c1 02             	add    $0x2,%ecx
  800bbc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc1:	eb c4                	jmp    800b87 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bc3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bc6:	89 f3                	mov    %esi,%ebx
  800bc8:	80 fb 19             	cmp    $0x19,%bl
  800bcb:	77 29                	ja     800bf6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bcd:	0f be d2             	movsbl %dl,%edx
  800bd0:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd6:	7d 30                	jge    800c08 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd8:	83 c1 01             	add    $0x1,%ecx
  800bdb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bdf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800be1:	0f b6 11             	movzbl (%ecx),%edx
  800be4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be7:	89 f3                	mov    %esi,%ebx
  800be9:	80 fb 09             	cmp    $0x9,%bl
  800bec:	77 d5                	ja     800bc3 <strtol+0x80>
			dig = *s - '0';
  800bee:	0f be d2             	movsbl %dl,%edx
  800bf1:	83 ea 30             	sub    $0x30,%edx
  800bf4:	eb dd                	jmp    800bd3 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bf6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf9:	89 f3                	mov    %esi,%ebx
  800bfb:	80 fb 19             	cmp    $0x19,%bl
  800bfe:	77 08                	ja     800c08 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c00:	0f be d2             	movsbl %dl,%edx
  800c03:	83 ea 37             	sub    $0x37,%edx
  800c06:	eb cb                	jmp    800bd3 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0c:	74 05                	je     800c13 <strtol+0xd0>
		*endptr = (char *) s;
  800c0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c11:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c13:	89 c2                	mov    %eax,%edx
  800c15:	f7 da                	neg    %edx
  800c17:	85 ff                	test   %edi,%edi
  800c19:	0f 45 c2             	cmovne %edx,%eax
}
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    
  800c21:	66 90                	xchg   %ax,%ax
  800c23:	66 90                	xchg   %ax,%ax
  800c25:	66 90                	xchg   %ax,%ax
  800c27:	66 90                	xchg   %ax,%ax
  800c29:	66 90                	xchg   %ax,%ax
  800c2b:	66 90                	xchg   %ax,%ax
  800c2d:	66 90                	xchg   %ax,%ax
  800c2f:	90                   	nop

00800c30 <__udivdi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 1c             	sub    $0x1c,%esp
  800c37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c47:	85 d2                	test   %edx,%edx
  800c49:	75 35                	jne    800c80 <__udivdi3+0x50>
  800c4b:	39 f3                	cmp    %esi,%ebx
  800c4d:	0f 87 bd 00 00 00    	ja     800d10 <__udivdi3+0xe0>
  800c53:	85 db                	test   %ebx,%ebx
  800c55:	89 d9                	mov    %ebx,%ecx
  800c57:	75 0b                	jne    800c64 <__udivdi3+0x34>
  800c59:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5e:	31 d2                	xor    %edx,%edx
  800c60:	f7 f3                	div    %ebx
  800c62:	89 c1                	mov    %eax,%ecx
  800c64:	31 d2                	xor    %edx,%edx
  800c66:	89 f0                	mov    %esi,%eax
  800c68:	f7 f1                	div    %ecx
  800c6a:	89 c6                	mov    %eax,%esi
  800c6c:	89 e8                	mov    %ebp,%eax
  800c6e:	89 f7                	mov    %esi,%edi
  800c70:	f7 f1                	div    %ecx
  800c72:	89 fa                	mov    %edi,%edx
  800c74:	83 c4 1c             	add    $0x1c,%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    
  800c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c80:	39 f2                	cmp    %esi,%edx
  800c82:	77 7c                	ja     800d00 <__udivdi3+0xd0>
  800c84:	0f bd fa             	bsr    %edx,%edi
  800c87:	83 f7 1f             	xor    $0x1f,%edi
  800c8a:	0f 84 98 00 00 00    	je     800d28 <__udivdi3+0xf8>
  800c90:	89 f9                	mov    %edi,%ecx
  800c92:	b8 20 00 00 00       	mov    $0x20,%eax
  800c97:	29 f8                	sub    %edi,%eax
  800c99:	d3 e2                	shl    %cl,%edx
  800c9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c9f:	89 c1                	mov    %eax,%ecx
  800ca1:	89 da                	mov    %ebx,%edx
  800ca3:	d3 ea                	shr    %cl,%edx
  800ca5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ca9:	09 d1                	or     %edx,%ecx
  800cab:	89 f2                	mov    %esi,%edx
  800cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb1:	89 f9                	mov    %edi,%ecx
  800cb3:	d3 e3                	shl    %cl,%ebx
  800cb5:	89 c1                	mov    %eax,%ecx
  800cb7:	d3 ea                	shr    %cl,%edx
  800cb9:	89 f9                	mov    %edi,%ecx
  800cbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cbf:	d3 e6                	shl    %cl,%esi
  800cc1:	89 eb                	mov    %ebp,%ebx
  800cc3:	89 c1                	mov    %eax,%ecx
  800cc5:	d3 eb                	shr    %cl,%ebx
  800cc7:	09 de                	or     %ebx,%esi
  800cc9:	89 f0                	mov    %esi,%eax
  800ccb:	f7 74 24 08          	divl   0x8(%esp)
  800ccf:	89 d6                	mov    %edx,%esi
  800cd1:	89 c3                	mov    %eax,%ebx
  800cd3:	f7 64 24 0c          	mull   0xc(%esp)
  800cd7:	39 d6                	cmp    %edx,%esi
  800cd9:	72 0c                	jb     800ce7 <__udivdi3+0xb7>
  800cdb:	89 f9                	mov    %edi,%ecx
  800cdd:	d3 e5                	shl    %cl,%ebp
  800cdf:	39 c5                	cmp    %eax,%ebp
  800ce1:	73 5d                	jae    800d40 <__udivdi3+0x110>
  800ce3:	39 d6                	cmp    %edx,%esi
  800ce5:	75 59                	jne    800d40 <__udivdi3+0x110>
  800ce7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cea:	31 ff                	xor    %edi,%edi
  800cec:	89 fa                	mov    %edi,%edx
  800cee:	83 c4 1c             	add    $0x1c,%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
  800cf6:	8d 76 00             	lea    0x0(%esi),%esi
  800cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d00:	31 ff                	xor    %edi,%edi
  800d02:	31 c0                	xor    %eax,%eax
  800d04:	89 fa                	mov    %edi,%edx
  800d06:	83 c4 1c             	add    $0x1c,%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    
  800d0e:	66 90                	xchg   %ax,%ax
  800d10:	31 ff                	xor    %edi,%edi
  800d12:	89 e8                	mov    %ebp,%eax
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	f7 f3                	div    %ebx
  800d18:	89 fa                	mov    %edi,%edx
  800d1a:	83 c4 1c             	add    $0x1c,%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
  800d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d28:	39 f2                	cmp    %esi,%edx
  800d2a:	72 06                	jb     800d32 <__udivdi3+0x102>
  800d2c:	31 c0                	xor    %eax,%eax
  800d2e:	39 eb                	cmp    %ebp,%ebx
  800d30:	77 d2                	ja     800d04 <__udivdi3+0xd4>
  800d32:	b8 01 00 00 00       	mov    $0x1,%eax
  800d37:	eb cb                	jmp    800d04 <__udivdi3+0xd4>
  800d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d40:	89 d8                	mov    %ebx,%eax
  800d42:	31 ff                	xor    %edi,%edi
  800d44:	eb be                	jmp    800d04 <__udivdi3+0xd4>
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__umoddi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
  800d57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d67:	85 ed                	test   %ebp,%ebp
  800d69:	89 f0                	mov    %esi,%eax
  800d6b:	89 da                	mov    %ebx,%edx
  800d6d:	75 19                	jne    800d88 <__umoddi3+0x38>
  800d6f:	39 df                	cmp    %ebx,%edi
  800d71:	0f 86 b1 00 00 00    	jbe    800e28 <__umoddi3+0xd8>
  800d77:	f7 f7                	div    %edi
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	83 c4 1c             	add    $0x1c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
  800d88:	39 dd                	cmp    %ebx,%ebp
  800d8a:	77 f1                	ja     800d7d <__umoddi3+0x2d>
  800d8c:	0f bd cd             	bsr    %ebp,%ecx
  800d8f:	83 f1 1f             	xor    $0x1f,%ecx
  800d92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d96:	0f 84 b4 00 00 00    	je     800e50 <__umoddi3+0x100>
  800d9c:	b8 20 00 00 00       	mov    $0x20,%eax
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800da7:	29 c2                	sub    %eax,%edx
  800da9:	89 c1                	mov    %eax,%ecx
  800dab:	89 f8                	mov    %edi,%eax
  800dad:	d3 e5                	shl    %cl,%ebp
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800db5:	d3 e8                	shr    %cl,%eax
  800db7:	09 c5                	or     %eax,%ebp
  800db9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dbd:	89 c1                	mov    %eax,%ecx
  800dbf:	d3 e7                	shl    %cl,%edi
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	d3 ef                	shr    %cl,%edi
  800dcb:	89 c1                	mov    %eax,%ecx
  800dcd:	89 f0                	mov    %esi,%eax
  800dcf:	d3 e3                	shl    %cl,%ebx
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 fa                	mov    %edi,%edx
  800dd5:	d3 e8                	shr    %cl,%eax
  800dd7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ddc:	09 d8                	or     %ebx,%eax
  800dde:	f7 f5                	div    %ebp
  800de0:	d3 e6                	shl    %cl,%esi
  800de2:	89 d1                	mov    %edx,%ecx
  800de4:	f7 64 24 08          	mull   0x8(%esp)
  800de8:	39 d1                	cmp    %edx,%ecx
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	72 06                	jb     800df6 <__umoddi3+0xa6>
  800df0:	75 0e                	jne    800e00 <__umoddi3+0xb0>
  800df2:	39 c6                	cmp    %eax,%esi
  800df4:	73 0a                	jae    800e00 <__umoddi3+0xb0>
  800df6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dfa:	19 ea                	sbb    %ebp,%edx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	89 c3                	mov    %eax,%ebx
  800e00:	89 ca                	mov    %ecx,%edx
  800e02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e07:	29 de                	sub    %ebx,%esi
  800e09:	19 fa                	sbb    %edi,%edx
  800e0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e0f:	89 d0                	mov    %edx,%eax
  800e11:	d3 e0                	shl    %cl,%eax
  800e13:	89 d9                	mov    %ebx,%ecx
  800e15:	d3 ee                	shr    %cl,%esi
  800e17:	d3 ea                	shr    %cl,%edx
  800e19:	09 f0                	or     %esi,%eax
  800e1b:	83 c4 1c             	add    $0x1c,%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    
  800e23:	90                   	nop
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	85 ff                	test   %edi,%edi
  800e2a:	89 f9                	mov    %edi,%ecx
  800e2c:	75 0b                	jne    800e39 <__umoddi3+0xe9>
  800e2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e33:	31 d2                	xor    %edx,%edx
  800e35:	f7 f7                	div    %edi
  800e37:	89 c1                	mov    %eax,%ecx
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	f7 f1                	div    %ecx
  800e3f:	89 f0                	mov    %esi,%eax
  800e41:	f7 f1                	div    %ecx
  800e43:	e9 31 ff ff ff       	jmp    800d79 <__umoddi3+0x29>
  800e48:	90                   	nop
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	39 dd                	cmp    %ebx,%ebp
  800e52:	72 08                	jb     800e5c <__umoddi3+0x10c>
  800e54:	39 f7                	cmp    %esi,%edi
  800e56:	0f 87 21 ff ff ff    	ja     800d7d <__umoddi3+0x2d>
  800e5c:	89 da                	mov    %ebx,%edx
  800e5e:	89 f0                	mov    %esi,%eax
  800e60:	29 f8                	sub    %edi,%eax
  800e62:	19 ea                	sbb    %ebp,%edx
  800e64:	e9 14 ff ff ff       	jmp    800d7d <__umoddi3+0x2d>
