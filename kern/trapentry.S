/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*以上两个宏功能分别是：
	1.第一个是接受一个函数名和对应的中断向量编号，定义出一个相应的中断处理程序。
	所以得知中断向量程序的执行过程就是向堆栈中压入错误码和中断号，跳转到_alltraps执行共有部分
	2.并不是每一次中断都会放入错误码，没有错误码的时候我们就要用0来补齐，这也就是第二个宏的作用
*/

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	# 需要处理的中断详细可见/inc/trap.h
	# 关于是否有错误码，可以看实验指导的pdf
	TRAPHANDLER_NOEC(trap_divide, T_DIVIDE)
	TRAPHANDLER_NOEC(trap_debug, T_DEBUG)
	TRAPHANDLER_NOEC(trap_nmi, T_NMI)
	TRAPHANDLER_NOEC(trap_brkpt, T_BRKPT)
	TRAPHANDLER_NOEC(trap_oflow, T_OFLOW)
	TRAPHANDLER_NOEC(trap_bound, T_BOUND)
	TRAPHANDLER_NOEC(trap_illop, T_ILLOP)
	TRAPHANDLER_NOEC(trap_device, T_DEVICE)
	TRAPHANDLER(trap_dblflt, T_DBLFLT)
	# TRAPHANDLER_NOEC(trap_coproc, T_COPROC) /* reserved */
	TRAPHANDLER(trap_tss, T_TSS)
	TRAPHANDLER(trap_segnp, T_SEGNP)
	TRAPHANDLER(trap_stack, T_STACK)
	TRAPHANDLER(trap_gpflt, T_GPFLT)
	TRAPHANDLER(trap_pgflt, T_PGFLT)
	# TRAPHANDLER_NOEC(trap_res, T_RES)  /* reserved */
	TRAPHANDLER_NOEC(trap_fperr, T_FPERR)
	TRAPHANDLER(trap_align, T_ALIGN)
	TRAPHANDLER_NOEC(trap_mchk, T_MCHK)
	TRAPHANDLER_NOEC(trap_simderr, T_SIMDERR)

	TRAPHANDLER_NOEC(trap_syscall, T_SYSCALL) /*B部分系统调用*/

	# 外部中断IRQ，由于IRQ的编号有一个IRQ_OFFSET，所以编号为IRQ_OFFSET  +IRQ_WHATEVER
	TRAPHANDLER_NOEC(trap_timer, IRQ_OFFSET + IRQ_TIMER)
	TRAPHANDLER_NOEC(trap_kbd, IRQ_OFFSET + IRQ_KBD)
	TRAPHANDLER_NOEC(trap_serial, IRQ_OFFSET + IRQ_SERIAL)
	TRAPHANDLER_NOEC(trap_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
	TRAPHANDLER_NOEC(trap_ide, IRQ_OFFSET + IRQ_IDE)
	TRAPHANDLER_NOEC(trap_error, IRQ_OFFSET + IRQ_ERROR)

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	# 将错误码和中断号压入堆栈，如果没有错误码则压入一个0保证和TrapFrame的对齐
	# 调用pushal压入当前的寄存器的值进行保存
	pushl %ds
	pushl %es
	pushal

	# 将GD_KD读入%ds和%es
	movl $GD_KD, %eax
	movw %ax, %ds
	movw %ax, %es

	# 将指向trapframe的函数的指针作为argument的参数传递
	pushl %esp
	# 调用trap函数
	call trap 




