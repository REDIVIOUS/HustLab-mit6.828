
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 b0 18 00       	mov    $0x18b000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 1b 01 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 d4 9f 08 00    	add    $0x89fd4,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 10 d0 18 f0    	mov    $0xf018d010,%eax
f0100058:	c7 c2 00 c1 18 f0    	mov    $0xf018c100,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 41 51 00 00       	call   f01051aa <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4e 05 00 00       	call   f01005bc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 e0 b5 f7 ff    	lea    -0x84a20(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 af 3a 00 00       	call   f0103b31 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 5f 13 00 00       	call   f01013e6 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 d2 33 00 00       	call   f010345e <env_init>
	trap_init();
f010008c:	e8 53 3b 00 00       	call   f0103be4 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f010009c:	e8 9f 35 00 00       	call   f0103640 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 4c c3 18 f0    	mov    $0xf018c34c,%eax
f01000aa:	ff 30                	pushl  (%eax)
f01000ac:	e8 80 39 00 00       	call   f0103a31 <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	57                   	push   %edi
f01000b5:	56                   	push   %esi
f01000b6:	53                   	push   %ebx
f01000b7:	83 ec 0c             	sub    $0xc,%esp
f01000ba:	e8 a8 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f01000bf:	81 c3 61 9f 08 00    	add    $0x89f61,%ebx
f01000c5:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000c8:	c7 c0 00 d0 18 f0    	mov    $0xf018d000,%eax
f01000ce:	83 38 00             	cmpl   $0x0,(%eax)
f01000d1:	74 0f                	je     f01000e2 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 0a 08 00 00       	call   f01008e7 <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x22>
	panicstr = fmt;
f01000e2:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f01000e4:	fa                   	cli    
f01000e5:	fc                   	cld    
	va_start(ap, fmt);
f01000e6:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e9:	83 ec 04             	sub    $0x4,%esp
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	8d 83 fb b5 f7 ff    	lea    -0x84a05(%ebx),%eax
f01000f8:	50                   	push   %eax
f01000f9:	e8 33 3a 00 00       	call   f0103b31 <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	56                   	push   %esi
f0100102:	57                   	push   %edi
f0100103:	e8 f2 39 00 00       	call   f0103afa <vcprintf>
	cprintf("\n");
f0100108:	8d 83 92 c5 f7 ff    	lea    -0x83a6e(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 1b 3a 00 00       	call   f0103b31 <cprintf>
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	eb b8                	jmp    f01000d3 <_panic+0x22>

f010011b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011b:	55                   	push   %ebp
f010011c:	89 e5                	mov    %esp,%ebp
f010011e:	56                   	push   %esi
f010011f:	53                   	push   %ebx
f0100120:	e8 42 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100125:	81 c3 fb 9e 08 00    	add    $0x89efb,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	pushl  0xc(%ebp)
f0100134:	ff 75 08             	pushl  0x8(%ebp)
f0100137:	8d 83 13 b6 f7 ff    	lea    -0x849ed(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 ee 39 00 00       	call   f0103b31 <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	pushl  0x10(%ebp)
f010014a:	e8 ab 39 00 00       	call   f0103afa <vcprintf>
	cprintf("\n");
f010014f:	8d 83 92 c5 f7 ff    	lea    -0x83a6e(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 d4 39 00 00       	call   f0103b31 <cprintf>
	va_end(ap);
}
f010015d:	83 c4 10             	add    $0x10,%esp
f0100160:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100163:	5b                   	pop    %ebx
f0100164:	5e                   	pop    %esi
f0100165:	5d                   	pop    %ebp
f0100166:	c3                   	ret    

f0100167 <__x86.get_pc_thunk.bx>:
f0100167:	8b 1c 24             	mov    (%esp),%ebx
f010016a:	c3                   	ret    

f010016b <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010016b:	55                   	push   %ebp
f010016c:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010016e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100173:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100174:	a8 01                	test   $0x1,%al
f0100176:	74 0b                	je     f0100183 <serial_proc_data+0x18>
f0100178:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017e:	0f b6 c0             	movzbl %al,%eax
}
f0100181:	5d                   	pop    %ebp
f0100182:	c3                   	ret    
		return -1;
f0100183:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100188:	eb f7                	jmp    f0100181 <serial_proc_data+0x16>

f010018a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010018a:	55                   	push   %ebp
f010018b:	89 e5                	mov    %esp,%ebp
f010018d:	56                   	push   %esi
f010018e:	53                   	push   %ebx
f010018f:	e8 d3 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100194:	81 c3 8c 9e 08 00    	add    $0x89e8c,%ebx
f010019a:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f010019c:	ff d6                	call   *%esi
f010019e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a1:	74 2e                	je     f01001d1 <cons_intr+0x47>
		if (c == 0)
f01001a3:	85 c0                	test   %eax,%eax
f01001a5:	74 f5                	je     f010019c <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a7:	8b 8b 04 23 00 00    	mov    0x2304(%ebx),%ecx
f01001ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b0:	89 93 04 23 00 00    	mov    %edx,0x2304(%ebx)
f01001b6:	88 84 0b 00 21 00 00 	mov    %al,0x2100(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001bd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c3:	75 d7                	jne    f010019c <cons_intr+0x12>
			cons.wpos = 0;
f01001c5:	c7 83 04 23 00 00 00 	movl   $0x0,0x2304(%ebx)
f01001cc:	00 00 00 
f01001cf:	eb cb                	jmp    f010019c <cons_intr+0x12>
	}
}
f01001d1:	5b                   	pop    %ebx
f01001d2:	5e                   	pop    %esi
f01001d3:	5d                   	pop    %ebp
f01001d4:	c3                   	ret    

f01001d5 <kbd_proc_data>:
{
f01001d5:	55                   	push   %ebp
f01001d6:	89 e5                	mov    %esp,%ebp
f01001d8:	56                   	push   %esi
f01001d9:	53                   	push   %ebx
f01001da:	e8 88 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01001df:	81 c3 41 9e 08 00    	add    $0x89e41,%ebx
f01001e5:	ba 64 00 00 00       	mov    $0x64,%edx
f01001ea:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001eb:	a8 01                	test   $0x1,%al
f01001ed:	0f 84 06 01 00 00    	je     f01002f9 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f01001f3:	a8 20                	test   $0x20,%al
f01001f5:	0f 85 05 01 00 00    	jne    f0100300 <kbd_proc_data+0x12b>
f01001fb:	ba 60 00 00 00       	mov    $0x60,%edx
f0100200:	ec                   	in     (%dx),%al
f0100201:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100203:	3c e0                	cmp    $0xe0,%al
f0100205:	0f 84 93 00 00 00    	je     f010029e <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f010020b:	84 c0                	test   %al,%al
f010020d:	0f 88 a0 00 00 00    	js     f01002b3 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100213:	8b 8b e0 20 00 00    	mov    0x20e0(%ebx),%ecx
f0100219:	f6 c1 40             	test   $0x40,%cl
f010021c:	74 0e                	je     f010022c <kbd_proc_data+0x57>
		data |= 0x80;
f010021e:	83 c8 80             	or     $0xffffff80,%eax
f0100221:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100223:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100226:	89 8b e0 20 00 00    	mov    %ecx,0x20e0(%ebx)
	shift |= shiftcode[data];
f010022c:	0f b6 d2             	movzbl %dl,%edx
f010022f:	0f b6 84 13 60 b7 f7 	movzbl -0x848a0(%ebx,%edx,1),%eax
f0100236:	ff 
f0100237:	0b 83 e0 20 00 00    	or     0x20e0(%ebx),%eax
	shift ^= togglecode[data];
f010023d:	0f b6 8c 13 60 b6 f7 	movzbl -0x849a0(%ebx,%edx,1),%ecx
f0100244:	ff 
f0100245:	31 c8                	xor    %ecx,%eax
f0100247:	89 83 e0 20 00 00    	mov    %eax,0x20e0(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010024d:	89 c1                	mov    %eax,%ecx
f010024f:	83 e1 03             	and    $0x3,%ecx
f0100252:	8b 8c 8b 00 20 00 00 	mov    0x2000(%ebx,%ecx,4),%ecx
f0100259:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010025d:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100260:	a8 08                	test   $0x8,%al
f0100262:	74 0d                	je     f0100271 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f0100264:	89 f2                	mov    %esi,%edx
f0100266:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100269:	83 f9 19             	cmp    $0x19,%ecx
f010026c:	77 7a                	ja     f01002e8 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f010026e:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100271:	f7 d0                	not    %eax
f0100273:	a8 06                	test   $0x6,%al
f0100275:	75 33                	jne    f01002aa <kbd_proc_data+0xd5>
f0100277:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010027d:	75 2b                	jne    f01002aa <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f010027f:	83 ec 0c             	sub    $0xc,%esp
f0100282:	8d 83 2d b6 f7 ff    	lea    -0x849d3(%ebx),%eax
f0100288:	50                   	push   %eax
f0100289:	e8 a3 38 00 00       	call   f0103b31 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010028e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100293:	ba 92 00 00 00       	mov    $0x92,%edx
f0100298:	ee                   	out    %al,(%dx)
f0100299:	83 c4 10             	add    $0x10,%esp
f010029c:	eb 0c                	jmp    f01002aa <kbd_proc_data+0xd5>
		shift |= E0ESC;
f010029e:	83 8b e0 20 00 00 40 	orl    $0x40,0x20e0(%ebx)
		return 0;
f01002a5:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002aa:	89 f0                	mov    %esi,%eax
f01002ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002af:	5b                   	pop    %ebx
f01002b0:	5e                   	pop    %esi
f01002b1:	5d                   	pop    %ebp
f01002b2:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002b3:	8b 8b e0 20 00 00    	mov    0x20e0(%ebx),%ecx
f01002b9:	89 ce                	mov    %ecx,%esi
f01002bb:	83 e6 40             	and    $0x40,%esi
f01002be:	83 e0 7f             	and    $0x7f,%eax
f01002c1:	85 f6                	test   %esi,%esi
f01002c3:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002c6:	0f b6 d2             	movzbl %dl,%edx
f01002c9:	0f b6 84 13 60 b7 f7 	movzbl -0x848a0(%ebx,%edx,1),%eax
f01002d0:	ff 
f01002d1:	83 c8 40             	or     $0x40,%eax
f01002d4:	0f b6 c0             	movzbl %al,%eax
f01002d7:	f7 d0                	not    %eax
f01002d9:	21 c8                	and    %ecx,%eax
f01002db:	89 83 e0 20 00 00    	mov    %eax,0x20e0(%ebx)
		return 0;
f01002e1:	be 00 00 00 00       	mov    $0x0,%esi
f01002e6:	eb c2                	jmp    f01002aa <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f01002e8:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002eb:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002ee:	83 fa 1a             	cmp    $0x1a,%edx
f01002f1:	0f 42 f1             	cmovb  %ecx,%esi
f01002f4:	e9 78 ff ff ff       	jmp    f0100271 <kbd_proc_data+0x9c>
		return -1;
f01002f9:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002fe:	eb aa                	jmp    f01002aa <kbd_proc_data+0xd5>
		return -1;
f0100300:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100305:	eb a3                	jmp    f01002aa <kbd_proc_data+0xd5>

f0100307 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100307:	55                   	push   %ebp
f0100308:	89 e5                	mov    %esp,%ebp
f010030a:	57                   	push   %edi
f010030b:	56                   	push   %esi
f010030c:	53                   	push   %ebx
f010030d:	83 ec 1c             	sub    $0x1c,%esp
f0100310:	e8 52 fe ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100315:	81 c3 0b 9d 08 00    	add    $0x89d0b,%ebx
f010031b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010031e:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100323:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100328:	b9 84 00 00 00       	mov    $0x84,%ecx
f010032d:	eb 09                	jmp    f0100338 <cons_putc+0x31>
f010032f:	89 ca                	mov    %ecx,%edx
f0100331:	ec                   	in     (%dx),%al
f0100332:	ec                   	in     (%dx),%al
f0100333:	ec                   	in     (%dx),%al
f0100334:	ec                   	in     (%dx),%al
	     i++)
f0100335:	83 c6 01             	add    $0x1,%esi
f0100338:	89 fa                	mov    %edi,%edx
f010033a:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010033b:	a8 20                	test   $0x20,%al
f010033d:	75 08                	jne    f0100347 <cons_putc+0x40>
f010033f:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100345:	7e e8                	jle    f010032f <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f0100347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010034a:	89 f8                	mov    %edi,%eax
f010034c:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100354:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100355:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010035a:	bf 79 03 00 00       	mov    $0x379,%edi
f010035f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100364:	eb 09                	jmp    f010036f <cons_putc+0x68>
f0100366:	89 ca                	mov    %ecx,%edx
f0100368:	ec                   	in     (%dx),%al
f0100369:	ec                   	in     (%dx),%al
f010036a:	ec                   	in     (%dx),%al
f010036b:	ec                   	in     (%dx),%al
f010036c:	83 c6 01             	add    $0x1,%esi
f010036f:	89 fa                	mov    %edi,%edx
f0100371:	ec                   	in     (%dx),%al
f0100372:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100378:	7f 04                	jg     f010037e <cons_putc+0x77>
f010037a:	84 c0                	test   %al,%al
f010037c:	79 e8                	jns    f0100366 <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100383:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0100387:	ee                   	out    %al,(%dx)
f0100388:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010038d:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100392:	ee                   	out    %al,(%dx)
f0100393:	b8 08 00 00 00       	mov    $0x8,%eax
f0100398:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039c:	89 fa                	mov    %edi,%edx
f010039e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003a4:	89 f8                	mov    %edi,%eax
f01003a6:	80 cc 07             	or     $0x7,%ah
f01003a9:	85 d2                	test   %edx,%edx
f01003ab:	0f 45 c7             	cmovne %edi,%eax
f01003ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003b1:	0f b6 c0             	movzbl %al,%eax
f01003b4:	83 f8 09             	cmp    $0x9,%eax
f01003b7:	0f 84 b9 00 00 00    	je     f0100476 <cons_putc+0x16f>
f01003bd:	83 f8 09             	cmp    $0x9,%eax
f01003c0:	7e 74                	jle    f0100436 <cons_putc+0x12f>
f01003c2:	83 f8 0a             	cmp    $0xa,%eax
f01003c5:	0f 84 9e 00 00 00    	je     f0100469 <cons_putc+0x162>
f01003cb:	83 f8 0d             	cmp    $0xd,%eax
f01003ce:	0f 85 d9 00 00 00    	jne    f01004ad <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f01003d4:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f01003db:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e1:	c1 e8 16             	shr    $0x16,%eax
f01003e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e7:	c1 e0 04             	shl    $0x4,%eax
f01003ea:	66 89 83 08 23 00 00 	mov    %ax,0x2308(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01003f1:	66 81 bb 08 23 00 00 	cmpw   $0x7cf,0x2308(%ebx)
f01003f8:	cf 07 
f01003fa:	0f 87 d4 00 00 00    	ja     f01004d4 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100400:	8b 8b 10 23 00 00    	mov    0x2310(%ebx),%ecx
f0100406:	b8 0e 00 00 00       	mov    $0xe,%eax
f010040b:	89 ca                	mov    %ecx,%edx
f010040d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010040e:	0f b7 9b 08 23 00 00 	movzwl 0x2308(%ebx),%ebx
f0100415:	8d 71 01             	lea    0x1(%ecx),%esi
f0100418:	89 d8                	mov    %ebx,%eax
f010041a:	66 c1 e8 08          	shr    $0x8,%ax
f010041e:	89 f2                	mov    %esi,%edx
f0100420:	ee                   	out    %al,(%dx)
f0100421:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
f0100429:	89 d8                	mov    %ebx,%eax
f010042b:	89 f2                	mov    %esi,%edx
f010042d:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010042e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100431:	5b                   	pop    %ebx
f0100432:	5e                   	pop    %esi
f0100433:	5f                   	pop    %edi
f0100434:	5d                   	pop    %ebp
f0100435:	c3                   	ret    
	switch (c & 0xff) {
f0100436:	83 f8 08             	cmp    $0x8,%eax
f0100439:	75 72                	jne    f01004ad <cons_putc+0x1a6>
		if (crt_pos > 0) {
f010043b:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f0100442:	66 85 c0             	test   %ax,%ax
f0100445:	74 b9                	je     f0100400 <cons_putc+0xf9>
			crt_pos--;
f0100447:	83 e8 01             	sub    $0x1,%eax
f010044a:	66 89 83 08 23 00 00 	mov    %ax,0x2308(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100451:	0f b7 c0             	movzwl %ax,%eax
f0100454:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100458:	b2 00                	mov    $0x0,%dl
f010045a:	83 ca 20             	or     $0x20,%edx
f010045d:	8b 8b 0c 23 00 00    	mov    0x230c(%ebx),%ecx
f0100463:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100467:	eb 88                	jmp    f01003f1 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f0100469:	66 83 83 08 23 00 00 	addw   $0x50,0x2308(%ebx)
f0100470:	50 
f0100471:	e9 5e ff ff ff       	jmp    f01003d4 <cons_putc+0xcd>
		cons_putc(' ');
f0100476:	b8 20 00 00 00       	mov    $0x20,%eax
f010047b:	e8 87 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f0100480:	b8 20 00 00 00       	mov    $0x20,%eax
f0100485:	e8 7d fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f010048a:	b8 20 00 00 00       	mov    $0x20,%eax
f010048f:	e8 73 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f0100494:	b8 20 00 00 00       	mov    $0x20,%eax
f0100499:	e8 69 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f010049e:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a3:	e8 5f fe ff ff       	call   f0100307 <cons_putc>
f01004a8:	e9 44 ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004ad:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f01004b4:	8d 50 01             	lea    0x1(%eax),%edx
f01004b7:	66 89 93 08 23 00 00 	mov    %dx,0x2308(%ebx)
f01004be:	0f b7 c0             	movzwl %ax,%eax
f01004c1:	8b 93 0c 23 00 00    	mov    0x230c(%ebx),%edx
f01004c7:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004cf:	e9 1d ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004d4:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
f01004da:	83 ec 04             	sub    $0x4,%esp
f01004dd:	68 00 0f 00 00       	push   $0xf00
f01004e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004e8:	52                   	push   %edx
f01004e9:	50                   	push   %eax
f01004ea:	e8 08 4d 00 00       	call   f01051f7 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004ef:	8b 93 0c 23 00 00    	mov    0x230c(%ebx),%edx
f01004f5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004fb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100501:	83 c4 10             	add    $0x10,%esp
f0100504:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100509:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010050c:	39 d0                	cmp    %edx,%eax
f010050e:	75 f4                	jne    f0100504 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100510:	66 83 ab 08 23 00 00 	subw   $0x50,0x2308(%ebx)
f0100517:	50 
f0100518:	e9 e3 fe ff ff       	jmp    f0100400 <cons_putc+0xf9>

f010051d <serial_intr>:
{
f010051d:	e8 e7 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100522:	05 fe 9a 08 00       	add    $0x89afe,%eax
	if (serial_exists)
f0100527:	80 b8 14 23 00 00 00 	cmpb   $0x0,0x2314(%eax)
f010052e:	75 02                	jne    f0100532 <serial_intr+0x15>
f0100530:	f3 c3                	repz ret 
{
f0100532:	55                   	push   %ebp
f0100533:	89 e5                	mov    %esp,%ebp
f0100535:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100538:	8d 80 4b 61 f7 ff    	lea    -0x89eb5(%eax),%eax
f010053e:	e8 47 fc ff ff       	call   f010018a <cons_intr>
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <kbd_intr>:
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	83 ec 08             	sub    $0x8,%esp
f010054b:	e8 b9 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100550:	05 d0 9a 08 00       	add    $0x89ad0,%eax
	cons_intr(kbd_proc_data);
f0100555:	8d 80 b5 61 f7 ff    	lea    -0x89e4b(%eax),%eax
f010055b:	e8 2a fc ff ff       	call   f010018a <cons_intr>
}
f0100560:	c9                   	leave  
f0100561:	c3                   	ret    

f0100562 <cons_getc>:
{
f0100562:	55                   	push   %ebp
f0100563:	89 e5                	mov    %esp,%ebp
f0100565:	53                   	push   %ebx
f0100566:	83 ec 04             	sub    $0x4,%esp
f0100569:	e8 f9 fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010056e:	81 c3 b2 9a 08 00    	add    $0x89ab2,%ebx
	serial_intr();
f0100574:	e8 a4 ff ff ff       	call   f010051d <serial_intr>
	kbd_intr();
f0100579:	e8 c7 ff ff ff       	call   f0100545 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010057e:	8b 93 00 23 00 00    	mov    0x2300(%ebx),%edx
	return 0;
f0100584:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100589:	3b 93 04 23 00 00    	cmp    0x2304(%ebx),%edx
f010058f:	74 19                	je     f01005aa <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f0100591:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100594:	89 8b 00 23 00 00    	mov    %ecx,0x2300(%ebx)
f010059a:	0f b6 84 13 00 21 00 	movzbl 0x2100(%ebx,%edx,1),%eax
f01005a1:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005a2:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005a8:	74 06                	je     f01005b0 <cons_getc+0x4e>
}
f01005aa:	83 c4 04             	add    $0x4,%esp
f01005ad:	5b                   	pop    %ebx
f01005ae:	5d                   	pop    %ebp
f01005af:	c3                   	ret    
			cons.rpos = 0;
f01005b0:	c7 83 00 23 00 00 00 	movl   $0x0,0x2300(%ebx)
f01005b7:	00 00 00 
f01005ba:	eb ee                	jmp    f01005aa <cons_getc+0x48>

f01005bc <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005bc:	55                   	push   %ebp
f01005bd:	89 e5                	mov    %esp,%ebp
f01005bf:	57                   	push   %edi
f01005c0:	56                   	push   %esi
f01005c1:	53                   	push   %ebx
f01005c2:	83 ec 1c             	sub    $0x1c,%esp
f01005c5:	e8 9d fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01005ca:	81 c3 56 9a 08 00    	add    $0x89a56,%ebx
	was = *cp;
f01005d0:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005d7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005de:	5a a5 
	if (*cp != 0xA55A) {
f01005e0:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005e7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005eb:	0f 84 bc 00 00 00    	je     f01006ad <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01005f1:	c7 83 10 23 00 00 b4 	movl   $0x3b4,0x2310(%ebx)
f01005f8:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005fb:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100602:	8b bb 10 23 00 00    	mov    0x2310(%ebx),%edi
f0100608:	b8 0e 00 00 00       	mov    $0xe,%eax
f010060d:	89 fa                	mov    %edi,%edx
f010060f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100610:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100613:	89 ca                	mov    %ecx,%edx
f0100615:	ec                   	in     (%dx),%al
f0100616:	0f b6 f0             	movzbl %al,%esi
f0100619:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010061c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100621:	89 fa                	mov    %edi,%edx
f0100623:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100624:	89 ca                	mov    %ecx,%edx
f0100626:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010062a:	89 bb 0c 23 00 00    	mov    %edi,0x230c(%ebx)
	pos |= inb(addr_6845 + 1);
f0100630:	0f b6 c0             	movzbl %al,%eax
f0100633:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100635:	66 89 b3 08 23 00 00 	mov    %si,0x2308(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010063c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100641:	89 c8                	mov    %ecx,%eax
f0100643:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100648:	ee                   	out    %al,(%dx)
f0100649:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010064e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100653:	89 fa                	mov    %edi,%edx
f0100655:	ee                   	out    %al,(%dx)
f0100656:	b8 0c 00 00 00       	mov    $0xc,%eax
f010065b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100660:	ee                   	out    %al,(%dx)
f0100661:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100666:	89 c8                	mov    %ecx,%eax
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ee                   	out    %al,(%dx)
f010066b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100670:	89 fa                	mov    %edi,%edx
f0100672:	ee                   	out    %al,(%dx)
f0100673:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100678:	89 c8                	mov    %ecx,%eax
f010067a:	ee                   	out    %al,(%dx)
f010067b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100680:	89 f2                	mov    %esi,%edx
f0100682:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100683:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100688:	ec                   	in     (%dx),%al
f0100689:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010068b:	3c ff                	cmp    $0xff,%al
f010068d:	0f 95 83 14 23 00 00 	setne  0x2314(%ebx)
f0100694:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100699:	ec                   	in     (%dx),%al
f010069a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069f:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006a0:	80 f9 ff             	cmp    $0xff,%cl
f01006a3:	74 25                	je     f01006ca <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006a8:	5b                   	pop    %ebx
f01006a9:	5e                   	pop    %esi
f01006aa:	5f                   	pop    %edi
f01006ab:	5d                   	pop    %ebp
f01006ac:	c3                   	ret    
		*cp = was;
f01006ad:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b4:	c7 83 10 23 00 00 d4 	movl   $0x3d4,0x2310(%ebx)
f01006bb:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006be:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006c5:	e9 38 ff ff ff       	jmp    f0100602 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006ca:	83 ec 0c             	sub    $0xc,%esp
f01006cd:	8d 83 39 b6 f7 ff    	lea    -0x849c7(%ebx),%eax
f01006d3:	50                   	push   %eax
f01006d4:	e8 58 34 00 00       	call   f0103b31 <cprintf>
f01006d9:	83 c4 10             	add    $0x10,%esp
}
f01006dc:	eb c7                	jmp    f01006a5 <cons_init+0xe9>

f01006de <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006de:	55                   	push   %ebp
f01006df:	89 e5                	mov    %esp,%ebp
f01006e1:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01006e7:	e8 1b fc ff ff       	call   f0100307 <cons_putc>
}
f01006ec:	c9                   	leave  
f01006ed:	c3                   	ret    

f01006ee <getchar>:

int
getchar(void)
{
f01006ee:	55                   	push   %ebp
f01006ef:	89 e5                	mov    %esp,%ebp
f01006f1:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006f4:	e8 69 fe ff ff       	call   f0100562 <cons_getc>
f01006f9:	85 c0                	test   %eax,%eax
f01006fb:	74 f7                	je     f01006f4 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006fd:	c9                   	leave  
f01006fe:	c3                   	ret    

f01006ff <iscons>:

int
iscons(int fdnum)
{
f01006ff:	55                   	push   %ebp
f0100700:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100702:	b8 01 00 00 00       	mov    $0x1,%eax
f0100707:	5d                   	pop    %ebp
f0100708:	c3                   	ret    

f0100709 <__x86.get_pc_thunk.ax>:
f0100709:	8b 04 24             	mov    (%esp),%eax
f010070c:	c3                   	ret    

f010070d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010070d:	55                   	push   %ebp
f010070e:	89 e5                	mov    %esp,%ebp
f0100710:	56                   	push   %esi
f0100711:	53                   	push   %ebx
f0100712:	e8 50 fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100717:	81 c3 09 99 08 00    	add    $0x89909,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010071d:	83 ec 04             	sub    $0x4,%esp
f0100720:	8d 83 60 b8 f7 ff    	lea    -0x847a0(%ebx),%eax
f0100726:	50                   	push   %eax
f0100727:	8d 83 7e b8 f7 ff    	lea    -0x84782(%ebx),%eax
f010072d:	50                   	push   %eax
f010072e:	8d b3 83 b8 f7 ff    	lea    -0x8477d(%ebx),%esi
f0100734:	56                   	push   %esi
f0100735:	e8 f7 33 00 00       	call   f0103b31 <cprintf>
f010073a:	83 c4 0c             	add    $0xc,%esp
f010073d:	8d 83 38 b9 f7 ff    	lea    -0x846c8(%ebx),%eax
f0100743:	50                   	push   %eax
f0100744:	8d 83 8c b8 f7 ff    	lea    -0x84774(%ebx),%eax
f010074a:	50                   	push   %eax
f010074b:	56                   	push   %esi
f010074c:	e8 e0 33 00 00       	call   f0103b31 <cprintf>
f0100751:	83 c4 0c             	add    $0xc,%esp
f0100754:	8d 83 95 b8 f7 ff    	lea    -0x8476b(%ebx),%eax
f010075a:	50                   	push   %eax
f010075b:	8d 83 ac b8 f7 ff    	lea    -0x84754(%ebx),%eax
f0100761:	50                   	push   %eax
f0100762:	56                   	push   %esi
f0100763:	e8 c9 33 00 00       	call   f0103b31 <cprintf>
	return 0;
}
f0100768:	b8 00 00 00 00       	mov    $0x0,%eax
f010076d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100770:	5b                   	pop    %ebx
f0100771:	5e                   	pop    %esi
f0100772:	5d                   	pop    %ebp
f0100773:	c3                   	ret    

f0100774 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100774:	55                   	push   %ebp
f0100775:	89 e5                	mov    %esp,%ebp
f0100777:	57                   	push   %edi
f0100778:	56                   	push   %esi
f0100779:	53                   	push   %ebx
f010077a:	83 ec 18             	sub    $0x18,%esp
f010077d:	e8 e5 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100782:	81 c3 9e 98 08 00    	add    $0x8989e,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100788:	8d 83 b6 b8 f7 ff    	lea    -0x8474a(%ebx),%eax
f010078e:	50                   	push   %eax
f010078f:	e8 9d 33 00 00       	call   f0103b31 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100794:	83 c4 08             	add    $0x8,%esp
f0100797:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f010079d:	8d 83 60 b9 f7 ff    	lea    -0x846a0(%ebx),%eax
f01007a3:	50                   	push   %eax
f01007a4:	e8 88 33 00 00       	call   f0103b31 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007a9:	83 c4 0c             	add    $0xc,%esp
f01007ac:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007b2:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007b8:	50                   	push   %eax
f01007b9:	57                   	push   %edi
f01007ba:	8d 83 88 b9 f7 ff    	lea    -0x84678(%ebx),%eax
f01007c0:	50                   	push   %eax
f01007c1:	e8 6b 33 00 00       	call   f0103b31 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007c6:	83 c4 0c             	add    $0xc,%esp
f01007c9:	c7 c0 e9 55 10 f0    	mov    $0xf01055e9,%eax
f01007cf:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007d5:	52                   	push   %edx
f01007d6:	50                   	push   %eax
f01007d7:	8d 83 ac b9 f7 ff    	lea    -0x84654(%ebx),%eax
f01007dd:	50                   	push   %eax
f01007de:	e8 4e 33 00 00       	call   f0103b31 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	c7 c0 00 c1 18 f0    	mov    $0xf018c100,%eax
f01007ec:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007f2:	52                   	push   %edx
f01007f3:	50                   	push   %eax
f01007f4:	8d 83 d0 b9 f7 ff    	lea    -0x84630(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 31 33 00 00       	call   f0103b31 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	c7 c6 10 d0 18 f0    	mov    $0xf018d010,%esi
f0100809:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010080f:	50                   	push   %eax
f0100810:	56                   	push   %esi
f0100811:	8d 83 f4 b9 f7 ff    	lea    -0x8460c(%ebx),%eax
f0100817:	50                   	push   %eax
f0100818:	e8 14 33 00 00       	call   f0103b31 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010081d:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100820:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100826:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100828:	c1 fe 0a             	sar    $0xa,%esi
f010082b:	56                   	push   %esi
f010082c:	8d 83 18 ba f7 ff    	lea    -0x845e8(%ebx),%eax
f0100832:	50                   	push   %eax
f0100833:	e8 f9 32 00 00       	call   f0103b31 <cprintf>
	return 0;
}
f0100838:	b8 00 00 00 00       	mov    $0x0,%eax
f010083d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100840:	5b                   	pop    %ebx
f0100841:	5e                   	pop    %esi
f0100842:	5f                   	pop    %edi
f0100843:	5d                   	pop    %ebp
f0100844:	c3                   	ret    

f0100845 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100845:	55                   	push   %ebp
f0100846:	89 e5                	mov    %esp,%ebp
f0100848:	57                   	push   %edi
f0100849:	56                   	push   %esi
f010084a:	53                   	push   %ebx
f010084b:	83 ec 48             	sub    $0x48,%esp
f010084e:	e8 14 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100853:	81 c3 cd 97 08 00    	add    $0x897cd,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100859:	89 ee                	mov    %ebp,%esi
	uint32_t ebp, eip;
	uint32_t *p_ebp; //ebp的指针，用于访问ebp后面的元素 
	struct Eipdebuginfo info; //文件信息
	ebp = read_ebp(); //获取ebp
	cprintf("Stack backtrace:\n");
f010085b:	8d 83 cf b8 f7 ff    	lea    -0x84731(%ebx),%eax
f0100861:	50                   	push   %eax
f0100862:	e8 ca 32 00 00       	call   f0103b31 <cprintf>
	while(ebp){
f0100867:	83 c4 10             	add    $0x10,%esp
		p_ebp = (uint32_t *)ebp;
		eip = *(p_ebp+1);
		//打印参数
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",ebp, eip, *(p_ebp+2), *(p_ebp+3), *(p_ebp+4), *(p_ebp+5), *(p_ebp+6));
f010086a:	8d 83 44 ba f7 ff    	lea    -0x845bc(%ebx),%eax
f0100870:	89 45 c0             	mov    %eax,-0x40(%ebp)
		if(debuginfo_eip(eip, &info) ==0){
f0100873:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100876:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while(ebp){
f0100879:	eb 05                	jmp    f0100880 <mon_backtrace+0x3b>
			uint32_t offset = eip - info.eip_fn_addr; 
			//打印eip的函数名、文件名、行号等
			//%.*s有两个参数，代表输出string的最多length个字符
			cprintf("         %s:%d: %.*s+%d\n",info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, offset);
		}
		ebp = *p_ebp; //递归打印
f010087b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010087e:	8b 30                	mov    (%eax),%esi
	while(ebp){
f0100880:	85 f6                	test   %esi,%esi
f0100882:	74 56                	je     f01008da <mon_backtrace+0x95>
		p_ebp = (uint32_t *)ebp;
f0100884:	89 75 c4             	mov    %esi,-0x3c(%ebp)
		eip = *(p_ebp+1);
f0100887:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",ebp, eip, *(p_ebp+2), *(p_ebp+3), *(p_ebp+4), *(p_ebp+5), *(p_ebp+6));
f010088a:	ff 76 18             	pushl  0x18(%esi)
f010088d:	ff 76 14             	pushl  0x14(%esi)
f0100890:	ff 76 10             	pushl  0x10(%esi)
f0100893:	ff 76 0c             	pushl  0xc(%esi)
f0100896:	ff 76 08             	pushl  0x8(%esi)
f0100899:	57                   	push   %edi
f010089a:	56                   	push   %esi
f010089b:	ff 75 c0             	pushl  -0x40(%ebp)
f010089e:	e8 8e 32 00 00       	call   f0103b31 <cprintf>
		if(debuginfo_eip(eip, &info) ==0){
f01008a3:	83 c4 18             	add    $0x18,%esp
f01008a6:	ff 75 bc             	pushl  -0x44(%ebp)
f01008a9:	57                   	push   %edi
f01008aa:	e8 63 3d 00 00       	call   f0104612 <debuginfo_eip>
f01008af:	83 c4 10             	add    $0x10,%esp
f01008b2:	85 c0                	test   %eax,%eax
f01008b4:	75 c5                	jne    f010087b <mon_backtrace+0x36>
			cprintf("         %s:%d: %.*s+%d\n",info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, offset);
f01008b6:	83 ec 08             	sub    $0x8,%esp
			uint32_t offset = eip - info.eip_fn_addr; 
f01008b9:	2b 7d e0             	sub    -0x20(%ebp),%edi
			cprintf("         %s:%d: %.*s+%d\n",info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, offset);
f01008bc:	57                   	push   %edi
f01008bd:	ff 75 d8             	pushl  -0x28(%ebp)
f01008c0:	ff 75 dc             	pushl  -0x24(%ebp)
f01008c3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008c6:	ff 75 d0             	pushl  -0x30(%ebp)
f01008c9:	8d 83 e1 b8 f7 ff    	lea    -0x8471f(%ebx),%eax
f01008cf:	50                   	push   %eax
f01008d0:	e8 5c 32 00 00       	call   f0103b31 <cprintf>
f01008d5:	83 c4 20             	add    $0x20,%esp
f01008d8:	eb a1                	jmp    f010087b <mon_backtrace+0x36>
	}
	return 0;
}
f01008da:	b8 00 00 00 00       	mov    $0x0,%eax
f01008df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008e2:	5b                   	pop    %ebx
f01008e3:	5e                   	pop    %esi
f01008e4:	5f                   	pop    %edi
f01008e5:	5d                   	pop    %ebp
f01008e6:	c3                   	ret    

f01008e7 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008e7:	55                   	push   %ebp
f01008e8:	89 e5                	mov    %esp,%ebp
f01008ea:	57                   	push   %edi
f01008eb:	56                   	push   %esi
f01008ec:	53                   	push   %ebx
f01008ed:	83 ec 68             	sub    $0x68,%esp
f01008f0:	e8 72 f8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01008f5:	81 c3 2b 97 08 00    	add    $0x8972b,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008fb:	8d 83 7c ba f7 ff    	lea    -0x84584(%ebx),%eax
f0100901:	50                   	push   %eax
f0100902:	e8 2a 32 00 00       	call   f0103b31 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100907:	8d 83 a0 ba f7 ff    	lea    -0x84560(%ebx),%eax
f010090d:	89 04 24             	mov    %eax,(%esp)
f0100910:	e8 1c 32 00 00       	call   f0103b31 <cprintf>

	if (tf != NULL)
f0100915:	83 c4 10             	add    $0x10,%esp
f0100918:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010091c:	74 0e                	je     f010092c <monitor+0x45>
		print_trapframe(tf);
f010091e:	83 ec 0c             	sub    $0xc,%esp
f0100921:	ff 75 08             	pushl  0x8(%ebp)
f0100924:	e8 e5 36 00 00       	call   f010400e <print_trapframe>
f0100929:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010092c:	8d bb fe b8 f7 ff    	lea    -0x84702(%ebx),%edi
f0100932:	eb 4a                	jmp    f010097e <monitor+0x97>
f0100934:	83 ec 08             	sub    $0x8,%esp
f0100937:	0f be c0             	movsbl %al,%eax
f010093a:	50                   	push   %eax
f010093b:	57                   	push   %edi
f010093c:	e8 2c 48 00 00       	call   f010516d <strchr>
f0100941:	83 c4 10             	add    $0x10,%esp
f0100944:	85 c0                	test   %eax,%eax
f0100946:	74 08                	je     f0100950 <monitor+0x69>
			*buf++ = 0;
f0100948:	c6 06 00             	movb   $0x0,(%esi)
f010094b:	8d 76 01             	lea    0x1(%esi),%esi
f010094e:	eb 76                	jmp    f01009c6 <monitor+0xdf>
		if (*buf == 0)
f0100950:	80 3e 00             	cmpb   $0x0,(%esi)
f0100953:	74 7c                	je     f01009d1 <monitor+0xea>
		if (argc == MAXARGS-1) {
f0100955:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100959:	74 0f                	je     f010096a <monitor+0x83>
		argv[argc++] = buf;
f010095b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010095e:	8d 48 01             	lea    0x1(%eax),%ecx
f0100961:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100964:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100968:	eb 41                	jmp    f01009ab <monitor+0xc4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010096a:	83 ec 08             	sub    $0x8,%esp
f010096d:	6a 10                	push   $0x10
f010096f:	8d 83 03 b9 f7 ff    	lea    -0x846fd(%ebx),%eax
f0100975:	50                   	push   %eax
f0100976:	e8 b6 31 00 00       	call   f0103b31 <cprintf>
f010097b:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010097e:	8d 83 fa b8 f7 ff    	lea    -0x84706(%ebx),%eax
f0100984:	89 c6                	mov    %eax,%esi
f0100986:	83 ec 0c             	sub    $0xc,%esp
f0100989:	56                   	push   %esi
f010098a:	e8 a6 45 00 00       	call   f0104f35 <readline>
		if (buf != NULL)
f010098f:	83 c4 10             	add    $0x10,%esp
f0100992:	85 c0                	test   %eax,%eax
f0100994:	74 f0                	je     f0100986 <monitor+0x9f>
f0100996:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100998:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f010099f:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009a6:	eb 1e                	jmp    f01009c6 <monitor+0xdf>
			buf++;
f01009a8:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009ab:	0f b6 06             	movzbl (%esi),%eax
f01009ae:	84 c0                	test   %al,%al
f01009b0:	74 14                	je     f01009c6 <monitor+0xdf>
f01009b2:	83 ec 08             	sub    $0x8,%esp
f01009b5:	0f be c0             	movsbl %al,%eax
f01009b8:	50                   	push   %eax
f01009b9:	57                   	push   %edi
f01009ba:	e8 ae 47 00 00       	call   f010516d <strchr>
f01009bf:	83 c4 10             	add    $0x10,%esp
f01009c2:	85 c0                	test   %eax,%eax
f01009c4:	74 e2                	je     f01009a8 <monitor+0xc1>
		while (*buf && strchr(WHITESPACE, *buf))
f01009c6:	0f b6 06             	movzbl (%esi),%eax
f01009c9:	84 c0                	test   %al,%al
f01009cb:	0f 85 63 ff ff ff    	jne    f0100934 <monitor+0x4d>
	argv[argc] = 0;
f01009d1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009d4:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f01009db:	00 
	if (argc == 0)
f01009dc:	85 c0                	test   %eax,%eax
f01009de:	74 9e                	je     f010097e <monitor+0x97>
f01009e0:	8d b3 20 20 00 00    	lea    0x2020(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01009eb:	89 7d a0             	mov    %edi,-0x60(%ebp)
f01009ee:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f01009f0:	83 ec 08             	sub    $0x8,%esp
f01009f3:	ff 36                	pushl  (%esi)
f01009f5:	ff 75 a8             	pushl  -0x58(%ebp)
f01009f8:	e8 12 47 00 00       	call   f010510f <strcmp>
f01009fd:	83 c4 10             	add    $0x10,%esp
f0100a00:	85 c0                	test   %eax,%eax
f0100a02:	74 28                	je     f0100a2c <monitor+0x145>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a04:	83 c7 01             	add    $0x1,%edi
f0100a07:	83 c6 0c             	add    $0xc,%esi
f0100a0a:	83 ff 03             	cmp    $0x3,%edi
f0100a0d:	75 e1                	jne    f01009f0 <monitor+0x109>
f0100a0f:	8b 7d a0             	mov    -0x60(%ebp),%edi
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a12:	83 ec 08             	sub    $0x8,%esp
f0100a15:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a18:	8d 83 20 b9 f7 ff    	lea    -0x846e0(%ebx),%eax
f0100a1e:	50                   	push   %eax
f0100a1f:	e8 0d 31 00 00       	call   f0103b31 <cprintf>
f0100a24:	83 c4 10             	add    $0x10,%esp
f0100a27:	e9 52 ff ff ff       	jmp    f010097e <monitor+0x97>
f0100a2c:	89 f8                	mov    %edi,%eax
f0100a2e:	8b 7d a0             	mov    -0x60(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100a31:	83 ec 04             	sub    $0x4,%esp
f0100a34:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a37:	ff 75 08             	pushl  0x8(%ebp)
f0100a3a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a3d:	52                   	push   %edx
f0100a3e:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a41:	ff 94 83 28 20 00 00 	call   *0x2028(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a48:	83 c4 10             	add    $0x10,%esp
f0100a4b:	85 c0                	test   %eax,%eax
f0100a4d:	0f 89 2b ff ff ff    	jns    f010097e <monitor+0x97>
				break;
	}
}
f0100a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a56:	5b                   	pop    %ebx
f0100a57:	5e                   	pop    %esi
f0100a58:	5f                   	pop    %edi
f0100a59:	5d                   	pop    %ebp
f0100a5a:	c3                   	ret    

f0100a5b <boot_alloc>:
// 函数仅在设置jos的时候使用，设置虚拟系统并初始化，page_alloc是实际的分配器
// 该函数的作用是申请n个字节的空间，返回空间的首地址（虚拟地址），如果n=0则返回下一个空闲页面的地址
// 并且保证每次分配的内存都要和PGSIZE，即4k（4096字节）对齐
static void *
boot_alloc(uint32_t n)
{
f0100a5b:	55                   	push   %ebp
f0100a5c:	89 e5                	mov    %esp,%ebp
f0100a5e:	e8 8f 28 00 00       	call   f01032f2 <__x86.get_pc_thunk.dx>
f0100a63:	81 c2 bd 95 08 00    	add    $0x895bd,%edx
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	// 初始化nextfree
	// end指向内核的bss段的末尾
	if (!nextfree) {
f0100a69:	83 ba 18 23 00 00 00 	cmpl   $0x0,0x2318(%edx)
f0100a70:	74 20                	je     f0100a92 <boot_alloc+0x37>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0){
f0100a72:	85 c0                	test   %eax,%eax
f0100a74:	74 36                	je     f0100aac <boot_alloc+0x51>
		return nextfree;
	}
	result = nextfree; 
f0100a76:	8b 8a 18 23 00 00    	mov    0x2318(%edx),%ecx
    nextfree = ROUNDUP(nextfree + n, PGSIZE); //分配n个字节的空间，并与PGSIZE对齐
f0100a7c:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0100a83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a88:	89 82 18 23 00 00    	mov    %eax,0x2318(%edx)
	return result;
}
f0100a8e:	89 c8                	mov    %ecx,%eax
f0100a90:	5d                   	pop    %ebp
f0100a91:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a92:	c7 c1 10 d0 18 f0    	mov    $0xf018d010,%ecx
f0100a98:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100a9e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100aa4:	89 8a 18 23 00 00    	mov    %ecx,0x2318(%edx)
f0100aaa:	eb c6                	jmp    f0100a72 <boot_alloc+0x17>
		return nextfree;
f0100aac:	8b 8a 18 23 00 00    	mov    0x2318(%edx),%ecx
f0100ab2:	eb da                	jmp    f0100a8e <boot_alloc+0x33>

f0100ab4 <nvram_read>:
{
f0100ab4:	55                   	push   %ebp
f0100ab5:	89 e5                	mov    %esp,%ebp
f0100ab7:	57                   	push   %edi
f0100ab8:	56                   	push   %esi
f0100ab9:	53                   	push   %ebx
f0100aba:	83 ec 18             	sub    $0x18,%esp
f0100abd:	e8 a5 f6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100ac2:	81 c3 5e 95 08 00    	add    $0x8955e,%ebx
f0100ac8:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100aca:	50                   	push   %eax
f0100acb:	e8 da 2f 00 00       	call   f0103aaa <mc146818_read>
f0100ad0:	89 c6                	mov    %eax,%esi
f0100ad2:	83 c7 01             	add    $0x1,%edi
f0100ad5:	89 3c 24             	mov    %edi,(%esp)
f0100ad8:	e8 cd 2f 00 00       	call   f0103aaa <mc146818_read>
f0100add:	c1 e0 08             	shl    $0x8,%eax
f0100ae0:	09 f0                	or     %esi,%eax
}
f0100ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ae5:	5b                   	pop    %ebx
f0100ae6:	5e                   	pop    %esi
f0100ae7:	5f                   	pop    %edi
f0100ae8:	5d                   	pop    %ebp
f0100ae9:	c3                   	ret    

f0100aea <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100aea:	55                   	push   %ebp
f0100aeb:	89 e5                	mov    %esp,%ebp
f0100aed:	56                   	push   %esi
f0100aee:	53                   	push   %ebx
f0100aef:	e8 02 28 00 00       	call   f01032f6 <__x86.get_pc_thunk.cx>
f0100af4:	81 c1 2c 95 08 00    	add    $0x8952c,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100afa:	89 d3                	mov    %edx,%ebx
f0100afc:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100aff:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100b02:	a8 01                	test   $0x1,%al
f0100b04:	74 5a                	je     f0100b60 <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b0b:	89 c6                	mov    %eax,%esi
f0100b0d:	c1 ee 0c             	shr    $0xc,%esi
f0100b10:	c7 c3 04 d0 18 f0    	mov    $0xf018d004,%ebx
f0100b16:	3b 33                	cmp    (%ebx),%esi
f0100b18:	73 2b                	jae    f0100b45 <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100b1a:	c1 ea 0c             	shr    $0xc,%edx
f0100b1d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b23:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b2a:	89 c2                	mov    %eax,%edx
f0100b2c:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b34:	85 d2                	test   %edx,%edx
f0100b36:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b3b:	0f 44 c2             	cmove  %edx,%eax
}
f0100b3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b41:	5b                   	pop    %ebx
f0100b42:	5e                   	pop    %esi
f0100b43:	5d                   	pop    %ebp
f0100b44:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b45:	50                   	push   %eax
f0100b46:	8d 81 c8 ba f7 ff    	lea    -0x84538(%ecx),%eax
f0100b4c:	50                   	push   %eax
f0100b4d:	68 6c 03 00 00       	push   $0x36c
f0100b52:	8d 81 e1 c2 f7 ff    	lea    -0x83d1f(%ecx),%eax
f0100b58:	50                   	push   %eax
f0100b59:	89 cb                	mov    %ecx,%ebx
f0100b5b:	e8 51 f5 ff ff       	call   f01000b1 <_panic>
		return ~0;
f0100b60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b65:	eb d7                	jmp    f0100b3e <check_va2pa+0x54>

f0100b67 <check_page_free_list>:
{
f0100b67:	55                   	push   %ebp
f0100b68:	89 e5                	mov    %esp,%ebp
f0100b6a:	57                   	push   %edi
f0100b6b:	56                   	push   %esi
f0100b6c:	53                   	push   %ebx
f0100b6d:	83 ec 3c             	sub    $0x3c,%esp
f0100b70:	e8 85 27 00 00       	call   f01032fa <__x86.get_pc_thunk.di>
f0100b75:	81 c7 ab 94 08 00    	add    $0x894ab,%edi
f0100b7b:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b7e:	84 c0                	test   %al,%al
f0100b80:	0f 85 dd 02 00 00    	jne    f0100e63 <check_page_free_list+0x2fc>
	if (!page_free_list)
f0100b86:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100b89:	83 b8 20 23 00 00 00 	cmpl   $0x0,0x2320(%eax)
f0100b90:	74 0c                	je     f0100b9e <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b92:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0100b99:	e9 2f 03 00 00       	jmp    f0100ecd <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f0100b9e:	83 ec 04             	sub    $0x4,%esp
f0100ba1:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ba4:	8d 83 ec ba f7 ff    	lea    -0x84514(%ebx),%eax
f0100baa:	50                   	push   %eax
f0100bab:	68 a8 02 00 00       	push   $0x2a8
f0100bb0:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100bb6:	50                   	push   %eax
f0100bb7:	e8 f5 f4 ff ff       	call   f01000b1 <_panic>
f0100bbc:	50                   	push   %eax
f0100bbd:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100bc0:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0100bc6:	50                   	push   %eax
f0100bc7:	6a 56                	push   $0x56
f0100bc9:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f0100bcf:	50                   	push   %eax
f0100bd0:	e8 dc f4 ff ff       	call   f01000b1 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bd5:	8b 36                	mov    (%esi),%esi
f0100bd7:	85 f6                	test   %esi,%esi
f0100bd9:	74 40                	je     f0100c1b <check_page_free_list+0xb4>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bdb:	89 f0                	mov    %esi,%eax
f0100bdd:	2b 07                	sub    (%edi),%eax
f0100bdf:	c1 f8 03             	sar    $0x3,%eax
f0100be2:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100be5:	89 c2                	mov    %eax,%edx
f0100be7:	c1 ea 16             	shr    $0x16,%edx
f0100bea:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100bed:	73 e6                	jae    f0100bd5 <check_page_free_list+0x6e>
	if (PGNUM(pa) >= npages)
f0100bef:	89 c2                	mov    %eax,%edx
f0100bf1:	c1 ea 0c             	shr    $0xc,%edx
f0100bf4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100bf7:	3b 11                	cmp    (%ecx),%edx
f0100bf9:	73 c1                	jae    f0100bbc <check_page_free_list+0x55>
			memset(page2kva(pp), 0x97, 128);
f0100bfb:	83 ec 04             	sub    $0x4,%esp
f0100bfe:	68 80 00 00 00       	push   $0x80
f0100c03:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c08:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c0d:	50                   	push   %eax
f0100c0e:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c11:	e8 94 45 00 00       	call   f01051aa <memset>
f0100c16:	83 c4 10             	add    $0x10,%esp
f0100c19:	eb ba                	jmp    f0100bd5 <check_page_free_list+0x6e>
	first_free_page = (char *) boot_alloc(0);
f0100c1b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c20:	e8 36 fe ff ff       	call   f0100a5b <boot_alloc>
f0100c25:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c28:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c2b:	8b 97 20 23 00 00    	mov    0x2320(%edi),%edx
		assert(pp >= pages);
f0100c31:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0100c37:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100c39:	c7 c0 04 d0 18 f0    	mov    $0xf018d004,%eax
f0100c3f:	8b 00                	mov    (%eax),%eax
f0100c41:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c44:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c47:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c4a:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c4f:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c52:	e9 08 01 00 00       	jmp    f0100d5f <check_page_free_list+0x1f8>
		assert(pp >= pages);
f0100c57:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c5a:	8d 83 fb c2 f7 ff    	lea    -0x83d05(%ebx),%eax
f0100c60:	50                   	push   %eax
f0100c61:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0100c67:	50                   	push   %eax
f0100c68:	68 c2 02 00 00       	push   $0x2c2
f0100c6d:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100c73:	50                   	push   %eax
f0100c74:	e8 38 f4 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100c79:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c7c:	8d 83 1c c3 f7 ff    	lea    -0x83ce4(%ebx),%eax
f0100c82:	50                   	push   %eax
f0100c83:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0100c89:	50                   	push   %eax
f0100c8a:	68 c3 02 00 00       	push   $0x2c3
f0100c8f:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100c95:	50                   	push   %eax
f0100c96:	e8 16 f4 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c9b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c9e:	8d 83 10 bb f7 ff    	lea    -0x844f0(%ebx),%eax
f0100ca4:	50                   	push   %eax
f0100ca5:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0100cab:	50                   	push   %eax
f0100cac:	68 c4 02 00 00       	push   $0x2c4
f0100cb1:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100cb7:	50                   	push   %eax
f0100cb8:	e8 f4 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100cbd:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cc0:	8d 83 30 c3 f7 ff    	lea    -0x83cd0(%ebx),%eax
f0100cc6:	50                   	push   %eax
f0100cc7:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0100ccd:	50                   	push   %eax
f0100cce:	68 c7 02 00 00       	push   $0x2c7
f0100cd3:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100cd9:	50                   	push   %eax
f0100cda:	e8 d2 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cdf:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ce2:	8d 83 41 c3 f7 ff    	lea    -0x83cbf(%ebx),%eax
f0100ce8:	50                   	push   %eax
f0100ce9:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0100cef:	50                   	push   %eax
f0100cf0:	68 c8 02 00 00       	push   $0x2c8
f0100cf5:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100cfb:	50                   	push   %eax
f0100cfc:	e8 b0 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d01:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d04:	8d 83 44 bb f7 ff    	lea    -0x844bc(%ebx),%eax
f0100d0a:	50                   	push   %eax
f0100d0b:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0100d11:	50                   	push   %eax
f0100d12:	68 c9 02 00 00       	push   $0x2c9
f0100d17:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100d1d:	50                   	push   %eax
f0100d1e:	e8 8e f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d23:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d26:	8d 83 5a c3 f7 ff    	lea    -0x83ca6(%ebx),%eax
f0100d2c:	50                   	push   %eax
f0100d2d:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0100d33:	50                   	push   %eax
f0100d34:	68 ca 02 00 00       	push   $0x2ca
f0100d39:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100d3f:	50                   	push   %eax
f0100d40:	e8 6c f3 ff ff       	call   f01000b1 <_panic>
	if (PGNUM(pa) >= npages)
f0100d45:	89 c6                	mov    %eax,%esi
f0100d47:	c1 ee 0c             	shr    $0xc,%esi
f0100d4a:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0100d4d:	76 70                	jbe    f0100dbf <check_page_free_list+0x258>
	return (void *)(pa + KERNBASE);
f0100d4f:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d54:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100d57:	77 7f                	ja     f0100dd8 <check_page_free_list+0x271>
			++nfree_extmem;
f0100d59:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d5d:	8b 12                	mov    (%edx),%edx
f0100d5f:	85 d2                	test   %edx,%edx
f0100d61:	0f 84 93 00 00 00    	je     f0100dfa <check_page_free_list+0x293>
		assert(pp >= pages);
f0100d67:	39 d1                	cmp    %edx,%ecx
f0100d69:	0f 87 e8 fe ff ff    	ja     f0100c57 <check_page_free_list+0xf0>
		assert(pp < pages + npages);
f0100d6f:	39 d3                	cmp    %edx,%ebx
f0100d71:	0f 86 02 ff ff ff    	jbe    f0100c79 <check_page_free_list+0x112>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d77:	89 d0                	mov    %edx,%eax
f0100d79:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100d7c:	a8 07                	test   $0x7,%al
f0100d7e:	0f 85 17 ff ff ff    	jne    f0100c9b <check_page_free_list+0x134>
	return (pp - pages) << PGSHIFT;
f0100d84:	c1 f8 03             	sar    $0x3,%eax
f0100d87:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100d8a:	85 c0                	test   %eax,%eax
f0100d8c:	0f 84 2b ff ff ff    	je     f0100cbd <check_page_free_list+0x156>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d92:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d97:	0f 84 42 ff ff ff    	je     f0100cdf <check_page_free_list+0x178>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d9d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100da2:	0f 84 59 ff ff ff    	je     f0100d01 <check_page_free_list+0x19a>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da8:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dad:	0f 84 70 ff ff ff    	je     f0100d23 <check_page_free_list+0x1bc>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100db3:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100db8:	77 8b                	ja     f0100d45 <check_page_free_list+0x1de>
			++nfree_basemem;
f0100dba:	83 c7 01             	add    $0x1,%edi
f0100dbd:	eb 9e                	jmp    f0100d5d <check_page_free_list+0x1f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dbf:	50                   	push   %eax
f0100dc0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dc3:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0100dc9:	50                   	push   %eax
f0100dca:	6a 56                	push   $0x56
f0100dcc:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f0100dd2:	50                   	push   %eax
f0100dd3:	e8 d9 f2 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dd8:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ddb:	8d 83 68 bb f7 ff    	lea    -0x84498(%ebx),%eax
f0100de1:	50                   	push   %eax
f0100de2:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0100de8:	50                   	push   %eax
f0100de9:	68 cb 02 00 00       	push   $0x2cb
f0100dee:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100df4:	50                   	push   %eax
f0100df5:	e8 b7 f2 ff ff       	call   f01000b1 <_panic>
f0100dfa:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0100dfd:	85 ff                	test   %edi,%edi
f0100dff:	7e 1e                	jle    f0100e1f <check_page_free_list+0x2b8>
	assert(nfree_extmem > 0);
f0100e01:	85 f6                	test   %esi,%esi
f0100e03:	7e 3c                	jle    f0100e41 <check_page_free_list+0x2da>
	cprintf("check_page_free_list() succeeded!\n");
f0100e05:	83 ec 0c             	sub    $0xc,%esp
f0100e08:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e0b:	8d 83 b0 bb f7 ff    	lea    -0x84450(%ebx),%eax
f0100e11:	50                   	push   %eax
f0100e12:	e8 1a 2d 00 00       	call   f0103b31 <cprintf>
}
f0100e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e1a:	5b                   	pop    %ebx
f0100e1b:	5e                   	pop    %esi
f0100e1c:	5f                   	pop    %edi
f0100e1d:	5d                   	pop    %ebp
f0100e1e:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e1f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e22:	8d 83 74 c3 f7 ff    	lea    -0x83c8c(%ebx),%eax
f0100e28:	50                   	push   %eax
f0100e29:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0100e2f:	50                   	push   %eax
f0100e30:	68 d3 02 00 00       	push   $0x2d3
f0100e35:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100e3b:	50                   	push   %eax
f0100e3c:	e8 70 f2 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100e41:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e44:	8d 83 86 c3 f7 ff    	lea    -0x83c7a(%ebx),%eax
f0100e4a:	50                   	push   %eax
f0100e4b:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0100e51:	50                   	push   %eax
f0100e52:	68 d4 02 00 00       	push   $0x2d4
f0100e57:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0100e5d:	50                   	push   %eax
f0100e5e:	e8 4e f2 ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f0100e63:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100e66:	8b 80 20 23 00 00    	mov    0x2320(%eax),%eax
f0100e6c:	85 c0                	test   %eax,%eax
f0100e6e:	0f 84 2a fd ff ff    	je     f0100b9e <check_page_free_list+0x37>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e74:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e77:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e7a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e7d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100e80:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100e83:	c7 c3 0c d0 18 f0    	mov    $0xf018d00c,%ebx
f0100e89:	89 c2                	mov    %eax,%edx
f0100e8b:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e8d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e93:	0f 95 c2             	setne  %dl
f0100e96:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e99:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e9d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e9f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ea3:	8b 00                	mov    (%eax),%eax
f0100ea5:	85 c0                	test   %eax,%eax
f0100ea7:	75 e0                	jne    f0100e89 <check_page_free_list+0x322>
		*tp[1] = 0;
f0100ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100eac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100eb2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100eb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100eb8:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100eba:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ebd:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ec0:	89 87 20 23 00 00    	mov    %eax,0x2320(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ec6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ecd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100ed0:	8b b0 20 23 00 00    	mov    0x2320(%eax),%esi
f0100ed6:	c7 c7 0c d0 18 f0    	mov    $0xf018d00c,%edi
	if (PGNUM(pa) >= npages)
f0100edc:	c7 c0 04 d0 18 f0    	mov    $0xf018d004,%eax
f0100ee2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ee5:	e9 ed fc ff ff       	jmp    f0100bd7 <check_page_free_list+0x70>

f0100eea <page_init>:
{
f0100eea:	55                   	push   %ebp
f0100eeb:	89 e5                	mov    %esp,%ebp
f0100eed:	57                   	push   %edi
f0100eee:	56                   	push   %esi
f0100eef:	53                   	push   %ebx
f0100ef0:	83 ec 1c             	sub    $0x1c,%esp
f0100ef3:	e8 6f f2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100ef8:	81 c3 28 91 08 00    	add    $0x89128,%ebx
	for (i = 0; i < npages; i++) {
f0100efe:	be 00 00 00 00       	mov    $0x0,%esi
f0100f03:	c7 c7 04 d0 18 f0    	mov    $0xf018d004,%edi
			pages[i].pp_ref = 0;
f0100f09:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0100f0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0; i < npages; i++) {
f0100f12:	eb 38                	jmp    f0100f4c <page_init+0x62>
		else if(i > 0 && i < npages_basemem){ // 当base memory在[PGSIZE, npages_basemem * PGSIZE)范围内的时候，它是free的
f0100f14:	39 b3 24 23 00 00    	cmp    %esi,0x2324(%ebx)
f0100f1a:	76 52                	jbe    f0100f6e <page_init+0x84>
f0100f1c:	8d 0c f5 00 00 00 00 	lea    0x0(,%esi,8),%ecx
			pages[i].pp_ref = 0;
f0100f23:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0100f29:	89 ca                	mov    %ecx,%edx
f0100f2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f2e:	03 10                	add    (%eax),%edx
f0100f30:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f36:	8b 83 20 23 00 00    	mov    0x2320(%ebx),%eax
f0100f3c:	89 02                	mov    %eax,(%edx)
			page_free_list = &pages[i]; //page_free_list变量指向空闲队列的队尾
f0100f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f41:	03 08                	add    (%eax),%ecx
f0100f43:	89 8b 20 23 00 00    	mov    %ecx,0x2320(%ebx)
	for (i = 0; i < npages; i++) {
f0100f49:	83 c6 01             	add    $0x1,%esi
f0100f4c:	39 37                	cmp    %esi,(%edi)
f0100f4e:	0f 86 c1 00 00 00    	jbe    f0101015 <page_init+0x12b>
		if(i==0){ //空闲队列page_free_list中，物理0号页面是被使用的
f0100f54:	85 f6                	test   %esi,%esi
f0100f56:	75 bc                	jne    f0100f14 <page_init+0x2a>
			pages[i].pp_ref = 1;
f0100f58:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0100f5e:	8b 00                	mov    (%eax),%eax
f0100f60:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100f66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f6c:	eb db                	jmp    f0100f49 <page_init+0x5f>
		else if(i >= IOPHYSMEM/PGSIZE && i < EXTPHYSMEM/PGSIZE){ // 处于IO段[IOPHYSMEM, EXTPHYSMEM)，应该从未被分配过，我们在这里标识为已使用
f0100f6e:	8d 86 60 ff ff ff    	lea    -0xa0(%esi),%eax
f0100f74:	83 f8 5f             	cmp    $0x5f,%eax
f0100f77:	77 19                	ja     f0100f92 <page_init+0xa8>
			pages[i].pp_ref = 1;
f0100f79:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0100f7f:	8b 00                	mov    (%eax),%eax
f0100f81:	8d 04 f0             	lea    (%eax,%esi,8),%eax
f0100f84:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100f8a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f90:	eb b7                	jmp    f0100f49 <page_init+0x5f>
		else if(i >= EXTPHYSMEM/PGSIZE && i < PADDR(boot_alloc(0))/PGSIZE){ //直到第一个被boot_alloc(0)之前都处于使用状态（用于也表和其他数据结构）
f0100f92:	81 fe ff 00 00 00    	cmp    $0xff,%esi
f0100f98:	77 29                	ja     f0100fc3 <page_init+0xd9>
f0100f9a:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
			pages[i].pp_ref = 0;
f0100fa1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fa4:	89 c2                	mov    %eax,%edx
f0100fa6:	03 11                	add    (%ecx),%edx
f0100fa8:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100fae:	8b 8b 20 23 00 00    	mov    0x2320(%ebx),%ecx
f0100fb4:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i]; //page_free_list变量指向空闲队列的队尾
f0100fb6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fb9:	03 01                	add    (%ecx),%eax
f0100fbb:	89 83 20 23 00 00    	mov    %eax,0x2320(%ebx)
f0100fc1:	eb 86                	jmp    f0100f49 <page_init+0x5f>
		else if(i >= EXTPHYSMEM/PGSIZE && i < PADDR(boot_alloc(0))/PGSIZE){ //直到第一个被boot_alloc(0)之前都处于使用状态（用于也表和其他数据结构）
f0100fc3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fc8:	e8 8e fa ff ff       	call   f0100a5b <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100fcd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fd2:	76 28                	jbe    f0100ffc <page_init+0x112>
	return (physaddr_t)kva - KERNBASE;
f0100fd4:	05 00 00 00 10       	add    $0x10000000,%eax
f0100fd9:	c1 e8 0c             	shr    $0xc,%eax
f0100fdc:	39 f0                	cmp    %esi,%eax
f0100fde:	76 ba                	jbe    f0100f9a <page_init+0xb0>
			pages[i].pp_ref = 1;
f0100fe0:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0100fe6:	8b 00                	mov    (%eax),%eax
f0100fe8:	8d 04 f0             	lea    (%eax,%esi,8),%eax
f0100feb:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100ff1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ff7:	e9 4d ff ff ff       	jmp    f0100f49 <page_init+0x5f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ffc:	50                   	push   %eax
f0100ffd:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0101003:	50                   	push   %eax
f0101004:	68 4a 01 00 00       	push   $0x14a
f0101009:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010100f:	50                   	push   %eax
f0101010:	e8 9c f0 ff ff       	call   f01000b1 <_panic>
}
f0101015:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101018:	5b                   	pop    %ebx
f0101019:	5e                   	pop    %esi
f010101a:	5f                   	pop    %edi
f010101b:	5d                   	pop    %ebp
f010101c:	c3                   	ret    

f010101d <page_alloc>:
{
f010101d:	55                   	push   %ebp
f010101e:	89 e5                	mov    %esp,%ebp
f0101020:	56                   	push   %esi
f0101021:	53                   	push   %ebx
f0101022:	e8 40 f1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101027:	81 c3 f9 8f 08 00    	add    $0x88ff9,%ebx
    if (!page_free_list){ //如果空闲列表为空则返回空指针
f010102d:	8b b3 20 23 00 00    	mov    0x2320(%ebx),%esi
f0101033:	85 f6                	test   %esi,%esi
f0101035:	74 14                	je     f010104b <page_alloc+0x2e>
    page_free_list = page_free_list->pp_link; //指向下一个空闲页面
f0101037:	8b 06                	mov    (%esi),%eax
f0101039:	89 83 20 23 00 00    	mov    %eax,0x2320(%ebx)
    return_page->pp_link = NULL; //将该页面的link指向NULL
f010103f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (alloc_flags & ALLOC_ZERO){ //如果是要分配的页面，则以‘\0’填充
f0101045:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101049:	75 09                	jne    f0101054 <page_alloc+0x37>
}
f010104b:	89 f0                	mov    %esi,%eax
f010104d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101050:	5b                   	pop    %ebx
f0101051:	5e                   	pop    %esi
f0101052:	5d                   	pop    %ebp
f0101053:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101054:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f010105a:	89 f2                	mov    %esi,%edx
f010105c:	2b 10                	sub    (%eax),%edx
f010105e:	89 d0                	mov    %edx,%eax
f0101060:	c1 f8 03             	sar    $0x3,%eax
f0101063:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101066:	89 c1                	mov    %eax,%ecx
f0101068:	c1 e9 0c             	shr    $0xc,%ecx
f010106b:	c7 c2 04 d0 18 f0    	mov    $0xf018d004,%edx
f0101071:	3b 0a                	cmp    (%edx),%ecx
f0101073:	73 1a                	jae    f010108f <page_alloc+0x72>
        memset(page2kva(return_page), '\0', PGSIZE);
f0101075:	83 ec 04             	sub    $0x4,%esp
f0101078:	68 00 10 00 00       	push   $0x1000
f010107d:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010107f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101084:	50                   	push   %eax
f0101085:	e8 20 41 00 00       	call   f01051aa <memset>
f010108a:	83 c4 10             	add    $0x10,%esp
f010108d:	eb bc                	jmp    f010104b <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010108f:	50                   	push   %eax
f0101090:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0101096:	50                   	push   %eax
f0101097:	6a 56                	push   $0x56
f0101099:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f010109f:	50                   	push   %eax
f01010a0:	e8 0c f0 ff ff       	call   f01000b1 <_panic>

f01010a5 <page_free>:
{
f01010a5:	55                   	push   %ebp
f01010a6:	89 e5                	mov    %esp,%ebp
f01010a8:	53                   	push   %ebx
f01010a9:	83 ec 04             	sub    $0x4,%esp
f01010ac:	e8 b6 f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01010b1:	81 c3 6f 8f 08 00    	add    $0x88f6f,%ebx
f01010b7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != 0) {
f01010ba:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010bf:	75 18                	jne    f01010d9 <page_free+0x34>
f01010c1:	83 38 00             	cmpl   $0x0,(%eax)
f01010c4:	75 13                	jne    f01010d9 <page_free+0x34>
	pp->pp_link = page_free_list;
f01010c6:	8b 8b 20 23 00 00    	mov    0x2320(%ebx),%ecx
f01010cc:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f01010ce:	89 83 20 23 00 00    	mov    %eax,0x2320(%ebx)
}
f01010d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010d7:	c9                   	leave  
f01010d8:	c3                   	ret    
	    panic("You are trying to free a page in use, wrong operation");
f01010d9:	83 ec 04             	sub    $0x4,%esp
f01010dc:	8d 83 f8 bb f7 ff    	lea    -0x84408(%ebx),%eax
f01010e2:	50                   	push   %eax
f01010e3:	68 81 01 00 00       	push   $0x181
f01010e8:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01010ee:	50                   	push   %eax
f01010ef:	e8 bd ef ff ff       	call   f01000b1 <_panic>

f01010f4 <page_decref>:
{
f01010f4:	55                   	push   %ebp
f01010f5:	89 e5                	mov    %esp,%ebp
f01010f7:	83 ec 08             	sub    $0x8,%esp
f01010fa:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010fd:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101101:	83 e8 01             	sub    $0x1,%eax
f0101104:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101108:	66 85 c0             	test   %ax,%ax
f010110b:	74 02                	je     f010110f <page_decref+0x1b>
}
f010110d:	c9                   	leave  
f010110e:	c3                   	ret    
		page_free(pp);
f010110f:	83 ec 0c             	sub    $0xc,%esp
f0101112:	52                   	push   %edx
f0101113:	e8 8d ff ff ff       	call   f01010a5 <page_free>
f0101118:	83 c4 10             	add    $0x10,%esp
}
f010111b:	eb f0                	jmp    f010110d <page_decref+0x19>

f010111d <pgdir_walk>:
{
f010111d:	55                   	push   %ebp
f010111e:	89 e5                	mov    %esp,%ebp
f0101120:	57                   	push   %edi
f0101121:	56                   	push   %esi
f0101122:	53                   	push   %ebx
f0101123:	83 ec 1c             	sub    $0x1c,%esp
f0101126:	e8 3c f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010112b:	81 c3 f5 8e 08 00    	add    $0x88ef5,%ebx
f0101131:	8b 75 0c             	mov    0xc(%ebp),%esi
	uint32_t pdIndex = PDX(va), ptIndex = PTX(va); //获取VA在页目录（一级页表）和页表（二级页表）中的索引
f0101134:	89 f0                	mov    %esi,%eax
f0101136:	c1 e8 0c             	shr    $0xc,%eax
f0101139:	25 ff 03 00 00       	and    $0x3ff,%eax
f010113e:	89 c7                	mov    %eax,%edi
f0101140:	c1 ee 16             	shr    $0x16,%esi
	pde_t * pde = &pgdir[pdIndex]; //目录页表项（一级页表）指针
f0101143:	c1 e6 02             	shl    $0x2,%esi
f0101146:	03 75 08             	add    0x8(%ebp),%esi
	if(*pde & PTE_P){ // 判断VA所对应的二级页表是否已经存在
f0101149:	8b 16                	mov    (%esi),%edx
f010114b:	f6 c2 01             	test   $0x1,%dl
f010114e:	74 3f                	je     f010118f <pgdir_walk+0x72>
		pte = (KADDR(PTE_ADDR(*pde))); // 获取表项页表的PTE（转换为虚拟地址）
f0101150:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101156:	89 d0                	mov    %edx,%eax
f0101158:	c1 e8 0c             	shr    $0xc,%eax
f010115b:	c7 c1 04 d0 18 f0    	mov    $0xf018d004,%ecx
f0101161:	39 01                	cmp    %eax,(%ecx)
f0101163:	76 11                	jbe    f0101176 <pgdir_walk+0x59>
	return (void *)(pa + KERNBASE);
f0101165:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
	return &pte[ptIndex]; //返回页表项
f010116b:	8d 04 ba             	lea    (%edx,%edi,4),%eax
}
f010116e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101171:	5b                   	pop    %ebx
f0101172:	5e                   	pop    %esi
f0101173:	5f                   	pop    %edi
f0101174:	5d                   	pop    %ebp
f0101175:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101176:	52                   	push   %edx
f0101177:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f010117d:	50                   	push   %eax
f010117e:	68 b5 01 00 00       	push   $0x1b5
f0101183:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0101189:	50                   	push   %eax
f010118a:	e8 22 ef ff ff       	call   f01000b1 <_panic>
		if(create && (NewPage = page_alloc(ALLOC_ZERO))){ //如果允许创建且能够成功创建
f010118f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101193:	0f 84 8e 00 00 00    	je     f0101227 <pgdir_walk+0x10a>
f0101199:	83 ec 0c             	sub    $0xc,%esp
f010119c:	6a 01                	push   $0x1
f010119e:	e8 7a fe ff ff       	call   f010101d <page_alloc>
f01011a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01011a6:	83 c4 10             	add    $0x10,%esp
f01011a9:	85 c0                	test   %eax,%eax
f01011ab:	0f 84 80 00 00 00    	je     f0101231 <pgdir_walk+0x114>
	return (pp - pages) << PGSHIFT;
f01011b1:	c7 c2 0c d0 18 f0    	mov    $0xf018d00c,%edx
f01011b7:	89 c1                	mov    %eax,%ecx
f01011b9:	2b 0a                	sub    (%edx),%ecx
f01011bb:	c1 f9 03             	sar    $0x3,%ecx
f01011be:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f01011c1:	89 ca                	mov    %ecx,%edx
f01011c3:	c1 ea 0c             	shr    $0xc,%edx
f01011c6:	89 d0                	mov    %edx,%eax
f01011c8:	c7 c2 04 d0 18 f0    	mov    $0xf018d004,%edx
f01011ce:	3b 02                	cmp    (%edx),%eax
f01011d0:	73 26                	jae    f01011f8 <pgdir_walk+0xdb>
	return (void *)(pa + KERNBASE);
f01011d2:	8d 91 00 00 00 f0    	lea    -0x10000000(%ecx),%edx
f01011d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			NewPage->pp_ref++; //引用数增加
f01011de:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011e1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if ((uint32_t)kva < KERNBASE)
f01011e6:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01011ec:	76 20                	jbe    f010120e <pgdir_walk+0xf1>
			*pde = PADDR(pte) | PTE_P | PTE_W | PTE_U;  //设置页目录项
f01011ee:	83 c9 07             	or     $0x7,%ecx
f01011f1:	89 0e                	mov    %ecx,(%esi)
f01011f3:	e9 73 ff ff ff       	jmp    f010116b <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011f8:	51                   	push   %ecx
f01011f9:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f01011ff:	50                   	push   %eax
f0101200:	6a 56                	push   $0x56
f0101202:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f0101208:	50                   	push   %eax
f0101209:	e8 a3 ee ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010120e:	52                   	push   %edx
f010120f:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0101215:	50                   	push   %eax
f0101216:	68 bb 01 00 00       	push   $0x1bb
f010121b:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0101221:	50                   	push   %eax
f0101222:	e8 8a ee ff ff       	call   f01000b1 <_panic>
			return NULL;
f0101227:	b8 00 00 00 00       	mov    $0x0,%eax
f010122c:	e9 3d ff ff ff       	jmp    f010116e <pgdir_walk+0x51>
f0101231:	b8 00 00 00 00       	mov    $0x0,%eax
f0101236:	e9 33 ff ff ff       	jmp    f010116e <pgdir_walk+0x51>

f010123b <boot_map_region>:
{
f010123b:	55                   	push   %ebp
f010123c:	89 e5                	mov    %esp,%ebp
f010123e:	57                   	push   %edi
f010123f:	56                   	push   %esi
f0101240:	53                   	push   %ebx
f0101241:	83 ec 1c             	sub    $0x1c,%esp
f0101244:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101247:	8b 45 08             	mov    0x8(%ebp),%eax
	for(i = size; i > 0; i -= PGSIZE){
f010124a:	89 ce                	mov    %ecx,%esi
f010124c:	89 c3                	mov    %eax,%ebx
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1); //va所对应的PTE，不存在的话创建一个
f010124e:	89 d7                	mov    %edx,%edi
f0101250:	29 c7                	sub    %eax,%edi
		*pte= pa | perm | PTE_P; //进行映射，添加permission bits（根据提示写出）
f0101252:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101255:	83 c8 01             	or     $0x1,%eax
f0101258:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for(i = size; i > 0; i -= PGSIZE){
f010125b:	85 f6                	test   %esi,%esi
f010125d:	7e 2d                	jle    f010128c <boot_map_region+0x51>
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1); //va所对应的PTE，不存在的话创建一个
f010125f:	83 ec 04             	sub    $0x4,%esp
f0101262:	6a 01                	push   $0x1
f0101264:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101267:	50                   	push   %eax
f0101268:	ff 75 e4             	pushl  -0x1c(%ebp)
f010126b:	e8 ad fe ff ff       	call   f010111d <pgdir_walk>
		if(pte == NULL){
f0101270:	83 c4 10             	add    $0x10,%esp
f0101273:	85 c0                	test   %eax,%eax
f0101275:	74 15                	je     f010128c <boot_map_region+0x51>
		*pte= pa | perm | PTE_P; //进行映射，添加permission bits（根据提示写出）
f0101277:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010127a:	09 da                	or     %ebx,%edx
f010127c:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f010127e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for(i = size; i > 0; i -= PGSIZE){
f0101284:	81 ee 00 10 00 00    	sub    $0x1000,%esi
f010128a:	eb cf                	jmp    f010125b <boot_map_region+0x20>
}
f010128c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010128f:	5b                   	pop    %ebx
f0101290:	5e                   	pop    %esi
f0101291:	5f                   	pop    %edi
f0101292:	5d                   	pop    %ebp
f0101293:	c3                   	ret    

f0101294 <page_lookup>:
{
f0101294:	55                   	push   %ebp
f0101295:	89 e5                	mov    %esp,%ebp
f0101297:	56                   	push   %esi
f0101298:	53                   	push   %ebx
f0101299:	e8 c9 ee ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010129e:	81 c3 82 8d 08 00    	add    $0x88d82,%ebx
f01012a4:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t * pte = pgdir_walk(pgdir, va, 0); //获取VA的PTE
f01012a7:	83 ec 04             	sub    $0x4,%esp
f01012aa:	6a 00                	push   $0x0
f01012ac:	ff 75 0c             	pushl  0xc(%ebp)
f01012af:	ff 75 08             	pushl  0x8(%ebp)
f01012b2:	e8 66 fe ff ff       	call   f010111d <pgdir_walk>
	if(pte == NULL){ //如果VA没有对应的物理页
f01012b7:	83 c4 10             	add    $0x10,%esp
f01012ba:	85 c0                	test   %eax,%eax
f01012bc:	74 3f                	je     f01012fd <page_lookup+0x69>
    if (pte_store){ //如果pte_store不是0，我们应该将pte存入其中
f01012be:	85 f6                	test   %esi,%esi
f01012c0:	74 02                	je     f01012c4 <page_lookup+0x30>
        *pte_store = pte;
f01012c2:	89 06                	mov    %eax,(%esi)
f01012c4:	8b 00                	mov    (%eax),%eax
f01012c6:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012c9:	c7 c2 04 d0 18 f0    	mov    $0xf018d004,%edx
f01012cf:	39 02                	cmp    %eax,(%edx)
f01012d1:	76 12                	jbe    f01012e5 <page_lookup+0x51>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01012d3:	c7 c2 0c d0 18 f0    	mov    $0xf018d00c,%edx
f01012d9:	8b 12                	mov    (%edx),%edx
f01012db:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01012de:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012e1:	5b                   	pop    %ebx
f01012e2:	5e                   	pop    %esi
f01012e3:	5d                   	pop    %ebp
f01012e4:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01012e5:	83 ec 04             	sub    $0x4,%esp
f01012e8:	8d 83 30 bc f7 ff    	lea    -0x843d0(%ebx),%eax
f01012ee:	50                   	push   %eax
f01012ef:	6a 4f                	push   $0x4f
f01012f1:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f01012f7:	50                   	push   %eax
f01012f8:	e8 b4 ed ff ff       	call   f01000b1 <_panic>
		return NULL;
f01012fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0101302:	eb da                	jmp    f01012de <page_lookup+0x4a>

f0101304 <page_remove>:
{
f0101304:	55                   	push   %ebp
f0101305:	89 e5                	mov    %esp,%ebp
f0101307:	53                   	push   %ebx
f0101308:	83 ec 18             	sub    $0x18,%esp
f010130b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo* page = page_lookup(pgdir, va, pte_store);
f010130e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101311:	50                   	push   %eax
f0101312:	53                   	push   %ebx
f0101313:	ff 75 08             	pushl  0x8(%ebp)
f0101316:	e8 79 ff ff ff       	call   f0101294 <page_lookup>
	if(!page){ //如果没有建立的映射，直接返回
f010131b:	83 c4 10             	add    $0x10,%esp
f010131e:	85 c0                	test   %eax,%eax
f0101320:	75 05                	jne    f0101327 <page_remove+0x23>
}
f0101322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101325:	c9                   	leave  
f0101326:	c3                   	ret    
	page_decref(page); //引用数递减，到0的时候直接free掉这个page
f0101327:	83 ec 0c             	sub    $0xc,%esp
f010132a:	50                   	push   %eax
f010132b:	e8 c4 fd ff ff       	call   f01010f4 <page_decref>
	**pte_store = 0; //pte_store置0
f0101330:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101333:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101339:	0f 01 3b             	invlpg (%ebx)
f010133c:	83 c4 10             	add    $0x10,%esp
f010133f:	eb e1                	jmp    f0101322 <page_remove+0x1e>

f0101341 <page_insert>:
{
f0101341:	55                   	push   %ebp
f0101342:	89 e5                	mov    %esp,%ebp
f0101344:	57                   	push   %edi
f0101345:	56                   	push   %esi
f0101346:	53                   	push   %ebx
f0101347:	83 ec 10             	sub    $0x10,%esp
f010134a:	e8 ab 1f 00 00       	call   f01032fa <__x86.get_pc_thunk.di>
f010134f:	81 c7 d1 8c 08 00    	add    $0x88cd1,%edi
f0101355:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 1); // 获得VA的pte，如果没有对应的页则新建一个
f0101358:	6a 01                	push   $0x1
f010135a:	ff 75 10             	pushl  0x10(%ebp)
f010135d:	ff 75 08             	pushl  0x8(%ebp)
f0101360:	e8 b8 fd ff ff       	call   f010111d <pgdir_walk>
    if (pte ==  NULL){ // 如果没有对应的页（这里是没有创建成功），则返回-E_NO_MEM
f0101365:	83 c4 10             	add    $0x10,%esp
f0101368:	85 c0                	test   %eax,%eax
f010136a:	74 73                	je     f01013df <page_insert+0x9e>
f010136c:	89 c3                	mov    %eax,%ebx
    if (*pte & PTE_P){// 该表项是一个物理内存页
f010136e:	8b 00                	mov    (%eax),%eax
f0101370:	a8 01                	test   $0x1,%al
f0101372:	74 2c                	je     f01013a0 <page_insert+0x5f>
        if (PTE_ADDR(*pte) == page2pa(pp)){ //VA已经映射的和当前要映射的是同一个物理页
f0101374:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	return (pp - pages) << PGSHIFT;
f0101379:	c7 c2 0c d0 18 f0    	mov    $0xf018d00c,%edx
f010137f:	89 f1                	mov    %esi,%ecx
f0101381:	2b 0a                	sub    (%edx),%ecx
f0101383:	89 ca                	mov    %ecx,%edx
f0101385:	c1 fa 03             	sar    $0x3,%edx
f0101388:	c1 e2 0c             	shl    $0xc,%edx
f010138b:	39 d0                	cmp    %edx,%eax
f010138d:	74 3f                	je     f01013ce <page_insert+0x8d>
            page_remove(pgdir, va); //删除之前的映射
f010138f:	83 ec 08             	sub    $0x8,%esp
f0101392:	ff 75 10             	pushl  0x10(%ebp)
f0101395:	ff 75 08             	pushl  0x8(%ebp)
f0101398:	e8 67 ff ff ff       	call   f0101304 <page_remove>
f010139d:	83 c4 10             	add    $0x10,%esp
f01013a0:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f01013a6:	89 f1                	mov    %esi,%ecx
f01013a8:	2b 08                	sub    (%eax),%ecx
f01013aa:	89 c8                	mov    %ecx,%eax
f01013ac:	c1 f8 03             	sar    $0x3,%eax
f01013af:	c1 e0 0c             	shl    $0xc,%eax
    *pte = page2pa(pp) | perm | PTE_P; //按照要求更新页面，指针为pte
f01013b2:	8b 55 14             	mov    0x14(%ebp),%edx
f01013b5:	83 ca 01             	or     $0x1,%edx
f01013b8:	09 d0                	or     %edx,%eax
f01013ba:	89 03                	mov    %eax,(%ebx)
    pp->pp_ref++; //更新物理页引用计数
f01013bc:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
    return 0;
f01013c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013c9:	5b                   	pop    %ebx
f01013ca:	5e                   	pop    %esi
f01013cb:	5f                   	pop    %edi
f01013cc:	5d                   	pop    %ebp
f01013cd:	c3                   	ret    
            *pte = page2pa(pp) | perm | PTE_P; //按照要求更新页面
f01013ce:	8b 55 14             	mov    0x14(%ebp),%edx
f01013d1:	83 ca 01             	or     $0x1,%edx
f01013d4:	09 d0                	or     %edx,%eax
f01013d6:	89 03                	mov    %eax,(%ebx)
            return 0;
f01013d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01013dd:	eb e7                	jmp    f01013c6 <page_insert+0x85>
        return -E_NO_MEM;
f01013df:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01013e4:	eb e0                	jmp    f01013c6 <page_insert+0x85>

f01013e6 <mem_init>:
{
f01013e6:	55                   	push   %ebp
f01013e7:	89 e5                	mov    %esp,%ebp
f01013e9:	57                   	push   %edi
f01013ea:	56                   	push   %esi
f01013eb:	53                   	push   %ebx
f01013ec:	83 ec 3c             	sub    $0x3c,%esp
f01013ef:	e8 15 f3 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01013f4:	05 2c 8c 08 00       	add    $0x88c2c,%eax
f01013f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f01013fc:	b8 15 00 00 00       	mov    $0x15,%eax
f0101401:	e8 ae f6 ff ff       	call   f0100ab4 <nvram_read>
f0101406:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101408:	b8 17 00 00 00       	mov    $0x17,%eax
f010140d:	e8 a2 f6 ff ff       	call   f0100ab4 <nvram_read>
f0101412:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101414:	b8 34 00 00 00       	mov    $0x34,%eax
f0101419:	e8 96 f6 ff ff       	call   f0100ab4 <nvram_read>
f010141e:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101421:	85 c0                	test   %eax,%eax
f0101423:	0f 85 f3 00 00 00    	jne    f010151c <mem_init+0x136>
		totalmem = 1 * 1024 + extmem;
f0101429:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010142f:	85 f6                	test   %esi,%esi
f0101431:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101434:	89 c1                	mov    %eax,%ecx
f0101436:	c1 e9 02             	shr    $0x2,%ecx
f0101439:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010143c:	c7 c2 04 d0 18 f0    	mov    $0xf018d004,%edx
f0101442:	89 0a                	mov    %ecx,(%edx)
	npages_basemem = basemem / (PGSIZE / 1024);
f0101444:	89 da                	mov    %ebx,%edx
f0101446:	c1 ea 02             	shr    $0x2,%edx
f0101449:	89 97 24 23 00 00    	mov    %edx,0x2324(%edi)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010144f:	89 c2                	mov    %eax,%edx
f0101451:	29 da                	sub    %ebx,%edx
f0101453:	52                   	push   %edx
f0101454:	53                   	push   %ebx
f0101455:	50                   	push   %eax
f0101456:	8d 87 50 bc f7 ff    	lea    -0x843b0(%edi),%eax
f010145c:	50                   	push   %eax
f010145d:	89 fb                	mov    %edi,%ebx
f010145f:	e8 cd 26 00 00       	call   f0103b31 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101464:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101469:	e8 ed f5 ff ff       	call   f0100a5b <boot_alloc>
f010146e:	c7 c6 08 d0 18 f0    	mov    $0xf018d008,%esi
f0101474:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f0101476:	83 c4 0c             	add    $0xc,%esp
f0101479:	68 00 10 00 00       	push   $0x1000
f010147e:	6a 00                	push   $0x0
f0101480:	50                   	push   %eax
f0101481:	e8 24 3d 00 00       	call   f01051aa <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101486:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101488:	83 c4 10             	add    $0x10,%esp
f010148b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101490:	0f 86 90 00 00 00    	jbe    f0101526 <mem_init+0x140>
	return (physaddr_t)kva - KERNBASE;
f0101496:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010149c:	83 ca 05             	or     $0x5,%edx
f010149f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof (struct PageInfo)); //用boot_alloc申请地址空间
f01014a5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01014a8:	c7 c3 04 d0 18 f0    	mov    $0xf018d004,%ebx
f01014ae:	8b 03                	mov    (%ebx),%eax
f01014b0:	c1 e0 03             	shl    $0x3,%eax
f01014b3:	e8 a3 f5 ff ff       	call   f0100a5b <boot_alloc>
f01014b8:	c7 c6 0c d0 18 f0    	mov    $0xf018d00c,%esi
f01014be:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo)); //初始化pages
f01014c0:	83 ec 04             	sub    $0x4,%esp
f01014c3:	8b 13                	mov    (%ebx),%edx
f01014c5:	c1 e2 03             	shl    $0x3,%edx
f01014c8:	52                   	push   %edx
f01014c9:	6a 00                	push   $0x0
f01014cb:	50                   	push   %eax
f01014cc:	89 fb                	mov    %edi,%ebx
f01014ce:	e8 d7 3c 00 00       	call   f01051aa <memset>
	envs = (struct Env*)boot_alloc(NENV * sizeof(struct Env)); //用boot_alloc申请地址空间
f01014d3:	b8 00 80 01 00       	mov    $0x18000,%eax
f01014d8:	e8 7e f5 ff ff       	call   f0100a5b <boot_alloc>
f01014dd:	c7 c2 4c c3 18 f0    	mov    $0xf018c34c,%edx
f01014e3:	89 02                	mov    %eax,(%edx)
	memset(envs, 0, NENV * sizeof(struct Env)); //初始化envs
f01014e5:	83 c4 0c             	add    $0xc,%esp
f01014e8:	68 00 80 01 00       	push   $0x18000
f01014ed:	6a 00                	push   $0x0
f01014ef:	50                   	push   %eax
f01014f0:	e8 b5 3c 00 00       	call   f01051aa <memset>
	page_init();
f01014f5:	e8 f0 f9 ff ff       	call   f0100eea <page_init>
	check_page_free_list(1);
f01014fa:	b8 01 00 00 00       	mov    $0x1,%eax
f01014ff:	e8 63 f6 ff ff       	call   f0100b67 <check_page_free_list>
	if (!pages)
f0101504:	83 c4 10             	add    $0x10,%esp
f0101507:	83 3e 00             	cmpl   $0x0,(%esi)
f010150a:	74 36                	je     f0101542 <mem_init+0x15c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010150c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010150f:	8b 80 20 23 00 00    	mov    0x2320(%eax),%eax
f0101515:	be 00 00 00 00       	mov    $0x0,%esi
f010151a:	eb 49                	jmp    f0101565 <mem_init+0x17f>
		totalmem = 16 * 1024 + ext16mem;
f010151c:	05 00 40 00 00       	add    $0x4000,%eax
f0101521:	e9 0e ff ff ff       	jmp    f0101434 <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101526:	50                   	push   %eax
f0101527:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010152a:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0101530:	50                   	push   %eax
f0101531:	68 9a 00 00 00       	push   $0x9a
f0101536:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010153c:	50                   	push   %eax
f010153d:	e8 6f eb ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f0101542:	83 ec 04             	sub    $0x4,%esp
f0101545:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101548:	8d 83 97 c3 f7 ff    	lea    -0x83c69(%ebx),%eax
f010154e:	50                   	push   %eax
f010154f:	68 e7 02 00 00       	push   $0x2e7
f0101554:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010155a:	50                   	push   %eax
f010155b:	e8 51 eb ff ff       	call   f01000b1 <_panic>
		++nfree;
f0101560:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101563:	8b 00                	mov    (%eax),%eax
f0101565:	85 c0                	test   %eax,%eax
f0101567:	75 f7                	jne    f0101560 <mem_init+0x17a>
	assert((pp0 = page_alloc(0)));
f0101569:	83 ec 0c             	sub    $0xc,%esp
f010156c:	6a 00                	push   $0x0
f010156e:	e8 aa fa ff ff       	call   f010101d <page_alloc>
f0101573:	89 c3                	mov    %eax,%ebx
f0101575:	83 c4 10             	add    $0x10,%esp
f0101578:	85 c0                	test   %eax,%eax
f010157a:	0f 84 3b 02 00 00    	je     f01017bb <mem_init+0x3d5>
	assert((pp1 = page_alloc(0)));
f0101580:	83 ec 0c             	sub    $0xc,%esp
f0101583:	6a 00                	push   $0x0
f0101585:	e8 93 fa ff ff       	call   f010101d <page_alloc>
f010158a:	89 c7                	mov    %eax,%edi
f010158c:	83 c4 10             	add    $0x10,%esp
f010158f:	85 c0                	test   %eax,%eax
f0101591:	0f 84 46 02 00 00    	je     f01017dd <mem_init+0x3f7>
	assert((pp2 = page_alloc(0)));
f0101597:	83 ec 0c             	sub    $0xc,%esp
f010159a:	6a 00                	push   $0x0
f010159c:	e8 7c fa ff ff       	call   f010101d <page_alloc>
f01015a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01015a4:	83 c4 10             	add    $0x10,%esp
f01015a7:	85 c0                	test   %eax,%eax
f01015a9:	0f 84 50 02 00 00    	je     f01017ff <mem_init+0x419>
	assert(pp1 && pp1 != pp0);
f01015af:	39 fb                	cmp    %edi,%ebx
f01015b1:	0f 84 6a 02 00 00    	je     f0101821 <mem_init+0x43b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015ba:	39 c7                	cmp    %eax,%edi
f01015bc:	0f 84 81 02 00 00    	je     f0101843 <mem_init+0x45d>
f01015c2:	39 c3                	cmp    %eax,%ebx
f01015c4:	0f 84 79 02 00 00    	je     f0101843 <mem_init+0x45d>
	return (pp - pages) << PGSHIFT;
f01015ca:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01015cd:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f01015d3:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015d5:	c7 c0 04 d0 18 f0    	mov    $0xf018d004,%eax
f01015db:	8b 10                	mov    (%eax),%edx
f01015dd:	c1 e2 0c             	shl    $0xc,%edx
f01015e0:	89 d8                	mov    %ebx,%eax
f01015e2:	29 c8                	sub    %ecx,%eax
f01015e4:	c1 f8 03             	sar    $0x3,%eax
f01015e7:	c1 e0 0c             	shl    $0xc,%eax
f01015ea:	39 d0                	cmp    %edx,%eax
f01015ec:	0f 83 73 02 00 00    	jae    f0101865 <mem_init+0x47f>
f01015f2:	89 f8                	mov    %edi,%eax
f01015f4:	29 c8                	sub    %ecx,%eax
f01015f6:	c1 f8 03             	sar    $0x3,%eax
f01015f9:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01015fc:	39 c2                	cmp    %eax,%edx
f01015fe:	0f 86 83 02 00 00    	jbe    f0101887 <mem_init+0x4a1>
f0101604:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101607:	29 c8                	sub    %ecx,%eax
f0101609:	c1 f8 03             	sar    $0x3,%eax
f010160c:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010160f:	39 c2                	cmp    %eax,%edx
f0101611:	0f 86 92 02 00 00    	jbe    f01018a9 <mem_init+0x4c3>
	fl = page_free_list;
f0101617:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010161a:	8b 88 20 23 00 00    	mov    0x2320(%eax),%ecx
f0101620:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101623:	c7 80 20 23 00 00 00 	movl   $0x0,0x2320(%eax)
f010162a:	00 00 00 
	assert(!page_alloc(0));
f010162d:	83 ec 0c             	sub    $0xc,%esp
f0101630:	6a 00                	push   $0x0
f0101632:	e8 e6 f9 ff ff       	call   f010101d <page_alloc>
f0101637:	83 c4 10             	add    $0x10,%esp
f010163a:	85 c0                	test   %eax,%eax
f010163c:	0f 85 89 02 00 00    	jne    f01018cb <mem_init+0x4e5>
	page_free(pp0);
f0101642:	83 ec 0c             	sub    $0xc,%esp
f0101645:	53                   	push   %ebx
f0101646:	e8 5a fa ff ff       	call   f01010a5 <page_free>
	page_free(pp1);
f010164b:	89 3c 24             	mov    %edi,(%esp)
f010164e:	e8 52 fa ff ff       	call   f01010a5 <page_free>
	page_free(pp2);
f0101653:	83 c4 04             	add    $0x4,%esp
f0101656:	ff 75 d0             	pushl  -0x30(%ebp)
f0101659:	e8 47 fa ff ff       	call   f01010a5 <page_free>
	assert((pp0 = page_alloc(0)));
f010165e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101665:	e8 b3 f9 ff ff       	call   f010101d <page_alloc>
f010166a:	89 c7                	mov    %eax,%edi
f010166c:	83 c4 10             	add    $0x10,%esp
f010166f:	85 c0                	test   %eax,%eax
f0101671:	0f 84 76 02 00 00    	je     f01018ed <mem_init+0x507>
	assert((pp1 = page_alloc(0)));
f0101677:	83 ec 0c             	sub    $0xc,%esp
f010167a:	6a 00                	push   $0x0
f010167c:	e8 9c f9 ff ff       	call   f010101d <page_alloc>
f0101681:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101684:	83 c4 10             	add    $0x10,%esp
f0101687:	85 c0                	test   %eax,%eax
f0101689:	0f 84 80 02 00 00    	je     f010190f <mem_init+0x529>
	assert((pp2 = page_alloc(0)));
f010168f:	83 ec 0c             	sub    $0xc,%esp
f0101692:	6a 00                	push   $0x0
f0101694:	e8 84 f9 ff ff       	call   f010101d <page_alloc>
f0101699:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010169c:	83 c4 10             	add    $0x10,%esp
f010169f:	85 c0                	test   %eax,%eax
f01016a1:	0f 84 8a 02 00 00    	je     f0101931 <mem_init+0x54b>
	assert(pp1 && pp1 != pp0);
f01016a7:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f01016aa:	0f 84 a3 02 00 00    	je     f0101953 <mem_init+0x56d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016b0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01016b3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01016b6:	0f 84 b9 02 00 00    	je     f0101975 <mem_init+0x58f>
f01016bc:	39 c7                	cmp    %eax,%edi
f01016be:	0f 84 b1 02 00 00    	je     f0101975 <mem_init+0x58f>
	assert(!page_alloc(0));
f01016c4:	83 ec 0c             	sub    $0xc,%esp
f01016c7:	6a 00                	push   $0x0
f01016c9:	e8 4f f9 ff ff       	call   f010101d <page_alloc>
f01016ce:	83 c4 10             	add    $0x10,%esp
f01016d1:	85 c0                	test   %eax,%eax
f01016d3:	0f 85 be 02 00 00    	jne    f0101997 <mem_init+0x5b1>
f01016d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016dc:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f01016e2:	89 f9                	mov    %edi,%ecx
f01016e4:	2b 08                	sub    (%eax),%ecx
f01016e6:	89 c8                	mov    %ecx,%eax
f01016e8:	c1 f8 03             	sar    $0x3,%eax
f01016eb:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01016ee:	89 c1                	mov    %eax,%ecx
f01016f0:	c1 e9 0c             	shr    $0xc,%ecx
f01016f3:	c7 c2 04 d0 18 f0    	mov    $0xf018d004,%edx
f01016f9:	3b 0a                	cmp    (%edx),%ecx
f01016fb:	0f 83 b8 02 00 00    	jae    f01019b9 <mem_init+0x5d3>
	memset(page2kva(pp0), 1, PGSIZE);
f0101701:	83 ec 04             	sub    $0x4,%esp
f0101704:	68 00 10 00 00       	push   $0x1000
f0101709:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010170b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101710:	50                   	push   %eax
f0101711:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101714:	e8 91 3a 00 00       	call   f01051aa <memset>
	page_free(pp0);
f0101719:	89 3c 24             	mov    %edi,(%esp)
f010171c:	e8 84 f9 ff ff       	call   f01010a5 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101721:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101728:	e8 f0 f8 ff ff       	call   f010101d <page_alloc>
f010172d:	83 c4 10             	add    $0x10,%esp
f0101730:	85 c0                	test   %eax,%eax
f0101732:	0f 84 97 02 00 00    	je     f01019cf <mem_init+0x5e9>
	assert(pp && pp0 == pp);
f0101738:	39 c7                	cmp    %eax,%edi
f010173a:	0f 85 b1 02 00 00    	jne    f01019f1 <mem_init+0x60b>
	return (pp - pages) << PGSHIFT;
f0101740:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101743:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0101749:	89 fa                	mov    %edi,%edx
f010174b:	2b 10                	sub    (%eax),%edx
f010174d:	c1 fa 03             	sar    $0x3,%edx
f0101750:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101753:	89 d1                	mov    %edx,%ecx
f0101755:	c1 e9 0c             	shr    $0xc,%ecx
f0101758:	c7 c0 04 d0 18 f0    	mov    $0xf018d004,%eax
f010175e:	3b 08                	cmp    (%eax),%ecx
f0101760:	0f 83 ad 02 00 00    	jae    f0101a13 <mem_init+0x62d>
	return (void *)(pa + KERNBASE);
f0101766:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010176c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101772:	80 38 00             	cmpb   $0x0,(%eax)
f0101775:	0f 85 ae 02 00 00    	jne    f0101a29 <mem_init+0x643>
f010177b:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f010177e:	39 d0                	cmp    %edx,%eax
f0101780:	75 f0                	jne    f0101772 <mem_init+0x38c>
	page_free_list = fl;
f0101782:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101785:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101788:	89 8b 20 23 00 00    	mov    %ecx,0x2320(%ebx)
	page_free(pp0);
f010178e:	83 ec 0c             	sub    $0xc,%esp
f0101791:	57                   	push   %edi
f0101792:	e8 0e f9 ff ff       	call   f01010a5 <page_free>
	page_free(pp1);
f0101797:	83 c4 04             	add    $0x4,%esp
f010179a:	ff 75 d0             	pushl  -0x30(%ebp)
f010179d:	e8 03 f9 ff ff       	call   f01010a5 <page_free>
	page_free(pp2);
f01017a2:	83 c4 04             	add    $0x4,%esp
f01017a5:	ff 75 cc             	pushl  -0x34(%ebp)
f01017a8:	e8 f8 f8 ff ff       	call   f01010a5 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017ad:	8b 83 20 23 00 00    	mov    0x2320(%ebx),%eax
f01017b3:	83 c4 10             	add    $0x10,%esp
f01017b6:	e9 95 02 00 00       	jmp    f0101a50 <mem_init+0x66a>
	assert((pp0 = page_alloc(0)));
f01017bb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017be:	8d 83 b2 c3 f7 ff    	lea    -0x83c4e(%ebx),%eax
f01017c4:	50                   	push   %eax
f01017c5:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01017cb:	50                   	push   %eax
f01017cc:	68 ef 02 00 00       	push   $0x2ef
f01017d1:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01017d7:	50                   	push   %eax
f01017d8:	e8 d4 e8 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01017dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017e0:	8d 83 c8 c3 f7 ff    	lea    -0x83c38(%ebx),%eax
f01017e6:	50                   	push   %eax
f01017e7:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01017ed:	50                   	push   %eax
f01017ee:	68 f0 02 00 00       	push   $0x2f0
f01017f3:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01017f9:	50                   	push   %eax
f01017fa:	e8 b2 e8 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01017ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101802:	8d 83 de c3 f7 ff    	lea    -0x83c22(%ebx),%eax
f0101808:	50                   	push   %eax
f0101809:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010180f:	50                   	push   %eax
f0101810:	68 f1 02 00 00       	push   $0x2f1
f0101815:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010181b:	50                   	push   %eax
f010181c:	e8 90 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101821:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101824:	8d 83 f4 c3 f7 ff    	lea    -0x83c0c(%ebx),%eax
f010182a:	50                   	push   %eax
f010182b:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0101831:	50                   	push   %eax
f0101832:	68 f4 02 00 00       	push   $0x2f4
f0101837:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010183d:	50                   	push   %eax
f010183e:	e8 6e e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101843:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101846:	8d 83 8c bc f7 ff    	lea    -0x84374(%ebx),%eax
f010184c:	50                   	push   %eax
f010184d:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0101853:	50                   	push   %eax
f0101854:	68 f5 02 00 00       	push   $0x2f5
f0101859:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010185f:	50                   	push   %eax
f0101860:	e8 4c e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101865:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101868:	8d 83 06 c4 f7 ff    	lea    -0x83bfa(%ebx),%eax
f010186e:	50                   	push   %eax
f010186f:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0101875:	50                   	push   %eax
f0101876:	68 f6 02 00 00       	push   $0x2f6
f010187b:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0101881:	50                   	push   %eax
f0101882:	e8 2a e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101887:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010188a:	8d 83 23 c4 f7 ff    	lea    -0x83bdd(%ebx),%eax
f0101890:	50                   	push   %eax
f0101891:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0101897:	50                   	push   %eax
f0101898:	68 f7 02 00 00       	push   $0x2f7
f010189d:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01018a3:	50                   	push   %eax
f01018a4:	e8 08 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01018a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ac:	8d 83 40 c4 f7 ff    	lea    -0x83bc0(%ebx),%eax
f01018b2:	50                   	push   %eax
f01018b3:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01018b9:	50                   	push   %eax
f01018ba:	68 f8 02 00 00       	push   $0x2f8
f01018bf:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01018c5:	50                   	push   %eax
f01018c6:	e8 e6 e7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01018cb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ce:	8d 83 5d c4 f7 ff    	lea    -0x83ba3(%ebx),%eax
f01018d4:	50                   	push   %eax
f01018d5:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01018db:	50                   	push   %eax
f01018dc:	68 ff 02 00 00       	push   $0x2ff
f01018e1:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01018e7:	50                   	push   %eax
f01018e8:	e8 c4 e7 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01018ed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018f0:	8d 83 b2 c3 f7 ff    	lea    -0x83c4e(%ebx),%eax
f01018f6:	50                   	push   %eax
f01018f7:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01018fd:	50                   	push   %eax
f01018fe:	68 06 03 00 00       	push   $0x306
f0101903:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0101909:	50                   	push   %eax
f010190a:	e8 a2 e7 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f010190f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101912:	8d 83 c8 c3 f7 ff    	lea    -0x83c38(%ebx),%eax
f0101918:	50                   	push   %eax
f0101919:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010191f:	50                   	push   %eax
f0101920:	68 07 03 00 00       	push   $0x307
f0101925:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010192b:	50                   	push   %eax
f010192c:	e8 80 e7 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101931:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101934:	8d 83 de c3 f7 ff    	lea    -0x83c22(%ebx),%eax
f010193a:	50                   	push   %eax
f010193b:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0101941:	50                   	push   %eax
f0101942:	68 08 03 00 00       	push   $0x308
f0101947:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010194d:	50                   	push   %eax
f010194e:	e8 5e e7 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101953:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101956:	8d 83 f4 c3 f7 ff    	lea    -0x83c0c(%ebx),%eax
f010195c:	50                   	push   %eax
f010195d:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0101963:	50                   	push   %eax
f0101964:	68 0a 03 00 00       	push   $0x30a
f0101969:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010196f:	50                   	push   %eax
f0101970:	e8 3c e7 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101975:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101978:	8d 83 8c bc f7 ff    	lea    -0x84374(%ebx),%eax
f010197e:	50                   	push   %eax
f010197f:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0101985:	50                   	push   %eax
f0101986:	68 0b 03 00 00       	push   $0x30b
f010198b:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0101991:	50                   	push   %eax
f0101992:	e8 1a e7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101997:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010199a:	8d 83 5d c4 f7 ff    	lea    -0x83ba3(%ebx),%eax
f01019a0:	50                   	push   %eax
f01019a1:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01019a7:	50                   	push   %eax
f01019a8:	68 0c 03 00 00       	push   $0x30c
f01019ad:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01019b3:	50                   	push   %eax
f01019b4:	e8 f8 e6 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019b9:	50                   	push   %eax
f01019ba:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f01019c0:	50                   	push   %eax
f01019c1:	6a 56                	push   $0x56
f01019c3:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f01019c9:	50                   	push   %eax
f01019ca:	e8 e2 e6 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019d2:	8d 83 6c c4 f7 ff    	lea    -0x83b94(%ebx),%eax
f01019d8:	50                   	push   %eax
f01019d9:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01019df:	50                   	push   %eax
f01019e0:	68 11 03 00 00       	push   $0x311
f01019e5:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01019eb:	50                   	push   %eax
f01019ec:	e8 c0 e6 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f01019f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019f4:	8d 83 8a c4 f7 ff    	lea    -0x83b76(%ebx),%eax
f01019fa:	50                   	push   %eax
f01019fb:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0101a01:	50                   	push   %eax
f0101a02:	68 12 03 00 00       	push   $0x312
f0101a07:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0101a0d:	50                   	push   %eax
f0101a0e:	e8 9e e6 ff ff       	call   f01000b1 <_panic>
f0101a13:	52                   	push   %edx
f0101a14:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0101a1a:	50                   	push   %eax
f0101a1b:	6a 56                	push   $0x56
f0101a1d:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f0101a23:	50                   	push   %eax
f0101a24:	e8 88 e6 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f0101a29:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a2c:	8d 83 9a c4 f7 ff    	lea    -0x83b66(%ebx),%eax
f0101a32:	50                   	push   %eax
f0101a33:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0101a39:	50                   	push   %eax
f0101a3a:	68 15 03 00 00       	push   $0x315
f0101a3f:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0101a45:	50                   	push   %eax
f0101a46:	e8 66 e6 ff ff       	call   f01000b1 <_panic>
		--nfree;
f0101a4b:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a4e:	8b 00                	mov    (%eax),%eax
f0101a50:	85 c0                	test   %eax,%eax
f0101a52:	75 f7                	jne    f0101a4b <mem_init+0x665>
	assert(nfree == 0);
f0101a54:	85 f6                	test   %esi,%esi
f0101a56:	0f 85 6f 08 00 00    	jne    f01022cb <mem_init+0xee5>
	cprintf("check_page_alloc() succeeded!\n");
f0101a5c:	83 ec 0c             	sub    $0xc,%esp
f0101a5f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a62:	8d 83 ac bc f7 ff    	lea    -0x84354(%ebx),%eax
f0101a68:	50                   	push   %eax
f0101a69:	e8 c3 20 00 00       	call   f0103b31 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a75:	e8 a3 f5 ff ff       	call   f010101d <page_alloc>
f0101a7a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a7d:	83 c4 10             	add    $0x10,%esp
f0101a80:	85 c0                	test   %eax,%eax
f0101a82:	0f 84 65 08 00 00    	je     f01022ed <mem_init+0xf07>
	assert((pp1 = page_alloc(0)));
f0101a88:	83 ec 0c             	sub    $0xc,%esp
f0101a8b:	6a 00                	push   $0x0
f0101a8d:	e8 8b f5 ff ff       	call   f010101d <page_alloc>
f0101a92:	89 c7                	mov    %eax,%edi
f0101a94:	83 c4 10             	add    $0x10,%esp
f0101a97:	85 c0                	test   %eax,%eax
f0101a99:	0f 84 70 08 00 00    	je     f010230f <mem_init+0xf29>
	assert((pp2 = page_alloc(0)));
f0101a9f:	83 ec 0c             	sub    $0xc,%esp
f0101aa2:	6a 00                	push   $0x0
f0101aa4:	e8 74 f5 ff ff       	call   f010101d <page_alloc>
f0101aa9:	89 c6                	mov    %eax,%esi
f0101aab:	83 c4 10             	add    $0x10,%esp
f0101aae:	85 c0                	test   %eax,%eax
f0101ab0:	0f 84 7b 08 00 00    	je     f0102331 <mem_init+0xf4b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ab6:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101ab9:	0f 84 94 08 00 00    	je     f0102353 <mem_init+0xf6d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101abf:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101ac2:	0f 84 ad 08 00 00    	je     f0102375 <mem_init+0xf8f>
f0101ac8:	39 c7                	cmp    %eax,%edi
f0101aca:	0f 84 a5 08 00 00    	je     f0102375 <mem_init+0xf8f>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ad0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ad3:	8b 88 20 23 00 00    	mov    0x2320(%eax),%ecx
f0101ad9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101adc:	c7 80 20 23 00 00 00 	movl   $0x0,0x2320(%eax)
f0101ae3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ae6:	83 ec 0c             	sub    $0xc,%esp
f0101ae9:	6a 00                	push   $0x0
f0101aeb:	e8 2d f5 ff ff       	call   f010101d <page_alloc>
f0101af0:	83 c4 10             	add    $0x10,%esp
f0101af3:	85 c0                	test   %eax,%eax
f0101af5:	0f 85 9c 08 00 00    	jne    f0102397 <mem_init+0xfb1>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101afb:	83 ec 04             	sub    $0x4,%esp
f0101afe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b01:	50                   	push   %eax
f0101b02:	6a 00                	push   $0x0
f0101b04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b07:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101b0d:	ff 30                	pushl  (%eax)
f0101b0f:	e8 80 f7 ff ff       	call   f0101294 <page_lookup>
f0101b14:	83 c4 10             	add    $0x10,%esp
f0101b17:	85 c0                	test   %eax,%eax
f0101b19:	0f 85 9a 08 00 00    	jne    f01023b9 <mem_init+0xfd3>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b1f:	6a 02                	push   $0x2
f0101b21:	6a 00                	push   $0x0
f0101b23:	57                   	push   %edi
f0101b24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b27:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101b2d:	ff 30                	pushl  (%eax)
f0101b2f:	e8 0d f8 ff ff       	call   f0101341 <page_insert>
f0101b34:	83 c4 10             	add    $0x10,%esp
f0101b37:	85 c0                	test   %eax,%eax
f0101b39:	0f 89 9c 08 00 00    	jns    f01023db <mem_init+0xff5>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b3f:	83 ec 0c             	sub    $0xc,%esp
f0101b42:	ff 75 d0             	pushl  -0x30(%ebp)
f0101b45:	e8 5b f5 ff ff       	call   f01010a5 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b4a:	6a 02                	push   $0x2
f0101b4c:	6a 00                	push   $0x0
f0101b4e:	57                   	push   %edi
f0101b4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b52:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101b58:	ff 30                	pushl  (%eax)
f0101b5a:	e8 e2 f7 ff ff       	call   f0101341 <page_insert>
f0101b5f:	83 c4 20             	add    $0x20,%esp
f0101b62:	85 c0                	test   %eax,%eax
f0101b64:	0f 85 93 08 00 00    	jne    f01023fd <mem_init+0x1017>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b6a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b6d:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101b73:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101b75:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0101b7b:	8b 08                	mov    (%eax),%ecx
f0101b7d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101b80:	8b 13                	mov    (%ebx),%edx
f0101b82:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b88:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b8b:	29 c8                	sub    %ecx,%eax
f0101b8d:	c1 f8 03             	sar    $0x3,%eax
f0101b90:	c1 e0 0c             	shl    $0xc,%eax
f0101b93:	39 c2                	cmp    %eax,%edx
f0101b95:	0f 85 84 08 00 00    	jne    f010241f <mem_init+0x1039>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b9b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ba0:	89 d8                	mov    %ebx,%eax
f0101ba2:	e8 43 ef ff ff       	call   f0100aea <check_va2pa>
f0101ba7:	89 fa                	mov    %edi,%edx
f0101ba9:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101bac:	c1 fa 03             	sar    $0x3,%edx
f0101baf:	c1 e2 0c             	shl    $0xc,%edx
f0101bb2:	39 d0                	cmp    %edx,%eax
f0101bb4:	0f 85 87 08 00 00    	jne    f0102441 <mem_init+0x105b>
	assert(pp1->pp_ref == 1);
f0101bba:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101bbf:	0f 85 9e 08 00 00    	jne    f0102463 <mem_init+0x107d>
	assert(pp0->pp_ref == 1);
f0101bc5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bc8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bcd:	0f 85 b2 08 00 00    	jne    f0102485 <mem_init+0x109f>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bd3:	6a 02                	push   $0x2
f0101bd5:	68 00 10 00 00       	push   $0x1000
f0101bda:	56                   	push   %esi
f0101bdb:	53                   	push   %ebx
f0101bdc:	e8 60 f7 ff ff       	call   f0101341 <page_insert>
f0101be1:	83 c4 10             	add    $0x10,%esp
f0101be4:	85 c0                	test   %eax,%eax
f0101be6:	0f 85 bb 08 00 00    	jne    f01024a7 <mem_init+0x10c1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bec:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bf1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101bf4:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101bfa:	8b 00                	mov    (%eax),%eax
f0101bfc:	e8 e9 ee ff ff       	call   f0100aea <check_va2pa>
f0101c01:	c7 c2 0c d0 18 f0    	mov    $0xf018d00c,%edx
f0101c07:	89 f1                	mov    %esi,%ecx
f0101c09:	2b 0a                	sub    (%edx),%ecx
f0101c0b:	89 ca                	mov    %ecx,%edx
f0101c0d:	c1 fa 03             	sar    $0x3,%edx
f0101c10:	c1 e2 0c             	shl    $0xc,%edx
f0101c13:	39 d0                	cmp    %edx,%eax
f0101c15:	0f 85 ae 08 00 00    	jne    f01024c9 <mem_init+0x10e3>
	assert(pp2->pp_ref == 1);
f0101c1b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c20:	0f 85 c5 08 00 00    	jne    f01024eb <mem_init+0x1105>

	// should be no free memory
	assert(!page_alloc(0));
f0101c26:	83 ec 0c             	sub    $0xc,%esp
f0101c29:	6a 00                	push   $0x0
f0101c2b:	e8 ed f3 ff ff       	call   f010101d <page_alloc>
f0101c30:	83 c4 10             	add    $0x10,%esp
f0101c33:	85 c0                	test   %eax,%eax
f0101c35:	0f 85 d2 08 00 00    	jne    f010250d <mem_init+0x1127>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c3b:	6a 02                	push   $0x2
f0101c3d:	68 00 10 00 00       	push   $0x1000
f0101c42:	56                   	push   %esi
f0101c43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c46:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101c4c:	ff 30                	pushl  (%eax)
f0101c4e:	e8 ee f6 ff ff       	call   f0101341 <page_insert>
f0101c53:	83 c4 10             	add    $0x10,%esp
f0101c56:	85 c0                	test   %eax,%eax
f0101c58:	0f 85 d1 08 00 00    	jne    f010252f <mem_init+0x1149>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c5e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c63:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c66:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101c6c:	8b 00                	mov    (%eax),%eax
f0101c6e:	e8 77 ee ff ff       	call   f0100aea <check_va2pa>
f0101c73:	c7 c2 0c d0 18 f0    	mov    $0xf018d00c,%edx
f0101c79:	89 f1                	mov    %esi,%ecx
f0101c7b:	2b 0a                	sub    (%edx),%ecx
f0101c7d:	89 ca                	mov    %ecx,%edx
f0101c7f:	c1 fa 03             	sar    $0x3,%edx
f0101c82:	c1 e2 0c             	shl    $0xc,%edx
f0101c85:	39 d0                	cmp    %edx,%eax
f0101c87:	0f 85 c4 08 00 00    	jne    f0102551 <mem_init+0x116b>
	assert(pp2->pp_ref == 1);
f0101c8d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c92:	0f 85 db 08 00 00    	jne    f0102573 <mem_init+0x118d>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c98:	83 ec 0c             	sub    $0xc,%esp
f0101c9b:	6a 00                	push   $0x0
f0101c9d:	e8 7b f3 ff ff       	call   f010101d <page_alloc>
f0101ca2:	83 c4 10             	add    $0x10,%esp
f0101ca5:	85 c0                	test   %eax,%eax
f0101ca7:	0f 85 e8 08 00 00    	jne    f0102595 <mem_init+0x11af>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101cad:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101cb0:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101cb6:	8b 10                	mov    (%eax),%edx
f0101cb8:	8b 02                	mov    (%edx),%eax
f0101cba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101cbf:	89 c3                	mov    %eax,%ebx
f0101cc1:	c1 eb 0c             	shr    $0xc,%ebx
f0101cc4:	c7 c1 04 d0 18 f0    	mov    $0xf018d004,%ecx
f0101cca:	3b 19                	cmp    (%ecx),%ebx
f0101ccc:	0f 83 e5 08 00 00    	jae    f01025b7 <mem_init+0x11d1>
	return (void *)(pa + KERNBASE);
f0101cd2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cd7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101cda:	83 ec 04             	sub    $0x4,%esp
f0101cdd:	6a 00                	push   $0x0
f0101cdf:	68 00 10 00 00       	push   $0x1000
f0101ce4:	52                   	push   %edx
f0101ce5:	e8 33 f4 ff ff       	call   f010111d <pgdir_walk>
f0101cea:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ced:	8d 51 04             	lea    0x4(%ecx),%edx
f0101cf0:	83 c4 10             	add    $0x10,%esp
f0101cf3:	39 d0                	cmp    %edx,%eax
f0101cf5:	0f 85 d8 08 00 00    	jne    f01025d3 <mem_init+0x11ed>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cfb:	6a 06                	push   $0x6
f0101cfd:	68 00 10 00 00       	push   $0x1000
f0101d02:	56                   	push   %esi
f0101d03:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d06:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101d0c:	ff 30                	pushl  (%eax)
f0101d0e:	e8 2e f6 ff ff       	call   f0101341 <page_insert>
f0101d13:	83 c4 10             	add    $0x10,%esp
f0101d16:	85 c0                	test   %eax,%eax
f0101d18:	0f 85 d7 08 00 00    	jne    f01025f5 <mem_init+0x120f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d1e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d21:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101d27:	8b 18                	mov    (%eax),%ebx
f0101d29:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d2e:	89 d8                	mov    %ebx,%eax
f0101d30:	e8 b5 ed ff ff       	call   f0100aea <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101d35:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d38:	c7 c2 0c d0 18 f0    	mov    $0xf018d00c,%edx
f0101d3e:	89 f1                	mov    %esi,%ecx
f0101d40:	2b 0a                	sub    (%edx),%ecx
f0101d42:	89 ca                	mov    %ecx,%edx
f0101d44:	c1 fa 03             	sar    $0x3,%edx
f0101d47:	c1 e2 0c             	shl    $0xc,%edx
f0101d4a:	39 d0                	cmp    %edx,%eax
f0101d4c:	0f 85 c5 08 00 00    	jne    f0102617 <mem_init+0x1231>
	assert(pp2->pp_ref == 1);
f0101d52:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d57:	0f 85 dc 08 00 00    	jne    f0102639 <mem_init+0x1253>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d5d:	83 ec 04             	sub    $0x4,%esp
f0101d60:	6a 00                	push   $0x0
f0101d62:	68 00 10 00 00       	push   $0x1000
f0101d67:	53                   	push   %ebx
f0101d68:	e8 b0 f3 ff ff       	call   f010111d <pgdir_walk>
f0101d6d:	83 c4 10             	add    $0x10,%esp
f0101d70:	f6 00 04             	testb  $0x4,(%eax)
f0101d73:	0f 84 e2 08 00 00    	je     f010265b <mem_init+0x1275>
	assert(kern_pgdir[0] & PTE_U);
f0101d79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d7c:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101d82:	8b 00                	mov    (%eax),%eax
f0101d84:	f6 00 04             	testb  $0x4,(%eax)
f0101d87:	0f 84 f0 08 00 00    	je     f010267d <mem_init+0x1297>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d8d:	6a 02                	push   $0x2
f0101d8f:	68 00 10 00 00       	push   $0x1000
f0101d94:	56                   	push   %esi
f0101d95:	50                   	push   %eax
f0101d96:	e8 a6 f5 ff ff       	call   f0101341 <page_insert>
f0101d9b:	83 c4 10             	add    $0x10,%esp
f0101d9e:	85 c0                	test   %eax,%eax
f0101da0:	0f 85 f9 08 00 00    	jne    f010269f <mem_init+0x12b9>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101da6:	83 ec 04             	sub    $0x4,%esp
f0101da9:	6a 00                	push   $0x0
f0101dab:	68 00 10 00 00       	push   $0x1000
f0101db0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101db3:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101db9:	ff 30                	pushl  (%eax)
f0101dbb:	e8 5d f3 ff ff       	call   f010111d <pgdir_walk>
f0101dc0:	83 c4 10             	add    $0x10,%esp
f0101dc3:	f6 00 02             	testb  $0x2,(%eax)
f0101dc6:	0f 84 f5 08 00 00    	je     f01026c1 <mem_init+0x12db>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dcc:	83 ec 04             	sub    $0x4,%esp
f0101dcf:	6a 00                	push   $0x0
f0101dd1:	68 00 10 00 00       	push   $0x1000
f0101dd6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dd9:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101ddf:	ff 30                	pushl  (%eax)
f0101de1:	e8 37 f3 ff ff       	call   f010111d <pgdir_walk>
f0101de6:	83 c4 10             	add    $0x10,%esp
f0101de9:	f6 00 04             	testb  $0x4,(%eax)
f0101dec:	0f 85 f1 08 00 00    	jne    f01026e3 <mem_init+0x12fd>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101df2:	6a 02                	push   $0x2
f0101df4:	68 00 00 40 00       	push   $0x400000
f0101df9:	ff 75 d0             	pushl  -0x30(%ebp)
f0101dfc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dff:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101e05:	ff 30                	pushl  (%eax)
f0101e07:	e8 35 f5 ff ff       	call   f0101341 <page_insert>
f0101e0c:	83 c4 10             	add    $0x10,%esp
f0101e0f:	85 c0                	test   %eax,%eax
f0101e11:	0f 89 ee 08 00 00    	jns    f0102705 <mem_init+0x131f>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e17:	6a 02                	push   $0x2
f0101e19:	68 00 10 00 00       	push   $0x1000
f0101e1e:	57                   	push   %edi
f0101e1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e22:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101e28:	ff 30                	pushl  (%eax)
f0101e2a:	e8 12 f5 ff ff       	call   f0101341 <page_insert>
f0101e2f:	83 c4 10             	add    $0x10,%esp
f0101e32:	85 c0                	test   %eax,%eax
f0101e34:	0f 85 ed 08 00 00    	jne    f0102727 <mem_init+0x1341>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e3a:	83 ec 04             	sub    $0x4,%esp
f0101e3d:	6a 00                	push   $0x0
f0101e3f:	68 00 10 00 00       	push   $0x1000
f0101e44:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e47:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101e4d:	ff 30                	pushl  (%eax)
f0101e4f:	e8 c9 f2 ff ff       	call   f010111d <pgdir_walk>
f0101e54:	83 c4 10             	add    $0x10,%esp
f0101e57:	f6 00 04             	testb  $0x4,(%eax)
f0101e5a:	0f 85 e9 08 00 00    	jne    f0102749 <mem_init+0x1363>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e63:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0101e69:	8b 18                	mov    (%eax),%ebx
f0101e6b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e70:	89 d8                	mov    %ebx,%eax
f0101e72:	e8 73 ec ff ff       	call   f0100aea <check_va2pa>
f0101e77:	89 c2                	mov    %eax,%edx
f0101e79:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e7c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e7f:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0101e85:	89 f9                	mov    %edi,%ecx
f0101e87:	2b 08                	sub    (%eax),%ecx
f0101e89:	89 c8                	mov    %ecx,%eax
f0101e8b:	c1 f8 03             	sar    $0x3,%eax
f0101e8e:	c1 e0 0c             	shl    $0xc,%eax
f0101e91:	39 c2                	cmp    %eax,%edx
f0101e93:	0f 85 d2 08 00 00    	jne    f010276b <mem_init+0x1385>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e99:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e9e:	89 d8                	mov    %ebx,%eax
f0101ea0:	e8 45 ec ff ff       	call   f0100aea <check_va2pa>
f0101ea5:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ea8:	0f 85 df 08 00 00    	jne    f010278d <mem_init+0x13a7>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101eae:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101eb3:	0f 85 f6 08 00 00    	jne    f01027af <mem_init+0x13c9>
	assert(pp2->pp_ref == 0);
f0101eb9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ebe:	0f 85 0d 09 00 00    	jne    f01027d1 <mem_init+0x13eb>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ec4:	83 ec 0c             	sub    $0xc,%esp
f0101ec7:	6a 00                	push   $0x0
f0101ec9:	e8 4f f1 ff ff       	call   f010101d <page_alloc>
f0101ece:	83 c4 10             	add    $0x10,%esp
f0101ed1:	39 c6                	cmp    %eax,%esi
f0101ed3:	0f 85 1a 09 00 00    	jne    f01027f3 <mem_init+0x140d>
f0101ed9:	85 c0                	test   %eax,%eax
f0101edb:	0f 84 12 09 00 00    	je     f01027f3 <mem_init+0x140d>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ee1:	83 ec 08             	sub    $0x8,%esp
f0101ee4:	6a 00                	push   $0x0
f0101ee6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ee9:	c7 c3 08 d0 18 f0    	mov    $0xf018d008,%ebx
f0101eef:	ff 33                	pushl  (%ebx)
f0101ef1:	e8 0e f4 ff ff       	call   f0101304 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ef6:	8b 1b                	mov    (%ebx),%ebx
f0101ef8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101efd:	89 d8                	mov    %ebx,%eax
f0101eff:	e8 e6 eb ff ff       	call   f0100aea <check_va2pa>
f0101f04:	83 c4 10             	add    $0x10,%esp
f0101f07:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f0a:	0f 85 05 09 00 00    	jne    f0102815 <mem_init+0x142f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f10:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f15:	89 d8                	mov    %ebx,%eax
f0101f17:	e8 ce eb ff ff       	call   f0100aea <check_va2pa>
f0101f1c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f1f:	c7 c2 0c d0 18 f0    	mov    $0xf018d00c,%edx
f0101f25:	89 f9                	mov    %edi,%ecx
f0101f27:	2b 0a                	sub    (%edx),%ecx
f0101f29:	89 ca                	mov    %ecx,%edx
f0101f2b:	c1 fa 03             	sar    $0x3,%edx
f0101f2e:	c1 e2 0c             	shl    $0xc,%edx
f0101f31:	39 d0                	cmp    %edx,%eax
f0101f33:	0f 85 fe 08 00 00    	jne    f0102837 <mem_init+0x1451>
	assert(pp1->pp_ref == 1);
f0101f39:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f3e:	0f 85 15 09 00 00    	jne    f0102859 <mem_init+0x1473>
	assert(pp2->pp_ref == 0);
f0101f44:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f49:	0f 85 2c 09 00 00    	jne    f010287b <mem_init+0x1495>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f4f:	6a 00                	push   $0x0
f0101f51:	68 00 10 00 00       	push   $0x1000
f0101f56:	57                   	push   %edi
f0101f57:	53                   	push   %ebx
f0101f58:	e8 e4 f3 ff ff       	call   f0101341 <page_insert>
f0101f5d:	83 c4 10             	add    $0x10,%esp
f0101f60:	85 c0                	test   %eax,%eax
f0101f62:	0f 85 35 09 00 00    	jne    f010289d <mem_init+0x14b7>
	assert(pp1->pp_ref);
f0101f68:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f6d:	0f 84 4c 09 00 00    	je     f01028bf <mem_init+0x14d9>
	assert(pp1->pp_link == NULL);
f0101f73:	83 3f 00             	cmpl   $0x0,(%edi)
f0101f76:	0f 85 65 09 00 00    	jne    f01028e1 <mem_init+0x14fb>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f7c:	83 ec 08             	sub    $0x8,%esp
f0101f7f:	68 00 10 00 00       	push   $0x1000
f0101f84:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f87:	c7 c3 08 d0 18 f0    	mov    $0xf018d008,%ebx
f0101f8d:	ff 33                	pushl  (%ebx)
f0101f8f:	e8 70 f3 ff ff       	call   f0101304 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f94:	8b 1b                	mov    (%ebx),%ebx
f0101f96:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f9b:	89 d8                	mov    %ebx,%eax
f0101f9d:	e8 48 eb ff ff       	call   f0100aea <check_va2pa>
f0101fa2:	83 c4 10             	add    $0x10,%esp
f0101fa5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa8:	0f 85 55 09 00 00    	jne    f0102903 <mem_init+0x151d>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fae:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fb3:	89 d8                	mov    %ebx,%eax
f0101fb5:	e8 30 eb ff ff       	call   f0100aea <check_va2pa>
f0101fba:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fbd:	0f 85 62 09 00 00    	jne    f0102925 <mem_init+0x153f>
	assert(pp1->pp_ref == 0);
f0101fc3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101fc8:	0f 85 79 09 00 00    	jne    f0102947 <mem_init+0x1561>
	assert(pp2->pp_ref == 0);
f0101fce:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fd3:	0f 85 90 09 00 00    	jne    f0102969 <mem_init+0x1583>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101fd9:	83 ec 0c             	sub    $0xc,%esp
f0101fdc:	6a 00                	push   $0x0
f0101fde:	e8 3a f0 ff ff       	call   f010101d <page_alloc>
f0101fe3:	83 c4 10             	add    $0x10,%esp
f0101fe6:	85 c0                	test   %eax,%eax
f0101fe8:	0f 84 9d 09 00 00    	je     f010298b <mem_init+0x15a5>
f0101fee:	39 c7                	cmp    %eax,%edi
f0101ff0:	0f 85 95 09 00 00    	jne    f010298b <mem_init+0x15a5>

	// should be no free memory
	assert(!page_alloc(0));
f0101ff6:	83 ec 0c             	sub    $0xc,%esp
f0101ff9:	6a 00                	push   $0x0
f0101ffb:	e8 1d f0 ff ff       	call   f010101d <page_alloc>
f0102000:	83 c4 10             	add    $0x10,%esp
f0102003:	85 c0                	test   %eax,%eax
f0102005:	0f 85 a2 09 00 00    	jne    f01029ad <mem_init+0x15c7>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010200b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010200e:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0102014:	8b 08                	mov    (%eax),%ecx
f0102016:	8b 11                	mov    (%ecx),%edx
f0102018:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010201e:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0102024:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102027:	2b 18                	sub    (%eax),%ebx
f0102029:	89 d8                	mov    %ebx,%eax
f010202b:	c1 f8 03             	sar    $0x3,%eax
f010202e:	c1 e0 0c             	shl    $0xc,%eax
f0102031:	39 c2                	cmp    %eax,%edx
f0102033:	0f 85 96 09 00 00    	jne    f01029cf <mem_init+0x15e9>
	kern_pgdir[0] = 0;
f0102039:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010203f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102042:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102047:	0f 85 a4 09 00 00    	jne    f01029f1 <mem_init+0x160b>
	pp0->pp_ref = 0;
f010204d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102050:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102056:	83 ec 0c             	sub    $0xc,%esp
f0102059:	50                   	push   %eax
f010205a:	e8 46 f0 ff ff       	call   f01010a5 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010205f:	83 c4 0c             	add    $0xc,%esp
f0102062:	6a 01                	push   $0x1
f0102064:	68 00 10 40 00       	push   $0x401000
f0102069:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010206c:	c7 c3 08 d0 18 f0    	mov    $0xf018d008,%ebx
f0102072:	ff 33                	pushl  (%ebx)
f0102074:	e8 a4 f0 ff ff       	call   f010111d <pgdir_walk>
f0102079:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010207c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010207f:	8b 1b                	mov    (%ebx),%ebx
f0102081:	8b 53 04             	mov    0x4(%ebx),%edx
f0102084:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010208a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010208d:	c7 c1 04 d0 18 f0    	mov    $0xf018d004,%ecx
f0102093:	8b 09                	mov    (%ecx),%ecx
f0102095:	89 d0                	mov    %edx,%eax
f0102097:	c1 e8 0c             	shr    $0xc,%eax
f010209a:	83 c4 10             	add    $0x10,%esp
f010209d:	39 c8                	cmp    %ecx,%eax
f010209f:	0f 83 6e 09 00 00    	jae    f0102a13 <mem_init+0x162d>
	assert(ptep == ptep1 + PTX(va));
f01020a5:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01020ab:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f01020ae:	0f 85 7b 09 00 00    	jne    f0102a2f <mem_init+0x1649>
	kern_pgdir[PDX(va)] = 0;
f01020b4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f01020bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01020be:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f01020c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020c7:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f01020cd:	2b 18                	sub    (%eax),%ebx
f01020cf:	89 d8                	mov    %ebx,%eax
f01020d1:	c1 f8 03             	sar    $0x3,%eax
f01020d4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01020d7:	89 c2                	mov    %eax,%edx
f01020d9:	c1 ea 0c             	shr    $0xc,%edx
f01020dc:	39 d1                	cmp    %edx,%ecx
f01020de:	0f 86 6d 09 00 00    	jbe    f0102a51 <mem_init+0x166b>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020e4:	83 ec 04             	sub    $0x4,%esp
f01020e7:	68 00 10 00 00       	push   $0x1000
f01020ec:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01020f1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020f6:	50                   	push   %eax
f01020f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020fa:	e8 ab 30 00 00       	call   f01051aa <memset>
	page_free(pp0);
f01020ff:	83 c4 04             	add    $0x4,%esp
f0102102:	ff 75 d0             	pushl  -0x30(%ebp)
f0102105:	e8 9b ef ff ff       	call   f01010a5 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010210a:	83 c4 0c             	add    $0xc,%esp
f010210d:	6a 01                	push   $0x1
f010210f:	6a 00                	push   $0x0
f0102111:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102114:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f010211a:	ff 30                	pushl  (%eax)
f010211c:	e8 fc ef ff ff       	call   f010111d <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102121:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0102127:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010212a:	2b 10                	sub    (%eax),%edx
f010212c:	c1 fa 03             	sar    $0x3,%edx
f010212f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102132:	89 d1                	mov    %edx,%ecx
f0102134:	c1 e9 0c             	shr    $0xc,%ecx
f0102137:	83 c4 10             	add    $0x10,%esp
f010213a:	c7 c0 04 d0 18 f0    	mov    $0xf018d004,%eax
f0102140:	3b 08                	cmp    (%eax),%ecx
f0102142:	0f 83 22 09 00 00    	jae    f0102a6a <mem_init+0x1684>
	return (void *)(pa + KERNBASE);
f0102148:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010214e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102151:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102157:	f6 00 01             	testb  $0x1,(%eax)
f010215a:	0f 85 23 09 00 00    	jne    f0102a83 <mem_init+0x169d>
f0102160:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102163:	39 d0                	cmp    %edx,%eax
f0102165:	75 f0                	jne    f0102157 <mem_init+0xd71>
	kern_pgdir[0] = 0;
f0102167:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010216a:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0102170:	8b 00                	mov    (%eax),%eax
f0102172:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102178:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010217b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102181:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102184:	89 93 20 23 00 00    	mov    %edx,0x2320(%ebx)

	// free the pages we took
	page_free(pp0);
f010218a:	83 ec 0c             	sub    $0xc,%esp
f010218d:	50                   	push   %eax
f010218e:	e8 12 ef ff ff       	call   f01010a5 <page_free>
	page_free(pp1);
f0102193:	89 3c 24             	mov    %edi,(%esp)
f0102196:	e8 0a ef ff ff       	call   f01010a5 <page_free>
	page_free(pp2);
f010219b:	89 34 24             	mov    %esi,(%esp)
f010219e:	e8 02 ef ff ff       	call   f01010a5 <page_free>

	cprintf("check_page() succeeded!\n");
f01021a3:	8d 83 7b c5 f7 ff    	lea    -0x83a85(%ebx),%eax
f01021a9:	89 04 24             	mov    %eax,(%esp)
f01021ac:	e8 80 19 00 00       	call   f0103b31 <cprintf>
	int size = ROUNDUP((sizeof(struct PageInfo)*npages), PGSIZE);
f01021b1:	c7 c0 04 d0 18 f0    	mov    $0xf018d004,%eax
f01021b7:	8b 00                	mov    (%eax),%eax
f01021b9:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f01021c0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, size, PADDR(pages), (PTE_U | PTE_P));
f01021c6:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f01021cc:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01021ce:	83 c4 10             	add    $0x10,%esp
f01021d1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021d6:	0f 86 c9 08 00 00    	jbe    f0102aa5 <mem_init+0x16bf>
f01021dc:	83 ec 08             	sub    $0x8,%esp
f01021df:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021e1:	05 00 00 00 10       	add    $0x10000000,%eax
f01021e6:	50                   	push   %eax
f01021e7:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01021ec:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01021ef:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f01021f5:	8b 00                	mov    (%eax),%eax
f01021f7:	e8 3f f0 ff ff       	call   f010123b <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, size, PADDR(envs), (PTE_U | PTE_P));
f01021fc:	c7 c0 4c c3 18 f0    	mov    $0xf018c34c,%eax
f0102202:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102204:	83 c4 10             	add    $0x10,%esp
f0102207:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010220c:	0f 86 af 08 00 00    	jbe    f0102ac1 <mem_init+0x16db>
f0102212:	83 ec 08             	sub    $0x8,%esp
f0102215:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102217:	05 00 00 00 10       	add    $0x10000000,%eax
f010221c:	50                   	push   %eax
f010221d:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102222:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102227:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010222a:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0102230:	8b 00                	mov    (%eax),%eax
f0102232:	e8 04 f0 ff ff       	call   f010123b <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102237:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
f010223d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102240:	83 c4 10             	add    $0x10,%esp
f0102243:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102248:	0f 86 8f 08 00 00    	jbe    f0102add <mem_init+0x16f7>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, size, PADDR(bootstack),  (PTE_W | PTE_P));
f010224e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102251:	c7 c3 08 d0 18 f0    	mov    $0xf018d008,%ebx
f0102257:	83 ec 08             	sub    $0x8,%esp
f010225a:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f010225c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010225f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102264:	50                   	push   %eax
f0102265:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010226a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010226f:	8b 03                	mov    (%ebx),%eax
f0102271:	e8 c5 ef ff ff       	call   f010123b <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, size, 0, (PTE_W | PTE_P));
f0102276:	83 c4 08             	add    $0x8,%esp
f0102279:	6a 03                	push   $0x3
f010227b:	6a 00                	push   $0x0
f010227d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102282:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102287:	8b 03                	mov    (%ebx),%eax
f0102289:	e8 ad ef ff ff       	call   f010123b <boot_map_region>
	pgdir = kern_pgdir;
f010228e:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102290:	c7 c0 04 d0 18 f0    	mov    $0xf018d004,%eax
f0102296:	8b 00                	mov    (%eax),%eax
f0102298:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010229b:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01022a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022aa:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f01022b0:	8b 00                	mov    (%eax),%eax
f01022b2:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01022b5:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01022b8:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f01022be:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f01022c1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01022c6:	e9 57 08 00 00       	jmp    f0102b22 <mem_init+0x173c>
	assert(nfree == 0);
f01022cb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022ce:	8d 83 a4 c4 f7 ff    	lea    -0x83b5c(%ebx),%eax
f01022d4:	50                   	push   %eax
f01022d5:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01022db:	50                   	push   %eax
f01022dc:	68 22 03 00 00       	push   $0x322
f01022e1:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01022e7:	50                   	push   %eax
f01022e8:	e8 c4 dd ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01022ed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022f0:	8d 83 b2 c3 f7 ff    	lea    -0x83c4e(%ebx),%eax
f01022f6:	50                   	push   %eax
f01022f7:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01022fd:	50                   	push   %eax
f01022fe:	68 80 03 00 00       	push   $0x380
f0102303:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102309:	50                   	push   %eax
f010230a:	e8 a2 dd ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f010230f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102312:	8d 83 c8 c3 f7 ff    	lea    -0x83c38(%ebx),%eax
f0102318:	50                   	push   %eax
f0102319:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010231f:	50                   	push   %eax
f0102320:	68 81 03 00 00       	push   $0x381
f0102325:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010232b:	50                   	push   %eax
f010232c:	e8 80 dd ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102331:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102334:	8d 83 de c3 f7 ff    	lea    -0x83c22(%ebx),%eax
f010233a:	50                   	push   %eax
f010233b:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102341:	50                   	push   %eax
f0102342:	68 82 03 00 00       	push   $0x382
f0102347:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010234d:	50                   	push   %eax
f010234e:	e8 5e dd ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0102353:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102356:	8d 83 f4 c3 f7 ff    	lea    -0x83c0c(%ebx),%eax
f010235c:	50                   	push   %eax
f010235d:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102363:	50                   	push   %eax
f0102364:	68 85 03 00 00       	push   $0x385
f0102369:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010236f:	50                   	push   %eax
f0102370:	e8 3c dd ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102375:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102378:	8d 83 8c bc f7 ff    	lea    -0x84374(%ebx),%eax
f010237e:	50                   	push   %eax
f010237f:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102385:	50                   	push   %eax
f0102386:	68 86 03 00 00       	push   $0x386
f010238b:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102391:	50                   	push   %eax
f0102392:	e8 1a dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102397:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010239a:	8d 83 5d c4 f7 ff    	lea    -0x83ba3(%ebx),%eax
f01023a0:	50                   	push   %eax
f01023a1:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01023a7:	50                   	push   %eax
f01023a8:	68 8d 03 00 00       	push   $0x38d
f01023ad:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01023b3:	50                   	push   %eax
f01023b4:	e8 f8 dc ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01023b9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023bc:	8d 83 cc bc f7 ff    	lea    -0x84334(%ebx),%eax
f01023c2:	50                   	push   %eax
f01023c3:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01023c9:	50                   	push   %eax
f01023ca:	68 90 03 00 00       	push   $0x390
f01023cf:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01023d5:	50                   	push   %eax
f01023d6:	e8 d6 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01023db:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023de:	8d 83 04 bd f7 ff    	lea    -0x842fc(%ebx),%eax
f01023e4:	50                   	push   %eax
f01023e5:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01023eb:	50                   	push   %eax
f01023ec:	68 93 03 00 00       	push   $0x393
f01023f1:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01023f7:	50                   	push   %eax
f01023f8:	e8 b4 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023fd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102400:	8d 83 34 bd f7 ff    	lea    -0x842cc(%ebx),%eax
f0102406:	50                   	push   %eax
f0102407:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010240d:	50                   	push   %eax
f010240e:	68 97 03 00 00       	push   $0x397
f0102413:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102419:	50                   	push   %eax
f010241a:	e8 92 dc ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010241f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102422:	8d 83 64 bd f7 ff    	lea    -0x8429c(%ebx),%eax
f0102428:	50                   	push   %eax
f0102429:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010242f:	50                   	push   %eax
f0102430:	68 98 03 00 00       	push   $0x398
f0102435:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010243b:	50                   	push   %eax
f010243c:	e8 70 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102441:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102444:	8d 83 8c bd f7 ff    	lea    -0x84274(%ebx),%eax
f010244a:	50                   	push   %eax
f010244b:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102451:	50                   	push   %eax
f0102452:	68 99 03 00 00       	push   $0x399
f0102457:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010245d:	50                   	push   %eax
f010245e:	e8 4e dc ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102463:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102466:	8d 83 af c4 f7 ff    	lea    -0x83b51(%ebx),%eax
f010246c:	50                   	push   %eax
f010246d:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102473:	50                   	push   %eax
f0102474:	68 9a 03 00 00       	push   $0x39a
f0102479:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010247f:	50                   	push   %eax
f0102480:	e8 2c dc ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102485:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102488:	8d 83 c0 c4 f7 ff    	lea    -0x83b40(%ebx),%eax
f010248e:	50                   	push   %eax
f010248f:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102495:	50                   	push   %eax
f0102496:	68 9b 03 00 00       	push   $0x39b
f010249b:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01024a1:	50                   	push   %eax
f01024a2:	e8 0a dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024aa:	8d 83 bc bd f7 ff    	lea    -0x84244(%ebx),%eax
f01024b0:	50                   	push   %eax
f01024b1:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01024b7:	50                   	push   %eax
f01024b8:	68 9e 03 00 00       	push   $0x39e
f01024bd:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01024c3:	50                   	push   %eax
f01024c4:	e8 e8 db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024cc:	8d 83 f8 bd f7 ff    	lea    -0x84208(%ebx),%eax
f01024d2:	50                   	push   %eax
f01024d3:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01024d9:	50                   	push   %eax
f01024da:	68 9f 03 00 00       	push   $0x39f
f01024df:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01024e5:	50                   	push   %eax
f01024e6:	e8 c6 db ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01024eb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024ee:	8d 83 d1 c4 f7 ff    	lea    -0x83b2f(%ebx),%eax
f01024f4:	50                   	push   %eax
f01024f5:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01024fb:	50                   	push   %eax
f01024fc:	68 a0 03 00 00       	push   $0x3a0
f0102501:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102507:	50                   	push   %eax
f0102508:	e8 a4 db ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010250d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102510:	8d 83 5d c4 f7 ff    	lea    -0x83ba3(%ebx),%eax
f0102516:	50                   	push   %eax
f0102517:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010251d:	50                   	push   %eax
f010251e:	68 a3 03 00 00       	push   $0x3a3
f0102523:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102529:	50                   	push   %eax
f010252a:	e8 82 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010252f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102532:	8d 83 bc bd f7 ff    	lea    -0x84244(%ebx),%eax
f0102538:	50                   	push   %eax
f0102539:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010253f:	50                   	push   %eax
f0102540:	68 a6 03 00 00       	push   $0x3a6
f0102545:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010254b:	50                   	push   %eax
f010254c:	e8 60 db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102551:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102554:	8d 83 f8 bd f7 ff    	lea    -0x84208(%ebx),%eax
f010255a:	50                   	push   %eax
f010255b:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102561:	50                   	push   %eax
f0102562:	68 a7 03 00 00       	push   $0x3a7
f0102567:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010256d:	50                   	push   %eax
f010256e:	e8 3e db ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102573:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102576:	8d 83 d1 c4 f7 ff    	lea    -0x83b2f(%ebx),%eax
f010257c:	50                   	push   %eax
f010257d:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102583:	50                   	push   %eax
f0102584:	68 a8 03 00 00       	push   $0x3a8
f0102589:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010258f:	50                   	push   %eax
f0102590:	e8 1c db ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102595:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102598:	8d 83 5d c4 f7 ff    	lea    -0x83ba3(%ebx),%eax
f010259e:	50                   	push   %eax
f010259f:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01025a5:	50                   	push   %eax
f01025a6:	68 ac 03 00 00       	push   $0x3ac
f01025ab:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01025b1:	50                   	push   %eax
f01025b2:	e8 fa da ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025b7:	50                   	push   %eax
f01025b8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025bb:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f01025c1:	50                   	push   %eax
f01025c2:	68 af 03 00 00       	push   $0x3af
f01025c7:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01025cd:	50                   	push   %eax
f01025ce:	e8 de da ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01025d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025d6:	8d 83 28 be f7 ff    	lea    -0x841d8(%ebx),%eax
f01025dc:	50                   	push   %eax
f01025dd:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01025e3:	50                   	push   %eax
f01025e4:	68 b0 03 00 00       	push   $0x3b0
f01025e9:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01025ef:	50                   	push   %eax
f01025f0:	e8 bc da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01025f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025f8:	8d 83 68 be f7 ff    	lea    -0x84198(%ebx),%eax
f01025fe:	50                   	push   %eax
f01025ff:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102605:	50                   	push   %eax
f0102606:	68 b3 03 00 00       	push   $0x3b3
f010260b:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102611:	50                   	push   %eax
f0102612:	e8 9a da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102617:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010261a:	8d 83 f8 bd f7 ff    	lea    -0x84208(%ebx),%eax
f0102620:	50                   	push   %eax
f0102621:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102627:	50                   	push   %eax
f0102628:	68 b4 03 00 00       	push   $0x3b4
f010262d:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102633:	50                   	push   %eax
f0102634:	e8 78 da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102639:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010263c:	8d 83 d1 c4 f7 ff    	lea    -0x83b2f(%ebx),%eax
f0102642:	50                   	push   %eax
f0102643:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102649:	50                   	push   %eax
f010264a:	68 b5 03 00 00       	push   $0x3b5
f010264f:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102655:	50                   	push   %eax
f0102656:	e8 56 da ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010265b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010265e:	8d 83 a8 be f7 ff    	lea    -0x84158(%ebx),%eax
f0102664:	50                   	push   %eax
f0102665:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010266b:	50                   	push   %eax
f010266c:	68 b6 03 00 00       	push   $0x3b6
f0102671:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102677:	50                   	push   %eax
f0102678:	e8 34 da ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010267d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102680:	8d 83 e2 c4 f7 ff    	lea    -0x83b1e(%ebx),%eax
f0102686:	50                   	push   %eax
f0102687:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010268d:	50                   	push   %eax
f010268e:	68 b7 03 00 00       	push   $0x3b7
f0102693:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102699:	50                   	push   %eax
f010269a:	e8 12 da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010269f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026a2:	8d 83 bc bd f7 ff    	lea    -0x84244(%ebx),%eax
f01026a8:	50                   	push   %eax
f01026a9:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01026af:	50                   	push   %eax
f01026b0:	68 ba 03 00 00       	push   $0x3ba
f01026b5:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01026bb:	50                   	push   %eax
f01026bc:	e8 f0 d9 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01026c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026c4:	8d 83 dc be f7 ff    	lea    -0x84124(%ebx),%eax
f01026ca:	50                   	push   %eax
f01026cb:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01026d1:	50                   	push   %eax
f01026d2:	68 bb 03 00 00       	push   $0x3bb
f01026d7:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01026dd:	50                   	push   %eax
f01026de:	e8 ce d9 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026e6:	8d 83 10 bf f7 ff    	lea    -0x840f0(%ebx),%eax
f01026ec:	50                   	push   %eax
f01026ed:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01026f3:	50                   	push   %eax
f01026f4:	68 bc 03 00 00       	push   $0x3bc
f01026f9:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01026ff:	50                   	push   %eax
f0102700:	e8 ac d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102705:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102708:	8d 83 48 bf f7 ff    	lea    -0x840b8(%ebx),%eax
f010270e:	50                   	push   %eax
f010270f:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102715:	50                   	push   %eax
f0102716:	68 bf 03 00 00       	push   $0x3bf
f010271b:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102721:	50                   	push   %eax
f0102722:	e8 8a d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102727:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010272a:	8d 83 80 bf f7 ff    	lea    -0x84080(%ebx),%eax
f0102730:	50                   	push   %eax
f0102731:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102737:	50                   	push   %eax
f0102738:	68 c2 03 00 00       	push   $0x3c2
f010273d:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102743:	50                   	push   %eax
f0102744:	e8 68 d9 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102749:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010274c:	8d 83 10 bf f7 ff    	lea    -0x840f0(%ebx),%eax
f0102752:	50                   	push   %eax
f0102753:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102759:	50                   	push   %eax
f010275a:	68 c3 03 00 00       	push   $0x3c3
f010275f:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102765:	50                   	push   %eax
f0102766:	e8 46 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010276b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010276e:	8d 83 bc bf f7 ff    	lea    -0x84044(%ebx),%eax
f0102774:	50                   	push   %eax
f0102775:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010277b:	50                   	push   %eax
f010277c:	68 c6 03 00 00       	push   $0x3c6
f0102781:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102787:	50                   	push   %eax
f0102788:	e8 24 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010278d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102790:	8d 83 e8 bf f7 ff    	lea    -0x84018(%ebx),%eax
f0102796:	50                   	push   %eax
f0102797:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010279d:	50                   	push   %eax
f010279e:	68 c7 03 00 00       	push   $0x3c7
f01027a3:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01027a9:	50                   	push   %eax
f01027aa:	e8 02 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f01027af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027b2:	8d 83 f8 c4 f7 ff    	lea    -0x83b08(%ebx),%eax
f01027b8:	50                   	push   %eax
f01027b9:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01027bf:	50                   	push   %eax
f01027c0:	68 c9 03 00 00       	push   $0x3c9
f01027c5:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01027cb:	50                   	push   %eax
f01027cc:	e8 e0 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01027d1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027d4:	8d 83 09 c5 f7 ff    	lea    -0x83af7(%ebx),%eax
f01027da:	50                   	push   %eax
f01027db:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01027e1:	50                   	push   %eax
f01027e2:	68 ca 03 00 00       	push   $0x3ca
f01027e7:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01027ed:	50                   	push   %eax
f01027ee:	e8 be d8 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01027f3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027f6:	8d 83 18 c0 f7 ff    	lea    -0x83fe8(%ebx),%eax
f01027fc:	50                   	push   %eax
f01027fd:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102803:	50                   	push   %eax
f0102804:	68 cd 03 00 00       	push   $0x3cd
f0102809:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010280f:	50                   	push   %eax
f0102810:	e8 9c d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102815:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102818:	8d 83 3c c0 f7 ff    	lea    -0x83fc4(%ebx),%eax
f010281e:	50                   	push   %eax
f010281f:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102825:	50                   	push   %eax
f0102826:	68 d1 03 00 00       	push   $0x3d1
f010282b:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102831:	50                   	push   %eax
f0102832:	e8 7a d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102837:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010283a:	8d 83 e8 bf f7 ff    	lea    -0x84018(%ebx),%eax
f0102840:	50                   	push   %eax
f0102841:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102847:	50                   	push   %eax
f0102848:	68 d2 03 00 00       	push   $0x3d2
f010284d:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102853:	50                   	push   %eax
f0102854:	e8 58 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102859:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010285c:	8d 83 af c4 f7 ff    	lea    -0x83b51(%ebx),%eax
f0102862:	50                   	push   %eax
f0102863:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102869:	50                   	push   %eax
f010286a:	68 d3 03 00 00       	push   $0x3d3
f010286f:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102875:	50                   	push   %eax
f0102876:	e8 36 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010287b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010287e:	8d 83 09 c5 f7 ff    	lea    -0x83af7(%ebx),%eax
f0102884:	50                   	push   %eax
f0102885:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010288b:	50                   	push   %eax
f010288c:	68 d4 03 00 00       	push   $0x3d4
f0102891:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102897:	50                   	push   %eax
f0102898:	e8 14 d8 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010289d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028a0:	8d 83 60 c0 f7 ff    	lea    -0x83fa0(%ebx),%eax
f01028a6:	50                   	push   %eax
f01028a7:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01028ad:	50                   	push   %eax
f01028ae:	68 d7 03 00 00       	push   $0x3d7
f01028b3:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01028b9:	50                   	push   %eax
f01028ba:	e8 f2 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f01028bf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028c2:	8d 83 1a c5 f7 ff    	lea    -0x83ae6(%ebx),%eax
f01028c8:	50                   	push   %eax
f01028c9:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01028cf:	50                   	push   %eax
f01028d0:	68 d8 03 00 00       	push   $0x3d8
f01028d5:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01028db:	50                   	push   %eax
f01028dc:	e8 d0 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f01028e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028e4:	8d 83 26 c5 f7 ff    	lea    -0x83ada(%ebx),%eax
f01028ea:	50                   	push   %eax
f01028eb:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01028f1:	50                   	push   %eax
f01028f2:	68 d9 03 00 00       	push   $0x3d9
f01028f7:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01028fd:	50                   	push   %eax
f01028fe:	e8 ae d7 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102903:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102906:	8d 83 3c c0 f7 ff    	lea    -0x83fc4(%ebx),%eax
f010290c:	50                   	push   %eax
f010290d:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102913:	50                   	push   %eax
f0102914:	68 dd 03 00 00       	push   $0x3dd
f0102919:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010291f:	50                   	push   %eax
f0102920:	e8 8c d7 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102925:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102928:	8d 83 98 c0 f7 ff    	lea    -0x83f68(%ebx),%eax
f010292e:	50                   	push   %eax
f010292f:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102935:	50                   	push   %eax
f0102936:	68 de 03 00 00       	push   $0x3de
f010293b:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102941:	50                   	push   %eax
f0102942:	e8 6a d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102947:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010294a:	8d 83 3b c5 f7 ff    	lea    -0x83ac5(%ebx),%eax
f0102950:	50                   	push   %eax
f0102951:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102957:	50                   	push   %eax
f0102958:	68 df 03 00 00       	push   $0x3df
f010295d:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102963:	50                   	push   %eax
f0102964:	e8 48 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102969:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010296c:	8d 83 09 c5 f7 ff    	lea    -0x83af7(%ebx),%eax
f0102972:	50                   	push   %eax
f0102973:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102979:	50                   	push   %eax
f010297a:	68 e0 03 00 00       	push   $0x3e0
f010297f:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102985:	50                   	push   %eax
f0102986:	e8 26 d7 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010298b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010298e:	8d 83 c0 c0 f7 ff    	lea    -0x83f40(%ebx),%eax
f0102994:	50                   	push   %eax
f0102995:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010299b:	50                   	push   %eax
f010299c:	68 e3 03 00 00       	push   $0x3e3
f01029a1:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01029a7:	50                   	push   %eax
f01029a8:	e8 04 d7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01029ad:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029b0:	8d 83 5d c4 f7 ff    	lea    -0x83ba3(%ebx),%eax
f01029b6:	50                   	push   %eax
f01029b7:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01029bd:	50                   	push   %eax
f01029be:	68 e6 03 00 00       	push   $0x3e6
f01029c3:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01029c9:	50                   	push   %eax
f01029ca:	e8 e2 d6 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01029cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029d2:	8d 83 64 bd f7 ff    	lea    -0x8429c(%ebx),%eax
f01029d8:	50                   	push   %eax
f01029d9:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01029df:	50                   	push   %eax
f01029e0:	68 e9 03 00 00       	push   $0x3e9
f01029e5:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01029eb:	50                   	push   %eax
f01029ec:	e8 c0 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01029f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029f4:	8d 83 c0 c4 f7 ff    	lea    -0x83b40(%ebx),%eax
f01029fa:	50                   	push   %eax
f01029fb:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102a01:	50                   	push   %eax
f0102a02:	68 eb 03 00 00       	push   $0x3eb
f0102a07:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102a0d:	50                   	push   %eax
f0102a0e:	e8 9e d6 ff ff       	call   f01000b1 <_panic>
f0102a13:	52                   	push   %edx
f0102a14:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a17:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0102a1d:	50                   	push   %eax
f0102a1e:	68 f2 03 00 00       	push   $0x3f2
f0102a23:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102a29:	50                   	push   %eax
f0102a2a:	e8 82 d6 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102a2f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a32:	8d 83 4c c5 f7 ff    	lea    -0x83ab4(%ebx),%eax
f0102a38:	50                   	push   %eax
f0102a39:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102a3f:	50                   	push   %eax
f0102a40:	68 f3 03 00 00       	push   $0x3f3
f0102a45:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102a4b:	50                   	push   %eax
f0102a4c:	e8 60 d6 ff ff       	call   f01000b1 <_panic>
f0102a51:	50                   	push   %eax
f0102a52:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a55:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0102a5b:	50                   	push   %eax
f0102a5c:	6a 56                	push   $0x56
f0102a5e:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f0102a64:	50                   	push   %eax
f0102a65:	e8 47 d6 ff ff       	call   f01000b1 <_panic>
f0102a6a:	52                   	push   %edx
f0102a6b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a6e:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0102a74:	50                   	push   %eax
f0102a75:	6a 56                	push   $0x56
f0102a77:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f0102a7d:	50                   	push   %eax
f0102a7e:	e8 2e d6 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102a83:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a86:	8d 83 64 c5 f7 ff    	lea    -0x83a9c(%ebx),%eax
f0102a8c:	50                   	push   %eax
f0102a8d:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102a93:	50                   	push   %eax
f0102a94:	68 fd 03 00 00       	push   $0x3fd
f0102a99:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102a9f:	50                   	push   %eax
f0102aa0:	e8 0c d6 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102aa5:	50                   	push   %eax
f0102aa6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102aa9:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0102aaf:	50                   	push   %eax
f0102ab0:	68 ce 00 00 00       	push   $0xce
f0102ab5:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102abb:	50                   	push   %eax
f0102abc:	e8 f0 d5 ff ff       	call   f01000b1 <_panic>
f0102ac1:	50                   	push   %eax
f0102ac2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ac5:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0102acb:	50                   	push   %eax
f0102acc:	68 da 00 00 00       	push   $0xda
f0102ad1:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102ad7:	50                   	push   %eax
f0102ad8:	e8 d4 d5 ff ff       	call   f01000b1 <_panic>
f0102add:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ae0:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f0102ae6:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0102aec:	50                   	push   %eax
f0102aed:	68 ec 00 00 00       	push   $0xec
f0102af2:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102af8:	50                   	push   %eax
f0102af9:	e8 b3 d5 ff ff       	call   f01000b1 <_panic>
f0102afe:	ff 75 c0             	pushl  -0x40(%ebp)
f0102b01:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b04:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0102b0a:	50                   	push   %eax
f0102b0b:	68 3a 03 00 00       	push   $0x33a
f0102b10:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102b16:	50                   	push   %eax
f0102b17:	e8 95 d5 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102b1c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102b22:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102b25:	76 3f                	jbe    f0102b66 <mem_init+0x1780>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b27:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102b2d:	89 f0                	mov    %esi,%eax
f0102b2f:	e8 b6 df ff ff       	call   f0100aea <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102b34:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102b3b:	76 c1                	jbe    f0102afe <mem_init+0x1718>
f0102b3d:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102b40:	39 d0                	cmp    %edx,%eax
f0102b42:	74 d8                	je     f0102b1c <mem_init+0x1736>
f0102b44:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b47:	8d 83 e4 c0 f7 ff    	lea    -0x83f1c(%ebx),%eax
f0102b4d:	50                   	push   %eax
f0102b4e:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102b54:	50                   	push   %eax
f0102b55:	68 3a 03 00 00       	push   $0x33a
f0102b5a:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102b60:	50                   	push   %eax
f0102b61:	e8 4b d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102b66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b69:	c7 c0 4c c3 18 f0    	mov    $0xf018c34c,%eax
f0102b6f:	8b 00                	mov    (%eax),%eax
f0102b71:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102b74:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102b77:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0102b7c:	8d 98 00 00 40 21    	lea    0x21400000(%eax),%ebx
f0102b82:	89 fa                	mov    %edi,%edx
f0102b84:	89 f0                	mov    %esi,%eax
f0102b86:	e8 5f df ff ff       	call   f0100aea <check_va2pa>
f0102b8b:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102b92:	76 3d                	jbe    f0102bd1 <mem_init+0x17eb>
f0102b94:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102b97:	39 d0                	cmp    %edx,%eax
f0102b99:	75 54                	jne    f0102bef <mem_init+0x1809>
f0102b9b:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102ba1:	81 ff 00 80 c1 ee    	cmp    $0xeec18000,%edi
f0102ba7:	75 d9                	jne    f0102b82 <mem_init+0x179c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ba9:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102bac:	c1 e7 0c             	shl    $0xc,%edi
f0102baf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102bb4:	39 fb                	cmp    %edi,%ebx
f0102bb6:	73 7b                	jae    f0102c33 <mem_init+0x184d>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102bb8:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102bbe:	89 f0                	mov    %esi,%eax
f0102bc0:	e8 25 df ff ff       	call   f0100aea <check_va2pa>
f0102bc5:	39 c3                	cmp    %eax,%ebx
f0102bc7:	75 48                	jne    f0102c11 <mem_init+0x182b>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102bc9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102bcf:	eb e3                	jmp    f0102bb4 <mem_init+0x17ce>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bd1:	ff 75 cc             	pushl  -0x34(%ebp)
f0102bd4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bd7:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0102bdd:	50                   	push   %eax
f0102bde:	68 3f 03 00 00       	push   $0x33f
f0102be3:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102be9:	50                   	push   %eax
f0102bea:	e8 c2 d4 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102bef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bf2:	8d 83 18 c1 f7 ff    	lea    -0x83ee8(%ebx),%eax
f0102bf8:	50                   	push   %eax
f0102bf9:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102bff:	50                   	push   %eax
f0102c00:	68 3f 03 00 00       	push   $0x33f
f0102c05:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102c0b:	50                   	push   %eax
f0102c0c:	e8 a0 d4 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c11:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c14:	8d 83 4c c1 f7 ff    	lea    -0x83eb4(%ebx),%eax
f0102c1a:	50                   	push   %eax
f0102c1b:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102c21:	50                   	push   %eax
f0102c22:	68 43 03 00 00       	push   $0x343
f0102c27:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102c2d:	50                   	push   %eax
f0102c2e:	e8 7e d4 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c33:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c38:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102c3b:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f0102c41:	89 da                	mov    %ebx,%edx
f0102c43:	89 f0                	mov    %esi,%eax
f0102c45:	e8 a0 de ff ff       	call   f0100aea <check_va2pa>
f0102c4a:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102c4d:	39 c2                	cmp    %eax,%edx
f0102c4f:	75 26                	jne    f0102c77 <mem_init+0x1891>
f0102c51:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102c57:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102c5d:	75 e2                	jne    f0102c41 <mem_init+0x185b>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c5f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102c64:	89 f0                	mov    %esi,%eax
f0102c66:	e8 7f de ff ff       	call   f0100aea <check_va2pa>
f0102c6b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c6e:	75 29                	jne    f0102c99 <mem_init+0x18b3>
	for (i = 0; i < NPDENTRIES; i++) {
f0102c70:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c75:	eb 6d                	jmp    f0102ce4 <mem_init+0x18fe>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c77:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c7a:	8d 83 74 c1 f7 ff    	lea    -0x83e8c(%ebx),%eax
f0102c80:	50                   	push   %eax
f0102c81:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102c87:	50                   	push   %eax
f0102c88:	68 47 03 00 00       	push   $0x347
f0102c8d:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102c93:	50                   	push   %eax
f0102c94:	e8 18 d4 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c99:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c9c:	8d 83 bc c1 f7 ff    	lea    -0x83e44(%ebx),%eax
f0102ca2:	50                   	push   %eax
f0102ca3:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102ca9:	50                   	push   %eax
f0102caa:	68 48 03 00 00       	push   $0x348
f0102caf:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102cb5:	50                   	push   %eax
f0102cb6:	e8 f6 d3 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102cbb:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102cbf:	74 52                	je     f0102d13 <mem_init+0x192d>
	for (i = 0; i < NPDENTRIES; i++) {
f0102cc1:	83 c0 01             	add    $0x1,%eax
f0102cc4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102cc9:	0f 87 bb 00 00 00    	ja     f0102d8a <mem_init+0x19a4>
		switch (i) {
f0102ccf:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102cd4:	72 0e                	jb     f0102ce4 <mem_init+0x18fe>
f0102cd6:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102cdb:	76 de                	jbe    f0102cbb <mem_init+0x18d5>
f0102cdd:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ce2:	74 d7                	je     f0102cbb <mem_init+0x18d5>
			if (i >= PDX(KERNBASE)) {
f0102ce4:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ce9:	77 4a                	ja     f0102d35 <mem_init+0x194f>
				assert(pgdir[i] == 0);
f0102ceb:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102cef:	74 d0                	je     f0102cc1 <mem_init+0x18db>
f0102cf1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cf4:	8d 83 b6 c5 f7 ff    	lea    -0x83a4a(%ebx),%eax
f0102cfa:	50                   	push   %eax
f0102cfb:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102d01:	50                   	push   %eax
f0102d02:	68 58 03 00 00       	push   $0x358
f0102d07:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102d0d:	50                   	push   %eax
f0102d0e:	e8 9e d3 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102d13:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d16:	8d 83 94 c5 f7 ff    	lea    -0x83a6c(%ebx),%eax
f0102d1c:	50                   	push   %eax
f0102d1d:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102d23:	50                   	push   %eax
f0102d24:	68 51 03 00 00       	push   $0x351
f0102d29:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102d2f:	50                   	push   %eax
f0102d30:	e8 7c d3 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102d35:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102d38:	f6 c2 01             	test   $0x1,%dl
f0102d3b:	74 2b                	je     f0102d68 <mem_init+0x1982>
				assert(pgdir[i] & PTE_W);
f0102d3d:	f6 c2 02             	test   $0x2,%dl
f0102d40:	0f 85 7b ff ff ff    	jne    f0102cc1 <mem_init+0x18db>
f0102d46:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d49:	8d 83 a5 c5 f7 ff    	lea    -0x83a5b(%ebx),%eax
f0102d4f:	50                   	push   %eax
f0102d50:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102d56:	50                   	push   %eax
f0102d57:	68 56 03 00 00       	push   $0x356
f0102d5c:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102d62:	50                   	push   %eax
f0102d63:	e8 49 d3 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102d68:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d6b:	8d 83 94 c5 f7 ff    	lea    -0x83a6c(%ebx),%eax
f0102d71:	50                   	push   %eax
f0102d72:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0102d78:	50                   	push   %eax
f0102d79:	68 55 03 00 00       	push   $0x355
f0102d7e:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0102d84:	50                   	push   %eax
f0102d85:	e8 27 d3 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102d8a:	83 ec 0c             	sub    $0xc,%esp
f0102d8d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d90:	8d 87 ec c1 f7 ff    	lea    -0x83e14(%edi),%eax
f0102d96:	50                   	push   %eax
f0102d97:	89 fb                	mov    %edi,%ebx
f0102d99:	e8 93 0d 00 00       	call   f0103b31 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102d9e:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0102da4:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102da6:	83 c4 10             	add    $0x10,%esp
f0102da9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dae:	0f 86 44 02 00 00    	jbe    f0102ff8 <mem_init+0x1c12>
	return (physaddr_t)kva - KERNBASE;
f0102db4:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102db9:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102dbc:	b8 00 00 00 00       	mov    $0x0,%eax
f0102dc1:	e8 a1 dd ff ff       	call   f0100b67 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102dc6:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102dc9:	83 e0 f3             	and    $0xfffffff3,%eax
f0102dcc:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102dd1:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102dd4:	83 ec 0c             	sub    $0xc,%esp
f0102dd7:	6a 00                	push   $0x0
f0102dd9:	e8 3f e2 ff ff       	call   f010101d <page_alloc>
f0102dde:	89 c6                	mov    %eax,%esi
f0102de0:	83 c4 10             	add    $0x10,%esp
f0102de3:	85 c0                	test   %eax,%eax
f0102de5:	0f 84 29 02 00 00    	je     f0103014 <mem_init+0x1c2e>
	assert((pp1 = page_alloc(0)));
f0102deb:	83 ec 0c             	sub    $0xc,%esp
f0102dee:	6a 00                	push   $0x0
f0102df0:	e8 28 e2 ff ff       	call   f010101d <page_alloc>
f0102df5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102df8:	83 c4 10             	add    $0x10,%esp
f0102dfb:	85 c0                	test   %eax,%eax
f0102dfd:	0f 84 33 02 00 00    	je     f0103036 <mem_init+0x1c50>
	assert((pp2 = page_alloc(0)));
f0102e03:	83 ec 0c             	sub    $0xc,%esp
f0102e06:	6a 00                	push   $0x0
f0102e08:	e8 10 e2 ff ff       	call   f010101d <page_alloc>
f0102e0d:	89 c7                	mov    %eax,%edi
f0102e0f:	83 c4 10             	add    $0x10,%esp
f0102e12:	85 c0                	test   %eax,%eax
f0102e14:	0f 84 3e 02 00 00    	je     f0103058 <mem_init+0x1c72>
	page_free(pp0);
f0102e1a:	83 ec 0c             	sub    $0xc,%esp
f0102e1d:	56                   	push   %esi
f0102e1e:	e8 82 e2 ff ff       	call   f01010a5 <page_free>
	return (pp - pages) << PGSHIFT;
f0102e23:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e26:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0102e2c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102e2f:	2b 08                	sub    (%eax),%ecx
f0102e31:	89 c8                	mov    %ecx,%eax
f0102e33:	c1 f8 03             	sar    $0x3,%eax
f0102e36:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102e39:	89 c1                	mov    %eax,%ecx
f0102e3b:	c1 e9 0c             	shr    $0xc,%ecx
f0102e3e:	83 c4 10             	add    $0x10,%esp
f0102e41:	c7 c2 04 d0 18 f0    	mov    $0xf018d004,%edx
f0102e47:	3b 0a                	cmp    (%edx),%ecx
f0102e49:	0f 83 2b 02 00 00    	jae    f010307a <mem_init+0x1c94>
	memset(page2kva(pp1), 1, PGSIZE);
f0102e4f:	83 ec 04             	sub    $0x4,%esp
f0102e52:	68 00 10 00 00       	push   $0x1000
f0102e57:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102e59:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e5e:	50                   	push   %eax
f0102e5f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e62:	e8 43 23 00 00       	call   f01051aa <memset>
	return (pp - pages) << PGSHIFT;
f0102e67:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e6a:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0102e70:	89 f9                	mov    %edi,%ecx
f0102e72:	2b 08                	sub    (%eax),%ecx
f0102e74:	89 c8                	mov    %ecx,%eax
f0102e76:	c1 f8 03             	sar    $0x3,%eax
f0102e79:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102e7c:	89 c1                	mov    %eax,%ecx
f0102e7e:	c1 e9 0c             	shr    $0xc,%ecx
f0102e81:	83 c4 10             	add    $0x10,%esp
f0102e84:	c7 c2 04 d0 18 f0    	mov    $0xf018d004,%edx
f0102e8a:	3b 0a                	cmp    (%edx),%ecx
f0102e8c:	0f 83 fe 01 00 00    	jae    f0103090 <mem_init+0x1caa>
	memset(page2kva(pp2), 2, PGSIZE);
f0102e92:	83 ec 04             	sub    $0x4,%esp
f0102e95:	68 00 10 00 00       	push   $0x1000
f0102e9a:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102e9c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ea1:	50                   	push   %eax
f0102ea2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ea5:	e8 00 23 00 00       	call   f01051aa <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102eaa:	6a 02                	push   $0x2
f0102eac:	68 00 10 00 00       	push   $0x1000
f0102eb1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102eb4:	53                   	push   %ebx
f0102eb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102eb8:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0102ebe:	ff 30                	pushl  (%eax)
f0102ec0:	e8 7c e4 ff ff       	call   f0101341 <page_insert>
	assert(pp1->pp_ref == 1);
f0102ec5:	83 c4 20             	add    $0x20,%esp
f0102ec8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102ecd:	0f 85 d3 01 00 00    	jne    f01030a6 <mem_init+0x1cc0>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ed3:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102eda:	01 01 01 
f0102edd:	0f 85 e5 01 00 00    	jne    f01030c8 <mem_init+0x1ce2>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ee3:	6a 02                	push   $0x2
f0102ee5:	68 00 10 00 00       	push   $0x1000
f0102eea:	57                   	push   %edi
f0102eeb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102eee:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0102ef4:	ff 30                	pushl  (%eax)
f0102ef6:	e8 46 e4 ff ff       	call   f0101341 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102efb:	83 c4 10             	add    $0x10,%esp
f0102efe:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102f05:	02 02 02 
f0102f08:	0f 85 dc 01 00 00    	jne    f01030ea <mem_init+0x1d04>
	assert(pp2->pp_ref == 1);
f0102f0e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102f13:	0f 85 f3 01 00 00    	jne    f010310c <mem_init+0x1d26>
	assert(pp1->pp_ref == 0);
f0102f19:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102f1c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102f21:	0f 85 07 02 00 00    	jne    f010312e <mem_init+0x1d48>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102f27:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102f2e:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102f31:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f34:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0102f3a:	89 f9                	mov    %edi,%ecx
f0102f3c:	2b 08                	sub    (%eax),%ecx
f0102f3e:	89 c8                	mov    %ecx,%eax
f0102f40:	c1 f8 03             	sar    $0x3,%eax
f0102f43:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102f46:	89 c1                	mov    %eax,%ecx
f0102f48:	c1 e9 0c             	shr    $0xc,%ecx
f0102f4b:	c7 c2 04 d0 18 f0    	mov    $0xf018d004,%edx
f0102f51:	3b 0a                	cmp    (%edx),%ecx
f0102f53:	0f 83 f7 01 00 00    	jae    f0103150 <mem_init+0x1d6a>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f59:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102f60:	03 03 03 
f0102f63:	0f 85 fd 01 00 00    	jne    f0103166 <mem_init+0x1d80>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102f69:	83 ec 08             	sub    $0x8,%esp
f0102f6c:	68 00 10 00 00       	push   $0x1000
f0102f71:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f74:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0102f7a:	ff 30                	pushl  (%eax)
f0102f7c:	e8 83 e3 ff ff       	call   f0101304 <page_remove>
	assert(pp2->pp_ref == 0);
f0102f81:	83 c4 10             	add    $0x10,%esp
f0102f84:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102f89:	0f 85 f9 01 00 00    	jne    f0103188 <mem_init+0x1da2>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f8f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102f92:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0102f98:	8b 08                	mov    (%eax),%ecx
f0102f9a:	8b 11                	mov    (%ecx),%edx
f0102f9c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102fa2:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f0102fa8:	89 f7                	mov    %esi,%edi
f0102faa:	2b 38                	sub    (%eax),%edi
f0102fac:	89 f8                	mov    %edi,%eax
f0102fae:	c1 f8 03             	sar    $0x3,%eax
f0102fb1:	c1 e0 0c             	shl    $0xc,%eax
f0102fb4:	39 c2                	cmp    %eax,%edx
f0102fb6:	0f 85 ee 01 00 00    	jne    f01031aa <mem_init+0x1dc4>
	kern_pgdir[0] = 0;
f0102fbc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102fc2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102fc7:	0f 85 ff 01 00 00    	jne    f01031cc <mem_init+0x1de6>
	pp0->pp_ref = 0;
f0102fcd:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102fd3:	83 ec 0c             	sub    $0xc,%esp
f0102fd6:	56                   	push   %esi
f0102fd7:	e8 c9 e0 ff ff       	call   f01010a5 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102fdc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fdf:	8d 83 80 c2 f7 ff    	lea    -0x83d80(%ebx),%eax
f0102fe5:	89 04 24             	mov    %eax,(%esp)
f0102fe8:	e8 44 0b 00 00       	call   f0103b31 <cprintf>
}
f0102fed:	83 c4 10             	add    $0x10,%esp
f0102ff0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ff3:	5b                   	pop    %ebx
f0102ff4:	5e                   	pop    %esi
f0102ff5:	5f                   	pop    %edi
f0102ff6:	5d                   	pop    %ebp
f0102ff7:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ff8:	50                   	push   %eax
f0102ff9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ffc:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0103002:	50                   	push   %eax
f0103003:	68 07 01 00 00       	push   $0x107
f0103008:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010300e:	50                   	push   %eax
f010300f:	e8 9d d0 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0103014:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103017:	8d 83 b2 c3 f7 ff    	lea    -0x83c4e(%ebx),%eax
f010301d:	50                   	push   %eax
f010301e:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0103024:	50                   	push   %eax
f0103025:	68 18 04 00 00       	push   $0x418
f010302a:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0103030:	50                   	push   %eax
f0103031:	e8 7b d0 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0103036:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103039:	8d 83 c8 c3 f7 ff    	lea    -0x83c38(%ebx),%eax
f010303f:	50                   	push   %eax
f0103040:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0103046:	50                   	push   %eax
f0103047:	68 19 04 00 00       	push   $0x419
f010304c:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0103052:	50                   	push   %eax
f0103053:	e8 59 d0 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0103058:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010305b:	8d 83 de c3 f7 ff    	lea    -0x83c22(%ebx),%eax
f0103061:	50                   	push   %eax
f0103062:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0103068:	50                   	push   %eax
f0103069:	68 1a 04 00 00       	push   $0x41a
f010306e:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0103074:	50                   	push   %eax
f0103075:	e8 37 d0 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010307a:	50                   	push   %eax
f010307b:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0103081:	50                   	push   %eax
f0103082:	6a 56                	push   $0x56
f0103084:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f010308a:	50                   	push   %eax
f010308b:	e8 21 d0 ff ff       	call   f01000b1 <_panic>
f0103090:	50                   	push   %eax
f0103091:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0103097:	50                   	push   %eax
f0103098:	6a 56                	push   $0x56
f010309a:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f01030a0:	50                   	push   %eax
f01030a1:	e8 0b d0 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01030a6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030a9:	8d 83 af c4 f7 ff    	lea    -0x83b51(%ebx),%eax
f01030af:	50                   	push   %eax
f01030b0:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01030b6:	50                   	push   %eax
f01030b7:	68 1f 04 00 00       	push   $0x41f
f01030bc:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01030c2:	50                   	push   %eax
f01030c3:	e8 e9 cf ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01030c8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030cb:	8d 83 0c c2 f7 ff    	lea    -0x83df4(%ebx),%eax
f01030d1:	50                   	push   %eax
f01030d2:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01030d8:	50                   	push   %eax
f01030d9:	68 20 04 00 00       	push   $0x420
f01030de:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01030e4:	50                   	push   %eax
f01030e5:	e8 c7 cf ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01030ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030ed:	8d 83 30 c2 f7 ff    	lea    -0x83dd0(%ebx),%eax
f01030f3:	50                   	push   %eax
f01030f4:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01030fa:	50                   	push   %eax
f01030fb:	68 22 04 00 00       	push   $0x422
f0103100:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0103106:	50                   	push   %eax
f0103107:	e8 a5 cf ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f010310c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010310f:	8d 83 d1 c4 f7 ff    	lea    -0x83b2f(%ebx),%eax
f0103115:	50                   	push   %eax
f0103116:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010311c:	50                   	push   %eax
f010311d:	68 23 04 00 00       	push   $0x423
f0103122:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0103128:	50                   	push   %eax
f0103129:	e8 83 cf ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f010312e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103131:	8d 83 3b c5 f7 ff    	lea    -0x83ac5(%ebx),%eax
f0103137:	50                   	push   %eax
f0103138:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010313e:	50                   	push   %eax
f010313f:	68 24 04 00 00       	push   $0x424
f0103144:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f010314a:	50                   	push   %eax
f010314b:	e8 61 cf ff ff       	call   f01000b1 <_panic>
f0103150:	50                   	push   %eax
f0103151:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0103157:	50                   	push   %eax
f0103158:	6a 56                	push   $0x56
f010315a:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f0103160:	50                   	push   %eax
f0103161:	e8 4b cf ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103166:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103169:	8d 83 54 c2 f7 ff    	lea    -0x83dac(%ebx),%eax
f010316f:	50                   	push   %eax
f0103170:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0103176:	50                   	push   %eax
f0103177:	68 26 04 00 00       	push   $0x426
f010317c:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f0103182:	50                   	push   %eax
f0103183:	e8 29 cf ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0103188:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010318b:	8d 83 09 c5 f7 ff    	lea    -0x83af7(%ebx),%eax
f0103191:	50                   	push   %eax
f0103192:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0103198:	50                   	push   %eax
f0103199:	68 28 04 00 00       	push   $0x428
f010319e:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01031a4:	50                   	push   %eax
f01031a5:	e8 07 cf ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01031aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031ad:	8d 83 64 bd f7 ff    	lea    -0x8429c(%ebx),%eax
f01031b3:	50                   	push   %eax
f01031b4:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01031ba:	50                   	push   %eax
f01031bb:	68 2b 04 00 00       	push   $0x42b
f01031c0:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01031c6:	50                   	push   %eax
f01031c7:	e8 e5 ce ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01031cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031cf:	8d 83 c0 c4 f7 ff    	lea    -0x83b40(%ebx),%eax
f01031d5:	50                   	push   %eax
f01031d6:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f01031dc:	50                   	push   %eax
f01031dd:	68 2d 04 00 00       	push   $0x42d
f01031e2:	8d 83 e1 c2 f7 ff    	lea    -0x83d1f(%ebx),%eax
f01031e8:	50                   	push   %eax
f01031e9:	e8 c3 ce ff ff       	call   f01000b1 <_panic>

f01031ee <tlb_invalidate>:
{
f01031ee:	55                   	push   %ebp
f01031ef:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01031f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031f4:	0f 01 38             	invlpg (%eax)
}
f01031f7:	5d                   	pop    %ebp
f01031f8:	c3                   	ret    

f01031f9 <user_mem_check>:
{
f01031f9:	55                   	push   %ebp
f01031fa:	89 e5                	mov    %esp,%ebp
f01031fc:	57                   	push   %edi
f01031fd:	56                   	push   %esi
f01031fe:	53                   	push   %ebx
f01031ff:	83 ec 1c             	sub    $0x1c,%esp
f0103202:	e8 02 d5 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f0103207:	05 19 6e 08 00       	add    $0x86e19,%eax
f010320c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t addr = (uint32_t) ROUNDDOWN(va, PGSIZE);
f010320f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103212:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va + len, PGSIZE);
f0103218:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010321b:	03 7d 10             	add    0x10(%ebp),%edi
f010321e:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0103224:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	perm = perm | PTE_P | PTE_U; //页表权限
f010322a:	8b 75 14             	mov    0x14(%ebp),%esi
f010322d:	83 ce 05             	or     $0x5,%esi
	for(; addr < end; addr += PGSIZE){
f0103230:	39 fb                	cmp    %edi,%ebx
f0103232:	73 58                	jae    f010328c <user_mem_check+0x93>
		pte = pgdir_walk(env->env_pgdir, (void *)addr, 0); //获取该页pte
f0103234:	83 ec 04             	sub    $0x4,%esp
f0103237:	6a 00                	push   $0x0
f0103239:	53                   	push   %ebx
f010323a:	8b 45 08             	mov    0x8(%ebp),%eax
f010323d:	ff 70 5c             	pushl  0x5c(%eax)
f0103240:	e8 d8 de ff ff       	call   f010111d <pgdir_walk>
		if(addr >= ULIM || pte == NULL || (*pte & perm) != perm){ //大于等于ULIM则地址无效
f0103245:	83 c4 10             	add    $0x10,%esp
f0103248:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010324e:	77 14                	ja     f0103264 <user_mem_check+0x6b>
f0103250:	85 c0                	test   %eax,%eax
f0103252:	74 10                	je     f0103264 <user_mem_check+0x6b>
f0103254:	89 f2                	mov    %esi,%edx
f0103256:	23 10                	and    (%eax),%edx
f0103258:	39 d6                	cmp    %edx,%esi
f010325a:	75 08                	jne    f0103264 <user_mem_check+0x6b>
	for(; addr < end; addr += PGSIZE){
f010325c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103262:	eb cc                	jmp    f0103230 <user_mem_check+0x37>
			if(addr < (uint32_t)va){
f0103264:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103267:	73 13                	jae    f010327c <user_mem_check+0x83>
				user_mem_check_addr = (uint32_t)va;
f0103269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010326c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010326f:	89 88 1c 23 00 00    	mov    %ecx,0x231c(%eax)
			return -E_FAULT;
f0103275:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010327a:	eb 15                	jmp    f0103291 <user_mem_check+0x98>
				user_mem_check_addr = addr;
f010327c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010327f:	89 98 1c 23 00 00    	mov    %ebx,0x231c(%eax)
			return -E_FAULT;
f0103285:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010328a:	eb 05                	jmp    f0103291 <user_mem_check+0x98>
	return 0;
f010328c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103291:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103294:	5b                   	pop    %ebx
f0103295:	5e                   	pop    %esi
f0103296:	5f                   	pop    %edi
f0103297:	5d                   	pop    %ebp
f0103298:	c3                   	ret    

f0103299 <user_mem_assert>:
{
f0103299:	55                   	push   %ebp
f010329a:	89 e5                	mov    %esp,%ebp
f010329c:	56                   	push   %esi
f010329d:	53                   	push   %ebx
f010329e:	e8 c4 ce ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01032a3:	81 c3 7d 6d 08 00    	add    $0x86d7d,%ebx
f01032a9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01032ac:	8b 45 14             	mov    0x14(%ebp),%eax
f01032af:	83 c8 04             	or     $0x4,%eax
f01032b2:	50                   	push   %eax
f01032b3:	ff 75 10             	pushl  0x10(%ebp)
f01032b6:	ff 75 0c             	pushl  0xc(%ebp)
f01032b9:	56                   	push   %esi
f01032ba:	e8 3a ff ff ff       	call   f01031f9 <user_mem_check>
f01032bf:	83 c4 10             	add    $0x10,%esp
f01032c2:	85 c0                	test   %eax,%eax
f01032c4:	78 07                	js     f01032cd <user_mem_assert+0x34>
}
f01032c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01032c9:	5b                   	pop    %ebx
f01032ca:	5e                   	pop    %esi
f01032cb:	5d                   	pop    %ebp
f01032cc:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01032cd:	83 ec 04             	sub    $0x4,%esp
f01032d0:	ff b3 1c 23 00 00    	pushl  0x231c(%ebx)
f01032d6:	ff 76 48             	pushl  0x48(%esi)
f01032d9:	8d 83 ac c2 f7 ff    	lea    -0x83d54(%ebx),%eax
f01032df:	50                   	push   %eax
f01032e0:	e8 4c 08 00 00       	call   f0103b31 <cprintf>
		env_destroy(env);	// may not return
f01032e5:	89 34 24             	mov    %esi,(%esp)
f01032e8:	e8 d6 06 00 00       	call   f01039c3 <env_destroy>
f01032ed:	83 c4 10             	add    $0x10,%esp
}
f01032f0:	eb d4                	jmp    f01032c6 <user_mem_assert+0x2d>

f01032f2 <__x86.get_pc_thunk.dx>:
f01032f2:	8b 14 24             	mov    (%esp),%edx
f01032f5:	c3                   	ret    

f01032f6 <__x86.get_pc_thunk.cx>:
f01032f6:	8b 0c 24             	mov    (%esp),%ecx
f01032f9:	c3                   	ret    

f01032fa <__x86.get_pc_thunk.di>:
f01032fa:	8b 3c 24             	mov    (%esp),%edi
f01032fd:	c3                   	ret    

f01032fe <region_alloc>:

// 申请长度为len的物理内存，将其映射到虚拟地址VA上去
// 根据提示，我们还应该将va和va+len对齐
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01032fe:	55                   	push   %ebp
f01032ff:	89 e5                	mov    %esp,%ebp
f0103301:	57                   	push   %edi
f0103302:	56                   	push   %esi
f0103303:	53                   	push   %ebx
f0103304:	83 ec 1c             	sub    $0x1c,%esp
f0103307:	e8 5b ce ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010330c:	81 c3 14 6d 08 00    	add    $0x86d14,%ebx
f0103312:	89 c7                	mov    %eax,%edi
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	//va和va+len对齐
	uint32_t va0 = ROUNDDOWN((uint32_t)va, PGSIZE);
	uint32_t va1 = ROUNDUP((uint32_t)va+len, PGSIZE);
f0103314:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f010331b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t va0 = ROUNDDOWN((uint32_t)va, PGSIZE);
f0103323:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103329:	89 d6                	mov    %edx,%esi
	struct PageInfo *pp;
	int i, r;
	//申请长度为len的内存
	for(i = va0; i < va1; i += PGSIZE){
f010332b:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010332e:	73 5f                	jae    f010338f <region_alloc+0x91>
		pp = (struct PageInfo*)page_alloc(0);
f0103330:	83 ec 0c             	sub    $0xc,%esp
f0103333:	6a 00                	push   $0x0
f0103335:	e8 e3 dc ff ff       	call   f010101d <page_alloc>
		if(!pp){ //判断内存分配是否成功
f010333a:	83 c4 10             	add    $0x10,%esp
f010333d:	85 c0                	test   %eax,%eax
f010333f:	74 1b                	je     f010335c <region_alloc+0x5e>
			panic("page allocation fails: %e", r);
		}
		r = page_insert(e->env_pgdir, pp, (void *)i, PTE_U | PTE_W); //将申请到的也插入到页表目录中去
f0103341:	6a 06                	push   $0x6
f0103343:	56                   	push   %esi
f0103344:	50                   	push   %eax
f0103345:	ff 77 5c             	pushl  0x5c(%edi)
f0103348:	e8 f4 df ff ff       	call   f0101341 <page_insert>
		if(r){ //判断上一步插入是否成功
f010334d:	83 c4 10             	add    $0x10,%esp
f0103350:	85 c0                	test   %eax,%eax
f0103352:	75 22                	jne    f0103376 <region_alloc+0x78>
	for(i = va0; i < va1; i += PGSIZE){
f0103354:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010335a:	eb cf                	jmp    f010332b <region_alloc+0x2d>
			panic("page allocation fails: %e", r);
f010335c:	6a 00                	push   $0x0
f010335e:	8d 83 c4 c5 f7 ff    	lea    -0x83a3c(%ebx),%eax
f0103364:	50                   	push   %eax
f0103365:	68 2d 01 00 00       	push   $0x12d
f010336a:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f0103370:	50                   	push   %eax
f0103371:	e8 3b cd ff ff       	call   f01000b1 <_panic>
			panic("page mapping fails: %e", r);
f0103376:	50                   	push   %eax
f0103377:	8d 83 e9 c5 f7 ff    	lea    -0x83a17(%ebx),%eax
f010337d:	50                   	push   %eax
f010337e:	68 31 01 00 00       	push   $0x131
f0103383:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f0103389:	50                   	push   %eax
f010338a:	e8 22 cd ff ff       	call   f01000b1 <_panic>
		}
	}
}
f010338f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103392:	5b                   	pop    %ebx
f0103393:	5e                   	pop    %esi
f0103394:	5f                   	pop    %edi
f0103395:	5d                   	pop    %ebp
f0103396:	c3                   	ret    

f0103397 <envid2env>:
{
f0103397:	55                   	push   %ebp
f0103398:	89 e5                	mov    %esp,%ebp
f010339a:	53                   	push   %ebx
f010339b:	e8 56 ff ff ff       	call   f01032f6 <__x86.get_pc_thunk.cx>
f01033a0:	81 c1 80 6c 08 00    	add    $0x86c80,%ecx
f01033a6:	8b 55 08             	mov    0x8(%ebp),%edx
f01033a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f01033ac:	85 d2                	test   %edx,%edx
f01033ae:	74 41                	je     f01033f1 <envid2env+0x5a>
	e = &envs[ENVX(envid)];
f01033b0:	89 d0                	mov    %edx,%eax
f01033b2:	25 ff 03 00 00       	and    $0x3ff,%eax
f01033b7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01033ba:	c1 e0 05             	shl    $0x5,%eax
f01033bd:	03 81 2c 23 00 00    	add    0x232c(%ecx),%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01033c3:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f01033c7:	74 3a                	je     f0103403 <envid2env+0x6c>
f01033c9:	39 50 48             	cmp    %edx,0x48(%eax)
f01033cc:	75 35                	jne    f0103403 <envid2env+0x6c>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01033ce:	84 db                	test   %bl,%bl
f01033d0:	74 12                	je     f01033e4 <envid2env+0x4d>
f01033d2:	8b 91 28 23 00 00    	mov    0x2328(%ecx),%edx
f01033d8:	39 c2                	cmp    %eax,%edx
f01033da:	74 08                	je     f01033e4 <envid2env+0x4d>
f01033dc:	8b 5a 48             	mov    0x48(%edx),%ebx
f01033df:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f01033e2:	75 2f                	jne    f0103413 <envid2env+0x7c>
	*env_store = e;
f01033e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01033e7:	89 03                	mov    %eax,(%ebx)
	return 0;
f01033e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033ee:	5b                   	pop    %ebx
f01033ef:	5d                   	pop    %ebp
f01033f0:	c3                   	ret    
		*env_store = curenv;
f01033f1:	8b 81 28 23 00 00    	mov    0x2328(%ecx),%eax
f01033f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01033fa:	89 01                	mov    %eax,(%ecx)
		return 0;
f01033fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0103401:	eb eb                	jmp    f01033ee <envid2env+0x57>
		*env_store = 0;
f0103403:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103406:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010340c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103411:	eb db                	jmp    f01033ee <envid2env+0x57>
		*env_store = 0;
f0103413:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103416:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010341c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103421:	eb cb                	jmp    f01033ee <envid2env+0x57>

f0103423 <env_init_percpu>:
{
f0103423:	55                   	push   %ebp
f0103424:	89 e5                	mov    %esp,%ebp
f0103426:	e8 de d2 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f010342b:	05 f5 6b 08 00       	add    $0x86bf5,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103430:	8d 80 e0 1f 00 00    	lea    0x1fe0(%eax),%eax
f0103436:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103439:	b8 23 00 00 00       	mov    $0x23,%eax
f010343e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103440:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103442:	b8 10 00 00 00       	mov    $0x10,%eax
f0103447:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103449:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010344b:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010344d:	ea 54 34 10 f0 08 00 	ljmp   $0x8,$0xf0103454
	asm volatile("lldt %0" : : "r" (sel));
f0103454:	b8 00 00 00 00       	mov    $0x0,%eax
f0103459:	0f 00 d0             	lldt   %ax
}
f010345c:	5d                   	pop    %ebp
f010345d:	c3                   	ret    

f010345e <env_init>:
{
f010345e:	55                   	push   %ebp
f010345f:	89 e5                	mov    %esp,%ebp
f0103461:	57                   	push   %edi
f0103462:	56                   	push   %esi
f0103463:	53                   	push   %ebx
f0103464:	e8 3d 06 00 00       	call   f0103aa6 <__x86.get_pc_thunk.si>
f0103469:	81 c6 b7 6b 08 00    	add    $0x86bb7,%esi
		envs[i].env_id = 0; //进程id为0
f010346f:	8b be 2c 23 00 00    	mov    0x232c(%esi),%edi
f0103475:	8b 96 30 23 00 00    	mov    0x2330(%esi),%edx
f010347b:	8d 87 a0 7f 01 00    	lea    0x17fa0(%edi),%eax
f0103481:	8d 5f a0             	lea    -0x60(%edi),%ebx
f0103484:	89 c1                	mov    %eax,%ecx
f0103486:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list; //添加入空闲队列
f010348d:	89 50 44             	mov    %edx,0x44(%eax)
f0103490:	83 e8 60             	sub    $0x60,%eax
		env_free_list = &envs[i]; //更新空闲队列指针
f0103493:	89 ca                	mov    %ecx,%edx
	for(i = NENV - 1; i >= 0; i--){
f0103495:	39 d8                	cmp    %ebx,%eax
f0103497:	75 eb                	jne    f0103484 <env_init+0x26>
f0103499:	89 be 30 23 00 00    	mov    %edi,0x2330(%esi)
	env_init_percpu();
f010349f:	e8 7f ff ff ff       	call   f0103423 <env_init_percpu>
}
f01034a4:	5b                   	pop    %ebx
f01034a5:	5e                   	pop    %esi
f01034a6:	5f                   	pop    %edi
f01034a7:	5d                   	pop    %ebp
f01034a8:	c3                   	ret    

f01034a9 <env_alloc>:
{
f01034a9:	55                   	push   %ebp
f01034aa:	89 e5                	mov    %esp,%ebp
f01034ac:	57                   	push   %edi
f01034ad:	56                   	push   %esi
f01034ae:	53                   	push   %ebx
f01034af:	83 ec 0c             	sub    $0xc,%esp
f01034b2:	e8 b0 cc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01034b7:	81 c3 69 6b 08 00    	add    $0x86b69,%ebx
	if (!(e = env_free_list))
f01034bd:	8b b3 30 23 00 00    	mov    0x2330(%ebx),%esi
f01034c3:	85 f6                	test   %esi,%esi
f01034c5:	0f 84 67 01 00 00    	je     f0103632 <env_alloc+0x189>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01034cb:	83 ec 0c             	sub    $0xc,%esp
f01034ce:	6a 01                	push   $0x1
f01034d0:	e8 48 db ff ff       	call   f010101d <page_alloc>
f01034d5:	89 c7                	mov    %eax,%edi
f01034d7:	83 c4 10             	add    $0x10,%esp
f01034da:	85 c0                	test   %eax,%eax
f01034dc:	0f 84 57 01 00 00    	je     f0103639 <env_alloc+0x190>
	return (pp - pages) << PGSHIFT;
f01034e2:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f01034e8:	89 f9                	mov    %edi,%ecx
f01034ea:	2b 08                	sub    (%eax),%ecx
f01034ec:	89 c8                	mov    %ecx,%eax
f01034ee:	c1 f8 03             	sar    $0x3,%eax
f01034f1:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01034f4:	89 c1                	mov    %eax,%ecx
f01034f6:	c1 e9 0c             	shr    $0xc,%ecx
f01034f9:	c7 c2 04 d0 18 f0    	mov    $0xf018d004,%edx
f01034ff:	3b 0a                	cmp    (%edx),%ecx
f0103501:	0f 83 fc 00 00 00    	jae    f0103603 <env_alloc+0x15a>
	return (void *)(pa + KERNBASE);
f0103507:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);
f010350c:	89 46 5c             	mov    %eax,0x5c(%esi)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE); //将kern_pgdir的内容拷贝过来
f010350f:	83 ec 04             	sub    $0x4,%esp
f0103512:	68 00 10 00 00       	push   $0x1000
f0103517:	c7 c2 08 d0 18 f0    	mov    $0xf018d008,%edx
f010351d:	ff 32                	pushl  (%edx)
f010351f:	50                   	push   %eax
f0103520:	e8 3a 1d 00 00       	call   f010525f <memcpy>
	p->pp_ref++; //为了使得env_free正常工作，这里我们需要递增其引用数
f0103525:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010352a:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f010352d:	83 c4 10             	add    $0x10,%esp
f0103530:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103535:	0f 86 de 00 00 00    	jbe    f0103619 <env_alloc+0x170>
	return (physaddr_t)kva - KERNBASE;
f010353b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103541:	83 ca 05             	or     $0x5,%edx
f0103544:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010354a:	8b 46 48             	mov    0x48(%esi),%eax
f010354d:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103552:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103557:	ba 00 10 00 00       	mov    $0x1000,%edx
f010355c:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010355f:	89 f2                	mov    %esi,%edx
f0103561:	2b 93 2c 23 00 00    	sub    0x232c(%ebx),%edx
f0103567:	c1 fa 05             	sar    $0x5,%edx
f010356a:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103570:	09 d0                	or     %edx,%eax
f0103572:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f0103575:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103578:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f010357b:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103582:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103589:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103590:	83 ec 04             	sub    $0x4,%esp
f0103593:	6a 44                	push   $0x44
f0103595:	6a 00                	push   $0x0
f0103597:	56                   	push   %esi
f0103598:	e8 0d 1c 00 00       	call   f01051aa <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010359d:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01035a3:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01035a9:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f01035af:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01035b6:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f01035bc:	8b 46 44             	mov    0x44(%esi),%eax
f01035bf:	89 83 30 23 00 00    	mov    %eax,0x2330(%ebx)
	*newenv_store = e;
f01035c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01035c8:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01035ca:	8b 4e 48             	mov    0x48(%esi),%ecx
f01035cd:	8b 83 28 23 00 00    	mov    0x2328(%ebx),%eax
f01035d3:	83 c4 10             	add    $0x10,%esp
f01035d6:	ba 00 00 00 00       	mov    $0x0,%edx
f01035db:	85 c0                	test   %eax,%eax
f01035dd:	74 03                	je     f01035e2 <env_alloc+0x139>
f01035df:	8b 50 48             	mov    0x48(%eax),%edx
f01035e2:	83 ec 04             	sub    $0x4,%esp
f01035e5:	51                   	push   %ecx
f01035e6:	52                   	push   %edx
f01035e7:	8d 83 00 c6 f7 ff    	lea    -0x83a00(%ebx),%eax
f01035ed:	50                   	push   %eax
f01035ee:	e8 3e 05 00 00       	call   f0103b31 <cprintf>
	return 0;
f01035f3:	83 c4 10             	add    $0x10,%esp
f01035f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01035fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035fe:	5b                   	pop    %ebx
f01035ff:	5e                   	pop    %esi
f0103600:	5f                   	pop    %edi
f0103601:	5d                   	pop    %ebp
f0103602:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103603:	50                   	push   %eax
f0103604:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f010360a:	50                   	push   %eax
f010360b:	6a 56                	push   $0x56
f010360d:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f0103613:	50                   	push   %eax
f0103614:	e8 98 ca ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103619:	50                   	push   %eax
f010361a:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0103620:	50                   	push   %eax
f0103621:	68 cb 00 00 00       	push   $0xcb
f0103626:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f010362c:	50                   	push   %eax
f010362d:	e8 7f ca ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f0103632:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103637:	eb c2                	jmp    f01035fb <env_alloc+0x152>
		return -E_NO_MEM;
f0103639:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010363e:	eb bb                	jmp    f01035fb <env_alloc+0x152>

f0103640 <env_create>:
// 分配使用环境，做好运行一个用户程序的全部准备
// 使用env_alloc申请一个进程描述结构，用load_icode将binary地址所对应的程序传入指定的虚拟空间，设置其env_type
// 
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103640:	55                   	push   %ebp
f0103641:	89 e5                	mov    %esp,%ebp
f0103643:	57                   	push   %edi
f0103644:	56                   	push   %esi
f0103645:	53                   	push   %ebx
f0103646:	83 ec 34             	sub    $0x34,%esp
f0103649:	e8 19 cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010364e:	81 c3 d2 69 08 00    	add    $0x869d2,%ebx
	// LAB 3: Your code here.
	struct Env *new_Env = NULL; //建立一个Env结构体指针用来表示新创建的Env结构
f0103654:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&new_Env, 0); //使用env_alloc申请一个Env结构
f010365b:	6a 00                	push   $0x0
f010365d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103660:	50                   	push   %eax
f0103661:	e8 43 fe ff ff       	call   f01034a9 <env_alloc>
	if (r < 0){ // 如果申请不到env结构（Env空闲队列中没有剩余，可参考env_alloc函数）
f0103666:	83 c4 10             	add    $0x10,%esp
f0103669:	85 c0                	test   %eax,%eax
f010366b:	78 39                	js     f01036a6 <env_create+0x66>
	    panic("No Free Env: %e", r);
	    return;
	}
	load_icode(new_Env, binary); //binary所对应的程序装载到指定的的空间
f010366d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103670:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    if (elfhdr->e_magic != ELF_MAGIC){ // 判断ELF头是否有效
f0103673:	8b 45 08             	mov    0x8(%ebp),%eax
f0103676:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010367c:	75 41                	jne    f01036bf <env_create+0x7f>
    ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff); //开始加载的程序段
f010367e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103681:	89 c6                	mov    %eax,%esi
f0103683:	03 70 1c             	add    0x1c(%eax),%esi
    eph = ph + elfhdr->e_phnum; //结束加载的程序段
f0103686:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f010368a:	c1 e7 05             	shl    $0x5,%edi
f010368d:	01 f7                	add    %esi,%edi
    lcr3(PADDR(e->env_pgdir)); //将页表切换到用户虚拟地址空间
f010368f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103692:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103695:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010369a:	76 3e                	jbe    f01036da <env_create+0x9a>
	return (physaddr_t)kva - KERNBASE;
f010369c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01036a1:	0f 22 d8             	mov    %eax,%cr3
f01036a4:	eb 6b                	jmp    f0103711 <env_create+0xd1>
	    panic("No Free Env: %e", r);
f01036a6:	50                   	push   %eax
f01036a7:	8d 83 15 c6 f7 ff    	lea    -0x839eb(%ebx),%eax
f01036ad:	50                   	push   %eax
f01036ae:	68 a5 01 00 00       	push   $0x1a5
f01036b3:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f01036b9:	50                   	push   %eax
f01036ba:	e8 f2 c9 ff ff       	call   f01000b1 <_panic>
		panic("The ELF header is incorrect！\n");
f01036bf:	83 ec 04             	sub    $0x4,%esp
f01036c2:	8d 83 48 c6 f7 ff    	lea    -0x839b8(%ebx),%eax
f01036c8:	50                   	push   %eax
f01036c9:	68 71 01 00 00       	push   $0x171
f01036ce:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f01036d4:	50                   	push   %eax
f01036d5:	e8 d7 c9 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036da:	50                   	push   %eax
f01036db:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f01036e1:	50                   	push   %eax
f01036e2:	68 79 01 00 00       	push   $0x179
f01036e7:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f01036ed:	50                   	push   %eax
f01036ee:	e8 be c9 ff ff       	call   f01000b1 <_panic>
			panic("The memory size is not enough to support loading the file.\n");
f01036f3:	83 ec 04             	sub    $0x4,%esp
f01036f6:	8d 83 68 c6 f7 ff    	lea    -0x83998(%ebx),%eax
f01036fc:	50                   	push   %eax
f01036fd:	68 83 01 00 00       	push   $0x183
f0103702:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f0103708:	50                   	push   %eax
f0103709:	e8 a3 c9 ff ff       	call   f01000b1 <_panic>
    for ( ;ph < eph; ph++) {
f010370e:	83 c6 20             	add    $0x20,%esi
f0103711:	39 f7                	cmp    %esi,%edi
f0103713:	76 49                	jbe    f010375e <env_create+0x11e>
        if (ph->p_type == ELF_PROG_LOAD){ //如果当前段需要被加载，才加载该段
f0103715:	83 3e 01             	cmpl   $0x1,(%esi)
f0103718:	75 f4                	jne    f010370e <env_create+0xce>
			if (ph->p_filesz > ph->p_memsz){
f010371a:	8b 4e 14             	mov    0x14(%esi),%ecx
f010371d:	39 4e 10             	cmp    %ecx,0x10(%esi)
f0103720:	77 d1                	ja     f01036f3 <env_create+0xb3>
        region_alloc(e, (void *) ph->p_va, ph->p_memsz); //申请空间，将对应段映射到p_va
f0103722:	8b 56 08             	mov    0x8(%esi),%edx
f0103725:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103728:	e8 d1 fb ff ff       	call   f01032fe <region_alloc>
		memmove((void *) ph->p_va, binary + ph->p_offset, ph->p_filesz); //将前filesz个字节拷贝对应虚拟空间
f010372d:	83 ec 04             	sub    $0x4,%esp
f0103730:	ff 76 10             	pushl  0x10(%esi)
f0103733:	8b 45 08             	mov    0x8(%ebp),%eax
f0103736:	03 46 04             	add    0x4(%esi),%eax
f0103739:	50                   	push   %eax
f010373a:	ff 76 08             	pushl  0x8(%esi)
f010373d:	e8 b5 1a 00 00       	call   f01051f7 <memmove>
		memset((void *) ph->p_va + ph->p_filesz, 0, (ph->p_memsz - ph->p_filesz)); //BBS段（剩下的虚拟空间）初始化为0
f0103742:	8b 46 10             	mov    0x10(%esi),%eax
f0103745:	83 c4 0c             	add    $0xc,%esp
f0103748:	8b 56 14             	mov    0x14(%esi),%edx
f010374b:	29 c2                	sub    %eax,%edx
f010374d:	52                   	push   %edx
f010374e:	6a 00                	push   $0x0
f0103750:	03 46 08             	add    0x8(%esi),%eax
f0103753:	50                   	push   %eax
f0103754:	e8 51 1a 00 00       	call   f01051aa <memset>
f0103759:	83 c4 10             	add    $0x10,%esp
f010375c:	eb b0                	jmp    f010370e <env_create+0xce>
	e->env_tf.tf_eip = elfhdr->e_entry; //设置程序的入口地址，让程序刚好能够从这里执行
f010375e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103761:	8b 40 18             	mov    0x18(%eax),%eax
f0103764:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103767:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *) USTACKTOP - PGSIZE, PGSIZE); //映射到虚拟地址STACKTOP - PGSIZE                                                                                                                               
f010376a:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010376f:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103774:	89 f8                	mov    %edi,%eax
f0103776:	e8 83 fb ff ff       	call   f01032fe <region_alloc>
    lcr3(PADDR(kern_pgdir)); //将页表切换回内核虚拟地址空间
f010377b:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f0103781:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103783:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103788:	76 19                	jbe    f01037a3 <env_create+0x163>
	return (physaddr_t)kva - KERNBASE;
f010378a:	05 00 00 00 10       	add    $0x10000000,%eax
f010378f:	0f 22 d8             	mov    %eax,%cr3
	new_Env->env_type = type;
f0103792:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103795:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103798:	89 50 50             	mov    %edx,0x50(%eax)
}
f010379b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010379e:	5b                   	pop    %ebx
f010379f:	5e                   	pop    %esi
f01037a0:	5f                   	pop    %edi
f01037a1:	5d                   	pop    %ebp
f01037a2:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037a3:	50                   	push   %eax
f01037a4:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f01037aa:	50                   	push   %eax
f01037ab:	68 91 01 00 00       	push   $0x191
f01037b0:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f01037b6:	50                   	push   %eax
f01037b7:	e8 f5 c8 ff ff       	call   f01000b1 <_panic>

f01037bc <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01037bc:	55                   	push   %ebp
f01037bd:	89 e5                	mov    %esp,%ebp
f01037bf:	57                   	push   %edi
f01037c0:	56                   	push   %esi
f01037c1:	53                   	push   %ebx
f01037c2:	83 ec 2c             	sub    $0x2c,%esp
f01037c5:	e8 9d c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01037ca:	81 c3 56 68 08 00    	add    $0x86856,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01037d0:	8b 93 28 23 00 00    	mov    0x2328(%ebx),%edx
f01037d6:	3b 55 08             	cmp    0x8(%ebp),%edx
f01037d9:	75 17                	jne    f01037f2 <env_free+0x36>
		lcr3(PADDR(kern_pgdir));
f01037db:	c7 c0 08 d0 18 f0    	mov    $0xf018d008,%eax
f01037e1:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01037e3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037e8:	76 46                	jbe    f0103830 <env_free+0x74>
	return (physaddr_t)kva - KERNBASE;
f01037ea:	05 00 00 00 10       	add    $0x10000000,%eax
f01037ef:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f5:	8b 48 48             	mov    0x48(%eax),%ecx
f01037f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01037fd:	85 d2                	test   %edx,%edx
f01037ff:	74 03                	je     f0103804 <env_free+0x48>
f0103801:	8b 42 48             	mov    0x48(%edx),%eax
f0103804:	83 ec 04             	sub    $0x4,%esp
f0103807:	51                   	push   %ecx
f0103808:	50                   	push   %eax
f0103809:	8d 83 25 c6 f7 ff    	lea    -0x839db(%ebx),%eax
f010380f:	50                   	push   %eax
f0103810:	e8 1c 03 00 00       	call   f0103b31 <cprintf>
f0103815:	83 c4 10             	add    $0x10,%esp
f0103818:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	if (PGNUM(pa) >= npages)
f010381f:	c7 c0 04 d0 18 f0    	mov    $0xf018d004,%eax
f0103825:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f0103828:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010382b:	e9 9f 00 00 00       	jmp    f01038cf <env_free+0x113>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103830:	50                   	push   %eax
f0103831:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0103837:	50                   	push   %eax
f0103838:	68 ba 01 00 00       	push   $0x1ba
f010383d:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f0103843:	50                   	push   %eax
f0103844:	e8 68 c8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103849:	50                   	push   %eax
f010384a:	8d 83 c8 ba f7 ff    	lea    -0x84538(%ebx),%eax
f0103850:	50                   	push   %eax
f0103851:	68 c9 01 00 00       	push   $0x1c9
f0103856:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f010385c:	50                   	push   %eax
f010385d:	e8 4f c8 ff ff       	call   f01000b1 <_panic>
f0103862:	83 c6 04             	add    $0x4,%esi
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103865:	39 fe                	cmp    %edi,%esi
f0103867:	74 24                	je     f010388d <env_free+0xd1>
			if (pt[pteno] & PTE_P)
f0103869:	f6 06 01             	testb  $0x1,(%esi)
f010386c:	74 f4                	je     f0103862 <env_free+0xa6>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010386e:	83 ec 08             	sub    $0x8,%esp
f0103871:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103874:	01 f0                	add    %esi,%eax
f0103876:	c1 e0 0a             	shl    $0xa,%eax
f0103879:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010387c:	50                   	push   %eax
f010387d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103880:	ff 70 5c             	pushl  0x5c(%eax)
f0103883:	e8 7c da ff ff       	call   f0101304 <page_remove>
f0103888:	83 c4 10             	add    $0x10,%esp
f010388b:	eb d5                	jmp    f0103862 <env_free+0xa6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010388d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103890:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103893:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103896:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f010389d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01038a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01038a3:	3b 10                	cmp    (%eax),%edx
f01038a5:	73 6f                	jae    f0103916 <env_free+0x15a>
		page_decref(pa2page(pa));
f01038a7:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01038aa:	c7 c0 0c d0 18 f0    	mov    $0xf018d00c,%eax
f01038b0:	8b 00                	mov    (%eax),%eax
f01038b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01038b5:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01038b8:	50                   	push   %eax
f01038b9:	e8 36 d8 ff ff       	call   f01010f4 <page_decref>
f01038be:	83 c4 10             	add    $0x10,%esp
f01038c1:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f01038c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01038c8:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01038cd:	74 5f                	je     f010392e <env_free+0x172>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01038cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01038d2:	8b 40 5c             	mov    0x5c(%eax),%eax
f01038d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01038d8:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01038db:	a8 01                	test   $0x1,%al
f01038dd:	74 e2                	je     f01038c1 <env_free+0x105>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01038df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01038e4:	89 c2                	mov    %eax,%edx
f01038e6:	c1 ea 0c             	shr    $0xc,%edx
f01038e9:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01038ec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01038ef:	39 11                	cmp    %edx,(%ecx)
f01038f1:	0f 86 52 ff ff ff    	jbe    f0103849 <env_free+0x8d>
	return (void *)(pa + KERNBASE);
f01038f7:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01038fd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103900:	c1 e2 14             	shl    $0x14,%edx
f0103903:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103906:	8d b8 00 10 00 f0    	lea    -0xffff000(%eax),%edi
f010390c:	f7 d8                	neg    %eax
f010390e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103911:	e9 53 ff ff ff       	jmp    f0103869 <env_free+0xad>
		panic("pa2page called with invalid pa");
f0103916:	83 ec 04             	sub    $0x4,%esp
f0103919:	8d 83 30 bc f7 ff    	lea    -0x843d0(%ebx),%eax
f010391f:	50                   	push   %eax
f0103920:	6a 4f                	push   $0x4f
f0103922:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f0103928:	50                   	push   %eax
f0103929:	e8 83 c7 ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010392e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103931:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103934:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103939:	76 57                	jbe    f0103992 <env_free+0x1d6>
	e->env_pgdir = 0;
f010393b:	8b 55 08             	mov    0x8(%ebp),%edx
f010393e:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103945:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f010394a:	c1 e8 0c             	shr    $0xc,%eax
f010394d:	c7 c2 04 d0 18 f0    	mov    $0xf018d004,%edx
f0103953:	3b 02                	cmp    (%edx),%eax
f0103955:	73 54                	jae    f01039ab <env_free+0x1ef>
	page_decref(pa2page(pa));
f0103957:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010395a:	c7 c2 0c d0 18 f0    	mov    $0xf018d00c,%edx
f0103960:	8b 12                	mov    (%edx),%edx
f0103962:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103965:	50                   	push   %eax
f0103966:	e8 89 d7 ff ff       	call   f01010f4 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010396b:	8b 45 08             	mov    0x8(%ebp),%eax
f010396e:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103975:	8b 83 30 23 00 00    	mov    0x2330(%ebx),%eax
f010397b:	8b 55 08             	mov    0x8(%ebp),%edx
f010397e:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103981:	89 93 30 23 00 00    	mov    %edx,0x2330(%ebx)
}
f0103987:	83 c4 10             	add    $0x10,%esp
f010398a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010398d:	5b                   	pop    %ebx
f010398e:	5e                   	pop    %esi
f010398f:	5f                   	pop    %edi
f0103990:	5d                   	pop    %ebp
f0103991:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103992:	50                   	push   %eax
f0103993:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0103999:	50                   	push   %eax
f010399a:	68 d7 01 00 00       	push   $0x1d7
f010399f:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f01039a5:	50                   	push   %eax
f01039a6:	e8 06 c7 ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f01039ab:	83 ec 04             	sub    $0x4,%esp
f01039ae:	8d 83 30 bc f7 ff    	lea    -0x843d0(%ebx),%eax
f01039b4:	50                   	push   %eax
f01039b5:	6a 4f                	push   $0x4f
f01039b7:	8d 83 ed c2 f7 ff    	lea    -0x83d13(%ebx),%eax
f01039bd:	50                   	push   %eax
f01039be:	e8 ee c6 ff ff       	call   f01000b1 <_panic>

f01039c3 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01039c3:	55                   	push   %ebp
f01039c4:	89 e5                	mov    %esp,%ebp
f01039c6:	53                   	push   %ebx
f01039c7:	83 ec 10             	sub    $0x10,%esp
f01039ca:	e8 98 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01039cf:	81 c3 51 66 08 00    	add    $0x86651,%ebx
	env_free(e);
f01039d5:	ff 75 08             	pushl  0x8(%ebp)
f01039d8:	e8 df fd ff ff       	call   f01037bc <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01039dd:	8d 83 a4 c6 f7 ff    	lea    -0x8395c(%ebx),%eax
f01039e3:	89 04 24             	mov    %eax,(%esp)
f01039e6:	e8 46 01 00 00       	call   f0103b31 <cprintf>
f01039eb:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01039ee:	83 ec 0c             	sub    $0xc,%esp
f01039f1:	6a 00                	push   $0x0
f01039f3:	e8 ef ce ff ff       	call   f01008e7 <monitor>
f01039f8:	83 c4 10             	add    $0x10,%esp
f01039fb:	eb f1                	jmp    f01039ee <env_destroy+0x2b>

f01039fd <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01039fd:	55                   	push   %ebp
f01039fe:	89 e5                	mov    %esp,%ebp
f0103a00:	53                   	push   %ebx
f0103a01:	83 ec 08             	sub    $0x8,%esp
f0103a04:	e8 5e c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103a09:	81 c3 17 66 08 00    	add    $0x86617,%ebx
	asm volatile(
f0103a0f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103a12:	61                   	popa   
f0103a13:	07                   	pop    %es
f0103a14:	1f                   	pop    %ds
f0103a15:	83 c4 08             	add    $0x8,%esp
f0103a18:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103a19:	8d 83 3b c6 f7 ff    	lea    -0x839c5(%ebx),%eax
f0103a1f:	50                   	push   %eax
f0103a20:	68 00 02 00 00       	push   $0x200
f0103a25:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f0103a2b:	50                   	push   %eax
f0103a2c:	e8 80 c6 ff ff       	call   f01000b1 <_panic>

f0103a31 <env_run>:
// 进程运行函数，类似于进程调度
// 一个新的进程要运行，如果现在的进程是运行状态，则变为就绪状态
// 切换新的进程为当前进程，并置为运行状态
void
env_run(struct Env *e)
{
f0103a31:	55                   	push   %ebp
f0103a32:	89 e5                	mov    %esp,%ebp
f0103a34:	53                   	push   %ebx
f0103a35:	83 ec 04             	sub    $0x4,%esp
f0103a38:	e8 2a c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103a3d:	81 c3 e3 65 08 00    	add    $0x865e3,%ebx
f0103a43:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv)
f0103a46:	8b 93 28 23 00 00    	mov    0x2328(%ebx),%edx
f0103a4c:	85 d2                	test   %edx,%edx
f0103a4e:	74 06                	je     f0103a56 <env_run+0x25>
	{
	    if (curenv->env_status == ENV_RUNNING){ //如果当前运行状态则变为就绪状态
f0103a50:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103a54:	74 35                	je     f0103a8b <env_run+0x5a>
    	    curenv->env_status = ENV_RUNNABLE;
	    }
	}
	// 当前进程是新进程，并变为运行状态
	curenv = e;
f0103a56:	89 83 28 23 00 00    	mov    %eax,0x2328(%ebx)
	e->env_status = ENV_RUNNING;
f0103a5c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	e->env_runs++; //运行的次数增加
f0103a63:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(e->env_pgdir)); //将也表切换到当前用户环境运行的虚拟空间
f0103a67:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103a6a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103a70:	77 22                	ja     f0103a94 <env_run+0x63>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a72:	52                   	push   %edx
f0103a73:	8d 83 d4 bb f7 ff    	lea    -0x8442c(%ebx),%eax
f0103a79:	50                   	push   %eax
f0103a7a:	68 2b 02 00 00       	push   $0x22b
f0103a7f:	8d 83 de c5 f7 ff    	lea    -0x83a22(%ebx),%eax
f0103a85:	50                   	push   %eax
f0103a86:	e8 26 c6 ff ff       	call   f01000b1 <_panic>
    	    curenv->env_status = ENV_RUNNABLE;
f0103a8b:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f0103a92:	eb c2                	jmp    f0103a56 <env_run+0x25>
	return (physaddr_t)kva - KERNBASE;
f0103a94:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103a9a:	0f 22 da             	mov    %edx,%cr3

	// 利用env_pop_tf()函数恢复用户环境寄存器，真正切换到用户程序（用户态）的过程
	// 其原理是将当前进程的trapframe用出栈的形式，切换当前的运行环境
    env_pop_tf(&e->env_tf);
f0103a9d:	83 ec 0c             	sub    $0xc,%esp
f0103aa0:	50                   	push   %eax
f0103aa1:	e8 57 ff ff ff       	call   f01039fd <env_pop_tf>

f0103aa6 <__x86.get_pc_thunk.si>:
f0103aa6:	8b 34 24             	mov    (%esp),%esi
f0103aa9:	c3                   	ret    

f0103aaa <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103aaa:	55                   	push   %ebp
f0103aab:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103aad:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ab0:	ba 70 00 00 00       	mov    $0x70,%edx
f0103ab5:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103ab6:	ba 71 00 00 00       	mov    $0x71,%edx
f0103abb:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103abc:	0f b6 c0             	movzbl %al,%eax
}
f0103abf:	5d                   	pop    %ebp
f0103ac0:	c3                   	ret    

f0103ac1 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103ac1:	55                   	push   %ebp
f0103ac2:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103ac4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ac7:	ba 70 00 00 00       	mov    $0x70,%edx
f0103acc:	ee                   	out    %al,(%dx)
f0103acd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ad0:	ba 71 00 00 00       	mov    $0x71,%edx
f0103ad5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103ad6:	5d                   	pop    %ebp
f0103ad7:	c3                   	ret    

f0103ad8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103ad8:	55                   	push   %ebp
f0103ad9:	89 e5                	mov    %esp,%ebp
f0103adb:	53                   	push   %ebx
f0103adc:	83 ec 10             	sub    $0x10,%esp
f0103adf:	e8 83 c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103ae4:	81 c3 3c 65 08 00    	add    $0x8653c,%ebx
	cputchar(ch);
f0103aea:	ff 75 08             	pushl  0x8(%ebp)
f0103aed:	e8 ec cb ff ff       	call   f01006de <cputchar>
	*cnt++;
}
f0103af2:	83 c4 10             	add    $0x10,%esp
f0103af5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103af8:	c9                   	leave  
f0103af9:	c3                   	ret    

f0103afa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103afa:	55                   	push   %ebp
f0103afb:	89 e5                	mov    %esp,%ebp
f0103afd:	53                   	push   %ebx
f0103afe:	83 ec 14             	sub    $0x14,%esp
f0103b01:	e8 61 c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103b06:	81 c3 1a 65 08 00    	add    $0x8651a,%ebx
	int cnt = 0;
f0103b0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103b13:	ff 75 0c             	pushl  0xc(%ebp)
f0103b16:	ff 75 08             	pushl  0x8(%ebp)
f0103b19:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b1c:	50                   	push   %eax
f0103b1d:	8d 83 b8 9a f7 ff    	lea    -0x86548(%ebx),%eax
f0103b23:	50                   	push   %eax
f0103b24:	e8 00 0f 00 00       	call   f0104a29 <vprintfmt>
	return cnt;
}
f0103b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b2f:	c9                   	leave  
f0103b30:	c3                   	ret    

f0103b31 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103b31:	55                   	push   %ebp
f0103b32:	89 e5                	mov    %esp,%ebp
f0103b34:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b37:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b3a:	50                   	push   %eax
f0103b3b:	ff 75 08             	pushl  0x8(%ebp)
f0103b3e:	e8 b7 ff ff ff       	call   f0103afa <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b43:	c9                   	leave  
f0103b44:	c3                   	ret    

f0103b45 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b45:	55                   	push   %ebp
f0103b46:	89 e5                	mov    %esp,%ebp
f0103b48:	57                   	push   %edi
f0103b49:	56                   	push   %esi
f0103b4a:	53                   	push   %ebx
f0103b4b:	83 ec 04             	sub    $0x4,%esp
f0103b4e:	e8 14 c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103b53:	81 c3 cd 64 08 00    	add    $0x864cd,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103b59:	c7 83 64 2b 00 00 00 	movl   $0xf0000000,0x2b64(%ebx)
f0103b60:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103b63:	66 c7 83 68 2b 00 00 	movw   $0x10,0x2b68(%ebx)
f0103b6a:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103b6c:	66 c7 83 c6 2b 00 00 	movw   $0x68,0x2bc6(%ebx)
f0103b73:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103b75:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f0103b7b:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103b81:	8d b3 60 2b 00 00    	lea    0x2b60(%ebx),%esi
f0103b87:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103b8b:	89 f2                	mov    %esi,%edx
f0103b8d:	c1 ea 10             	shr    $0x10,%edx
f0103b90:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103b93:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f0103b97:	83 e2 f0             	and    $0xfffffff0,%edx
f0103b9a:	83 ca 09             	or     $0x9,%edx
f0103b9d:	83 e2 9f             	and    $0xffffff9f,%edx
f0103ba0:	83 ca 80             	or     $0xffffff80,%edx
f0103ba3:	88 55 f3             	mov    %dl,-0xd(%ebp)
f0103ba6:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103ba9:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103bad:	83 e1 c0             	and    $0xffffffc0,%ecx
f0103bb0:	83 c9 40             	or     $0x40,%ecx
f0103bb3:	83 e1 7f             	and    $0x7f,%ecx
f0103bb6:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103bb9:	c1 ee 18             	shr    $0x18,%esi
f0103bbc:	89 f1                	mov    %esi,%ecx
f0103bbe:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103bc1:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f0103bc5:	83 e2 ef             	and    $0xffffffef,%edx
f0103bc8:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103bcb:	b8 28 00 00 00       	mov    $0x28,%eax
f0103bd0:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103bd3:	8d 83 e8 1f 00 00    	lea    0x1fe8(%ebx),%eax
f0103bd9:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103bdc:	83 c4 04             	add    $0x4,%esp
f0103bdf:	5b                   	pop    %ebx
f0103be0:	5e                   	pop    %esi
f0103be1:	5f                   	pop    %edi
f0103be2:	5d                   	pop    %ebp
f0103be3:	c3                   	ret    

f0103be4 <trap_init>:
{
f0103be4:	55                   	push   %ebp
f0103be5:	89 e5                	mov    %esp,%ebp
f0103be7:	e8 1d cb ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f0103bec:	05 34 64 08 00       	add    $0x86434,%eax
	SETGATE(idt[T_DIVIDE], 0, GD_KT, trap_divide, 0);
f0103bf1:	c7 c2 c6 43 10 f0    	mov    $0xf01043c6,%edx
f0103bf7:	66 89 90 40 23 00 00 	mov    %dx,0x2340(%eax)
f0103bfe:	66 c7 80 42 23 00 00 	movw   $0x8,0x2342(%eax)
f0103c05:	08 00 
f0103c07:	c6 80 44 23 00 00 00 	movb   $0x0,0x2344(%eax)
f0103c0e:	c6 80 45 23 00 00 8e 	movb   $0x8e,0x2345(%eax)
f0103c15:	c1 ea 10             	shr    $0x10,%edx
f0103c18:	66 89 90 46 23 00 00 	mov    %dx,0x2346(%eax)
    SETGATE(idt[T_DEBUG], 0, GD_KT, trap_debug, 0);
f0103c1f:	c7 c2 cc 43 10 f0    	mov    $0xf01043cc,%edx
f0103c25:	66 89 90 48 23 00 00 	mov    %dx,0x2348(%eax)
f0103c2c:	66 c7 80 4a 23 00 00 	movw   $0x8,0x234a(%eax)
f0103c33:	08 00 
f0103c35:	c6 80 4c 23 00 00 00 	movb   $0x0,0x234c(%eax)
f0103c3c:	c6 80 4d 23 00 00 8e 	movb   $0x8e,0x234d(%eax)
f0103c43:	c1 ea 10             	shr    $0x10,%edx
f0103c46:	66 89 90 4e 23 00 00 	mov    %dx,0x234e(%eax)
    SETGATE(idt[T_NMI], 0, GD_KT, trap_nmi, 0);
f0103c4d:	c7 c2 d2 43 10 f0    	mov    $0xf01043d2,%edx
f0103c53:	66 89 90 50 23 00 00 	mov    %dx,0x2350(%eax)
f0103c5a:	66 c7 80 52 23 00 00 	movw   $0x8,0x2352(%eax)
f0103c61:	08 00 
f0103c63:	c6 80 54 23 00 00 00 	movb   $0x0,0x2354(%eax)
f0103c6a:	c6 80 55 23 00 00 8e 	movb   $0x8e,0x2355(%eax)
f0103c71:	c1 ea 10             	shr    $0x10,%edx
f0103c74:	66 89 90 56 23 00 00 	mov    %dx,0x2356(%eax)
    SETGATE(idt[T_BRKPT], 0, GD_KT, trap_brkpt, 3); //这里需要注意，断点功能是用户态（level3）都可以用的，其他的只能核态使用
f0103c7b:	c7 c2 d8 43 10 f0    	mov    $0xf01043d8,%edx
f0103c81:	66 89 90 58 23 00 00 	mov    %dx,0x2358(%eax)
f0103c88:	66 c7 80 5a 23 00 00 	movw   $0x8,0x235a(%eax)
f0103c8f:	08 00 
f0103c91:	c6 80 5c 23 00 00 00 	movb   $0x0,0x235c(%eax)
f0103c98:	c6 80 5d 23 00 00 ee 	movb   $0xee,0x235d(%eax)
f0103c9f:	c1 ea 10             	shr    $0x10,%edx
f0103ca2:	66 89 90 5e 23 00 00 	mov    %dx,0x235e(%eax)
    SETGATE(idt[T_OFLOW], 0, GD_KT, trap_oflow, 0);
f0103ca9:	c7 c2 de 43 10 f0    	mov    $0xf01043de,%edx
f0103caf:	66 89 90 60 23 00 00 	mov    %dx,0x2360(%eax)
f0103cb6:	66 c7 80 62 23 00 00 	movw   $0x8,0x2362(%eax)
f0103cbd:	08 00 
f0103cbf:	c6 80 64 23 00 00 00 	movb   $0x0,0x2364(%eax)
f0103cc6:	c6 80 65 23 00 00 8e 	movb   $0x8e,0x2365(%eax)
f0103ccd:	c1 ea 10             	shr    $0x10,%edx
f0103cd0:	66 89 90 66 23 00 00 	mov    %dx,0x2366(%eax)
    SETGATE(idt[T_BOUND], 0, GD_KT, trap_bound, 0);
f0103cd7:	c7 c2 e4 43 10 f0    	mov    $0xf01043e4,%edx
f0103cdd:	66 89 90 68 23 00 00 	mov    %dx,0x2368(%eax)
f0103ce4:	66 c7 80 6a 23 00 00 	movw   $0x8,0x236a(%eax)
f0103ceb:	08 00 
f0103ced:	c6 80 6c 23 00 00 00 	movb   $0x0,0x236c(%eax)
f0103cf4:	c6 80 6d 23 00 00 8e 	movb   $0x8e,0x236d(%eax)
f0103cfb:	c1 ea 10             	shr    $0x10,%edx
f0103cfe:	66 89 90 6e 23 00 00 	mov    %dx,0x236e(%eax)
    SETGATE(idt[T_ILLOP], 0, GD_KT, trap_illop, 0);
f0103d05:	c7 c2 ea 43 10 f0    	mov    $0xf01043ea,%edx
f0103d0b:	66 89 90 70 23 00 00 	mov    %dx,0x2370(%eax)
f0103d12:	66 c7 80 72 23 00 00 	movw   $0x8,0x2372(%eax)
f0103d19:	08 00 
f0103d1b:	c6 80 74 23 00 00 00 	movb   $0x0,0x2374(%eax)
f0103d22:	c6 80 75 23 00 00 8e 	movb   $0x8e,0x2375(%eax)
f0103d29:	c1 ea 10             	shr    $0x10,%edx
f0103d2c:	66 89 90 76 23 00 00 	mov    %dx,0x2376(%eax)
    SETGATE(idt[T_DEVICE], 0, GD_KT, trap_device, 0);
f0103d33:	c7 c2 f0 43 10 f0    	mov    $0xf01043f0,%edx
f0103d39:	66 89 90 78 23 00 00 	mov    %dx,0x2378(%eax)
f0103d40:	66 c7 80 7a 23 00 00 	movw   $0x8,0x237a(%eax)
f0103d47:	08 00 
f0103d49:	c6 80 7c 23 00 00 00 	movb   $0x0,0x237c(%eax)
f0103d50:	c6 80 7d 23 00 00 8e 	movb   $0x8e,0x237d(%eax)
f0103d57:	c1 ea 10             	shr    $0x10,%edx
f0103d5a:	66 89 90 7e 23 00 00 	mov    %dx,0x237e(%eax)
    SETGATE(idt[T_DBLFLT], 0, GD_KT, trap_dblflt, 0);
f0103d61:	c7 c2 f6 43 10 f0    	mov    $0xf01043f6,%edx
f0103d67:	66 89 90 80 23 00 00 	mov    %dx,0x2380(%eax)
f0103d6e:	66 c7 80 82 23 00 00 	movw   $0x8,0x2382(%eax)
f0103d75:	08 00 
f0103d77:	c6 80 84 23 00 00 00 	movb   $0x0,0x2384(%eax)
f0103d7e:	c6 80 85 23 00 00 8e 	movb   $0x8e,0x2385(%eax)
f0103d85:	c1 ea 10             	shr    $0x10,%edx
f0103d88:	66 89 90 86 23 00 00 	mov    %dx,0x2386(%eax)
    SETGATE(idt[T_TSS], 0, GD_KT, trap_tss, 0);
f0103d8f:	c7 c2 fa 43 10 f0    	mov    $0xf01043fa,%edx
f0103d95:	66 89 90 90 23 00 00 	mov    %dx,0x2390(%eax)
f0103d9c:	66 c7 80 92 23 00 00 	movw   $0x8,0x2392(%eax)
f0103da3:	08 00 
f0103da5:	c6 80 94 23 00 00 00 	movb   $0x0,0x2394(%eax)
f0103dac:	c6 80 95 23 00 00 8e 	movb   $0x8e,0x2395(%eax)
f0103db3:	c1 ea 10             	shr    $0x10,%edx
f0103db6:	66 89 90 96 23 00 00 	mov    %dx,0x2396(%eax)
    SETGATE(idt[T_SEGNP], 0, GD_KT, trap_segnp, 0);
f0103dbd:	c7 c2 fe 43 10 f0    	mov    $0xf01043fe,%edx
f0103dc3:	66 89 90 98 23 00 00 	mov    %dx,0x2398(%eax)
f0103dca:	66 c7 80 9a 23 00 00 	movw   $0x8,0x239a(%eax)
f0103dd1:	08 00 
f0103dd3:	c6 80 9c 23 00 00 00 	movb   $0x0,0x239c(%eax)
f0103dda:	c6 80 9d 23 00 00 8e 	movb   $0x8e,0x239d(%eax)
f0103de1:	c1 ea 10             	shr    $0x10,%edx
f0103de4:	66 89 90 9e 23 00 00 	mov    %dx,0x239e(%eax)
    SETGATE(idt[T_STACK], 0, GD_KT, trap_stack, 0);
f0103deb:	c7 c2 02 44 10 f0    	mov    $0xf0104402,%edx
f0103df1:	66 89 90 a0 23 00 00 	mov    %dx,0x23a0(%eax)
f0103df8:	66 c7 80 a2 23 00 00 	movw   $0x8,0x23a2(%eax)
f0103dff:	08 00 
f0103e01:	c6 80 a4 23 00 00 00 	movb   $0x0,0x23a4(%eax)
f0103e08:	c6 80 a5 23 00 00 8e 	movb   $0x8e,0x23a5(%eax)
f0103e0f:	c1 ea 10             	shr    $0x10,%edx
f0103e12:	66 89 90 a6 23 00 00 	mov    %dx,0x23a6(%eax)
    SETGATE(idt[T_GPFLT], 0, GD_KT, trap_gpflt, 0);
f0103e19:	c7 c2 06 44 10 f0    	mov    $0xf0104406,%edx
f0103e1f:	66 89 90 a8 23 00 00 	mov    %dx,0x23a8(%eax)
f0103e26:	66 c7 80 aa 23 00 00 	movw   $0x8,0x23aa(%eax)
f0103e2d:	08 00 
f0103e2f:	c6 80 ac 23 00 00 00 	movb   $0x0,0x23ac(%eax)
f0103e36:	c6 80 ad 23 00 00 8e 	movb   $0x8e,0x23ad(%eax)
f0103e3d:	c1 ea 10             	shr    $0x10,%edx
f0103e40:	66 89 90 ae 23 00 00 	mov    %dx,0x23ae(%eax)
    SETGATE(idt[T_PGFLT], 0, GD_KT, trap_pgflt, 0);
f0103e47:	c7 c2 0a 44 10 f0    	mov    $0xf010440a,%edx
f0103e4d:	66 89 90 b0 23 00 00 	mov    %dx,0x23b0(%eax)
f0103e54:	66 c7 80 b2 23 00 00 	movw   $0x8,0x23b2(%eax)
f0103e5b:	08 00 
f0103e5d:	c6 80 b4 23 00 00 00 	movb   $0x0,0x23b4(%eax)
f0103e64:	c6 80 b5 23 00 00 8e 	movb   $0x8e,0x23b5(%eax)
f0103e6b:	c1 ea 10             	shr    $0x10,%edx
f0103e6e:	66 89 90 b6 23 00 00 	mov    %dx,0x23b6(%eax)
    SETGATE(idt[T_FPERR], 0, GD_KT, trap_fperr, 0);
f0103e75:	c7 c2 0e 44 10 f0    	mov    $0xf010440e,%edx
f0103e7b:	66 89 90 c0 23 00 00 	mov    %dx,0x23c0(%eax)
f0103e82:	66 c7 80 c2 23 00 00 	movw   $0x8,0x23c2(%eax)
f0103e89:	08 00 
f0103e8b:	c6 80 c4 23 00 00 00 	movb   $0x0,0x23c4(%eax)
f0103e92:	c6 80 c5 23 00 00 8e 	movb   $0x8e,0x23c5(%eax)
f0103e99:	c1 ea 10             	shr    $0x10,%edx
f0103e9c:	66 89 90 c6 23 00 00 	mov    %dx,0x23c6(%eax)
    SETGATE(idt[T_ALIGN], 0, GD_KT, trap_align, 0);
f0103ea3:	c7 c2 14 44 10 f0    	mov    $0xf0104414,%edx
f0103ea9:	66 89 90 c8 23 00 00 	mov    %dx,0x23c8(%eax)
f0103eb0:	66 c7 80 ca 23 00 00 	movw   $0x8,0x23ca(%eax)
f0103eb7:	08 00 
f0103eb9:	c6 80 cc 23 00 00 00 	movb   $0x0,0x23cc(%eax)
f0103ec0:	c6 80 cd 23 00 00 8e 	movb   $0x8e,0x23cd(%eax)
f0103ec7:	c1 ea 10             	shr    $0x10,%edx
f0103eca:	66 89 90 ce 23 00 00 	mov    %dx,0x23ce(%eax)
    SETGATE(idt[T_MCHK], 0, GD_KT, trap_mchk, 0);
f0103ed1:	c7 c2 18 44 10 f0    	mov    $0xf0104418,%edx
f0103ed7:	66 89 90 d0 23 00 00 	mov    %dx,0x23d0(%eax)
f0103ede:	66 c7 80 d2 23 00 00 	movw   $0x8,0x23d2(%eax)
f0103ee5:	08 00 
f0103ee7:	c6 80 d4 23 00 00 00 	movb   $0x0,0x23d4(%eax)
f0103eee:	c6 80 d5 23 00 00 8e 	movb   $0x8e,0x23d5(%eax)
f0103ef5:	c1 ea 10             	shr    $0x10,%edx
f0103ef8:	66 89 90 d6 23 00 00 	mov    %dx,0x23d6(%eax)
    SETGATE(idt[T_SIMDERR], 0, GD_KT, trap_simderr, 0);
f0103eff:	c7 c2 1e 44 10 f0    	mov    $0xf010441e,%edx
f0103f05:	66 89 90 d8 23 00 00 	mov    %dx,0x23d8(%eax)
f0103f0c:	66 c7 80 da 23 00 00 	movw   $0x8,0x23da(%eax)
f0103f13:	08 00 
f0103f15:	c6 80 dc 23 00 00 00 	movb   $0x0,0x23dc(%eax)
f0103f1c:	c6 80 dd 23 00 00 8e 	movb   $0x8e,0x23dd(%eax)
f0103f23:	c1 ea 10             	shr    $0x10,%edx
f0103f26:	66 89 90 de 23 00 00 	mov    %dx,0x23de(%eax)
	SETGATE(idt[T_SYSCALL], 0, GD_KT, trap_syscall, 3); //B部分系统调用，注意这里是level3，用户态可用
f0103f2d:	c7 c2 24 44 10 f0    	mov    $0xf0104424,%edx
f0103f33:	66 89 90 c0 24 00 00 	mov    %dx,0x24c0(%eax)
f0103f3a:	66 c7 80 c2 24 00 00 	movw   $0x8,0x24c2(%eax)
f0103f41:	08 00 
f0103f43:	c6 80 c4 24 00 00 00 	movb   $0x0,0x24c4(%eax)
f0103f4a:	c6 80 c5 24 00 00 ee 	movb   $0xee,0x24c5(%eax)
f0103f51:	c1 ea 10             	shr    $0x10,%edx
f0103f54:	66 89 90 c6 24 00 00 	mov    %dx,0x24c6(%eax)
	trap_init_percpu();
f0103f5b:	e8 e5 fb ff ff       	call   f0103b45 <trap_init_percpu>
}
f0103f60:	5d                   	pop    %ebp
f0103f61:	c3                   	ret    

f0103f62 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103f62:	55                   	push   %ebp
f0103f63:	89 e5                	mov    %esp,%ebp
f0103f65:	56                   	push   %esi
f0103f66:	53                   	push   %ebx
f0103f67:	e8 fb c1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103f6c:	81 c3 b4 60 08 00    	add    $0x860b4,%ebx
f0103f72:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103f75:	83 ec 08             	sub    $0x8,%esp
f0103f78:	ff 36                	pushl  (%esi)
f0103f7a:	8d 83 da c6 f7 ff    	lea    -0x83926(%ebx),%eax
f0103f80:	50                   	push   %eax
f0103f81:	e8 ab fb ff ff       	call   f0103b31 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103f86:	83 c4 08             	add    $0x8,%esp
f0103f89:	ff 76 04             	pushl  0x4(%esi)
f0103f8c:	8d 83 e9 c6 f7 ff    	lea    -0x83917(%ebx),%eax
f0103f92:	50                   	push   %eax
f0103f93:	e8 99 fb ff ff       	call   f0103b31 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f98:	83 c4 08             	add    $0x8,%esp
f0103f9b:	ff 76 08             	pushl  0x8(%esi)
f0103f9e:	8d 83 f8 c6 f7 ff    	lea    -0x83908(%ebx),%eax
f0103fa4:	50                   	push   %eax
f0103fa5:	e8 87 fb ff ff       	call   f0103b31 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103faa:	83 c4 08             	add    $0x8,%esp
f0103fad:	ff 76 0c             	pushl  0xc(%esi)
f0103fb0:	8d 83 07 c7 f7 ff    	lea    -0x838f9(%ebx),%eax
f0103fb6:	50                   	push   %eax
f0103fb7:	e8 75 fb ff ff       	call   f0103b31 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103fbc:	83 c4 08             	add    $0x8,%esp
f0103fbf:	ff 76 10             	pushl  0x10(%esi)
f0103fc2:	8d 83 16 c7 f7 ff    	lea    -0x838ea(%ebx),%eax
f0103fc8:	50                   	push   %eax
f0103fc9:	e8 63 fb ff ff       	call   f0103b31 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103fce:	83 c4 08             	add    $0x8,%esp
f0103fd1:	ff 76 14             	pushl  0x14(%esi)
f0103fd4:	8d 83 25 c7 f7 ff    	lea    -0x838db(%ebx),%eax
f0103fda:	50                   	push   %eax
f0103fdb:	e8 51 fb ff ff       	call   f0103b31 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103fe0:	83 c4 08             	add    $0x8,%esp
f0103fe3:	ff 76 18             	pushl  0x18(%esi)
f0103fe6:	8d 83 34 c7 f7 ff    	lea    -0x838cc(%ebx),%eax
f0103fec:	50                   	push   %eax
f0103fed:	e8 3f fb ff ff       	call   f0103b31 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103ff2:	83 c4 08             	add    $0x8,%esp
f0103ff5:	ff 76 1c             	pushl  0x1c(%esi)
f0103ff8:	8d 83 43 c7 f7 ff    	lea    -0x838bd(%ebx),%eax
f0103ffe:	50                   	push   %eax
f0103fff:	e8 2d fb ff ff       	call   f0103b31 <cprintf>
}
f0104004:	83 c4 10             	add    $0x10,%esp
f0104007:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010400a:	5b                   	pop    %ebx
f010400b:	5e                   	pop    %esi
f010400c:	5d                   	pop    %ebp
f010400d:	c3                   	ret    

f010400e <print_trapframe>:
{
f010400e:	55                   	push   %ebp
f010400f:	89 e5                	mov    %esp,%ebp
f0104011:	57                   	push   %edi
f0104012:	56                   	push   %esi
f0104013:	53                   	push   %ebx
f0104014:	83 ec 14             	sub    $0x14,%esp
f0104017:	e8 4b c1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010401c:	81 c3 04 60 08 00    	add    $0x86004,%ebx
f0104022:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0104025:	56                   	push   %esi
f0104026:	8d 83 92 c8 f7 ff    	lea    -0x8376e(%ebx),%eax
f010402c:	50                   	push   %eax
f010402d:	e8 ff fa ff ff       	call   f0103b31 <cprintf>
	print_regs(&tf->tf_regs);
f0104032:	89 34 24             	mov    %esi,(%esp)
f0104035:	e8 28 ff ff ff       	call   f0103f62 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010403a:	83 c4 08             	add    $0x8,%esp
f010403d:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0104041:	50                   	push   %eax
f0104042:	8d 83 94 c7 f7 ff    	lea    -0x8386c(%ebx),%eax
f0104048:	50                   	push   %eax
f0104049:	e8 e3 fa ff ff       	call   f0103b31 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010404e:	83 c4 08             	add    $0x8,%esp
f0104051:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0104055:	50                   	push   %eax
f0104056:	8d 83 a7 c7 f7 ff    	lea    -0x83859(%ebx),%eax
f010405c:	50                   	push   %eax
f010405d:	e8 cf fa ff ff       	call   f0103b31 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104062:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0104065:	83 c4 10             	add    $0x10,%esp
f0104068:	83 fa 13             	cmp    $0x13,%edx
f010406b:	0f 86 e9 00 00 00    	jbe    f010415a <print_trapframe+0x14c>
	return "(unknown trap)";
f0104071:	83 fa 30             	cmp    $0x30,%edx
f0104074:	8d 83 52 c7 f7 ff    	lea    -0x838ae(%ebx),%eax
f010407a:	8d 8b 5e c7 f7 ff    	lea    -0x838a2(%ebx),%ecx
f0104080:	0f 45 c1             	cmovne %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104083:	83 ec 04             	sub    $0x4,%esp
f0104086:	50                   	push   %eax
f0104087:	52                   	push   %edx
f0104088:	8d 83 ba c7 f7 ff    	lea    -0x83846(%ebx),%eax
f010408e:	50                   	push   %eax
f010408f:	e8 9d fa ff ff       	call   f0103b31 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104094:	83 c4 10             	add    $0x10,%esp
f0104097:	39 b3 40 2b 00 00    	cmp    %esi,0x2b40(%ebx)
f010409d:	0f 84 c3 00 00 00    	je     f0104166 <print_trapframe+0x158>
	cprintf("  err  0x%08x", tf->tf_err);
f01040a3:	83 ec 08             	sub    $0x8,%esp
f01040a6:	ff 76 2c             	pushl  0x2c(%esi)
f01040a9:	8d 83 db c7 f7 ff    	lea    -0x83825(%ebx),%eax
f01040af:	50                   	push   %eax
f01040b0:	e8 7c fa ff ff       	call   f0103b31 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f01040b5:	83 c4 10             	add    $0x10,%esp
f01040b8:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01040bc:	0f 85 c9 00 00 00    	jne    f010418b <print_trapframe+0x17d>
			tf->tf_err & 1 ? "protection" : "not-present");
f01040c2:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f01040c5:	89 c2                	mov    %eax,%edx
f01040c7:	83 e2 01             	and    $0x1,%edx
f01040ca:	8d 8b 6d c7 f7 ff    	lea    -0x83893(%ebx),%ecx
f01040d0:	8d 93 78 c7 f7 ff    	lea    -0x83888(%ebx),%edx
f01040d6:	0f 44 ca             	cmove  %edx,%ecx
f01040d9:	89 c2                	mov    %eax,%edx
f01040db:	83 e2 02             	and    $0x2,%edx
f01040de:	8d 93 84 c7 f7 ff    	lea    -0x8387c(%ebx),%edx
f01040e4:	8d bb 8a c7 f7 ff    	lea    -0x83876(%ebx),%edi
f01040ea:	0f 44 d7             	cmove  %edi,%edx
f01040ed:	83 e0 04             	and    $0x4,%eax
f01040f0:	8d 83 8f c7 f7 ff    	lea    -0x83871(%ebx),%eax
f01040f6:	8d bb bd c8 f7 ff    	lea    -0x83743(%ebx),%edi
f01040fc:	0f 44 c7             	cmove  %edi,%eax
f01040ff:	51                   	push   %ecx
f0104100:	52                   	push   %edx
f0104101:	50                   	push   %eax
f0104102:	8d 83 e9 c7 f7 ff    	lea    -0x83817(%ebx),%eax
f0104108:	50                   	push   %eax
f0104109:	e8 23 fa ff ff       	call   f0103b31 <cprintf>
f010410e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104111:	83 ec 08             	sub    $0x8,%esp
f0104114:	ff 76 30             	pushl  0x30(%esi)
f0104117:	8d 83 f8 c7 f7 ff    	lea    -0x83808(%ebx),%eax
f010411d:	50                   	push   %eax
f010411e:	e8 0e fa ff ff       	call   f0103b31 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104123:	83 c4 08             	add    $0x8,%esp
f0104126:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010412a:	50                   	push   %eax
f010412b:	8d 83 07 c8 f7 ff    	lea    -0x837f9(%ebx),%eax
f0104131:	50                   	push   %eax
f0104132:	e8 fa f9 ff ff       	call   f0103b31 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104137:	83 c4 08             	add    $0x8,%esp
f010413a:	ff 76 38             	pushl  0x38(%esi)
f010413d:	8d 83 1a c8 f7 ff    	lea    -0x837e6(%ebx),%eax
f0104143:	50                   	push   %eax
f0104144:	e8 e8 f9 ff ff       	call   f0103b31 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104149:	83 c4 10             	add    $0x10,%esp
f010414c:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0104150:	75 50                	jne    f01041a2 <print_trapframe+0x194>
}
f0104152:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104155:	5b                   	pop    %ebx
f0104156:	5e                   	pop    %esi
f0104157:	5f                   	pop    %edi
f0104158:	5d                   	pop    %ebp
f0104159:	c3                   	ret    
		return excnames[trapno];
f010415a:	8b 84 93 60 20 00 00 	mov    0x2060(%ebx,%edx,4),%eax
f0104161:	e9 1d ff ff ff       	jmp    f0104083 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104166:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f010416a:	0f 85 33 ff ff ff    	jne    f01040a3 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104170:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104173:	83 ec 08             	sub    $0x8,%esp
f0104176:	50                   	push   %eax
f0104177:	8d 83 cc c7 f7 ff    	lea    -0x83834(%ebx),%eax
f010417d:	50                   	push   %eax
f010417e:	e8 ae f9 ff ff       	call   f0103b31 <cprintf>
f0104183:	83 c4 10             	add    $0x10,%esp
f0104186:	e9 18 ff ff ff       	jmp    f01040a3 <print_trapframe+0x95>
		cprintf("\n");
f010418b:	83 ec 0c             	sub    $0xc,%esp
f010418e:	8d 83 92 c5 f7 ff    	lea    -0x83a6e(%ebx),%eax
f0104194:	50                   	push   %eax
f0104195:	e8 97 f9 ff ff       	call   f0103b31 <cprintf>
f010419a:	83 c4 10             	add    $0x10,%esp
f010419d:	e9 6f ff ff ff       	jmp    f0104111 <print_trapframe+0x103>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01041a2:	83 ec 08             	sub    $0x8,%esp
f01041a5:	ff 76 3c             	pushl  0x3c(%esi)
f01041a8:	8d 83 29 c8 f7 ff    	lea    -0x837d7(%ebx),%eax
f01041ae:	50                   	push   %eax
f01041af:	e8 7d f9 ff ff       	call   f0103b31 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01041b4:	83 c4 08             	add    $0x8,%esp
f01041b7:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f01041bb:	50                   	push   %eax
f01041bc:	8d 83 38 c8 f7 ff    	lea    -0x837c8(%ebx),%eax
f01041c2:	50                   	push   %eax
f01041c3:	e8 69 f9 ff ff       	call   f0103b31 <cprintf>
f01041c8:	83 c4 10             	add    $0x10,%esp
}
f01041cb:	eb 85                	jmp    f0104152 <print_trapframe+0x144>

f01041cd <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01041cd:	55                   	push   %ebp
f01041ce:	89 e5                	mov    %esp,%ebp
f01041d0:	57                   	push   %edi
f01041d1:	56                   	push   %esi
f01041d2:	53                   	push   %ebx
f01041d3:	83 ec 0c             	sub    $0xc,%esp
f01041d6:	e8 8c bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01041db:	81 c3 45 5e 08 00    	add    $0x85e45,%ebx
f01041e1:	8b 75 08             	mov    0x8(%ebp),%esi
f01041e4:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if((tf->tf_cs & 3) == 0){ //如果是核态
f01041e7:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f01041eb:	74 38                	je     f0104225 <page_fault_handler+0x58>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041ed:	ff 76 30             	pushl  0x30(%esi)
f01041f0:	50                   	push   %eax
f01041f1:	c7 c7 48 c3 18 f0    	mov    $0xf018c348,%edi
f01041f7:	8b 07                	mov    (%edi),%eax
f01041f9:	ff 70 48             	pushl  0x48(%eax)
f01041fc:	8d 83 08 ca f7 ff    	lea    -0x835f8(%ebx),%eax
f0104202:	50                   	push   %eax
f0104203:	e8 29 f9 ff ff       	call   f0103b31 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104208:	89 34 24             	mov    %esi,(%esp)
f010420b:	e8 fe fd ff ff       	call   f010400e <print_trapframe>
	env_destroy(curenv);
f0104210:	83 c4 04             	add    $0x4,%esp
f0104213:	ff 37                	pushl  (%edi)
f0104215:	e8 a9 f7 ff ff       	call   f01039c3 <env_destroy>
}
f010421a:	83 c4 10             	add    $0x10,%esp
f010421d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104220:	5b                   	pop    %ebx
f0104221:	5e                   	pop    %esi
f0104222:	5f                   	pop    %edi
f0104223:	5d                   	pop    %ebp
f0104224:	c3                   	ret    
		panic("Kernel-mode page faults!");
f0104225:	83 ec 04             	sub    $0x4,%esp
f0104228:	8d 83 4b c8 f7 ff    	lea    -0x837b5(%ebx),%eax
f010422e:	50                   	push   %eax
f010422f:	68 0d 01 00 00       	push   $0x10d
f0104234:	8d 83 64 c8 f7 ff    	lea    -0x8379c(%ebx),%eax
f010423a:	50                   	push   %eax
f010423b:	e8 71 be ff ff       	call   f01000b1 <_panic>

f0104240 <trap>:
{
f0104240:	55                   	push   %ebp
f0104241:	89 e5                	mov    %esp,%ebp
f0104243:	57                   	push   %edi
f0104244:	56                   	push   %esi
f0104245:	53                   	push   %ebx
f0104246:	83 ec 0c             	sub    $0xc,%esp
f0104249:	e8 19 bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010424e:	81 c3 d2 5d 08 00    	add    $0x85dd2,%ebx
f0104254:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104257:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104258:	9c                   	pushf  
f0104259:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f010425a:	f6 c4 02             	test   $0x2,%ah
f010425d:	74 1f                	je     f010427e <trap+0x3e>
f010425f:	8d 83 70 c8 f7 ff    	lea    -0x83790(%ebx),%eax
f0104265:	50                   	push   %eax
f0104266:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010426c:	50                   	push   %eax
f010426d:	68 e3 00 00 00       	push   $0xe3
f0104272:	8d 83 64 c8 f7 ff    	lea    -0x8379c(%ebx),%eax
f0104278:	50                   	push   %eax
f0104279:	e8 33 be ff ff       	call   f01000b1 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f010427e:	83 ec 08             	sub    $0x8,%esp
f0104281:	56                   	push   %esi
f0104282:	8d 83 89 c8 f7 ff    	lea    -0x83777(%ebx),%eax
f0104288:	50                   	push   %eax
f0104289:	e8 a3 f8 ff ff       	call   f0103b31 <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f010428e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104292:	83 e0 03             	and    $0x3,%eax
f0104295:	83 c4 10             	add    $0x10,%esp
f0104298:	66 83 f8 03          	cmp    $0x3,%ax
f010429c:	75 21                	jne    f01042bf <trap+0x7f>
		assert(curenv);
f010429e:	c7 c0 48 c3 18 f0    	mov    $0xf018c348,%eax
f01042a4:	8b 00                	mov    (%eax),%eax
f01042a6:	85 c0                	test   %eax,%eax
f01042a8:	0f 84 94 00 00 00    	je     f0104342 <trap+0x102>
		curenv->env_tf = *tf;
f01042ae:	b9 11 00 00 00       	mov    $0x11,%ecx
f01042b3:	89 c7                	mov    %eax,%edi
f01042b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01042b7:	c7 c0 48 c3 18 f0    	mov    $0xf018c348,%eax
f01042bd:	8b 30                	mov    (%eax),%esi
	last_tf = tf;
f01042bf:	89 b3 40 2b 00 00    	mov    %esi,0x2b40(%ebx)
	if(tf->tf_trapno == T_PGFLT){ //页面错误时调用page_fault_trap函数处理
f01042c5:	8b 46 28             	mov    0x28(%esi),%eax
f01042c8:	83 f8 0e             	cmp    $0xe,%eax
f01042cb:	0f 84 90 00 00 00    	je     f0104361 <trap+0x121>
	else if(tf->tf_trapno == T_BRKPT){ //断点异常的时候调用内核监视器
f01042d1:	83 f8 03             	cmp    $0x3,%eax
f01042d4:	0f 84 95 00 00 00    	je     f010436f <trap+0x12f>
	else if(tf->tf_trapno == T_SYSCALL){ //将系统调用的返回值赋值给eax
f01042da:	83 f8 30             	cmp    $0x30,%eax
f01042dd:	0f 84 9a 00 00 00    	je     f010437d <trap+0x13d>
	print_trapframe(tf);
f01042e3:	83 ec 0c             	sub    $0xc,%esp
f01042e6:	56                   	push   %esi
f01042e7:	e8 22 fd ff ff       	call   f010400e <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01042ec:	83 c4 10             	add    $0x10,%esp
f01042ef:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01042f4:	0f 84 a7 00 00 00    	je     f01043a1 <trap+0x161>
		env_destroy(curenv);
f01042fa:	83 ec 0c             	sub    $0xc,%esp
f01042fd:	c7 c0 48 c3 18 f0    	mov    $0xf018c348,%eax
f0104303:	ff 30                	pushl  (%eax)
f0104305:	e8 b9 f6 ff ff       	call   f01039c3 <env_destroy>
f010430a:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010430d:	c7 c0 48 c3 18 f0    	mov    $0xf018c348,%eax
f0104313:	8b 00                	mov    (%eax),%eax
f0104315:	85 c0                	test   %eax,%eax
f0104317:	74 0a                	je     f0104323 <trap+0xe3>
f0104319:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010431d:	0f 84 99 00 00 00    	je     f01043bc <trap+0x17c>
f0104323:	8d 83 2c ca f7 ff    	lea    -0x835d4(%ebx),%eax
f0104329:	50                   	push   %eax
f010432a:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f0104330:	50                   	push   %eax
f0104331:	68 fb 00 00 00       	push   $0xfb
f0104336:	8d 83 64 c8 f7 ff    	lea    -0x8379c(%ebx),%eax
f010433c:	50                   	push   %eax
f010433d:	e8 6f bd ff ff       	call   f01000b1 <_panic>
		assert(curenv);
f0104342:	8d 83 a4 c8 f7 ff    	lea    -0x8375c(%ebx),%eax
f0104348:	50                   	push   %eax
f0104349:	8d 83 07 c3 f7 ff    	lea    -0x83cf9(%ebx),%eax
f010434f:	50                   	push   %eax
f0104350:	68 e9 00 00 00       	push   $0xe9
f0104355:	8d 83 64 c8 f7 ff    	lea    -0x8379c(%ebx),%eax
f010435b:	50                   	push   %eax
f010435c:	e8 50 bd ff ff       	call   f01000b1 <_panic>
		page_fault_handler(tf);
f0104361:	83 ec 0c             	sub    $0xc,%esp
f0104364:	56                   	push   %esi
f0104365:	e8 63 fe ff ff       	call   f01041cd <page_fault_handler>
f010436a:	83 c4 10             	add    $0x10,%esp
f010436d:	eb 9e                	jmp    f010430d <trap+0xcd>
		monitor(tf);
f010436f:	83 ec 0c             	sub    $0xc,%esp
f0104372:	56                   	push   %esi
f0104373:	e8 6f c5 ff ff       	call   f01008e7 <monitor>
f0104378:	83 c4 10             	add    $0x10,%esp
f010437b:	eb 90                	jmp    f010430d <trap+0xcd>
		SysRet = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
f010437d:	83 ec 08             	sub    $0x8,%esp
f0104380:	ff 76 04             	pushl  0x4(%esi)
f0104383:	ff 36                	pushl  (%esi)
f0104385:	ff 76 10             	pushl  0x10(%esi)
f0104388:	ff 76 18             	pushl  0x18(%esi)
f010438b:	ff 76 14             	pushl  0x14(%esi)
f010438e:	ff 76 1c             	pushl  0x1c(%esi)
f0104391:	e8 a6 00 00 00       	call   f010443c <syscall>
		tf->tf_regs.reg_eax = SysRet;
f0104396:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104399:	83 c4 20             	add    $0x20,%esp
f010439c:	e9 6c ff ff ff       	jmp    f010430d <trap+0xcd>
		panic("unhandled trap in kernel");
f01043a1:	83 ec 04             	sub    $0x4,%esp
f01043a4:	8d 83 ab c8 f7 ff    	lea    -0x83755(%ebx),%eax
f01043aa:	50                   	push   %eax
f01043ab:	68 d2 00 00 00       	push   $0xd2
f01043b0:	8d 83 64 c8 f7 ff    	lea    -0x8379c(%ebx),%eax
f01043b6:	50                   	push   %eax
f01043b7:	e8 f5 bc ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f01043bc:	83 ec 0c             	sub    $0xc,%esp
f01043bf:	50                   	push   %eax
f01043c0:	e8 6c f6 ff ff       	call   f0103a31 <env_run>
f01043c5:	90                   	nop

f01043c6 <trap_divide>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	# 需要处理的中断详细可见/inc/trap.h
	# 关于是否有错误码，可以看实验指导的pdf
	TRAPHANDLER_NOEC(trap_divide, T_DIVIDE)
f01043c6:	6a 00                	push   $0x0
f01043c8:	6a 00                	push   $0x0
f01043ca:	eb 5e                	jmp    f010442a <_alltraps>

f01043cc <trap_debug>:
	TRAPHANDLER_NOEC(trap_debug, T_DEBUG)
f01043cc:	6a 00                	push   $0x0
f01043ce:	6a 01                	push   $0x1
f01043d0:	eb 58                	jmp    f010442a <_alltraps>

f01043d2 <trap_nmi>:
	TRAPHANDLER_NOEC(trap_nmi, T_NMI)
f01043d2:	6a 00                	push   $0x0
f01043d4:	6a 02                	push   $0x2
f01043d6:	eb 52                	jmp    f010442a <_alltraps>

f01043d8 <trap_brkpt>:
	TRAPHANDLER_NOEC(trap_brkpt, T_BRKPT)
f01043d8:	6a 00                	push   $0x0
f01043da:	6a 03                	push   $0x3
f01043dc:	eb 4c                	jmp    f010442a <_alltraps>

f01043de <trap_oflow>:
	TRAPHANDLER_NOEC(trap_oflow, T_OFLOW)
f01043de:	6a 00                	push   $0x0
f01043e0:	6a 04                	push   $0x4
f01043e2:	eb 46                	jmp    f010442a <_alltraps>

f01043e4 <trap_bound>:
	TRAPHANDLER_NOEC(trap_bound, T_BOUND)
f01043e4:	6a 00                	push   $0x0
f01043e6:	6a 05                	push   $0x5
f01043e8:	eb 40                	jmp    f010442a <_alltraps>

f01043ea <trap_illop>:
	TRAPHANDLER_NOEC(trap_illop, T_ILLOP)
f01043ea:	6a 00                	push   $0x0
f01043ec:	6a 06                	push   $0x6
f01043ee:	eb 3a                	jmp    f010442a <_alltraps>

f01043f0 <trap_device>:
	TRAPHANDLER_NOEC(trap_device, T_DEVICE)
f01043f0:	6a 00                	push   $0x0
f01043f2:	6a 07                	push   $0x7
f01043f4:	eb 34                	jmp    f010442a <_alltraps>

f01043f6 <trap_dblflt>:
	TRAPHANDLER(trap_dblflt, T_DBLFLT)
f01043f6:	6a 08                	push   $0x8
f01043f8:	eb 30                	jmp    f010442a <_alltraps>

f01043fa <trap_tss>:
	# TRAPHANDLER_NOEC(trap_coproc, T_COPROC) /* reserved */
	TRAPHANDLER(trap_tss, T_TSS)
f01043fa:	6a 0a                	push   $0xa
f01043fc:	eb 2c                	jmp    f010442a <_alltraps>

f01043fe <trap_segnp>:
	TRAPHANDLER(trap_segnp, T_SEGNP)
f01043fe:	6a 0b                	push   $0xb
f0104400:	eb 28                	jmp    f010442a <_alltraps>

f0104402 <trap_stack>:
	TRAPHANDLER(trap_stack, T_STACK)
f0104402:	6a 0c                	push   $0xc
f0104404:	eb 24                	jmp    f010442a <_alltraps>

f0104406 <trap_gpflt>:
	TRAPHANDLER(trap_gpflt, T_GPFLT)
f0104406:	6a 0d                	push   $0xd
f0104408:	eb 20                	jmp    f010442a <_alltraps>

f010440a <trap_pgflt>:
	TRAPHANDLER(trap_pgflt, T_PGFLT)
f010440a:	6a 0e                	push   $0xe
f010440c:	eb 1c                	jmp    f010442a <_alltraps>

f010440e <trap_fperr>:
	# TRAPHANDLER_NOEC(trap_res, T_RES)  /* reserved */
	TRAPHANDLER_NOEC(trap_fperr, T_FPERR)
f010440e:	6a 00                	push   $0x0
f0104410:	6a 10                	push   $0x10
f0104412:	eb 16                	jmp    f010442a <_alltraps>

f0104414 <trap_align>:
	TRAPHANDLER(trap_align, T_ALIGN)
f0104414:	6a 11                	push   $0x11
f0104416:	eb 12                	jmp    f010442a <_alltraps>

f0104418 <trap_mchk>:
	TRAPHANDLER_NOEC(trap_mchk, T_MCHK)
f0104418:	6a 00                	push   $0x0
f010441a:	6a 12                	push   $0x12
f010441c:	eb 0c                	jmp    f010442a <_alltraps>

f010441e <trap_simderr>:
	TRAPHANDLER_NOEC(trap_simderr, T_SIMDERR)
f010441e:	6a 00                	push   $0x0
f0104420:	6a 13                	push   $0x13
f0104422:	eb 06                	jmp    f010442a <_alltraps>

f0104424 <trap_syscall>:

	TRAPHANDLER_NOEC(trap_syscall, T_SYSCALL) /*B部分系统调用*/
f0104424:	6a 00                	push   $0x0
f0104426:	6a 30                	push   $0x30
f0104428:	eb 00                	jmp    f010442a <_alltraps>

f010442a <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	# 将错误码和中断号压入堆栈，如果没有错误码则压入一个0保证和TrapFrame的对齐
	# 调用pushal压入当前的寄存器的值进行保存
	pushl %ds
f010442a:	1e                   	push   %ds
	pushl %es
f010442b:	06                   	push   %es
	pushal
f010442c:	60                   	pusha  

	# 将GD_KD读入%ds和%es
	movl $GD_KD, %eax
f010442d:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104432:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104434:	8e c0                	mov    %eax,%es

	# 将指向trapframe的函数的指针作为argument的参数传递
	pushl %esp
f0104436:	54                   	push   %esp
	# 调用trap函数
	call trap 
f0104437:	e8 04 fe ff ff       	call   f0104240 <trap>

f010443c <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010443c:	55                   	push   %ebp
f010443d:	89 e5                	mov    %esp,%ebp
f010443f:	53                   	push   %ebx
f0104440:	83 ec 14             	sub    $0x14,%esp
f0104443:	e8 1f bd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104448:	81 c3 d8 5b 08 00    	add    $0x85bd8,%ebx
f010444e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t SysRet = 0; //定义返回值
	switch(syscallno){
f0104451:	83 f8 01             	cmp    $0x1,%eax
f0104454:	74 4d                	je     f01044a3 <syscall+0x67>
f0104456:	83 f8 01             	cmp    $0x1,%eax
f0104459:	72 11                	jb     f010446c <syscall+0x30>
f010445b:	83 f8 02             	cmp    $0x2,%eax
f010445e:	74 4a                	je     f01044aa <syscall+0x6e>
f0104460:	83 f8 03             	cmp    $0x3,%eax
f0104463:	74 52                	je     f01044b7 <syscall+0x7b>
			break;
		case SYS_env_destroy: //destroy掉一个继承，返回0代表成功，小于0代表失败
			SysRet = sys_env_destroy((envid_t) a1);
			break;
		default:
			return -E_INVAL;
f0104465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010446a:	eb 32                	jmp    f010449e <syscall+0x62>
	user_mem_assert(curenv, s, len, PTE_U);
f010446c:	6a 04                	push   $0x4
f010446e:	ff 75 10             	pushl  0x10(%ebp)
f0104471:	ff 75 0c             	pushl  0xc(%ebp)
f0104474:	c7 c0 48 c3 18 f0    	mov    $0xf018c348,%eax
f010447a:	ff 30                	pushl  (%eax)
f010447c:	e8 18 ee ff ff       	call   f0103299 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104481:	83 c4 0c             	add    $0xc,%esp
f0104484:	ff 75 0c             	pushl  0xc(%ebp)
f0104487:	ff 75 10             	pushl  0x10(%ebp)
f010448a:	8d 83 58 ca f7 ff    	lea    -0x835a8(%ebx),%eax
f0104490:	50                   	push   %eax
f0104491:	e8 9b f6 ff ff       	call   f0103b31 <cprintf>
f0104496:	83 c4 10             	add    $0x10,%esp
	int32_t SysRet = 0; //定义返回值
f0104499:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return SysRet;
}
f010449e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01044a1:	c9                   	leave  
f01044a2:	c3                   	ret    
	return cons_getc();
f01044a3:	e8 ba c0 ff ff       	call   f0100562 <cons_getc>
			break;
f01044a8:	eb f4                	jmp    f010449e <syscall+0x62>
	return curenv->env_id;
f01044aa:	c7 c0 48 c3 18 f0    	mov    $0xf018c348,%eax
f01044b0:	8b 00                	mov    (%eax),%eax
f01044b2:	8b 40 48             	mov    0x48(%eax),%eax
			break;
f01044b5:	eb e7                	jmp    f010449e <syscall+0x62>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01044b7:	83 ec 04             	sub    $0x4,%esp
f01044ba:	6a 01                	push   $0x1
f01044bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01044bf:	50                   	push   %eax
f01044c0:	ff 75 0c             	pushl  0xc(%ebp)
f01044c3:	e8 cf ee ff ff       	call   f0103397 <envid2env>
f01044c8:	83 c4 10             	add    $0x10,%esp
f01044cb:	85 c0                	test   %eax,%eax
f01044cd:	78 cf                	js     f010449e <syscall+0x62>
	if (e == curenv)
f01044cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01044d2:	c7 c0 48 c3 18 f0    	mov    $0xf018c348,%eax
f01044d8:	8b 00                	mov    (%eax),%eax
f01044da:	39 c2                	cmp    %eax,%edx
f01044dc:	74 2d                	je     f010450b <syscall+0xcf>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01044de:	83 ec 04             	sub    $0x4,%esp
f01044e1:	ff 72 48             	pushl  0x48(%edx)
f01044e4:	ff 70 48             	pushl  0x48(%eax)
f01044e7:	8d 83 78 ca f7 ff    	lea    -0x83588(%ebx),%eax
f01044ed:	50                   	push   %eax
f01044ee:	e8 3e f6 ff ff       	call   f0103b31 <cprintf>
f01044f3:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01044f6:	83 ec 0c             	sub    $0xc,%esp
f01044f9:	ff 75 f4             	pushl  -0xc(%ebp)
f01044fc:	e8 c2 f4 ff ff       	call   f01039c3 <env_destroy>
f0104501:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104504:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
f0104509:	eb 93                	jmp    f010449e <syscall+0x62>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010450b:	83 ec 08             	sub    $0x8,%esp
f010450e:	ff 70 48             	pushl  0x48(%eax)
f0104511:	8d 83 5d ca f7 ff    	lea    -0x835a3(%ebx),%eax
f0104517:	50                   	push   %eax
f0104518:	e8 14 f6 ff ff       	call   f0103b31 <cprintf>
f010451d:	83 c4 10             	add    $0x10,%esp
f0104520:	eb d4                	jmp    f01044f6 <syscall+0xba>

f0104522 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104522:	55                   	push   %ebp
f0104523:	89 e5                	mov    %esp,%ebp
f0104525:	57                   	push   %edi
f0104526:	56                   	push   %esi
f0104527:	53                   	push   %ebx
f0104528:	83 ec 14             	sub    $0x14,%esp
f010452b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010452e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104531:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104534:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104537:	8b 32                	mov    (%edx),%esi
f0104539:	8b 01                	mov    (%ecx),%eax
f010453b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010453e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104545:	eb 2f                	jmp    f0104576 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104547:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010454a:	39 c6                	cmp    %eax,%esi
f010454c:	7f 49                	jg     f0104597 <stab_binsearch+0x75>
f010454e:	0f b6 0a             	movzbl (%edx),%ecx
f0104551:	83 ea 0c             	sub    $0xc,%edx
f0104554:	39 f9                	cmp    %edi,%ecx
f0104556:	75 ef                	jne    f0104547 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104558:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010455b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010455e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104562:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104565:	73 35                	jae    f010459c <stab_binsearch+0x7a>
			*region_left = m;
f0104567:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010456a:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f010456c:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f010456f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104576:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104579:	7f 4e                	jg     f01045c9 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f010457b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010457e:	01 f0                	add    %esi,%eax
f0104580:	89 c3                	mov    %eax,%ebx
f0104582:	c1 eb 1f             	shr    $0x1f,%ebx
f0104585:	01 c3                	add    %eax,%ebx
f0104587:	d1 fb                	sar    %ebx
f0104589:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010458c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010458f:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104593:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104595:	eb b3                	jmp    f010454a <stab_binsearch+0x28>
			l = true_m + 1;
f0104597:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010459a:	eb da                	jmp    f0104576 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f010459c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010459f:	76 14                	jbe    f01045b5 <stab_binsearch+0x93>
			*region_right = m - 1;
f01045a1:	83 e8 01             	sub    $0x1,%eax
f01045a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01045a7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01045aa:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01045ac:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01045b3:	eb c1                	jmp    f0104576 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01045b5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01045b8:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01045ba:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01045be:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01045c0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01045c7:	eb ad                	jmp    f0104576 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01045c9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01045cd:	74 16                	je     f01045e5 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01045cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045d2:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01045d4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01045d7:	8b 0e                	mov    (%esi),%ecx
f01045d9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01045dc:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01045df:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01045e3:	eb 12                	jmp    f01045f7 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f01045e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045e8:	8b 00                	mov    (%eax),%eax
f01045ea:	83 e8 01             	sub    $0x1,%eax
f01045ed:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01045f0:	89 07                	mov    %eax,(%edi)
f01045f2:	eb 16                	jmp    f010460a <stab_binsearch+0xe8>
		     l--)
f01045f4:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01045f7:	39 c1                	cmp    %eax,%ecx
f01045f9:	7d 0a                	jge    f0104605 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f01045fb:	0f b6 1a             	movzbl (%edx),%ebx
f01045fe:	83 ea 0c             	sub    $0xc,%edx
f0104601:	39 fb                	cmp    %edi,%ebx
f0104603:	75 ef                	jne    f01045f4 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0104605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104608:	89 07                	mov    %eax,(%edi)
	}
}
f010460a:	83 c4 14             	add    $0x14,%esp
f010460d:	5b                   	pop    %ebx
f010460e:	5e                   	pop    %esi
f010460f:	5f                   	pop    %edi
f0104610:	5d                   	pop    %ebp
f0104611:	c3                   	ret    

f0104612 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104612:	55                   	push   %ebp
f0104613:	89 e5                	mov    %esp,%ebp
f0104615:	57                   	push   %edi
f0104616:	56                   	push   %esi
f0104617:	53                   	push   %ebx
f0104618:	83 ec 4c             	sub    $0x4c,%esp
f010461b:	e8 47 bb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104620:	81 c3 00 5a 08 00    	add    $0x85a00,%ebx
f0104626:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104629:	8d 83 90 ca f7 ff    	lea    -0x83570(%ebx),%eax
f010462f:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0104631:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0104638:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f010463b:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0104642:	8b 45 08             	mov    0x8(%ebp),%eax
f0104645:	89 47 10             	mov    %eax,0x10(%edi)
	info->eip_fn_narg = 0;
f0104648:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010464f:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0104654:	0f 86 34 01 00 00    	jbe    f010478e <debuginfo_eip+0x17c>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010465a:	c7 c0 74 23 11 f0    	mov    $0xf0112374,%eax
f0104660:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104663:	c7 c0 8d f8 10 f0    	mov    $0xf010f88d,%eax
f0104669:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stab_end = __STAB_END__;
f010466c:	c7 c6 8c f8 10 f0    	mov    $0xf010f88c,%esi
		stabs = __STAB_BEGIN__;
f0104672:	c7 c0 ac 6c 10 f0    	mov    $0xf0106cac,%eax
f0104678:	89 45 bc             	mov    %eax,-0x44(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010467b:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010467e:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0104681:	0f 83 75 02 00 00    	jae    f01048fc <debuginfo_eip+0x2ea>
f0104687:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010468b:	0f 85 72 02 00 00    	jne    f0104903 <debuginfo_eip+0x2f1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104691:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104698:	2b 75 bc             	sub    -0x44(%ebp),%esi
f010469b:	c1 fe 02             	sar    $0x2,%esi
f010469e:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01046a4:	83 e8 01             	sub    $0x1,%eax
f01046a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01046aa:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01046ad:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01046b0:	83 ec 08             	sub    $0x8,%esp
f01046b3:	ff 75 08             	pushl  0x8(%ebp)
f01046b6:	6a 64                	push   $0x64
f01046b8:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01046bb:	89 f0                	mov    %esi,%eax
f01046bd:	e8 60 fe ff ff       	call   f0104522 <stab_binsearch>
	if (lfile == 0)
f01046c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046c5:	83 c4 10             	add    $0x10,%esp
f01046c8:	85 c0                	test   %eax,%eax
f01046ca:	0f 84 3a 02 00 00    	je     f010490a <debuginfo_eip+0x2f8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01046d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01046d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01046d9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01046dc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01046df:	83 ec 08             	sub    $0x8,%esp
f01046e2:	ff 75 08             	pushl  0x8(%ebp)
f01046e5:	6a 24                	push   $0x24
f01046e7:	89 f0                	mov    %esi,%eax
f01046e9:	e8 34 fe ff ff       	call   f0104522 <stab_binsearch>

	if (lfun <= rfun) {
f01046ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01046f4:	83 c4 10             	add    $0x10,%esp
f01046f7:	39 d0                	cmp    %edx,%eax
f01046f9:	0f 8f 2f 01 00 00    	jg     f010482e <debuginfo_eip+0x21c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01046ff:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104702:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104705:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104708:	8b 36                	mov    (%esi),%esi
f010470a:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010470d:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f0104710:	39 ce                	cmp    %ecx,%esi
f0104712:	73 06                	jae    f010471a <debuginfo_eip+0x108>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104714:	03 75 b4             	add    -0x4c(%ebp),%esi
f0104717:	89 77 08             	mov    %esi,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010471a:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010471d:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104720:	89 4f 10             	mov    %ecx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0104723:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0104726:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104729:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010472c:	83 ec 08             	sub    $0x8,%esp
f010472f:	6a 3a                	push   $0x3a
f0104731:	ff 77 08             	pushl  0x8(%edi)
f0104734:	e8 55 0a 00 00       	call   f010518e <strfind>
f0104739:	2b 47 08             	sub    0x8(%edi),%eax
f010473c:	89 47 0c             	mov    %eax,0xc(%edi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	// 二分查找stab表确定行号
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010473f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104742:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104745:	83 c4 08             	add    $0x8,%esp
f0104748:	ff 75 08             	pushl  0x8(%ebp)
f010474b:	6a 44                	push   $0x44
f010474d:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0104750:	89 d8                	mov    %ebx,%eax
f0104752:	e8 cb fd ff ff       	call   f0104522 <stab_binsearch>
    if (lline <= rline) {
f0104757:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010475a:	83 c4 10             	add    $0x10,%esp
f010475d:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0104760:	0f 8f ab 01 00 00    	jg     f0104911 <debuginfo_eip+0x2ff>
		//对应的行号储存在n_desc中
        info->eip_line = stabs[lline].n_desc;
f0104766:	89 d0                	mov    %edx,%eax
f0104768:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010476b:	c1 e2 02             	shl    $0x2,%edx
f010476e:	0f b7 4c 13 06       	movzwl 0x6(%ebx,%edx,1),%ecx
f0104773:	89 4f 04             	mov    %ecx,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104776:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104779:	8d 54 13 04          	lea    0x4(%ebx,%edx,1),%edx
f010477d:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104781:	bb 01 00 00 00       	mov    $0x1,%ebx
f0104786:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0104789:	e9 c0 00 00 00       	jmp    f010484e <debuginfo_eip+0x23c>
		if(user_mem_check(curenv, usd, size, PTE_U) < 0){ //检验这部分用户数据内存是否合法
f010478e:	6a 04                	push   $0x4
f0104790:	6a 10                	push   $0x10
f0104792:	68 00 00 20 00       	push   $0x200000
f0104797:	c7 c0 48 c3 18 f0    	mov    $0xf018c348,%eax
f010479d:	ff 30                	pushl  (%eax)
f010479f:	e8 55 ea ff ff       	call   f01031f9 <user_mem_check>
f01047a4:	83 c4 10             	add    $0x10,%esp
f01047a7:	85 c0                	test   %eax,%eax
f01047a9:	0f 88 3f 01 00 00    	js     f01048ee <debuginfo_eip+0x2dc>
		stabs = usd->stabs;
f01047af:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f01047b5:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f01047b8:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f01047be:	a1 08 00 20 00       	mov    0x200008,%eax
f01047c3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f01047c6:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01047cc:	89 55 b8             	mov    %edx,-0x48(%ebp)
		if(user_mem_check(curenv, stabs, size, PTE_U) < 0){
f01047cf:	6a 04                	push   $0x4
		size = stab_end - stabs + 1;
f01047d1:	89 f0                	mov    %esi,%eax
f01047d3:	29 c8                	sub    %ecx,%eax
f01047d5:	c1 f8 02             	sar    $0x2,%eax
f01047d8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01047de:	83 c0 01             	add    $0x1,%eax
		if(user_mem_check(curenv, stabs, size, PTE_U) < 0){
f01047e1:	50                   	push   %eax
f01047e2:	51                   	push   %ecx
f01047e3:	c7 c0 48 c3 18 f0    	mov    $0xf018c348,%eax
f01047e9:	ff 30                	pushl  (%eax)
f01047eb:	e8 09 ea ff ff       	call   f01031f9 <user_mem_check>
f01047f0:	83 c4 10             	add    $0x10,%esp
f01047f3:	85 c0                	test   %eax,%eax
f01047f5:	0f 88 fa 00 00 00    	js     f01048f5 <debuginfo_eip+0x2e3>
		if(user_mem_check(curenv, stabstr, size, PTE_U) < 0){
f01047fb:	6a 04                	push   $0x4
		size = stabstr_end - stabstr + 1;
f01047fd:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104800:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0104803:	29 ca                	sub    %ecx,%edx
f0104805:	89 d0                	mov    %edx,%eax
f0104807:	83 c0 01             	add    $0x1,%eax
		if(user_mem_check(curenv, stabstr, size, PTE_U) < 0){
f010480a:	50                   	push   %eax
f010480b:	51                   	push   %ecx
f010480c:	c7 c0 48 c3 18 f0    	mov    $0xf018c348,%eax
f0104812:	ff 30                	pushl  (%eax)
f0104814:	e8 e0 e9 ff ff       	call   f01031f9 <user_mem_check>
f0104819:	83 c4 10             	add    $0x10,%esp
f010481c:	85 c0                	test   %eax,%eax
f010481e:	0f 89 57 fe ff ff    	jns    f010467b <debuginfo_eip+0x69>
			return -1;
f0104824:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104829:	e9 ef 00 00 00       	jmp    f010491d <debuginfo_eip+0x30b>
		info->eip_fn_addr = addr;
f010482e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104831:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfile;
f0104834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104837:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010483a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010483d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104840:	e9 e7 fe ff ff       	jmp    f010472c <debuginfo_eip+0x11a>
f0104845:	83 e8 01             	sub    $0x1,%eax
f0104848:	83 ea 0c             	sub    $0xc,%edx
f010484b:	88 5d c4             	mov    %bl,-0x3c(%ebp)
f010484e:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104851:	39 c6                	cmp    %eax,%esi
f0104853:	7f 24                	jg     f0104879 <debuginfo_eip+0x267>
	       && stabs[lline].n_type != N_SOL
f0104855:	0f b6 0a             	movzbl (%edx),%ecx
f0104858:	80 f9 84             	cmp    $0x84,%cl
f010485b:	74 46                	je     f01048a3 <debuginfo_eip+0x291>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010485d:	80 f9 64             	cmp    $0x64,%cl
f0104860:	75 e3                	jne    f0104845 <debuginfo_eip+0x233>
f0104862:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104866:	74 dd                	je     f0104845 <debuginfo_eip+0x233>
f0104868:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010486b:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010486f:	74 3b                	je     f01048ac <debuginfo_eip+0x29a>
f0104871:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104874:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104877:	eb 33                	jmp    f01048ac <debuginfo_eip+0x29a>
f0104879:	8b 7d 0c             	mov    0xc(%ebp),%edi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010487c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010487f:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104882:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104887:	39 da                	cmp    %ebx,%edx
f0104889:	0f 8d 8e 00 00 00    	jge    f010491d <debuginfo_eip+0x30b>
		for (lline = lfun + 1;
f010488f:	83 c2 01             	add    $0x1,%edx
f0104892:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104895:	89 d0                	mov    %edx,%eax
f0104897:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010489a:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010489d:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f01048a1:	eb 32                	jmp    f01048d5 <debuginfo_eip+0x2c3>
f01048a3:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01048a6:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01048aa:	75 1d                	jne    f01048c9 <debuginfo_eip+0x2b7>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01048ac:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01048af:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01048b2:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01048b5:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01048b8:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f01048bb:	29 f0                	sub    %esi,%eax
f01048bd:	39 c2                	cmp    %eax,%edx
f01048bf:	73 bb                	jae    f010487c <debuginfo_eip+0x26a>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01048c1:	89 f0                	mov    %esi,%eax
f01048c3:	01 d0                	add    %edx,%eax
f01048c5:	89 07                	mov    %eax,(%edi)
f01048c7:	eb b3                	jmp    f010487c <debuginfo_eip+0x26a>
f01048c9:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01048cc:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01048cf:	eb db                	jmp    f01048ac <debuginfo_eip+0x29a>
			info->eip_fn_narg++;
f01048d1:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f01048d5:	39 c3                	cmp    %eax,%ebx
f01048d7:	7e 3f                	jle    f0104918 <debuginfo_eip+0x306>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01048d9:	0f b6 0a             	movzbl (%edx),%ecx
f01048dc:	83 c0 01             	add    $0x1,%eax
f01048df:	83 c2 0c             	add    $0xc,%edx
f01048e2:	80 f9 a0             	cmp    $0xa0,%cl
f01048e5:	74 ea                	je     f01048d1 <debuginfo_eip+0x2bf>
	return 0;
f01048e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01048ec:	eb 2f                	jmp    f010491d <debuginfo_eip+0x30b>
            return -1;
f01048ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048f3:	eb 28                	jmp    f010491d <debuginfo_eip+0x30b>
			return -1;
f01048f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048fa:	eb 21                	jmp    f010491d <debuginfo_eip+0x30b>
		return -1;
f01048fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104901:	eb 1a                	jmp    f010491d <debuginfo_eip+0x30b>
f0104903:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104908:	eb 13                	jmp    f010491d <debuginfo_eip+0x30b>
		return -1;
f010490a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010490f:	eb 0c                	jmp    f010491d <debuginfo_eip+0x30b>
        return -1;
f0104911:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104916:	eb 05                	jmp    f010491d <debuginfo_eip+0x30b>
	return 0;
f0104918:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010491d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104920:	5b                   	pop    %ebx
f0104921:	5e                   	pop    %esi
f0104922:	5f                   	pop    %edi
f0104923:	5d                   	pop    %ebp
f0104924:	c3                   	ret    

f0104925 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104925:	55                   	push   %ebp
f0104926:	89 e5                	mov    %esp,%ebp
f0104928:	57                   	push   %edi
f0104929:	56                   	push   %esi
f010492a:	53                   	push   %ebx
f010492b:	83 ec 2c             	sub    $0x2c,%esp
f010492e:	e8 c3 e9 ff ff       	call   f01032f6 <__x86.get_pc_thunk.cx>
f0104933:	81 c1 ed 56 08 00    	add    $0x856ed,%ecx
f0104939:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010493c:	89 c7                	mov    %eax,%edi
f010493e:	89 d6                	mov    %edx,%esi
f0104940:	8b 45 08             	mov    0x8(%ebp),%eax
f0104943:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104946:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104949:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010494c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010494f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104954:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0104957:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f010495a:	39 d3                	cmp    %edx,%ebx
f010495c:	72 09                	jb     f0104967 <printnum+0x42>
f010495e:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104961:	0f 87 83 00 00 00    	ja     f01049ea <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104967:	83 ec 0c             	sub    $0xc,%esp
f010496a:	ff 75 18             	pushl  0x18(%ebp)
f010496d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104970:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104973:	53                   	push   %ebx
f0104974:	ff 75 10             	pushl  0x10(%ebp)
f0104977:	83 ec 08             	sub    $0x8,%esp
f010497a:	ff 75 dc             	pushl  -0x24(%ebp)
f010497d:	ff 75 d8             	pushl  -0x28(%ebp)
f0104980:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104983:	ff 75 d0             	pushl  -0x30(%ebp)
f0104986:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104989:	e8 22 0a 00 00       	call   f01053b0 <__udivdi3>
f010498e:	83 c4 18             	add    $0x18,%esp
f0104991:	52                   	push   %edx
f0104992:	50                   	push   %eax
f0104993:	89 f2                	mov    %esi,%edx
f0104995:	89 f8                	mov    %edi,%eax
f0104997:	e8 89 ff ff ff       	call   f0104925 <printnum>
f010499c:	83 c4 20             	add    $0x20,%esp
f010499f:	eb 13                	jmp    f01049b4 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01049a1:	83 ec 08             	sub    $0x8,%esp
f01049a4:	56                   	push   %esi
f01049a5:	ff 75 18             	pushl  0x18(%ebp)
f01049a8:	ff d7                	call   *%edi
f01049aa:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01049ad:	83 eb 01             	sub    $0x1,%ebx
f01049b0:	85 db                	test   %ebx,%ebx
f01049b2:	7f ed                	jg     f01049a1 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01049b4:	83 ec 08             	sub    $0x8,%esp
f01049b7:	56                   	push   %esi
f01049b8:	83 ec 04             	sub    $0x4,%esp
f01049bb:	ff 75 dc             	pushl  -0x24(%ebp)
f01049be:	ff 75 d8             	pushl  -0x28(%ebp)
f01049c1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01049c4:	ff 75 d0             	pushl  -0x30(%ebp)
f01049c7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01049ca:	89 f3                	mov    %esi,%ebx
f01049cc:	e8 ff 0a 00 00       	call   f01054d0 <__umoddi3>
f01049d1:	83 c4 14             	add    $0x14,%esp
f01049d4:	0f be 84 06 9a ca f7 	movsbl -0x83566(%esi,%eax,1),%eax
f01049db:	ff 
f01049dc:	50                   	push   %eax
f01049dd:	ff d7                	call   *%edi
}
f01049df:	83 c4 10             	add    $0x10,%esp
f01049e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049e5:	5b                   	pop    %ebx
f01049e6:	5e                   	pop    %esi
f01049e7:	5f                   	pop    %edi
f01049e8:	5d                   	pop    %ebp
f01049e9:	c3                   	ret    
f01049ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01049ed:	eb be                	jmp    f01049ad <printnum+0x88>

f01049ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01049ef:	55                   	push   %ebp
f01049f0:	89 e5                	mov    %esp,%ebp
f01049f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01049f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01049f9:	8b 10                	mov    (%eax),%edx
f01049fb:	3b 50 04             	cmp    0x4(%eax),%edx
f01049fe:	73 0a                	jae    f0104a0a <sprintputch+0x1b>
		*b->buf++ = ch;
f0104a00:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104a03:	89 08                	mov    %ecx,(%eax)
f0104a05:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a08:	88 02                	mov    %al,(%edx)
}
f0104a0a:	5d                   	pop    %ebp
f0104a0b:	c3                   	ret    

f0104a0c <printfmt>:
{
f0104a0c:	55                   	push   %ebp
f0104a0d:	89 e5                	mov    %esp,%ebp
f0104a0f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104a12:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104a15:	50                   	push   %eax
f0104a16:	ff 75 10             	pushl  0x10(%ebp)
f0104a19:	ff 75 0c             	pushl  0xc(%ebp)
f0104a1c:	ff 75 08             	pushl  0x8(%ebp)
f0104a1f:	e8 05 00 00 00       	call   f0104a29 <vprintfmt>
}
f0104a24:	83 c4 10             	add    $0x10,%esp
f0104a27:	c9                   	leave  
f0104a28:	c3                   	ret    

f0104a29 <vprintfmt>:
{
f0104a29:	55                   	push   %ebp
f0104a2a:	89 e5                	mov    %esp,%ebp
f0104a2c:	57                   	push   %edi
f0104a2d:	56                   	push   %esi
f0104a2e:	53                   	push   %ebx
f0104a2f:	83 ec 2c             	sub    $0x2c,%esp
f0104a32:	e8 30 b7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104a37:	81 c3 e9 55 08 00    	add    $0x855e9,%ebx
f0104a3d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104a40:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a43:	e9 c3 03 00 00       	jmp    f0104e0b <.L35+0x48>
		padc = ' ';
f0104a48:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0104a4c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0104a53:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0104a5a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104a61:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104a66:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104a69:	8d 47 01             	lea    0x1(%edi),%eax
f0104a6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104a6f:	0f b6 17             	movzbl (%edi),%edx
f0104a72:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104a75:	3c 55                	cmp    $0x55,%al
f0104a77:	0f 87 16 04 00 00    	ja     f0104e93 <.L22>
f0104a7d:	0f b6 c0             	movzbl %al,%eax
f0104a80:	89 d9                	mov    %ebx,%ecx
f0104a82:	03 8c 83 24 cb f7 ff 	add    -0x834dc(%ebx,%eax,4),%ecx
f0104a89:	ff e1                	jmp    *%ecx

f0104a8b <.L69>:
f0104a8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104a8e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104a92:	eb d5                	jmp    f0104a69 <vprintfmt+0x40>

f0104a94 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0104a94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104a97:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104a9b:	eb cc                	jmp    f0104a69 <vprintfmt+0x40>

f0104a9d <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0104a9d:	0f b6 d2             	movzbl %dl,%edx
f0104aa0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104aa3:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0104aa8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104aab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104aaf:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104ab2:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104ab5:	83 f9 09             	cmp    $0x9,%ecx
f0104ab8:	77 55                	ja     f0104b0f <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0104aba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104abd:	eb e9                	jmp    f0104aa8 <.L29+0xb>

f0104abf <.L26>:
			precision = va_arg(ap, int);
f0104abf:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ac2:	8b 00                	mov    (%eax),%eax
f0104ac4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104ac7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104aca:	8d 40 04             	lea    0x4(%eax),%eax
f0104acd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104ad0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104ad3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ad7:	79 90                	jns    f0104a69 <vprintfmt+0x40>
				width = precision, precision = -1;
f0104ad9:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104adc:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104adf:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0104ae6:	eb 81                	jmp    f0104a69 <vprintfmt+0x40>

f0104ae8 <.L27>:
f0104ae8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104aeb:	85 c0                	test   %eax,%eax
f0104aed:	ba 00 00 00 00       	mov    $0x0,%edx
f0104af2:	0f 49 d0             	cmovns %eax,%edx
f0104af5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104af8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104afb:	e9 69 ff ff ff       	jmp    f0104a69 <vprintfmt+0x40>

f0104b00 <.L23>:
f0104b00:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104b03:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104b0a:	e9 5a ff ff ff       	jmp    f0104a69 <vprintfmt+0x40>
f0104b0f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104b12:	eb bf                	jmp    f0104ad3 <.L26+0x14>

f0104b14 <.L33>:
			lflag++;
f0104b14:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104b18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104b1b:	e9 49 ff ff ff       	jmp    f0104a69 <vprintfmt+0x40>

f0104b20 <.L30>:
			putch(va_arg(ap, int), putdat);
f0104b20:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b23:	8d 78 04             	lea    0x4(%eax),%edi
f0104b26:	83 ec 08             	sub    $0x8,%esp
f0104b29:	56                   	push   %esi
f0104b2a:	ff 30                	pushl  (%eax)
f0104b2c:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104b2f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104b32:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104b35:	e9 ce 02 00 00       	jmp    f0104e08 <.L35+0x45>

f0104b3a <.L32>:
			err = va_arg(ap, int);
f0104b3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b3d:	8d 78 04             	lea    0x4(%eax),%edi
f0104b40:	8b 00                	mov    (%eax),%eax
f0104b42:	99                   	cltd   
f0104b43:	31 d0                	xor    %edx,%eax
f0104b45:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104b47:	83 f8 06             	cmp    $0x6,%eax
f0104b4a:	7f 27                	jg     f0104b73 <.L32+0x39>
f0104b4c:	8b 94 83 b0 20 00 00 	mov    0x20b0(%ebx,%eax,4),%edx
f0104b53:	85 d2                	test   %edx,%edx
f0104b55:	74 1c                	je     f0104b73 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0104b57:	52                   	push   %edx
f0104b58:	8d 83 19 c3 f7 ff    	lea    -0x83ce7(%ebx),%eax
f0104b5e:	50                   	push   %eax
f0104b5f:	56                   	push   %esi
f0104b60:	ff 75 08             	pushl  0x8(%ebp)
f0104b63:	e8 a4 fe ff ff       	call   f0104a0c <printfmt>
f0104b68:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104b6b:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104b6e:	e9 95 02 00 00       	jmp    f0104e08 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f0104b73:	50                   	push   %eax
f0104b74:	8d 83 b2 ca f7 ff    	lea    -0x8354e(%ebx),%eax
f0104b7a:	50                   	push   %eax
f0104b7b:	56                   	push   %esi
f0104b7c:	ff 75 08             	pushl  0x8(%ebp)
f0104b7f:	e8 88 fe ff ff       	call   f0104a0c <printfmt>
f0104b84:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104b87:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104b8a:	e9 79 02 00 00       	jmp    f0104e08 <.L35+0x45>

f0104b8f <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0104b8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b92:	83 c0 04             	add    $0x4,%eax
f0104b95:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104b98:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b9b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104b9d:	85 ff                	test   %edi,%edi
f0104b9f:	8d 83 ab ca f7 ff    	lea    -0x83555(%ebx),%eax
f0104ba5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104ba8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104bac:	0f 8e b5 00 00 00    	jle    f0104c67 <.L36+0xd8>
f0104bb2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104bb6:	75 08                	jne    f0104bc0 <.L36+0x31>
f0104bb8:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104bbb:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104bbe:	eb 6d                	jmp    f0104c2d <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bc0:	83 ec 08             	sub    $0x8,%esp
f0104bc3:	ff 75 cc             	pushl  -0x34(%ebp)
f0104bc6:	57                   	push   %edi
f0104bc7:	e8 7e 04 00 00       	call   f010504a <strnlen>
f0104bcc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104bcf:	29 c2                	sub    %eax,%edx
f0104bd1:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0104bd4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104bd7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104bdb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104bde:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104be1:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104be3:	eb 10                	jmp    f0104bf5 <.L36+0x66>
					putch(padc, putdat);
f0104be5:	83 ec 08             	sub    $0x8,%esp
f0104be8:	56                   	push   %esi
f0104be9:	ff 75 e0             	pushl  -0x20(%ebp)
f0104bec:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bef:	83 ef 01             	sub    $0x1,%edi
f0104bf2:	83 c4 10             	add    $0x10,%esp
f0104bf5:	85 ff                	test   %edi,%edi
f0104bf7:	7f ec                	jg     f0104be5 <.L36+0x56>
f0104bf9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104bfc:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104bff:	85 d2                	test   %edx,%edx
f0104c01:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c06:	0f 49 c2             	cmovns %edx,%eax
f0104c09:	29 c2                	sub    %eax,%edx
f0104c0b:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104c0e:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104c11:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104c14:	eb 17                	jmp    f0104c2d <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f0104c16:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104c1a:	75 30                	jne    f0104c4c <.L36+0xbd>
					putch(ch, putdat);
f0104c1c:	83 ec 08             	sub    $0x8,%esp
f0104c1f:	ff 75 0c             	pushl  0xc(%ebp)
f0104c22:	50                   	push   %eax
f0104c23:	ff 55 08             	call   *0x8(%ebp)
f0104c26:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c29:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0104c2d:	83 c7 01             	add    $0x1,%edi
f0104c30:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0104c34:	0f be c2             	movsbl %dl,%eax
f0104c37:	85 c0                	test   %eax,%eax
f0104c39:	74 52                	je     f0104c8d <.L36+0xfe>
f0104c3b:	85 f6                	test   %esi,%esi
f0104c3d:	78 d7                	js     f0104c16 <.L36+0x87>
f0104c3f:	83 ee 01             	sub    $0x1,%esi
f0104c42:	79 d2                	jns    f0104c16 <.L36+0x87>
f0104c44:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c47:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104c4a:	eb 32                	jmp    f0104c7e <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0104c4c:	0f be d2             	movsbl %dl,%edx
f0104c4f:	83 ea 20             	sub    $0x20,%edx
f0104c52:	83 fa 5e             	cmp    $0x5e,%edx
f0104c55:	76 c5                	jbe    f0104c1c <.L36+0x8d>
					putch('?', putdat);
f0104c57:	83 ec 08             	sub    $0x8,%esp
f0104c5a:	ff 75 0c             	pushl  0xc(%ebp)
f0104c5d:	6a 3f                	push   $0x3f
f0104c5f:	ff 55 08             	call   *0x8(%ebp)
f0104c62:	83 c4 10             	add    $0x10,%esp
f0104c65:	eb c2                	jmp    f0104c29 <.L36+0x9a>
f0104c67:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104c6a:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104c6d:	eb be                	jmp    f0104c2d <.L36+0x9e>
				putch(' ', putdat);
f0104c6f:	83 ec 08             	sub    $0x8,%esp
f0104c72:	56                   	push   %esi
f0104c73:	6a 20                	push   $0x20
f0104c75:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0104c78:	83 ef 01             	sub    $0x1,%edi
f0104c7b:	83 c4 10             	add    $0x10,%esp
f0104c7e:	85 ff                	test   %edi,%edi
f0104c80:	7f ed                	jg     f0104c6f <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0104c82:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104c85:	89 45 14             	mov    %eax,0x14(%ebp)
f0104c88:	e9 7b 01 00 00       	jmp    f0104e08 <.L35+0x45>
f0104c8d:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104c90:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c93:	eb e9                	jmp    f0104c7e <.L36+0xef>

f0104c95 <.L31>:
f0104c95:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104c98:	83 f9 01             	cmp    $0x1,%ecx
f0104c9b:	7e 40                	jle    f0104cdd <.L31+0x48>
		return va_arg(*ap, long long);
f0104c9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ca0:	8b 50 04             	mov    0x4(%eax),%edx
f0104ca3:	8b 00                	mov    (%eax),%eax
f0104ca5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ca8:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104cab:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cae:	8d 40 08             	lea    0x8(%eax),%eax
f0104cb1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104cb4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104cb8:	79 55                	jns    f0104d0f <.L31+0x7a>
				putch('-', putdat);
f0104cba:	83 ec 08             	sub    $0x8,%esp
f0104cbd:	56                   	push   %esi
f0104cbe:	6a 2d                	push   $0x2d
f0104cc0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104cc3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104cc6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104cc9:	f7 da                	neg    %edx
f0104ccb:	83 d1 00             	adc    $0x0,%ecx
f0104cce:	f7 d9                	neg    %ecx
f0104cd0:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104cd3:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104cd8:	e9 10 01 00 00       	jmp    f0104ded <.L35+0x2a>
	else if (lflag)
f0104cdd:	85 c9                	test   %ecx,%ecx
f0104cdf:	75 17                	jne    f0104cf8 <.L31+0x63>
		return va_arg(*ap, int);
f0104ce1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ce4:	8b 00                	mov    (%eax),%eax
f0104ce6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ce9:	99                   	cltd   
f0104cea:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104ced:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cf0:	8d 40 04             	lea    0x4(%eax),%eax
f0104cf3:	89 45 14             	mov    %eax,0x14(%ebp)
f0104cf6:	eb bc                	jmp    f0104cb4 <.L31+0x1f>
		return va_arg(*ap, long);
f0104cf8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cfb:	8b 00                	mov    (%eax),%eax
f0104cfd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d00:	99                   	cltd   
f0104d01:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104d04:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d07:	8d 40 04             	lea    0x4(%eax),%eax
f0104d0a:	89 45 14             	mov    %eax,0x14(%ebp)
f0104d0d:	eb a5                	jmp    f0104cb4 <.L31+0x1f>
			num = getint(&ap, lflag);
f0104d0f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104d12:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0104d15:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d1a:	e9 ce 00 00 00       	jmp    f0104ded <.L35+0x2a>

f0104d1f <.L37>:
f0104d1f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104d22:	83 f9 01             	cmp    $0x1,%ecx
f0104d25:	7e 18                	jle    f0104d3f <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f0104d27:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d2a:	8b 10                	mov    (%eax),%edx
f0104d2c:	8b 48 04             	mov    0x4(%eax),%ecx
f0104d2f:	8d 40 08             	lea    0x8(%eax),%eax
f0104d32:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104d35:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d3a:	e9 ae 00 00 00       	jmp    f0104ded <.L35+0x2a>
	else if (lflag)
f0104d3f:	85 c9                	test   %ecx,%ecx
f0104d41:	75 1a                	jne    f0104d5d <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f0104d43:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d46:	8b 10                	mov    (%eax),%edx
f0104d48:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d4d:	8d 40 04             	lea    0x4(%eax),%eax
f0104d50:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104d53:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d58:	e9 90 00 00 00       	jmp    f0104ded <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104d5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d60:	8b 10                	mov    (%eax),%edx
f0104d62:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d67:	8d 40 04             	lea    0x4(%eax),%eax
f0104d6a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104d6d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d72:	eb 79                	jmp    f0104ded <.L35+0x2a>

f0104d74 <.L34>:
f0104d74:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104d77:	83 f9 01             	cmp    $0x1,%ecx
f0104d7a:	7e 15                	jle    f0104d91 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f0104d7c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d7f:	8b 10                	mov    (%eax),%edx
f0104d81:	8b 48 04             	mov    0x4(%eax),%ecx
f0104d84:	8d 40 08             	lea    0x8(%eax),%eax
f0104d87:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0104d8a:	b8 08 00 00 00       	mov    $0x8,%eax
f0104d8f:	eb 5c                	jmp    f0104ded <.L35+0x2a>
	else if (lflag)
f0104d91:	85 c9                	test   %ecx,%ecx
f0104d93:	75 17                	jne    f0104dac <.L34+0x38>
		return va_arg(*ap, unsigned int);
f0104d95:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d98:	8b 10                	mov    (%eax),%edx
f0104d9a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d9f:	8d 40 04             	lea    0x4(%eax),%eax
f0104da2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0104da5:	b8 08 00 00 00       	mov    $0x8,%eax
f0104daa:	eb 41                	jmp    f0104ded <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104dac:	8b 45 14             	mov    0x14(%ebp),%eax
f0104daf:	8b 10                	mov    (%eax),%edx
f0104db1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104db6:	8d 40 04             	lea    0x4(%eax),%eax
f0104db9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0104dbc:	b8 08 00 00 00       	mov    $0x8,%eax
f0104dc1:	eb 2a                	jmp    f0104ded <.L35+0x2a>

f0104dc3 <.L35>:
			putch('0', putdat);
f0104dc3:	83 ec 08             	sub    $0x8,%esp
f0104dc6:	56                   	push   %esi
f0104dc7:	6a 30                	push   $0x30
f0104dc9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104dcc:	83 c4 08             	add    $0x8,%esp
f0104dcf:	56                   	push   %esi
f0104dd0:	6a 78                	push   $0x78
f0104dd2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0104dd5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dd8:	8b 10                	mov    (%eax),%edx
f0104dda:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104ddf:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104de2:	8d 40 04             	lea    0x4(%eax),%eax
f0104de5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104de8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104ded:	83 ec 0c             	sub    $0xc,%esp
f0104df0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104df4:	57                   	push   %edi
f0104df5:	ff 75 e0             	pushl  -0x20(%ebp)
f0104df8:	50                   	push   %eax
f0104df9:	51                   	push   %ecx
f0104dfa:	52                   	push   %edx
f0104dfb:	89 f2                	mov    %esi,%edx
f0104dfd:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e00:	e8 20 fb ff ff       	call   f0104925 <printnum>
			break;
f0104e05:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104e08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104e0b:	83 c7 01             	add    $0x1,%edi
f0104e0e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104e12:	83 f8 25             	cmp    $0x25,%eax
f0104e15:	0f 84 2d fc ff ff    	je     f0104a48 <vprintfmt+0x1f>
			if (ch == '\0')
f0104e1b:	85 c0                	test   %eax,%eax
f0104e1d:	0f 84 91 00 00 00    	je     f0104eb4 <.L22+0x21>
			putch(ch, putdat);
f0104e23:	83 ec 08             	sub    $0x8,%esp
f0104e26:	56                   	push   %esi
f0104e27:	50                   	push   %eax
f0104e28:	ff 55 08             	call   *0x8(%ebp)
f0104e2b:	83 c4 10             	add    $0x10,%esp
f0104e2e:	eb db                	jmp    f0104e0b <.L35+0x48>

f0104e30 <.L38>:
f0104e30:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104e33:	83 f9 01             	cmp    $0x1,%ecx
f0104e36:	7e 15                	jle    f0104e4d <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f0104e38:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e3b:	8b 10                	mov    (%eax),%edx
f0104e3d:	8b 48 04             	mov    0x4(%eax),%ecx
f0104e40:	8d 40 08             	lea    0x8(%eax),%eax
f0104e43:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104e46:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e4b:	eb a0                	jmp    f0104ded <.L35+0x2a>
	else if (lflag)
f0104e4d:	85 c9                	test   %ecx,%ecx
f0104e4f:	75 17                	jne    f0104e68 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f0104e51:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e54:	8b 10                	mov    (%eax),%edx
f0104e56:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e5b:	8d 40 04             	lea    0x4(%eax),%eax
f0104e5e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104e61:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e66:	eb 85                	jmp    f0104ded <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104e68:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e6b:	8b 10                	mov    (%eax),%edx
f0104e6d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e72:	8d 40 04             	lea    0x4(%eax),%eax
f0104e75:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104e78:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e7d:	e9 6b ff ff ff       	jmp    f0104ded <.L35+0x2a>

f0104e82 <.L25>:
			putch(ch, putdat);
f0104e82:	83 ec 08             	sub    $0x8,%esp
f0104e85:	56                   	push   %esi
f0104e86:	6a 25                	push   $0x25
f0104e88:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104e8b:	83 c4 10             	add    $0x10,%esp
f0104e8e:	e9 75 ff ff ff       	jmp    f0104e08 <.L35+0x45>

f0104e93 <.L22>:
			putch('%', putdat);
f0104e93:	83 ec 08             	sub    $0x8,%esp
f0104e96:	56                   	push   %esi
f0104e97:	6a 25                	push   $0x25
f0104e99:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104e9c:	83 c4 10             	add    $0x10,%esp
f0104e9f:	89 f8                	mov    %edi,%eax
f0104ea1:	eb 03                	jmp    f0104ea6 <.L22+0x13>
f0104ea3:	83 e8 01             	sub    $0x1,%eax
f0104ea6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104eaa:	75 f7                	jne    f0104ea3 <.L22+0x10>
f0104eac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104eaf:	e9 54 ff ff ff       	jmp    f0104e08 <.L35+0x45>
}
f0104eb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104eb7:	5b                   	pop    %ebx
f0104eb8:	5e                   	pop    %esi
f0104eb9:	5f                   	pop    %edi
f0104eba:	5d                   	pop    %ebp
f0104ebb:	c3                   	ret    

f0104ebc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104ebc:	55                   	push   %ebp
f0104ebd:	89 e5                	mov    %esp,%ebp
f0104ebf:	53                   	push   %ebx
f0104ec0:	83 ec 14             	sub    $0x14,%esp
f0104ec3:	e8 9f b2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104ec8:	81 c3 58 51 08 00    	add    $0x85158,%ebx
f0104ece:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ed1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104ed4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ed7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104edb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104ede:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104ee5:	85 c0                	test   %eax,%eax
f0104ee7:	74 2b                	je     f0104f14 <vsnprintf+0x58>
f0104ee9:	85 d2                	test   %edx,%edx
f0104eeb:	7e 27                	jle    f0104f14 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104eed:	ff 75 14             	pushl  0x14(%ebp)
f0104ef0:	ff 75 10             	pushl  0x10(%ebp)
f0104ef3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104ef6:	50                   	push   %eax
f0104ef7:	8d 83 cf a9 f7 ff    	lea    -0x85631(%ebx),%eax
f0104efd:	50                   	push   %eax
f0104efe:	e8 26 fb ff ff       	call   f0104a29 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104f03:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f06:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f0c:	83 c4 10             	add    $0x10,%esp
}
f0104f0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104f12:	c9                   	leave  
f0104f13:	c3                   	ret    
		return -E_INVAL;
f0104f14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f19:	eb f4                	jmp    f0104f0f <vsnprintf+0x53>

f0104f1b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104f1b:	55                   	push   %ebp
f0104f1c:	89 e5                	mov    %esp,%ebp
f0104f1e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104f21:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104f24:	50                   	push   %eax
f0104f25:	ff 75 10             	pushl  0x10(%ebp)
f0104f28:	ff 75 0c             	pushl  0xc(%ebp)
f0104f2b:	ff 75 08             	pushl  0x8(%ebp)
f0104f2e:	e8 89 ff ff ff       	call   f0104ebc <vsnprintf>
	va_end(ap);

	return rc;
}
f0104f33:	c9                   	leave  
f0104f34:	c3                   	ret    

f0104f35 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104f35:	55                   	push   %ebp
f0104f36:	89 e5                	mov    %esp,%ebp
f0104f38:	57                   	push   %edi
f0104f39:	56                   	push   %esi
f0104f3a:	53                   	push   %ebx
f0104f3b:	83 ec 1c             	sub    $0x1c,%esp
f0104f3e:	e8 24 b2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104f43:	81 c3 dd 50 08 00    	add    $0x850dd,%ebx
f0104f49:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104f4c:	85 c0                	test   %eax,%eax
f0104f4e:	74 13                	je     f0104f63 <readline+0x2e>
		cprintf("%s", prompt);
f0104f50:	83 ec 08             	sub    $0x8,%esp
f0104f53:	50                   	push   %eax
f0104f54:	8d 83 19 c3 f7 ff    	lea    -0x83ce7(%ebx),%eax
f0104f5a:	50                   	push   %eax
f0104f5b:	e8 d1 eb ff ff       	call   f0103b31 <cprintf>
f0104f60:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104f63:	83 ec 0c             	sub    $0xc,%esp
f0104f66:	6a 00                	push   $0x0
f0104f68:	e8 92 b7 ff ff       	call   f01006ff <iscons>
f0104f6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f70:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104f73:	bf 00 00 00 00       	mov    $0x0,%edi
f0104f78:	eb 46                	jmp    f0104fc0 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0104f7a:	83 ec 08             	sub    $0x8,%esp
f0104f7d:	50                   	push   %eax
f0104f7e:	8d 83 7c cc f7 ff    	lea    -0x83384(%ebx),%eax
f0104f84:	50                   	push   %eax
f0104f85:	e8 a7 eb ff ff       	call   f0103b31 <cprintf>
			return NULL;
f0104f8a:	83 c4 10             	add    $0x10,%esp
f0104f8d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f95:	5b                   	pop    %ebx
f0104f96:	5e                   	pop    %esi
f0104f97:	5f                   	pop    %edi
f0104f98:	5d                   	pop    %ebp
f0104f99:	c3                   	ret    
			if (echoing)
f0104f9a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104f9e:	75 05                	jne    f0104fa5 <readline+0x70>
			i--;
f0104fa0:	83 ef 01             	sub    $0x1,%edi
f0104fa3:	eb 1b                	jmp    f0104fc0 <readline+0x8b>
				cputchar('\b');
f0104fa5:	83 ec 0c             	sub    $0xc,%esp
f0104fa8:	6a 08                	push   $0x8
f0104faa:	e8 2f b7 ff ff       	call   f01006de <cputchar>
f0104faf:	83 c4 10             	add    $0x10,%esp
f0104fb2:	eb ec                	jmp    f0104fa0 <readline+0x6b>
			buf[i++] = c;
f0104fb4:	89 f0                	mov    %esi,%eax
f0104fb6:	88 84 3b e0 2b 00 00 	mov    %al,0x2be0(%ebx,%edi,1)
f0104fbd:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104fc0:	e8 29 b7 ff ff       	call   f01006ee <getchar>
f0104fc5:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104fc7:	85 c0                	test   %eax,%eax
f0104fc9:	78 af                	js     f0104f7a <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104fcb:	83 f8 08             	cmp    $0x8,%eax
f0104fce:	0f 94 c2             	sete   %dl
f0104fd1:	83 f8 7f             	cmp    $0x7f,%eax
f0104fd4:	0f 94 c0             	sete   %al
f0104fd7:	08 c2                	or     %al,%dl
f0104fd9:	74 04                	je     f0104fdf <readline+0xaa>
f0104fdb:	85 ff                	test   %edi,%edi
f0104fdd:	7f bb                	jg     f0104f9a <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104fdf:	83 fe 1f             	cmp    $0x1f,%esi
f0104fe2:	7e 1c                	jle    f0105000 <readline+0xcb>
f0104fe4:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104fea:	7f 14                	jg     f0105000 <readline+0xcb>
			if (echoing)
f0104fec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104ff0:	74 c2                	je     f0104fb4 <readline+0x7f>
				cputchar(c);
f0104ff2:	83 ec 0c             	sub    $0xc,%esp
f0104ff5:	56                   	push   %esi
f0104ff6:	e8 e3 b6 ff ff       	call   f01006de <cputchar>
f0104ffb:	83 c4 10             	add    $0x10,%esp
f0104ffe:	eb b4                	jmp    f0104fb4 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0105000:	83 fe 0a             	cmp    $0xa,%esi
f0105003:	74 05                	je     f010500a <readline+0xd5>
f0105005:	83 fe 0d             	cmp    $0xd,%esi
f0105008:	75 b6                	jne    f0104fc0 <readline+0x8b>
			if (echoing)
f010500a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010500e:	75 13                	jne    f0105023 <readline+0xee>
			buf[i] = 0;
f0105010:	c6 84 3b e0 2b 00 00 	movb   $0x0,0x2be0(%ebx,%edi,1)
f0105017:	00 
			return buf;
f0105018:	8d 83 e0 2b 00 00    	lea    0x2be0(%ebx),%eax
f010501e:	e9 6f ff ff ff       	jmp    f0104f92 <readline+0x5d>
				cputchar('\n');
f0105023:	83 ec 0c             	sub    $0xc,%esp
f0105026:	6a 0a                	push   $0xa
f0105028:	e8 b1 b6 ff ff       	call   f01006de <cputchar>
f010502d:	83 c4 10             	add    $0x10,%esp
f0105030:	eb de                	jmp    f0105010 <readline+0xdb>

f0105032 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105032:	55                   	push   %ebp
f0105033:	89 e5                	mov    %esp,%ebp
f0105035:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105038:	b8 00 00 00 00       	mov    $0x0,%eax
f010503d:	eb 03                	jmp    f0105042 <strlen+0x10>
		n++;
f010503f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105042:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105046:	75 f7                	jne    f010503f <strlen+0xd>
	return n;
}
f0105048:	5d                   	pop    %ebp
f0105049:	c3                   	ret    

f010504a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010504a:	55                   	push   %ebp
f010504b:	89 e5                	mov    %esp,%ebp
f010504d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105050:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105053:	b8 00 00 00 00       	mov    $0x0,%eax
f0105058:	eb 03                	jmp    f010505d <strnlen+0x13>
		n++;
f010505a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010505d:	39 d0                	cmp    %edx,%eax
f010505f:	74 06                	je     f0105067 <strnlen+0x1d>
f0105061:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105065:	75 f3                	jne    f010505a <strnlen+0x10>
	return n;
}
f0105067:	5d                   	pop    %ebp
f0105068:	c3                   	ret    

f0105069 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105069:	55                   	push   %ebp
f010506a:	89 e5                	mov    %esp,%ebp
f010506c:	53                   	push   %ebx
f010506d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105070:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105073:	89 c2                	mov    %eax,%edx
f0105075:	83 c1 01             	add    $0x1,%ecx
f0105078:	83 c2 01             	add    $0x1,%edx
f010507b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010507f:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105082:	84 db                	test   %bl,%bl
f0105084:	75 ef                	jne    f0105075 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105086:	5b                   	pop    %ebx
f0105087:	5d                   	pop    %ebp
f0105088:	c3                   	ret    

f0105089 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105089:	55                   	push   %ebp
f010508a:	89 e5                	mov    %esp,%ebp
f010508c:	53                   	push   %ebx
f010508d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105090:	53                   	push   %ebx
f0105091:	e8 9c ff ff ff       	call   f0105032 <strlen>
f0105096:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105099:	ff 75 0c             	pushl  0xc(%ebp)
f010509c:	01 d8                	add    %ebx,%eax
f010509e:	50                   	push   %eax
f010509f:	e8 c5 ff ff ff       	call   f0105069 <strcpy>
	return dst;
}
f01050a4:	89 d8                	mov    %ebx,%eax
f01050a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01050a9:	c9                   	leave  
f01050aa:	c3                   	ret    

f01050ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01050ab:	55                   	push   %ebp
f01050ac:	89 e5                	mov    %esp,%ebp
f01050ae:	56                   	push   %esi
f01050af:	53                   	push   %ebx
f01050b0:	8b 75 08             	mov    0x8(%ebp),%esi
f01050b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01050b6:	89 f3                	mov    %esi,%ebx
f01050b8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01050bb:	89 f2                	mov    %esi,%edx
f01050bd:	eb 0f                	jmp    f01050ce <strncpy+0x23>
		*dst++ = *src;
f01050bf:	83 c2 01             	add    $0x1,%edx
f01050c2:	0f b6 01             	movzbl (%ecx),%eax
f01050c5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01050c8:	80 39 01             	cmpb   $0x1,(%ecx)
f01050cb:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f01050ce:	39 da                	cmp    %ebx,%edx
f01050d0:	75 ed                	jne    f01050bf <strncpy+0x14>
	}
	return ret;
}
f01050d2:	89 f0                	mov    %esi,%eax
f01050d4:	5b                   	pop    %ebx
f01050d5:	5e                   	pop    %esi
f01050d6:	5d                   	pop    %ebp
f01050d7:	c3                   	ret    

f01050d8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01050d8:	55                   	push   %ebp
f01050d9:	89 e5                	mov    %esp,%ebp
f01050db:	56                   	push   %esi
f01050dc:	53                   	push   %ebx
f01050dd:	8b 75 08             	mov    0x8(%ebp),%esi
f01050e0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01050e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01050e6:	89 f0                	mov    %esi,%eax
f01050e8:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01050ec:	85 c9                	test   %ecx,%ecx
f01050ee:	75 0b                	jne    f01050fb <strlcpy+0x23>
f01050f0:	eb 17                	jmp    f0105109 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01050f2:	83 c2 01             	add    $0x1,%edx
f01050f5:	83 c0 01             	add    $0x1,%eax
f01050f8:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01050fb:	39 d8                	cmp    %ebx,%eax
f01050fd:	74 07                	je     f0105106 <strlcpy+0x2e>
f01050ff:	0f b6 0a             	movzbl (%edx),%ecx
f0105102:	84 c9                	test   %cl,%cl
f0105104:	75 ec                	jne    f01050f2 <strlcpy+0x1a>
		*dst = '\0';
f0105106:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105109:	29 f0                	sub    %esi,%eax
}
f010510b:	5b                   	pop    %ebx
f010510c:	5e                   	pop    %esi
f010510d:	5d                   	pop    %ebp
f010510e:	c3                   	ret    

f010510f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010510f:	55                   	push   %ebp
f0105110:	89 e5                	mov    %esp,%ebp
f0105112:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105115:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105118:	eb 06                	jmp    f0105120 <strcmp+0x11>
		p++, q++;
f010511a:	83 c1 01             	add    $0x1,%ecx
f010511d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105120:	0f b6 01             	movzbl (%ecx),%eax
f0105123:	84 c0                	test   %al,%al
f0105125:	74 04                	je     f010512b <strcmp+0x1c>
f0105127:	3a 02                	cmp    (%edx),%al
f0105129:	74 ef                	je     f010511a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010512b:	0f b6 c0             	movzbl %al,%eax
f010512e:	0f b6 12             	movzbl (%edx),%edx
f0105131:	29 d0                	sub    %edx,%eax
}
f0105133:	5d                   	pop    %ebp
f0105134:	c3                   	ret    

f0105135 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105135:	55                   	push   %ebp
f0105136:	89 e5                	mov    %esp,%ebp
f0105138:	53                   	push   %ebx
f0105139:	8b 45 08             	mov    0x8(%ebp),%eax
f010513c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010513f:	89 c3                	mov    %eax,%ebx
f0105141:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105144:	eb 06                	jmp    f010514c <strncmp+0x17>
		n--, p++, q++;
f0105146:	83 c0 01             	add    $0x1,%eax
f0105149:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010514c:	39 d8                	cmp    %ebx,%eax
f010514e:	74 16                	je     f0105166 <strncmp+0x31>
f0105150:	0f b6 08             	movzbl (%eax),%ecx
f0105153:	84 c9                	test   %cl,%cl
f0105155:	74 04                	je     f010515b <strncmp+0x26>
f0105157:	3a 0a                	cmp    (%edx),%cl
f0105159:	74 eb                	je     f0105146 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010515b:	0f b6 00             	movzbl (%eax),%eax
f010515e:	0f b6 12             	movzbl (%edx),%edx
f0105161:	29 d0                	sub    %edx,%eax
}
f0105163:	5b                   	pop    %ebx
f0105164:	5d                   	pop    %ebp
f0105165:	c3                   	ret    
		return 0;
f0105166:	b8 00 00 00 00       	mov    $0x0,%eax
f010516b:	eb f6                	jmp    f0105163 <strncmp+0x2e>

f010516d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010516d:	55                   	push   %ebp
f010516e:	89 e5                	mov    %esp,%ebp
f0105170:	8b 45 08             	mov    0x8(%ebp),%eax
f0105173:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105177:	0f b6 10             	movzbl (%eax),%edx
f010517a:	84 d2                	test   %dl,%dl
f010517c:	74 09                	je     f0105187 <strchr+0x1a>
		if (*s == c)
f010517e:	38 ca                	cmp    %cl,%dl
f0105180:	74 0a                	je     f010518c <strchr+0x1f>
	for (; *s; s++)
f0105182:	83 c0 01             	add    $0x1,%eax
f0105185:	eb f0                	jmp    f0105177 <strchr+0xa>
			return (char *) s;
	return 0;
f0105187:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010518c:	5d                   	pop    %ebp
f010518d:	c3                   	ret    

f010518e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010518e:	55                   	push   %ebp
f010518f:	89 e5                	mov    %esp,%ebp
f0105191:	8b 45 08             	mov    0x8(%ebp),%eax
f0105194:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105198:	eb 03                	jmp    f010519d <strfind+0xf>
f010519a:	83 c0 01             	add    $0x1,%eax
f010519d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01051a0:	38 ca                	cmp    %cl,%dl
f01051a2:	74 04                	je     f01051a8 <strfind+0x1a>
f01051a4:	84 d2                	test   %dl,%dl
f01051a6:	75 f2                	jne    f010519a <strfind+0xc>
			break;
	return (char *) s;
}
f01051a8:	5d                   	pop    %ebp
f01051a9:	c3                   	ret    

f01051aa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01051aa:	55                   	push   %ebp
f01051ab:	89 e5                	mov    %esp,%ebp
f01051ad:	57                   	push   %edi
f01051ae:	56                   	push   %esi
f01051af:	53                   	push   %ebx
f01051b0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01051b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01051b6:	85 c9                	test   %ecx,%ecx
f01051b8:	74 13                	je     f01051cd <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01051ba:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01051c0:	75 05                	jne    f01051c7 <memset+0x1d>
f01051c2:	f6 c1 03             	test   $0x3,%cl
f01051c5:	74 0d                	je     f01051d4 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01051c7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051ca:	fc                   	cld    
f01051cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01051cd:	89 f8                	mov    %edi,%eax
f01051cf:	5b                   	pop    %ebx
f01051d0:	5e                   	pop    %esi
f01051d1:	5f                   	pop    %edi
f01051d2:	5d                   	pop    %ebp
f01051d3:	c3                   	ret    
		c &= 0xFF;
f01051d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01051d8:	89 d3                	mov    %edx,%ebx
f01051da:	c1 e3 08             	shl    $0x8,%ebx
f01051dd:	89 d0                	mov    %edx,%eax
f01051df:	c1 e0 18             	shl    $0x18,%eax
f01051e2:	89 d6                	mov    %edx,%esi
f01051e4:	c1 e6 10             	shl    $0x10,%esi
f01051e7:	09 f0                	or     %esi,%eax
f01051e9:	09 c2                	or     %eax,%edx
f01051eb:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01051ed:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01051f0:	89 d0                	mov    %edx,%eax
f01051f2:	fc                   	cld    
f01051f3:	f3 ab                	rep stos %eax,%es:(%edi)
f01051f5:	eb d6                	jmp    f01051cd <memset+0x23>

f01051f7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01051f7:	55                   	push   %ebp
f01051f8:	89 e5                	mov    %esp,%ebp
f01051fa:	57                   	push   %edi
f01051fb:	56                   	push   %esi
f01051fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01051ff:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105202:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105205:	39 c6                	cmp    %eax,%esi
f0105207:	73 35                	jae    f010523e <memmove+0x47>
f0105209:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010520c:	39 c2                	cmp    %eax,%edx
f010520e:	76 2e                	jbe    f010523e <memmove+0x47>
		s += n;
		d += n;
f0105210:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105213:	89 d6                	mov    %edx,%esi
f0105215:	09 fe                	or     %edi,%esi
f0105217:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010521d:	74 0c                	je     f010522b <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010521f:	83 ef 01             	sub    $0x1,%edi
f0105222:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105225:	fd                   	std    
f0105226:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105228:	fc                   	cld    
f0105229:	eb 21                	jmp    f010524c <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010522b:	f6 c1 03             	test   $0x3,%cl
f010522e:	75 ef                	jne    f010521f <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105230:	83 ef 04             	sub    $0x4,%edi
f0105233:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105236:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105239:	fd                   	std    
f010523a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010523c:	eb ea                	jmp    f0105228 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010523e:	89 f2                	mov    %esi,%edx
f0105240:	09 c2                	or     %eax,%edx
f0105242:	f6 c2 03             	test   $0x3,%dl
f0105245:	74 09                	je     f0105250 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105247:	89 c7                	mov    %eax,%edi
f0105249:	fc                   	cld    
f010524a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010524c:	5e                   	pop    %esi
f010524d:	5f                   	pop    %edi
f010524e:	5d                   	pop    %ebp
f010524f:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105250:	f6 c1 03             	test   $0x3,%cl
f0105253:	75 f2                	jne    f0105247 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105255:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105258:	89 c7                	mov    %eax,%edi
f010525a:	fc                   	cld    
f010525b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010525d:	eb ed                	jmp    f010524c <memmove+0x55>

f010525f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010525f:	55                   	push   %ebp
f0105260:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105262:	ff 75 10             	pushl  0x10(%ebp)
f0105265:	ff 75 0c             	pushl  0xc(%ebp)
f0105268:	ff 75 08             	pushl  0x8(%ebp)
f010526b:	e8 87 ff ff ff       	call   f01051f7 <memmove>
}
f0105270:	c9                   	leave  
f0105271:	c3                   	ret    

f0105272 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105272:	55                   	push   %ebp
f0105273:	89 e5                	mov    %esp,%ebp
f0105275:	56                   	push   %esi
f0105276:	53                   	push   %ebx
f0105277:	8b 45 08             	mov    0x8(%ebp),%eax
f010527a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010527d:	89 c6                	mov    %eax,%esi
f010527f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105282:	39 f0                	cmp    %esi,%eax
f0105284:	74 1c                	je     f01052a2 <memcmp+0x30>
		if (*s1 != *s2)
f0105286:	0f b6 08             	movzbl (%eax),%ecx
f0105289:	0f b6 1a             	movzbl (%edx),%ebx
f010528c:	38 d9                	cmp    %bl,%cl
f010528e:	75 08                	jne    f0105298 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105290:	83 c0 01             	add    $0x1,%eax
f0105293:	83 c2 01             	add    $0x1,%edx
f0105296:	eb ea                	jmp    f0105282 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105298:	0f b6 c1             	movzbl %cl,%eax
f010529b:	0f b6 db             	movzbl %bl,%ebx
f010529e:	29 d8                	sub    %ebx,%eax
f01052a0:	eb 05                	jmp    f01052a7 <memcmp+0x35>
	}

	return 0;
f01052a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052a7:	5b                   	pop    %ebx
f01052a8:	5e                   	pop    %esi
f01052a9:	5d                   	pop    %ebp
f01052aa:	c3                   	ret    

f01052ab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01052ab:	55                   	push   %ebp
f01052ac:	89 e5                	mov    %esp,%ebp
f01052ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01052b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01052b4:	89 c2                	mov    %eax,%edx
f01052b6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01052b9:	39 d0                	cmp    %edx,%eax
f01052bb:	73 09                	jae    f01052c6 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01052bd:	38 08                	cmp    %cl,(%eax)
f01052bf:	74 05                	je     f01052c6 <memfind+0x1b>
	for (; s < ends; s++)
f01052c1:	83 c0 01             	add    $0x1,%eax
f01052c4:	eb f3                	jmp    f01052b9 <memfind+0xe>
			break;
	return (void *) s;
}
f01052c6:	5d                   	pop    %ebp
f01052c7:	c3                   	ret    

f01052c8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01052c8:	55                   	push   %ebp
f01052c9:	89 e5                	mov    %esp,%ebp
f01052cb:	57                   	push   %edi
f01052cc:	56                   	push   %esi
f01052cd:	53                   	push   %ebx
f01052ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01052d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01052d4:	eb 03                	jmp    f01052d9 <strtol+0x11>
		s++;
f01052d6:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01052d9:	0f b6 01             	movzbl (%ecx),%eax
f01052dc:	3c 20                	cmp    $0x20,%al
f01052de:	74 f6                	je     f01052d6 <strtol+0xe>
f01052e0:	3c 09                	cmp    $0x9,%al
f01052e2:	74 f2                	je     f01052d6 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01052e4:	3c 2b                	cmp    $0x2b,%al
f01052e6:	74 2e                	je     f0105316 <strtol+0x4e>
	int neg = 0;
f01052e8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01052ed:	3c 2d                	cmp    $0x2d,%al
f01052ef:	74 2f                	je     f0105320 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01052f1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01052f7:	75 05                	jne    f01052fe <strtol+0x36>
f01052f9:	80 39 30             	cmpb   $0x30,(%ecx)
f01052fc:	74 2c                	je     f010532a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01052fe:	85 db                	test   %ebx,%ebx
f0105300:	75 0a                	jne    f010530c <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105302:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0105307:	80 39 30             	cmpb   $0x30,(%ecx)
f010530a:	74 28                	je     f0105334 <strtol+0x6c>
		base = 10;
f010530c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105311:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105314:	eb 50                	jmp    f0105366 <strtol+0x9e>
		s++;
f0105316:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105319:	bf 00 00 00 00       	mov    $0x0,%edi
f010531e:	eb d1                	jmp    f01052f1 <strtol+0x29>
		s++, neg = 1;
f0105320:	83 c1 01             	add    $0x1,%ecx
f0105323:	bf 01 00 00 00       	mov    $0x1,%edi
f0105328:	eb c7                	jmp    f01052f1 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010532a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010532e:	74 0e                	je     f010533e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105330:	85 db                	test   %ebx,%ebx
f0105332:	75 d8                	jne    f010530c <strtol+0x44>
		s++, base = 8;
f0105334:	83 c1 01             	add    $0x1,%ecx
f0105337:	bb 08 00 00 00       	mov    $0x8,%ebx
f010533c:	eb ce                	jmp    f010530c <strtol+0x44>
		s += 2, base = 16;
f010533e:	83 c1 02             	add    $0x2,%ecx
f0105341:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105346:	eb c4                	jmp    f010530c <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105348:	8d 72 9f             	lea    -0x61(%edx),%esi
f010534b:	89 f3                	mov    %esi,%ebx
f010534d:	80 fb 19             	cmp    $0x19,%bl
f0105350:	77 29                	ja     f010537b <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105352:	0f be d2             	movsbl %dl,%edx
f0105355:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105358:	3b 55 10             	cmp    0x10(%ebp),%edx
f010535b:	7d 30                	jge    f010538d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010535d:	83 c1 01             	add    $0x1,%ecx
f0105360:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105364:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105366:	0f b6 11             	movzbl (%ecx),%edx
f0105369:	8d 72 d0             	lea    -0x30(%edx),%esi
f010536c:	89 f3                	mov    %esi,%ebx
f010536e:	80 fb 09             	cmp    $0x9,%bl
f0105371:	77 d5                	ja     f0105348 <strtol+0x80>
			dig = *s - '0';
f0105373:	0f be d2             	movsbl %dl,%edx
f0105376:	83 ea 30             	sub    $0x30,%edx
f0105379:	eb dd                	jmp    f0105358 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f010537b:	8d 72 bf             	lea    -0x41(%edx),%esi
f010537e:	89 f3                	mov    %esi,%ebx
f0105380:	80 fb 19             	cmp    $0x19,%bl
f0105383:	77 08                	ja     f010538d <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105385:	0f be d2             	movsbl %dl,%edx
f0105388:	83 ea 37             	sub    $0x37,%edx
f010538b:	eb cb                	jmp    f0105358 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010538d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105391:	74 05                	je     f0105398 <strtol+0xd0>
		*endptr = (char *) s;
f0105393:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105396:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105398:	89 c2                	mov    %eax,%edx
f010539a:	f7 da                	neg    %edx
f010539c:	85 ff                	test   %edi,%edi
f010539e:	0f 45 c2             	cmovne %edx,%eax
}
f01053a1:	5b                   	pop    %ebx
f01053a2:	5e                   	pop    %esi
f01053a3:	5f                   	pop    %edi
f01053a4:	5d                   	pop    %ebp
f01053a5:	c3                   	ret    
f01053a6:	66 90                	xchg   %ax,%ax
f01053a8:	66 90                	xchg   %ax,%ax
f01053aa:	66 90                	xchg   %ax,%ax
f01053ac:	66 90                	xchg   %ax,%ax
f01053ae:	66 90                	xchg   %ax,%ax

f01053b0 <__udivdi3>:
f01053b0:	55                   	push   %ebp
f01053b1:	57                   	push   %edi
f01053b2:	56                   	push   %esi
f01053b3:	53                   	push   %ebx
f01053b4:	83 ec 1c             	sub    $0x1c,%esp
f01053b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01053bb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01053bf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01053c3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01053c7:	85 d2                	test   %edx,%edx
f01053c9:	75 35                	jne    f0105400 <__udivdi3+0x50>
f01053cb:	39 f3                	cmp    %esi,%ebx
f01053cd:	0f 87 bd 00 00 00    	ja     f0105490 <__udivdi3+0xe0>
f01053d3:	85 db                	test   %ebx,%ebx
f01053d5:	89 d9                	mov    %ebx,%ecx
f01053d7:	75 0b                	jne    f01053e4 <__udivdi3+0x34>
f01053d9:	b8 01 00 00 00       	mov    $0x1,%eax
f01053de:	31 d2                	xor    %edx,%edx
f01053e0:	f7 f3                	div    %ebx
f01053e2:	89 c1                	mov    %eax,%ecx
f01053e4:	31 d2                	xor    %edx,%edx
f01053e6:	89 f0                	mov    %esi,%eax
f01053e8:	f7 f1                	div    %ecx
f01053ea:	89 c6                	mov    %eax,%esi
f01053ec:	89 e8                	mov    %ebp,%eax
f01053ee:	89 f7                	mov    %esi,%edi
f01053f0:	f7 f1                	div    %ecx
f01053f2:	89 fa                	mov    %edi,%edx
f01053f4:	83 c4 1c             	add    $0x1c,%esp
f01053f7:	5b                   	pop    %ebx
f01053f8:	5e                   	pop    %esi
f01053f9:	5f                   	pop    %edi
f01053fa:	5d                   	pop    %ebp
f01053fb:	c3                   	ret    
f01053fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105400:	39 f2                	cmp    %esi,%edx
f0105402:	77 7c                	ja     f0105480 <__udivdi3+0xd0>
f0105404:	0f bd fa             	bsr    %edx,%edi
f0105407:	83 f7 1f             	xor    $0x1f,%edi
f010540a:	0f 84 98 00 00 00    	je     f01054a8 <__udivdi3+0xf8>
f0105410:	89 f9                	mov    %edi,%ecx
f0105412:	b8 20 00 00 00       	mov    $0x20,%eax
f0105417:	29 f8                	sub    %edi,%eax
f0105419:	d3 e2                	shl    %cl,%edx
f010541b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010541f:	89 c1                	mov    %eax,%ecx
f0105421:	89 da                	mov    %ebx,%edx
f0105423:	d3 ea                	shr    %cl,%edx
f0105425:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105429:	09 d1                	or     %edx,%ecx
f010542b:	89 f2                	mov    %esi,%edx
f010542d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105431:	89 f9                	mov    %edi,%ecx
f0105433:	d3 e3                	shl    %cl,%ebx
f0105435:	89 c1                	mov    %eax,%ecx
f0105437:	d3 ea                	shr    %cl,%edx
f0105439:	89 f9                	mov    %edi,%ecx
f010543b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010543f:	d3 e6                	shl    %cl,%esi
f0105441:	89 eb                	mov    %ebp,%ebx
f0105443:	89 c1                	mov    %eax,%ecx
f0105445:	d3 eb                	shr    %cl,%ebx
f0105447:	09 de                	or     %ebx,%esi
f0105449:	89 f0                	mov    %esi,%eax
f010544b:	f7 74 24 08          	divl   0x8(%esp)
f010544f:	89 d6                	mov    %edx,%esi
f0105451:	89 c3                	mov    %eax,%ebx
f0105453:	f7 64 24 0c          	mull   0xc(%esp)
f0105457:	39 d6                	cmp    %edx,%esi
f0105459:	72 0c                	jb     f0105467 <__udivdi3+0xb7>
f010545b:	89 f9                	mov    %edi,%ecx
f010545d:	d3 e5                	shl    %cl,%ebp
f010545f:	39 c5                	cmp    %eax,%ebp
f0105461:	73 5d                	jae    f01054c0 <__udivdi3+0x110>
f0105463:	39 d6                	cmp    %edx,%esi
f0105465:	75 59                	jne    f01054c0 <__udivdi3+0x110>
f0105467:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010546a:	31 ff                	xor    %edi,%edi
f010546c:	89 fa                	mov    %edi,%edx
f010546e:	83 c4 1c             	add    $0x1c,%esp
f0105471:	5b                   	pop    %ebx
f0105472:	5e                   	pop    %esi
f0105473:	5f                   	pop    %edi
f0105474:	5d                   	pop    %ebp
f0105475:	c3                   	ret    
f0105476:	8d 76 00             	lea    0x0(%esi),%esi
f0105479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0105480:	31 ff                	xor    %edi,%edi
f0105482:	31 c0                	xor    %eax,%eax
f0105484:	89 fa                	mov    %edi,%edx
f0105486:	83 c4 1c             	add    $0x1c,%esp
f0105489:	5b                   	pop    %ebx
f010548a:	5e                   	pop    %esi
f010548b:	5f                   	pop    %edi
f010548c:	5d                   	pop    %ebp
f010548d:	c3                   	ret    
f010548e:	66 90                	xchg   %ax,%ax
f0105490:	31 ff                	xor    %edi,%edi
f0105492:	89 e8                	mov    %ebp,%eax
f0105494:	89 f2                	mov    %esi,%edx
f0105496:	f7 f3                	div    %ebx
f0105498:	89 fa                	mov    %edi,%edx
f010549a:	83 c4 1c             	add    $0x1c,%esp
f010549d:	5b                   	pop    %ebx
f010549e:	5e                   	pop    %esi
f010549f:	5f                   	pop    %edi
f01054a0:	5d                   	pop    %ebp
f01054a1:	c3                   	ret    
f01054a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01054a8:	39 f2                	cmp    %esi,%edx
f01054aa:	72 06                	jb     f01054b2 <__udivdi3+0x102>
f01054ac:	31 c0                	xor    %eax,%eax
f01054ae:	39 eb                	cmp    %ebp,%ebx
f01054b0:	77 d2                	ja     f0105484 <__udivdi3+0xd4>
f01054b2:	b8 01 00 00 00       	mov    $0x1,%eax
f01054b7:	eb cb                	jmp    f0105484 <__udivdi3+0xd4>
f01054b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01054c0:	89 d8                	mov    %ebx,%eax
f01054c2:	31 ff                	xor    %edi,%edi
f01054c4:	eb be                	jmp    f0105484 <__udivdi3+0xd4>
f01054c6:	66 90                	xchg   %ax,%ax
f01054c8:	66 90                	xchg   %ax,%ax
f01054ca:	66 90                	xchg   %ax,%ax
f01054cc:	66 90                	xchg   %ax,%ax
f01054ce:	66 90                	xchg   %ax,%ax

f01054d0 <__umoddi3>:
f01054d0:	55                   	push   %ebp
f01054d1:	57                   	push   %edi
f01054d2:	56                   	push   %esi
f01054d3:	53                   	push   %ebx
f01054d4:	83 ec 1c             	sub    $0x1c,%esp
f01054d7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01054db:	8b 74 24 30          	mov    0x30(%esp),%esi
f01054df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01054e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01054e7:	85 ed                	test   %ebp,%ebp
f01054e9:	89 f0                	mov    %esi,%eax
f01054eb:	89 da                	mov    %ebx,%edx
f01054ed:	75 19                	jne    f0105508 <__umoddi3+0x38>
f01054ef:	39 df                	cmp    %ebx,%edi
f01054f1:	0f 86 b1 00 00 00    	jbe    f01055a8 <__umoddi3+0xd8>
f01054f7:	f7 f7                	div    %edi
f01054f9:	89 d0                	mov    %edx,%eax
f01054fb:	31 d2                	xor    %edx,%edx
f01054fd:	83 c4 1c             	add    $0x1c,%esp
f0105500:	5b                   	pop    %ebx
f0105501:	5e                   	pop    %esi
f0105502:	5f                   	pop    %edi
f0105503:	5d                   	pop    %ebp
f0105504:	c3                   	ret    
f0105505:	8d 76 00             	lea    0x0(%esi),%esi
f0105508:	39 dd                	cmp    %ebx,%ebp
f010550a:	77 f1                	ja     f01054fd <__umoddi3+0x2d>
f010550c:	0f bd cd             	bsr    %ebp,%ecx
f010550f:	83 f1 1f             	xor    $0x1f,%ecx
f0105512:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105516:	0f 84 b4 00 00 00    	je     f01055d0 <__umoddi3+0x100>
f010551c:	b8 20 00 00 00       	mov    $0x20,%eax
f0105521:	89 c2                	mov    %eax,%edx
f0105523:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105527:	29 c2                	sub    %eax,%edx
f0105529:	89 c1                	mov    %eax,%ecx
f010552b:	89 f8                	mov    %edi,%eax
f010552d:	d3 e5                	shl    %cl,%ebp
f010552f:	89 d1                	mov    %edx,%ecx
f0105531:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105535:	d3 e8                	shr    %cl,%eax
f0105537:	09 c5                	or     %eax,%ebp
f0105539:	8b 44 24 04          	mov    0x4(%esp),%eax
f010553d:	89 c1                	mov    %eax,%ecx
f010553f:	d3 e7                	shl    %cl,%edi
f0105541:	89 d1                	mov    %edx,%ecx
f0105543:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105547:	89 df                	mov    %ebx,%edi
f0105549:	d3 ef                	shr    %cl,%edi
f010554b:	89 c1                	mov    %eax,%ecx
f010554d:	89 f0                	mov    %esi,%eax
f010554f:	d3 e3                	shl    %cl,%ebx
f0105551:	89 d1                	mov    %edx,%ecx
f0105553:	89 fa                	mov    %edi,%edx
f0105555:	d3 e8                	shr    %cl,%eax
f0105557:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010555c:	09 d8                	or     %ebx,%eax
f010555e:	f7 f5                	div    %ebp
f0105560:	d3 e6                	shl    %cl,%esi
f0105562:	89 d1                	mov    %edx,%ecx
f0105564:	f7 64 24 08          	mull   0x8(%esp)
f0105568:	39 d1                	cmp    %edx,%ecx
f010556a:	89 c3                	mov    %eax,%ebx
f010556c:	89 d7                	mov    %edx,%edi
f010556e:	72 06                	jb     f0105576 <__umoddi3+0xa6>
f0105570:	75 0e                	jne    f0105580 <__umoddi3+0xb0>
f0105572:	39 c6                	cmp    %eax,%esi
f0105574:	73 0a                	jae    f0105580 <__umoddi3+0xb0>
f0105576:	2b 44 24 08          	sub    0x8(%esp),%eax
f010557a:	19 ea                	sbb    %ebp,%edx
f010557c:	89 d7                	mov    %edx,%edi
f010557e:	89 c3                	mov    %eax,%ebx
f0105580:	89 ca                	mov    %ecx,%edx
f0105582:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0105587:	29 de                	sub    %ebx,%esi
f0105589:	19 fa                	sbb    %edi,%edx
f010558b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010558f:	89 d0                	mov    %edx,%eax
f0105591:	d3 e0                	shl    %cl,%eax
f0105593:	89 d9                	mov    %ebx,%ecx
f0105595:	d3 ee                	shr    %cl,%esi
f0105597:	d3 ea                	shr    %cl,%edx
f0105599:	09 f0                	or     %esi,%eax
f010559b:	83 c4 1c             	add    $0x1c,%esp
f010559e:	5b                   	pop    %ebx
f010559f:	5e                   	pop    %esi
f01055a0:	5f                   	pop    %edi
f01055a1:	5d                   	pop    %ebp
f01055a2:	c3                   	ret    
f01055a3:	90                   	nop
f01055a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01055a8:	85 ff                	test   %edi,%edi
f01055aa:	89 f9                	mov    %edi,%ecx
f01055ac:	75 0b                	jne    f01055b9 <__umoddi3+0xe9>
f01055ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01055b3:	31 d2                	xor    %edx,%edx
f01055b5:	f7 f7                	div    %edi
f01055b7:	89 c1                	mov    %eax,%ecx
f01055b9:	89 d8                	mov    %ebx,%eax
f01055bb:	31 d2                	xor    %edx,%edx
f01055bd:	f7 f1                	div    %ecx
f01055bf:	89 f0                	mov    %esi,%eax
f01055c1:	f7 f1                	div    %ecx
f01055c3:	e9 31 ff ff ff       	jmp    f01054f9 <__umoddi3+0x29>
f01055c8:	90                   	nop
f01055c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01055d0:	39 dd                	cmp    %ebx,%ebp
f01055d2:	72 08                	jb     f01055dc <__umoddi3+0x10c>
f01055d4:	39 f7                	cmp    %esi,%edi
f01055d6:	0f 87 21 ff ff ff    	ja     f01054fd <__umoddi3+0x2d>
f01055dc:	89 da                	mov    %ebx,%edx
f01055de:	89 f0                	mov    %esi,%eax
f01055e0:	29 f8                	sub    %edi,%eax
f01055e2:	19 ea                	sbb    %ebp,%edx
f01055e4:	e9 14 ff ff ff       	jmp    f01054fd <__umoddi3+0x2d>
