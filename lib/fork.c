// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查错误的页面，是否是可写的或者COW页面
	if((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0){
		panic("The page is not a write, or to copy-on-write page.");
	}

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 申请一个新的页面，将它映射到PFTEMP，将旧页面的数据拷贝到新页面上去，然后将新页面移动到旧页面的地址上
	envid_t id = sys_getenvid();

	//申请一个新页面到PFTEMP上
	r = sys_page_alloc(id, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
	if(r < 0){ //在PFTEMP申请页面失败的情况
		panic("page allocation fails.");
	}

	//将旧页面（addr）上的数据copy到新页面（PFTEMP）上
	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);

	//取消addr处的虚拟空间（旧页面）与环境id的映射
	r = sys_page_unmap(id, ROUNDDOWN(addr, PGSIZE));
	if(r < 0){ //addr处与环境id解除页面映射失败的情况
		panic("addr page and id ummap fails.");
	}

	//PFTEMP处页面映射到addr处，环境为id
	r = sys_page_map(id, PFTEMP, id, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W);
	if(r < 0){ //没有成功将PFTEMP映射回addr的情况
		panic("PFTEMP map back to addr fails.");
	}

	//将环境id与临时空间PFTEMP解除映射
	r = sys_page_unmap(id, PFTEMP);
	if(r < 0){ //没有成功将PFTEMP对应页面和环境id解除映射的情况
		panic("PFTEMP page and id unmap fails.");
	}
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	// 函数是将当前进程的第pn页映射到envid的第pn页上去，并且将这一页标置为COW
	// 如果页面本身是可写的或者COW的，新建立的映射一定要是COW的。
	// 函数返回0则代表成功，小于0代表失败
	void *addr = (void *)((uint32_t)(pn * PGSIZE)); //当前pn页的地址
	int perm = PTE_P | PTE_U;
	pte_t pte = uvpt[pn];
	envid_t id = sys_getenvid();//当前进程号

	//若当前进程的权限是可写或者COW，则新建立的映射一定有COW权限
	if((pte & PTE_W) > 0 || (pte & PTE_COW) > 0){
		perm |= PTE_COW;
	}
	//将当前pn页映射到envid的pn页上去（同一位置）
	r = sys_page_map(id, addr, envid, addr, perm);
	if(r < 0){ //映射失败情况
		panic("page mapping to evnid's pn fails.");
		return r;
	}
	//映射父进程
	if(perm & PTE_COW){
		r = sys_page_map(id, addr, id, addr, perm);
		if(r < 0){
			panic("page mapping to itself (id) fails.");
			return r;
		}
	}
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	// 实现copy-on-write fork
	// 将当前进程（父进程）的地址空间和页面错误处理程序拷贝给子进程，将子进程设置为就绪并返回
	// 父进程返回子进程的envid，子进程返回0，返回小于0代表错误

	//为父进程设置页面错误处理函数以及错误处理堆栈
	set_pgfault_handler(pgfault);
	//创建子进程
	envid_t child_id = sys_exofork();
	if(child_id < 0){ //若fork失败
		panic("folk fails.");
	} 
	else if(child_id == 0){ //若当前是子进程
		thisenv = &envs[ENVX(sys_getenvid())]; //当前进程设置为子进程
		return 0; //子进程返回0
	}

	//以下均为在父进程完成的操作
	//首先将父进程中权限为PTE_P全部映射到子进程
	int pn;
	for(pn = PGNUM(UTEXT); pn < PGNUM(UXSTACKTOP - PGSIZE); pn++){
		if((uvpd[pn >> 10] & PTE_P) &&  (uvpt[pn] & PTE_P)){
			duppage(child_id, pn);
		}
	}
	
	//错误栈的拷贝
	int r;
	// 申请新的一个物理页。映射到子进程的UXSTACKTOP - PGSIZE位置
	r = sys_page_alloc(child_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U);
	if(r < 0){ //映射失败情况
		panic("page mapping child_id fails.");
		return r;
	}
	// 将父进程（PFTEMP）映射到子进程的新物理页上去，使得父进程可以访问那一页
	r = sys_page_map(child_id, (void *)(UXSTACKTOP - PGSIZE), sys_getenvid(), PFTEMP, PTE_P | PTE_W | PTE_U);
	if(r < 0){ //映射失败情况
		panic("father_env mapping to PFTEMP fails.");
		return r;
	}
	//将父进程错误栈的内容全部拷贝到子进程错误栈上去
	memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
	//将父进程和PFTEMP的映射取消
	r = sys_page_unmap(sys_getenvid(), PFTEMP);
	if(r < 0){ //未能取消该映射
		panic("unmap father_env and PFTEMP fails.");
		return r;
	}

	//设置当前页面错误处理函数
	extern  void _pgfault_upcall(void); //页面调度处理函数
	r = sys_env_set_pgfault_upcall(child_id, _pgfault_upcall);
	if(r < 0){ //设置失败
		panic("Set _pgfault_upcall fails.");
	}

	//子进程设置为就绪状态
	r = sys_env_set_status(child_id, ENV_RUNNABLE);
	if(r < 0){
		panic("set status fails.");
	}
	return child_id;
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
