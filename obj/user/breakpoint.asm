
obj/user/breakpoint:     file format elf32-i386


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
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 0c             	sub    $0xc,%esp
  800042:	e8 57 00 00 00       	call   80009e <__x86.get_pc_thunk.bx>
  800047:	81 c3 b9 1f 00 00    	add    $0x1fb9,%ebx
  80004d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800050:	c7 c6 2c 20 80 00    	mov    $0x80202c,%esi
  800056:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	thisenv = (struct Env*)(envs + ENVX(sys_getenvid())); //（为当前进程）初始化全局指针
  80005c:	e8 f4 00 00 00       	call   800155 <sys_getenvid>
  800061:	25 ff 03 00 00       	and    $0x3ff,%eax
  800066:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800069:	c1 e0 05             	shl    $0x5,%eax
  80006c:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800072:	89 06                	mov    %eax,(%esi)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800078:	7e 08                	jle    800082 <libmain+0x49>
		binaryname = argv[0];
  80007a:	8b 07                	mov    (%edi),%eax
  80007c:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	57                   	push   %edi
  800086:	ff 75 08             	pushl  0x8(%ebp)
  800089:	e8 a5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008e:	e8 0f 00 00 00       	call   8000a2 <exit>
}
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800099:	5b                   	pop    %ebx
  80009a:	5e                   	pop    %esi
  80009b:	5f                   	pop    %edi
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <__x86.get_pc_thunk.bx>:
  80009e:	8b 1c 24             	mov    (%esp),%ebx
  8000a1:	c3                   	ret    

008000a2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	53                   	push   %ebx
  8000a6:	83 ec 10             	sub    $0x10,%esp
  8000a9:	e8 f0 ff ff ff       	call   80009e <__x86.get_pc_thunk.bx>
  8000ae:	81 c3 52 1f 00 00    	add    $0x1f52,%ebx
	sys_env_destroy(0);
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 45 00 00 00       	call   800100 <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d4:	89 c3                	mov    %eax,%ebx
  8000d6:	89 c7                	mov    %eax,%edi
  8000d8:	89 c6                	mov    %eax,%esi
  8000da:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f1:	89 d1                	mov    %edx,%ecx
  8000f3:	89 d3                	mov    %edx,%ebx
  8000f5:	89 d7                	mov    %edx,%edi
  8000f7:	89 d6                	mov    %edx,%esi
  8000f9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	57                   	push   %edi
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	83 ec 1c             	sub    $0x1c,%esp
  800109:	e8 66 00 00 00       	call   800174 <__x86.get_pc_thunk.ax>
  80010e:	05 f2 1e 00 00       	add    $0x1ef2,%eax
  800113:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800116:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011b:	8b 55 08             	mov    0x8(%ebp),%edx
  80011e:	b8 03 00 00 00       	mov    $0x3,%eax
  800123:	89 cb                	mov    %ecx,%ebx
  800125:	89 cf                	mov    %ecx,%edi
  800127:	89 ce                	mov    %ecx,%esi
  800129:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	7f 08                	jg     800137 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	50                   	push   %eax
  80013b:	6a 03                	push   $0x3
  80013d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800140:	8d 83 66 ee ff ff    	lea    -0x119a(%ebx),%eax
  800146:	50                   	push   %eax
  800147:	6a 23                	push   $0x23
  800149:	8d 83 83 ee ff ff    	lea    -0x117d(%ebx),%eax
  80014f:	50                   	push   %eax
  800150:	e8 23 00 00 00       	call   800178 <_panic>

00800155 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	b8 02 00 00 00       	mov    $0x2,%eax
  800165:	89 d1                	mov    %edx,%ecx
  800167:	89 d3                	mov    %edx,%ebx
  800169:	89 d7                	mov    %edx,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016f:	5b                   	pop    %ebx
  800170:	5e                   	pop    %esi
  800171:	5f                   	pop    %edi
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <__x86.get_pc_thunk.ax>:
  800174:	8b 04 24             	mov    (%esp),%eax
  800177:	c3                   	ret    

00800178 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	e8 18 ff ff ff       	call   80009e <__x86.get_pc_thunk.bx>
  800186:	81 c3 7a 1e 00 00    	add    $0x1e7a,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018f:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800195:	8b 38                	mov    (%eax),%edi
  800197:	e8 b9 ff ff ff       	call   800155 <sys_getenvid>
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	ff 75 0c             	pushl  0xc(%ebp)
  8001a2:	ff 75 08             	pushl  0x8(%ebp)
  8001a5:	57                   	push   %edi
  8001a6:	50                   	push   %eax
  8001a7:	8d 83 94 ee ff ff    	lea    -0x116c(%ebx),%eax
  8001ad:	50                   	push   %eax
  8001ae:	e8 d1 00 00 00       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	56                   	push   %esi
  8001b7:	ff 75 10             	pushl  0x10(%ebp)
  8001ba:	e8 63 00 00 00       	call   800222 <vcprintf>
	cprintf("\n");
  8001bf:	8d 83 b8 ee ff ff    	lea    -0x1148(%ebx),%eax
  8001c5:	89 04 24             	mov    %eax,(%esp)
  8001c8:	e8 b7 00 00 00       	call   800284 <cprintf>
  8001cd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d0:	cc                   	int3   
  8001d1:	eb fd                	jmp    8001d0 <_panic+0x58>

008001d3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	e8 c1 fe ff ff       	call   80009e <__x86.get_pc_thunk.bx>
  8001dd:	81 c3 23 1e 00 00    	add    $0x1e23,%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e6:	8b 16                	mov    (%esi),%edx
  8001e8:	8d 42 01             	lea    0x1(%edx),%eax
  8001eb:	89 06                	mov    %eax,(%esi)
  8001ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f0:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f9:	74 0b                	je     800206 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fb:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800202:	5b                   	pop    %ebx
  800203:	5e                   	pop    %esi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	68 ff 00 00 00       	push   $0xff
  80020e:	8d 46 08             	lea    0x8(%esi),%eax
  800211:	50                   	push   %eax
  800212:	e8 ac fe ff ff       	call   8000c3 <sys_cputs>
		b->idx = 0;
  800217:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	eb d9                	jmp    8001fb <putch+0x28>

00800222 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	53                   	push   %ebx
  800226:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022c:	e8 6d fe ff ff       	call   80009e <__x86.get_pc_thunk.bx>
  800231:	81 c3 cf 1d 00 00    	add    $0x1dcf,%ebx
	struct printbuf b;

	b.idx = 0;
  800237:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023e:	00 00 00 
	b.cnt = 0;
  800241:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800248:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024b:	ff 75 0c             	pushl  0xc(%ebp)
  80024e:	ff 75 08             	pushl  0x8(%ebp)
  800251:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800257:	50                   	push   %eax
  800258:	8d 83 d3 e1 ff ff    	lea    -0x1e2d(%ebx),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 38 01 00 00       	call   80039c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800264:	83 c4 08             	add    $0x8,%esp
  800267:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800273:	50                   	push   %eax
  800274:	e8 4a fe ff ff       	call   8000c3 <sys_cputs>

	return b.cnt;
}
  800279:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 08             	pushl  0x8(%ebp)
  800291:	e8 8c ff ff ff       	call   800222 <vcprintf>
	va_end(ap);

	return cnt;
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 2c             	sub    $0x2c,%esp
  8002a1:	e8 02 06 00 00       	call   8008a8 <__x86.get_pc_thunk.cx>
  8002a6:	81 c1 5a 1d 00 00    	add    $0x1d5a,%ecx
  8002ac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002af:	89 c7                	mov    %eax,%edi
  8002b1:	89 d6                	mov    %edx,%esi
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002bc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c7:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002ca:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002cd:	39 d3                	cmp    %edx,%ebx
  8002cf:	72 09                	jb     8002da <printnum+0x42>
  8002d1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d4:	0f 87 83 00 00 00    	ja     80035d <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002da:	83 ec 0c             	sub    $0xc,%esp
  8002dd:	ff 75 18             	pushl  0x18(%ebp)
  8002e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e6:	53                   	push   %ebx
  8002e7:	ff 75 10             	pushl  0x10(%ebp)
  8002ea:	83 ec 08             	sub    $0x8,%esp
  8002ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f6:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002fc:	e8 1f 09 00 00       	call   800c20 <__udivdi3>
  800301:	83 c4 18             	add    $0x18,%esp
  800304:	52                   	push   %edx
  800305:	50                   	push   %eax
  800306:	89 f2                	mov    %esi,%edx
  800308:	89 f8                	mov    %edi,%eax
  80030a:	e8 89 ff ff ff       	call   800298 <printnum>
  80030f:	83 c4 20             	add    $0x20,%esp
  800312:	eb 13                	jmp    800327 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800314:	83 ec 08             	sub    $0x8,%esp
  800317:	56                   	push   %esi
  800318:	ff 75 18             	pushl  0x18(%ebp)
  80031b:	ff d7                	call   *%edi
  80031d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800320:	83 eb 01             	sub    $0x1,%ebx
  800323:	85 db                	test   %ebx,%ebx
  800325:	7f ed                	jg     800314 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800327:	83 ec 08             	sub    $0x8,%esp
  80032a:	56                   	push   %esi
  80032b:	83 ec 04             	sub    $0x4,%esp
  80032e:	ff 75 dc             	pushl  -0x24(%ebp)
  800331:	ff 75 d8             	pushl  -0x28(%ebp)
  800334:	ff 75 d4             	pushl  -0x2c(%ebp)
  800337:	ff 75 d0             	pushl  -0x30(%ebp)
  80033a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80033d:	89 f3                	mov    %esi,%ebx
  80033f:	e8 fc 09 00 00       	call   800d40 <__umoddi3>
  800344:	83 c4 14             	add    $0x14,%esp
  800347:	0f be 84 06 ba ee ff 	movsbl -0x1146(%esi,%eax,1),%eax
  80034e:	ff 
  80034f:	50                   	push   %eax
  800350:	ff d7                	call   *%edi
}
  800352:	83 c4 10             	add    $0x10,%esp
  800355:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800358:	5b                   	pop    %ebx
  800359:	5e                   	pop    %esi
  80035a:	5f                   	pop    %edi
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    
  80035d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800360:	eb be                	jmp    800320 <printnum+0x88>

00800362 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800368:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	3b 50 04             	cmp    0x4(%eax),%edx
  800371:	73 0a                	jae    80037d <sprintputch+0x1b>
		*b->buf++ = ch;
  800373:	8d 4a 01             	lea    0x1(%edx),%ecx
  800376:	89 08                	mov    %ecx,(%eax)
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	88 02                	mov    %al,(%edx)
}
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <printfmt>:
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800385:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800388:	50                   	push   %eax
  800389:	ff 75 10             	pushl  0x10(%ebp)
  80038c:	ff 75 0c             	pushl  0xc(%ebp)
  80038f:	ff 75 08             	pushl  0x8(%ebp)
  800392:	e8 05 00 00 00       	call   80039c <vprintfmt>
}
  800397:	83 c4 10             	add    $0x10,%esp
  80039a:	c9                   	leave  
  80039b:	c3                   	ret    

0080039c <vprintfmt>:
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	57                   	push   %edi
  8003a0:	56                   	push   %esi
  8003a1:	53                   	push   %ebx
  8003a2:	83 ec 2c             	sub    $0x2c,%esp
  8003a5:	e8 f4 fc ff ff       	call   80009e <__x86.get_pc_thunk.bx>
  8003aa:	81 c3 56 1c 00 00    	add    $0x1c56,%ebx
  8003b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b6:	e9 c3 03 00 00       	jmp    80077e <.L35+0x48>
		padc = ' ';
  8003bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003c6:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8d 47 01             	lea    0x1(%edi),%eax
  8003df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e2:	0f b6 17             	movzbl (%edi),%edx
  8003e5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e8:	3c 55                	cmp    $0x55,%al
  8003ea:	0f 87 16 04 00 00    	ja     800806 <.L22>
  8003f0:	0f b6 c0             	movzbl %al,%eax
  8003f3:	89 d9                	mov    %ebx,%ecx
  8003f5:	03 8c 83 48 ef ff ff 	add    -0x10b8(%ebx,%eax,4),%ecx
  8003fc:	ff e1                	jmp    *%ecx

008003fe <.L69>:
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800401:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800405:	eb d5                	jmp    8003dc <vprintfmt+0x40>

00800407 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80040a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040e:	eb cc                	jmp    8003dc <vprintfmt+0x40>

00800410 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	0f b6 d2             	movzbl %dl,%edx
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80041b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800422:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800425:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800428:	83 f9 09             	cmp    $0x9,%ecx
  80042b:	77 55                	ja     800482 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80042d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800430:	eb e9                	jmp    80041b <.L29+0xb>

00800432 <.L26>:
			precision = va_arg(ap, int);
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8b 00                	mov    (%eax),%eax
  800437:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 40 04             	lea    0x4(%eax),%eax
  800440:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800446:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044a:	79 90                	jns    8003dc <vprintfmt+0x40>
				width = precision, precision = -1;
  80044c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80044f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800452:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800459:	eb 81                	jmp    8003dc <vprintfmt+0x40>

0080045b <.L27>:
  80045b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045e:	85 c0                	test   %eax,%eax
  800460:	ba 00 00 00 00       	mov    $0x0,%edx
  800465:	0f 49 d0             	cmovns %eax,%edx
  800468:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	e9 69 ff ff ff       	jmp    8003dc <vprintfmt+0x40>

00800473 <.L23>:
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800476:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047d:	e9 5a ff ff ff       	jmp    8003dc <vprintfmt+0x40>
  800482:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800485:	eb bf                	jmp    800446 <.L26+0x14>

00800487 <.L33>:
			lflag++;
  800487:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80048e:	e9 49 ff ff ff       	jmp    8003dc <vprintfmt+0x40>

00800493 <.L30>:
			putch(va_arg(ap, int), putdat);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 78 04             	lea    0x4(%eax),%edi
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	56                   	push   %esi
  80049d:	ff 30                	pushl  (%eax)
  80049f:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004a5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004a8:	e9 ce 02 00 00       	jmp    80077b <.L35+0x45>

008004ad <.L32>:
			err = va_arg(ap, int);
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 78 04             	lea    0x4(%eax),%edi
  8004b3:	8b 00                	mov    (%eax),%eax
  8004b5:	99                   	cltd   
  8004b6:	31 d0                	xor    %edx,%eax
  8004b8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ba:	83 f8 06             	cmp    $0x6,%eax
  8004bd:	7f 27                	jg     8004e6 <.L32+0x39>
  8004bf:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004c6:	85 d2                	test   %edx,%edx
  8004c8:	74 1c                	je     8004e6 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004ca:	52                   	push   %edx
  8004cb:	8d 83 db ee ff ff    	lea    -0x1125(%ebx),%eax
  8004d1:	50                   	push   %eax
  8004d2:	56                   	push   %esi
  8004d3:	ff 75 08             	pushl  0x8(%ebp)
  8004d6:	e8 a4 fe ff ff       	call   80037f <printfmt>
  8004db:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004de:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e1:	e9 95 02 00 00       	jmp    80077b <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	50                   	push   %eax
  8004e7:	8d 83 d2 ee ff ff    	lea    -0x112e(%ebx),%eax
  8004ed:	50                   	push   %eax
  8004ee:	56                   	push   %esi
  8004ef:	ff 75 08             	pushl  0x8(%ebp)
  8004f2:	e8 88 fe ff ff       	call   80037f <printfmt>
  8004f7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fa:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004fd:	e9 79 02 00 00       	jmp    80077b <.L35+0x45>

00800502 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	83 c0 04             	add    $0x4,%eax
  800508:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800510:	85 ff                	test   %edi,%edi
  800512:	8d 83 cb ee ff ff    	lea    -0x1135(%ebx),%eax
  800518:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051f:	0f 8e b5 00 00 00    	jle    8005da <.L36+0xd8>
  800525:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800529:	75 08                	jne    800533 <.L36+0x31>
  80052b:	89 75 0c             	mov    %esi,0xc(%ebp)
  80052e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800531:	eb 6d                	jmp    8005a0 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	ff 75 cc             	pushl  -0x34(%ebp)
  800539:	57                   	push   %edi
  80053a:	e8 85 03 00 00       	call   8008c4 <strnlen>
  80053f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800542:	29 c2                	sub    %eax,%edx
  800544:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800547:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80054a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800551:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800554:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800556:	eb 10                	jmp    800568 <.L36+0x66>
					putch(padc, putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	56                   	push   %esi
  80055c:	ff 75 e0             	pushl  -0x20(%ebp)
  80055f:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	83 ef 01             	sub    $0x1,%edi
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	85 ff                	test   %edi,%edi
  80056a:	7f ec                	jg     800558 <.L36+0x56>
  80056c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056f:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800572:	85 d2                	test   %edx,%edx
  800574:	b8 00 00 00 00       	mov    $0x0,%eax
  800579:	0f 49 c2             	cmovns %edx,%eax
  80057c:	29 c2                	sub    %eax,%edx
  80057e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800581:	89 75 0c             	mov    %esi,0xc(%ebp)
  800584:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800587:	eb 17                	jmp    8005a0 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800589:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058d:	75 30                	jne    8005bf <.L36+0xbd>
					putch(ch, putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	ff 75 0c             	pushl  0xc(%ebp)
  800595:	50                   	push   %eax
  800596:	ff 55 08             	call   *0x8(%ebp)
  800599:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059c:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005a0:	83 c7 01             	add    $0x1,%edi
  8005a3:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a7:	0f be c2             	movsbl %dl,%eax
  8005aa:	85 c0                	test   %eax,%eax
  8005ac:	74 52                	je     800600 <.L36+0xfe>
  8005ae:	85 f6                	test   %esi,%esi
  8005b0:	78 d7                	js     800589 <.L36+0x87>
  8005b2:	83 ee 01             	sub    $0x1,%esi
  8005b5:	79 d2                	jns    800589 <.L36+0x87>
  8005b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ba:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005bd:	eb 32                	jmp    8005f1 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005bf:	0f be d2             	movsbl %dl,%edx
  8005c2:	83 ea 20             	sub    $0x20,%edx
  8005c5:	83 fa 5e             	cmp    $0x5e,%edx
  8005c8:	76 c5                	jbe    80058f <.L36+0x8d>
					putch('?', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	ff 75 0c             	pushl  0xc(%ebp)
  8005d0:	6a 3f                	push   $0x3f
  8005d2:	ff 55 08             	call   *0x8(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	eb c2                	jmp    80059c <.L36+0x9a>
  8005da:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005dd:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005e0:	eb be                	jmp    8005a0 <.L36+0x9e>
				putch(' ', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	56                   	push   %esi
  8005e6:	6a 20                	push   $0x20
  8005e8:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005eb:	83 ef 01             	sub    $0x1,%edi
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	85 ff                	test   %edi,%edi
  8005f3:	7f ed                	jg     8005e2 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fb:	e9 7b 01 00 00       	jmp    80077b <.L35+0x45>
  800600:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800603:	8b 75 0c             	mov    0xc(%ebp),%esi
  800606:	eb e9                	jmp    8005f1 <.L36+0xef>

00800608 <.L31>:
  800608:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80060b:	83 f9 01             	cmp    $0x1,%ecx
  80060e:	7e 40                	jle    800650 <.L31+0x48>
		return va_arg(*ap, long long);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8b 50 04             	mov    0x4(%eax),%edx
  800616:	8b 00                	mov    (%eax),%eax
  800618:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 40 08             	lea    0x8(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800627:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062b:	79 55                	jns    800682 <.L31+0x7a>
				putch('-', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	56                   	push   %esi
  800631:	6a 2d                	push   $0x2d
  800633:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800636:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800639:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063c:	f7 da                	neg    %edx
  80063e:	83 d1 00             	adc    $0x0,%ecx
  800641:	f7 d9                	neg    %ecx
  800643:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 10 01 00 00       	jmp    800760 <.L35+0x2a>
	else if (lflag)
  800650:	85 c9                	test   %ecx,%ecx
  800652:	75 17                	jne    80066b <.L31+0x63>
		return va_arg(*ap, int);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 00                	mov    (%eax),%eax
  800659:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065c:	99                   	cltd   
  80065d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 40 04             	lea    0x4(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
  800669:	eb bc                	jmp    800627 <.L31+0x1f>
		return va_arg(*ap, long);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 00                	mov    (%eax),%eax
  800670:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800673:	99                   	cltd   
  800674:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 40 04             	lea    0x4(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
  800680:	eb a5                	jmp    800627 <.L31+0x1f>
			num = getint(&ap, lflag);
  800682:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800685:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800688:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068d:	e9 ce 00 00 00       	jmp    800760 <.L35+0x2a>

00800692 <.L37>:
  800692:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800695:	83 f9 01             	cmp    $0x1,%ecx
  800698:	7e 18                	jle    8006b2 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a2:	8d 40 08             	lea    0x8(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ad:	e9 ae 00 00 00       	jmp    800760 <.L35+0x2a>
	else if (lflag)
  8006b2:	85 c9                	test   %ecx,%ecx
  8006b4:	75 1a                	jne    8006d0 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8b 10                	mov    (%eax),%edx
  8006bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c0:	8d 40 04             	lea    0x4(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cb:	e9 90 00 00 00       	jmp    800760 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e5:	eb 79                	jmp    800760 <.L35+0x2a>

008006e7 <.L34>:
  8006e7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006ea:	83 f9 01             	cmp    $0x1,%ecx
  8006ed:	7e 15                	jle    800704 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f7:	8d 40 08             	lea    0x8(%eax),%eax
  8006fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006fd:	b8 08 00 00 00       	mov    $0x8,%eax
  800702:	eb 5c                	jmp    800760 <.L35+0x2a>
	else if (lflag)
  800704:	85 c9                	test   %ecx,%ecx
  800706:	75 17                	jne    80071f <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800712:	8d 40 04             	lea    0x4(%eax),%eax
  800715:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800718:	b8 08 00 00 00       	mov    $0x8,%eax
  80071d:	eb 41                	jmp    800760 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8b 10                	mov    (%eax),%edx
  800724:	b9 00 00 00 00       	mov    $0x0,%ecx
  800729:	8d 40 04             	lea    0x4(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80072f:	b8 08 00 00 00       	mov    $0x8,%eax
  800734:	eb 2a                	jmp    800760 <.L35+0x2a>

00800736 <.L35>:
			putch('0', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	56                   	push   %esi
  80073a:	6a 30                	push   $0x30
  80073c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80073f:	83 c4 08             	add    $0x8,%esp
  800742:	56                   	push   %esi
  800743:	6a 78                	push   $0x78
  800745:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800752:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800755:	8d 40 04             	lea    0x4(%eax),%eax
  800758:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800760:	83 ec 0c             	sub    $0xc,%esp
  800763:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800767:	57                   	push   %edi
  800768:	ff 75 e0             	pushl  -0x20(%ebp)
  80076b:	50                   	push   %eax
  80076c:	51                   	push   %ecx
  80076d:	52                   	push   %edx
  80076e:	89 f2                	mov    %esi,%edx
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	e8 20 fb ff ff       	call   800298 <printnum>
			break;
  800778:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80077b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80077e:	83 c7 01             	add    $0x1,%edi
  800781:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800785:	83 f8 25             	cmp    $0x25,%eax
  800788:	0f 84 2d fc ff ff    	je     8003bb <vprintfmt+0x1f>
			if (ch == '\0')
  80078e:	85 c0                	test   %eax,%eax
  800790:	0f 84 91 00 00 00    	je     800827 <.L22+0x21>
			putch(ch, putdat);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	56                   	push   %esi
  80079a:	50                   	push   %eax
  80079b:	ff 55 08             	call   *0x8(%ebp)
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	eb db                	jmp    80077e <.L35+0x48>

008007a3 <.L38>:
  8007a3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007a6:	83 f9 01             	cmp    $0x1,%ecx
  8007a9:	7e 15                	jle    8007c0 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8b 10                	mov    (%eax),%edx
  8007b0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007b3:	8d 40 08             	lea    0x8(%eax),%eax
  8007b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b9:	b8 10 00 00 00       	mov    $0x10,%eax
  8007be:	eb a0                	jmp    800760 <.L35+0x2a>
	else if (lflag)
  8007c0:	85 c9                	test   %ecx,%ecx
  8007c2:	75 17                	jne    8007db <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8b 10                	mov    (%eax),%edx
  8007c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ce:	8d 40 04             	lea    0x4(%eax),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d4:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d9:	eb 85                	jmp    800760 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8b 10                	mov    (%eax),%edx
  8007e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e5:	8d 40 04             	lea    0x4(%eax),%eax
  8007e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007eb:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f0:	e9 6b ff ff ff       	jmp    800760 <.L35+0x2a>

008007f5 <.L25>:
			putch(ch, putdat);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	56                   	push   %esi
  8007f9:	6a 25                	push   $0x25
  8007fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	e9 75 ff ff ff       	jmp    80077b <.L35+0x45>

00800806 <.L22>:
			putch('%', putdat);
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	56                   	push   %esi
  80080a:	6a 25                	push   $0x25
  80080c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	89 f8                	mov    %edi,%eax
  800814:	eb 03                	jmp    800819 <.L22+0x13>
  800816:	83 e8 01             	sub    $0x1,%eax
  800819:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80081d:	75 f7                	jne    800816 <.L22+0x10>
  80081f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800822:	e9 54 ff ff ff       	jmp    80077b <.L35+0x45>
}
  800827:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80082a:	5b                   	pop    %ebx
  80082b:	5e                   	pop    %esi
  80082c:	5f                   	pop    %edi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	83 ec 14             	sub    $0x14,%esp
  800836:	e8 63 f8 ff ff       	call   80009e <__x86.get_pc_thunk.bx>
  80083b:	81 c3 c5 17 00 00    	add    $0x17c5,%ebx
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800847:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80084e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800851:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800858:	85 c0                	test   %eax,%eax
  80085a:	74 2b                	je     800887 <vsnprintf+0x58>
  80085c:	85 d2                	test   %edx,%edx
  80085e:	7e 27                	jle    800887 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800860:	ff 75 14             	pushl  0x14(%ebp)
  800863:	ff 75 10             	pushl  0x10(%ebp)
  800866:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800869:	50                   	push   %eax
  80086a:	8d 83 62 e3 ff ff    	lea    -0x1c9e(%ebx),%eax
  800870:	50                   	push   %eax
  800871:	e8 26 fb ff ff       	call   80039c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800876:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800879:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087f:	83 c4 10             	add    $0x10,%esp
}
  800882:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800885:	c9                   	leave  
  800886:	c3                   	ret    
		return -E_INVAL;
  800887:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088c:	eb f4                	jmp    800882 <vsnprintf+0x53>

0080088e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800894:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800897:	50                   	push   %eax
  800898:	ff 75 10             	pushl  0x10(%ebp)
  80089b:	ff 75 0c             	pushl  0xc(%ebp)
  80089e:	ff 75 08             	pushl  0x8(%ebp)
  8008a1:	e8 89 ff ff ff       	call   80082f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <__x86.get_pc_thunk.cx>:
  8008a8:	8b 0c 24             	mov    (%esp),%ecx
  8008ab:	c3                   	ret    

008008ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b7:	eb 03                	jmp    8008bc <strlen+0x10>
		n++;
  8008b9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c0:	75 f7                	jne    8008b9 <strlen+0xd>
	return n;
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d2:	eb 03                	jmp    8008d7 <strnlen+0x13>
		n++;
  8008d4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d7:	39 d0                	cmp    %edx,%eax
  8008d9:	74 06                	je     8008e1 <strnlen+0x1d>
  8008db:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008df:	75 f3                	jne    8008d4 <strnlen+0x10>
	return n;
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ed:	89 c2                	mov    %eax,%edx
  8008ef:	83 c1 01             	add    $0x1,%ecx
  8008f2:	83 c2 01             	add    $0x1,%edx
  8008f5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fc:	84 db                	test   %bl,%bl
  8008fe:	75 ef                	jne    8008ef <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800900:	5b                   	pop    %ebx
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090a:	53                   	push   %ebx
  80090b:	e8 9c ff ff ff       	call   8008ac <strlen>
  800910:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800913:	ff 75 0c             	pushl  0xc(%ebp)
  800916:	01 d8                	add    %ebx,%eax
  800918:	50                   	push   %eax
  800919:	e8 c5 ff ff ff       	call   8008e3 <strcpy>
	return dst;
}
  80091e:	89 d8                	mov    %ebx,%eax
  800920:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	8b 75 08             	mov    0x8(%ebp),%esi
  80092d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800930:	89 f3                	mov    %esi,%ebx
  800932:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800935:	89 f2                	mov    %esi,%edx
  800937:	eb 0f                	jmp    800948 <strncpy+0x23>
		*dst++ = *src;
  800939:	83 c2 01             	add    $0x1,%edx
  80093c:	0f b6 01             	movzbl (%ecx),%eax
  80093f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800942:	80 39 01             	cmpb   $0x1,(%ecx)
  800945:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800948:	39 da                	cmp    %ebx,%edx
  80094a:	75 ed                	jne    800939 <strncpy+0x14>
	}
	return ret;
}
  80094c:	89 f0                	mov    %esi,%eax
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 75 08             	mov    0x8(%ebp),%esi
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800960:	89 f0                	mov    %esi,%eax
  800962:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800966:	85 c9                	test   %ecx,%ecx
  800968:	75 0b                	jne    800975 <strlcpy+0x23>
  80096a:	eb 17                	jmp    800983 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096c:	83 c2 01             	add    $0x1,%edx
  80096f:	83 c0 01             	add    $0x1,%eax
  800972:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800975:	39 d8                	cmp    %ebx,%eax
  800977:	74 07                	je     800980 <strlcpy+0x2e>
  800979:	0f b6 0a             	movzbl (%edx),%ecx
  80097c:	84 c9                	test   %cl,%cl
  80097e:	75 ec                	jne    80096c <strlcpy+0x1a>
		*dst = '\0';
  800980:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800983:	29 f0                	sub    %esi,%eax
}
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800992:	eb 06                	jmp    80099a <strcmp+0x11>
		p++, q++;
  800994:	83 c1 01             	add    $0x1,%ecx
  800997:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80099a:	0f b6 01             	movzbl (%ecx),%eax
  80099d:	84 c0                	test   %al,%al
  80099f:	74 04                	je     8009a5 <strcmp+0x1c>
  8009a1:	3a 02                	cmp    (%edx),%al
  8009a3:	74 ef                	je     800994 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a5:	0f b6 c0             	movzbl %al,%eax
  8009a8:	0f b6 12             	movzbl (%edx),%edx
  8009ab:	29 d0                	sub    %edx,%eax
}
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	53                   	push   %ebx
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b9:	89 c3                	mov    %eax,%ebx
  8009bb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009be:	eb 06                	jmp    8009c6 <strncmp+0x17>
		n--, p++, q++;
  8009c0:	83 c0 01             	add    $0x1,%eax
  8009c3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c6:	39 d8                	cmp    %ebx,%eax
  8009c8:	74 16                	je     8009e0 <strncmp+0x31>
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	84 c9                	test   %cl,%cl
  8009cf:	74 04                	je     8009d5 <strncmp+0x26>
  8009d1:	3a 0a                	cmp    (%edx),%cl
  8009d3:	74 eb                	je     8009c0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d5:	0f b6 00             	movzbl (%eax),%eax
  8009d8:	0f b6 12             	movzbl (%edx),%edx
  8009db:	29 d0                	sub    %edx,%eax
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    
		return 0;
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e5:	eb f6                	jmp    8009dd <strncmp+0x2e>

008009e7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f1:	0f b6 10             	movzbl (%eax),%edx
  8009f4:	84 d2                	test   %dl,%dl
  8009f6:	74 09                	je     800a01 <strchr+0x1a>
		if (*s == c)
  8009f8:	38 ca                	cmp    %cl,%dl
  8009fa:	74 0a                	je     800a06 <strchr+0x1f>
	for (; *s; s++)
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	eb f0                	jmp    8009f1 <strchr+0xa>
			return (char *) s;
	return 0;
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a12:	eb 03                	jmp    800a17 <strfind+0xf>
  800a14:	83 c0 01             	add    $0x1,%eax
  800a17:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a1a:	38 ca                	cmp    %cl,%dl
  800a1c:	74 04                	je     800a22 <strfind+0x1a>
  800a1e:	84 d2                	test   %dl,%dl
  800a20:	75 f2                	jne    800a14 <strfind+0xc>
			break;
	return (char *) s;
}
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a30:	85 c9                	test   %ecx,%ecx
  800a32:	74 13                	je     800a47 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3a:	75 05                	jne    800a41 <memset+0x1d>
  800a3c:	f6 c1 03             	test   $0x3,%cl
  800a3f:	74 0d                	je     800a4e <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a44:	fc                   	cld    
  800a45:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a47:	89 f8                	mov    %edi,%eax
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    
		c &= 0xFF;
  800a4e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a52:	89 d3                	mov    %edx,%ebx
  800a54:	c1 e3 08             	shl    $0x8,%ebx
  800a57:	89 d0                	mov    %edx,%eax
  800a59:	c1 e0 18             	shl    $0x18,%eax
  800a5c:	89 d6                	mov    %edx,%esi
  800a5e:	c1 e6 10             	shl    $0x10,%esi
  800a61:	09 f0                	or     %esi,%eax
  800a63:	09 c2                	or     %eax,%edx
  800a65:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a67:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a6a:	89 d0                	mov    %edx,%eax
  800a6c:	fc                   	cld    
  800a6d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6f:	eb d6                	jmp    800a47 <memset+0x23>

00800a71 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7f:	39 c6                	cmp    %eax,%esi
  800a81:	73 35                	jae    800ab8 <memmove+0x47>
  800a83:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a86:	39 c2                	cmp    %eax,%edx
  800a88:	76 2e                	jbe    800ab8 <memmove+0x47>
		s += n;
		d += n;
  800a8a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8d:	89 d6                	mov    %edx,%esi
  800a8f:	09 fe                	or     %edi,%esi
  800a91:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a97:	74 0c                	je     800aa5 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a99:	83 ef 01             	sub    $0x1,%edi
  800a9c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a9f:	fd                   	std    
  800aa0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa2:	fc                   	cld    
  800aa3:	eb 21                	jmp    800ac6 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa5:	f6 c1 03             	test   $0x3,%cl
  800aa8:	75 ef                	jne    800a99 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aaa:	83 ef 04             	sub    $0x4,%edi
  800aad:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab3:	fd                   	std    
  800ab4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab6:	eb ea                	jmp    800aa2 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab8:	89 f2                	mov    %esi,%edx
  800aba:	09 c2                	or     %eax,%edx
  800abc:	f6 c2 03             	test   $0x3,%dl
  800abf:	74 09                	je     800aca <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac1:	89 c7                	mov    %eax,%edi
  800ac3:	fc                   	cld    
  800ac4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aca:	f6 c1 03             	test   $0x3,%cl
  800acd:	75 f2                	jne    800ac1 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800acf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ad2:	89 c7                	mov    %eax,%edi
  800ad4:	fc                   	cld    
  800ad5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad7:	eb ed                	jmp    800ac6 <memmove+0x55>

00800ad9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800adc:	ff 75 10             	pushl  0x10(%ebp)
  800adf:	ff 75 0c             	pushl  0xc(%ebp)
  800ae2:	ff 75 08             	pushl  0x8(%ebp)
  800ae5:	e8 87 ff ff ff       	call   800a71 <memmove>
}
  800aea:	c9                   	leave  
  800aeb:	c3                   	ret    

00800aec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af7:	89 c6                	mov    %eax,%esi
  800af9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afc:	39 f0                	cmp    %esi,%eax
  800afe:	74 1c                	je     800b1c <memcmp+0x30>
		if (*s1 != *s2)
  800b00:	0f b6 08             	movzbl (%eax),%ecx
  800b03:	0f b6 1a             	movzbl (%edx),%ebx
  800b06:	38 d9                	cmp    %bl,%cl
  800b08:	75 08                	jne    800b12 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	83 c2 01             	add    $0x1,%edx
  800b10:	eb ea                	jmp    800afc <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b12:	0f b6 c1             	movzbl %cl,%eax
  800b15:	0f b6 db             	movzbl %bl,%ebx
  800b18:	29 d8                	sub    %ebx,%eax
  800b1a:	eb 05                	jmp    800b21 <memcmp+0x35>
	}

	return 0;
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b33:	39 d0                	cmp    %edx,%eax
  800b35:	73 09                	jae    800b40 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b37:	38 08                	cmp    %cl,(%eax)
  800b39:	74 05                	je     800b40 <memfind+0x1b>
	for (; s < ends; s++)
  800b3b:	83 c0 01             	add    $0x1,%eax
  800b3e:	eb f3                	jmp    800b33 <memfind+0xe>
			break;
	return (void *) s;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4e:	eb 03                	jmp    800b53 <strtol+0x11>
		s++;
  800b50:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b53:	0f b6 01             	movzbl (%ecx),%eax
  800b56:	3c 20                	cmp    $0x20,%al
  800b58:	74 f6                	je     800b50 <strtol+0xe>
  800b5a:	3c 09                	cmp    $0x9,%al
  800b5c:	74 f2                	je     800b50 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b5e:	3c 2b                	cmp    $0x2b,%al
  800b60:	74 2e                	je     800b90 <strtol+0x4e>
	int neg = 0;
  800b62:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b67:	3c 2d                	cmp    $0x2d,%al
  800b69:	74 2f                	je     800b9a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b71:	75 05                	jne    800b78 <strtol+0x36>
  800b73:	80 39 30             	cmpb   $0x30,(%ecx)
  800b76:	74 2c                	je     800ba4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b78:	85 db                	test   %ebx,%ebx
  800b7a:	75 0a                	jne    800b86 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b81:	80 39 30             	cmpb   $0x30,(%ecx)
  800b84:	74 28                	je     800bae <strtol+0x6c>
		base = 10;
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b8e:	eb 50                	jmp    800be0 <strtol+0x9e>
		s++;
  800b90:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b93:	bf 00 00 00 00       	mov    $0x0,%edi
  800b98:	eb d1                	jmp    800b6b <strtol+0x29>
		s++, neg = 1;
  800b9a:	83 c1 01             	add    $0x1,%ecx
  800b9d:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba2:	eb c7                	jmp    800b6b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba8:	74 0e                	je     800bb8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800baa:	85 db                	test   %ebx,%ebx
  800bac:	75 d8                	jne    800b86 <strtol+0x44>
		s++, base = 8;
  800bae:	83 c1 01             	add    $0x1,%ecx
  800bb1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb6:	eb ce                	jmp    800b86 <strtol+0x44>
		s += 2, base = 16;
  800bb8:	83 c1 02             	add    $0x2,%ecx
  800bbb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc0:	eb c4                	jmp    800b86 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bc2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bc5:	89 f3                	mov    %esi,%ebx
  800bc7:	80 fb 19             	cmp    $0x19,%bl
  800bca:	77 29                	ja     800bf5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bcc:	0f be d2             	movsbl %dl,%edx
  800bcf:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd5:	7d 30                	jge    800c07 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd7:	83 c1 01             	add    $0x1,%ecx
  800bda:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bde:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800be0:	0f b6 11             	movzbl (%ecx),%edx
  800be3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be6:	89 f3                	mov    %esi,%ebx
  800be8:	80 fb 09             	cmp    $0x9,%bl
  800beb:	77 d5                	ja     800bc2 <strtol+0x80>
			dig = *s - '0';
  800bed:	0f be d2             	movsbl %dl,%edx
  800bf0:	83 ea 30             	sub    $0x30,%edx
  800bf3:	eb dd                	jmp    800bd2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bf5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf8:	89 f3                	mov    %esi,%ebx
  800bfa:	80 fb 19             	cmp    $0x19,%bl
  800bfd:	77 08                	ja     800c07 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bff:	0f be d2             	movsbl %dl,%edx
  800c02:	83 ea 37             	sub    $0x37,%edx
  800c05:	eb cb                	jmp    800bd2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0b:	74 05                	je     800c12 <strtol+0xd0>
		*endptr = (char *) s;
  800c0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c10:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c12:	89 c2                	mov    %eax,%edx
  800c14:	f7 da                	neg    %edx
  800c16:	85 ff                	test   %edi,%edi
  800c18:	0f 45 c2             	cmovne %edx,%eax
}
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <__udivdi3>:
  800c20:	55                   	push   %ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 1c             	sub    $0x1c,%esp
  800c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c2b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c33:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c37:	85 d2                	test   %edx,%edx
  800c39:	75 35                	jne    800c70 <__udivdi3+0x50>
  800c3b:	39 f3                	cmp    %esi,%ebx
  800c3d:	0f 87 bd 00 00 00    	ja     800d00 <__udivdi3+0xe0>
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	89 d9                	mov    %ebx,%ecx
  800c47:	75 0b                	jne    800c54 <__udivdi3+0x34>
  800c49:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4e:	31 d2                	xor    %edx,%edx
  800c50:	f7 f3                	div    %ebx
  800c52:	89 c1                	mov    %eax,%ecx
  800c54:	31 d2                	xor    %edx,%edx
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	f7 f1                	div    %ecx
  800c5a:	89 c6                	mov    %eax,%esi
  800c5c:	89 e8                	mov    %ebp,%eax
  800c5e:	89 f7                	mov    %esi,%edi
  800c60:	f7 f1                	div    %ecx
  800c62:	89 fa                	mov    %edi,%edx
  800c64:	83 c4 1c             	add    $0x1c,%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    
  800c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c70:	39 f2                	cmp    %esi,%edx
  800c72:	77 7c                	ja     800cf0 <__udivdi3+0xd0>
  800c74:	0f bd fa             	bsr    %edx,%edi
  800c77:	83 f7 1f             	xor    $0x1f,%edi
  800c7a:	0f 84 98 00 00 00    	je     800d18 <__udivdi3+0xf8>
  800c80:	89 f9                	mov    %edi,%ecx
  800c82:	b8 20 00 00 00       	mov    $0x20,%eax
  800c87:	29 f8                	sub    %edi,%eax
  800c89:	d3 e2                	shl    %cl,%edx
  800c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	89 da                	mov    %ebx,%edx
  800c93:	d3 ea                	shr    %cl,%edx
  800c95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c99:	09 d1                	or     %edx,%ecx
  800c9b:	89 f2                	mov    %esi,%edx
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f9                	mov    %edi,%ecx
  800ca3:	d3 e3                	shl    %cl,%ebx
  800ca5:	89 c1                	mov    %eax,%ecx
  800ca7:	d3 ea                	shr    %cl,%edx
  800ca9:	89 f9                	mov    %edi,%ecx
  800cab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800caf:	d3 e6                	shl    %cl,%esi
  800cb1:	89 eb                	mov    %ebp,%ebx
  800cb3:	89 c1                	mov    %eax,%ecx
  800cb5:	d3 eb                	shr    %cl,%ebx
  800cb7:	09 de                	or     %ebx,%esi
  800cb9:	89 f0                	mov    %esi,%eax
  800cbb:	f7 74 24 08          	divl   0x8(%esp)
  800cbf:	89 d6                	mov    %edx,%esi
  800cc1:	89 c3                	mov    %eax,%ebx
  800cc3:	f7 64 24 0c          	mull   0xc(%esp)
  800cc7:	39 d6                	cmp    %edx,%esi
  800cc9:	72 0c                	jb     800cd7 <__udivdi3+0xb7>
  800ccb:	89 f9                	mov    %edi,%ecx
  800ccd:	d3 e5                	shl    %cl,%ebp
  800ccf:	39 c5                	cmp    %eax,%ebp
  800cd1:	73 5d                	jae    800d30 <__udivdi3+0x110>
  800cd3:	39 d6                	cmp    %edx,%esi
  800cd5:	75 59                	jne    800d30 <__udivdi3+0x110>
  800cd7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cda:	31 ff                	xor    %edi,%edi
  800cdc:	89 fa                	mov    %edi,%edx
  800cde:	83 c4 1c             	add    $0x1c,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    
  800ce6:	8d 76 00             	lea    0x0(%esi),%esi
  800ce9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cf0:	31 ff                	xor    %edi,%edi
  800cf2:	31 c0                	xor    %eax,%eax
  800cf4:	89 fa                	mov    %edi,%edx
  800cf6:	83 c4 1c             	add    $0x1c,%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
  800cfe:	66 90                	xchg   %ax,%ax
  800d00:	31 ff                	xor    %edi,%edi
  800d02:	89 e8                	mov    %ebp,%eax
  800d04:	89 f2                	mov    %esi,%edx
  800d06:	f7 f3                	div    %ebx
  800d08:	89 fa                	mov    %edi,%edx
  800d0a:	83 c4 1c             	add    $0x1c,%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
  800d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d18:	39 f2                	cmp    %esi,%edx
  800d1a:	72 06                	jb     800d22 <__udivdi3+0x102>
  800d1c:	31 c0                	xor    %eax,%eax
  800d1e:	39 eb                	cmp    %ebp,%ebx
  800d20:	77 d2                	ja     800cf4 <__udivdi3+0xd4>
  800d22:	b8 01 00 00 00       	mov    $0x1,%eax
  800d27:	eb cb                	jmp    800cf4 <__udivdi3+0xd4>
  800d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d30:	89 d8                	mov    %ebx,%eax
  800d32:	31 ff                	xor    %edi,%edi
  800d34:	eb be                	jmp    800cf4 <__udivdi3+0xd4>
  800d36:	66 90                	xchg   %ax,%ax
  800d38:	66 90                	xchg   %ax,%ax
  800d3a:	66 90                	xchg   %ax,%ax
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__umoddi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d57:	85 ed                	test   %ebp,%ebp
  800d59:	89 f0                	mov    %esi,%eax
  800d5b:	89 da                	mov    %ebx,%edx
  800d5d:	75 19                	jne    800d78 <__umoddi3+0x38>
  800d5f:	39 df                	cmp    %ebx,%edi
  800d61:	0f 86 b1 00 00 00    	jbe    800e18 <__umoddi3+0xd8>
  800d67:	f7 f7                	div    %edi
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	83 c4 1c             	add    $0x1c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
  800d75:	8d 76 00             	lea    0x0(%esi),%esi
  800d78:	39 dd                	cmp    %ebx,%ebp
  800d7a:	77 f1                	ja     800d6d <__umoddi3+0x2d>
  800d7c:	0f bd cd             	bsr    %ebp,%ecx
  800d7f:	83 f1 1f             	xor    $0x1f,%ecx
  800d82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d86:	0f 84 b4 00 00 00    	je     800e40 <__umoddi3+0x100>
  800d8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d97:	29 c2                	sub    %eax,%edx
  800d99:	89 c1                	mov    %eax,%ecx
  800d9b:	89 f8                	mov    %edi,%eax
  800d9d:	d3 e5                	shl    %cl,%ebp
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800da5:	d3 e8                	shr    %cl,%eax
  800da7:	09 c5                	or     %eax,%ebp
  800da9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dad:	89 c1                	mov    %eax,%ecx
  800daf:	d3 e7                	shl    %cl,%edi
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800db7:	89 df                	mov    %ebx,%edi
  800db9:	d3 ef                	shr    %cl,%edi
  800dbb:	89 c1                	mov    %eax,%ecx
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	d3 e3                	shl    %cl,%ebx
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 fa                	mov    %edi,%edx
  800dc5:	d3 e8                	shr    %cl,%eax
  800dc7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dcc:	09 d8                	or     %ebx,%eax
  800dce:	f7 f5                	div    %ebp
  800dd0:	d3 e6                	shl    %cl,%esi
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	f7 64 24 08          	mull   0x8(%esp)
  800dd8:	39 d1                	cmp    %edx,%ecx
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 d7                	mov    %edx,%edi
  800dde:	72 06                	jb     800de6 <__umoddi3+0xa6>
  800de0:	75 0e                	jne    800df0 <__umoddi3+0xb0>
  800de2:	39 c6                	cmp    %eax,%esi
  800de4:	73 0a                	jae    800df0 <__umoddi3+0xb0>
  800de6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dea:	19 ea                	sbb    %ebp,%edx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	89 c3                	mov    %eax,%ebx
  800df0:	89 ca                	mov    %ecx,%edx
  800df2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800df7:	29 de                	sub    %ebx,%esi
  800df9:	19 fa                	sbb    %edi,%edx
  800dfb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	d3 e0                	shl    %cl,%eax
  800e03:	89 d9                	mov    %ebx,%ecx
  800e05:	d3 ee                	shr    %cl,%esi
  800e07:	d3 ea                	shr    %cl,%edx
  800e09:	09 f0                	or     %esi,%eax
  800e0b:	83 c4 1c             	add    $0x1c,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
  800e13:	90                   	nop
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	85 ff                	test   %edi,%edi
  800e1a:	89 f9                	mov    %edi,%ecx
  800e1c:	75 0b                	jne    800e29 <__umoddi3+0xe9>
  800e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e23:	31 d2                	xor    %edx,%edx
  800e25:	f7 f7                	div    %edi
  800e27:	89 c1                	mov    %eax,%ecx
  800e29:	89 d8                	mov    %ebx,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 f0                	mov    %esi,%eax
  800e31:	f7 f1                	div    %ecx
  800e33:	e9 31 ff ff ff       	jmp    800d69 <__umoddi3+0x29>
  800e38:	90                   	nop
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 dd                	cmp    %ebx,%ebp
  800e42:	72 08                	jb     800e4c <__umoddi3+0x10c>
  800e44:	39 f7                	cmp    %esi,%edi
  800e46:	0f 87 21 ff ff ff    	ja     800d6d <__umoddi3+0x2d>
  800e4c:	89 da                	mov    %ebx,%edx
  800e4e:	89 f0                	mov    %esi,%eax
  800e50:	29 f8                	sub    %edi,%eax
  800e52:	19 ea                	sbb    %ebp,%edx
  800e54:	e9 14 ff ff ff       	jmp    800d6d <__umoddi3+0x2d>
