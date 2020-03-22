/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	// 加入对应用户地址空间的检查[s, s+len)
	user_mem_assert(curenv, s, len, PTE_U);

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	// 用env_alloc()创建一个新环境，设定运行状态为ENV_NOT_RUNNABLE，并拷贝父进程寄存器的值，返回子进程号
	struct Env *NewEnv;
	int32_t Ret = env_alloc(&NewEnv, curenv->env_id);
	if(Ret < 0){ //创建环境失败返回错误原因
		return Ret;
	}
	NewEnv->env_status = ENV_NOT_RUNNABLE; //设定运行状态
	NewEnv->env_tf = curenv->env_tf; //拷贝当前寄存器的值
	NewEnv->env_tf.tf_regs.reg_eax = 0; //EAX寄存器设置为0，使得子进程返回0
	return NewEnv->env_id; //函数返回新进程的进程号
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	// 设置环境（进程）的状态，返回0表示成功，否则返回错误
	// 运用envid2env函数去用环境id获得Env结构，我们需要将其第三个参数设置为1，去检验当前环境是否有权限去设置状态
	struct Env *env; //当前环境结构
	if(status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE){ //设置参数必须是这两个值，否则返回错误
		return -E_INVAL; // 返回status不合法
	}
	if(envid2env(envid, &env, 1) < 0){ //如果当前id对应的环境不存在或者没有权限去修改status
		return -E_BAD_ENV; //返回对应错误
	}
	env->env_status = status; //设置对应环境的的status
	return 0; //返回修改正确
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// 完成当前进程的页错误调度处理，将env_pgfault_upcall设置为fuc函数，若成功返回0，否则返回错误信息
	struct Env *env;
	if(envid2env(envid, &env, 1) < 0){ //当前id对应环境不存在或者没有修改权限，返回错误
		return -E_BAD_ENV;
	}
	env->env_pgfault_upcall = func; //调用错误处理函数func
	return 0;
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// 分配一个物理页，映射到虚拟地址va上去（对应envid的位置）,并插入页表
	// 其中页表的内容设置为0，如果返回0代表成功，小于0返回具体错误
	struct Env *env; //当前环境（进程）
	if(envid2env(envid, &env, 1) < 0){ //如果当前id对应的环境不存在或者没有权限去修改status
		return -E_BAD_ENV; //返回对应错误
	}
	if((uintptr_t)va >= UTOP || PGOFF(va)){ //如果va的地址大于UTOP或者va没有页面对齐
		return -E_INVAL;
	}
	if((~perm & (PTE_U | PTE_P)) != 0){ //PTE_U | PTE_P是必要的参数，若没有则报错
		return -E_INVAL;
	}
	if((perm & (~ (PTE_U | PTE_P | PTE_AVAIL | PTE_W))) != 0) { //PTE_AVAIL | PTE_W是可选参数,除上述四种如果还有其他参数报错
		return -E_INVAL;
	}
	struct PageInfo *pp = page_alloc(ALLOC_ZERO); //内容为0
	if(!pp){ //如果页面没有创建成功
		return -E_NO_MEM;
	}
	int Ret = page_insert(env->env_pgdir, pp, va, perm); //插入页面
	if(Ret < 0){ //插入失败
		return -E_NO_MEM;
	}
	return 0; //返回分配成功
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// 将‘srcva’地址对应的页（不拷贝页面内容），映射到目标进程的虚拟地址'dstva'上，成功返回0，小于0返回失败原因
	// 技巧：这里结构和sys_page_alloc一致，只不过这里有两个页面都要进行对应判断，将一个页面的相应判断改为两个页面即可
	struct Env *srcenv, *dstenv; //源进程和目标进程结构
	struct PageInfo *srcpp; //源页面
	pte_t *pte;

	// 前两个判断条件改写为判断双环境情况
	if(envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1) < 0){
		return -E_BAD_ENV;  //如果srcenvid或dstenvid对应的环境不存在或者没有权限去修改status
	}
	if((uintptr_t)srcva >= UTOP || PGOFF(srcva) || (uintptr_t)dstva >= UTOP || PGOFF(dstva)){
		return -E_INVAL;  //如果srcva/dstva的地址大于等于UTOP或者srcva/dstva没有页面对齐
	}

	// 该函数新加的判定条件
	srcpp = page_lookup(srcenv->env_pgdir, srcva, &pte); //查找源进程页面
	if(!srcpp){
		return -E_INVAL; //如果srcva没有被映射到srcenvid的地址空间，返回错误
	}
	if((perm & PTE_W) && ((*pte & PTE_W) == 0)){
		return -E_INVAL; //如果perm & PTE_W返回错误，而srcva在srcenvid的地址空间内是只可读的
	}

	// 下面两个关于perm的判断条件保持不懂
	if((~perm & (PTE_U | PTE_P)) != 0){
		return -E_INVAL; //PTE_U | PTE_P是必要的参数，若没有则报错
	}
	if((perm & (~ (PTE_U | PTE_P | PTE_AVAIL | PTE_W))) != 0) {
		return -E_INVAL; //PTE_AVAIL | PTE_W是可选参数,除上述四种如果还有其他参数报错
	}

	// 目标地址插入源页面
	int Ret = page_insert(dstenv->env_pgdir, srcpp, dstva, perm); //在目标处插入源页面
	if(Ret < 0){ //插入失败
		return -E_NO_MEM;
	}
	return 0; //返回分配成功
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// 解除虚地址va（对应envid的地址空间）的映射，返回0表示接触成功，小于0返回错误信息
	struct Env *env;
	if(envid2env(envid, &env, 1) < 0){
		return -E_BAD_ENV; //如果当前id对应的环境不存在或者没有权限去修改status，返回错误
	}
	if((uintptr_t)va >= UTOP || PGOFF(va)){
		return -E_INVAL; //如果地址大于UTOP或者页面没有对齐，返回错误信息
	}
	page_remove(env->env_pgdir, va); //删除对应的映射
	return 0;
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	// 进程通信发送函数，将‘value’发送给envid，返回0代表成功，小于0返回错误
	envid_t srcid = sys_getenvid();
	struct Env *dst_env;
	pte_t *pte; //当前页表入口
	struct PageInfo *pp; //当前页表结构
	int r = envid2env(envid, &dst_env, 0); //因为这里不需要检查权限，所以最后一个参数是0
	if(r < 0){
		return -E_BAD_ENV; //目标进程不存在的情况，返回错误
	}
	if(dst_env->env_ipc_recving == false){
		return -E_IPC_NOT_RECV; //目标进程不处于接受状态，返回错误
	}
	// if(srcva < (void *)UTOP && PGOFF(srcva)){
	// 	return -E_INVAL; //源虚拟地址小于UTOP但是每对齐的情况，返回错误
	// }
	if(srcva < (void *)UTOP){ //perm不合适的情况，直接搬用sys_page_alloc的代码
		if((~perm & (PTE_U | PTE_P)) != 0){
			return -E_INVAL; //PTE_U | PTE_P是必要的参数，若没有则报错
		}
		if((perm & (~ (PTE_U | PTE_P | PTE_AVAIL | PTE_W))) != 0) {
			return -E_INVAL; //PTE_AVAIL | PTE_W是可选参数,除上述四种如果还有其他参数报错
		}
	}

	//在srcva查找当前页表
	pp = page_lookup(curenv->env_pgdir, srcva, &pte);
	if(srcva < (void *)UTOP && pp == NULL){
		return -E_INVAL; //如果源地址小于UTOP但是没在源地址找到映射过去的页面，返回错误
	}
	if(srcva < (void *)UTOP && ((perm & PTE_W) && (*pte & PTE_W) == 0)){ 
		return -E_INVAL; //源地址小于UTOP但srcva在当前环境是只可读的，返回错误
	}
	if(srcva < (void *)UTOP){
		//否则，将页面映射到目标的地址空间
		r = page_insert(dst_env->env_pgdir, pp, dst_env->env_ipc_dstva, perm);
		if(r < 0){
			return -E_NO_MEM; //没有足够的空间映射到目标的地址空间，返回错误
		}
		dst_env->env_ipc_perm = perm; //在页面已经转移的情况下，设置目标页面的perm
	}

	//发送成功的情况，更新目标环境参数
	dst_env->env_ipc_recving = 0; //目标环境的接收标记置0
	dst_env->env_ipc_from = srcid; //目标环境对应的发送环境对应本进程
	dst_env->env_ipc_value = value; //设置value
	dst_env->env_tf.tf_regs.reg_eax = 0; //从sysycall返回，将eax设置为0
	dst_env->env_status = ENV_RUNNABLE; //就绪状态
	return 0;
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// 进程通信接收函数，进程挂起直到接收到了value，返回0代表成功，小于0返回失败
	envid_t dstid = sys_getenvid();
	if(dstva < (void *)UTOP && PGOFF(dstva)){
		return -E_INVAL; //当目标地址小于UTOP或者页面不对齐的时候返回错误
	}
	if((uint32_t)dstva >= UTOP){
		curenv->env_ipc_dstva = (void *)UTOP; //地址无效的时候发送无效页面
	}
	else{
		curenv->env_ipc_dstva = dstva; //地址有效，设置目标地址
	}

	// 设置环境
	curenv->env_ipc_recving = true; //接收状态
	curenv->env_status = ENV_NOT_RUNNABLE; //本进程挂起
	sys_yield();
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t SysRet = 0; //定义返回值
	switch(syscallno){
		case SYS_cputs: //将长度为len的的字符串输出到终端上
			sys_cputs((const char *) a1, (size_t)a2);
			break;
		case SYS_cgetc: //从终端读取一个字符
			SysRet = sys_cgetc();
			break;
		case SYS_getenvid: //获得一个进程id
			SysRet = sys_getenvid();
			break;
		case SYS_env_destroy: //destroy掉一个继承，返回0代表成功，小于0代表失败
			SysRet = sys_env_destroy((envid_t) a1);
			break;
		case SYS_yield: //lab4添加系统调用，选择一个就绪的环境并运行它
			sys_yield();
			break;
		case SYS_exofork: //创建一个新的进程
			SysRet = sys_exofork();
			break;
		case SYS_env_set_status: //设定进程运行状态
			SysRet = sys_env_set_status((envid_t)a1, (int)a2);
			break;
		case SYS_page_alloc: //为新进程分配一个物理页
			SysRet = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
			break;
		case SYS_page_map: //映射物理页到目标程序地址
			SysRet = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
			break;
		case SYS_page_unmap: //解除虚地址va（对应envid的地址空间）的映射
			SysRet = sys_page_unmap((envid_t)a1, (void *)a2);
			break;
		case SYS_env_set_pgfault_upcall: //进程页错误调度处理函数
			SysRet = sys_env_set_pgfault_upcall(a1, (void*)a2);
			break;
		case SYS_ipc_try_send: //进程发送
			SysRet = sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
			break;
		case SYS_ipc_recv: //进程接收
			SysRet = sys_ipc_recv((void *)a1);
			break;
		default:
			return -E_INVAL;
	}
	return SysRet;
}