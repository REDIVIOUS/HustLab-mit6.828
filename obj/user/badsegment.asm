
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	57                   	push   %edi
  800042:	56                   	push   %esi
  800043:	53                   	push   %ebx
  800044:	83 ec 0c             	sub    $0xc,%esp
  800047:	e8 57 00 00 00       	call   8000a3 <__x86.get_pc_thunk.bx>
  80004c:	81 c3 b4 1f 00 00    	add    $0x1fb4,%ebx
  800052:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800055:	c7 c6 2c 20 80 00    	mov    $0x80202c,%esi
  80005b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	thisenv = (struct Env*)(envs + ENVX(sys_getenvid())); //（为当前进程）初始化全局指针
  800061:	e8 f4 00 00 00       	call   80015a <sys_getenvid>
  800066:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006b:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80006e:	c1 e0 05             	shl    $0x5,%eax
  800071:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800077:	89 06                	mov    %eax,(%esi)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80007d:	7e 08                	jle    800087 <libmain+0x49>
		binaryname = argv[0];
  80007f:	8b 07                	mov    (%edi),%eax
  800081:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	57                   	push   %edi
  80008b:	ff 75 08             	pushl  0x8(%ebp)
  80008e:	e8 a0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800093:	e8 0f 00 00 00       	call   8000a7 <exit>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5e                   	pop    %esi
  8000a0:	5f                   	pop    %edi
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    

008000a3 <__x86.get_pc_thunk.bx>:
  8000a3:	8b 1c 24             	mov    (%esp),%ebx
  8000a6:	c3                   	ret    

008000a7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	53                   	push   %ebx
  8000ab:	83 ec 10             	sub    $0x10,%esp
  8000ae:	e8 f0 ff ff ff       	call   8000a3 <__x86.get_pc_thunk.bx>
  8000b3:	81 c3 4d 1f 00 00    	add    $0x1f4d,%ebx
	sys_env_destroy(0);
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 45 00 00 00       	call   800105 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d9:	89 c3                	mov    %eax,%ebx
  8000db:	89 c7                	mov    %eax,%edi
  8000dd:	89 c6                	mov    %eax,%esi
  8000df:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f6:	89 d1                	mov    %edx,%ecx
  8000f8:	89 d3                	mov    %edx,%ebx
  8000fa:	89 d7                	mov    %edx,%edi
  8000fc:	89 d6                	mov    %edx,%esi
  8000fe:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
  80010b:	83 ec 1c             	sub    $0x1c,%esp
  80010e:	e8 66 00 00 00       	call   800179 <__x86.get_pc_thunk.ax>
  800113:	05 ed 1e 00 00       	add    $0x1eed,%eax
  800118:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80011b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800120:	8b 55 08             	mov    0x8(%ebp),%edx
  800123:	b8 03 00 00 00       	mov    $0x3,%eax
  800128:	89 cb                	mov    %ecx,%ebx
  80012a:	89 cf                	mov    %ecx,%edi
  80012c:	89 ce                	mov    %ecx,%esi
  80012e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800130:	85 c0                	test   %eax,%eax
  800132:	7f 08                	jg     80013c <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800134:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	50                   	push   %eax
  800140:	6a 03                	push   $0x3
  800142:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800145:	8d 83 76 ee ff ff    	lea    -0x118a(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	6a 23                	push   $0x23
  80014e:	8d 83 93 ee ff ff    	lea    -0x116d(%ebx),%eax
  800154:	50                   	push   %eax
  800155:	e8 23 00 00 00       	call   80017d <_panic>

0080015a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 02 00 00 00       	mov    $0x2,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <__x86.get_pc_thunk.ax>:
  800179:	8b 04 24             	mov    (%esp),%eax
  80017c:	c3                   	ret    

0080017d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	57                   	push   %edi
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	e8 18 ff ff ff       	call   8000a3 <__x86.get_pc_thunk.bx>
  80018b:	81 c3 75 1e 00 00    	add    $0x1e75,%ebx
	va_list ap;

	va_start(ap, fmt);
  800191:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800194:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80019a:	8b 38                	mov    (%eax),%edi
  80019c:	e8 b9 ff ff ff       	call   80015a <sys_getenvid>
  8001a1:	83 ec 0c             	sub    $0xc,%esp
  8001a4:	ff 75 0c             	pushl  0xc(%ebp)
  8001a7:	ff 75 08             	pushl  0x8(%ebp)
  8001aa:	57                   	push   %edi
  8001ab:	50                   	push   %eax
  8001ac:	8d 83 a4 ee ff ff    	lea    -0x115c(%ebx),%eax
  8001b2:	50                   	push   %eax
  8001b3:	e8 d1 00 00 00       	call   800289 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b8:	83 c4 18             	add    $0x18,%esp
  8001bb:	56                   	push   %esi
  8001bc:	ff 75 10             	pushl  0x10(%ebp)
  8001bf:	e8 63 00 00 00       	call   800227 <vcprintf>
	cprintf("\n");
  8001c4:	8d 83 c8 ee ff ff    	lea    -0x1138(%ebx),%eax
  8001ca:	89 04 24             	mov    %eax,(%esp)
  8001cd:	e8 b7 00 00 00       	call   800289 <cprintf>
  8001d2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d5:	cc                   	int3   
  8001d6:	eb fd                	jmp    8001d5 <_panic+0x58>

008001d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	e8 c1 fe ff ff       	call   8000a3 <__x86.get_pc_thunk.bx>
  8001e2:	81 c3 1e 1e 00 00    	add    $0x1e1e,%ebx
  8001e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001eb:	8b 16                	mov    (%esi),%edx
  8001ed:	8d 42 01             	lea    0x1(%edx),%eax
  8001f0:	89 06                	mov    %eax,(%esi)
  8001f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f5:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fe:	74 0b                	je     80020b <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800200:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800204:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	68 ff 00 00 00       	push   $0xff
  800213:	8d 46 08             	lea    0x8(%esi),%eax
  800216:	50                   	push   %eax
  800217:	e8 ac fe ff ff       	call   8000c8 <sys_cputs>
		b->idx = 0;
  80021c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800222:	83 c4 10             	add    $0x10,%esp
  800225:	eb d9                	jmp    800200 <putch+0x28>

00800227 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	53                   	push   %ebx
  80022b:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800231:	e8 6d fe ff ff       	call   8000a3 <__x86.get_pc_thunk.bx>
  800236:	81 c3 ca 1d 00 00    	add    $0x1dca,%ebx
	struct printbuf b;

	b.idx = 0;
  80023c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800243:	00 00 00 
	b.cnt = 0;
  800246:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025c:	50                   	push   %eax
  80025d:	8d 83 d8 e1 ff ff    	lea    -0x1e28(%ebx),%eax
  800263:	50                   	push   %eax
  800264:	e8 38 01 00 00       	call   8003a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800269:	83 c4 08             	add    $0x8,%esp
  80026c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800272:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800278:	50                   	push   %eax
  800279:	e8 4a fe ff ff       	call   8000c8 <sys_cputs>

	return b.cnt;
}
  80027e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800292:	50                   	push   %eax
  800293:	ff 75 08             	pushl  0x8(%ebp)
  800296:	e8 8c ff ff ff       	call   800227 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 2c             	sub    $0x2c,%esp
  8002a6:	e8 02 06 00 00       	call   8008ad <__x86.get_pc_thunk.cx>
  8002ab:	81 c1 55 1d 00 00    	add    $0x1d55,%ecx
  8002b1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002b4:	89 c7                	mov    %eax,%edi
  8002b6:	89 d6                	mov    %edx,%esi
  8002b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002be:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002cf:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002d2:	39 d3                	cmp    %edx,%ebx
  8002d4:	72 09                	jb     8002df <printnum+0x42>
  8002d6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d9:	0f 87 83 00 00 00    	ja     800362 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 18             	pushl  0x18(%ebp)
  8002e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002eb:	53                   	push   %ebx
  8002ec:	ff 75 10             	pushl  0x10(%ebp)
  8002ef:	83 ec 08             	sub    $0x8,%esp
  8002f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8002fe:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800301:	e8 2a 09 00 00       	call   800c30 <__udivdi3>
  800306:	83 c4 18             	add    $0x18,%esp
  800309:	52                   	push   %edx
  80030a:	50                   	push   %eax
  80030b:	89 f2                	mov    %esi,%edx
  80030d:	89 f8                	mov    %edi,%eax
  80030f:	e8 89 ff ff ff       	call   80029d <printnum>
  800314:	83 c4 20             	add    $0x20,%esp
  800317:	eb 13                	jmp    80032c <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800319:	83 ec 08             	sub    $0x8,%esp
  80031c:	56                   	push   %esi
  80031d:	ff 75 18             	pushl  0x18(%ebp)
  800320:	ff d7                	call   *%edi
  800322:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800325:	83 eb 01             	sub    $0x1,%ebx
  800328:	85 db                	test   %ebx,%ebx
  80032a:	7f ed                	jg     800319 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	83 ec 04             	sub    $0x4,%esp
  800333:	ff 75 dc             	pushl  -0x24(%ebp)
  800336:	ff 75 d8             	pushl  -0x28(%ebp)
  800339:	ff 75 d4             	pushl  -0x2c(%ebp)
  80033c:	ff 75 d0             	pushl  -0x30(%ebp)
  80033f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800342:	89 f3                	mov    %esi,%ebx
  800344:	e8 07 0a 00 00       	call   800d50 <__umoddi3>
  800349:	83 c4 14             	add    $0x14,%esp
  80034c:	0f be 84 06 ca ee ff 	movsbl -0x1136(%esi,%eax,1),%eax
  800353:	ff 
  800354:	50                   	push   %eax
  800355:	ff d7                	call   *%edi
}
  800357:	83 c4 10             	add    $0x10,%esp
  80035a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035d:	5b                   	pop    %ebx
  80035e:	5e                   	pop    %esi
  80035f:	5f                   	pop    %edi
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    
  800362:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800365:	eb be                	jmp    800325 <printnum+0x88>

00800367 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800371:	8b 10                	mov    (%eax),%edx
  800373:	3b 50 04             	cmp    0x4(%eax),%edx
  800376:	73 0a                	jae    800382 <sprintputch+0x1b>
		*b->buf++ = ch;
  800378:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037b:	89 08                	mov    %ecx,(%eax)
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	88 02                	mov    %al,(%edx)
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <printfmt>:
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80038a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038d:	50                   	push   %eax
  80038e:	ff 75 10             	pushl  0x10(%ebp)
  800391:	ff 75 0c             	pushl  0xc(%ebp)
  800394:	ff 75 08             	pushl  0x8(%ebp)
  800397:	e8 05 00 00 00       	call   8003a1 <vprintfmt>
}
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	c9                   	leave  
  8003a0:	c3                   	ret    

008003a1 <vprintfmt>:
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	57                   	push   %edi
  8003a5:	56                   	push   %esi
  8003a6:	53                   	push   %ebx
  8003a7:	83 ec 2c             	sub    $0x2c,%esp
  8003aa:	e8 f4 fc ff ff       	call   8000a3 <__x86.get_pc_thunk.bx>
  8003af:	81 c3 51 1c 00 00    	add    $0x1c51,%ebx
  8003b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003b8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003bb:	e9 c3 03 00 00       	jmp    800783 <.L35+0x48>
		padc = ' ';
  8003c0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003c4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003cb:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003de:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8d 47 01             	lea    0x1(%edi),%eax
  8003e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e7:	0f b6 17             	movzbl (%edi),%edx
  8003ea:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ed:	3c 55                	cmp    $0x55,%al
  8003ef:	0f 87 16 04 00 00    	ja     80080b <.L22>
  8003f5:	0f b6 c0             	movzbl %al,%eax
  8003f8:	89 d9                	mov    %ebx,%ecx
  8003fa:	03 8c 83 58 ef ff ff 	add    -0x10a8(%ebx,%eax,4),%ecx
  800401:	ff e1                	jmp    *%ecx

00800403 <.L69>:
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800406:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80040a:	eb d5                	jmp    8003e1 <vprintfmt+0x40>

0080040c <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80040f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800413:	eb cc                	jmp    8003e1 <vprintfmt+0x40>

00800415 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	0f b6 d2             	movzbl %dl,%edx
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80041b:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800420:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800423:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800427:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80042a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80042d:	83 f9 09             	cmp    $0x9,%ecx
  800430:	77 55                	ja     800487 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800432:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800435:	eb e9                	jmp    800420 <.L29+0xb>

00800437 <.L26>:
			precision = va_arg(ap, int);
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 40 04             	lea    0x4(%eax),%eax
  800445:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80044b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044f:	79 90                	jns    8003e1 <vprintfmt+0x40>
				width = precision, precision = -1;
  800451:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80045e:	eb 81                	jmp    8003e1 <vprintfmt+0x40>

00800460 <.L27>:
  800460:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	ba 00 00 00 00       	mov    $0x0,%edx
  80046a:	0f 49 d0             	cmovns %eax,%edx
  80046d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800473:	e9 69 ff ff ff       	jmp    8003e1 <vprintfmt+0x40>

00800478 <.L23>:
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80047b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800482:	e9 5a ff ff ff       	jmp    8003e1 <vprintfmt+0x40>
  800487:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048a:	eb bf                	jmp    80044b <.L26+0x14>

0080048c <.L33>:
			lflag++;
  80048c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800493:	e9 49 ff ff ff       	jmp    8003e1 <vprintfmt+0x40>

00800498 <.L30>:
			putch(va_arg(ap, int), putdat);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 78 04             	lea    0x4(%eax),%edi
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	56                   	push   %esi
  8004a2:	ff 30                	pushl  (%eax)
  8004a4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004aa:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004ad:	e9 ce 02 00 00       	jmp    800780 <.L35+0x45>

008004b2 <.L32>:
			err = va_arg(ap, int);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 78 04             	lea    0x4(%eax),%edi
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	99                   	cltd   
  8004bb:	31 d0                	xor    %edx,%eax
  8004bd:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004bf:	83 f8 06             	cmp    $0x6,%eax
  8004c2:	7f 27                	jg     8004eb <.L32+0x39>
  8004c4:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004cb:	85 d2                	test   %edx,%edx
  8004cd:	74 1c                	je     8004eb <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004cf:	52                   	push   %edx
  8004d0:	8d 83 eb ee ff ff    	lea    -0x1115(%ebx),%eax
  8004d6:	50                   	push   %eax
  8004d7:	56                   	push   %esi
  8004d8:	ff 75 08             	pushl  0x8(%ebp)
  8004db:	e8 a4 fe ff ff       	call   800384 <printfmt>
  8004e0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e6:	e9 95 02 00 00       	jmp    800780 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004eb:	50                   	push   %eax
  8004ec:	8d 83 e2 ee ff ff    	lea    -0x111e(%ebx),%eax
  8004f2:	50                   	push   %eax
  8004f3:	56                   	push   %esi
  8004f4:	ff 75 08             	pushl  0x8(%ebp)
  8004f7:	e8 88 fe ff ff       	call   800384 <printfmt>
  8004fc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ff:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800502:	e9 79 02 00 00       	jmp    800780 <.L35+0x45>

00800507 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	83 c0 04             	add    $0x4,%eax
  80050d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800515:	85 ff                	test   %edi,%edi
  800517:	8d 83 db ee ff ff    	lea    -0x1125(%ebx),%eax
  80051d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800520:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800524:	0f 8e b5 00 00 00    	jle    8005df <.L36+0xd8>
  80052a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052e:	75 08                	jne    800538 <.L36+0x31>
  800530:	89 75 0c             	mov    %esi,0xc(%ebp)
  800533:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800536:	eb 6d                	jmp    8005a5 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 cc             	pushl  -0x34(%ebp)
  80053e:	57                   	push   %edi
  80053f:	e8 85 03 00 00       	call   8008c9 <strnlen>
  800544:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800547:	29 c2                	sub    %eax,%edx
  800549:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80054c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80054f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800553:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800556:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800559:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	eb 10                	jmp    80056d <.L36+0x66>
					putch(padc, putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	56                   	push   %esi
  800561:	ff 75 e0             	pushl  -0x20(%ebp)
  800564:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	83 ef 01             	sub    $0x1,%edi
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	85 ff                	test   %edi,%edi
  80056f:	7f ec                	jg     80055d <.L36+0x56>
  800571:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800574:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800577:	85 d2                	test   %edx,%edx
  800579:	b8 00 00 00 00       	mov    $0x0,%eax
  80057e:	0f 49 c2             	cmovns %edx,%eax
  800581:	29 c2                	sub    %eax,%edx
  800583:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800586:	89 75 0c             	mov    %esi,0xc(%ebp)
  800589:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80058c:	eb 17                	jmp    8005a5 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  80058e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800592:	75 30                	jne    8005c4 <.L36+0xbd>
					putch(ch, putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	ff 75 0c             	pushl  0xc(%ebp)
  80059a:	50                   	push   %eax
  80059b:	ff 55 08             	call   *0x8(%ebp)
  80059e:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a1:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005a5:	83 c7 01             	add    $0x1,%edi
  8005a8:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005ac:	0f be c2             	movsbl %dl,%eax
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	74 52                	je     800605 <.L36+0xfe>
  8005b3:	85 f6                	test   %esi,%esi
  8005b5:	78 d7                	js     80058e <.L36+0x87>
  8005b7:	83 ee 01             	sub    $0x1,%esi
  8005ba:	79 d2                	jns    80058e <.L36+0x87>
  8005bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005bf:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005c2:	eb 32                	jmp    8005f6 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c4:	0f be d2             	movsbl %dl,%edx
  8005c7:	83 ea 20             	sub    $0x20,%edx
  8005ca:	83 fa 5e             	cmp    $0x5e,%edx
  8005cd:	76 c5                	jbe    800594 <.L36+0x8d>
					putch('?', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	ff 75 0c             	pushl  0xc(%ebp)
  8005d5:	6a 3f                	push   $0x3f
  8005d7:	ff 55 08             	call   *0x8(%ebp)
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	eb c2                	jmp    8005a1 <.L36+0x9a>
  8005df:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005e2:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005e5:	eb be                	jmp    8005a5 <.L36+0x9e>
				putch(' ', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	56                   	push   %esi
  8005eb:	6a 20                	push   $0x20
  8005ed:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005f0:	83 ef 01             	sub    $0x1,%edi
  8005f3:	83 c4 10             	add    $0x10,%esp
  8005f6:	85 ff                	test   %edi,%edi
  8005f8:	7f ed                	jg     8005e7 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800600:	e9 7b 01 00 00       	jmp    800780 <.L35+0x45>
  800605:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800608:	8b 75 0c             	mov    0xc(%ebp),%esi
  80060b:	eb e9                	jmp    8005f6 <.L36+0xef>

0080060d <.L31>:
  80060d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800610:	83 f9 01             	cmp    $0x1,%ecx
  800613:	7e 40                	jle    800655 <.L31+0x48>
		return va_arg(*ap, long long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 50 04             	mov    0x4(%eax),%edx
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800620:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 40 08             	lea    0x8(%eax),%eax
  800629:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80062c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800630:	79 55                	jns    800687 <.L31+0x7a>
				putch('-', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	56                   	push   %esi
  800636:	6a 2d                	push   $0x2d
  800638:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80063b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800641:	f7 da                	neg    %edx
  800643:	83 d1 00             	adc    $0x0,%ecx
  800646:	f7 d9                	neg    %ecx
  800648:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80064b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800650:	e9 10 01 00 00       	jmp    800765 <.L35+0x2a>
	else if (lflag)
  800655:	85 c9                	test   %ecx,%ecx
  800657:	75 17                	jne    800670 <.L31+0x63>
		return va_arg(*ap, int);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	99                   	cltd   
  800662:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
  80066e:	eb bc                	jmp    80062c <.L31+0x1f>
		return va_arg(*ap, long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 00                	mov    (%eax),%eax
  800675:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800678:	99                   	cltd   
  800679:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 40 04             	lea    0x4(%eax),%eax
  800682:	89 45 14             	mov    %eax,0x14(%ebp)
  800685:	eb a5                	jmp    80062c <.L31+0x1f>
			num = getint(&ap, lflag);
  800687:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80068a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80068d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800692:	e9 ce 00 00 00       	jmp    800765 <.L35+0x2a>

00800697 <.L37>:
  800697:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80069a:	83 f9 01             	cmp    $0x1,%ecx
  80069d:	7e 18                	jle    8006b7 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a7:	8d 40 08             	lea    0x8(%eax),%eax
  8006aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b2:	e9 ae 00 00 00       	jmp    800765 <.L35+0x2a>
	else if (lflag)
  8006b7:	85 c9                	test   %ecx,%ecx
  8006b9:	75 1a                	jne    8006d5 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8b 10                	mov    (%eax),%edx
  8006c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c5:	8d 40 04             	lea    0x4(%eax),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d0:	e9 90 00 00 00       	jmp    800765 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006df:	8d 40 04             	lea    0x4(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ea:	eb 79                	jmp    800765 <.L35+0x2a>

008006ec <.L34>:
  8006ec:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006ef:	83 f9 01             	cmp    $0x1,%ecx
  8006f2:	7e 15                	jle    800709 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8b 10                	mov    (%eax),%edx
  8006f9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006fc:	8d 40 08             	lea    0x8(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800702:	b8 08 00 00 00       	mov    $0x8,%eax
  800707:	eb 5c                	jmp    800765 <.L35+0x2a>
	else if (lflag)
  800709:	85 c9                	test   %ecx,%ecx
  80070b:	75 17                	jne    800724 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80071d:	b8 08 00 00 00       	mov    $0x8,%eax
  800722:	eb 41                	jmp    800765 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8b 10                	mov    (%eax),%edx
  800729:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072e:	8d 40 04             	lea    0x4(%eax),%eax
  800731:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800734:	b8 08 00 00 00       	mov    $0x8,%eax
  800739:	eb 2a                	jmp    800765 <.L35+0x2a>

0080073b <.L35>:
			putch('0', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	56                   	push   %esi
  80073f:	6a 30                	push   $0x30
  800741:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	56                   	push   %esi
  800748:	6a 78                	push   $0x78
  80074a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8b 10                	mov    (%eax),%edx
  800752:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800757:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80075a:	8d 40 04             	lea    0x4(%eax),%eax
  80075d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800760:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800765:	83 ec 0c             	sub    $0xc,%esp
  800768:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80076c:	57                   	push   %edi
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	50                   	push   %eax
  800771:	51                   	push   %ecx
  800772:	52                   	push   %edx
  800773:	89 f2                	mov    %esi,%edx
  800775:	8b 45 08             	mov    0x8(%ebp),%eax
  800778:	e8 20 fb ff ff       	call   80029d <printnum>
			break;
  80077d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800780:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800783:	83 c7 01             	add    $0x1,%edi
  800786:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80078a:	83 f8 25             	cmp    $0x25,%eax
  80078d:	0f 84 2d fc ff ff    	je     8003c0 <vprintfmt+0x1f>
			if (ch == '\0')
  800793:	85 c0                	test   %eax,%eax
  800795:	0f 84 91 00 00 00    	je     80082c <.L22+0x21>
			putch(ch, putdat);
  80079b:	83 ec 08             	sub    $0x8,%esp
  80079e:	56                   	push   %esi
  80079f:	50                   	push   %eax
  8007a0:	ff 55 08             	call   *0x8(%ebp)
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	eb db                	jmp    800783 <.L35+0x48>

008007a8 <.L38>:
  8007a8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007ab:	83 f9 01             	cmp    $0x1,%ecx
  8007ae:	7e 15                	jle    8007c5 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8b 10                	mov    (%eax),%edx
  8007b5:	8b 48 04             	mov    0x4(%eax),%ecx
  8007b8:	8d 40 08             	lea    0x8(%eax),%eax
  8007bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007be:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c3:	eb a0                	jmp    800765 <.L35+0x2a>
	else if (lflag)
  8007c5:	85 c9                	test   %ecx,%ecx
  8007c7:	75 17                	jne    8007e0 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8b 10                	mov    (%eax),%edx
  8007ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d3:	8d 40 04             	lea    0x4(%eax),%eax
  8007d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d9:	b8 10 00 00 00       	mov    $0x10,%eax
  8007de:	eb 85                	jmp    800765 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8b 10                	mov    (%eax),%edx
  8007e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ea:	8d 40 04             	lea    0x4(%eax),%eax
  8007ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f0:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f5:	e9 6b ff ff ff       	jmp    800765 <.L35+0x2a>

008007fa <.L25>:
			putch(ch, putdat);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	56                   	push   %esi
  8007fe:	6a 25                	push   $0x25
  800800:	ff 55 08             	call   *0x8(%ebp)
			break;
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	e9 75 ff ff ff       	jmp    800780 <.L35+0x45>

0080080b <.L22>:
			putch('%', putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	56                   	push   %esi
  80080f:	6a 25                	push   $0x25
  800811:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	89 f8                	mov    %edi,%eax
  800819:	eb 03                	jmp    80081e <.L22+0x13>
  80081b:	83 e8 01             	sub    $0x1,%eax
  80081e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800822:	75 f7                	jne    80081b <.L22+0x10>
  800824:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800827:	e9 54 ff ff ff       	jmp    800780 <.L35+0x45>
}
  80082c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80082f:	5b                   	pop    %ebx
  800830:	5e                   	pop    %esi
  800831:	5f                   	pop    %edi
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	83 ec 14             	sub    $0x14,%esp
  80083b:	e8 63 f8 ff ff       	call   8000a3 <__x86.get_pc_thunk.bx>
  800840:	81 c3 c0 17 00 00    	add    $0x17c0,%ebx
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800853:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800856:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085d:	85 c0                	test   %eax,%eax
  80085f:	74 2b                	je     80088c <vsnprintf+0x58>
  800861:	85 d2                	test   %edx,%edx
  800863:	7e 27                	jle    80088c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800865:	ff 75 14             	pushl  0x14(%ebp)
  800868:	ff 75 10             	pushl  0x10(%ebp)
  80086b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086e:	50                   	push   %eax
  80086f:	8d 83 67 e3 ff ff    	lea    -0x1c99(%ebx),%eax
  800875:	50                   	push   %eax
  800876:	e8 26 fb ff ff       	call   8003a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800884:	83 c4 10             	add    $0x10,%esp
}
  800887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    
		return -E_INVAL;
  80088c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800891:	eb f4                	jmp    800887 <vsnprintf+0x53>

00800893 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800899:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089c:	50                   	push   %eax
  80089d:	ff 75 10             	pushl  0x10(%ebp)
  8008a0:	ff 75 0c             	pushl  0xc(%ebp)
  8008a3:	ff 75 08             	pushl  0x8(%ebp)
  8008a6:	e8 89 ff ff ff       	call   800834 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    

008008ad <__x86.get_pc_thunk.cx>:
  8008ad:	8b 0c 24             	mov    (%esp),%ecx
  8008b0:	c3                   	ret    

008008b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bc:	eb 03                	jmp    8008c1 <strlen+0x10>
		n++;
  8008be:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c5:	75 f7                	jne    8008be <strlen+0xd>
	return n;
}
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d7:	eb 03                	jmp    8008dc <strnlen+0x13>
		n++;
  8008d9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dc:	39 d0                	cmp    %edx,%eax
  8008de:	74 06                	je     8008e6 <strnlen+0x1d>
  8008e0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e4:	75 f3                	jne    8008d9 <strnlen+0x10>
	return n;
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	53                   	push   %ebx
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f2:	89 c2                	mov    %eax,%edx
  8008f4:	83 c1 01             	add    $0x1,%ecx
  8008f7:	83 c2 01             	add    $0x1,%edx
  8008fa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008fe:	88 5a ff             	mov    %bl,-0x1(%edx)
  800901:	84 db                	test   %bl,%bl
  800903:	75 ef                	jne    8008f4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800905:	5b                   	pop    %ebx
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	53                   	push   %ebx
  80090c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090f:	53                   	push   %ebx
  800910:	e8 9c ff ff ff       	call   8008b1 <strlen>
  800915:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800918:	ff 75 0c             	pushl  0xc(%ebp)
  80091b:	01 d8                	add    %ebx,%eax
  80091d:	50                   	push   %eax
  80091e:	e8 c5 ff ff ff       	call   8008e8 <strcpy>
	return dst;
}
  800923:	89 d8                	mov    %ebx,%eax
  800925:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 75 08             	mov    0x8(%ebp),%esi
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800935:	89 f3                	mov    %esi,%ebx
  800937:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093a:	89 f2                	mov    %esi,%edx
  80093c:	eb 0f                	jmp    80094d <strncpy+0x23>
		*dst++ = *src;
  80093e:	83 c2 01             	add    $0x1,%edx
  800941:	0f b6 01             	movzbl (%ecx),%eax
  800944:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800947:	80 39 01             	cmpb   $0x1,(%ecx)
  80094a:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80094d:	39 da                	cmp    %ebx,%edx
  80094f:	75 ed                	jne    80093e <strncpy+0x14>
	}
	return ret;
}
  800951:	89 f0                	mov    %esi,%eax
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 75 08             	mov    0x8(%ebp),%esi
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800965:	89 f0                	mov    %esi,%eax
  800967:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096b:	85 c9                	test   %ecx,%ecx
  80096d:	75 0b                	jne    80097a <strlcpy+0x23>
  80096f:	eb 17                	jmp    800988 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800971:	83 c2 01             	add    $0x1,%edx
  800974:	83 c0 01             	add    $0x1,%eax
  800977:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80097a:	39 d8                	cmp    %ebx,%eax
  80097c:	74 07                	je     800985 <strlcpy+0x2e>
  80097e:	0f b6 0a             	movzbl (%edx),%ecx
  800981:	84 c9                	test   %cl,%cl
  800983:	75 ec                	jne    800971 <strlcpy+0x1a>
		*dst = '\0';
  800985:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800988:	29 f0                	sub    %esi,%eax
}
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800997:	eb 06                	jmp    80099f <strcmp+0x11>
		p++, q++;
  800999:	83 c1 01             	add    $0x1,%ecx
  80099c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80099f:	0f b6 01             	movzbl (%ecx),%eax
  8009a2:	84 c0                	test   %al,%al
  8009a4:	74 04                	je     8009aa <strcmp+0x1c>
  8009a6:	3a 02                	cmp    (%edx),%al
  8009a8:	74 ef                	je     800999 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009aa:	0f b6 c0             	movzbl %al,%eax
  8009ad:	0f b6 12             	movzbl (%edx),%edx
  8009b0:	29 d0                	sub    %edx,%eax
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009be:	89 c3                	mov    %eax,%ebx
  8009c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c3:	eb 06                	jmp    8009cb <strncmp+0x17>
		n--, p++, q++;
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009cb:	39 d8                	cmp    %ebx,%eax
  8009cd:	74 16                	je     8009e5 <strncmp+0x31>
  8009cf:	0f b6 08             	movzbl (%eax),%ecx
  8009d2:	84 c9                	test   %cl,%cl
  8009d4:	74 04                	je     8009da <strncmp+0x26>
  8009d6:	3a 0a                	cmp    (%edx),%cl
  8009d8:	74 eb                	je     8009c5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009da:	0f b6 00             	movzbl (%eax),%eax
  8009dd:	0f b6 12             	movzbl (%edx),%edx
  8009e0:	29 d0                	sub    %edx,%eax
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    
		return 0;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	eb f6                	jmp    8009e2 <strncmp+0x2e>

008009ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f6:	0f b6 10             	movzbl (%eax),%edx
  8009f9:	84 d2                	test   %dl,%dl
  8009fb:	74 09                	je     800a06 <strchr+0x1a>
		if (*s == c)
  8009fd:	38 ca                	cmp    %cl,%dl
  8009ff:	74 0a                	je     800a0b <strchr+0x1f>
	for (; *s; s++)
  800a01:	83 c0 01             	add    $0x1,%eax
  800a04:	eb f0                	jmp    8009f6 <strchr+0xa>
			return (char *) s;
	return 0;
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a17:	eb 03                	jmp    800a1c <strfind+0xf>
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a1f:	38 ca                	cmp    %cl,%dl
  800a21:	74 04                	je     800a27 <strfind+0x1a>
  800a23:	84 d2                	test   %dl,%dl
  800a25:	75 f2                	jne    800a19 <strfind+0xc>
			break;
	return (char *) s;
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a35:	85 c9                	test   %ecx,%ecx
  800a37:	74 13                	je     800a4c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3f:	75 05                	jne    800a46 <memset+0x1d>
  800a41:	f6 c1 03             	test   $0x3,%cl
  800a44:	74 0d                	je     800a53 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a49:	fc                   	cld    
  800a4a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4c:	89 f8                	mov    %edi,%eax
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    
		c &= 0xFF;
  800a53:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a57:	89 d3                	mov    %edx,%ebx
  800a59:	c1 e3 08             	shl    $0x8,%ebx
  800a5c:	89 d0                	mov    %edx,%eax
  800a5e:	c1 e0 18             	shl    $0x18,%eax
  800a61:	89 d6                	mov    %edx,%esi
  800a63:	c1 e6 10             	shl    $0x10,%esi
  800a66:	09 f0                	or     %esi,%eax
  800a68:	09 c2                	or     %eax,%edx
  800a6a:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a6c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a6f:	89 d0                	mov    %edx,%eax
  800a71:	fc                   	cld    
  800a72:	f3 ab                	rep stos %eax,%es:(%edi)
  800a74:	eb d6                	jmp    800a4c <memset+0x23>

00800a76 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a81:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a84:	39 c6                	cmp    %eax,%esi
  800a86:	73 35                	jae    800abd <memmove+0x47>
  800a88:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8b:	39 c2                	cmp    %eax,%edx
  800a8d:	76 2e                	jbe    800abd <memmove+0x47>
		s += n;
		d += n;
  800a8f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	89 d6                	mov    %edx,%esi
  800a94:	09 fe                	or     %edi,%esi
  800a96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a9c:	74 0c                	je     800aaa <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9e:	83 ef 01             	sub    $0x1,%edi
  800aa1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa4:	fd                   	std    
  800aa5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa7:	fc                   	cld    
  800aa8:	eb 21                	jmp    800acb <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaa:	f6 c1 03             	test   $0x3,%cl
  800aad:	75 ef                	jne    800a9e <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aaf:	83 ef 04             	sub    $0x4,%edi
  800ab2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab8:	fd                   	std    
  800ab9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abb:	eb ea                	jmp    800aa7 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abd:	89 f2                	mov    %esi,%edx
  800abf:	09 c2                	or     %eax,%edx
  800ac1:	f6 c2 03             	test   $0x3,%dl
  800ac4:	74 09                	je     800acf <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac6:	89 c7                	mov    %eax,%edi
  800ac8:	fc                   	cld    
  800ac9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	f6 c1 03             	test   $0x3,%cl
  800ad2:	75 f2                	jne    800ac6 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ad7:	89 c7                	mov    %eax,%edi
  800ad9:	fc                   	cld    
  800ada:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800adc:	eb ed                	jmp    800acb <memmove+0x55>

00800ade <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae1:	ff 75 10             	pushl  0x10(%ebp)
  800ae4:	ff 75 0c             	pushl  0xc(%ebp)
  800ae7:	ff 75 08             	pushl  0x8(%ebp)
  800aea:	e8 87 ff ff ff       	call   800a76 <memmove>
}
  800aef:	c9                   	leave  
  800af0:	c3                   	ret    

00800af1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afc:	89 c6                	mov    %eax,%esi
  800afe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b01:	39 f0                	cmp    %esi,%eax
  800b03:	74 1c                	je     800b21 <memcmp+0x30>
		if (*s1 != *s2)
  800b05:	0f b6 08             	movzbl (%eax),%ecx
  800b08:	0f b6 1a             	movzbl (%edx),%ebx
  800b0b:	38 d9                	cmp    %bl,%cl
  800b0d:	75 08                	jne    800b17 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b0f:	83 c0 01             	add    $0x1,%eax
  800b12:	83 c2 01             	add    $0x1,%edx
  800b15:	eb ea                	jmp    800b01 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b17:	0f b6 c1             	movzbl %cl,%eax
  800b1a:	0f b6 db             	movzbl %bl,%ebx
  800b1d:	29 d8                	sub    %ebx,%eax
  800b1f:	eb 05                	jmp    800b26 <memcmp+0x35>
	}

	return 0;
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b33:	89 c2                	mov    %eax,%edx
  800b35:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b38:	39 d0                	cmp    %edx,%eax
  800b3a:	73 09                	jae    800b45 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3c:	38 08                	cmp    %cl,(%eax)
  800b3e:	74 05                	je     800b45 <memfind+0x1b>
	for (; s < ends; s++)
  800b40:	83 c0 01             	add    $0x1,%eax
  800b43:	eb f3                	jmp    800b38 <memfind+0xe>
			break;
	return (void *) s;
}
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b53:	eb 03                	jmp    800b58 <strtol+0x11>
		s++;
  800b55:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b58:	0f b6 01             	movzbl (%ecx),%eax
  800b5b:	3c 20                	cmp    $0x20,%al
  800b5d:	74 f6                	je     800b55 <strtol+0xe>
  800b5f:	3c 09                	cmp    $0x9,%al
  800b61:	74 f2                	je     800b55 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b63:	3c 2b                	cmp    $0x2b,%al
  800b65:	74 2e                	je     800b95 <strtol+0x4e>
	int neg = 0;
  800b67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b6c:	3c 2d                	cmp    $0x2d,%al
  800b6e:	74 2f                	je     800b9f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b70:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b76:	75 05                	jne    800b7d <strtol+0x36>
  800b78:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7b:	74 2c                	je     800ba9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7d:	85 db                	test   %ebx,%ebx
  800b7f:	75 0a                	jne    800b8b <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b81:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b86:	80 39 30             	cmpb   $0x30,(%ecx)
  800b89:	74 28                	je     800bb3 <strtol+0x6c>
		base = 10;
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b90:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b93:	eb 50                	jmp    800be5 <strtol+0x9e>
		s++;
  800b95:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b98:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9d:	eb d1                	jmp    800b70 <strtol+0x29>
		s++, neg = 1;
  800b9f:	83 c1 01             	add    $0x1,%ecx
  800ba2:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba7:	eb c7                	jmp    800b70 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bad:	74 0e                	je     800bbd <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800baf:	85 db                	test   %ebx,%ebx
  800bb1:	75 d8                	jne    800b8b <strtol+0x44>
		s++, base = 8;
  800bb3:	83 c1 01             	add    $0x1,%ecx
  800bb6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bbb:	eb ce                	jmp    800b8b <strtol+0x44>
		s += 2, base = 16;
  800bbd:	83 c1 02             	add    $0x2,%ecx
  800bc0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc5:	eb c4                	jmp    800b8b <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bc7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bca:	89 f3                	mov    %esi,%ebx
  800bcc:	80 fb 19             	cmp    $0x19,%bl
  800bcf:	77 29                	ja     800bfa <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bd1:	0f be d2             	movsbl %dl,%edx
  800bd4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bda:	7d 30                	jge    800c0c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bdc:	83 c1 01             	add    $0x1,%ecx
  800bdf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800be5:	0f b6 11             	movzbl (%ecx),%edx
  800be8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800beb:	89 f3                	mov    %esi,%ebx
  800bed:	80 fb 09             	cmp    $0x9,%bl
  800bf0:	77 d5                	ja     800bc7 <strtol+0x80>
			dig = *s - '0';
  800bf2:	0f be d2             	movsbl %dl,%edx
  800bf5:	83 ea 30             	sub    $0x30,%edx
  800bf8:	eb dd                	jmp    800bd7 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bfa:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfd:	89 f3                	mov    %esi,%ebx
  800bff:	80 fb 19             	cmp    $0x19,%bl
  800c02:	77 08                	ja     800c0c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c04:	0f be d2             	movsbl %dl,%edx
  800c07:	83 ea 37             	sub    $0x37,%edx
  800c0a:	eb cb                	jmp    800bd7 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c10:	74 05                	je     800c17 <strtol+0xd0>
		*endptr = (char *) s;
  800c12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c15:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c17:	89 c2                	mov    %eax,%edx
  800c19:	f7 da                	neg    %edx
  800c1b:	85 ff                	test   %edi,%edi
  800c1d:	0f 45 c2             	cmovne %edx,%eax
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    
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
