
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
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
  80003a:	e8 20 00 00 00       	call   80005f <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800045:	ff 35 00 00 00 00    	pushl  0x0
  80004b:	8d 83 8c ee ff ff    	lea    -0x1174(%ebx),%eax
  800051:	50                   	push   %eax
  800052:	e8 43 01 00 00       	call   80019a <cprintf>
}
  800057:	83 c4 10             	add    $0x10,%esp
  80005a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <__x86.get_pc_thunk.bx>:
  80005f:	8b 1c 24             	mov    (%esp),%ebx
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	57                   	push   %edi
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 0c             	sub    $0xc,%esp
  80006c:	e8 ee ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800071:	81 c3 8f 1f 00 00    	add    $0x1f8f,%ebx
  800077:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80007a:	c7 c6 2c 20 80 00    	mov    $0x80202c,%esi
  800080:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	thisenv = (struct Env*)(envs + ENVX(sys_getenvid())); //（为当前进程）初始化全局指针
  800086:	e8 3d 0b 00 00       	call   800bc8 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800093:	c1 e0 05             	shl    $0x5,%eax
  800096:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80009c:	89 06                	mov    %eax,(%esi)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000a2:	7e 08                	jle    8000ac <libmain+0x49>
		binaryname = argv[0];
  8000a4:	8b 07                	mov    (%edi),%eax
  8000a6:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000ac:	83 ec 08             	sub    $0x8,%esp
  8000af:	57                   	push   %edi
  8000b0:	ff 75 08             	pushl  0x8(%ebp)
  8000b3:	e8 7b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 10             	sub    $0x10,%esp
  8000cf:	e8 8b ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000d4:	81 c3 2c 1f 00 00    	add    $0x1f2c,%ebx
	sys_env_destroy(0);
  8000da:	6a 00                	push   $0x0
  8000dc:	e8 92 0a 00 00       	call   800b73 <sys_env_destroy>
}
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    

008000e9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
  8000ee:	e8 6c ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000f3:	81 c3 0d 1f 00 00    	add    $0x1f0d,%ebx
  8000f9:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000fc:	8b 16                	mov    (%esi),%edx
  8000fe:	8d 42 01             	lea    0x1(%edx),%eax
  800101:	89 06                	mov    %eax,(%esi)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	74 0b                	je     80011c <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800111:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800115:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80011c:	83 ec 08             	sub    $0x8,%esp
  80011f:	68 ff 00 00 00       	push   $0xff
  800124:	8d 46 08             	lea    0x8(%esi),%eax
  800127:	50                   	push   %eax
  800128:	e8 09 0a 00 00       	call   800b36 <sys_cputs>
		b->idx = 0;
  80012d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	eb d9                	jmp    800111 <putch+0x28>

00800138 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	53                   	push   %ebx
  80013c:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800142:	e8 18 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800147:	81 c3 b9 1e 00 00    	add    $0x1eb9,%ebx
	struct printbuf b;

	b.idx = 0;
  80014d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800154:	00 00 00 
	b.cnt = 0;
  800157:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800161:	ff 75 0c             	pushl  0xc(%ebp)
  800164:	ff 75 08             	pushl  0x8(%ebp)
  800167:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016d:	50                   	push   %eax
  80016e:	8d 83 e9 e0 ff ff    	lea    -0x1f17(%ebx),%eax
  800174:	50                   	push   %eax
  800175:	e8 38 01 00 00       	call   8002b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017a:	83 c4 08             	add    $0x8,%esp
  80017d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800183:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	e8 a7 09 00 00       	call   800b36 <sys_cputs>

	return b.cnt;
}
  80018f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800195:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800198:	c9                   	leave  
  800199:	c3                   	ret    

0080019a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a3:	50                   	push   %eax
  8001a4:	ff 75 08             	pushl  0x8(%ebp)
  8001a7:	e8 8c ff ff ff       	call   800138 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ac:	c9                   	leave  
  8001ad:	c3                   	ret    

008001ae <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	57                   	push   %edi
  8001b2:	56                   	push   %esi
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 2c             	sub    $0x2c,%esp
  8001b7:	e8 02 06 00 00       	call   8007be <__x86.get_pc_thunk.cx>
  8001bc:	81 c1 44 1e 00 00    	add    $0x1e44,%ecx
  8001c2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001e0:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 09                	jb     8001f0 <printnum+0x42>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	0f 87 83 00 00 00    	ja     800273 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f0:	83 ec 0c             	sub    $0xc,%esp
  8001f3:	ff 75 18             	pushl  0x18(%ebp)
  8001f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fc:	53                   	push   %ebx
  8001fd:	ff 75 10             	pushl  0x10(%ebp)
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	ff 75 dc             	pushl  -0x24(%ebp)
  800206:	ff 75 d8             	pushl  -0x28(%ebp)
  800209:	ff 75 d4             	pushl  -0x2c(%ebp)
  80020c:	ff 75 d0             	pushl  -0x30(%ebp)
  80020f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800212:	e8 39 0a 00 00       	call   800c50 <__udivdi3>
  800217:	83 c4 18             	add    $0x18,%esp
  80021a:	52                   	push   %edx
  80021b:	50                   	push   %eax
  80021c:	89 f2                	mov    %esi,%edx
  80021e:	89 f8                	mov    %edi,%eax
  800220:	e8 89 ff ff ff       	call   8001ae <printnum>
  800225:	83 c4 20             	add    $0x20,%esp
  800228:	eb 13                	jmp    80023d <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	56                   	push   %esi
  80022e:	ff 75 18             	pushl  0x18(%ebp)
  800231:	ff d7                	call   *%edi
  800233:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800236:	83 eb 01             	sub    $0x1,%ebx
  800239:	85 db                	test   %ebx,%ebx
  80023b:	7f ed                	jg     80022a <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	56                   	push   %esi
  800241:	83 ec 04             	sub    $0x4,%esp
  800244:	ff 75 dc             	pushl  -0x24(%ebp)
  800247:	ff 75 d8             	pushl  -0x28(%ebp)
  80024a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80024d:	ff 75 d0             	pushl  -0x30(%ebp)
  800250:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800253:	89 f3                	mov    %esi,%ebx
  800255:	e8 16 0b 00 00       	call   800d70 <__umoddi3>
  80025a:	83 c4 14             	add    $0x14,%esp
  80025d:	0f be 84 06 b4 ee ff 	movsbl -0x114c(%esi,%eax,1),%eax
  800264:	ff 
  800265:	50                   	push   %eax
  800266:	ff d7                	call   *%edi
}
  800268:	83 c4 10             	add    $0x10,%esp
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
  800273:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800276:	eb be                	jmp    800236 <printnum+0x88>

00800278 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800282:	8b 10                	mov    (%eax),%edx
  800284:	3b 50 04             	cmp    0x4(%eax),%edx
  800287:	73 0a                	jae    800293 <sprintputch+0x1b>
		*b->buf++ = ch;
  800289:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028c:	89 08                	mov    %ecx,(%eax)
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	88 02                	mov    %al,(%edx)
}
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <printfmt>:
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80029b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029e:	50                   	push   %eax
  80029f:	ff 75 10             	pushl  0x10(%ebp)
  8002a2:	ff 75 0c             	pushl  0xc(%ebp)
  8002a5:	ff 75 08             	pushl  0x8(%ebp)
  8002a8:	e8 05 00 00 00       	call   8002b2 <vprintfmt>
}
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <vprintfmt>:
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	57                   	push   %edi
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	83 ec 2c             	sub    $0x2c,%esp
  8002bb:	e8 9f fd ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8002c0:	81 c3 40 1d 00 00    	add    $0x1d40,%ebx
  8002c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002cc:	e9 c3 03 00 00       	jmp    800694 <.L35+0x48>
		padc = ' ';
  8002d1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002dc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ef:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002f2:	8d 47 01             	lea    0x1(%edi),%eax
  8002f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f8:	0f b6 17             	movzbl (%edi),%edx
  8002fb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002fe:	3c 55                	cmp    $0x55,%al
  800300:	0f 87 16 04 00 00    	ja     80071c <.L22>
  800306:	0f b6 c0             	movzbl %al,%eax
  800309:	89 d9                	mov    %ebx,%ecx
  80030b:	03 8c 83 44 ef ff ff 	add    -0x10bc(%ebx,%eax,4),%ecx
  800312:	ff e1                	jmp    *%ecx

00800314 <.L69>:
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800317:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80031b:	eb d5                	jmp    8002f2 <vprintfmt+0x40>

0080031d <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800320:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800324:	eb cc                	jmp    8002f2 <vprintfmt+0x40>

00800326 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	0f b6 d2             	movzbl %dl,%edx
  800329:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80032c:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800331:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800334:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800338:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80033e:	83 f9 09             	cmp    $0x9,%ecx
  800341:	77 55                	ja     800398 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800343:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800346:	eb e9                	jmp    800331 <.L29+0xb>

00800348 <.L26>:
			precision = va_arg(ap, int);
  800348:	8b 45 14             	mov    0x14(%ebp),%eax
  80034b:	8b 00                	mov    (%eax),%eax
  80034d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8d 40 04             	lea    0x4(%eax),%eax
  800356:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80035c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800360:	79 90                	jns    8002f2 <vprintfmt+0x40>
				width = precision, precision = -1;
  800362:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800365:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800368:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80036f:	eb 81                	jmp    8002f2 <vprintfmt+0x40>

00800371 <.L27>:
  800371:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800374:	85 c0                	test   %eax,%eax
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
  80037b:	0f 49 d0             	cmovns %eax,%edx
  80037e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800384:	e9 69 ff ff ff       	jmp    8002f2 <vprintfmt+0x40>

00800389 <.L23>:
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80038c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800393:	e9 5a ff ff ff       	jmp    8002f2 <vprintfmt+0x40>
  800398:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80039b:	eb bf                	jmp    80035c <.L26+0x14>

0080039d <.L33>:
			lflag++;
  80039d:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a4:	e9 49 ff ff ff       	jmp    8002f2 <vprintfmt+0x40>

008003a9 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ac:	8d 78 04             	lea    0x4(%eax),%edi
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	56                   	push   %esi
  8003b3:	ff 30                	pushl  (%eax)
  8003b5:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003b8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003bb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003be:	e9 ce 02 00 00       	jmp    800691 <.L35+0x45>

008003c3 <.L32>:
			err = va_arg(ap, int);
  8003c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c6:	8d 78 04             	lea    0x4(%eax),%edi
  8003c9:	8b 00                	mov    (%eax),%eax
  8003cb:	99                   	cltd   
  8003cc:	31 d0                	xor    %edx,%eax
  8003ce:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d0:	83 f8 06             	cmp    $0x6,%eax
  8003d3:	7f 27                	jg     8003fc <.L32+0x39>
  8003d5:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003dc:	85 d2                	test   %edx,%edx
  8003de:	74 1c                	je     8003fc <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003e0:	52                   	push   %edx
  8003e1:	8d 83 d5 ee ff ff    	lea    -0x112b(%ebx),%eax
  8003e7:	50                   	push   %eax
  8003e8:	56                   	push   %esi
  8003e9:	ff 75 08             	pushl  0x8(%ebp)
  8003ec:	e8 a4 fe ff ff       	call   800295 <printfmt>
  8003f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f7:	e9 95 02 00 00       	jmp    800691 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8003fc:	50                   	push   %eax
  8003fd:	8d 83 cc ee ff ff    	lea    -0x1134(%ebx),%eax
  800403:	50                   	push   %eax
  800404:	56                   	push   %esi
  800405:	ff 75 08             	pushl  0x8(%ebp)
  800408:	e8 88 fe ff ff       	call   800295 <printfmt>
  80040d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800410:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800413:	e9 79 02 00 00       	jmp    800691 <.L35+0x45>

00800418 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	83 c0 04             	add    $0x4,%eax
  80041e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800426:	85 ff                	test   %edi,%edi
  800428:	8d 83 c5 ee ff ff    	lea    -0x113b(%ebx),%eax
  80042e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	0f 8e b5 00 00 00    	jle    8004f0 <.L36+0xd8>
  80043b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80043f:	75 08                	jne    800449 <.L36+0x31>
  800441:	89 75 0c             	mov    %esi,0xc(%ebp)
  800444:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800447:	eb 6d                	jmp    8004b6 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	ff 75 cc             	pushl  -0x34(%ebp)
  80044f:	57                   	push   %edi
  800450:	e8 85 03 00 00       	call   8007da <strnlen>
  800455:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800458:	29 c2                	sub    %eax,%edx
  80045a:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80045d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800460:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800467:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80046a:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046c:	eb 10                	jmp    80047e <.L36+0x66>
					putch(padc, putdat);
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	56                   	push   %esi
  800472:	ff 75 e0             	pushl  -0x20(%ebp)
  800475:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	83 ef 01             	sub    $0x1,%edi
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	85 ff                	test   %edi,%edi
  800480:	7f ec                	jg     80046e <.L36+0x56>
  800482:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800485:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800488:	85 d2                	test   %edx,%edx
  80048a:	b8 00 00 00 00       	mov    $0x0,%eax
  80048f:	0f 49 c2             	cmovns %edx,%eax
  800492:	29 c2                	sub    %eax,%edx
  800494:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800497:	89 75 0c             	mov    %esi,0xc(%ebp)
  80049a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80049d:	eb 17                	jmp    8004b6 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  80049f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a3:	75 30                	jne    8004d5 <.L36+0xbd>
					putch(ch, putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 0c             	pushl  0xc(%ebp)
  8004ab:	50                   	push   %eax
  8004ac:	ff 55 08             	call   *0x8(%ebp)
  8004af:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b2:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004b6:	83 c7 01             	add    $0x1,%edi
  8004b9:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004bd:	0f be c2             	movsbl %dl,%eax
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	74 52                	je     800516 <.L36+0xfe>
  8004c4:	85 f6                	test   %esi,%esi
  8004c6:	78 d7                	js     80049f <.L36+0x87>
  8004c8:	83 ee 01             	sub    $0x1,%esi
  8004cb:	79 d2                	jns    80049f <.L36+0x87>
  8004cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004d0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004d3:	eb 32                	jmp    800507 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d5:	0f be d2             	movsbl %dl,%edx
  8004d8:	83 ea 20             	sub    $0x20,%edx
  8004db:	83 fa 5e             	cmp    $0x5e,%edx
  8004de:	76 c5                	jbe    8004a5 <.L36+0x8d>
					putch('?', putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	6a 3f                	push   $0x3f
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	eb c2                	jmp    8004b2 <.L36+0x9a>
  8004f0:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004f3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004f6:	eb be                	jmp    8004b6 <.L36+0x9e>
				putch(' ', putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	56                   	push   %esi
  8004fc:	6a 20                	push   $0x20
  8004fe:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800501:	83 ef 01             	sub    $0x1,%edi
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	85 ff                	test   %edi,%edi
  800509:	7f ed                	jg     8004f8 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  80050b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80050e:	89 45 14             	mov    %eax,0x14(%ebp)
  800511:	e9 7b 01 00 00       	jmp    800691 <.L35+0x45>
  800516:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800519:	8b 75 0c             	mov    0xc(%ebp),%esi
  80051c:	eb e9                	jmp    800507 <.L36+0xef>

0080051e <.L31>:
  80051e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800521:	83 f9 01             	cmp    $0x1,%ecx
  800524:	7e 40                	jle    800566 <.L31+0x48>
		return va_arg(*ap, long long);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8b 50 04             	mov    0x4(%eax),%edx
  80052c:	8b 00                	mov    (%eax),%eax
  80052e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800531:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 40 08             	lea    0x8(%eax),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80053d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800541:	79 55                	jns    800598 <.L31+0x7a>
				putch('-', putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	6a 2d                	push   $0x2d
  800549:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80054c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800552:	f7 da                	neg    %edx
  800554:	83 d1 00             	adc    $0x0,%ecx
  800557:	f7 d9                	neg    %ecx
  800559:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800561:	e9 10 01 00 00       	jmp    800676 <.L35+0x2a>
	else if (lflag)
  800566:	85 c9                	test   %ecx,%ecx
  800568:	75 17                	jne    800581 <.L31+0x63>
		return va_arg(*ap, int);
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8b 00                	mov    (%eax),%eax
  80056f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800572:	99                   	cltd   
  800573:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 40 04             	lea    0x4(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
  80057f:	eb bc                	jmp    80053d <.L31+0x1f>
		return va_arg(*ap, long);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	99                   	cltd   
  80058a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 40 04             	lea    0x4(%eax),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
  800596:	eb a5                	jmp    80053d <.L31+0x1f>
			num = getint(&ap, lflag);
  800598:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a3:	e9 ce 00 00 00       	jmp    800676 <.L35+0x2a>

008005a8 <.L37>:
  8005a8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005ab:	83 f9 01             	cmp    $0x1,%ecx
  8005ae:	7e 18                	jle    8005c8 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8b 10                	mov    (%eax),%edx
  8005b5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b8:	8d 40 08             	lea    0x8(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	e9 ae 00 00 00       	jmp    800676 <.L35+0x2a>
	else if (lflag)
  8005c8:	85 c9                	test   %ecx,%ecx
  8005ca:	75 1a                	jne    8005e6 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8b 10                	mov    (%eax),%edx
  8005d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d6:	8d 40 04             	lea    0x4(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e1:	e9 90 00 00 00       	jmp    800676 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 10                	mov    (%eax),%edx
  8005eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fb:	eb 79                	jmp    800676 <.L35+0x2a>

008005fd <.L34>:
  8005fd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800600:	83 f9 01             	cmp    $0x1,%ecx
  800603:	7e 15                	jle    80061a <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 10                	mov    (%eax),%edx
  80060a:	8b 48 04             	mov    0x4(%eax),%ecx
  80060d:	8d 40 08             	lea    0x8(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800613:	b8 08 00 00 00       	mov    $0x8,%eax
  800618:	eb 5c                	jmp    800676 <.L35+0x2a>
	else if (lflag)
  80061a:	85 c9                	test   %ecx,%ecx
  80061c:	75 17                	jne    800635 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8b 10                	mov    (%eax),%edx
  800623:	b9 00 00 00 00       	mov    $0x0,%ecx
  800628:	8d 40 04             	lea    0x4(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80062e:	b8 08 00 00 00       	mov    $0x8,%eax
  800633:	eb 41                	jmp    800676 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063f:	8d 40 04             	lea    0x4(%eax),%eax
  800642:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800645:	b8 08 00 00 00       	mov    $0x8,%eax
  80064a:	eb 2a                	jmp    800676 <.L35+0x2a>

0080064c <.L35>:
			putch('0', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	56                   	push   %esi
  800650:	6a 30                	push   $0x30
  800652:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	6a 78                	push   $0x78
  80065b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800668:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80066b:	8d 40 04             	lea    0x4(%eax),%eax
  80066e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800671:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800676:	83 ec 0c             	sub    $0xc,%esp
  800679:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80067d:	57                   	push   %edi
  80067e:	ff 75 e0             	pushl  -0x20(%ebp)
  800681:	50                   	push   %eax
  800682:	51                   	push   %ecx
  800683:	52                   	push   %edx
  800684:	89 f2                	mov    %esi,%edx
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	e8 20 fb ff ff       	call   8001ae <printnum>
			break;
  80068e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800691:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800694:	83 c7 01             	add    $0x1,%edi
  800697:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069b:	83 f8 25             	cmp    $0x25,%eax
  80069e:	0f 84 2d fc ff ff    	je     8002d1 <vprintfmt+0x1f>
			if (ch == '\0')
  8006a4:	85 c0                	test   %eax,%eax
  8006a6:	0f 84 91 00 00 00    	je     80073d <.L22+0x21>
			putch(ch, putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	56                   	push   %esi
  8006b0:	50                   	push   %eax
  8006b1:	ff 55 08             	call   *0x8(%ebp)
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	eb db                	jmp    800694 <.L35+0x48>

008006b9 <.L38>:
  8006b9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006bc:	83 f9 01             	cmp    $0x1,%ecx
  8006bf:	7e 15                	jle    8006d6 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c9:	8d 40 08             	lea    0x8(%eax),%eax
  8006cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cf:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d4:	eb a0                	jmp    800676 <.L35+0x2a>
	else if (lflag)
  8006d6:	85 c9                	test   %ecx,%ecx
  8006d8:	75 17                	jne    8006f1 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 10                	mov    (%eax),%edx
  8006df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e4:	8d 40 04             	lea    0x4(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ea:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ef:	eb 85                	jmp    800676 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8b 10                	mov    (%eax),%edx
  8006f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800701:	b8 10 00 00 00       	mov    $0x10,%eax
  800706:	e9 6b ff ff ff       	jmp    800676 <.L35+0x2a>

0080070b <.L25>:
			putch(ch, putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	56                   	push   %esi
  80070f:	6a 25                	push   $0x25
  800711:	ff 55 08             	call   *0x8(%ebp)
			break;
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	e9 75 ff ff ff       	jmp    800691 <.L35+0x45>

0080071c <.L22>:
			putch('%', putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	56                   	push   %esi
  800720:	6a 25                	push   $0x25
  800722:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	89 f8                	mov    %edi,%eax
  80072a:	eb 03                	jmp    80072f <.L22+0x13>
  80072c:	83 e8 01             	sub    $0x1,%eax
  80072f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800733:	75 f7                	jne    80072c <.L22+0x10>
  800735:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800738:	e9 54 ff ff ff       	jmp    800691 <.L35+0x45>
}
  80073d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800740:	5b                   	pop    %ebx
  800741:	5e                   	pop    %esi
  800742:	5f                   	pop    %edi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	53                   	push   %ebx
  800749:	83 ec 14             	sub    $0x14,%esp
  80074c:	e8 0e f9 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800751:	81 c3 af 18 00 00    	add    $0x18af,%ebx
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800760:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800764:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800767:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076e:	85 c0                	test   %eax,%eax
  800770:	74 2b                	je     80079d <vsnprintf+0x58>
  800772:	85 d2                	test   %edx,%edx
  800774:	7e 27                	jle    80079d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800776:	ff 75 14             	pushl  0x14(%ebp)
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	8d 83 78 e2 ff ff    	lea    -0x1d88(%ebx),%eax
  800786:	50                   	push   %eax
  800787:	e8 26 fb ff ff       	call   8002b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800795:	83 c4 10             	add    $0x10,%esp
}
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    
		return -E_INVAL;
  80079d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a2:	eb f4                	jmp    800798 <vsnprintf+0x53>

008007a4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007aa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ad:	50                   	push   %eax
  8007ae:	ff 75 10             	pushl  0x10(%ebp)
  8007b1:	ff 75 0c             	pushl  0xc(%ebp)
  8007b4:	ff 75 08             	pushl  0x8(%ebp)
  8007b7:	e8 89 ff ff ff       	call   800745 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <__x86.get_pc_thunk.cx>:
  8007be:	8b 0c 24             	mov    (%esp),%ecx
  8007c1:	c3                   	ret    

008007c2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cd:	eb 03                	jmp    8007d2 <strlen+0x10>
		n++;
  8007cf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d6:	75 f7                	jne    8007cf <strlen+0xd>
	return n;
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e8:	eb 03                	jmp    8007ed <strnlen+0x13>
		n++;
  8007ea:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ed:	39 d0                	cmp    %edx,%eax
  8007ef:	74 06                	je     8007f7 <strnlen+0x1d>
  8007f1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f5:	75 f3                	jne    8007ea <strnlen+0x10>
	return n;
}
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800803:	89 c2                	mov    %eax,%edx
  800805:	83 c1 01             	add    $0x1,%ecx
  800808:	83 c2 01             	add    $0x1,%edx
  80080b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800812:	84 db                	test   %bl,%bl
  800814:	75 ef                	jne    800805 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800820:	53                   	push   %ebx
  800821:	e8 9c ff ff ff       	call   8007c2 <strlen>
  800826:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800829:	ff 75 0c             	pushl  0xc(%ebp)
  80082c:	01 d8                	add    %ebx,%eax
  80082e:	50                   	push   %eax
  80082f:	e8 c5 ff ff ff       	call   8007f9 <strcpy>
	return dst;
}
  800834:	89 d8                	mov    %ebx,%eax
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 75 08             	mov    0x8(%ebp),%esi
  800843:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800846:	89 f3                	mov    %esi,%ebx
  800848:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084b:	89 f2                	mov    %esi,%edx
  80084d:	eb 0f                	jmp    80085e <strncpy+0x23>
		*dst++ = *src;
  80084f:	83 c2 01             	add    $0x1,%edx
  800852:	0f b6 01             	movzbl (%ecx),%eax
  800855:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800858:	80 39 01             	cmpb   $0x1,(%ecx)
  80085b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80085e:	39 da                	cmp    %ebx,%edx
  800860:	75 ed                	jne    80084f <strncpy+0x14>
	}
	return ret;
}
  800862:	89 f0                	mov    %esi,%eax
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 75 08             	mov    0x8(%ebp),%esi
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
  800873:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800876:	89 f0                	mov    %esi,%eax
  800878:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087c:	85 c9                	test   %ecx,%ecx
  80087e:	75 0b                	jne    80088b <strlcpy+0x23>
  800880:	eb 17                	jmp    800899 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800882:	83 c2 01             	add    $0x1,%edx
  800885:	83 c0 01             	add    $0x1,%eax
  800888:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80088b:	39 d8                	cmp    %ebx,%eax
  80088d:	74 07                	je     800896 <strlcpy+0x2e>
  80088f:	0f b6 0a             	movzbl (%edx),%ecx
  800892:	84 c9                	test   %cl,%cl
  800894:	75 ec                	jne    800882 <strlcpy+0x1a>
		*dst = '\0';
  800896:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800899:	29 f0                	sub    %esi,%eax
}
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a8:	eb 06                	jmp    8008b0 <strcmp+0x11>
		p++, q++;
  8008aa:	83 c1 01             	add    $0x1,%ecx
  8008ad:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008b0:	0f b6 01             	movzbl (%ecx),%eax
  8008b3:	84 c0                	test   %al,%al
  8008b5:	74 04                	je     8008bb <strcmp+0x1c>
  8008b7:	3a 02                	cmp    (%edx),%al
  8008b9:	74 ef                	je     8008aa <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 c0             	movzbl %al,%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	53                   	push   %ebx
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d4:	eb 06                	jmp    8008dc <strncmp+0x17>
		n--, p++, q++;
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008dc:	39 d8                	cmp    %ebx,%eax
  8008de:	74 16                	je     8008f6 <strncmp+0x31>
  8008e0:	0f b6 08             	movzbl (%eax),%ecx
  8008e3:	84 c9                	test   %cl,%cl
  8008e5:	74 04                	je     8008eb <strncmp+0x26>
  8008e7:	3a 0a                	cmp    (%edx),%cl
  8008e9:	74 eb                	je     8008d6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 00             	movzbl (%eax),%eax
  8008ee:	0f b6 12             	movzbl (%edx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
}
  8008f3:	5b                   	pop    %ebx
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    
		return 0;
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fb:	eb f6                	jmp    8008f3 <strncmp+0x2e>

008008fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800907:	0f b6 10             	movzbl (%eax),%edx
  80090a:	84 d2                	test   %dl,%dl
  80090c:	74 09                	je     800917 <strchr+0x1a>
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 0a                	je     80091c <strchr+0x1f>
	for (; *s; s++)
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	eb f0                	jmp    800907 <strchr+0xa>
			return (char *) s;
	return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800928:	eb 03                	jmp    80092d <strfind+0xf>
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800930:	38 ca                	cmp    %cl,%dl
  800932:	74 04                	je     800938 <strfind+0x1a>
  800934:	84 d2                	test   %dl,%dl
  800936:	75 f2                	jne    80092a <strfind+0xc>
			break;
	return (char *) s;
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 7d 08             	mov    0x8(%ebp),%edi
  800943:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800946:	85 c9                	test   %ecx,%ecx
  800948:	74 13                	je     80095d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800950:	75 05                	jne    800957 <memset+0x1d>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	74 0d                	je     800964 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	fc                   	cld    
  80095b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095d:	89 f8                	mov    %edi,%eax
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5f                   	pop    %edi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    
		c &= 0xFF;
  800964:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800968:	89 d3                	mov    %edx,%ebx
  80096a:	c1 e3 08             	shl    $0x8,%ebx
  80096d:	89 d0                	mov    %edx,%eax
  80096f:	c1 e0 18             	shl    $0x18,%eax
  800972:	89 d6                	mov    %edx,%esi
  800974:	c1 e6 10             	shl    $0x10,%esi
  800977:	09 f0                	or     %esi,%eax
  800979:	09 c2                	or     %eax,%edx
  80097b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80097d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800980:	89 d0                	mov    %edx,%eax
  800982:	fc                   	cld    
  800983:	f3 ab                	rep stos %eax,%es:(%edi)
  800985:	eb d6                	jmp    80095d <memset+0x23>

00800987 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800992:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800995:	39 c6                	cmp    %eax,%esi
  800997:	73 35                	jae    8009ce <memmove+0x47>
  800999:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099c:	39 c2                	cmp    %eax,%edx
  80099e:	76 2e                	jbe    8009ce <memmove+0x47>
		s += n;
		d += n;
  8009a0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a3:	89 d6                	mov    %edx,%esi
  8009a5:	09 fe                	or     %edi,%esi
  8009a7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ad:	74 0c                	je     8009bb <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009af:	83 ef 01             	sub    $0x1,%edi
  8009b2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b5:	fd                   	std    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b8:	fc                   	cld    
  8009b9:	eb 21                	jmp    8009dc <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	f6 c1 03             	test   $0x3,%cl
  8009be:	75 ef                	jne    8009af <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c0:	83 ef 04             	sub    $0x4,%edi
  8009c3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c9:	fd                   	std    
  8009ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cc:	eb ea                	jmp    8009b8 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	89 f2                	mov    %esi,%edx
  8009d0:	09 c2                	or     %eax,%edx
  8009d2:	f6 c2 03             	test   $0x3,%dl
  8009d5:	74 09                	je     8009e0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d7:	89 c7                	mov    %eax,%edi
  8009d9:	fc                   	cld    
  8009da:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009dc:	5e                   	pop    %esi
  8009dd:	5f                   	pop    %edi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e0:	f6 c1 03             	test   $0x3,%cl
  8009e3:	75 f2                	jne    8009d7 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e8:	89 c7                	mov    %eax,%edi
  8009ea:	fc                   	cld    
  8009eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ed:	eb ed                	jmp    8009dc <memmove+0x55>

008009ef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f2:	ff 75 10             	pushl  0x10(%ebp)
  8009f5:	ff 75 0c             	pushl  0xc(%ebp)
  8009f8:	ff 75 08             	pushl  0x8(%ebp)
  8009fb:	e8 87 ff ff ff       	call   800987 <memmove>
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 c6                	mov    %eax,%esi
  800a0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a12:	39 f0                	cmp    %esi,%eax
  800a14:	74 1c                	je     800a32 <memcmp+0x30>
		if (*s1 != *s2)
  800a16:	0f b6 08             	movzbl (%eax),%ecx
  800a19:	0f b6 1a             	movzbl (%edx),%ebx
  800a1c:	38 d9                	cmp    %bl,%cl
  800a1e:	75 08                	jne    800a28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	83 c2 01             	add    $0x1,%edx
  800a26:	eb ea                	jmp    800a12 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a28:	0f b6 c1             	movzbl %cl,%eax
  800a2b:	0f b6 db             	movzbl %bl,%ebx
  800a2e:	29 d8                	sub    %ebx,%eax
  800a30:	eb 05                	jmp    800a37 <memcmp+0x35>
	}

	return 0;
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a44:	89 c2                	mov    %eax,%edx
  800a46:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 09                	jae    800a56 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4d:	38 08                	cmp    %cl,(%eax)
  800a4f:	74 05                	je     800a56 <memfind+0x1b>
	for (; s < ends; s++)
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	eb f3                	jmp    800a49 <memfind+0xe>
			break;
	return (void *) s;
}
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a64:	eb 03                	jmp    800a69 <strtol+0x11>
		s++;
  800a66:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a69:	0f b6 01             	movzbl (%ecx),%eax
  800a6c:	3c 20                	cmp    $0x20,%al
  800a6e:	74 f6                	je     800a66 <strtol+0xe>
  800a70:	3c 09                	cmp    $0x9,%al
  800a72:	74 f2                	je     800a66 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a74:	3c 2b                	cmp    $0x2b,%al
  800a76:	74 2e                	je     800aa6 <strtol+0x4e>
	int neg = 0;
  800a78:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7d:	3c 2d                	cmp    $0x2d,%al
  800a7f:	74 2f                	je     800ab0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a81:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a87:	75 05                	jne    800a8e <strtol+0x36>
  800a89:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8c:	74 2c                	je     800aba <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8e:	85 db                	test   %ebx,%ebx
  800a90:	75 0a                	jne    800a9c <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a92:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a97:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9a:	74 28                	je     800ac4 <strtol+0x6c>
		base = 10;
  800a9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa4:	eb 50                	jmp    800af6 <strtol+0x9e>
		s++;
  800aa6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aae:	eb d1                	jmp    800a81 <strtol+0x29>
		s++, neg = 1;
  800ab0:	83 c1 01             	add    $0x1,%ecx
  800ab3:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab8:	eb c7                	jmp    800a81 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abe:	74 0e                	je     800ace <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ac0:	85 db                	test   %ebx,%ebx
  800ac2:	75 d8                	jne    800a9c <strtol+0x44>
		s++, base = 8;
  800ac4:	83 c1 01             	add    $0x1,%ecx
  800ac7:	bb 08 00 00 00       	mov    $0x8,%ebx
  800acc:	eb ce                	jmp    800a9c <strtol+0x44>
		s += 2, base = 16;
  800ace:	83 c1 02             	add    $0x2,%ecx
  800ad1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad6:	eb c4                	jmp    800a9c <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ad8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 29                	ja     800b0b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae2:	0f be d2             	movsbl %dl,%edx
  800ae5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aeb:	7d 30                	jge    800b1d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aed:	83 c1 01             	add    $0x1,%ecx
  800af0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af6:	0f b6 11             	movzbl (%ecx),%edx
  800af9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 09             	cmp    $0x9,%bl
  800b01:	77 d5                	ja     800ad8 <strtol+0x80>
			dig = *s - '0';
  800b03:	0f be d2             	movsbl %dl,%edx
  800b06:	83 ea 30             	sub    $0x30,%edx
  800b09:	eb dd                	jmp    800ae8 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b0b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0e:	89 f3                	mov    %esi,%ebx
  800b10:	80 fb 19             	cmp    $0x19,%bl
  800b13:	77 08                	ja     800b1d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b15:	0f be d2             	movsbl %dl,%edx
  800b18:	83 ea 37             	sub    $0x37,%edx
  800b1b:	eb cb                	jmp    800ae8 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b21:	74 05                	je     800b28 <strtol+0xd0>
		*endptr = (char *) s;
  800b23:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b26:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	f7 da                	neg    %edx
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	0f 45 c2             	cmovne %edx,%eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	8b 55 08             	mov    0x8(%ebp),%edx
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	89 c6                	mov    %eax,%esi
  800b4d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b64:	89 d1                	mov    %edx,%ecx
  800b66:	89 d3                	mov    %edx,%ebx
  800b68:	89 d7                	mov    %edx,%edi
  800b6a:	89 d6                	mov    %edx,%esi
  800b6c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 1c             	sub    $0x1c,%esp
  800b7c:	e8 66 00 00 00       	call   800be7 <__x86.get_pc_thunk.ax>
  800b81:	05 7f 14 00 00       	add    $0x147f,%eax
  800b86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	b8 03 00 00 00       	mov    $0x3,%eax
  800b96:	89 cb                	mov    %ecx,%ebx
  800b98:	89 cf                	mov    %ecx,%edi
  800b9a:	89 ce                	mov    %ecx,%esi
  800b9c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7f 08                	jg     800baa <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	50                   	push   %eax
  800bae:	6a 03                	push   $0x3
  800bb0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bb3:	8d 83 9c f0 ff ff    	lea    -0xf64(%ebx),%eax
  800bb9:	50                   	push   %eax
  800bba:	6a 23                	push   $0x23
  800bbc:	8d 83 b9 f0 ff ff    	lea    -0xf47(%ebx),%eax
  800bc2:	50                   	push   %eax
  800bc3:	e8 23 00 00 00       	call   800beb <_panic>

00800bc8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bce:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd3:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd8:	89 d1                	mov    %edx,%ecx
  800bda:	89 d3                	mov    %edx,%ebx
  800bdc:	89 d7                	mov    %edx,%edi
  800bde:	89 d6                	mov    %edx,%esi
  800be0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <__x86.get_pc_thunk.ax>:
  800be7:	8b 04 24             	mov    (%esp),%eax
  800bea:	c3                   	ret    

00800beb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	e8 66 f4 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800bf9:	81 c3 07 14 00 00    	add    $0x1407,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bff:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c02:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c08:	8b 38                	mov    (%eax),%edi
  800c0a:	e8 b9 ff ff ff       	call   800bc8 <sys_getenvid>
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	ff 75 0c             	pushl  0xc(%ebp)
  800c15:	ff 75 08             	pushl  0x8(%ebp)
  800c18:	57                   	push   %edi
  800c19:	50                   	push   %eax
  800c1a:	8d 83 c8 f0 ff ff    	lea    -0xf38(%ebx),%eax
  800c20:	50                   	push   %eax
  800c21:	e8 74 f5 ff ff       	call   80019a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c26:	83 c4 18             	add    $0x18,%esp
  800c29:	56                   	push   %esi
  800c2a:	ff 75 10             	pushl  0x10(%ebp)
  800c2d:	e8 06 f5 ff ff       	call   800138 <vcprintf>
	cprintf("\n");
  800c32:	8d 83 a8 ee ff ff    	lea    -0x1158(%ebx),%eax
  800c38:	89 04 24             	mov    %eax,(%esp)
  800c3b:	e8 5a f5 ff ff       	call   80019a <cprintf>
  800c40:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c43:	cc                   	int3   
  800c44:	eb fd                	jmp    800c43 <_panic+0x58>
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
