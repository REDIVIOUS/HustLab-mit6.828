
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	57                   	push   %edi
  800046:	56                   	push   %esi
  800047:	53                   	push   %ebx
  800048:	83 ec 0c             	sub    $0xc,%esp
  80004b:	e8 57 00 00 00       	call   8000a7 <__x86.get_pc_thunk.bx>
  800050:	81 c3 b0 1f 00 00    	add    $0x1fb0,%ebx
  800056:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800059:	c7 c6 2c 20 80 00    	mov    $0x80202c,%esi
  80005f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	thisenv = (struct Env*)(envs + ENVX(sys_getenvid())); //（为当前进程）初始化全局指针
  800065:	e8 f4 00 00 00       	call   80015e <sys_getenvid>
  80006a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006f:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800072:	c1 e0 05             	shl    $0x5,%eax
  800075:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80007b:	89 06                	mov    %eax,(%esi)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800081:	7e 08                	jle    80008b <libmain+0x49>
		binaryname = argv[0];
  800083:	8b 07                	mov    (%edi),%eax
  800085:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	57                   	push   %edi
  80008f:	ff 75 08             	pushl  0x8(%ebp)
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0f 00 00 00       	call   8000ab <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5f                   	pop    %edi
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    

008000a7 <__x86.get_pc_thunk.bx>:
  8000a7:	8b 1c 24             	mov    (%esp),%ebx
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	53                   	push   %ebx
  8000af:	83 ec 10             	sub    $0x10,%esp
  8000b2:	e8 f0 ff ff ff       	call   8000a7 <__x86.get_pc_thunk.bx>
  8000b7:	81 c3 49 1f 00 00    	add    $0x1f49,%ebx
	sys_env_destroy(0);
  8000bd:	6a 00                	push   $0x0
  8000bf:	e8 45 00 00 00       	call   800109 <sys_env_destroy>
}
  8000c4:	83 c4 10             	add    $0x10,%esp
  8000c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000dd:	89 c3                	mov    %eax,%ebx
  8000df:	89 c7                	mov    %eax,%edi
  8000e1:	89 c6                	mov    %eax,%esi
  8000e3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e5:	5b                   	pop    %ebx
  8000e6:	5e                   	pop    %esi
  8000e7:	5f                   	pop    %edi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fa:	89 d1                	mov    %edx,%ecx
  8000fc:	89 d3                	mov    %edx,%ebx
  8000fe:	89 d7                	mov    %edx,%edi
  800100:	89 d6                	mov    %edx,%esi
  800102:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    

00800109 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	57                   	push   %edi
  80010d:	56                   	push   %esi
  80010e:	53                   	push   %ebx
  80010f:	83 ec 1c             	sub    $0x1c,%esp
  800112:	e8 66 00 00 00       	call   80017d <__x86.get_pc_thunk.ax>
  800117:	05 e9 1e 00 00       	add    $0x1ee9,%eax
  80011c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80011f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800124:	8b 55 08             	mov    0x8(%ebp),%edx
  800127:	b8 03 00 00 00       	mov    $0x3,%eax
  80012c:	89 cb                	mov    %ecx,%ebx
  80012e:	89 cf                	mov    %ecx,%edi
  800130:	89 ce                	mov    %ecx,%esi
  800132:	cd 30                	int    $0x30
	if(check && ret > 0)
  800134:	85 c0                	test   %eax,%eax
  800136:	7f 08                	jg     800140 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	50                   	push   %eax
  800144:	6a 03                	push   $0x3
  800146:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800149:	8d 83 76 ee ff ff    	lea    -0x118a(%ebx),%eax
  80014f:	50                   	push   %eax
  800150:	6a 23                	push   $0x23
  800152:	8d 83 93 ee ff ff    	lea    -0x116d(%ebx),%eax
  800158:	50                   	push   %eax
  800159:	e8 23 00 00 00       	call   800181 <_panic>

0080015e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
	asm volatile("int %1\n"
  800164:	ba 00 00 00 00       	mov    $0x0,%edx
  800169:	b8 02 00 00 00       	mov    $0x2,%eax
  80016e:	89 d1                	mov    %edx,%ecx
  800170:	89 d3                	mov    %edx,%ebx
  800172:	89 d7                	mov    %edx,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5f                   	pop    %edi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <__x86.get_pc_thunk.ax>:
  80017d:	8b 04 24             	mov    (%esp),%eax
  800180:	c3                   	ret    

00800181 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	e8 18 ff ff ff       	call   8000a7 <__x86.get_pc_thunk.bx>
  80018f:	81 c3 71 1e 00 00    	add    $0x1e71,%ebx
	va_list ap;

	va_start(ap, fmt);
  800195:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800198:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80019e:	8b 38                	mov    (%eax),%edi
  8001a0:	e8 b9 ff ff ff       	call   80015e <sys_getenvid>
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	ff 75 0c             	pushl  0xc(%ebp)
  8001ab:	ff 75 08             	pushl  0x8(%ebp)
  8001ae:	57                   	push   %edi
  8001af:	50                   	push   %eax
  8001b0:	8d 83 a4 ee ff ff    	lea    -0x115c(%ebx),%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 d1 00 00 00       	call   80028d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 63 00 00 00       	call   80022b <vcprintf>
	cprintf("\n");
  8001c8:	8d 83 c8 ee ff ff    	lea    -0x1138(%ebx),%eax
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	e8 b7 00 00 00       	call   80028d <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d9:	cc                   	int3   
  8001da:	eb fd                	jmp    8001d9 <_panic+0x58>

008001dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	e8 c1 fe ff ff       	call   8000a7 <__x86.get_pc_thunk.bx>
  8001e6:	81 c3 1a 1e 00 00    	add    $0x1e1a,%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001ef:	8b 16                	mov    (%esi),%edx
  8001f1:	8d 42 01             	lea    0x1(%edx),%eax
  8001f4:	89 06                	mov    %eax,(%esi)
  8001f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f9:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001fd:	3d ff 00 00 00       	cmp    $0xff,%eax
  800202:	74 0b                	je     80020f <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800204:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800208:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	68 ff 00 00 00       	push   $0xff
  800217:	8d 46 08             	lea    0x8(%esi),%eax
  80021a:	50                   	push   %eax
  80021b:	e8 ac fe ff ff       	call   8000cc <sys_cputs>
		b->idx = 0;
  800220:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	eb d9                	jmp    800204 <putch+0x28>

0080022b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800235:	e8 6d fe ff ff       	call   8000a7 <__x86.get_pc_thunk.bx>
  80023a:	81 c3 c6 1d 00 00    	add    $0x1dc6,%ebx
	struct printbuf b;

	b.idx = 0;
  800240:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800247:	00 00 00 
	b.cnt = 0;
  80024a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800251:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	ff 75 08             	pushl  0x8(%ebp)
  80025a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800260:	50                   	push   %eax
  800261:	8d 83 dc e1 ff ff    	lea    -0x1e24(%ebx),%eax
  800267:	50                   	push   %eax
  800268:	e8 38 01 00 00       	call   8003a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026d:	83 c4 08             	add    $0x8,%esp
  800270:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800276:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027c:	50                   	push   %eax
  80027d:	e8 4a fe ff ff       	call   8000cc <sys_cputs>

	return b.cnt;
}
  800282:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800288:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800293:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 08             	pushl  0x8(%ebp)
  80029a:	e8 8c ff ff ff       	call   80022b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 2c             	sub    $0x2c,%esp
  8002aa:	e8 02 06 00 00       	call   8008b1 <__x86.get_pc_thunk.cx>
  8002af:	81 c1 51 1d 00 00    	add    $0x1d51,%ecx
  8002b5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002b8:	89 c7                	mov    %eax,%edi
  8002ba:	89 d6                	mov    %edx,%esi
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002d3:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002d6:	39 d3                	cmp    %edx,%ebx
  8002d8:	72 09                	jb     8002e3 <printnum+0x42>
  8002da:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002dd:	0f 87 83 00 00 00    	ja     800366 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e3:	83 ec 0c             	sub    $0xc,%esp
  8002e6:	ff 75 18             	pushl  0x18(%ebp)
  8002e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ec:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ef:	53                   	push   %ebx
  8002f0:	ff 75 10             	pushl  0x10(%ebp)
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ff:	ff 75 d0             	pushl  -0x30(%ebp)
  800302:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800305:	e8 26 09 00 00       	call   800c30 <__udivdi3>
  80030a:	83 c4 18             	add    $0x18,%esp
  80030d:	52                   	push   %edx
  80030e:	50                   	push   %eax
  80030f:	89 f2                	mov    %esi,%edx
  800311:	89 f8                	mov    %edi,%eax
  800313:	e8 89 ff ff ff       	call   8002a1 <printnum>
  800318:	83 c4 20             	add    $0x20,%esp
  80031b:	eb 13                	jmp    800330 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031d:	83 ec 08             	sub    $0x8,%esp
  800320:	56                   	push   %esi
  800321:	ff 75 18             	pushl  0x18(%ebp)
  800324:	ff d7                	call   *%edi
  800326:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800329:	83 eb 01             	sub    $0x1,%ebx
  80032c:	85 db                	test   %ebx,%ebx
  80032e:	7f ed                	jg     80031d <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800330:	83 ec 08             	sub    $0x8,%esp
  800333:	56                   	push   %esi
  800334:	83 ec 04             	sub    $0x4,%esp
  800337:	ff 75 dc             	pushl  -0x24(%ebp)
  80033a:	ff 75 d8             	pushl  -0x28(%ebp)
  80033d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800340:	ff 75 d0             	pushl  -0x30(%ebp)
  800343:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800346:	89 f3                	mov    %esi,%ebx
  800348:	e8 03 0a 00 00       	call   800d50 <__umoddi3>
  80034d:	83 c4 14             	add    $0x14,%esp
  800350:	0f be 84 06 ca ee ff 	movsbl -0x1136(%esi,%eax,1),%eax
  800357:	ff 
  800358:	50                   	push   %eax
  800359:	ff d7                	call   *%edi
}
  80035b:	83 c4 10             	add    $0x10,%esp
  80035e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    
  800366:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800369:	eb be                	jmp    800329 <printnum+0x88>

0080036b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800371:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800375:	8b 10                	mov    (%eax),%edx
  800377:	3b 50 04             	cmp    0x4(%eax),%edx
  80037a:	73 0a                	jae    800386 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037f:	89 08                	mov    %ecx,(%eax)
  800381:	8b 45 08             	mov    0x8(%ebp),%eax
  800384:	88 02                	mov    %al,(%edx)
}
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <printfmt>:
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80038e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800391:	50                   	push   %eax
  800392:	ff 75 10             	pushl  0x10(%ebp)
  800395:	ff 75 0c             	pushl  0xc(%ebp)
  800398:	ff 75 08             	pushl  0x8(%ebp)
  80039b:	e8 05 00 00 00       	call   8003a5 <vprintfmt>
}
  8003a0:	83 c4 10             	add    $0x10,%esp
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <vprintfmt>:
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	57                   	push   %edi
  8003a9:	56                   	push   %esi
  8003aa:	53                   	push   %ebx
  8003ab:	83 ec 2c             	sub    $0x2c,%esp
  8003ae:	e8 f4 fc ff ff       	call   8000a7 <__x86.get_pc_thunk.bx>
  8003b3:	81 c3 4d 1c 00 00    	add    $0x1c4d,%ebx
  8003b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003bf:	e9 c3 03 00 00       	jmp    800787 <.L35+0x48>
		padc = ' ';
  8003c4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003c8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003cf:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003d6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e2:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8d 47 01             	lea    0x1(%edi),%eax
  8003e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003eb:	0f b6 17             	movzbl (%edi),%edx
  8003ee:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 16 04 00 00    	ja     80080f <.L22>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	89 d9                	mov    %ebx,%ecx
  8003fe:	03 8c 83 58 ef ff ff 	add    -0x10a8(%ebx,%eax,4),%ecx
  800405:	ff e1                	jmp    *%ecx

00800407 <.L69>:
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80040a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80040e:	eb d5                	jmp    8003e5 <vprintfmt+0x40>

00800410 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800413:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800417:	eb cc                	jmp    8003e5 <vprintfmt+0x40>

00800419 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	0f b6 d2             	movzbl %dl,%edx
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80041f:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800424:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800427:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80042e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800431:	83 f9 09             	cmp    $0x9,%ecx
  800434:	77 55                	ja     80048b <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800436:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800439:	eb e9                	jmp    800424 <.L29+0xb>

0080043b <.L26>:
			precision = va_arg(ap, int);
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 40 04             	lea    0x4(%eax),%eax
  800449:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80044f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800453:	79 90                	jns    8003e5 <vprintfmt+0x40>
				width = precision, precision = -1;
  800455:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800458:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045b:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800462:	eb 81                	jmp    8003e5 <vprintfmt+0x40>

00800464 <.L27>:
  800464:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800467:	85 c0                	test   %eax,%eax
  800469:	ba 00 00 00 00       	mov    $0x0,%edx
  80046e:	0f 49 d0             	cmovns %eax,%edx
  800471:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800477:	e9 69 ff ff ff       	jmp    8003e5 <vprintfmt+0x40>

0080047c <.L23>:
  80047c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80047f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800486:	e9 5a ff ff ff       	jmp    8003e5 <vprintfmt+0x40>
  80048b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048e:	eb bf                	jmp    80044f <.L26+0x14>

00800490 <.L33>:
			lflag++;
  800490:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800497:	e9 49 ff ff ff       	jmp    8003e5 <vprintfmt+0x40>

0080049c <.L30>:
			putch(va_arg(ap, int), putdat);
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 78 04             	lea    0x4(%eax),%edi
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	56                   	push   %esi
  8004a6:	ff 30                	pushl  (%eax)
  8004a8:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004ab:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004ae:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004b1:	e9 ce 02 00 00       	jmp    800784 <.L35+0x45>

008004b6 <.L32>:
			err = va_arg(ap, int);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 78 04             	lea    0x4(%eax),%edi
  8004bc:	8b 00                	mov    (%eax),%eax
  8004be:	99                   	cltd   
  8004bf:	31 d0                	xor    %edx,%eax
  8004c1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c3:	83 f8 06             	cmp    $0x6,%eax
  8004c6:	7f 27                	jg     8004ef <.L32+0x39>
  8004c8:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004cf:	85 d2                	test   %edx,%edx
  8004d1:	74 1c                	je     8004ef <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004d3:	52                   	push   %edx
  8004d4:	8d 83 eb ee ff ff    	lea    -0x1115(%ebx),%eax
  8004da:	50                   	push   %eax
  8004db:	56                   	push   %esi
  8004dc:	ff 75 08             	pushl  0x8(%ebp)
  8004df:	e8 a4 fe ff ff       	call   800388 <printfmt>
  8004e4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004ea:	e9 95 02 00 00       	jmp    800784 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004ef:	50                   	push   %eax
  8004f0:	8d 83 e2 ee ff ff    	lea    -0x111e(%ebx),%eax
  8004f6:	50                   	push   %eax
  8004f7:	56                   	push   %esi
  8004f8:	ff 75 08             	pushl  0x8(%ebp)
  8004fb:	e8 88 fe ff ff       	call   800388 <printfmt>
  800500:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800503:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800506:	e9 79 02 00 00       	jmp    800784 <.L35+0x45>

0080050b <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	83 c0 04             	add    $0x4,%eax
  800511:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800519:	85 ff                	test   %edi,%edi
  80051b:	8d 83 db ee ff ff    	lea    -0x1125(%ebx),%eax
  800521:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800524:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800528:	0f 8e b5 00 00 00    	jle    8005e3 <.L36+0xd8>
  80052e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800532:	75 08                	jne    80053c <.L36+0x31>
  800534:	89 75 0c             	mov    %esi,0xc(%ebp)
  800537:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80053a:	eb 6d                	jmp    8005a9 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	ff 75 cc             	pushl  -0x34(%ebp)
  800542:	57                   	push   %edi
  800543:	e8 85 03 00 00       	call   8008cd <strnlen>
  800548:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80054b:	29 c2                	sub    %eax,%edx
  80054d:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800550:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800553:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800557:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80055d:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	eb 10                	jmp    800571 <.L36+0x66>
					putch(padc, putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	56                   	push   %esi
  800565:	ff 75 e0             	pushl  -0x20(%ebp)
  800568:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	83 ef 01             	sub    $0x1,%edi
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	85 ff                	test   %edi,%edi
  800573:	7f ec                	jg     800561 <.L36+0x56>
  800575:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800578:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80057b:	85 d2                	test   %edx,%edx
  80057d:	b8 00 00 00 00       	mov    $0x0,%eax
  800582:	0f 49 c2             	cmovns %edx,%eax
  800585:	29 c2                	sub    %eax,%edx
  800587:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80058a:	89 75 0c             	mov    %esi,0xc(%ebp)
  80058d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800590:	eb 17                	jmp    8005a9 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800592:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800596:	75 30                	jne    8005c8 <.L36+0xbd>
					putch(ch, putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	ff 75 0c             	pushl  0xc(%ebp)
  80059e:	50                   	push   %eax
  80059f:	ff 55 08             	call   *0x8(%ebp)
  8005a2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a5:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005a9:	83 c7 01             	add    $0x1,%edi
  8005ac:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005b0:	0f be c2             	movsbl %dl,%eax
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	74 52                	je     800609 <.L36+0xfe>
  8005b7:	85 f6                	test   %esi,%esi
  8005b9:	78 d7                	js     800592 <.L36+0x87>
  8005bb:	83 ee 01             	sub    $0x1,%esi
  8005be:	79 d2                	jns    800592 <.L36+0x87>
  8005c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005c6:	eb 32                	jmp    8005fa <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c8:	0f be d2             	movsbl %dl,%edx
  8005cb:	83 ea 20             	sub    $0x20,%edx
  8005ce:	83 fa 5e             	cmp    $0x5e,%edx
  8005d1:	76 c5                	jbe    800598 <.L36+0x8d>
					putch('?', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	ff 75 0c             	pushl  0xc(%ebp)
  8005d9:	6a 3f                	push   $0x3f
  8005db:	ff 55 08             	call   *0x8(%ebp)
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	eb c2                	jmp    8005a5 <.L36+0x9a>
  8005e3:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005e6:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005e9:	eb be                	jmp    8005a9 <.L36+0x9e>
				putch(' ', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	56                   	push   %esi
  8005ef:	6a 20                	push   $0x20
  8005f1:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005f4:	83 ef 01             	sub    $0x1,%edi
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	7f ed                	jg     8005eb <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
  800604:	e9 7b 01 00 00       	jmp    800784 <.L35+0x45>
  800609:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80060c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80060f:	eb e9                	jmp    8005fa <.L36+0xef>

00800611 <.L31>:
  800611:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800614:	83 f9 01             	cmp    $0x1,%ecx
  800617:	7e 40                	jle    800659 <.L31+0x48>
		return va_arg(*ap, long long);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8b 50 04             	mov    0x4(%eax),%edx
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800624:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 40 08             	lea    0x8(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800630:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800634:	79 55                	jns    80068b <.L31+0x7a>
				putch('-', putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	56                   	push   %esi
  80063a:	6a 2d                	push   $0x2d
  80063c:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80063f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800642:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800645:	f7 da                	neg    %edx
  800647:	83 d1 00             	adc    $0x0,%ecx
  80064a:	f7 d9                	neg    %ecx
  80064c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80064f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800654:	e9 10 01 00 00       	jmp    800769 <.L35+0x2a>
	else if (lflag)
  800659:	85 c9                	test   %ecx,%ecx
  80065b:	75 17                	jne    800674 <.L31+0x63>
		return va_arg(*ap, int);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800665:	99                   	cltd   
  800666:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 40 04             	lea    0x4(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
  800672:	eb bc                	jmp    800630 <.L31+0x1f>
		return va_arg(*ap, long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 00                	mov    (%eax),%eax
  800679:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067c:	99                   	cltd   
  80067d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
  800689:	eb a5                	jmp    800630 <.L31+0x1f>
			num = getint(&ap, lflag);
  80068b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80068e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800691:	b8 0a 00 00 00       	mov    $0xa,%eax
  800696:	e9 ce 00 00 00       	jmp    800769 <.L35+0x2a>

0080069b <.L37>:
  80069b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80069e:	83 f9 01             	cmp    $0x1,%ecx
  8006a1:	7e 18                	jle    8006bb <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ab:	8d 40 08             	lea    0x8(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b6:	e9 ae 00 00 00       	jmp    800769 <.L35+0x2a>
	else if (lflag)
  8006bb:	85 c9                	test   %ecx,%ecx
  8006bd:	75 1a                	jne    8006d9 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 10                	mov    (%eax),%edx
  8006c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c9:	8d 40 04             	lea    0x4(%eax),%eax
  8006cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d4:	e9 90 00 00 00       	jmp    800769 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ee:	eb 79                	jmp    800769 <.L35+0x2a>

008006f0 <.L34>:
  8006f0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006f3:	83 f9 01             	cmp    $0x1,%ecx
  8006f6:	7e 15                	jle    80070d <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800700:	8d 40 08             	lea    0x8(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800706:	b8 08 00 00 00       	mov    $0x8,%eax
  80070b:	eb 5c                	jmp    800769 <.L35+0x2a>
	else if (lflag)
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	75 17                	jne    800728 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071b:	8d 40 04             	lea    0x4(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800721:	b8 08 00 00 00       	mov    $0x8,%eax
  800726:	eb 41                	jmp    800769 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800738:	b8 08 00 00 00       	mov    $0x8,%eax
  80073d:	eb 2a                	jmp    800769 <.L35+0x2a>

0080073f <.L35>:
			putch('0', putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	56                   	push   %esi
  800743:	6a 30                	push   $0x30
  800745:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800748:	83 c4 08             	add    $0x8,%esp
  80074b:	56                   	push   %esi
  80074c:	6a 78                	push   $0x78
  80074e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8b 10                	mov    (%eax),%edx
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80075b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80075e:	8d 40 04             	lea    0x4(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800764:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800770:	57                   	push   %edi
  800771:	ff 75 e0             	pushl  -0x20(%ebp)
  800774:	50                   	push   %eax
  800775:	51                   	push   %ecx
  800776:	52                   	push   %edx
  800777:	89 f2                	mov    %esi,%edx
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	e8 20 fb ff ff       	call   8002a1 <printnum>
			break;
  800781:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800787:	83 c7 01             	add    $0x1,%edi
  80078a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80078e:	83 f8 25             	cmp    $0x25,%eax
  800791:	0f 84 2d fc ff ff    	je     8003c4 <vprintfmt+0x1f>
			if (ch == '\0')
  800797:	85 c0                	test   %eax,%eax
  800799:	0f 84 91 00 00 00    	je     800830 <.L22+0x21>
			putch(ch, putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	56                   	push   %esi
  8007a3:	50                   	push   %eax
  8007a4:	ff 55 08             	call   *0x8(%ebp)
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb db                	jmp    800787 <.L35+0x48>

008007ac <.L38>:
  8007ac:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007af:	83 f9 01             	cmp    $0x1,%ecx
  8007b2:	7e 15                	jle    8007c9 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8b 10                	mov    (%eax),%edx
  8007b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007bc:	8d 40 08             	lea    0x8(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c7:	eb a0                	jmp    800769 <.L35+0x2a>
	else if (lflag)
  8007c9:	85 c9                	test   %ecx,%ecx
  8007cb:	75 17                	jne    8007e4 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8b 10                	mov    (%eax),%edx
  8007d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d7:	8d 40 04             	lea    0x4(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e2:	eb 85                	jmp    800769 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8b 10                	mov    (%eax),%edx
  8007e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ee:	8d 40 04             	lea    0x4(%eax),%eax
  8007f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f4:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f9:	e9 6b ff ff ff       	jmp    800769 <.L35+0x2a>

008007fe <.L25>:
			putch(ch, putdat);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	56                   	push   %esi
  800802:	6a 25                	push   $0x25
  800804:	ff 55 08             	call   *0x8(%ebp)
			break;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	e9 75 ff ff ff       	jmp    800784 <.L35+0x45>

0080080f <.L22>:
			putch('%', putdat);
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	56                   	push   %esi
  800813:	6a 25                	push   $0x25
  800815:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800818:	83 c4 10             	add    $0x10,%esp
  80081b:	89 f8                	mov    %edi,%eax
  80081d:	eb 03                	jmp    800822 <.L22+0x13>
  80081f:	83 e8 01             	sub    $0x1,%eax
  800822:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800826:	75 f7                	jne    80081f <.L22+0x10>
  800828:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80082b:	e9 54 ff ff ff       	jmp    800784 <.L35+0x45>
}
  800830:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800833:	5b                   	pop    %ebx
  800834:	5e                   	pop    %esi
  800835:	5f                   	pop    %edi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	83 ec 14             	sub    $0x14,%esp
  80083f:	e8 63 f8 ff ff       	call   8000a7 <__x86.get_pc_thunk.bx>
  800844:	81 c3 bc 17 00 00    	add    $0x17bc,%ebx
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800850:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800853:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800857:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800861:	85 c0                	test   %eax,%eax
  800863:	74 2b                	je     800890 <vsnprintf+0x58>
  800865:	85 d2                	test   %edx,%edx
  800867:	7e 27                	jle    800890 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800869:	ff 75 14             	pushl  0x14(%ebp)
  80086c:	ff 75 10             	pushl  0x10(%ebp)
  80086f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800872:	50                   	push   %eax
  800873:	8d 83 6b e3 ff ff    	lea    -0x1c95(%ebx),%eax
  800879:	50                   	push   %eax
  80087a:	e8 26 fb ff ff       	call   8003a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800882:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800888:	83 c4 10             	add    $0x10,%esp
}
  80088b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    
		return -E_INVAL;
  800890:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800895:	eb f4                	jmp    80088b <vsnprintf+0x53>

00800897 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a0:	50                   	push   %eax
  8008a1:	ff 75 10             	pushl  0x10(%ebp)
  8008a4:	ff 75 0c             	pushl  0xc(%ebp)
  8008a7:	ff 75 08             	pushl  0x8(%ebp)
  8008aa:	e8 89 ff ff ff       	call   800838 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <__x86.get_pc_thunk.cx>:
  8008b1:	8b 0c 24             	mov    (%esp),%ecx
  8008b4:	c3                   	ret    

008008b5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c0:	eb 03                	jmp    8008c5 <strlen+0x10>
		n++;
  8008c2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c9:	75 f7                	jne    8008c2 <strlen+0xd>
	return n;
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008db:	eb 03                	jmp    8008e0 <strnlen+0x13>
		n++;
  8008dd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e0:	39 d0                	cmp    %edx,%eax
  8008e2:	74 06                	je     8008ea <strnlen+0x1d>
  8008e4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e8:	75 f3                	jne    8008dd <strnlen+0x10>
	return n;
}
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	53                   	push   %ebx
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f6:	89 c2                	mov    %eax,%edx
  8008f8:	83 c1 01             	add    $0x1,%ecx
  8008fb:	83 c2 01             	add    $0x1,%edx
  8008fe:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800902:	88 5a ff             	mov    %bl,-0x1(%edx)
  800905:	84 db                	test   %bl,%bl
  800907:	75 ef                	jne    8008f8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800909:	5b                   	pop    %ebx
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800913:	53                   	push   %ebx
  800914:	e8 9c ff ff ff       	call   8008b5 <strlen>
  800919:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80091c:	ff 75 0c             	pushl  0xc(%ebp)
  80091f:	01 d8                	add    %ebx,%eax
  800921:	50                   	push   %eax
  800922:	e8 c5 ff ff ff       	call   8008ec <strcpy>
	return dst;
}
  800927:	89 d8                	mov    %ebx,%eax
  800929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 75 08             	mov    0x8(%ebp),%esi
  800936:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800939:	89 f3                	mov    %esi,%ebx
  80093b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093e:	89 f2                	mov    %esi,%edx
  800940:	eb 0f                	jmp    800951 <strncpy+0x23>
		*dst++ = *src;
  800942:	83 c2 01             	add    $0x1,%edx
  800945:	0f b6 01             	movzbl (%ecx),%eax
  800948:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094b:	80 39 01             	cmpb   $0x1,(%ecx)
  80094e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800951:	39 da                	cmp    %ebx,%edx
  800953:	75 ed                	jne    800942 <strncpy+0x14>
	}
	return ret;
}
  800955:	89 f0                	mov    %esi,%eax
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	8b 75 08             	mov    0x8(%ebp),%esi
  800963:	8b 55 0c             	mov    0xc(%ebp),%edx
  800966:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800969:	89 f0                	mov    %esi,%eax
  80096b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096f:	85 c9                	test   %ecx,%ecx
  800971:	75 0b                	jne    80097e <strlcpy+0x23>
  800973:	eb 17                	jmp    80098c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800975:	83 c2 01             	add    $0x1,%edx
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80097e:	39 d8                	cmp    %ebx,%eax
  800980:	74 07                	je     800989 <strlcpy+0x2e>
  800982:	0f b6 0a             	movzbl (%edx),%ecx
  800985:	84 c9                	test   %cl,%cl
  800987:	75 ec                	jne    800975 <strlcpy+0x1a>
		*dst = '\0';
  800989:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098c:	29 f0                	sub    %esi,%eax
}
  80098e:	5b                   	pop    %ebx
  80098f:	5e                   	pop    %esi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099b:	eb 06                	jmp    8009a3 <strcmp+0x11>
		p++, q++;
  80099d:	83 c1 01             	add    $0x1,%ecx
  8009a0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a3:	0f b6 01             	movzbl (%ecx),%eax
  8009a6:	84 c0                	test   %al,%al
  8009a8:	74 04                	je     8009ae <strcmp+0x1c>
  8009aa:	3a 02                	cmp    (%edx),%al
  8009ac:	74 ef                	je     80099d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ae:	0f b6 c0             	movzbl %al,%eax
  8009b1:	0f b6 12             	movzbl (%edx),%edx
  8009b4:	29 d0                	sub    %edx,%eax
}
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c2:	89 c3                	mov    %eax,%ebx
  8009c4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c7:	eb 06                	jmp    8009cf <strncmp+0x17>
		n--, p++, q++;
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009cf:	39 d8                	cmp    %ebx,%eax
  8009d1:	74 16                	je     8009e9 <strncmp+0x31>
  8009d3:	0f b6 08             	movzbl (%eax),%ecx
  8009d6:	84 c9                	test   %cl,%cl
  8009d8:	74 04                	je     8009de <strncmp+0x26>
  8009da:	3a 0a                	cmp    (%edx),%cl
  8009dc:	74 eb                	je     8009c9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009de:	0f b6 00             	movzbl (%eax),%eax
  8009e1:	0f b6 12             	movzbl (%edx),%edx
  8009e4:	29 d0                	sub    %edx,%eax
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    
		return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ee:	eb f6                	jmp    8009e6 <strncmp+0x2e>

008009f0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fa:	0f b6 10             	movzbl (%eax),%edx
  8009fd:	84 d2                	test   %dl,%dl
  8009ff:	74 09                	je     800a0a <strchr+0x1a>
		if (*s == c)
  800a01:	38 ca                	cmp    %cl,%dl
  800a03:	74 0a                	je     800a0f <strchr+0x1f>
	for (; *s; s++)
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	eb f0                	jmp    8009fa <strchr+0xa>
			return (char *) s;
	return 0;
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1b:	eb 03                	jmp    800a20 <strfind+0xf>
  800a1d:	83 c0 01             	add    $0x1,%eax
  800a20:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a23:	38 ca                	cmp    %cl,%dl
  800a25:	74 04                	je     800a2b <strfind+0x1a>
  800a27:	84 d2                	test   %dl,%dl
  800a29:	75 f2                	jne    800a1d <strfind+0xc>
			break;
	return (char *) s;
}
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a39:	85 c9                	test   %ecx,%ecx
  800a3b:	74 13                	je     800a50 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a43:	75 05                	jne    800a4a <memset+0x1d>
  800a45:	f6 c1 03             	test   $0x3,%cl
  800a48:	74 0d                	je     800a57 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4d:	fc                   	cld    
  800a4e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a50:	89 f8                	mov    %edi,%eax
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    
		c &= 0xFF;
  800a57:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5b:	89 d3                	mov    %edx,%ebx
  800a5d:	c1 e3 08             	shl    $0x8,%ebx
  800a60:	89 d0                	mov    %edx,%eax
  800a62:	c1 e0 18             	shl    $0x18,%eax
  800a65:	89 d6                	mov    %edx,%esi
  800a67:	c1 e6 10             	shl    $0x10,%esi
  800a6a:	09 f0                	or     %esi,%eax
  800a6c:	09 c2                	or     %eax,%edx
  800a6e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a70:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a73:	89 d0                	mov    %edx,%eax
  800a75:	fc                   	cld    
  800a76:	f3 ab                	rep stos %eax,%es:(%edi)
  800a78:	eb d6                	jmp    800a50 <memset+0x23>

00800a7a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a85:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a88:	39 c6                	cmp    %eax,%esi
  800a8a:	73 35                	jae    800ac1 <memmove+0x47>
  800a8c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8f:	39 c2                	cmp    %eax,%edx
  800a91:	76 2e                	jbe    800ac1 <memmove+0x47>
		s += n;
		d += n;
  800a93:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a96:	89 d6                	mov    %edx,%esi
  800a98:	09 fe                	or     %edi,%esi
  800a9a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa0:	74 0c                	je     800aae <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa2:	83 ef 01             	sub    $0x1,%edi
  800aa5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa8:	fd                   	std    
  800aa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aab:	fc                   	cld    
  800aac:	eb 21                	jmp    800acf <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aae:	f6 c1 03             	test   $0x3,%cl
  800ab1:	75 ef                	jne    800aa2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab3:	83 ef 04             	sub    $0x4,%edi
  800ab6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800abc:	fd                   	std    
  800abd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abf:	eb ea                	jmp    800aab <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac1:	89 f2                	mov    %esi,%edx
  800ac3:	09 c2                	or     %eax,%edx
  800ac5:	f6 c2 03             	test   $0x3,%dl
  800ac8:	74 09                	je     800ad3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aca:	89 c7                	mov    %eax,%edi
  800acc:	fc                   	cld    
  800acd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad3:	f6 c1 03             	test   $0x3,%cl
  800ad6:	75 f2                	jne    800aca <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800adb:	89 c7                	mov    %eax,%edi
  800add:	fc                   	cld    
  800ade:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae0:	eb ed                	jmp    800acf <memmove+0x55>

00800ae2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae5:	ff 75 10             	pushl  0x10(%ebp)
  800ae8:	ff 75 0c             	pushl  0xc(%ebp)
  800aeb:	ff 75 08             	pushl  0x8(%ebp)
  800aee:	e8 87 ff ff ff       	call   800a7a <memmove>
}
  800af3:	c9                   	leave  
  800af4:	c3                   	ret    

00800af5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b00:	89 c6                	mov    %eax,%esi
  800b02:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b05:	39 f0                	cmp    %esi,%eax
  800b07:	74 1c                	je     800b25 <memcmp+0x30>
		if (*s1 != *s2)
  800b09:	0f b6 08             	movzbl (%eax),%ecx
  800b0c:	0f b6 1a             	movzbl (%edx),%ebx
  800b0f:	38 d9                	cmp    %bl,%cl
  800b11:	75 08                	jne    800b1b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b13:	83 c0 01             	add    $0x1,%eax
  800b16:	83 c2 01             	add    $0x1,%edx
  800b19:	eb ea                	jmp    800b05 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b1b:	0f b6 c1             	movzbl %cl,%eax
  800b1e:	0f b6 db             	movzbl %bl,%ebx
  800b21:	29 d8                	sub    %ebx,%eax
  800b23:	eb 05                	jmp    800b2a <memcmp+0x35>
	}

	return 0;
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b37:	89 c2                	mov    %eax,%edx
  800b39:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3c:	39 d0                	cmp    %edx,%eax
  800b3e:	73 09                	jae    800b49 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b40:	38 08                	cmp    %cl,(%eax)
  800b42:	74 05                	je     800b49 <memfind+0x1b>
	for (; s < ends; s++)
  800b44:	83 c0 01             	add    $0x1,%eax
  800b47:	eb f3                	jmp    800b3c <memfind+0xe>
			break;
	return (void *) s;
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b57:	eb 03                	jmp    800b5c <strtol+0x11>
		s++;
  800b59:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b5c:	0f b6 01             	movzbl (%ecx),%eax
  800b5f:	3c 20                	cmp    $0x20,%al
  800b61:	74 f6                	je     800b59 <strtol+0xe>
  800b63:	3c 09                	cmp    $0x9,%al
  800b65:	74 f2                	je     800b59 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b67:	3c 2b                	cmp    $0x2b,%al
  800b69:	74 2e                	je     800b99 <strtol+0x4e>
	int neg = 0;
  800b6b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b70:	3c 2d                	cmp    $0x2d,%al
  800b72:	74 2f                	je     800ba3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b74:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b7a:	75 05                	jne    800b81 <strtol+0x36>
  800b7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7f:	74 2c                	je     800bad <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b81:	85 db                	test   %ebx,%ebx
  800b83:	75 0a                	jne    800b8f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b85:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8d:	74 28                	je     800bb7 <strtol+0x6c>
		base = 10;
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b94:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b97:	eb 50                	jmp    800be9 <strtol+0x9e>
		s++;
  800b99:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b9c:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba1:	eb d1                	jmp    800b74 <strtol+0x29>
		s++, neg = 1;
  800ba3:	83 c1 01             	add    $0x1,%ecx
  800ba6:	bf 01 00 00 00       	mov    $0x1,%edi
  800bab:	eb c7                	jmp    800b74 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bad:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb1:	74 0e                	je     800bc1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bb3:	85 db                	test   %ebx,%ebx
  800bb5:	75 d8                	jne    800b8f <strtol+0x44>
		s++, base = 8;
  800bb7:	83 c1 01             	add    $0x1,%ecx
  800bba:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bbf:	eb ce                	jmp    800b8f <strtol+0x44>
		s += 2, base = 16;
  800bc1:	83 c1 02             	add    $0x2,%ecx
  800bc4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc9:	eb c4                	jmp    800b8f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bcb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bce:	89 f3                	mov    %esi,%ebx
  800bd0:	80 fb 19             	cmp    $0x19,%bl
  800bd3:	77 29                	ja     800bfe <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bd5:	0f be d2             	movsbl %dl,%edx
  800bd8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bde:	7d 30                	jge    800c10 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800be0:	83 c1 01             	add    $0x1,%ecx
  800be3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800be9:	0f b6 11             	movzbl (%ecx),%edx
  800bec:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bef:	89 f3                	mov    %esi,%ebx
  800bf1:	80 fb 09             	cmp    $0x9,%bl
  800bf4:	77 d5                	ja     800bcb <strtol+0x80>
			dig = *s - '0';
  800bf6:	0f be d2             	movsbl %dl,%edx
  800bf9:	83 ea 30             	sub    $0x30,%edx
  800bfc:	eb dd                	jmp    800bdb <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bfe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c01:	89 f3                	mov    %esi,%ebx
  800c03:	80 fb 19             	cmp    $0x19,%bl
  800c06:	77 08                	ja     800c10 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c08:	0f be d2             	movsbl %dl,%edx
  800c0b:	83 ea 37             	sub    $0x37,%edx
  800c0e:	eb cb                	jmp    800bdb <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c14:	74 05                	je     800c1b <strtol+0xd0>
		*endptr = (char *) s;
  800c16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c19:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c1b:	89 c2                	mov    %eax,%edx
  800c1d:	f7 da                	neg    %edx
  800c1f:	85 ff                	test   %edi,%edi
  800c21:	0f 45 c2             	cmovne %edx,%eax
}
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    
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
