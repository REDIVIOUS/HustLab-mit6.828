// User-level page fault handler support.
// Rather than register the C page fault handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in pfentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language pgfault entrypoint defined in lib/pfentry.S.
extern void _pgfault_upcall(void);

// Pointer to currently installed C-language pgfault handler.
void (*_pgfault_handler)(struct UTrapframe *utf);

//
// Set the page fault handler function.
// If there isn't one yet, _pgfault_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
	int r;

	if (_pgfault_handler == 0) {
		// First time through!
		// LAB 4: Your code here.
		// 设置页面错误处理函数
		envid_t id = thisenv->env_id;
		// 第一次执行的时候需要申请一个存放错误的栈，从UXSTACKTOP往下一个页面大小
		r = sys_page_alloc(id, (void *)(UXSTACKTOP - PGSIZE), (PTE_U | PTE_P | PTE_W));
		if(r < 0){
			panic("set page fault handler fails.");
		}
		// 当页面错误发生时执行_pgfault_upcall
		r = sys_env_set_pgfault_upcall(id, _pgfault_upcall);
		if (r < 0){
			panic("page fault upcall fails, %e",r);
		}
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
}