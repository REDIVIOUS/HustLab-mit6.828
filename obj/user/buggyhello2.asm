
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 30 00 00 00       	call   800061 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1e 00 00 00       	call   80005d <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs(hello, 1024*1024);
  800045:	68 00 00 10 00       	push   $0x100000
  80004a:	ff b3 0c 00 00 00    	pushl  0xc(%ebx)
  800050:	e8 92 00 00 00       	call   8000e7 <sys_cputs>
}
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <__x86.get_pc_thunk.bx>:
  80005d:	8b 1c 24             	mov    (%esp),%ebx
  800060:	c3                   	ret    

00800061 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	57                   	push   %edi
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	83 ec 0c             	sub    $0xc,%esp
  80006a:	e8 ee ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800078:	c7 c6 30 20 80 00    	mov    $0x802030,%esi
  80007e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	thisenv = (struct Env*)(envs + ENVX(sys_getenvid())); //（为当前进程）初始化全局指针
  800084:	e8 f0 00 00 00       	call   800179 <sys_getenvid>
  800089:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800091:	c1 e0 05             	shl    $0x5,%eax
  800094:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80009a:	89 06                	mov    %eax,(%esi)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000a0:	7e 08                	jle    8000aa <libmain+0x49>
		binaryname = argv[0];
  8000a2:	8b 07                	mov    (%edi),%eax
  8000a4:	89 83 10 00 00 00    	mov    %eax,0x10(%ebx)

	// call user main routine
	umain(argc, argv);
  8000aa:	83 ec 08             	sub    $0x8,%esp
  8000ad:	57                   	push   %edi
  8000ae:	ff 75 08             	pushl  0x8(%ebp)
  8000b1:	e8 7d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b6:	e8 0b 00 00 00       	call   8000c6 <exit>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	53                   	push   %ebx
  8000ca:	83 ec 10             	sub    $0x10,%esp
  8000cd:	e8 8b ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8000d2:	81 c3 2e 1f 00 00    	add    $0x1f2e,%ebx
	sys_env_destroy(0);
  8000d8:	6a 00                	push   $0x0
  8000da:	e8 45 00 00 00       	call   800124 <sys_env_destroy>
}
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    

008000e7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f8:	89 c3                	mov    %eax,%ebx
  8000fa:	89 c7                	mov    %eax,%edi
  8000fc:	89 c6                	mov    %eax,%esi
  8000fe:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <sys_cgetc>:

int
sys_cgetc(void)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80010b:	ba 00 00 00 00       	mov    $0x0,%edx
  800110:	b8 01 00 00 00       	mov    $0x1,%eax
  800115:	89 d1                	mov    %edx,%ecx
  800117:	89 d3                	mov    %edx,%ebx
  800119:	89 d7                	mov    %edx,%edi
  80011b:	89 d6                	mov    %edx,%esi
  80011d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 1c             	sub    $0x1c,%esp
  80012d:	e8 66 00 00 00       	call   800198 <__x86.get_pc_thunk.ax>
  800132:	05 ce 1e 00 00       	add    $0x1ece,%eax
  800137:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80013a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013f:	8b 55 08             	mov    0x8(%ebp),%edx
  800142:	b8 03 00 00 00       	mov    $0x3,%eax
  800147:	89 cb                	mov    %ecx,%ebx
  800149:	89 cf                	mov    %ecx,%edi
  80014b:	89 ce                	mov    %ecx,%esi
  80014d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80014f:	85 c0                	test   %eax,%eax
  800151:	7f 08                	jg     80015b <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	50                   	push   %eax
  80015f:	6a 03                	push   $0x3
  800161:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800164:	8d 83 a4 ee ff ff    	lea    -0x115c(%ebx),%eax
  80016a:	50                   	push   %eax
  80016b:	6a 23                	push   $0x23
  80016d:	8d 83 c1 ee ff ff    	lea    -0x113f(%ebx),%eax
  800173:	50                   	push   %eax
  800174:	e8 23 00 00 00       	call   80019c <_panic>

00800179 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80017f:	ba 00 00 00 00       	mov    $0x0,%edx
  800184:	b8 02 00 00 00       	mov    $0x2,%eax
  800189:	89 d1                	mov    %edx,%ecx
  80018b:	89 d3                	mov    %edx,%ebx
  80018d:	89 d7                	mov    %edx,%edi
  80018f:	89 d6                	mov    %edx,%esi
  800191:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <__x86.get_pc_thunk.ax>:
  800198:	8b 04 24             	mov    (%esp),%eax
  80019b:	c3                   	ret    

0080019c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	57                   	push   %edi
  8001a0:	56                   	push   %esi
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	e8 b3 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001aa:	81 c3 56 1e 00 00    	add    $0x1e56,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001b0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b3:	c7 c0 10 20 80 00    	mov    $0x802010,%eax
  8001b9:	8b 38                	mov    (%eax),%edi
  8001bb:	e8 b9 ff ff ff       	call   800179 <sys_getenvid>
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	ff 75 0c             	pushl  0xc(%ebp)
  8001c6:	ff 75 08             	pushl  0x8(%ebp)
  8001c9:	57                   	push   %edi
  8001ca:	50                   	push   %eax
  8001cb:	8d 83 d0 ee ff ff    	lea    -0x1130(%ebx),%eax
  8001d1:	50                   	push   %eax
  8001d2:	e8 d1 00 00 00       	call   8002a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d7:	83 c4 18             	add    $0x18,%esp
  8001da:	56                   	push   %esi
  8001db:	ff 75 10             	pushl  0x10(%ebp)
  8001de:	e8 63 00 00 00       	call   800246 <vcprintf>
	cprintf("\n");
  8001e3:	8d 83 98 ee ff ff    	lea    -0x1168(%ebx),%eax
  8001e9:	89 04 24             	mov    %eax,(%esp)
  8001ec:	e8 b7 00 00 00       	call   8002a8 <cprintf>
  8001f1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f4:	cc                   	int3   
  8001f5:	eb fd                	jmp    8001f4 <_panic+0x58>

008001f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	56                   	push   %esi
  8001fb:	53                   	push   %ebx
  8001fc:	e8 5c fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800201:	81 c3 ff 1d 00 00    	add    $0x1dff,%ebx
  800207:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  80020a:	8b 16                	mov    (%esi),%edx
  80020c:	8d 42 01             	lea    0x1(%edx),%eax
  80020f:	89 06                	mov    %eax,(%esi)
  800211:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800214:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800218:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021d:	74 0b                	je     80022a <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80021f:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	68 ff 00 00 00       	push   $0xff
  800232:	8d 46 08             	lea    0x8(%esi),%eax
  800235:	50                   	push   %eax
  800236:	e8 ac fe ff ff       	call   8000e7 <sys_cputs>
		b->idx = 0;
  80023b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	eb d9                	jmp    80021f <putch+0x28>

00800246 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	53                   	push   %ebx
  80024a:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800250:	e8 08 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800255:	81 c3 ab 1d 00 00    	add    $0x1dab,%ebx
	struct printbuf b;

	b.idx = 0;
  80025b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800262:	00 00 00 
	b.cnt = 0;
  800265:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80026c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026f:	ff 75 0c             	pushl  0xc(%ebp)
  800272:	ff 75 08             	pushl  0x8(%ebp)
  800275:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80027b:	50                   	push   %eax
  80027c:	8d 83 f7 e1 ff ff    	lea    -0x1e09(%ebx),%eax
  800282:	50                   	push   %eax
  800283:	e8 38 01 00 00       	call   8003c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800288:	83 c4 08             	add    $0x8,%esp
  80028b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800291:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800297:	50                   	push   %eax
  800298:	e8 4a fe ff ff       	call   8000e7 <sys_cputs>

	return b.cnt;
}
  80029d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b1:	50                   	push   %eax
  8002b2:	ff 75 08             	pushl  0x8(%ebp)
  8002b5:	e8 8c ff ff ff       	call   800246 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 2c             	sub    $0x2c,%esp
  8002c5:	e8 02 06 00 00       	call   8008cc <__x86.get_pc_thunk.cx>
  8002ca:	81 c1 36 1d 00 00    	add    $0x1d36,%ecx
  8002d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002d3:	89 c7                	mov    %eax,%edi
  8002d5:	89 d6                	mov    %edx,%esi
  8002d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002eb:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002ee:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002f1:	39 d3                	cmp    %edx,%ebx
  8002f3:	72 09                	jb     8002fe <printnum+0x42>
  8002f5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f8:	0f 87 83 00 00 00    	ja     800381 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002fe:	83 ec 0c             	sub    $0xc,%esp
  800301:	ff 75 18             	pushl  0x18(%ebp)
  800304:	8b 45 14             	mov    0x14(%ebp),%eax
  800307:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030a:	53                   	push   %ebx
  80030b:	ff 75 10             	pushl  0x10(%ebp)
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	ff 75 dc             	pushl  -0x24(%ebp)
  800314:	ff 75 d8             	pushl  -0x28(%ebp)
  800317:	ff 75 d4             	pushl  -0x2c(%ebp)
  80031a:	ff 75 d0             	pushl  -0x30(%ebp)
  80031d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800320:	e8 2b 09 00 00       	call   800c50 <__udivdi3>
  800325:	83 c4 18             	add    $0x18,%esp
  800328:	52                   	push   %edx
  800329:	50                   	push   %eax
  80032a:	89 f2                	mov    %esi,%edx
  80032c:	89 f8                	mov    %edi,%eax
  80032e:	e8 89 ff ff ff       	call   8002bc <printnum>
  800333:	83 c4 20             	add    $0x20,%esp
  800336:	eb 13                	jmp    80034b <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800338:	83 ec 08             	sub    $0x8,%esp
  80033b:	56                   	push   %esi
  80033c:	ff 75 18             	pushl  0x18(%ebp)
  80033f:	ff d7                	call   *%edi
  800341:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800344:	83 eb 01             	sub    $0x1,%ebx
  800347:	85 db                	test   %ebx,%ebx
  800349:	7f ed                	jg     800338 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	56                   	push   %esi
  80034f:	83 ec 04             	sub    $0x4,%esp
  800352:	ff 75 dc             	pushl  -0x24(%ebp)
  800355:	ff 75 d8             	pushl  -0x28(%ebp)
  800358:	ff 75 d4             	pushl  -0x2c(%ebp)
  80035b:	ff 75 d0             	pushl  -0x30(%ebp)
  80035e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800361:	89 f3                	mov    %esi,%ebx
  800363:	e8 08 0a 00 00       	call   800d70 <__umoddi3>
  800368:	83 c4 14             	add    $0x14,%esp
  80036b:	0f be 84 06 f4 ee ff 	movsbl -0x110c(%esi,%eax,1),%eax
  800372:	ff 
  800373:	50                   	push   %eax
  800374:	ff d7                	call   *%edi
}
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    
  800381:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800384:	eb be                	jmp    800344 <printnum+0x88>

00800386 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800390:	8b 10                	mov    (%eax),%edx
  800392:	3b 50 04             	cmp    0x4(%eax),%edx
  800395:	73 0a                	jae    8003a1 <sprintputch+0x1b>
		*b->buf++ = ch;
  800397:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039a:	89 08                	mov    %ecx,(%eax)
  80039c:	8b 45 08             	mov    0x8(%ebp),%eax
  80039f:	88 02                	mov    %al,(%edx)
}
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <printfmt>:
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ac:	50                   	push   %eax
  8003ad:	ff 75 10             	pushl  0x10(%ebp)
  8003b0:	ff 75 0c             	pushl  0xc(%ebp)
  8003b3:	ff 75 08             	pushl  0x8(%ebp)
  8003b6:	e8 05 00 00 00       	call   8003c0 <vprintfmt>
}
  8003bb:	83 c4 10             	add    $0x10,%esp
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <vprintfmt>:
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	57                   	push   %edi
  8003c4:	56                   	push   %esi
  8003c5:	53                   	push   %ebx
  8003c6:	83 ec 2c             	sub    $0x2c,%esp
  8003c9:	e8 8f fc ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8003ce:	81 c3 32 1c 00 00    	add    $0x1c32,%ebx
  8003d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003da:	e9 c3 03 00 00       	jmp    8007a2 <.L35+0x48>
		padc = ' ';
  8003df:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003ea:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8d 47 01             	lea    0x1(%edi),%eax
  800403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800406:	0f b6 17             	movzbl (%edi),%edx
  800409:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040c:	3c 55                	cmp    $0x55,%al
  80040e:	0f 87 16 04 00 00    	ja     80082a <.L22>
  800414:	0f b6 c0             	movzbl %al,%eax
  800417:	89 d9                	mov    %ebx,%ecx
  800419:	03 8c 83 84 ef ff ff 	add    -0x107c(%ebx,%eax,4),%ecx
  800420:	ff e1                	jmp    *%ecx

00800422 <.L69>:
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800425:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800429:	eb d5                	jmp    800400 <vprintfmt+0x40>

0080042b <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80042e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800432:	eb cc                	jmp    800400 <vprintfmt+0x40>

00800434 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	0f b6 d2             	movzbl %dl,%edx
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80043a:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80043f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800442:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800446:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800449:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80044c:	83 f9 09             	cmp    $0x9,%ecx
  80044f:	77 55                	ja     8004a6 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800451:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800454:	eb e9                	jmp    80043f <.L29+0xb>

00800456 <.L26>:
			precision = va_arg(ap, int);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 40 04             	lea    0x4(%eax),%eax
  800464:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80046a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046e:	79 90                	jns    800400 <vprintfmt+0x40>
				width = precision, precision = -1;
  800470:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800473:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800476:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80047d:	eb 81                	jmp    800400 <vprintfmt+0x40>

0080047f <.L27>:
  80047f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800482:	85 c0                	test   %eax,%eax
  800484:	ba 00 00 00 00       	mov    $0x0,%edx
  800489:	0f 49 d0             	cmovns %eax,%edx
  80048c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 69 ff ff ff       	jmp    800400 <vprintfmt+0x40>

00800497 <.L23>:
  800497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80049a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a1:	e9 5a ff ff ff       	jmp    800400 <vprintfmt+0x40>
  8004a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004a9:	eb bf                	jmp    80046a <.L26+0x14>

008004ab <.L33>:
			lflag++;
  8004ab:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004b2:	e9 49 ff ff ff       	jmp    800400 <vprintfmt+0x40>

008004b7 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 78 04             	lea    0x4(%eax),%edi
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	56                   	push   %esi
  8004c1:	ff 30                	pushl  (%eax)
  8004c3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004c6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004c9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004cc:	e9 ce 02 00 00       	jmp    80079f <.L35+0x45>

008004d1 <.L32>:
			err = va_arg(ap, int);
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 78 04             	lea    0x4(%eax),%edi
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	99                   	cltd   
  8004da:	31 d0                	xor    %edx,%eax
  8004dc:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004de:	83 f8 06             	cmp    $0x6,%eax
  8004e1:	7f 27                	jg     80050a <.L32+0x39>
  8004e3:	8b 94 83 14 00 00 00 	mov    0x14(%ebx,%eax,4),%edx
  8004ea:	85 d2                	test   %edx,%edx
  8004ec:	74 1c                	je     80050a <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004ee:	52                   	push   %edx
  8004ef:	8d 83 15 ef ff ff    	lea    -0x10eb(%ebx),%eax
  8004f5:	50                   	push   %eax
  8004f6:	56                   	push   %esi
  8004f7:	ff 75 08             	pushl  0x8(%ebp)
  8004fa:	e8 a4 fe ff ff       	call   8003a3 <printfmt>
  8004ff:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800502:	89 7d 14             	mov    %edi,0x14(%ebp)
  800505:	e9 95 02 00 00       	jmp    80079f <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  80050a:	50                   	push   %eax
  80050b:	8d 83 0c ef ff ff    	lea    -0x10f4(%ebx),%eax
  800511:	50                   	push   %eax
  800512:	56                   	push   %esi
  800513:	ff 75 08             	pushl  0x8(%ebp)
  800516:	e8 88 fe ff ff       	call   8003a3 <printfmt>
  80051b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800521:	e9 79 02 00 00       	jmp    80079f <.L35+0x45>

00800526 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	83 c0 04             	add    $0x4,%eax
  80052c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800534:	85 ff                	test   %edi,%edi
  800536:	8d 83 05 ef ff ff    	lea    -0x10fb(%ebx),%eax
  80053c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80053f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800543:	0f 8e b5 00 00 00    	jle    8005fe <.L36+0xd8>
  800549:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80054d:	75 08                	jne    800557 <.L36+0x31>
  80054f:	89 75 0c             	mov    %esi,0xc(%ebp)
  800552:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800555:	eb 6d                	jmp    8005c4 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	ff 75 cc             	pushl  -0x34(%ebp)
  80055d:	57                   	push   %edi
  80055e:	e8 85 03 00 00       	call   8008e8 <strnlen>
  800563:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800566:	29 c2                	sub    %eax,%edx
  800568:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800572:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800575:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800578:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80057a:	eb 10                	jmp    80058c <.L36+0x66>
					putch(padc, putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	56                   	push   %esi
  800580:	ff 75 e0             	pushl  -0x20(%ebp)
  800583:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	83 ef 01             	sub    $0x1,%edi
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	85 ff                	test   %edi,%edi
  80058e:	7f ec                	jg     80057c <.L36+0x56>
  800590:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800593:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800596:	85 d2                	test   %edx,%edx
  800598:	b8 00 00 00 00       	mov    $0x0,%eax
  80059d:	0f 49 c2             	cmovns %edx,%eax
  8005a0:	29 c2                	sub    %eax,%edx
  8005a2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005a5:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005a8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005ab:	eb 17                	jmp    8005c4 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b1:	75 30                	jne    8005e3 <.L36+0xbd>
					putch(ch, putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	ff 75 0c             	pushl  0xc(%ebp)
  8005b9:	50                   	push   %eax
  8005ba:	ff 55 08             	call   *0x8(%ebp)
  8005bd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c0:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005c4:	83 c7 01             	add    $0x1,%edi
  8005c7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005cb:	0f be c2             	movsbl %dl,%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	74 52                	je     800624 <.L36+0xfe>
  8005d2:	85 f6                	test   %esi,%esi
  8005d4:	78 d7                	js     8005ad <.L36+0x87>
  8005d6:	83 ee 01             	sub    $0x1,%esi
  8005d9:	79 d2                	jns    8005ad <.L36+0x87>
  8005db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005de:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005e1:	eb 32                	jmp    800615 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e3:	0f be d2             	movsbl %dl,%edx
  8005e6:	83 ea 20             	sub    $0x20,%edx
  8005e9:	83 fa 5e             	cmp    $0x5e,%edx
  8005ec:	76 c5                	jbe    8005b3 <.L36+0x8d>
					putch('?', putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	ff 75 0c             	pushl  0xc(%ebp)
  8005f4:	6a 3f                	push   $0x3f
  8005f6:	ff 55 08             	call   *0x8(%ebp)
  8005f9:	83 c4 10             	add    $0x10,%esp
  8005fc:	eb c2                	jmp    8005c0 <.L36+0x9a>
  8005fe:	89 75 0c             	mov    %esi,0xc(%ebp)
  800601:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800604:	eb be                	jmp    8005c4 <.L36+0x9e>
				putch(' ', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	56                   	push   %esi
  80060a:	6a 20                	push   $0x20
  80060c:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ed                	jg     800606 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800619:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
  80061f:	e9 7b 01 00 00       	jmp    80079f <.L35+0x45>
  800624:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800627:	8b 75 0c             	mov    0xc(%ebp),%esi
  80062a:	eb e9                	jmp    800615 <.L36+0xef>

0080062c <.L31>:
  80062c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80062f:	83 f9 01             	cmp    $0x1,%ecx
  800632:	7e 40                	jle    800674 <.L31+0x48>
		return va_arg(*ap, long long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 50 04             	mov    0x4(%eax),%edx
  80063a:	8b 00                	mov    (%eax),%eax
  80063c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 40 08             	lea    0x8(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80064b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064f:	79 55                	jns    8006a6 <.L31+0x7a>
				putch('-', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	56                   	push   %esi
  800655:	6a 2d                	push   $0x2d
  800657:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80065d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800660:	f7 da                	neg    %edx
  800662:	83 d1 00             	adc    $0x0,%ecx
  800665:	f7 d9                	neg    %ecx
  800667:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066f:	e9 10 01 00 00       	jmp    800784 <.L35+0x2a>
	else if (lflag)
  800674:	85 c9                	test   %ecx,%ecx
  800676:	75 17                	jne    80068f <.L31+0x63>
		return va_arg(*ap, int);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800680:	99                   	cltd   
  800681:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 40 04             	lea    0x4(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
  80068d:	eb bc                	jmp    80064b <.L31+0x1f>
		return va_arg(*ap, long);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8b 00                	mov    (%eax),%eax
  800694:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800697:	99                   	cltd   
  800698:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8d 40 04             	lea    0x4(%eax),%eax
  8006a1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a4:	eb a5                	jmp    80064b <.L31+0x1f>
			num = getint(&ap, lflag);
  8006a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b1:	e9 ce 00 00 00       	jmp    800784 <.L35+0x2a>

008006b6 <.L37>:
  8006b6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006b9:	83 f9 01             	cmp    $0x1,%ecx
  8006bc:	7e 18                	jle    8006d6 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8b 10                	mov    (%eax),%edx
  8006c3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c6:	8d 40 08             	lea    0x8(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d1:	e9 ae 00 00 00       	jmp    800784 <.L35+0x2a>
	else if (lflag)
  8006d6:	85 c9                	test   %ecx,%ecx
  8006d8:	75 1a                	jne    8006f4 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 10                	mov    (%eax),%edx
  8006df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e4:	8d 40 04             	lea    0x4(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ef:	e9 90 00 00 00       	jmp    800784 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8b 10                	mov    (%eax),%edx
  8006f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fe:	8d 40 04             	lea    0x4(%eax),%eax
  800701:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800704:	b8 0a 00 00 00       	mov    $0xa,%eax
  800709:	eb 79                	jmp    800784 <.L35+0x2a>

0080070b <.L34>:
  80070b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80070e:	83 f9 01             	cmp    $0x1,%ecx
  800711:	7e 15                	jle    800728 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8b 10                	mov    (%eax),%edx
  800718:	8b 48 04             	mov    0x4(%eax),%ecx
  80071b:	8d 40 08             	lea    0x8(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800721:	b8 08 00 00 00       	mov    $0x8,%eax
  800726:	eb 5c                	jmp    800784 <.L35+0x2a>
	else if (lflag)
  800728:	85 c9                	test   %ecx,%ecx
  80072a:	75 17                	jne    800743 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 10                	mov    (%eax),%edx
  800731:	b9 00 00 00 00       	mov    $0x0,%ecx
  800736:	8d 40 04             	lea    0x4(%eax),%eax
  800739:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80073c:	b8 08 00 00 00       	mov    $0x8,%eax
  800741:	eb 41                	jmp    800784 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8b 10                	mov    (%eax),%edx
  800748:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074d:	8d 40 04             	lea    0x4(%eax),%eax
  800750:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800753:	b8 08 00 00 00       	mov    $0x8,%eax
  800758:	eb 2a                	jmp    800784 <.L35+0x2a>

0080075a <.L35>:
			putch('0', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	56                   	push   %esi
  80075e:	6a 30                	push   $0x30
  800760:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800763:	83 c4 08             	add    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	6a 78                	push   $0x78
  800769:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8b 10                	mov    (%eax),%edx
  800771:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800776:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800779:	8d 40 04             	lea    0x4(%eax),%eax
  80077c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800784:	83 ec 0c             	sub    $0xc,%esp
  800787:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80078b:	57                   	push   %edi
  80078c:	ff 75 e0             	pushl  -0x20(%ebp)
  80078f:	50                   	push   %eax
  800790:	51                   	push   %ecx
  800791:	52                   	push   %edx
  800792:	89 f2                	mov    %esi,%edx
  800794:	8b 45 08             	mov    0x8(%ebp),%eax
  800797:	e8 20 fb ff ff       	call   8002bc <printnum>
			break;
  80079c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80079f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a2:	83 c7 01             	add    $0x1,%edi
  8007a5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007a9:	83 f8 25             	cmp    $0x25,%eax
  8007ac:	0f 84 2d fc ff ff    	je     8003df <vprintfmt+0x1f>
			if (ch == '\0')
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	0f 84 91 00 00 00    	je     80084b <.L22+0x21>
			putch(ch, putdat);
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	56                   	push   %esi
  8007be:	50                   	push   %eax
  8007bf:	ff 55 08             	call   *0x8(%ebp)
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	eb db                	jmp    8007a2 <.L35+0x48>

008007c7 <.L38>:
  8007c7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007ca:	83 f9 01             	cmp    $0x1,%ecx
  8007cd:	7e 15                	jle    8007e4 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 10                	mov    (%eax),%edx
  8007d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d7:	8d 40 08             	lea    0x8(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e2:	eb a0                	jmp    800784 <.L35+0x2a>
	else if (lflag)
  8007e4:	85 c9                	test   %ecx,%ecx
  8007e6:	75 17                	jne    8007ff <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f8:	b8 10 00 00 00       	mov    $0x10,%eax
  8007fd:	eb 85                	jmp    800784 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 10                	mov    (%eax),%edx
  800804:	b9 00 00 00 00       	mov    $0x0,%ecx
  800809:	8d 40 04             	lea    0x4(%eax),%eax
  80080c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080f:	b8 10 00 00 00       	mov    $0x10,%eax
  800814:	e9 6b ff ff ff       	jmp    800784 <.L35+0x2a>

00800819 <.L25>:
			putch(ch, putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	56                   	push   %esi
  80081d:	6a 25                	push   $0x25
  80081f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	e9 75 ff ff ff       	jmp    80079f <.L35+0x45>

0080082a <.L22>:
			putch('%', putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	56                   	push   %esi
  80082e:	6a 25                	push   $0x25
  800830:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	89 f8                	mov    %edi,%eax
  800838:	eb 03                	jmp    80083d <.L22+0x13>
  80083a:	83 e8 01             	sub    $0x1,%eax
  80083d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800841:	75 f7                	jne    80083a <.L22+0x10>
  800843:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800846:	e9 54 ff ff ff       	jmp    80079f <.L35+0x45>
}
  80084b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5f                   	pop    %edi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	83 ec 14             	sub    $0x14,%esp
  80085a:	e8 fe f7 ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80085f:	81 c3 a1 17 00 00    	add    $0x17a1,%ebx
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800872:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800875:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087c:	85 c0                	test   %eax,%eax
  80087e:	74 2b                	je     8008ab <vsnprintf+0x58>
  800880:	85 d2                	test   %edx,%edx
  800882:	7e 27                	jle    8008ab <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800884:	ff 75 14             	pushl  0x14(%ebp)
  800887:	ff 75 10             	pushl  0x10(%ebp)
  80088a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088d:	50                   	push   %eax
  80088e:	8d 83 86 e3 ff ff    	lea    -0x1c7a(%ebx),%eax
  800894:	50                   	push   %eax
  800895:	e8 26 fb ff ff       	call   8003c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80089a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a3:	83 c4 10             	add    $0x10,%esp
}
  8008a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    
		return -E_INVAL;
  8008ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b0:	eb f4                	jmp    8008a6 <vsnprintf+0x53>

008008b2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008bb:	50                   	push   %eax
  8008bc:	ff 75 10             	pushl  0x10(%ebp)
  8008bf:	ff 75 0c             	pushl  0xc(%ebp)
  8008c2:	ff 75 08             	pushl  0x8(%ebp)
  8008c5:	e8 89 ff ff ff       	call   800853 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <__x86.get_pc_thunk.cx>:
  8008cc:	8b 0c 24             	mov    (%esp),%ecx
  8008cf:	c3                   	ret    

008008d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008db:	eb 03                	jmp    8008e0 <strlen+0x10>
		n++;
  8008dd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e4:	75 f7                	jne    8008dd <strlen+0xd>
	return n;
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f6:	eb 03                	jmp    8008fb <strnlen+0x13>
		n++;
  8008f8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fb:	39 d0                	cmp    %edx,%eax
  8008fd:	74 06                	je     800905 <strnlen+0x1d>
  8008ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800903:	75 f3                	jne    8008f8 <strnlen+0x10>
	return n;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800911:	89 c2                	mov    %eax,%edx
  800913:	83 c1 01             	add    $0x1,%ecx
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80091d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800920:	84 db                	test   %bl,%bl
  800922:	75 ef                	jne    800913 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800924:	5b                   	pop    %ebx
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80092e:	53                   	push   %ebx
  80092f:	e8 9c ff ff ff       	call   8008d0 <strlen>
  800934:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800937:	ff 75 0c             	pushl  0xc(%ebp)
  80093a:	01 d8                	add    %ebx,%eax
  80093c:	50                   	push   %eax
  80093d:	e8 c5 ff ff ff       	call   800907 <strcpy>
	return dst;
}
  800942:	89 d8                	mov    %ebx,%eax
  800944:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 75 08             	mov    0x8(%ebp),%esi
  800951:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800954:	89 f3                	mov    %esi,%ebx
  800956:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800959:	89 f2                	mov    %esi,%edx
  80095b:	eb 0f                	jmp    80096c <strncpy+0x23>
		*dst++ = *src;
  80095d:	83 c2 01             	add    $0x1,%edx
  800960:	0f b6 01             	movzbl (%ecx),%eax
  800963:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800966:	80 39 01             	cmpb   $0x1,(%ecx)
  800969:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80096c:	39 da                	cmp    %ebx,%edx
  80096e:	75 ed                	jne    80095d <strncpy+0x14>
	}
	return ret;
}
  800970:	89 f0                	mov    %esi,%eax
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 75 08             	mov    0x8(%ebp),%esi
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800984:	89 f0                	mov    %esi,%eax
  800986:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80098a:	85 c9                	test   %ecx,%ecx
  80098c:	75 0b                	jne    800999 <strlcpy+0x23>
  80098e:	eb 17                	jmp    8009a7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800990:	83 c2 01             	add    $0x1,%edx
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800999:	39 d8                	cmp    %ebx,%eax
  80099b:	74 07                	je     8009a4 <strlcpy+0x2e>
  80099d:	0f b6 0a             	movzbl (%edx),%ecx
  8009a0:	84 c9                	test   %cl,%cl
  8009a2:	75 ec                	jne    800990 <strlcpy+0x1a>
		*dst = '\0';
  8009a4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a7:	29 f0                	sub    %esi,%eax
}
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b6:	eb 06                	jmp    8009be <strcmp+0x11>
		p++, q++;
  8009b8:	83 c1 01             	add    $0x1,%ecx
  8009bb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009be:	0f b6 01             	movzbl (%ecx),%eax
  8009c1:	84 c0                	test   %al,%al
  8009c3:	74 04                	je     8009c9 <strcmp+0x1c>
  8009c5:	3a 02                	cmp    (%edx),%al
  8009c7:	74 ef                	je     8009b8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c9:	0f b6 c0             	movzbl %al,%eax
  8009cc:	0f b6 12             	movzbl (%edx),%edx
  8009cf:	29 d0                	sub    %edx,%eax
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	53                   	push   %ebx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dd:	89 c3                	mov    %eax,%ebx
  8009df:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e2:	eb 06                	jmp    8009ea <strncmp+0x17>
		n--, p++, q++;
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009ea:	39 d8                	cmp    %ebx,%eax
  8009ec:	74 16                	je     800a04 <strncmp+0x31>
  8009ee:	0f b6 08             	movzbl (%eax),%ecx
  8009f1:	84 c9                	test   %cl,%cl
  8009f3:	74 04                	je     8009f9 <strncmp+0x26>
  8009f5:	3a 0a                	cmp    (%edx),%cl
  8009f7:	74 eb                	je     8009e4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f9:	0f b6 00             	movzbl (%eax),%eax
  8009fc:	0f b6 12             	movzbl (%edx),%edx
  8009ff:	29 d0                	sub    %edx,%eax
}
  800a01:	5b                   	pop    %ebx
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    
		return 0;
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
  800a09:	eb f6                	jmp    800a01 <strncmp+0x2e>

00800a0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a15:	0f b6 10             	movzbl (%eax),%edx
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	74 09                	je     800a25 <strchr+0x1a>
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	74 0a                	je     800a2a <strchr+0x1f>
	for (; *s; s++)
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	eb f0                	jmp    800a15 <strchr+0xa>
			return (char *) s;
	return 0;
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a36:	eb 03                	jmp    800a3b <strfind+0xf>
  800a38:	83 c0 01             	add    $0x1,%eax
  800a3b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a3e:	38 ca                	cmp    %cl,%dl
  800a40:	74 04                	je     800a46 <strfind+0x1a>
  800a42:	84 d2                	test   %dl,%dl
  800a44:	75 f2                	jne    800a38 <strfind+0xc>
			break;
	return (char *) s;
}
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a54:	85 c9                	test   %ecx,%ecx
  800a56:	74 13                	je     800a6b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a58:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5e:	75 05                	jne    800a65 <memset+0x1d>
  800a60:	f6 c1 03             	test   $0x3,%cl
  800a63:	74 0d                	je     800a72 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a68:	fc                   	cld    
  800a69:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6b:	89 f8                	mov    %edi,%eax
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    
		c &= 0xFF;
  800a72:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a76:	89 d3                	mov    %edx,%ebx
  800a78:	c1 e3 08             	shl    $0x8,%ebx
  800a7b:	89 d0                	mov    %edx,%eax
  800a7d:	c1 e0 18             	shl    $0x18,%eax
  800a80:	89 d6                	mov    %edx,%esi
  800a82:	c1 e6 10             	shl    $0x10,%esi
  800a85:	09 f0                	or     %esi,%eax
  800a87:	09 c2                	or     %eax,%edx
  800a89:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a8b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a8e:	89 d0                	mov    %edx,%eax
  800a90:	fc                   	cld    
  800a91:	f3 ab                	rep stos %eax,%es:(%edi)
  800a93:	eb d6                	jmp    800a6b <memset+0x23>

00800a95 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa3:	39 c6                	cmp    %eax,%esi
  800aa5:	73 35                	jae    800adc <memmove+0x47>
  800aa7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aaa:	39 c2                	cmp    %eax,%edx
  800aac:	76 2e                	jbe    800adc <memmove+0x47>
		s += n;
		d += n;
  800aae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab1:	89 d6                	mov    %edx,%esi
  800ab3:	09 fe                	or     %edi,%esi
  800ab5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abb:	74 0c                	je     800ac9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800abd:	83 ef 01             	sub    $0x1,%edi
  800ac0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ac3:	fd                   	std    
  800ac4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac6:	fc                   	cld    
  800ac7:	eb 21                	jmp    800aea <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac9:	f6 c1 03             	test   $0x3,%cl
  800acc:	75 ef                	jne    800abd <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ace:	83 ef 04             	sub    $0x4,%edi
  800ad1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ad7:	fd                   	std    
  800ad8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ada:	eb ea                	jmp    800ac6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800adc:	89 f2                	mov    %esi,%edx
  800ade:	09 c2                	or     %eax,%edx
  800ae0:	f6 c2 03             	test   $0x3,%dl
  800ae3:	74 09                	je     800aee <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae5:	89 c7                	mov    %eax,%edi
  800ae7:	fc                   	cld    
  800ae8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aee:	f6 c1 03             	test   $0x3,%cl
  800af1:	75 f2                	jne    800ae5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800af6:	89 c7                	mov    %eax,%edi
  800af8:	fc                   	cld    
  800af9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afb:	eb ed                	jmp    800aea <memmove+0x55>

00800afd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b00:	ff 75 10             	pushl  0x10(%ebp)
  800b03:	ff 75 0c             	pushl  0xc(%ebp)
  800b06:	ff 75 08             	pushl  0x8(%ebp)
  800b09:	e8 87 ff ff ff       	call   800a95 <memmove>
}
  800b0e:	c9                   	leave  
  800b0f:	c3                   	ret    

00800b10 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1b:	89 c6                	mov    %eax,%esi
  800b1d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b20:	39 f0                	cmp    %esi,%eax
  800b22:	74 1c                	je     800b40 <memcmp+0x30>
		if (*s1 != *s2)
  800b24:	0f b6 08             	movzbl (%eax),%ecx
  800b27:	0f b6 1a             	movzbl (%edx),%ebx
  800b2a:	38 d9                	cmp    %bl,%cl
  800b2c:	75 08                	jne    800b36 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b2e:	83 c0 01             	add    $0x1,%eax
  800b31:	83 c2 01             	add    $0x1,%edx
  800b34:	eb ea                	jmp    800b20 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b36:	0f b6 c1             	movzbl %cl,%eax
  800b39:	0f b6 db             	movzbl %bl,%ebx
  800b3c:	29 d8                	sub    %ebx,%eax
  800b3e:	eb 05                	jmp    800b45 <memcmp+0x35>
	}

	return 0;
  800b40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b52:	89 c2                	mov    %eax,%edx
  800b54:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b57:	39 d0                	cmp    %edx,%eax
  800b59:	73 09                	jae    800b64 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5b:	38 08                	cmp    %cl,(%eax)
  800b5d:	74 05                	je     800b64 <memfind+0x1b>
	for (; s < ends; s++)
  800b5f:	83 c0 01             	add    $0x1,%eax
  800b62:	eb f3                	jmp    800b57 <memfind+0xe>
			break;
	return (void *) s;
}
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b72:	eb 03                	jmp    800b77 <strtol+0x11>
		s++;
  800b74:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b77:	0f b6 01             	movzbl (%ecx),%eax
  800b7a:	3c 20                	cmp    $0x20,%al
  800b7c:	74 f6                	je     800b74 <strtol+0xe>
  800b7e:	3c 09                	cmp    $0x9,%al
  800b80:	74 f2                	je     800b74 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b82:	3c 2b                	cmp    $0x2b,%al
  800b84:	74 2e                	je     800bb4 <strtol+0x4e>
	int neg = 0;
  800b86:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b8b:	3c 2d                	cmp    $0x2d,%al
  800b8d:	74 2f                	je     800bbe <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b95:	75 05                	jne    800b9c <strtol+0x36>
  800b97:	80 39 30             	cmpb   $0x30,(%ecx)
  800b9a:	74 2c                	je     800bc8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b9c:	85 db                	test   %ebx,%ebx
  800b9e:	75 0a                	jne    800baa <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ba5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba8:	74 28                	je     800bd2 <strtol+0x6c>
		base = 10;
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
  800baf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bb2:	eb 50                	jmp    800c04 <strtol+0x9e>
		s++;
  800bb4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bb7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbc:	eb d1                	jmp    800b8f <strtol+0x29>
		s++, neg = 1;
  800bbe:	83 c1 01             	add    $0x1,%ecx
  800bc1:	bf 01 00 00 00       	mov    $0x1,%edi
  800bc6:	eb c7                	jmp    800b8f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bcc:	74 0e                	je     800bdc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bce:	85 db                	test   %ebx,%ebx
  800bd0:	75 d8                	jne    800baa <strtol+0x44>
		s++, base = 8;
  800bd2:	83 c1 01             	add    $0x1,%ecx
  800bd5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bda:	eb ce                	jmp    800baa <strtol+0x44>
		s += 2, base = 16;
  800bdc:	83 c1 02             	add    $0x2,%ecx
  800bdf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be4:	eb c4                	jmp    800baa <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800be6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be9:	89 f3                	mov    %esi,%ebx
  800beb:	80 fb 19             	cmp    $0x19,%bl
  800bee:	77 29                	ja     800c19 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bf0:	0f be d2             	movsbl %dl,%edx
  800bf3:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bf9:	7d 30                	jge    800c2b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bfb:	83 c1 01             	add    $0x1,%ecx
  800bfe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c02:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c04:	0f b6 11             	movzbl (%ecx),%edx
  800c07:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c0a:	89 f3                	mov    %esi,%ebx
  800c0c:	80 fb 09             	cmp    $0x9,%bl
  800c0f:	77 d5                	ja     800be6 <strtol+0x80>
			dig = *s - '0';
  800c11:	0f be d2             	movsbl %dl,%edx
  800c14:	83 ea 30             	sub    $0x30,%edx
  800c17:	eb dd                	jmp    800bf6 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c19:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c1c:	89 f3                	mov    %esi,%ebx
  800c1e:	80 fb 19             	cmp    $0x19,%bl
  800c21:	77 08                	ja     800c2b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c23:	0f be d2             	movsbl %dl,%edx
  800c26:	83 ea 37             	sub    $0x37,%edx
  800c29:	eb cb                	jmp    800bf6 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c2b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2f:	74 05                	je     800c36 <strtol+0xd0>
		*endptr = (char *) s;
  800c31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c34:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c36:	89 c2                	mov    %eax,%edx
  800c38:	f7 da                	neg    %edx
  800c3a:	85 ff                	test   %edi,%edi
  800c3c:	0f 45 c2             	cmovne %edx,%eax
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    
  800c44:	66 90                	xchg   %ax,%ax
  800c46:	66 90                	xchg   %ax,%ax
  800c48:	66 90                	xchg   %ax,%ax
  800c4a:	66 90                	xchg   %ax,%ax
  800c4c:	66 90                	xchg   %ax,%ax
  800c4e:	66 90                	xchg   %ax,%ax

00800c50 <__udivdi3>:
  800c50:	55                   	push   %ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 1c             	sub    $0x1c,%esp
  800c57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c67:	85 d2                	test   %edx,%edx
  800c69:	75 35                	jne    800ca0 <__udivdi3+0x50>
  800c6b:	39 f3                	cmp    %esi,%ebx
  800c6d:	0f 87 bd 00 00 00    	ja     800d30 <__udivdi3+0xe0>
  800c73:	85 db                	test   %ebx,%ebx
  800c75:	89 d9                	mov    %ebx,%ecx
  800c77:	75 0b                	jne    800c84 <__udivdi3+0x34>
  800c79:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7e:	31 d2                	xor    %edx,%edx
  800c80:	f7 f3                	div    %ebx
  800c82:	89 c1                	mov    %eax,%ecx
  800c84:	31 d2                	xor    %edx,%edx
  800c86:	89 f0                	mov    %esi,%eax
  800c88:	f7 f1                	div    %ecx
  800c8a:	89 c6                	mov    %eax,%esi
  800c8c:	89 e8                	mov    %ebp,%eax
  800c8e:	89 f7                	mov    %esi,%edi
  800c90:	f7 f1                	div    %ecx
  800c92:	89 fa                	mov    %edi,%edx
  800c94:	83 c4 1c             	add    $0x1c,%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    
  800c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	39 f2                	cmp    %esi,%edx
  800ca2:	77 7c                	ja     800d20 <__udivdi3+0xd0>
  800ca4:	0f bd fa             	bsr    %edx,%edi
  800ca7:	83 f7 1f             	xor    $0x1f,%edi
  800caa:	0f 84 98 00 00 00    	je     800d48 <__udivdi3+0xf8>
  800cb0:	89 f9                	mov    %edi,%ecx
  800cb2:	b8 20 00 00 00       	mov    $0x20,%eax
  800cb7:	29 f8                	sub    %edi,%eax
  800cb9:	d3 e2                	shl    %cl,%edx
  800cbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cbf:	89 c1                	mov    %eax,%ecx
  800cc1:	89 da                	mov    %ebx,%edx
  800cc3:	d3 ea                	shr    %cl,%edx
  800cc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cc9:	09 d1                	or     %edx,%ecx
  800ccb:	89 f2                	mov    %esi,%edx
  800ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cd1:	89 f9                	mov    %edi,%ecx
  800cd3:	d3 e3                	shl    %cl,%ebx
  800cd5:	89 c1                	mov    %eax,%ecx
  800cd7:	d3 ea                	shr    %cl,%edx
  800cd9:	89 f9                	mov    %edi,%ecx
  800cdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cdf:	d3 e6                	shl    %cl,%esi
  800ce1:	89 eb                	mov    %ebp,%ebx
  800ce3:	89 c1                	mov    %eax,%ecx
  800ce5:	d3 eb                	shr    %cl,%ebx
  800ce7:	09 de                	or     %ebx,%esi
  800ce9:	89 f0                	mov    %esi,%eax
  800ceb:	f7 74 24 08          	divl   0x8(%esp)
  800cef:	89 d6                	mov    %edx,%esi
  800cf1:	89 c3                	mov    %eax,%ebx
  800cf3:	f7 64 24 0c          	mull   0xc(%esp)
  800cf7:	39 d6                	cmp    %edx,%esi
  800cf9:	72 0c                	jb     800d07 <__udivdi3+0xb7>
  800cfb:	89 f9                	mov    %edi,%ecx
  800cfd:	d3 e5                	shl    %cl,%ebp
  800cff:	39 c5                	cmp    %eax,%ebp
  800d01:	73 5d                	jae    800d60 <__udivdi3+0x110>
  800d03:	39 d6                	cmp    %edx,%esi
  800d05:	75 59                	jne    800d60 <__udivdi3+0x110>
  800d07:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d0a:	31 ff                	xor    %edi,%edi
  800d0c:	89 fa                	mov    %edi,%edx
  800d0e:	83 c4 1c             	add    $0x1c,%esp
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    
  800d16:	8d 76 00             	lea    0x0(%esi),%esi
  800d19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d20:	31 ff                	xor    %edi,%edi
  800d22:	31 c0                	xor    %eax,%eax
  800d24:	89 fa                	mov    %edi,%edx
  800d26:	83 c4 1c             	add    $0x1c,%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    
  800d2e:	66 90                	xchg   %ax,%ax
  800d30:	31 ff                	xor    %edi,%edi
  800d32:	89 e8                	mov    %ebp,%eax
  800d34:	89 f2                	mov    %esi,%edx
  800d36:	f7 f3                	div    %ebx
  800d38:	89 fa                	mov    %edi,%edx
  800d3a:	83 c4 1c             	add    $0x1c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
  800d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d48:	39 f2                	cmp    %esi,%edx
  800d4a:	72 06                	jb     800d52 <__udivdi3+0x102>
  800d4c:	31 c0                	xor    %eax,%eax
  800d4e:	39 eb                	cmp    %ebp,%ebx
  800d50:	77 d2                	ja     800d24 <__udivdi3+0xd4>
  800d52:	b8 01 00 00 00       	mov    $0x1,%eax
  800d57:	eb cb                	jmp    800d24 <__udivdi3+0xd4>
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	89 d8                	mov    %ebx,%eax
  800d62:	31 ff                	xor    %edi,%edi
  800d64:	eb be                	jmp    800d24 <__udivdi3+0xd4>
  800d66:	66 90                	xchg   %ax,%ax
  800d68:	66 90                	xchg   %ax,%ax
  800d6a:	66 90                	xchg   %ax,%ax
  800d6c:	66 90                	xchg   %ax,%ax
  800d6e:	66 90                	xchg   %ax,%ax

00800d70 <__umoddi3>:
  800d70:	55                   	push   %ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 1c             	sub    $0x1c,%esp
  800d77:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d87:	85 ed                	test   %ebp,%ebp
  800d89:	89 f0                	mov    %esi,%eax
  800d8b:	89 da                	mov    %ebx,%edx
  800d8d:	75 19                	jne    800da8 <__umoddi3+0x38>
  800d8f:	39 df                	cmp    %ebx,%edi
  800d91:	0f 86 b1 00 00 00    	jbe    800e48 <__umoddi3+0xd8>
  800d97:	f7 f7                	div    %edi
  800d99:	89 d0                	mov    %edx,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	83 c4 1c             	add    $0x1c,%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
  800da5:	8d 76 00             	lea    0x0(%esi),%esi
  800da8:	39 dd                	cmp    %ebx,%ebp
  800daa:	77 f1                	ja     800d9d <__umoddi3+0x2d>
  800dac:	0f bd cd             	bsr    %ebp,%ecx
  800daf:	83 f1 1f             	xor    $0x1f,%ecx
  800db2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800db6:	0f 84 b4 00 00 00    	je     800e70 <__umoddi3+0x100>
  800dbc:	b8 20 00 00 00       	mov    $0x20,%eax
  800dc1:	89 c2                	mov    %eax,%edx
  800dc3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dc7:	29 c2                	sub    %eax,%edx
  800dc9:	89 c1                	mov    %eax,%ecx
  800dcb:	89 f8                	mov    %edi,%eax
  800dcd:	d3 e5                	shl    %cl,%ebp
  800dcf:	89 d1                	mov    %edx,%ecx
  800dd1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dd5:	d3 e8                	shr    %cl,%eax
  800dd7:	09 c5                	or     %eax,%ebp
  800dd9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ddd:	89 c1                	mov    %eax,%ecx
  800ddf:	d3 e7                	shl    %cl,%edi
  800de1:	89 d1                	mov    %edx,%ecx
  800de3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800de7:	89 df                	mov    %ebx,%edi
  800de9:	d3 ef                	shr    %cl,%edi
  800deb:	89 c1                	mov    %eax,%ecx
  800ded:	89 f0                	mov    %esi,%eax
  800def:	d3 e3                	shl    %cl,%ebx
  800df1:	89 d1                	mov    %edx,%ecx
  800df3:	89 fa                	mov    %edi,%edx
  800df5:	d3 e8                	shr    %cl,%eax
  800df7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dfc:	09 d8                	or     %ebx,%eax
  800dfe:	f7 f5                	div    %ebp
  800e00:	d3 e6                	shl    %cl,%esi
  800e02:	89 d1                	mov    %edx,%ecx
  800e04:	f7 64 24 08          	mull   0x8(%esp)
  800e08:	39 d1                	cmp    %edx,%ecx
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	89 d7                	mov    %edx,%edi
  800e0e:	72 06                	jb     800e16 <__umoddi3+0xa6>
  800e10:	75 0e                	jne    800e20 <__umoddi3+0xb0>
  800e12:	39 c6                	cmp    %eax,%esi
  800e14:	73 0a                	jae    800e20 <__umoddi3+0xb0>
  800e16:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e1a:	19 ea                	sbb    %ebp,%edx
  800e1c:	89 d7                	mov    %edx,%edi
  800e1e:	89 c3                	mov    %eax,%ebx
  800e20:	89 ca                	mov    %ecx,%edx
  800e22:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e27:	29 de                	sub    %ebx,%esi
  800e29:	19 fa                	sbb    %edi,%edx
  800e2b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e2f:	89 d0                	mov    %edx,%eax
  800e31:	d3 e0                	shl    %cl,%eax
  800e33:	89 d9                	mov    %ebx,%ecx
  800e35:	d3 ee                	shr    %cl,%esi
  800e37:	d3 ea                	shr    %cl,%edx
  800e39:	09 f0                	or     %esi,%eax
  800e3b:	83 c4 1c             	add    $0x1c,%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    
  800e43:	90                   	nop
  800e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e48:	85 ff                	test   %edi,%edi
  800e4a:	89 f9                	mov    %edi,%ecx
  800e4c:	75 0b                	jne    800e59 <__umoddi3+0xe9>
  800e4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e53:	31 d2                	xor    %edx,%edx
  800e55:	f7 f7                	div    %edi
  800e57:	89 c1                	mov    %eax,%ecx
  800e59:	89 d8                	mov    %ebx,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	f7 f1                	div    %ecx
  800e5f:	89 f0                	mov    %esi,%eax
  800e61:	f7 f1                	div    %ecx
  800e63:	e9 31 ff ff ff       	jmp    800d99 <__umoddi3+0x29>
  800e68:	90                   	nop
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	39 dd                	cmp    %ebx,%ebp
  800e72:	72 08                	jb     800e7c <__umoddi3+0x10c>
  800e74:	39 f7                	cmp    %esi,%edi
  800e76:	0f 87 21 ff ff ff    	ja     800d9d <__umoddi3+0x2d>
  800e7c:	89 da                	mov    %ebx,%edx
  800e7e:	89 f0                	mov    %esi,%eax
  800e80:	29 f8                	sub    %edi,%eax
  800e82:	19 ea                	sbb    %ebp,%edx
  800e84:	e9 14 ff ff ff       	jmp    800d9d <__umoddi3+0x2d>
