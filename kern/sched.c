#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
	struct Env *idle;

	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	// 实现RR调度算法
	// 从上一个运行的进程开始，按照顺序在envs数组中搜索第一个就绪的的进程执行
	// 如果没有就绪的进程，但之前运行的进程仍然处于运行状态，选择之前的进程继续运行
	// 不可以选择其他CPU上运行的进程，如果没有就绪的进程等待执行，将cpu进行halt
	idle = curenv;
	int index; //当前选择进程的下标
	int i;
	// index初始化
	if(idle == NULL){
		index = -1;
	}
	else{
		index = ENVX(idle->env_id); //本进程
	}
	
	// 扫描NENV数组（全部遍历且只遍历一遍）寻找最近就绪进程
	for(i = 0; i < NENV; i++){
		index++;
		if(index == NENV){
			index = 0; //实现轮转
		}
		// 若当前进程就绪
		if(envs[index].env_status == ENV_RUNNABLE){
			env_run(&envs[index]); //运行这个进程
			return;
		}
	}

	//将数组遍历了一遍后，若本进程仍运行且无其他进程就绪，继续运行本进程
    if (idle && idle->env_status == ENV_RUNNING) {
        env_run(idle);
        return;
    }

	// sched_halt never returns
	sched_halt();
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}

