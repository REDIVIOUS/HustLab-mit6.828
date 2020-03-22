
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 46 00 00 00       	call   800077 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 34 00 00 00       	call   800073 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	zero = 0;
  800045:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  80004b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	cprintf("1/0 is %08x!\n", 1/zero);
  800051:	b8 01 00 00 00       	mov    $0x1,%eax
  800056:	b9 00 00 00 00       	mov    $0x0,%ecx
  80005b:	99                   	cltd   
  80005c:	f7 f9                	idiv   %ecx
  80005e:	50                   	push   %eax
  80005f:	8d 83 9c ee ff ff    	lea    -0x1164(%ebx),%eax
  800065:	50                   	push   %eax
  800066:	e8 43 01 00 00       	call   8001ae <cprintf>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <__x86.get_pc_thunk.bx>:
  800073:	8b 1c 24             	mov    (%esp),%ebx
  800076:	c3                   	ret    

00800077 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	57                   	push   %edi
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 0c             	sub    $0xc,%esp
  800080:	e8 ee ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800085:	81 c3 7b 1f 00 00    	add    $0x1f7b,%ebx
  80008b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008e:	c7 c6 30 20 80 00    	mov    $0x802030,%esi
  800094:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	thisenv = (struct Env*)(envs + ENVX(sys_getenvid())); //（为当前进程）初始化全局指针
  80009a:	e8 3d 0b 00 00       	call   800bdc <sys_getenvid>
  80009f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a4:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8000a7:	c1 e0 05             	shl    $0x5,%eax
  8000aa:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000b0:	89 06                	mov    %eax,(%esi)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000b6:	7e 08                	jle    8000c0 <libmain+0x49>
		binaryname = argv[0];
  8000b8:	8b 07                	mov    (%edi),%eax
  8000ba:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000c0:	83 ec 08             	sub    $0x8,%esp
  8000c3:	57                   	push   %edi
  8000c4:	ff 75 08             	pushl  0x8(%ebp)
  8000c7:	e8 67 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000cc:	e8 0b 00 00 00       	call   8000dc <exit>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	53                   	push   %ebx
  8000e0:	83 ec 10             	sub    $0x10,%esp
  8000e3:	e8 8b ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8000e8:	81 c3 18 1f 00 00    	add    $0x1f18,%ebx
	sys_env_destroy(0);
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 92 0a 00 00       	call   800b87 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	e8 6c ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800107:	81 c3 f9 1e 00 00    	add    $0x1ef9,%ebx
  80010d:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800110:	8b 16                	mov    (%esi),%edx
  800112:	8d 42 01             	lea    0x1(%edx),%eax
  800115:	89 06                	mov    %eax,(%esi)
  800117:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011a:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  80011e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800123:	74 0b                	je     800130 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800125:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800129:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5d                   	pop    %ebp
  80012f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	68 ff 00 00 00       	push   $0xff
  800138:	8d 46 08             	lea    0x8(%esi),%eax
  80013b:	50                   	push   %eax
  80013c:	e8 09 0a 00 00       	call   800b4a <sys_cputs>
		b->idx = 0;
  800141:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	eb d9                	jmp    800125 <putch+0x28>

0080014c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	53                   	push   %ebx
  800150:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800156:	e8 18 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  80015b:	81 c3 a5 1e 00 00    	add    $0x1ea5,%ebx
	struct printbuf b;

	b.idx = 0;
  800161:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800168:	00 00 00 
	b.cnt = 0;
  80016b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800172:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800175:	ff 75 0c             	pushl  0xc(%ebp)
  800178:	ff 75 08             	pushl  0x8(%ebp)
  80017b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	8d 83 fd e0 ff ff    	lea    -0x1f03(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 38 01 00 00       	call   8002c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018e:	83 c4 08             	add    $0x8,%esp
  800191:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800197:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019d:	50                   	push   %eax
  80019e:	e8 a7 09 00 00       	call   800b4a <sys_cputs>

	return b.cnt;
}
  8001a3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ac:	c9                   	leave  
  8001ad:	c3                   	ret    

008001ae <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b7:	50                   	push   %eax
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	e8 8c ff ff ff       	call   80014c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    

008001c2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	57                   	push   %edi
  8001c6:	56                   	push   %esi
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 2c             	sub    $0x2c,%esp
  8001cb:	e8 02 06 00 00       	call   8007d2 <__x86.get_pc_thunk.cx>
  8001d0:	81 c1 30 1e 00 00    	add    $0x1e30,%ecx
  8001d6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001d9:	89 c7                	mov    %eax,%edi
  8001db:	89 d6                	mov    %edx,%esi
  8001dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001f4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001f7:	39 d3                	cmp    %edx,%ebx
  8001f9:	72 09                	jb     800204 <printnum+0x42>
  8001fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fe:	0f 87 83 00 00 00    	ja     800287 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800204:	83 ec 0c             	sub    $0xc,%esp
  800207:	ff 75 18             	pushl  0x18(%ebp)
  80020a:	8b 45 14             	mov    0x14(%ebp),%eax
  80020d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	83 ec 08             	sub    $0x8,%esp
  800217:	ff 75 dc             	pushl  -0x24(%ebp)
  80021a:	ff 75 d8             	pushl  -0x28(%ebp)
  80021d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800220:	ff 75 d0             	pushl  -0x30(%ebp)
  800223:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800226:	e8 35 0a 00 00       	call   800c60 <__udivdi3>
  80022b:	83 c4 18             	add    $0x18,%esp
  80022e:	52                   	push   %edx
  80022f:	50                   	push   %eax
  800230:	89 f2                	mov    %esi,%edx
  800232:	89 f8                	mov    %edi,%eax
  800234:	e8 89 ff ff ff       	call   8001c2 <printnum>
  800239:	83 c4 20             	add    $0x20,%esp
  80023c:	eb 13                	jmp    800251 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023e:	83 ec 08             	sub    $0x8,%esp
  800241:	56                   	push   %esi
  800242:	ff 75 18             	pushl  0x18(%ebp)
  800245:	ff d7                	call   *%edi
  800247:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80024a:	83 eb 01             	sub    $0x1,%ebx
  80024d:	85 db                	test   %ebx,%ebx
  80024f:	7f ed                	jg     80023e <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	56                   	push   %esi
  800255:	83 ec 04             	sub    $0x4,%esp
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800261:	ff 75 d0             	pushl  -0x30(%ebp)
  800264:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800267:	89 f3                	mov    %esi,%ebx
  800269:	e8 12 0b 00 00       	call   800d80 <__umoddi3>
  80026e:	83 c4 14             	add    $0x14,%esp
  800271:	0f be 84 06 b4 ee ff 	movsbl -0x114c(%esi,%eax,1),%eax
  800278:	ff 
  800279:	50                   	push   %eax
  80027a:	ff d7                	call   *%edi
}
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800282:	5b                   	pop    %ebx
  800283:	5e                   	pop    %esi
  800284:	5f                   	pop    %edi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    
  800287:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028a:	eb be                	jmp    80024a <printnum+0x88>

0080028c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800292:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800296:	8b 10                	mov    (%eax),%edx
  800298:	3b 50 04             	cmp    0x4(%eax),%edx
  80029b:	73 0a                	jae    8002a7 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029d:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	88 02                	mov    %al,(%edx)
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <printfmt>:
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002af:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b2:	50                   	push   %eax
  8002b3:	ff 75 10             	pushl  0x10(%ebp)
  8002b6:	ff 75 0c             	pushl  0xc(%ebp)
  8002b9:	ff 75 08             	pushl  0x8(%ebp)
  8002bc:	e8 05 00 00 00       	call   8002c6 <vprintfmt>
}
  8002c1:	83 c4 10             	add    $0x10,%esp
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <vprintfmt>:
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 2c             	sub    $0x2c,%esp
  8002cf:	e8 9f fd ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8002d4:	81 c3 2c 1d 00 00    	add    $0x1d2c,%ebx
  8002da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002dd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e0:	e9 c3 03 00 00       	jmp    8006a8 <.L35+0x48>
		padc = ' ';
  8002e5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002f0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800303:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8d 47 01             	lea    0x1(%edi),%eax
  800309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030c:	0f b6 17             	movzbl (%edi),%edx
  80030f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800312:	3c 55                	cmp    $0x55,%al
  800314:	0f 87 16 04 00 00    	ja     800730 <.L22>
  80031a:	0f b6 c0             	movzbl %al,%eax
  80031d:	89 d9                	mov    %ebx,%ecx
  80031f:	03 8c 83 44 ef ff ff 	add    -0x10bc(%ebx,%eax,4),%ecx
  800326:	ff e1                	jmp    *%ecx

00800328 <.L69>:
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80032b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80032f:	eb d5                	jmp    800306 <vprintfmt+0x40>

00800331 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800334:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800338:	eb cc                	jmp    800306 <vprintfmt+0x40>

0080033a <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 d2             	movzbl %dl,%edx
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800340:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800345:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800348:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80034c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80034f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800352:	83 f9 09             	cmp    $0x9,%ecx
  800355:	77 55                	ja     8003ac <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800357:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80035a:	eb e9                	jmp    800345 <.L29+0xb>

0080035c <.L26>:
			precision = va_arg(ap, int);
  80035c:	8b 45 14             	mov    0x14(%ebp),%eax
  80035f:	8b 00                	mov    (%eax),%eax
  800361:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800364:	8b 45 14             	mov    0x14(%ebp),%eax
  800367:	8d 40 04             	lea    0x4(%eax),%eax
  80036a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800370:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800374:	79 90                	jns    800306 <vprintfmt+0x40>
				width = precision, precision = -1;
  800376:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800379:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800383:	eb 81                	jmp    800306 <vprintfmt+0x40>

00800385 <.L27>:
  800385:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800388:	85 c0                	test   %eax,%eax
  80038a:	ba 00 00 00 00       	mov    $0x0,%edx
  80038f:	0f 49 d0             	cmovns %eax,%edx
  800392:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800398:	e9 69 ff ff ff       	jmp    800306 <vprintfmt+0x40>

0080039d <.L23>:
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003a0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a7:	e9 5a ff ff ff       	jmp    800306 <vprintfmt+0x40>
  8003ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003af:	eb bf                	jmp    800370 <.L26+0x14>

008003b1 <.L33>:
			lflag++;
  8003b1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b8:	e9 49 ff ff ff       	jmp    800306 <vprintfmt+0x40>

008003bd <.L30>:
			putch(va_arg(ap, int), putdat);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 78 04             	lea    0x4(%eax),%edi
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	56                   	push   %esi
  8003c7:	ff 30                	pushl  (%eax)
  8003c9:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003cc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003cf:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d2:	e9 ce 02 00 00       	jmp    8006a5 <.L35+0x45>

008003d7 <.L32>:
			err = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 78 04             	lea    0x4(%eax),%edi
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	99                   	cltd   
  8003e0:	31 d0                	xor    %edx,%eax
  8003e2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e4:	83 f8 06             	cmp    $0x6,%eax
  8003e7:	7f 27                	jg     800410 <.L32+0x39>
  8003e9:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003f0:	85 d2                	test   %edx,%edx
  8003f2:	74 1c                	je     800410 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003f4:	52                   	push   %edx
  8003f5:	8d 83 d5 ee ff ff    	lea    -0x112b(%ebx),%eax
  8003fb:	50                   	push   %eax
  8003fc:	56                   	push   %esi
  8003fd:	ff 75 08             	pushl  0x8(%ebp)
  800400:	e8 a4 fe ff ff       	call   8002a9 <printfmt>
  800405:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800408:	89 7d 14             	mov    %edi,0x14(%ebp)
  80040b:	e9 95 02 00 00       	jmp    8006a5 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800410:	50                   	push   %eax
  800411:	8d 83 cc ee ff ff    	lea    -0x1134(%ebx),%eax
  800417:	50                   	push   %eax
  800418:	56                   	push   %esi
  800419:	ff 75 08             	pushl  0x8(%ebp)
  80041c:	e8 88 fe ff ff       	call   8002a9 <printfmt>
  800421:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800424:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800427:	e9 79 02 00 00       	jmp    8006a5 <.L35+0x45>

0080042c <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	83 c0 04             	add    $0x4,%eax
  800432:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80043a:	85 ff                	test   %edi,%edi
  80043c:	8d 83 c5 ee ff ff    	lea    -0x113b(%ebx),%eax
  800442:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800445:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800449:	0f 8e b5 00 00 00    	jle    800504 <.L36+0xd8>
  80044f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800453:	75 08                	jne    80045d <.L36+0x31>
  800455:	89 75 0c             	mov    %esi,0xc(%ebp)
  800458:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80045b:	eb 6d                	jmp    8004ca <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	ff 75 cc             	pushl  -0x34(%ebp)
  800463:	57                   	push   %edi
  800464:	e8 85 03 00 00       	call   8007ee <strnlen>
  800469:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80046c:	29 c2                	sub    %eax,%edx
  80046e:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800471:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800474:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800478:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047e:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800480:	eb 10                	jmp    800492 <.L36+0x66>
					putch(padc, putdat);
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	56                   	push   %esi
  800486:	ff 75 e0             	pushl  -0x20(%ebp)
  800489:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	83 ef 01             	sub    $0x1,%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 ff                	test   %edi,%edi
  800494:	7f ec                	jg     800482 <.L36+0x56>
  800496:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800499:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80049c:	85 d2                	test   %edx,%edx
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	0f 49 c2             	cmovns %edx,%eax
  8004a6:	29 c2                	sub    %eax,%edx
  8004a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ab:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004ae:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004b1:	eb 17                	jmp    8004ca <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b7:	75 30                	jne    8004e9 <.L36+0xbd>
					putch(ch, putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 0c             	pushl  0xc(%ebp)
  8004bf:	50                   	push   %eax
  8004c0:	ff 55 08             	call   *0x8(%ebp)
  8004c3:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c6:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004ca:	83 c7 01             	add    $0x1,%edi
  8004cd:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004d1:	0f be c2             	movsbl %dl,%eax
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	74 52                	je     80052a <.L36+0xfe>
  8004d8:	85 f6                	test   %esi,%esi
  8004da:	78 d7                	js     8004b3 <.L36+0x87>
  8004dc:	83 ee 01             	sub    $0x1,%esi
  8004df:	79 d2                	jns    8004b3 <.L36+0x87>
  8004e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004e4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e7:	eb 32                	jmp    80051b <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e9:	0f be d2             	movsbl %dl,%edx
  8004ec:	83 ea 20             	sub    $0x20,%edx
  8004ef:	83 fa 5e             	cmp    $0x5e,%edx
  8004f2:	76 c5                	jbe    8004b9 <.L36+0x8d>
					putch('?', putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	ff 75 0c             	pushl  0xc(%ebp)
  8004fa:	6a 3f                	push   $0x3f
  8004fc:	ff 55 08             	call   *0x8(%ebp)
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	eb c2                	jmp    8004c6 <.L36+0x9a>
  800504:	89 75 0c             	mov    %esi,0xc(%ebp)
  800507:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80050a:	eb be                	jmp    8004ca <.L36+0x9e>
				putch(' ', putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	56                   	push   %esi
  800510:	6a 20                	push   $0x20
  800512:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ed                	jg     80050c <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800522:	89 45 14             	mov    %eax,0x14(%ebp)
  800525:	e9 7b 01 00 00       	jmp    8006a5 <.L35+0x45>
  80052a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80052d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800530:	eb e9                	jmp    80051b <.L36+0xef>

00800532 <.L31>:
  800532:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800535:	83 f9 01             	cmp    $0x1,%ecx
  800538:	7e 40                	jle    80057a <.L31+0x48>
		return va_arg(*ap, long long);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8b 50 04             	mov    0x4(%eax),%edx
  800540:	8b 00                	mov    (%eax),%eax
  800542:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800545:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 40 08             	lea    0x8(%eax),%eax
  80054e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800551:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800555:	79 55                	jns    8005ac <.L31+0x7a>
				putch('-', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	56                   	push   %esi
  80055b:	6a 2d                	push   $0x2d
  80055d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800560:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800563:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800566:	f7 da                	neg    %edx
  800568:	83 d1 00             	adc    $0x0,%ecx
  80056b:	f7 d9                	neg    %ecx
  80056d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800570:	b8 0a 00 00 00       	mov    $0xa,%eax
  800575:	e9 10 01 00 00       	jmp    80068a <.L35+0x2a>
	else if (lflag)
  80057a:	85 c9                	test   %ecx,%ecx
  80057c:	75 17                	jne    800595 <.L31+0x63>
		return va_arg(*ap, int);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800586:	99                   	cltd   
  800587:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 40 04             	lea    0x4(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
  800593:	eb bc                	jmp    800551 <.L31+0x1f>
		return va_arg(*ap, long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 00                	mov    (%eax),%eax
  80059a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059d:	99                   	cltd   
  80059e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 40 04             	lea    0x4(%eax),%eax
  8005a7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005aa:	eb a5                	jmp    800551 <.L31+0x1f>
			num = getint(&ap, lflag);
  8005ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005af:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b7:	e9 ce 00 00 00       	jmp    80068a <.L35+0x2a>

008005bc <.L37>:
  8005bc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005bf:	83 f9 01             	cmp    $0x1,%ecx
  8005c2:	7e 18                	jle    8005dc <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8b 10                	mov    (%eax),%edx
  8005c9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005cc:	8d 40 08             	lea    0x8(%eax),%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d7:	e9 ae 00 00 00       	jmp    80068a <.L35+0x2a>
	else if (lflag)
  8005dc:	85 c9                	test   %ecx,%ecx
  8005de:	75 1a                	jne    8005fa <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ea:	8d 40 04             	lea    0x4(%eax),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f5:	e9 90 00 00 00       	jmp    80068a <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8b 10                	mov    (%eax),%edx
  8005ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800604:	8d 40 04             	lea    0x4(%eax),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060f:	eb 79                	jmp    80068a <.L35+0x2a>

00800611 <.L34>:
  800611:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800614:	83 f9 01             	cmp    $0x1,%ecx
  800617:	7e 15                	jle    80062e <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8b 10                	mov    (%eax),%edx
  80061e:	8b 48 04             	mov    0x4(%eax),%ecx
  800621:	8d 40 08             	lea    0x8(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800627:	b8 08 00 00 00       	mov    $0x8,%eax
  80062c:	eb 5c                	jmp    80068a <.L35+0x2a>
	else if (lflag)
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	75 17                	jne    800649 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800642:	b8 08 00 00 00       	mov    $0x8,%eax
  800647:	eb 41                	jmp    80068a <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800659:	b8 08 00 00 00       	mov    $0x8,%eax
  80065e:	eb 2a                	jmp    80068a <.L35+0x2a>

00800660 <.L35>:
			putch('0', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	56                   	push   %esi
  800664:	6a 30                	push   $0x30
  800666:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800669:	83 c4 08             	add    $0x8,%esp
  80066c:	56                   	push   %esi
  80066d:	6a 78                	push   $0x78
  80066f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 10                	mov    (%eax),%edx
  800677:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80067c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80067f:	8d 40 04             	lea    0x4(%eax),%eax
  800682:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800685:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80068a:	83 ec 0c             	sub    $0xc,%esp
  80068d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800691:	57                   	push   %edi
  800692:	ff 75 e0             	pushl  -0x20(%ebp)
  800695:	50                   	push   %eax
  800696:	51                   	push   %ecx
  800697:	52                   	push   %edx
  800698:	89 f2                	mov    %esi,%edx
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	e8 20 fb ff ff       	call   8001c2 <printnum>
			break;
  8006a2:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a8:	83 c7 01             	add    $0x1,%edi
  8006ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006af:	83 f8 25             	cmp    $0x25,%eax
  8006b2:	0f 84 2d fc ff ff    	je     8002e5 <vprintfmt+0x1f>
			if (ch == '\0')
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	0f 84 91 00 00 00    	je     800751 <.L22+0x21>
			putch(ch, putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	56                   	push   %esi
  8006c4:	50                   	push   %eax
  8006c5:	ff 55 08             	call   *0x8(%ebp)
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	eb db                	jmp    8006a8 <.L35+0x48>

008006cd <.L38>:
  8006cd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006d0:	83 f9 01             	cmp    $0x1,%ecx
  8006d3:	7e 15                	jle    8006ea <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	8b 48 04             	mov    0x4(%eax),%ecx
  8006dd:	8d 40 08             	lea    0x8(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e8:	eb a0                	jmp    80068a <.L35+0x2a>
	else if (lflag)
  8006ea:	85 c9                	test   %ecx,%ecx
  8006ec:	75 17                	jne    800705 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f8:	8d 40 04             	lea    0x4(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fe:	b8 10 00 00 00       	mov    $0x10,%eax
  800703:	eb 85                	jmp    80068a <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070f:	8d 40 04             	lea    0x4(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800715:	b8 10 00 00 00       	mov    $0x10,%eax
  80071a:	e9 6b ff ff ff       	jmp    80068a <.L35+0x2a>

0080071f <.L25>:
			putch(ch, putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	56                   	push   %esi
  800723:	6a 25                	push   $0x25
  800725:	ff 55 08             	call   *0x8(%ebp)
			break;
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	e9 75 ff ff ff       	jmp    8006a5 <.L35+0x45>

00800730 <.L22>:
			putch('%', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	56                   	push   %esi
  800734:	6a 25                	push   $0x25
  800736:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	89 f8                	mov    %edi,%eax
  80073e:	eb 03                	jmp    800743 <.L22+0x13>
  800740:	83 e8 01             	sub    $0x1,%eax
  800743:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800747:	75 f7                	jne    800740 <.L22+0x10>
  800749:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074c:	e9 54 ff ff ff       	jmp    8006a5 <.L35+0x45>
}
  800751:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800754:	5b                   	pop    %ebx
  800755:	5e                   	pop    %esi
  800756:	5f                   	pop    %edi
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	83 ec 14             	sub    $0x14,%esp
  800760:	e8 0e f9 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800765:	81 c3 9b 18 00 00    	add    $0x189b,%ebx
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800771:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800774:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800778:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800782:	85 c0                	test   %eax,%eax
  800784:	74 2b                	je     8007b1 <vsnprintf+0x58>
  800786:	85 d2                	test   %edx,%edx
  800788:	7e 27                	jle    8007b1 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078a:	ff 75 14             	pushl  0x14(%ebp)
  80078d:	ff 75 10             	pushl  0x10(%ebp)
  800790:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800793:	50                   	push   %eax
  800794:	8d 83 8c e2 ff ff    	lea    -0x1d74(%ebx),%eax
  80079a:	50                   	push   %eax
  80079b:	e8 26 fb ff ff       	call   8002c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a9:	83 c4 10             	add    $0x10,%esp
}
  8007ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    
		return -E_INVAL;
  8007b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b6:	eb f4                	jmp    8007ac <vsnprintf+0x53>

008007b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c1:	50                   	push   %eax
  8007c2:	ff 75 10             	pushl  0x10(%ebp)
  8007c5:	ff 75 0c             	pushl  0xc(%ebp)
  8007c8:	ff 75 08             	pushl  0x8(%ebp)
  8007cb:	e8 89 ff ff ff       	call   800759 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <__x86.get_pc_thunk.cx>:
  8007d2:	8b 0c 24             	mov    (%esp),%ecx
  8007d5:	c3                   	ret    

008007d6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 03                	jmp    8007e6 <strlen+0x10>
		n++;
  8007e3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ea:	75 f7                	jne    8007e3 <strlen+0xd>
	return n;
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	eb 03                	jmp    800801 <strnlen+0x13>
		n++;
  8007fe:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800801:	39 d0                	cmp    %edx,%eax
  800803:	74 06                	je     80080b <strnlen+0x1d>
  800805:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800809:	75 f3                	jne    8007fe <strnlen+0x10>
	return n;
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	53                   	push   %ebx
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800817:	89 c2                	mov    %eax,%edx
  800819:	83 c1 01             	add    $0x1,%ecx
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800823:	88 5a ff             	mov    %bl,-0x1(%edx)
  800826:	84 db                	test   %bl,%bl
  800828:	75 ef                	jne    800819 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082a:	5b                   	pop    %ebx
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	53                   	push   %ebx
  800831:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800834:	53                   	push   %ebx
  800835:	e8 9c ff ff ff       	call   8007d6 <strlen>
  80083a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083d:	ff 75 0c             	pushl  0xc(%ebp)
  800840:	01 d8                	add    %ebx,%eax
  800842:	50                   	push   %eax
  800843:	e8 c5 ff ff ff       	call   80080d <strcpy>
	return dst;
}
  800848:	89 d8                	mov    %ebx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	8b 75 08             	mov    0x8(%ebp),%esi
  800857:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085a:	89 f3                	mov    %esi,%ebx
  80085c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085f:	89 f2                	mov    %esi,%edx
  800861:	eb 0f                	jmp    800872 <strncpy+0x23>
		*dst++ = *src;
  800863:	83 c2 01             	add    $0x1,%edx
  800866:	0f b6 01             	movzbl (%ecx),%eax
  800869:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086c:	80 39 01             	cmpb   $0x1,(%ecx)
  80086f:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800872:	39 da                	cmp    %ebx,%edx
  800874:	75 ed                	jne    800863 <strncpy+0x14>
	}
	return ret;
}
  800876:	89 f0                	mov    %esi,%eax
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
  800887:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088a:	89 f0                	mov    %esi,%eax
  80088c:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	85 c9                	test   %ecx,%ecx
  800892:	75 0b                	jne    80089f <strlcpy+0x23>
  800894:	eb 17                	jmp    8008ad <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80089f:	39 d8                	cmp    %ebx,%eax
  8008a1:	74 07                	je     8008aa <strlcpy+0x2e>
  8008a3:	0f b6 0a             	movzbl (%edx),%ecx
  8008a6:	84 c9                	test   %cl,%cl
  8008a8:	75 ec                	jne    800896 <strlcpy+0x1a>
		*dst = '\0';
  8008aa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ad:	29 f0                	sub    %esi,%eax
}
  8008af:	5b                   	pop    %ebx
  8008b0:	5e                   	pop    %esi
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bc:	eb 06                	jmp    8008c4 <strcmp+0x11>
		p++, q++;
  8008be:	83 c1 01             	add    $0x1,%ecx
  8008c1:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008c4:	0f b6 01             	movzbl (%ecx),%eax
  8008c7:	84 c0                	test   %al,%al
  8008c9:	74 04                	je     8008cf <strcmp+0x1c>
  8008cb:	3a 02                	cmp    (%edx),%al
  8008cd:	74 ef                	je     8008be <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cf:	0f b6 c0             	movzbl %al,%eax
  8008d2:	0f b6 12             	movzbl (%edx),%edx
  8008d5:	29 d0                	sub    %edx,%eax
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	53                   	push   %ebx
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e3:	89 c3                	mov    %eax,%ebx
  8008e5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e8:	eb 06                	jmp    8008f0 <strncmp+0x17>
		n--, p++, q++;
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f0:	39 d8                	cmp    %ebx,%eax
  8008f2:	74 16                	je     80090a <strncmp+0x31>
  8008f4:	0f b6 08             	movzbl (%eax),%ecx
  8008f7:	84 c9                	test   %cl,%cl
  8008f9:	74 04                	je     8008ff <strncmp+0x26>
  8008fb:	3a 0a                	cmp    (%edx),%cl
  8008fd:	74 eb                	je     8008ea <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ff:	0f b6 00             	movzbl (%eax),%eax
  800902:	0f b6 12             	movzbl (%edx),%edx
  800905:	29 d0                	sub    %edx,%eax
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    
		return 0;
  80090a:	b8 00 00 00 00       	mov    $0x0,%eax
  80090f:	eb f6                	jmp    800907 <strncmp+0x2e>

00800911 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091b:	0f b6 10             	movzbl (%eax),%edx
  80091e:	84 d2                	test   %dl,%dl
  800920:	74 09                	je     80092b <strchr+0x1a>
		if (*s == c)
  800922:	38 ca                	cmp    %cl,%dl
  800924:	74 0a                	je     800930 <strchr+0x1f>
	for (; *s; s++)
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	eb f0                	jmp    80091b <strchr+0xa>
			return (char *) s;
	return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093c:	eb 03                	jmp    800941 <strfind+0xf>
  80093e:	83 c0 01             	add    $0x1,%eax
  800941:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800944:	38 ca                	cmp    %cl,%dl
  800946:	74 04                	je     80094c <strfind+0x1a>
  800948:	84 d2                	test   %dl,%dl
  80094a:	75 f2                	jne    80093e <strfind+0xc>
			break;
	return (char *) s;
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	57                   	push   %edi
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	8b 7d 08             	mov    0x8(%ebp),%edi
  800957:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095a:	85 c9                	test   %ecx,%ecx
  80095c:	74 13                	je     800971 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800964:	75 05                	jne    80096b <memset+0x1d>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	74 0d                	je     800978 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096e:	fc                   	cld    
  80096f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800971:	89 f8                	mov    %edi,%eax
  800973:	5b                   	pop    %ebx
  800974:	5e                   	pop    %esi
  800975:	5f                   	pop    %edi
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    
		c &= 0xFF;
  800978:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097c:	89 d3                	mov    %edx,%ebx
  80097e:	c1 e3 08             	shl    $0x8,%ebx
  800981:	89 d0                	mov    %edx,%eax
  800983:	c1 e0 18             	shl    $0x18,%eax
  800986:	89 d6                	mov    %edx,%esi
  800988:	c1 e6 10             	shl    $0x10,%esi
  80098b:	09 f0                	or     %esi,%eax
  80098d:	09 c2                	or     %eax,%edx
  80098f:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800991:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800994:	89 d0                	mov    %edx,%eax
  800996:	fc                   	cld    
  800997:	f3 ab                	rep stos %eax,%es:(%edi)
  800999:	eb d6                	jmp    800971 <memset+0x23>

0080099b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	57                   	push   %edi
  80099f:	56                   	push   %esi
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a9:	39 c6                	cmp    %eax,%esi
  8009ab:	73 35                	jae    8009e2 <memmove+0x47>
  8009ad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b0:	39 c2                	cmp    %eax,%edx
  8009b2:	76 2e                	jbe    8009e2 <memmove+0x47>
		s += n;
		d += n;
  8009b4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b7:	89 d6                	mov    %edx,%esi
  8009b9:	09 fe                	or     %edi,%esi
  8009bb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c1:	74 0c                	je     8009cf <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c3:	83 ef 01             	sub    $0x1,%edi
  8009c6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c9:	fd                   	std    
  8009ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cc:	fc                   	cld    
  8009cd:	eb 21                	jmp    8009f0 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	f6 c1 03             	test   $0x3,%cl
  8009d2:	75 ef                	jne    8009c3 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d4:	83 ef 04             	sub    $0x4,%edi
  8009d7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009da:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009dd:	fd                   	std    
  8009de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e0:	eb ea                	jmp    8009cc <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e2:	89 f2                	mov    %esi,%edx
  8009e4:	09 c2                	or     %eax,%edx
  8009e6:	f6 c2 03             	test   $0x3,%dl
  8009e9:	74 09                	je     8009f4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009eb:	89 c7                	mov    %eax,%edi
  8009ed:	fc                   	cld    
  8009ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f4:	f6 c1 03             	test   $0x3,%cl
  8009f7:	75 f2                	jne    8009eb <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009fc:	89 c7                	mov    %eax,%edi
  8009fe:	fc                   	cld    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb ed                	jmp    8009f0 <memmove+0x55>

00800a03 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a06:	ff 75 10             	pushl  0x10(%ebp)
  800a09:	ff 75 0c             	pushl  0xc(%ebp)
  800a0c:	ff 75 08             	pushl  0x8(%ebp)
  800a0f:	e8 87 ff ff ff       	call   80099b <memmove>
}
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    

00800a16 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a21:	89 c6                	mov    %eax,%esi
  800a23:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a26:	39 f0                	cmp    %esi,%eax
  800a28:	74 1c                	je     800a46 <memcmp+0x30>
		if (*s1 != *s2)
  800a2a:	0f b6 08             	movzbl (%eax),%ecx
  800a2d:	0f b6 1a             	movzbl (%edx),%ebx
  800a30:	38 d9                	cmp    %bl,%cl
  800a32:	75 08                	jne    800a3c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a34:	83 c0 01             	add    $0x1,%eax
  800a37:	83 c2 01             	add    $0x1,%edx
  800a3a:	eb ea                	jmp    800a26 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a3c:	0f b6 c1             	movzbl %cl,%eax
  800a3f:	0f b6 db             	movzbl %bl,%ebx
  800a42:	29 d8                	sub    %ebx,%eax
  800a44:	eb 05                	jmp    800a4b <memcmp+0x35>
	}

	return 0;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a58:	89 c2                	mov    %eax,%edx
  800a5a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5d:	39 d0                	cmp    %edx,%eax
  800a5f:	73 09                	jae    800a6a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	38 08                	cmp    %cl,(%eax)
  800a63:	74 05                	je     800a6a <memfind+0x1b>
	for (; s < ends; s++)
  800a65:	83 c0 01             	add    $0x1,%eax
  800a68:	eb f3                	jmp    800a5d <memfind+0xe>
			break;
	return (void *) s;
}
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a78:	eb 03                	jmp    800a7d <strtol+0x11>
		s++;
  800a7a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a7d:	0f b6 01             	movzbl (%ecx),%eax
  800a80:	3c 20                	cmp    $0x20,%al
  800a82:	74 f6                	je     800a7a <strtol+0xe>
  800a84:	3c 09                	cmp    $0x9,%al
  800a86:	74 f2                	je     800a7a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a88:	3c 2b                	cmp    $0x2b,%al
  800a8a:	74 2e                	je     800aba <strtol+0x4e>
	int neg = 0;
  800a8c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a91:	3c 2d                	cmp    $0x2d,%al
  800a93:	74 2f                	je     800ac4 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a95:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9b:	75 05                	jne    800aa2 <strtol+0x36>
  800a9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa0:	74 2c                	je     800ace <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	75 0a                	jne    800ab0 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa6:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aab:	80 39 30             	cmpb   $0x30,(%ecx)
  800aae:	74 28                	je     800ad8 <strtol+0x6c>
		base = 10;
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab8:	eb 50                	jmp    800b0a <strtol+0x9e>
		s++;
  800aba:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac2:	eb d1                	jmp    800a95 <strtol+0x29>
		s++, neg = 1;
  800ac4:	83 c1 01             	add    $0x1,%ecx
  800ac7:	bf 01 00 00 00       	mov    $0x1,%edi
  800acc:	eb c7                	jmp    800a95 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ace:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad2:	74 0e                	je     800ae2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ad4:	85 db                	test   %ebx,%ebx
  800ad6:	75 d8                	jne    800ab0 <strtol+0x44>
		s++, base = 8;
  800ad8:	83 c1 01             	add    $0x1,%ecx
  800adb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ae0:	eb ce                	jmp    800ab0 <strtol+0x44>
		s += 2, base = 16;
  800ae2:	83 c1 02             	add    $0x2,%ecx
  800ae5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aea:	eb c4                	jmp    800ab0 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aec:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aef:	89 f3                	mov    %esi,%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 29                	ja     800b1f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800af6:	0f be d2             	movsbl %dl,%edx
  800af9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800afc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aff:	7d 30                	jge    800b31 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b01:	83 c1 01             	add    $0x1,%ecx
  800b04:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b08:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b0a:	0f b6 11             	movzbl (%ecx),%edx
  800b0d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b10:	89 f3                	mov    %esi,%ebx
  800b12:	80 fb 09             	cmp    $0x9,%bl
  800b15:	77 d5                	ja     800aec <strtol+0x80>
			dig = *s - '0';
  800b17:	0f be d2             	movsbl %dl,%edx
  800b1a:	83 ea 30             	sub    $0x30,%edx
  800b1d:	eb dd                	jmp    800afc <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b1f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b22:	89 f3                	mov    %esi,%ebx
  800b24:	80 fb 19             	cmp    $0x19,%bl
  800b27:	77 08                	ja     800b31 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b29:	0f be d2             	movsbl %dl,%edx
  800b2c:	83 ea 37             	sub    $0x37,%edx
  800b2f:	eb cb                	jmp    800afc <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b35:	74 05                	je     800b3c <strtol+0xd0>
		*endptr = (char *) s;
  800b37:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b3c:	89 c2                	mov    %eax,%edx
  800b3e:	f7 da                	neg    %edx
  800b40:	85 ff                	test   %edi,%edi
  800b42:	0f 45 c2             	cmovne %edx,%eax
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b50:	b8 00 00 00 00       	mov    $0x0,%eax
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5b:	89 c3                	mov    %eax,%ebx
  800b5d:	89 c7                	mov    %eax,%edi
  800b5f:	89 c6                	mov    %eax,%esi
  800b61:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	b8 01 00 00 00       	mov    $0x1,%eax
  800b78:	89 d1                	mov    %edx,%ecx
  800b7a:	89 d3                	mov    %edx,%ebx
  800b7c:	89 d7                	mov    %edx,%edi
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
  800b8d:	83 ec 1c             	sub    $0x1c,%esp
  800b90:	e8 66 00 00 00       	call   800bfb <__x86.get_pc_thunk.ax>
  800b95:	05 6b 14 00 00       	add    $0x146b,%eax
  800b9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	b8 03 00 00 00       	mov    $0x3,%eax
  800baa:	89 cb                	mov    %ecx,%ebx
  800bac:	89 cf                	mov    %ecx,%edi
  800bae:	89 ce                	mov    %ecx,%esi
  800bb0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bb2:	85 c0                	test   %eax,%eax
  800bb4:	7f 08                	jg     800bbe <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	50                   	push   %eax
  800bc2:	6a 03                	push   $0x3
  800bc4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bc7:	8d 83 9c f0 ff ff    	lea    -0xf64(%ebx),%eax
  800bcd:	50                   	push   %eax
  800bce:	6a 23                	push   $0x23
  800bd0:	8d 83 b9 f0 ff ff    	lea    -0xf47(%ebx),%eax
  800bd6:	50                   	push   %eax
  800bd7:	e8 23 00 00 00       	call   800bff <_panic>

00800bdc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be2:	ba 00 00 00 00       	mov    $0x0,%edx
  800be7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bec:	89 d1                	mov    %edx,%ecx
  800bee:	89 d3                	mov    %edx,%ebx
  800bf0:	89 d7                	mov    %edx,%edi
  800bf2:	89 d6                	mov    %edx,%esi
  800bf4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <__x86.get_pc_thunk.ax>:
  800bfb:	8b 04 24             	mov    (%esp),%eax
  800bfe:	c3                   	ret    

00800bff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	e8 66 f4 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800c0d:	81 c3 f3 13 00 00    	add    $0x13f3,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c13:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c16:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c1c:	8b 38                	mov    (%eax),%edi
  800c1e:	e8 b9 ff ff ff       	call   800bdc <sys_getenvid>
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	ff 75 0c             	pushl  0xc(%ebp)
  800c29:	ff 75 08             	pushl  0x8(%ebp)
  800c2c:	57                   	push   %edi
  800c2d:	50                   	push   %eax
  800c2e:	8d 83 c8 f0 ff ff    	lea    -0xf38(%ebx),%eax
  800c34:	50                   	push   %eax
  800c35:	e8 74 f5 ff ff       	call   8001ae <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c3a:	83 c4 18             	add    $0x18,%esp
  800c3d:	56                   	push   %esi
  800c3e:	ff 75 10             	pushl  0x10(%ebp)
  800c41:	e8 06 f5 ff ff       	call   80014c <vcprintf>
	cprintf("\n");
  800c46:	8d 83 a8 ee ff ff    	lea    -0x1158(%ebx),%eax
  800c4c:	89 04 24             	mov    %eax,(%esp)
  800c4f:	e8 5a f5 ff ff       	call   8001ae <cprintf>
  800c54:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c57:	cc                   	int3   
  800c58:	eb fd                	jmp    800c57 <_panic+0x58>
  800c5a:	66 90                	xchg   %ax,%ax
  800c5c:	66 90                	xchg   %ax,%ax
  800c5e:	66 90                	xchg   %ax,%ax

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
