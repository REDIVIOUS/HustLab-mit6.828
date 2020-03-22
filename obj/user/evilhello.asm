
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 2c 00 00 00       	call   80005d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1a 00 00 00       	call   800059 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800045:	6a 64                	push   $0x64
  800047:	68 0c 00 10 f0       	push   $0xf010000c
  80004c:	e8 92 00 00 00       	call   8000e3 <sys_cputs>
}
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <__x86.get_pc_thunk.bx>:
  800059:	8b 1c 24             	mov    (%esp),%ebx
  80005c:	c3                   	ret    

0080005d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	e8 ee ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80006b:	81 c3 95 1f 00 00    	add    $0x1f95,%ebx
  800071:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800074:	c7 c6 2c 20 80 00    	mov    $0x80202c,%esi
  80007a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	thisenv = (struct Env*)(envs + ENVX(sys_getenvid())); //（为当前进程）初始化全局指针
  800080:	e8 f0 00 00 00       	call   800175 <sys_getenvid>
  800085:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008a:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80008d:	c1 e0 05             	shl    $0x5,%eax
  800090:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800096:	89 06                	mov    %eax,(%esi)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800098:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80009c:	7e 08                	jle    8000a6 <libmain+0x49>
		binaryname = argv[0];
  80009e:	8b 07                	mov    (%edi),%eax
  8000a0:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a6:	83 ec 08             	sub    $0x8,%esp
  8000a9:	57                   	push   %edi
  8000aa:	ff 75 08             	pushl  0x8(%ebp)
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0b 00 00 00       	call   8000c2 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	53                   	push   %ebx
  8000c6:	83 ec 10             	sub    $0x10,%esp
  8000c9:	e8 8b ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8000ce:	81 c3 32 1f 00 00    	add    $0x1f32,%ebx
	sys_env_destroy(0);
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 45 00 00 00       	call   800120 <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f4:	89 c3                	mov    %eax,%ebx
  8000f6:	89 c7                	mov    %eax,%edi
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <sys_cgetc>:

int
sys_cgetc(void)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
	asm volatile("int %1\n"
  800107:	ba 00 00 00 00       	mov    $0x0,%edx
  80010c:	b8 01 00 00 00       	mov    $0x1,%eax
  800111:	89 d1                	mov    %edx,%ecx
  800113:	89 d3                	mov    %edx,%ebx
  800115:	89 d7                	mov    %edx,%edi
  800117:	89 d6                	mov    %edx,%esi
  800119:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
  800126:	83 ec 1c             	sub    $0x1c,%esp
  800129:	e8 66 00 00 00       	call   800194 <__x86.get_pc_thunk.ax>
  80012e:	05 d2 1e 00 00       	add    $0x1ed2,%eax
  800133:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800136:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013b:	8b 55 08             	mov    0x8(%ebp),%edx
  80013e:	b8 03 00 00 00       	mov    $0x3,%eax
  800143:	89 cb                	mov    %ecx,%ebx
  800145:	89 cf                	mov    %ecx,%edi
  800147:	89 ce                	mov    %ecx,%esi
  800149:	cd 30                	int    $0x30
	if(check && ret > 0)
  80014b:	85 c0                	test   %eax,%eax
  80014d:	7f 08                	jg     800157 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5f                   	pop    %edi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	50                   	push   %eax
  80015b:	6a 03                	push   $0x3
  80015d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800160:	8d 83 86 ee ff ff    	lea    -0x117a(%ebx),%eax
  800166:	50                   	push   %eax
  800167:	6a 23                	push   $0x23
  800169:	8d 83 a3 ee ff ff    	lea    -0x115d(%ebx),%eax
  80016f:	50                   	push   %eax
  800170:	e8 23 00 00 00       	call   800198 <_panic>

00800175 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80017b:	ba 00 00 00 00       	mov    $0x0,%edx
  800180:	b8 02 00 00 00       	mov    $0x2,%eax
  800185:	89 d1                	mov    %edx,%ecx
  800187:	89 d3                	mov    %edx,%ebx
  800189:	89 d7                	mov    %edx,%edi
  80018b:	89 d6                	mov    %edx,%esi
  80018d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    

00800194 <__x86.get_pc_thunk.ax>:
  800194:	8b 04 24             	mov    (%esp),%eax
  800197:	c3                   	ret    

00800198 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	e8 b3 fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8001a6:	81 c3 5a 1e 00 00    	add    $0x1e5a,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001ac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001af:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8001b5:	8b 38                	mov    (%eax),%edi
  8001b7:	e8 b9 ff ff ff       	call   800175 <sys_getenvid>
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	ff 75 0c             	pushl  0xc(%ebp)
  8001c2:	ff 75 08             	pushl  0x8(%ebp)
  8001c5:	57                   	push   %edi
  8001c6:	50                   	push   %eax
  8001c7:	8d 83 b4 ee ff ff    	lea    -0x114c(%ebx),%eax
  8001cd:	50                   	push   %eax
  8001ce:	e8 d1 00 00 00       	call   8002a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d3:	83 c4 18             	add    $0x18,%esp
  8001d6:	56                   	push   %esi
  8001d7:	ff 75 10             	pushl  0x10(%ebp)
  8001da:	e8 63 00 00 00       	call   800242 <vcprintf>
	cprintf("\n");
  8001df:	8d 83 d8 ee ff ff    	lea    -0x1128(%ebx),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 b7 00 00 00       	call   8002a4 <cprintf>
  8001ed:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f0:	cc                   	int3   
  8001f1:	eb fd                	jmp    8001f0 <_panic+0x58>

008001f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	56                   	push   %esi
  8001f7:	53                   	push   %ebx
  8001f8:	e8 5c fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8001fd:	81 c3 03 1e 00 00    	add    $0x1e03,%ebx
  800203:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800206:	8b 16                	mov    (%esi),%edx
  800208:	8d 42 01             	lea    0x1(%edx),%eax
  80020b:	89 06                	mov    %eax,(%esi)
  80020d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800210:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800214:	3d ff 00 00 00       	cmp    $0xff,%eax
  800219:	74 0b                	je     800226 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80021b:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80021f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800222:	5b                   	pop    %ebx
  800223:	5e                   	pop    %esi
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800226:	83 ec 08             	sub    $0x8,%esp
  800229:	68 ff 00 00 00       	push   $0xff
  80022e:	8d 46 08             	lea    0x8(%esi),%eax
  800231:	50                   	push   %eax
  800232:	e8 ac fe ff ff       	call   8000e3 <sys_cputs>
		b->idx = 0;
  800237:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	eb d9                	jmp    80021b <putch+0x28>

00800242 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	53                   	push   %ebx
  800246:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80024c:	e8 08 fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800251:	81 c3 af 1d 00 00    	add    $0x1daf,%ebx
	struct printbuf b;

	b.idx = 0;
  800257:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025e:	00 00 00 
	b.cnt = 0;
  800261:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800268:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026b:	ff 75 0c             	pushl  0xc(%ebp)
  80026e:	ff 75 08             	pushl  0x8(%ebp)
  800271:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800277:	50                   	push   %eax
  800278:	8d 83 f3 e1 ff ff    	lea    -0x1e0d(%ebx),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 38 01 00 00       	call   8003bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800284:	83 c4 08             	add    $0x8,%esp
  800287:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80028d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800293:	50                   	push   %eax
  800294:	e8 4a fe ff ff       	call   8000e3 <sys_cputs>

	return b.cnt;
}
  800299:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ad:	50                   	push   %eax
  8002ae:	ff 75 08             	pushl  0x8(%ebp)
  8002b1:	e8 8c ff ff ff       	call   800242 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 2c             	sub    $0x2c,%esp
  8002c1:	e8 02 06 00 00       	call   8008c8 <__x86.get_pc_thunk.cx>
  8002c6:	81 c1 3a 1d 00 00    	add    $0x1d3a,%ecx
  8002cc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002cf:	89 c7                	mov    %eax,%edi
  8002d1:	89 d6                	mov    %edx,%esi
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002dc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002df:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e7:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002ea:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002ed:	39 d3                	cmp    %edx,%ebx
  8002ef:	72 09                	jb     8002fa <printnum+0x42>
  8002f1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f4:	0f 87 83 00 00 00    	ja     80037d <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	ff 75 18             	pushl  0x18(%ebp)
  800300:	8b 45 14             	mov    0x14(%ebp),%eax
  800303:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800306:	53                   	push   %ebx
  800307:	ff 75 10             	pushl  0x10(%ebp)
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	ff 75 d4             	pushl  -0x2c(%ebp)
  800316:	ff 75 d0             	pushl  -0x30(%ebp)
  800319:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80031c:	e8 1f 09 00 00       	call   800c40 <__udivdi3>
  800321:	83 c4 18             	add    $0x18,%esp
  800324:	52                   	push   %edx
  800325:	50                   	push   %eax
  800326:	89 f2                	mov    %esi,%edx
  800328:	89 f8                	mov    %edi,%eax
  80032a:	e8 89 ff ff ff       	call   8002b8 <printnum>
  80032f:	83 c4 20             	add    $0x20,%esp
  800332:	eb 13                	jmp    800347 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800334:	83 ec 08             	sub    $0x8,%esp
  800337:	56                   	push   %esi
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	ff d7                	call   *%edi
  80033d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800340:	83 eb 01             	sub    $0x1,%ebx
  800343:	85 db                	test   %ebx,%ebx
  800345:	7f ed                	jg     800334 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800347:	83 ec 08             	sub    $0x8,%esp
  80034a:	56                   	push   %esi
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	ff 75 d4             	pushl  -0x2c(%ebp)
  800357:	ff 75 d0             	pushl  -0x30(%ebp)
  80035a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80035d:	89 f3                	mov    %esi,%ebx
  80035f:	e8 fc 09 00 00       	call   800d60 <__umoddi3>
  800364:	83 c4 14             	add    $0x14,%esp
  800367:	0f be 84 06 da ee ff 	movsbl -0x1126(%esi,%eax,1),%eax
  80036e:	ff 
  80036f:	50                   	push   %eax
  800370:	ff d7                	call   *%edi
}
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800378:	5b                   	pop    %ebx
  800379:	5e                   	pop    %esi
  80037a:	5f                   	pop    %edi
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    
  80037d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800380:	eb be                	jmp    800340 <printnum+0x88>

00800382 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800388:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	3b 50 04             	cmp    0x4(%eax),%edx
  800391:	73 0a                	jae    80039d <sprintputch+0x1b>
		*b->buf++ = ch;
  800393:	8d 4a 01             	lea    0x1(%edx),%ecx
  800396:	89 08                	mov    %ecx,(%eax)
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	88 02                	mov    %al,(%edx)
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <printfmt>:
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a8:	50                   	push   %eax
  8003a9:	ff 75 10             	pushl  0x10(%ebp)
  8003ac:	ff 75 0c             	pushl  0xc(%ebp)
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 05 00 00 00       	call   8003bc <vprintfmt>
}
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    

008003bc <vprintfmt>:
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	57                   	push   %edi
  8003c0:	56                   	push   %esi
  8003c1:	53                   	push   %ebx
  8003c2:	83 ec 2c             	sub    $0x2c,%esp
  8003c5:	e8 8f fc ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8003ca:	81 c3 36 1c 00 00    	add    $0x1c36,%ebx
  8003d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d6:	e9 c3 03 00 00       	jmp    80079e <.L35+0x48>
		padc = ' ';
  8003db:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003df:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003e6:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003ed:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8d 47 01             	lea    0x1(%edi),%eax
  8003ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800402:	0f b6 17             	movzbl (%edi),%edx
  800405:	8d 42 dd             	lea    -0x23(%edx),%eax
  800408:	3c 55                	cmp    $0x55,%al
  80040a:	0f 87 16 04 00 00    	ja     800826 <.L22>
  800410:	0f b6 c0             	movzbl %al,%eax
  800413:	89 d9                	mov    %ebx,%ecx
  800415:	03 8c 83 68 ef ff ff 	add    -0x1098(%ebx,%eax,4),%ecx
  80041c:	ff e1                	jmp    *%ecx

0080041e <.L69>:
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800421:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800425:	eb d5                	jmp    8003fc <vprintfmt+0x40>

00800427 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80042a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042e:	eb cc                	jmp    8003fc <vprintfmt+0x40>

00800430 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	0f b6 d2             	movzbl %dl,%edx
  800433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80043b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800442:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800445:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800448:	83 f9 09             	cmp    $0x9,%ecx
  80044b:	77 55                	ja     8004a2 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80044d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800450:	eb e9                	jmp    80043b <.L29+0xb>

00800452 <.L26>:
			precision = va_arg(ap, int);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8b 00                	mov    (%eax),%eax
  800457:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 40 04             	lea    0x4(%eax),%eax
  800460:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800466:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046a:	79 90                	jns    8003fc <vprintfmt+0x40>
				width = precision, precision = -1;
  80046c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80046f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800472:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800479:	eb 81                	jmp    8003fc <vprintfmt+0x40>

0080047b <.L27>:
  80047b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047e:	85 c0                	test   %eax,%eax
  800480:	ba 00 00 00 00       	mov    $0x0,%edx
  800485:	0f 49 d0             	cmovns %eax,%edx
  800488:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048e:	e9 69 ff ff ff       	jmp    8003fc <vprintfmt+0x40>

00800493 <.L23>:
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800496:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049d:	e9 5a ff ff ff       	jmp    8003fc <vprintfmt+0x40>
  8004a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004a5:	eb bf                	jmp    800466 <.L26+0x14>

008004a7 <.L33>:
			lflag++;
  8004a7:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ae:	e9 49 ff ff ff       	jmp    8003fc <vprintfmt+0x40>

008004b3 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 78 04             	lea    0x4(%eax),%edi
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	56                   	push   %esi
  8004bd:	ff 30                	pushl  (%eax)
  8004bf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004c2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004c5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004c8:	e9 ce 02 00 00       	jmp    80079b <.L35+0x45>

008004cd <.L32>:
			err = va_arg(ap, int);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 78 04             	lea    0x4(%eax),%edi
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	99                   	cltd   
  8004d6:	31 d0                	xor    %edx,%eax
  8004d8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004da:	83 f8 06             	cmp    $0x6,%eax
  8004dd:	7f 27                	jg     800506 <.L32+0x39>
  8004df:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	74 1c                	je     800506 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004ea:	52                   	push   %edx
  8004eb:	8d 83 fb ee ff ff    	lea    -0x1105(%ebx),%eax
  8004f1:	50                   	push   %eax
  8004f2:	56                   	push   %esi
  8004f3:	ff 75 08             	pushl  0x8(%ebp)
  8004f6:	e8 a4 fe ff ff       	call   80039f <printfmt>
  8004fb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fe:	89 7d 14             	mov    %edi,0x14(%ebp)
  800501:	e9 95 02 00 00       	jmp    80079b <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800506:	50                   	push   %eax
  800507:	8d 83 f2 ee ff ff    	lea    -0x110e(%ebx),%eax
  80050d:	50                   	push   %eax
  80050e:	56                   	push   %esi
  80050f:	ff 75 08             	pushl  0x8(%ebp)
  800512:	e8 88 fe ff ff       	call   80039f <printfmt>
  800517:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051d:	e9 79 02 00 00       	jmp    80079b <.L35+0x45>

00800522 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	83 c0 04             	add    $0x4,%eax
  800528:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800530:	85 ff                	test   %edi,%edi
  800532:	8d 83 eb ee ff ff    	lea    -0x1115(%ebx),%eax
  800538:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80053b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053f:	0f 8e b5 00 00 00    	jle    8005fa <.L36+0xd8>
  800545:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800549:	75 08                	jne    800553 <.L36+0x31>
  80054b:	89 75 0c             	mov    %esi,0xc(%ebp)
  80054e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800551:	eb 6d                	jmp    8005c0 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	ff 75 cc             	pushl  -0x34(%ebp)
  800559:	57                   	push   %edi
  80055a:	e8 85 03 00 00       	call   8008e4 <strnlen>
  80055f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800562:	29 c2                	sub    %eax,%edx
  800564:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800567:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80056e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800571:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800574:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800576:	eb 10                	jmp    800588 <.L36+0x66>
					putch(padc, putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	56                   	push   %esi
  80057c:	ff 75 e0             	pushl  -0x20(%ebp)
  80057f:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800582:	83 ef 01             	sub    $0x1,%edi
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	85 ff                	test   %edi,%edi
  80058a:	7f ec                	jg     800578 <.L36+0x56>
  80058c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80058f:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	b8 00 00 00 00       	mov    $0x0,%eax
  800599:	0f 49 c2             	cmovns %edx,%eax
  80059c:	29 c2                	sub    %eax,%edx
  80059e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005a1:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005a4:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005a7:	eb 17                	jmp    8005c0 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ad:	75 30                	jne    8005df <.L36+0xbd>
					putch(ch, putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	ff 75 0c             	pushl  0xc(%ebp)
  8005b5:	50                   	push   %eax
  8005b6:	ff 55 08             	call   *0x8(%ebp)
  8005b9:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bc:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005c0:	83 c7 01             	add    $0x1,%edi
  8005c3:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005c7:	0f be c2             	movsbl %dl,%eax
  8005ca:	85 c0                	test   %eax,%eax
  8005cc:	74 52                	je     800620 <.L36+0xfe>
  8005ce:	85 f6                	test   %esi,%esi
  8005d0:	78 d7                	js     8005a9 <.L36+0x87>
  8005d2:	83 ee 01             	sub    $0x1,%esi
  8005d5:	79 d2                	jns    8005a9 <.L36+0x87>
  8005d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005da:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005dd:	eb 32                	jmp    800611 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005df:	0f be d2             	movsbl %dl,%edx
  8005e2:	83 ea 20             	sub    $0x20,%edx
  8005e5:	83 fa 5e             	cmp    $0x5e,%edx
  8005e8:	76 c5                	jbe    8005af <.L36+0x8d>
					putch('?', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	ff 75 0c             	pushl  0xc(%ebp)
  8005f0:	6a 3f                	push   $0x3f
  8005f2:	ff 55 08             	call   *0x8(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
  8005f8:	eb c2                	jmp    8005bc <.L36+0x9a>
  8005fa:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005fd:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800600:	eb be                	jmp    8005c0 <.L36+0x9e>
				putch(' ', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	56                   	push   %esi
  800606:	6a 20                	push   $0x20
  800608:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80060b:	83 ef 01             	sub    $0x1,%edi
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	85 ff                	test   %edi,%edi
  800613:	7f ed                	jg     800602 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800615:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
  80061b:	e9 7b 01 00 00       	jmp    80079b <.L35+0x45>
  800620:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800623:	8b 75 0c             	mov    0xc(%ebp),%esi
  800626:	eb e9                	jmp    800611 <.L36+0xef>

00800628 <.L31>:
  800628:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80062b:	83 f9 01             	cmp    $0x1,%ecx
  80062e:	7e 40                	jle    800670 <.L31+0x48>
		return va_arg(*ap, long long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 50 04             	mov    0x4(%eax),%edx
  800636:	8b 00                	mov    (%eax),%eax
  800638:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 40 08             	lea    0x8(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800647:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064b:	79 55                	jns    8006a2 <.L31+0x7a>
				putch('-', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	56                   	push   %esi
  800651:	6a 2d                	push   $0x2d
  800653:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800656:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800659:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80065c:	f7 da                	neg    %edx
  80065e:	83 d1 00             	adc    $0x0,%ecx
  800661:	f7 d9                	neg    %ecx
  800663:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	e9 10 01 00 00       	jmp    800780 <.L35+0x2a>
	else if (lflag)
  800670:	85 c9                	test   %ecx,%ecx
  800672:	75 17                	jne    80068b <.L31+0x63>
		return va_arg(*ap, int);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 00                	mov    (%eax),%eax
  800679:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067c:	99                   	cltd   
  80067d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
  800689:	eb bc                	jmp    800647 <.L31+0x1f>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800693:	99                   	cltd   
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 40 04             	lea    0x4(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a0:	eb a5                	jmp    800647 <.L31+0x1f>
			num = getint(&ap, lflag);
  8006a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ad:	e9 ce 00 00 00       	jmp    800780 <.L35+0x2a>

008006b2 <.L37>:
  8006b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006b5:	83 f9 01             	cmp    $0x1,%ecx
  8006b8:	7e 18                	jle    8006d2 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c2:	8d 40 08             	lea    0x8(%eax),%eax
  8006c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cd:	e9 ae 00 00 00       	jmp    800780 <.L35+0x2a>
	else if (lflag)
  8006d2:	85 c9                	test   %ecx,%ecx
  8006d4:	75 1a                	jne    8006f0 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006eb:	e9 90 00 00 00       	jmp    800780 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 10                	mov    (%eax),%edx
  8006f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fa:	8d 40 04             	lea    0x4(%eax),%eax
  8006fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800700:	b8 0a 00 00 00       	mov    $0xa,%eax
  800705:	eb 79                	jmp    800780 <.L35+0x2a>

00800707 <.L34>:
  800707:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80070a:	83 f9 01             	cmp    $0x1,%ecx
  80070d:	7e 15                	jle    800724 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8b 10                	mov    (%eax),%edx
  800714:	8b 48 04             	mov    0x4(%eax),%ecx
  800717:	8d 40 08             	lea    0x8(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80071d:	b8 08 00 00 00       	mov    $0x8,%eax
  800722:	eb 5c                	jmp    800780 <.L35+0x2a>
	else if (lflag)
  800724:	85 c9                	test   %ecx,%ecx
  800726:	75 17                	jne    80073f <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800738:	b8 08 00 00 00       	mov    $0x8,%eax
  80073d:	eb 41                	jmp    800780 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8b 10                	mov    (%eax),%edx
  800744:	b9 00 00 00 00       	mov    $0x0,%ecx
  800749:	8d 40 04             	lea    0x4(%eax),%eax
  80074c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80074f:	b8 08 00 00 00       	mov    $0x8,%eax
  800754:	eb 2a                	jmp    800780 <.L35+0x2a>

00800756 <.L35>:
			putch('0', putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	56                   	push   %esi
  80075a:	6a 30                	push   $0x30
  80075c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80075f:	83 c4 08             	add    $0x8,%esp
  800762:	56                   	push   %esi
  800763:	6a 78                	push   $0x78
  800765:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 10                	mov    (%eax),%edx
  80076d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800772:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800775:	8d 40 04             	lea    0x4(%eax),%eax
  800778:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800780:	83 ec 0c             	sub    $0xc,%esp
  800783:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800787:	57                   	push   %edi
  800788:	ff 75 e0             	pushl  -0x20(%ebp)
  80078b:	50                   	push   %eax
  80078c:	51                   	push   %ecx
  80078d:	52                   	push   %edx
  80078e:	89 f2                	mov    %esi,%edx
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	e8 20 fb ff ff       	call   8002b8 <printnum>
			break;
  800798:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80079b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80079e:	83 c7 01             	add    $0x1,%edi
  8007a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007a5:	83 f8 25             	cmp    $0x25,%eax
  8007a8:	0f 84 2d fc ff ff    	je     8003db <vprintfmt+0x1f>
			if (ch == '\0')
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	0f 84 91 00 00 00    	je     800847 <.L22+0x21>
			putch(ch, putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	56                   	push   %esi
  8007ba:	50                   	push   %eax
  8007bb:	ff 55 08             	call   *0x8(%ebp)
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb db                	jmp    80079e <.L35+0x48>

008007c3 <.L38>:
  8007c3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007c6:	83 f9 01             	cmp    $0x1,%ecx
  8007c9:	7e 15                	jle    8007e0 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8b 10                	mov    (%eax),%edx
  8007d0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d3:	8d 40 08             	lea    0x8(%eax),%eax
  8007d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d9:	b8 10 00 00 00       	mov    $0x10,%eax
  8007de:	eb a0                	jmp    800780 <.L35+0x2a>
	else if (lflag)
  8007e0:	85 c9                	test   %ecx,%ecx
  8007e2:	75 17                	jne    8007fb <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8b 10                	mov    (%eax),%edx
  8007e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ee:	8d 40 04             	lea    0x4(%eax),%eax
  8007f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f4:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f9:	eb 85                	jmp    800780 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8b 10                	mov    (%eax),%edx
  800800:	b9 00 00 00 00       	mov    $0x0,%ecx
  800805:	8d 40 04             	lea    0x4(%eax),%eax
  800808:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080b:	b8 10 00 00 00       	mov    $0x10,%eax
  800810:	e9 6b ff ff ff       	jmp    800780 <.L35+0x2a>

00800815 <.L25>:
			putch(ch, putdat);
  800815:	83 ec 08             	sub    $0x8,%esp
  800818:	56                   	push   %esi
  800819:	6a 25                	push   $0x25
  80081b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	e9 75 ff ff ff       	jmp    80079b <.L35+0x45>

00800826 <.L22>:
			putch('%', putdat);
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	56                   	push   %esi
  80082a:	6a 25                	push   $0x25
  80082c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082f:	83 c4 10             	add    $0x10,%esp
  800832:	89 f8                	mov    %edi,%eax
  800834:	eb 03                	jmp    800839 <.L22+0x13>
  800836:	83 e8 01             	sub    $0x1,%eax
  800839:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80083d:	75 f7                	jne    800836 <.L22+0x10>
  80083f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800842:	e9 54 ff ff ff       	jmp    80079b <.L35+0x45>
}
  800847:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5f                   	pop    %edi
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	e8 fe f7 ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80085b:	81 c3 a5 17 00 00    	add    $0x17a5,%ebx
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800867:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80086e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800871:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800878:	85 c0                	test   %eax,%eax
  80087a:	74 2b                	je     8008a7 <vsnprintf+0x58>
  80087c:	85 d2                	test   %edx,%edx
  80087e:	7e 27                	jle    8008a7 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800880:	ff 75 14             	pushl  0x14(%ebp)
  800883:	ff 75 10             	pushl  0x10(%ebp)
  800886:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800889:	50                   	push   %eax
  80088a:	8d 83 82 e3 ff ff    	lea    -0x1c7e(%ebx),%eax
  800890:	50                   	push   %eax
  800891:	e8 26 fb ff ff       	call   8003bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800896:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800899:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089f:	83 c4 10             	add    $0x10,%esp
}
  8008a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    
		return -E_INVAL;
  8008a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ac:	eb f4                	jmp    8008a2 <vsnprintf+0x53>

008008ae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b7:	50                   	push   %eax
  8008b8:	ff 75 10             	pushl  0x10(%ebp)
  8008bb:	ff 75 0c             	pushl  0xc(%ebp)
  8008be:	ff 75 08             	pushl  0x8(%ebp)
  8008c1:	e8 89 ff ff ff       	call   80084f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <__x86.get_pc_thunk.cx>:
  8008c8:	8b 0c 24             	mov    (%esp),%ecx
  8008cb:	c3                   	ret    

008008cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d7:	eb 03                	jmp    8008dc <strlen+0x10>
		n++;
  8008d9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008dc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e0:	75 f7                	jne    8008d9 <strlen+0xd>
	return n;
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f2:	eb 03                	jmp    8008f7 <strnlen+0x13>
		n++;
  8008f4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f7:	39 d0                	cmp    %edx,%eax
  8008f9:	74 06                	je     800901 <strnlen+0x1d>
  8008fb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ff:	75 f3                	jne    8008f4 <strnlen+0x10>
	return n;
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80090d:	89 c2                	mov    %eax,%edx
  80090f:	83 c1 01             	add    $0x1,%ecx
  800912:	83 c2 01             	add    $0x1,%edx
  800915:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800919:	88 5a ff             	mov    %bl,-0x1(%edx)
  80091c:	84 db                	test   %bl,%bl
  80091e:	75 ef                	jne    80090f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800920:	5b                   	pop    %ebx
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80092a:	53                   	push   %ebx
  80092b:	e8 9c ff ff ff       	call   8008cc <strlen>
  800930:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800933:	ff 75 0c             	pushl  0xc(%ebp)
  800936:	01 d8                	add    %ebx,%eax
  800938:	50                   	push   %eax
  800939:	e8 c5 ff ff ff       	call   800903 <strcpy>
	return dst;
}
  80093e:	89 d8                	mov    %ebx,%eax
  800940:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 75 08             	mov    0x8(%ebp),%esi
  80094d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800950:	89 f3                	mov    %esi,%ebx
  800952:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800955:	89 f2                	mov    %esi,%edx
  800957:	eb 0f                	jmp    800968 <strncpy+0x23>
		*dst++ = *src;
  800959:	83 c2 01             	add    $0x1,%edx
  80095c:	0f b6 01             	movzbl (%ecx),%eax
  80095f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800962:	80 39 01             	cmpb   $0x1,(%ecx)
  800965:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800968:	39 da                	cmp    %ebx,%edx
  80096a:	75 ed                	jne    800959 <strncpy+0x14>
	}
	return ret;
}
  80096c:	89 f0                	mov    %esi,%eax
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	56                   	push   %esi
  800976:	53                   	push   %ebx
  800977:	8b 75 08             	mov    0x8(%ebp),%esi
  80097a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800980:	89 f0                	mov    %esi,%eax
  800982:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800986:	85 c9                	test   %ecx,%ecx
  800988:	75 0b                	jne    800995 <strlcpy+0x23>
  80098a:	eb 17                	jmp    8009a3 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80098c:	83 c2 01             	add    $0x1,%edx
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800995:	39 d8                	cmp    %ebx,%eax
  800997:	74 07                	je     8009a0 <strlcpy+0x2e>
  800999:	0f b6 0a             	movzbl (%edx),%ecx
  80099c:	84 c9                	test   %cl,%cl
  80099e:	75 ec                	jne    80098c <strlcpy+0x1a>
		*dst = '\0';
  8009a0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a3:	29 f0                	sub    %esi,%eax
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b2:	eb 06                	jmp    8009ba <strcmp+0x11>
		p++, q++;
  8009b4:	83 c1 01             	add    $0x1,%ecx
  8009b7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009ba:	0f b6 01             	movzbl (%ecx),%eax
  8009bd:	84 c0                	test   %al,%al
  8009bf:	74 04                	je     8009c5 <strcmp+0x1c>
  8009c1:	3a 02                	cmp    (%edx),%al
  8009c3:	74 ef                	je     8009b4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c5:	0f b6 c0             	movzbl %al,%eax
  8009c8:	0f b6 12             	movzbl (%edx),%edx
  8009cb:	29 d0                	sub    %edx,%eax
}
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	53                   	push   %ebx
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d9:	89 c3                	mov    %eax,%ebx
  8009db:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009de:	eb 06                	jmp    8009e6 <strncmp+0x17>
		n--, p++, q++;
  8009e0:	83 c0 01             	add    $0x1,%eax
  8009e3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009e6:	39 d8                	cmp    %ebx,%eax
  8009e8:	74 16                	je     800a00 <strncmp+0x31>
  8009ea:	0f b6 08             	movzbl (%eax),%ecx
  8009ed:	84 c9                	test   %cl,%cl
  8009ef:	74 04                	je     8009f5 <strncmp+0x26>
  8009f1:	3a 0a                	cmp    (%edx),%cl
  8009f3:	74 eb                	je     8009e0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f5:	0f b6 00             	movzbl (%eax),%eax
  8009f8:	0f b6 12             	movzbl (%edx),%edx
  8009fb:	29 d0                	sub    %edx,%eax
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    
		return 0;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
  800a05:	eb f6                	jmp    8009fd <strncmp+0x2e>

00800a07 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a11:	0f b6 10             	movzbl (%eax),%edx
  800a14:	84 d2                	test   %dl,%dl
  800a16:	74 09                	je     800a21 <strchr+0x1a>
		if (*s == c)
  800a18:	38 ca                	cmp    %cl,%dl
  800a1a:	74 0a                	je     800a26 <strchr+0x1f>
	for (; *s; s++)
  800a1c:	83 c0 01             	add    $0x1,%eax
  800a1f:	eb f0                	jmp    800a11 <strchr+0xa>
			return (char *) s;
	return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a32:	eb 03                	jmp    800a37 <strfind+0xf>
  800a34:	83 c0 01             	add    $0x1,%eax
  800a37:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a3a:	38 ca                	cmp    %cl,%dl
  800a3c:	74 04                	je     800a42 <strfind+0x1a>
  800a3e:	84 d2                	test   %dl,%dl
  800a40:	75 f2                	jne    800a34 <strfind+0xc>
			break;
	return (char *) s;
}
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a50:	85 c9                	test   %ecx,%ecx
  800a52:	74 13                	je     800a67 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5a:	75 05                	jne    800a61 <memset+0x1d>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	74 0d                	je     800a6e <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a64:	fc                   	cld    
  800a65:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a67:	89 f8                	mov    %edi,%eax
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5f                   	pop    %edi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    
		c &= 0xFF;
  800a6e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a72:	89 d3                	mov    %edx,%ebx
  800a74:	c1 e3 08             	shl    $0x8,%ebx
  800a77:	89 d0                	mov    %edx,%eax
  800a79:	c1 e0 18             	shl    $0x18,%eax
  800a7c:	89 d6                	mov    %edx,%esi
  800a7e:	c1 e6 10             	shl    $0x10,%esi
  800a81:	09 f0                	or     %esi,%eax
  800a83:	09 c2                	or     %eax,%edx
  800a85:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a87:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a8a:	89 d0                	mov    %edx,%eax
  800a8c:	fc                   	cld    
  800a8d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a8f:	eb d6                	jmp    800a67 <memset+0x23>

00800a91 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	57                   	push   %edi
  800a95:	56                   	push   %esi
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a9f:	39 c6                	cmp    %eax,%esi
  800aa1:	73 35                	jae    800ad8 <memmove+0x47>
  800aa3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa6:	39 c2                	cmp    %eax,%edx
  800aa8:	76 2e                	jbe    800ad8 <memmove+0x47>
		s += n;
		d += n;
  800aaa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aad:	89 d6                	mov    %edx,%esi
  800aaf:	09 fe                	or     %edi,%esi
  800ab1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab7:	74 0c                	je     800ac5 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab9:	83 ef 01             	sub    $0x1,%edi
  800abc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800abf:	fd                   	std    
  800ac0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac2:	fc                   	cld    
  800ac3:	eb 21                	jmp    800ae6 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac5:	f6 c1 03             	test   $0x3,%cl
  800ac8:	75 ef                	jne    800ab9 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aca:	83 ef 04             	sub    $0x4,%edi
  800acd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ad3:	fd                   	std    
  800ad4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad6:	eb ea                	jmp    800ac2 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad8:	89 f2                	mov    %esi,%edx
  800ada:	09 c2                	or     %eax,%edx
  800adc:	f6 c2 03             	test   $0x3,%dl
  800adf:	74 09                	je     800aea <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae1:	89 c7                	mov    %eax,%edi
  800ae3:	fc                   	cld    
  800ae4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aea:	f6 c1 03             	test   $0x3,%cl
  800aed:	75 f2                	jne    800ae1 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aef:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800af2:	89 c7                	mov    %eax,%edi
  800af4:	fc                   	cld    
  800af5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af7:	eb ed                	jmp    800ae6 <memmove+0x55>

00800af9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800afc:	ff 75 10             	pushl  0x10(%ebp)
  800aff:	ff 75 0c             	pushl  0xc(%ebp)
  800b02:	ff 75 08             	pushl  0x8(%ebp)
  800b05:	e8 87 ff ff ff       	call   800a91 <memmove>
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b17:	89 c6                	mov    %eax,%esi
  800b19:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1c:	39 f0                	cmp    %esi,%eax
  800b1e:	74 1c                	je     800b3c <memcmp+0x30>
		if (*s1 != *s2)
  800b20:	0f b6 08             	movzbl (%eax),%ecx
  800b23:	0f b6 1a             	movzbl (%edx),%ebx
  800b26:	38 d9                	cmp    %bl,%cl
  800b28:	75 08                	jne    800b32 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b2a:	83 c0 01             	add    $0x1,%eax
  800b2d:	83 c2 01             	add    $0x1,%edx
  800b30:	eb ea                	jmp    800b1c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b32:	0f b6 c1             	movzbl %cl,%eax
  800b35:	0f b6 db             	movzbl %bl,%ebx
  800b38:	29 d8                	sub    %ebx,%eax
  800b3a:	eb 05                	jmp    800b41 <memcmp+0x35>
	}

	return 0;
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b53:	39 d0                	cmp    %edx,%eax
  800b55:	73 09                	jae    800b60 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b57:	38 08                	cmp    %cl,(%eax)
  800b59:	74 05                	je     800b60 <memfind+0x1b>
	for (; s < ends; s++)
  800b5b:	83 c0 01             	add    $0x1,%eax
  800b5e:	eb f3                	jmp    800b53 <memfind+0xe>
			break;
	return (void *) s;
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6e:	eb 03                	jmp    800b73 <strtol+0x11>
		s++;
  800b70:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b73:	0f b6 01             	movzbl (%ecx),%eax
  800b76:	3c 20                	cmp    $0x20,%al
  800b78:	74 f6                	je     800b70 <strtol+0xe>
  800b7a:	3c 09                	cmp    $0x9,%al
  800b7c:	74 f2                	je     800b70 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b7e:	3c 2b                	cmp    $0x2b,%al
  800b80:	74 2e                	je     800bb0 <strtol+0x4e>
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b87:	3c 2d                	cmp    $0x2d,%al
  800b89:	74 2f                	je     800bba <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b91:	75 05                	jne    800b98 <strtol+0x36>
  800b93:	80 39 30             	cmpb   $0x30,(%ecx)
  800b96:	74 2c                	je     800bc4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b98:	85 db                	test   %ebx,%ebx
  800b9a:	75 0a                	jne    800ba6 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b9c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ba1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba4:	74 28                	je     800bce <strtol+0x6c>
		base = 10;
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bae:	eb 50                	jmp    800c00 <strtol+0x9e>
		s++;
  800bb0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bb3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb8:	eb d1                	jmp    800b8b <strtol+0x29>
		s++, neg = 1;
  800bba:	83 c1 01             	add    $0x1,%ecx
  800bbd:	bf 01 00 00 00       	mov    $0x1,%edi
  800bc2:	eb c7                	jmp    800b8b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bc8:	74 0e                	je     800bd8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bca:	85 db                	test   %ebx,%ebx
  800bcc:	75 d8                	jne    800ba6 <strtol+0x44>
		s++, base = 8;
  800bce:	83 c1 01             	add    $0x1,%ecx
  800bd1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bd6:	eb ce                	jmp    800ba6 <strtol+0x44>
		s += 2, base = 16;
  800bd8:	83 c1 02             	add    $0x2,%ecx
  800bdb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be0:	eb c4                	jmp    800ba6 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800be2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be5:	89 f3                	mov    %esi,%ebx
  800be7:	80 fb 19             	cmp    $0x19,%bl
  800bea:	77 29                	ja     800c15 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bec:	0f be d2             	movsbl %dl,%edx
  800bef:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bf5:	7d 30                	jge    800c27 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bfe:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c00:	0f b6 11             	movzbl (%ecx),%edx
  800c03:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c06:	89 f3                	mov    %esi,%ebx
  800c08:	80 fb 09             	cmp    $0x9,%bl
  800c0b:	77 d5                	ja     800be2 <strtol+0x80>
			dig = *s - '0';
  800c0d:	0f be d2             	movsbl %dl,%edx
  800c10:	83 ea 30             	sub    $0x30,%edx
  800c13:	eb dd                	jmp    800bf2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c15:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c18:	89 f3                	mov    %esi,%ebx
  800c1a:	80 fb 19             	cmp    $0x19,%bl
  800c1d:	77 08                	ja     800c27 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c1f:	0f be d2             	movsbl %dl,%edx
  800c22:	83 ea 37             	sub    $0x37,%edx
  800c25:	eb cb                	jmp    800bf2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c27:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2b:	74 05                	je     800c32 <strtol+0xd0>
		*endptr = (char *) s;
  800c2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c30:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c32:	89 c2                	mov    %eax,%edx
  800c34:	f7 da                	neg    %edx
  800c36:	85 ff                	test   %edi,%edi
  800c38:	0f 45 c2             	cmovne %edx,%eax
}
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <__udivdi3>:
  800c40:	55                   	push   %ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 1c             	sub    $0x1c,%esp
  800c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c57:	85 d2                	test   %edx,%edx
  800c59:	75 35                	jne    800c90 <__udivdi3+0x50>
  800c5b:	39 f3                	cmp    %esi,%ebx
  800c5d:	0f 87 bd 00 00 00    	ja     800d20 <__udivdi3+0xe0>
  800c63:	85 db                	test   %ebx,%ebx
  800c65:	89 d9                	mov    %ebx,%ecx
  800c67:	75 0b                	jne    800c74 <__udivdi3+0x34>
  800c69:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6e:	31 d2                	xor    %edx,%edx
  800c70:	f7 f3                	div    %ebx
  800c72:	89 c1                	mov    %eax,%ecx
  800c74:	31 d2                	xor    %edx,%edx
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	f7 f1                	div    %ecx
  800c7a:	89 c6                	mov    %eax,%esi
  800c7c:	89 e8                	mov    %ebp,%eax
  800c7e:	89 f7                	mov    %esi,%edi
  800c80:	f7 f1                	div    %ecx
  800c82:	89 fa                	mov    %edi,%edx
  800c84:	83 c4 1c             	add    $0x1c,%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
  800c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c90:	39 f2                	cmp    %esi,%edx
  800c92:	77 7c                	ja     800d10 <__udivdi3+0xd0>
  800c94:	0f bd fa             	bsr    %edx,%edi
  800c97:	83 f7 1f             	xor    $0x1f,%edi
  800c9a:	0f 84 98 00 00 00    	je     800d38 <__udivdi3+0xf8>
  800ca0:	89 f9                	mov    %edi,%ecx
  800ca2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ca7:	29 f8                	sub    %edi,%eax
  800ca9:	d3 e2                	shl    %cl,%edx
  800cab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800caf:	89 c1                	mov    %eax,%ecx
  800cb1:	89 da                	mov    %ebx,%edx
  800cb3:	d3 ea                	shr    %cl,%edx
  800cb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cb9:	09 d1                	or     %edx,%ecx
  800cbb:	89 f2                	mov    %esi,%edx
  800cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc1:	89 f9                	mov    %edi,%ecx
  800cc3:	d3 e3                	shl    %cl,%ebx
  800cc5:	89 c1                	mov    %eax,%ecx
  800cc7:	d3 ea                	shr    %cl,%edx
  800cc9:	89 f9                	mov    %edi,%ecx
  800ccb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ccf:	d3 e6                	shl    %cl,%esi
  800cd1:	89 eb                	mov    %ebp,%ebx
  800cd3:	89 c1                	mov    %eax,%ecx
  800cd5:	d3 eb                	shr    %cl,%ebx
  800cd7:	09 de                	or     %ebx,%esi
  800cd9:	89 f0                	mov    %esi,%eax
  800cdb:	f7 74 24 08          	divl   0x8(%esp)
  800cdf:	89 d6                	mov    %edx,%esi
  800ce1:	89 c3                	mov    %eax,%ebx
  800ce3:	f7 64 24 0c          	mull   0xc(%esp)
  800ce7:	39 d6                	cmp    %edx,%esi
  800ce9:	72 0c                	jb     800cf7 <__udivdi3+0xb7>
  800ceb:	89 f9                	mov    %edi,%ecx
  800ced:	d3 e5                	shl    %cl,%ebp
  800cef:	39 c5                	cmp    %eax,%ebp
  800cf1:	73 5d                	jae    800d50 <__udivdi3+0x110>
  800cf3:	39 d6                	cmp    %edx,%esi
  800cf5:	75 59                	jne    800d50 <__udivdi3+0x110>
  800cf7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cfa:	31 ff                	xor    %edi,%edi
  800cfc:	89 fa                	mov    %edi,%edx
  800cfe:	83 c4 1c             	add    $0x1c,%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
  800d06:	8d 76 00             	lea    0x0(%esi),%esi
  800d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d10:	31 ff                	xor    %edi,%edi
  800d12:	31 c0                	xor    %eax,%eax
  800d14:	89 fa                	mov    %edi,%edx
  800d16:	83 c4 1c             	add    $0x1c,%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
  800d1e:	66 90                	xchg   %ax,%ax
  800d20:	31 ff                	xor    %edi,%edi
  800d22:	89 e8                	mov    %ebp,%eax
  800d24:	89 f2                	mov    %esi,%edx
  800d26:	f7 f3                	div    %ebx
  800d28:	89 fa                	mov    %edi,%edx
  800d2a:	83 c4 1c             	add    $0x1c,%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
  800d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d38:	39 f2                	cmp    %esi,%edx
  800d3a:	72 06                	jb     800d42 <__udivdi3+0x102>
  800d3c:	31 c0                	xor    %eax,%eax
  800d3e:	39 eb                	cmp    %ebp,%ebx
  800d40:	77 d2                	ja     800d14 <__udivdi3+0xd4>
  800d42:	b8 01 00 00 00       	mov    $0x1,%eax
  800d47:	eb cb                	jmp    800d14 <__udivdi3+0xd4>
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	89 d8                	mov    %ebx,%eax
  800d52:	31 ff                	xor    %edi,%edi
  800d54:	eb be                	jmp    800d14 <__udivdi3+0xd4>
  800d56:	66 90                	xchg   %ax,%ax
  800d58:	66 90                	xchg   %ax,%ax
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__umoddi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d77:	85 ed                	test   %ebp,%ebp
  800d79:	89 f0                	mov    %esi,%eax
  800d7b:	89 da                	mov    %ebx,%edx
  800d7d:	75 19                	jne    800d98 <__umoddi3+0x38>
  800d7f:	39 df                	cmp    %ebx,%edi
  800d81:	0f 86 b1 00 00 00    	jbe    800e38 <__umoddi3+0xd8>
  800d87:	f7 f7                	div    %edi
  800d89:	89 d0                	mov    %edx,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	83 c4 1c             	add    $0x1c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	39 dd                	cmp    %ebx,%ebp
  800d9a:	77 f1                	ja     800d8d <__umoddi3+0x2d>
  800d9c:	0f bd cd             	bsr    %ebp,%ecx
  800d9f:	83 f1 1f             	xor    $0x1f,%ecx
  800da2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800da6:	0f 84 b4 00 00 00    	je     800e60 <__umoddi3+0x100>
  800dac:	b8 20 00 00 00       	mov    $0x20,%eax
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800db7:	29 c2                	sub    %eax,%edx
  800db9:	89 c1                	mov    %eax,%ecx
  800dbb:	89 f8                	mov    %edi,%eax
  800dbd:	d3 e5                	shl    %cl,%ebp
  800dbf:	89 d1                	mov    %edx,%ecx
  800dc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dc5:	d3 e8                	shr    %cl,%eax
  800dc7:	09 c5                	or     %eax,%ebp
  800dc9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dcd:	89 c1                	mov    %eax,%ecx
  800dcf:	d3 e7                	shl    %cl,%edi
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	d3 ef                	shr    %cl,%edi
  800ddb:	89 c1                	mov    %eax,%ecx
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	d3 e3                	shl    %cl,%ebx
  800de1:	89 d1                	mov    %edx,%ecx
  800de3:	89 fa                	mov    %edi,%edx
  800de5:	d3 e8                	shr    %cl,%eax
  800de7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dec:	09 d8                	or     %ebx,%eax
  800dee:	f7 f5                	div    %ebp
  800df0:	d3 e6                	shl    %cl,%esi
  800df2:	89 d1                	mov    %edx,%ecx
  800df4:	f7 64 24 08          	mull   0x8(%esp)
  800df8:	39 d1                	cmp    %edx,%ecx
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	72 06                	jb     800e06 <__umoddi3+0xa6>
  800e00:	75 0e                	jne    800e10 <__umoddi3+0xb0>
  800e02:	39 c6                	cmp    %eax,%esi
  800e04:	73 0a                	jae    800e10 <__umoddi3+0xb0>
  800e06:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e0a:	19 ea                	sbb    %ebp,%edx
  800e0c:	89 d7                	mov    %edx,%edi
  800e0e:	89 c3                	mov    %eax,%ebx
  800e10:	89 ca                	mov    %ecx,%edx
  800e12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e17:	29 de                	sub    %ebx,%esi
  800e19:	19 fa                	sbb    %edi,%edx
  800e1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e1f:	89 d0                	mov    %edx,%eax
  800e21:	d3 e0                	shl    %cl,%eax
  800e23:	89 d9                	mov    %ebx,%ecx
  800e25:	d3 ee                	shr    %cl,%esi
  800e27:	d3 ea                	shr    %cl,%edx
  800e29:	09 f0                	or     %esi,%eax
  800e2b:	83 c4 1c             	add    $0x1c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    
  800e33:	90                   	nop
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	85 ff                	test   %edi,%edi
  800e3a:	89 f9                	mov    %edi,%ecx
  800e3c:	75 0b                	jne    800e49 <__umoddi3+0xe9>
  800e3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e43:	31 d2                	xor    %edx,%edx
  800e45:	f7 f7                	div    %edi
  800e47:	89 c1                	mov    %eax,%ecx
  800e49:	89 d8                	mov    %ebx,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f1                	div    %ecx
  800e4f:	89 f0                	mov    %esi,%eax
  800e51:	f7 f1                	div    %ecx
  800e53:	e9 31 ff ff ff       	jmp    800d89 <__umoddi3+0x29>
  800e58:	90                   	nop
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	39 dd                	cmp    %ebx,%ebp
  800e62:	72 08                	jb     800e6c <__umoddi3+0x10c>
  800e64:	39 f7                	cmp    %esi,%edi
  800e66:	0f 87 21 ff ff ff    	ja     800d8d <__umoddi3+0x2d>
  800e6c:	89 da                	mov    %ebx,%edx
  800e6e:	89 f0                	mov    %esi,%eax
  800e70:	29 f8                	sub    %edi,%eax
  800e72:	19 ea                	sbb    %ebp,%edx
  800e74:	e9 14 ff ff ff       	jmp    800d8d <__umoddi3+0x2d>
