
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 35 00 00 00       	call   800074 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("hello, world\n");
  800045:	8d 83 9c ee ff ff    	lea    -0x1164(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 5e 01 00 00       	call   8001af <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800051:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  800057:	8b 00                	mov    (%eax),%eax
  800059:	8b 40 48             	mov    0x48(%eax),%eax
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	8d 83 aa ee ff ff    	lea    -0x1156(%ebx),%eax
  800066:	50                   	push   %eax
  800067:	e8 43 01 00 00       	call   8001af <cprintf>
}
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <__x86.get_pc_thunk.bx>:
  800074:	8b 1c 24             	mov    (%esp),%ebx
  800077:	c3                   	ret    

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	57                   	push   %edi
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	83 ec 0c             	sub    $0xc,%esp
  800081:	e8 ee ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800086:	81 c3 7a 1f 00 00    	add    $0x1f7a,%ebx
  80008c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008f:	c7 c6 2c 20 80 00    	mov    $0x80202c,%esi
  800095:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	thisenv = (struct Env*)(envs + ENVX(sys_getenvid())); //（为当前进程）初始化全局指针
  80009b:	e8 3d 0b 00 00       	call   800bdd <sys_getenvid>
  8000a0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a5:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8000a8:	c1 e0 05             	shl    $0x5,%eax
  8000ab:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000b1:	89 06                	mov    %eax,(%esi)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000b7:	7e 08                	jle    8000c1 <libmain+0x49>
		binaryname = argv[0];
  8000b9:	8b 07                	mov    (%edi),%eax
  8000bb:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	57                   	push   %edi
  8000c5:	ff 75 08             	pushl  0x8(%ebp)
  8000c8:	e8 66 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000cd:	e8 0b 00 00 00       	call   8000dd <exit>
}
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 10             	sub    $0x10,%esp
  8000e4:	e8 8b ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000e9:	81 c3 17 1f 00 00    	add    $0x1f17,%ebx
	sys_env_destroy(0);
  8000ef:	6a 00                	push   $0x0
  8000f1:	e8 92 0a 00 00       	call   800b88 <sys_env_destroy>
}
  8000f6:	83 c4 10             	add    $0x10,%esp
  8000f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    

008000fe <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	e8 6c ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800108:	81 c3 f8 1e 00 00    	add    $0x1ef8,%ebx
  80010e:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800111:	8b 16                	mov    (%esi),%edx
  800113:	8d 42 01             	lea    0x1(%edx),%eax
  800116:	89 06                	mov    %eax,(%esi)
  800118:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011b:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  80011f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800124:	74 0b                	je     800131 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800126:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80012a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800131:	83 ec 08             	sub    $0x8,%esp
  800134:	68 ff 00 00 00       	push   $0xff
  800139:	8d 46 08             	lea    0x8(%esi),%eax
  80013c:	50                   	push   %eax
  80013d:	e8 09 0a 00 00       	call   800b4b <sys_cputs>
		b->idx = 0;
  800142:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	eb d9                	jmp    800126 <putch+0x28>

0080014d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	53                   	push   %ebx
  800151:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800157:	e8 18 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  80015c:	81 c3 a4 1e 00 00    	add    $0x1ea4,%ebx
	struct printbuf b;

	b.idx = 0;
  800162:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800169:	00 00 00 
	b.cnt = 0;
  80016c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800173:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800176:	ff 75 0c             	pushl  0xc(%ebp)
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	8d 83 fe e0 ff ff    	lea    -0x1f02(%ebx),%eax
  800189:	50                   	push   %eax
  80018a:	e8 38 01 00 00       	call   8002c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018f:	83 c4 08             	add    $0x8,%esp
  800192:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800198:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 a7 09 00 00       	call   800b4b <sys_cputs>

	return b.cnt;
}
  8001a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b8:	50                   	push   %eax
  8001b9:	ff 75 08             	pushl  0x8(%ebp)
  8001bc:	e8 8c ff ff ff       	call   80014d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	57                   	push   %edi
  8001c7:	56                   	push   %esi
  8001c8:	53                   	push   %ebx
  8001c9:	83 ec 2c             	sub    $0x2c,%esp
  8001cc:	e8 02 06 00 00       	call   8007d3 <__x86.get_pc_thunk.cx>
  8001d1:	81 c1 2f 1e 00 00    	add    $0x1e2f,%ecx
  8001d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001da:	89 c7                	mov    %eax,%edi
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001f5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001f8:	39 d3                	cmp    %edx,%ebx
  8001fa:	72 09                	jb     800205 <printnum+0x42>
  8001fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ff:	0f 87 83 00 00 00    	ja     800288 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800205:	83 ec 0c             	sub    $0xc,%esp
  800208:	ff 75 18             	pushl  0x18(%ebp)
  80020b:	8b 45 14             	mov    0x14(%ebp),%eax
  80020e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800211:	53                   	push   %ebx
  800212:	ff 75 10             	pushl  0x10(%ebp)
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	ff 75 dc             	pushl  -0x24(%ebp)
  80021b:	ff 75 d8             	pushl  -0x28(%ebp)
  80021e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800221:	ff 75 d0             	pushl  -0x30(%ebp)
  800224:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800227:	e8 34 0a 00 00       	call   800c60 <__udivdi3>
  80022c:	83 c4 18             	add    $0x18,%esp
  80022f:	52                   	push   %edx
  800230:	50                   	push   %eax
  800231:	89 f2                	mov    %esi,%edx
  800233:	89 f8                	mov    %edi,%eax
  800235:	e8 89 ff ff ff       	call   8001c3 <printnum>
  80023a:	83 c4 20             	add    $0x20,%esp
  80023d:	eb 13                	jmp    800252 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023f:	83 ec 08             	sub    $0x8,%esp
  800242:	56                   	push   %esi
  800243:	ff 75 18             	pushl  0x18(%ebp)
  800246:	ff d7                	call   *%edi
  800248:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80024b:	83 eb 01             	sub    $0x1,%ebx
  80024e:	85 db                	test   %ebx,%ebx
  800250:	7f ed                	jg     80023f <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800252:	83 ec 08             	sub    $0x8,%esp
  800255:	56                   	push   %esi
  800256:	83 ec 04             	sub    $0x4,%esp
  800259:	ff 75 dc             	pushl  -0x24(%ebp)
  80025c:	ff 75 d8             	pushl  -0x28(%ebp)
  80025f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800262:	ff 75 d0             	pushl  -0x30(%ebp)
  800265:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800268:	89 f3                	mov    %esi,%ebx
  80026a:	e8 11 0b 00 00       	call   800d80 <__umoddi3>
  80026f:	83 c4 14             	add    $0x14,%esp
  800272:	0f be 84 06 cb ee ff 	movsbl -0x1135(%esi,%eax,1),%eax
  800279:	ff 
  80027a:	50                   	push   %eax
  80027b:	ff d7                	call   *%edi
}
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800283:	5b                   	pop    %ebx
  800284:	5e                   	pop    %esi
  800285:	5f                   	pop    %edi
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    
  800288:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028b:	eb be                	jmp    80024b <printnum+0x88>

0080028d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800293:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800297:	8b 10                	mov    (%eax),%edx
  800299:	3b 50 04             	cmp    0x4(%eax),%edx
  80029c:	73 0a                	jae    8002a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	88 02                	mov    %al,(%edx)
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <printfmt>:
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b3:	50                   	push   %eax
  8002b4:	ff 75 10             	pushl  0x10(%ebp)
  8002b7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ba:	ff 75 08             	pushl  0x8(%ebp)
  8002bd:	e8 05 00 00 00       	call   8002c7 <vprintfmt>
}
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	c9                   	leave  
  8002c6:	c3                   	ret    

008002c7 <vprintfmt>:
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	57                   	push   %edi
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
  8002cd:	83 ec 2c             	sub    $0x2c,%esp
  8002d0:	e8 9f fd ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8002d5:	81 c3 2b 1d 00 00    	add    $0x1d2b,%ebx
  8002db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e1:	e9 c3 03 00 00       	jmp    8006a9 <.L35+0x48>
		padc = ' ';
  8002e6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002ea:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002f1:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002f8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800304:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8d 47 01             	lea    0x1(%edi),%eax
  80030a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030d:	0f b6 17             	movzbl (%edi),%edx
  800310:	8d 42 dd             	lea    -0x23(%edx),%eax
  800313:	3c 55                	cmp    $0x55,%al
  800315:	0f 87 16 04 00 00    	ja     800731 <.L22>
  80031b:	0f b6 c0             	movzbl %al,%eax
  80031e:	89 d9                	mov    %ebx,%ecx
  800320:	03 8c 83 58 ef ff ff 	add    -0x10a8(%ebx,%eax,4),%ecx
  800327:	ff e1                	jmp    *%ecx

00800329 <.L69>:
  800329:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80032c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800330:	eb d5                	jmp    800307 <vprintfmt+0x40>

00800332 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800335:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800339:	eb cc                	jmp    800307 <vprintfmt+0x40>

0080033b <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	0f b6 d2             	movzbl %dl,%edx
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800341:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800346:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800349:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80034d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800350:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800353:	83 f9 09             	cmp    $0x9,%ecx
  800356:	77 55                	ja     8003ad <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800358:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80035b:	eb e9                	jmp    800346 <.L29+0xb>

0080035d <.L26>:
			precision = va_arg(ap, int);
  80035d:	8b 45 14             	mov    0x14(%ebp),%eax
  800360:	8b 00                	mov    (%eax),%eax
  800362:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800365:	8b 45 14             	mov    0x14(%ebp),%eax
  800368:	8d 40 04             	lea    0x4(%eax),%eax
  80036b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800371:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800375:	79 90                	jns    800307 <vprintfmt+0x40>
				width = precision, precision = -1;
  800377:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80037a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800384:	eb 81                	jmp    800307 <vprintfmt+0x40>

00800386 <.L27>:
  800386:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800389:	85 c0                	test   %eax,%eax
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
  800390:	0f 49 d0             	cmovns %eax,%edx
  800393:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800399:	e9 69 ff ff ff       	jmp    800307 <vprintfmt+0x40>

0080039e <.L23>:
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003a1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a8:	e9 5a ff ff ff       	jmp    800307 <vprintfmt+0x40>
  8003ad:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003b0:	eb bf                	jmp    800371 <.L26+0x14>

008003b2 <.L33>:
			lflag++;
  8003b2:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b9:	e9 49 ff ff ff       	jmp    800307 <vprintfmt+0x40>

008003be <.L30>:
			putch(va_arg(ap, int), putdat);
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 78 04             	lea    0x4(%eax),%edi
  8003c4:	83 ec 08             	sub    $0x8,%esp
  8003c7:	56                   	push   %esi
  8003c8:	ff 30                	pushl  (%eax)
  8003ca:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003cd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003d0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d3:	e9 ce 02 00 00       	jmp    8006a6 <.L35+0x45>

008003d8 <.L32>:
			err = va_arg(ap, int);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 78 04             	lea    0x4(%eax),%edi
  8003de:	8b 00                	mov    (%eax),%eax
  8003e0:	99                   	cltd   
  8003e1:	31 d0                	xor    %edx,%eax
  8003e3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e5:	83 f8 06             	cmp    $0x6,%eax
  8003e8:	7f 27                	jg     800411 <.L32+0x39>
  8003ea:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003f1:	85 d2                	test   %edx,%edx
  8003f3:	74 1c                	je     800411 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003f5:	52                   	push   %edx
  8003f6:	8d 83 ec ee ff ff    	lea    -0x1114(%ebx),%eax
  8003fc:	50                   	push   %eax
  8003fd:	56                   	push   %esi
  8003fe:	ff 75 08             	pushl  0x8(%ebp)
  800401:	e8 a4 fe ff ff       	call   8002aa <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800409:	89 7d 14             	mov    %edi,0x14(%ebp)
  80040c:	e9 95 02 00 00       	jmp    8006a6 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800411:	50                   	push   %eax
  800412:	8d 83 e3 ee ff ff    	lea    -0x111d(%ebx),%eax
  800418:	50                   	push   %eax
  800419:	56                   	push   %esi
  80041a:	ff 75 08             	pushl  0x8(%ebp)
  80041d:	e8 88 fe ff ff       	call   8002aa <printfmt>
  800422:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800425:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800428:	e9 79 02 00 00       	jmp    8006a6 <.L35+0x45>

0080042d <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	83 c0 04             	add    $0x4,%eax
  800433:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80043b:	85 ff                	test   %edi,%edi
  80043d:	8d 83 dc ee ff ff    	lea    -0x1124(%ebx),%eax
  800443:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800446:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044a:	0f 8e b5 00 00 00    	jle    800505 <.L36+0xd8>
  800450:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800454:	75 08                	jne    80045e <.L36+0x31>
  800456:	89 75 0c             	mov    %esi,0xc(%ebp)
  800459:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80045c:	eb 6d                	jmp    8004cb <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	ff 75 cc             	pushl  -0x34(%ebp)
  800464:	57                   	push   %edi
  800465:	e8 85 03 00 00       	call   8007ef <strnlen>
  80046a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80046d:	29 c2                	sub    %eax,%edx
  80046f:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800475:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047f:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	eb 10                	jmp    800493 <.L36+0x66>
					putch(padc, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	56                   	push   %esi
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ef 01             	sub    $0x1,%edi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 ff                	test   %edi,%edi
  800495:	7f ec                	jg     800483 <.L36+0x56>
  800497:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80049d:	85 d2                	test   %edx,%edx
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	0f 49 c2             	cmovns %edx,%eax
  8004a7:	29 c2                	sub    %eax,%edx
  8004a9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ac:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004af:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004b2:	eb 17                	jmp    8004cb <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b8:	75 30                	jne    8004ea <.L36+0xbd>
					putch(ch, putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	ff 75 0c             	pushl  0xc(%ebp)
  8004c0:	50                   	push   %eax
  8004c1:	ff 55 08             	call   *0x8(%ebp)
  8004c4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c7:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004cb:	83 c7 01             	add    $0x1,%edi
  8004ce:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004d2:	0f be c2             	movsbl %dl,%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 52                	je     80052b <.L36+0xfe>
  8004d9:	85 f6                	test   %esi,%esi
  8004db:	78 d7                	js     8004b4 <.L36+0x87>
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	79 d2                	jns    8004b4 <.L36+0x87>
  8004e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004e5:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e8:	eb 32                	jmp    80051c <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ea:	0f be d2             	movsbl %dl,%edx
  8004ed:	83 ea 20             	sub    $0x20,%edx
  8004f0:	83 fa 5e             	cmp    $0x5e,%edx
  8004f3:	76 c5                	jbe    8004ba <.L36+0x8d>
					putch('?', putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	ff 75 0c             	pushl  0xc(%ebp)
  8004fb:	6a 3f                	push   $0x3f
  8004fd:	ff 55 08             	call   *0x8(%ebp)
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	eb c2                	jmp    8004c7 <.L36+0x9a>
  800505:	89 75 0c             	mov    %esi,0xc(%ebp)
  800508:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80050b:	eb be                	jmp    8004cb <.L36+0x9e>
				putch(' ', putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	56                   	push   %esi
  800511:	6a 20                	push   $0x20
  800513:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800516:	83 ef 01             	sub    $0x1,%edi
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	85 ff                	test   %edi,%edi
  80051e:	7f ed                	jg     80050d <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800520:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800523:	89 45 14             	mov    %eax,0x14(%ebp)
  800526:	e9 7b 01 00 00       	jmp    8006a6 <.L35+0x45>
  80052b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80052e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800531:	eb e9                	jmp    80051c <.L36+0xef>

00800533 <.L31>:
  800533:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800536:	83 f9 01             	cmp    $0x1,%ecx
  800539:	7e 40                	jle    80057b <.L31+0x48>
		return va_arg(*ap, long long);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8b 50 04             	mov    0x4(%eax),%edx
  800541:	8b 00                	mov    (%eax),%eax
  800543:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800546:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8d 40 08             	lea    0x8(%eax),%eax
  80054f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800552:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800556:	79 55                	jns    8005ad <.L31+0x7a>
				putch('-', putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	56                   	push   %esi
  80055c:	6a 2d                	push   $0x2d
  80055e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800561:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800564:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800567:	f7 da                	neg    %edx
  800569:	83 d1 00             	adc    $0x0,%ecx
  80056c:	f7 d9                	neg    %ecx
  80056e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800571:	b8 0a 00 00 00       	mov    $0xa,%eax
  800576:	e9 10 01 00 00       	jmp    80068b <.L35+0x2a>
	else if (lflag)
  80057b:	85 c9                	test   %ecx,%ecx
  80057d:	75 17                	jne    800596 <.L31+0x63>
		return va_arg(*ap, int);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8b 00                	mov    (%eax),%eax
  800584:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800587:	99                   	cltd   
  800588:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 40 04             	lea    0x4(%eax),%eax
  800591:	89 45 14             	mov    %eax,0x14(%ebp)
  800594:	eb bc                	jmp    800552 <.L31+0x1f>
		return va_arg(*ap, long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8b 00                	mov    (%eax),%eax
  80059b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059e:	99                   	cltd   
  80059f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 40 04             	lea    0x4(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ab:	eb a5                	jmp    800552 <.L31+0x1f>
			num = getint(&ap, lflag);
  8005ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b8:	e9 ce 00 00 00       	jmp    80068b <.L35+0x2a>

008005bd <.L37>:
  8005bd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005c0:	83 f9 01             	cmp    $0x1,%ecx
  8005c3:	7e 18                	jle    8005dd <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8b 10                	mov    (%eax),%edx
  8005ca:	8b 48 04             	mov    0x4(%eax),%ecx
  8005cd:	8d 40 08             	lea    0x8(%eax),%eax
  8005d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	e9 ae 00 00 00       	jmp    80068b <.L35+0x2a>
	else if (lflag)
  8005dd:	85 c9                	test   %ecx,%ecx
  8005df:	75 1a                	jne    8005fb <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005eb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f6:	e9 90 00 00 00       	jmp    80068b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	b9 00 00 00 00       	mov    $0x0,%ecx
  800605:	8d 40 04             	lea    0x4(%eax),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800610:	eb 79                	jmp    80068b <.L35+0x2a>

00800612 <.L34>:
  800612:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800615:	83 f9 01             	cmp    $0x1,%ecx
  800618:	7e 15                	jle    80062f <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	8b 48 04             	mov    0x4(%eax),%ecx
  800622:	8d 40 08             	lea    0x8(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800628:	b8 08 00 00 00       	mov    $0x8,%eax
  80062d:	eb 5c                	jmp    80068b <.L35+0x2a>
	else if (lflag)
  80062f:	85 c9                	test   %ecx,%ecx
  800631:	75 17                	jne    80064a <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 10                	mov    (%eax),%edx
  800638:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063d:	8d 40 04             	lea    0x4(%eax),%eax
  800640:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800643:	b8 08 00 00 00       	mov    $0x8,%eax
  800648:	eb 41                	jmp    80068b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 10                	mov    (%eax),%edx
  80064f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80065a:	b8 08 00 00 00       	mov    $0x8,%eax
  80065f:	eb 2a                	jmp    80068b <.L35+0x2a>

00800661 <.L35>:
			putch('0', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	56                   	push   %esi
  800665:	6a 30                	push   $0x30
  800667:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80066a:	83 c4 08             	add    $0x8,%esp
  80066d:	56                   	push   %esi
  80066e:	6a 78                	push   $0x78
  800670:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80067d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800686:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80068b:	83 ec 0c             	sub    $0xc,%esp
  80068e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800692:	57                   	push   %edi
  800693:	ff 75 e0             	pushl  -0x20(%ebp)
  800696:	50                   	push   %eax
  800697:	51                   	push   %ecx
  800698:	52                   	push   %edx
  800699:	89 f2                	mov    %esi,%edx
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	e8 20 fb ff ff       	call   8001c3 <printnum>
			break;
  8006a3:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a9:	83 c7 01             	add    $0x1,%edi
  8006ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b0:	83 f8 25             	cmp    $0x25,%eax
  8006b3:	0f 84 2d fc ff ff    	je     8002e6 <vprintfmt+0x1f>
			if (ch == '\0')
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	0f 84 91 00 00 00    	je     800752 <.L22+0x21>
			putch(ch, putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	56                   	push   %esi
  8006c5:	50                   	push   %eax
  8006c6:	ff 55 08             	call   *0x8(%ebp)
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb db                	jmp    8006a9 <.L35+0x48>

008006ce <.L38>:
  8006ce:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 15                	jle    8006eb <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8b 48 04             	mov    0x4(%eax),%ecx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e9:	eb a0                	jmp    80068b <.L35+0x2a>
	else if (lflag)
  8006eb:	85 c9                	test   %ecx,%ecx
  8006ed:	75 17                	jne    800706 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f9:	8d 40 04             	lea    0x4(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ff:	b8 10 00 00 00       	mov    $0x10,%eax
  800704:	eb 85                	jmp    80068b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800710:	8d 40 04             	lea    0x4(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800716:	b8 10 00 00 00       	mov    $0x10,%eax
  80071b:	e9 6b ff ff ff       	jmp    80068b <.L35+0x2a>

00800720 <.L25>:
			putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	56                   	push   %esi
  800724:	6a 25                	push   $0x25
  800726:	ff 55 08             	call   *0x8(%ebp)
			break;
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	e9 75 ff ff ff       	jmp    8006a6 <.L35+0x45>

00800731 <.L22>:
			putch('%', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	56                   	push   %esi
  800735:	6a 25                	push   $0x25
  800737:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	89 f8                	mov    %edi,%eax
  80073f:	eb 03                	jmp    800744 <.L22+0x13>
  800741:	83 e8 01             	sub    $0x1,%eax
  800744:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800748:	75 f7                	jne    800741 <.L22+0x10>
  80074a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074d:	e9 54 ff ff ff       	jmp    8006a6 <.L35+0x45>
}
  800752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	53                   	push   %ebx
  80075e:	83 ec 14             	sub    $0x14,%esp
  800761:	e8 0e f9 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800766:	81 c3 9a 18 00 00    	add    $0x189a,%ebx
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800779:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800783:	85 c0                	test   %eax,%eax
  800785:	74 2b                	je     8007b2 <vsnprintf+0x58>
  800787:	85 d2                	test   %edx,%edx
  800789:	7e 27                	jle    8007b2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078b:	ff 75 14             	pushl  0x14(%ebp)
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	8d 83 8d e2 ff ff    	lea    -0x1d73(%ebx),%eax
  80079b:	50                   	push   %eax
  80079c:	e8 26 fb ff ff       	call   8002c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007aa:	83 c4 10             	add    $0x10,%esp
}
  8007ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    
		return -E_INVAL;
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b7:	eb f4                	jmp    8007ad <vsnprintf+0x53>

008007b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c2:	50                   	push   %eax
  8007c3:	ff 75 10             	pushl  0x10(%ebp)
  8007c6:	ff 75 0c             	pushl  0xc(%ebp)
  8007c9:	ff 75 08             	pushl  0x8(%ebp)
  8007cc:	e8 89 ff ff ff       	call   80075a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <__x86.get_pc_thunk.cx>:
  8007d3:	8b 0c 24             	mov    (%esp),%ecx
  8007d6:	c3                   	ret    

008007d7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e2:	eb 03                	jmp    8007e7 <strlen+0x10>
		n++;
  8007e4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007e7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007eb:	75 f7                	jne    8007e4 <strlen+0xd>
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fd:	eb 03                	jmp    800802 <strnlen+0x13>
		n++;
  8007ff:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800802:	39 d0                	cmp    %edx,%eax
  800804:	74 06                	je     80080c <strnlen+0x1d>
  800806:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080a:	75 f3                	jne    8007ff <strnlen+0x10>
	return n;
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	53                   	push   %ebx
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800818:	89 c2                	mov    %eax,%edx
  80081a:	83 c1 01             	add    $0x1,%ecx
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800824:	88 5a ff             	mov    %bl,-0x1(%edx)
  800827:	84 db                	test   %bl,%bl
  800829:	75 ef                	jne    80081a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082b:	5b                   	pop    %ebx
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	53                   	push   %ebx
  800832:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800835:	53                   	push   %ebx
  800836:	e8 9c ff ff ff       	call   8007d7 <strlen>
  80083b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083e:	ff 75 0c             	pushl  0xc(%ebp)
  800841:	01 d8                	add    %ebx,%eax
  800843:	50                   	push   %eax
  800844:	e8 c5 ff ff ff       	call   80080e <strcpy>
	return dst;
}
  800849:	89 d8                	mov    %ebx,%eax
  80084b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	56                   	push   %esi
  800854:	53                   	push   %ebx
  800855:	8b 75 08             	mov    0x8(%ebp),%esi
  800858:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085b:	89 f3                	mov    %esi,%ebx
  80085d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800860:	89 f2                	mov    %esi,%edx
  800862:	eb 0f                	jmp    800873 <strncpy+0x23>
		*dst++ = *src;
  800864:	83 c2 01             	add    $0x1,%edx
  800867:	0f b6 01             	movzbl (%ecx),%eax
  80086a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086d:	80 39 01             	cmpb   $0x1,(%ecx)
  800870:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800873:	39 da                	cmp    %ebx,%edx
  800875:	75 ed                	jne    800864 <strncpy+0x14>
	}
	return ret;
}
  800877:	89 f0                	mov    %esi,%eax
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	56                   	push   %esi
  800881:	53                   	push   %ebx
  800882:	8b 75 08             	mov    0x8(%ebp),%esi
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
  800888:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088b:	89 f0                	mov    %esi,%eax
  80088d:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800891:	85 c9                	test   %ecx,%ecx
  800893:	75 0b                	jne    8008a0 <strlcpy+0x23>
  800895:	eb 17                	jmp    8008ae <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800897:	83 c2 01             	add    $0x1,%edx
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008a0:	39 d8                	cmp    %ebx,%eax
  8008a2:	74 07                	je     8008ab <strlcpy+0x2e>
  8008a4:	0f b6 0a             	movzbl (%edx),%ecx
  8008a7:	84 c9                	test   %cl,%cl
  8008a9:	75 ec                	jne    800897 <strlcpy+0x1a>
		*dst = '\0';
  8008ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ae:	29 f0                	sub    %esi,%eax
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bd:	eb 06                	jmp    8008c5 <strcmp+0x11>
		p++, q++;
  8008bf:	83 c1 01             	add    $0x1,%ecx
  8008c2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008c5:	0f b6 01             	movzbl (%ecx),%eax
  8008c8:	84 c0                	test   %al,%al
  8008ca:	74 04                	je     8008d0 <strcmp+0x1c>
  8008cc:	3a 02                	cmp    (%edx),%al
  8008ce:	74 ef                	je     8008bf <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d0:	0f b6 c0             	movzbl %al,%eax
  8008d3:	0f b6 12             	movzbl (%edx),%edx
  8008d6:	29 d0                	sub    %edx,%eax
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	53                   	push   %ebx
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e4:	89 c3                	mov    %eax,%ebx
  8008e6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e9:	eb 06                	jmp    8008f1 <strncmp+0x17>
		n--, p++, q++;
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f1:	39 d8                	cmp    %ebx,%eax
  8008f3:	74 16                	je     80090b <strncmp+0x31>
  8008f5:	0f b6 08             	movzbl (%eax),%ecx
  8008f8:	84 c9                	test   %cl,%cl
  8008fa:	74 04                	je     800900 <strncmp+0x26>
  8008fc:	3a 0a                	cmp    (%edx),%cl
  8008fe:	74 eb                	je     8008eb <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800900:	0f b6 00             	movzbl (%eax),%eax
  800903:	0f b6 12             	movzbl (%edx),%edx
  800906:	29 d0                	sub    %edx,%eax
}
  800908:	5b                   	pop    %ebx
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    
		return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	eb f6                	jmp    800908 <strncmp+0x2e>

00800912 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091c:	0f b6 10             	movzbl (%eax),%edx
  80091f:	84 d2                	test   %dl,%dl
  800921:	74 09                	je     80092c <strchr+0x1a>
		if (*s == c)
  800923:	38 ca                	cmp    %cl,%dl
  800925:	74 0a                	je     800931 <strchr+0x1f>
	for (; *s; s++)
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	eb f0                	jmp    80091c <strchr+0xa>
			return (char *) s;
	return 0;
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093d:	eb 03                	jmp    800942 <strfind+0xf>
  80093f:	83 c0 01             	add    $0x1,%eax
  800942:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800945:	38 ca                	cmp    %cl,%dl
  800947:	74 04                	je     80094d <strfind+0x1a>
  800949:	84 d2                	test   %dl,%dl
  80094b:	75 f2                	jne    80093f <strfind+0xc>
			break;
	return (char *) s;
}
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	57                   	push   %edi
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	8b 7d 08             	mov    0x8(%ebp),%edi
  800958:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095b:	85 c9                	test   %ecx,%ecx
  80095d:	74 13                	je     800972 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800965:	75 05                	jne    80096c <memset+0x1d>
  800967:	f6 c1 03             	test   $0x3,%cl
  80096a:	74 0d                	je     800979 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	fc                   	cld    
  800970:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800972:	89 f8                	mov    %edi,%eax
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    
		c &= 0xFF;
  800979:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097d:	89 d3                	mov    %edx,%ebx
  80097f:	c1 e3 08             	shl    $0x8,%ebx
  800982:	89 d0                	mov    %edx,%eax
  800984:	c1 e0 18             	shl    $0x18,%eax
  800987:	89 d6                	mov    %edx,%esi
  800989:	c1 e6 10             	shl    $0x10,%esi
  80098c:	09 f0                	or     %esi,%eax
  80098e:	09 c2                	or     %eax,%edx
  800990:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800992:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800995:	89 d0                	mov    %edx,%eax
  800997:	fc                   	cld    
  800998:	f3 ab                	rep stos %eax,%es:(%edi)
  80099a:	eb d6                	jmp    800972 <memset+0x23>

0080099c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009aa:	39 c6                	cmp    %eax,%esi
  8009ac:	73 35                	jae    8009e3 <memmove+0x47>
  8009ae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b1:	39 c2                	cmp    %eax,%edx
  8009b3:	76 2e                	jbe    8009e3 <memmove+0x47>
		s += n;
		d += n;
  8009b5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b8:	89 d6                	mov    %edx,%esi
  8009ba:	09 fe                	or     %edi,%esi
  8009bc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c2:	74 0c                	je     8009d0 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c4:	83 ef 01             	sub    $0x1,%edi
  8009c7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ca:	fd                   	std    
  8009cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cd:	fc                   	cld    
  8009ce:	eb 21                	jmp    8009f1 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d0:	f6 c1 03             	test   $0x3,%cl
  8009d3:	75 ef                	jne    8009c4 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d5:	83 ef 04             	sub    $0x4,%edi
  8009d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009db:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009de:	fd                   	std    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb ea                	jmp    8009cd <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e3:	89 f2                	mov    %esi,%edx
  8009e5:	09 c2                	or     %eax,%edx
  8009e7:	f6 c2 03             	test   $0x3,%dl
  8009ea:	74 09                	je     8009f5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ec:	89 c7                	mov    %eax,%edi
  8009ee:	fc                   	cld    
  8009ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f5:	f6 c1 03             	test   $0x3,%cl
  8009f8:	75 f2                	jne    8009ec <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009fd:	89 c7                	mov    %eax,%edi
  8009ff:	fc                   	cld    
  800a00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a02:	eb ed                	jmp    8009f1 <memmove+0x55>

00800a04 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a07:	ff 75 10             	pushl  0x10(%ebp)
  800a0a:	ff 75 0c             	pushl  0xc(%ebp)
  800a0d:	ff 75 08             	pushl  0x8(%ebp)
  800a10:	e8 87 ff ff ff       	call   80099c <memmove>
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a22:	89 c6                	mov    %eax,%esi
  800a24:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a27:	39 f0                	cmp    %esi,%eax
  800a29:	74 1c                	je     800a47 <memcmp+0x30>
		if (*s1 != *s2)
  800a2b:	0f b6 08             	movzbl (%eax),%ecx
  800a2e:	0f b6 1a             	movzbl (%edx),%ebx
  800a31:	38 d9                	cmp    %bl,%cl
  800a33:	75 08                	jne    800a3d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	83 c2 01             	add    $0x1,%edx
  800a3b:	eb ea                	jmp    800a27 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a3d:	0f b6 c1             	movzbl %cl,%eax
  800a40:	0f b6 db             	movzbl %bl,%ebx
  800a43:	29 d8                	sub    %ebx,%eax
  800a45:	eb 05                	jmp    800a4c <memcmp+0x35>
	}

	return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a59:	89 c2                	mov    %eax,%edx
  800a5b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5e:	39 d0                	cmp    %edx,%eax
  800a60:	73 09                	jae    800a6b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a62:	38 08                	cmp    %cl,(%eax)
  800a64:	74 05                	je     800a6b <memfind+0x1b>
	for (; s < ends; s++)
  800a66:	83 c0 01             	add    $0x1,%eax
  800a69:	eb f3                	jmp    800a5e <memfind+0xe>
			break;
	return (void *) s;
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a79:	eb 03                	jmp    800a7e <strtol+0x11>
		s++;
  800a7b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a7e:	0f b6 01             	movzbl (%ecx),%eax
  800a81:	3c 20                	cmp    $0x20,%al
  800a83:	74 f6                	je     800a7b <strtol+0xe>
  800a85:	3c 09                	cmp    $0x9,%al
  800a87:	74 f2                	je     800a7b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a89:	3c 2b                	cmp    $0x2b,%al
  800a8b:	74 2e                	je     800abb <strtol+0x4e>
	int neg = 0;
  800a8d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a92:	3c 2d                	cmp    $0x2d,%al
  800a94:	74 2f                	je     800ac5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9c:	75 05                	jne    800aa3 <strtol+0x36>
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	74 2c                	je     800acf <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa3:	85 db                	test   %ebx,%ebx
  800aa5:	75 0a                	jne    800ab1 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa7:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aac:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaf:	74 28                	je     800ad9 <strtol+0x6c>
		base = 10;
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab9:	eb 50                	jmp    800b0b <strtol+0x9e>
		s++;
  800abb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800abe:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac3:	eb d1                	jmp    800a96 <strtol+0x29>
		s++, neg = 1;
  800ac5:	83 c1 01             	add    $0x1,%ecx
  800ac8:	bf 01 00 00 00       	mov    $0x1,%edi
  800acd:	eb c7                	jmp    800a96 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800acf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad3:	74 0e                	je     800ae3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ad5:	85 db                	test   %ebx,%ebx
  800ad7:	75 d8                	jne    800ab1 <strtol+0x44>
		s++, base = 8;
  800ad9:	83 c1 01             	add    $0x1,%ecx
  800adc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ae1:	eb ce                	jmp    800ab1 <strtol+0x44>
		s += 2, base = 16;
  800ae3:	83 c1 02             	add    $0x2,%ecx
  800ae6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aeb:	eb c4                	jmp    800ab1 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aed:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af0:	89 f3                	mov    %esi,%ebx
  800af2:	80 fb 19             	cmp    $0x19,%bl
  800af5:	77 29                	ja     800b20 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800af7:	0f be d2             	movsbl %dl,%edx
  800afa:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800afd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b00:	7d 30                	jge    800b32 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b02:	83 c1 01             	add    $0x1,%ecx
  800b05:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b09:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b0b:	0f b6 11             	movzbl (%ecx),%edx
  800b0e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b11:	89 f3                	mov    %esi,%ebx
  800b13:	80 fb 09             	cmp    $0x9,%bl
  800b16:	77 d5                	ja     800aed <strtol+0x80>
			dig = *s - '0';
  800b18:	0f be d2             	movsbl %dl,%edx
  800b1b:	83 ea 30             	sub    $0x30,%edx
  800b1e:	eb dd                	jmp    800afd <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b20:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b23:	89 f3                	mov    %esi,%ebx
  800b25:	80 fb 19             	cmp    $0x19,%bl
  800b28:	77 08                	ja     800b32 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b2a:	0f be d2             	movsbl %dl,%edx
  800b2d:	83 ea 37             	sub    $0x37,%edx
  800b30:	eb cb                	jmp    800afd <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b36:	74 05                	je     800b3d <strtol+0xd0>
		*endptr = (char *) s;
  800b38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b3d:	89 c2                	mov    %eax,%edx
  800b3f:	f7 da                	neg    %edx
  800b41:	85 ff                	test   %edi,%edi
  800b43:	0f 45 c2             	cmovne %edx,%eax
}
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5c:	89 c3                	mov    %eax,%ebx
  800b5e:	89 c7                	mov    %eax,%edi
  800b60:	89 c6                	mov    %eax,%esi
  800b62:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 01 00 00 00       	mov    $0x1,%eax
  800b79:	89 d1                	mov    %edx,%ecx
  800b7b:	89 d3                	mov    %edx,%ebx
  800b7d:	89 d7                	mov    %edx,%edi
  800b7f:	89 d6                	mov    %edx,%esi
  800b81:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 1c             	sub    $0x1c,%esp
  800b91:	e8 66 00 00 00       	call   800bfc <__x86.get_pc_thunk.ax>
  800b96:	05 6a 14 00 00       	add    $0x146a,%eax
  800b9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba6:	b8 03 00 00 00       	mov    $0x3,%eax
  800bab:	89 cb                	mov    %ecx,%ebx
  800bad:	89 cf                	mov    %ecx,%edi
  800baf:	89 ce                	mov    %ecx,%esi
  800bb1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7f 08                	jg     800bbf <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	50                   	push   %eax
  800bc3:	6a 03                	push   $0x3
  800bc5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bc8:	8d 83 b0 f0 ff ff    	lea    -0xf50(%ebx),%eax
  800bce:	50                   	push   %eax
  800bcf:	6a 23                	push   $0x23
  800bd1:	8d 83 cd f0 ff ff    	lea    -0xf33(%ebx),%eax
  800bd7:	50                   	push   %eax
  800bd8:	e8 23 00 00 00       	call   800c00 <_panic>

00800bdd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be3:	ba 00 00 00 00       	mov    $0x0,%edx
  800be8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bed:	89 d1                	mov    %edx,%ecx
  800bef:	89 d3                	mov    %edx,%ebx
  800bf1:	89 d7                	mov    %edx,%edi
  800bf3:	89 d6                	mov    %edx,%esi
  800bf5:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <__x86.get_pc_thunk.ax>:
  800bfc:	8b 04 24             	mov    (%esp),%eax
  800bff:	c3                   	ret    

00800c00 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	e8 66 f4 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800c0e:	81 c3 f2 13 00 00    	add    $0x13f2,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c14:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c17:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c1d:	8b 38                	mov    (%eax),%edi
  800c1f:	e8 b9 ff ff ff       	call   800bdd <sys_getenvid>
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	ff 75 0c             	pushl  0xc(%ebp)
  800c2a:	ff 75 08             	pushl  0x8(%ebp)
  800c2d:	57                   	push   %edi
  800c2e:	50                   	push   %eax
  800c2f:	8d 83 dc f0 ff ff    	lea    -0xf24(%ebx),%eax
  800c35:	50                   	push   %eax
  800c36:	e8 74 f5 ff ff       	call   8001af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c3b:	83 c4 18             	add    $0x18,%esp
  800c3e:	56                   	push   %esi
  800c3f:	ff 75 10             	pushl  0x10(%ebp)
  800c42:	e8 06 f5 ff ff       	call   80014d <vcprintf>
	cprintf("\n");
  800c47:	8d 83 a8 ee ff ff    	lea    -0x1158(%ebx),%eax
  800c4d:	89 04 24             	mov    %eax,(%esp)
  800c50:	e8 5a f5 ff ff       	call   8001af <cprintf>
  800c55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c58:	cc                   	int3   
  800c59:	eb fd                	jmp    800c58 <_panic+0x58>
  800c5b:	66 90                	xchg   %ax,%ax
  800c5d:	66 90                	xchg   %ax,%ax
  800c5f:	90                   	nop

00800c60 <__udivdi3>:
  800c60:	55                   	push   %ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 1c             	sub    $0x1c,%esp
  800c67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c77:	85 d2                	test   %edx,%edx
  800c79:	75 35                	jne    800cb0 <__udivdi3+0x50>
  800c7b:	39 f3                	cmp    %esi,%ebx
  800c7d:	0f 87 bd 00 00 00    	ja     800d40 <__udivdi3+0xe0>
  800c83:	85 db                	test   %ebx,%ebx
  800c85:	89 d9                	mov    %ebx,%ecx
  800c87:	75 0b                	jne    800c94 <__udivdi3+0x34>
  800c89:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8e:	31 d2                	xor    %edx,%edx
  800c90:	f7 f3                	div    %ebx
  800c92:	89 c1                	mov    %eax,%ecx
  800c94:	31 d2                	xor    %edx,%edx
  800c96:	89 f0                	mov    %esi,%eax
  800c98:	f7 f1                	div    %ecx
  800c9a:	89 c6                	mov    %eax,%esi
  800c9c:	89 e8                	mov    %ebp,%eax
  800c9e:	89 f7                	mov    %esi,%edi
  800ca0:	f7 f1                	div    %ecx
  800ca2:	89 fa                	mov    %edi,%edx
  800ca4:	83 c4 1c             	add    $0x1c,%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
  800cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	39 f2                	cmp    %esi,%edx
  800cb2:	77 7c                	ja     800d30 <__udivdi3+0xd0>
  800cb4:	0f bd fa             	bsr    %edx,%edi
  800cb7:	83 f7 1f             	xor    $0x1f,%edi
  800cba:	0f 84 98 00 00 00    	je     800d58 <__udivdi3+0xf8>
  800cc0:	89 f9                	mov    %edi,%ecx
  800cc2:	b8 20 00 00 00       	mov    $0x20,%eax
  800cc7:	29 f8                	sub    %edi,%eax
  800cc9:	d3 e2                	shl    %cl,%edx
  800ccb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ccf:	89 c1                	mov    %eax,%ecx
  800cd1:	89 da                	mov    %ebx,%edx
  800cd3:	d3 ea                	shr    %cl,%edx
  800cd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cd9:	09 d1                	or     %edx,%ecx
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ce1:	89 f9                	mov    %edi,%ecx
  800ce3:	d3 e3                	shl    %cl,%ebx
  800ce5:	89 c1                	mov    %eax,%ecx
  800ce7:	d3 ea                	shr    %cl,%edx
  800ce9:	89 f9                	mov    %edi,%ecx
  800ceb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cef:	d3 e6                	shl    %cl,%esi
  800cf1:	89 eb                	mov    %ebp,%ebx
  800cf3:	89 c1                	mov    %eax,%ecx
  800cf5:	d3 eb                	shr    %cl,%ebx
  800cf7:	09 de                	or     %ebx,%esi
  800cf9:	89 f0                	mov    %esi,%eax
  800cfb:	f7 74 24 08          	divl   0x8(%esp)
  800cff:	89 d6                	mov    %edx,%esi
  800d01:	89 c3                	mov    %eax,%ebx
  800d03:	f7 64 24 0c          	mull   0xc(%esp)
  800d07:	39 d6                	cmp    %edx,%esi
  800d09:	72 0c                	jb     800d17 <__udivdi3+0xb7>
  800d0b:	89 f9                	mov    %edi,%ecx
  800d0d:	d3 e5                	shl    %cl,%ebp
  800d0f:	39 c5                	cmp    %eax,%ebp
  800d11:	73 5d                	jae    800d70 <__udivdi3+0x110>
  800d13:	39 d6                	cmp    %edx,%esi
  800d15:	75 59                	jne    800d70 <__udivdi3+0x110>
  800d17:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d1a:	31 ff                	xor    %edi,%edi
  800d1c:	89 fa                	mov    %edi,%edx
  800d1e:	83 c4 1c             	add    $0x1c,%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    
  800d26:	8d 76 00             	lea    0x0(%esi),%esi
  800d29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d30:	31 ff                	xor    %edi,%edi
  800d32:	31 c0                	xor    %eax,%eax
  800d34:	89 fa                	mov    %edi,%edx
  800d36:	83 c4 1c             	add    $0x1c,%esp
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    
  800d3e:	66 90                	xchg   %ax,%ax
  800d40:	31 ff                	xor    %edi,%edi
  800d42:	89 e8                	mov    %ebp,%eax
  800d44:	89 f2                	mov    %esi,%edx
  800d46:	f7 f3                	div    %ebx
  800d48:	89 fa                	mov    %edi,%edx
  800d4a:	83 c4 1c             	add    $0x1c,%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
  800d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d58:	39 f2                	cmp    %esi,%edx
  800d5a:	72 06                	jb     800d62 <__udivdi3+0x102>
  800d5c:	31 c0                	xor    %eax,%eax
  800d5e:	39 eb                	cmp    %ebp,%ebx
  800d60:	77 d2                	ja     800d34 <__udivdi3+0xd4>
  800d62:	b8 01 00 00 00       	mov    $0x1,%eax
  800d67:	eb cb                	jmp    800d34 <__udivdi3+0xd4>
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	89 d8                	mov    %ebx,%eax
  800d72:	31 ff                	xor    %edi,%edi
  800d74:	eb be                	jmp    800d34 <__udivdi3+0xd4>
  800d76:	66 90                	xchg   %ax,%ax
  800d78:	66 90                	xchg   %ax,%ax
  800d7a:	66 90                	xchg   %ax,%ax
  800d7c:	66 90                	xchg   %ax,%ax
  800d7e:	66 90                	xchg   %ax,%ax

00800d80 <__umoddi3>:
  800d80:	55                   	push   %ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 1c             	sub    $0x1c,%esp
  800d87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d97:	85 ed                	test   %ebp,%ebp
  800d99:	89 f0                	mov    %esi,%eax
  800d9b:	89 da                	mov    %ebx,%edx
  800d9d:	75 19                	jne    800db8 <__umoddi3+0x38>
  800d9f:	39 df                	cmp    %ebx,%edi
  800da1:	0f 86 b1 00 00 00    	jbe    800e58 <__umoddi3+0xd8>
  800da7:	f7 f7                	div    %edi
  800da9:	89 d0                	mov    %edx,%eax
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	83 c4 1c             	add    $0x1c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
  800db5:	8d 76 00             	lea    0x0(%esi),%esi
  800db8:	39 dd                	cmp    %ebx,%ebp
  800dba:	77 f1                	ja     800dad <__umoddi3+0x2d>
  800dbc:	0f bd cd             	bsr    %ebp,%ecx
  800dbf:	83 f1 1f             	xor    $0x1f,%ecx
  800dc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800dc6:	0f 84 b4 00 00 00    	je     800e80 <__umoddi3+0x100>
  800dcc:	b8 20 00 00 00       	mov    $0x20,%eax
  800dd1:	89 c2                	mov    %eax,%edx
  800dd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dd7:	29 c2                	sub    %eax,%edx
  800dd9:	89 c1                	mov    %eax,%ecx
  800ddb:	89 f8                	mov    %edi,%eax
  800ddd:	d3 e5                	shl    %cl,%ebp
  800ddf:	89 d1                	mov    %edx,%ecx
  800de1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800de5:	d3 e8                	shr    %cl,%eax
  800de7:	09 c5                	or     %eax,%ebp
  800de9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ded:	89 c1                	mov    %eax,%ecx
  800def:	d3 e7                	shl    %cl,%edi
  800df1:	89 d1                	mov    %edx,%ecx
  800df3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	d3 ef                	shr    %cl,%edi
  800dfb:	89 c1                	mov    %eax,%ecx
  800dfd:	89 f0                	mov    %esi,%eax
  800dff:	d3 e3                	shl    %cl,%ebx
  800e01:	89 d1                	mov    %edx,%ecx
  800e03:	89 fa                	mov    %edi,%edx
  800e05:	d3 e8                	shr    %cl,%eax
  800e07:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e0c:	09 d8                	or     %ebx,%eax
  800e0e:	f7 f5                	div    %ebp
  800e10:	d3 e6                	shl    %cl,%esi
  800e12:	89 d1                	mov    %edx,%ecx
  800e14:	f7 64 24 08          	mull   0x8(%esp)
  800e18:	39 d1                	cmp    %edx,%ecx
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	89 d7                	mov    %edx,%edi
  800e1e:	72 06                	jb     800e26 <__umoddi3+0xa6>
  800e20:	75 0e                	jne    800e30 <__umoddi3+0xb0>
  800e22:	39 c6                	cmp    %eax,%esi
  800e24:	73 0a                	jae    800e30 <__umoddi3+0xb0>
  800e26:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e2a:	19 ea                	sbb    %ebp,%edx
  800e2c:	89 d7                	mov    %edx,%edi
  800e2e:	89 c3                	mov    %eax,%ebx
  800e30:	89 ca                	mov    %ecx,%edx
  800e32:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e37:	29 de                	sub    %ebx,%esi
  800e39:	19 fa                	sbb    %edi,%edx
  800e3b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e3f:	89 d0                	mov    %edx,%eax
  800e41:	d3 e0                	shl    %cl,%eax
  800e43:	89 d9                	mov    %ebx,%ecx
  800e45:	d3 ee                	shr    %cl,%esi
  800e47:	d3 ea                	shr    %cl,%edx
  800e49:	09 f0                	or     %esi,%eax
  800e4b:	83 c4 1c             	add    $0x1c,%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    
  800e53:	90                   	nop
  800e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e58:	85 ff                	test   %edi,%edi
  800e5a:	89 f9                	mov    %edi,%ecx
  800e5c:	75 0b                	jne    800e69 <__umoddi3+0xe9>
  800e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e63:	31 d2                	xor    %edx,%edx
  800e65:	f7 f7                	div    %edi
  800e67:	89 c1                	mov    %eax,%ecx
  800e69:	89 d8                	mov    %ebx,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f1                	div    %ecx
  800e6f:	89 f0                	mov    %esi,%eax
  800e71:	f7 f1                	div    %ecx
  800e73:	e9 31 ff ff ff       	jmp    800da9 <__umoddi3+0x29>
  800e78:	90                   	nop
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	39 dd                	cmp    %ebx,%ebp
  800e82:	72 08                	jb     800e8c <__umoddi3+0x10c>
  800e84:	39 f7                	cmp    %esi,%edi
  800e86:	0f 87 21 ff ff ff    	ja     800dad <__umoddi3+0x2d>
  800e8c:	89 da                	mov    %ebx,%edx
  800e8e:	89 f0                	mov    %esi,%eax
  800e90:	29 f8                	sub    %edi,%eax
  800e92:	19 ea                	sbb    %ebp,%edx
  800e94:	e9 14 ff ff ff       	jmp    800dad <__umoddi3+0x2d>
