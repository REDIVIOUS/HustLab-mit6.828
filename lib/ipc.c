// User-level IPC library routines

#include <inc/lib.h>

// Receive a value via IPC and return it.
// If 'pg' is nonnull, then any page sent by the sender will be mapped at
//	that address.
// If 'from_env_store' is nonnull, then store the IPC sender's envid in
//	*from_env_store.
// If 'perm_store' is nonnull, then store the IPC sender's page permission
//	in *perm_store (this is nonzero iff a page was successfully
//	transferred to 'pg').
// If the system call fails, then store 0 in *fromenv and *perm (if
//	they're nonnull) and return the error.
// Otherwise, return the value sent by the sender
//
// Hint:
//   Use 'thisenv' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
	// LAB 4: Your code here.
	// 用户态下的接受函数，接收IPC传入的value并返回它(如果错误返回相应错误)
	int r;
	if(pg != NULL){ //如果pg不是空的，就在pg的地址映射发送页面
		r = sys_ipc_recv(pg);
	}
	else{ //否则map的位置就为UTOP（这里要选一个invalid的位置去map）
		r = sys_ipc_recv((void *)UTOP);
	}
	if(from_env_store != NULL){
		if(r >= 0){ //系统发送成功
			*from_env_store = thisenv->env_ipc_from; //存入源进程号
		}
		else{
			*from_env_store = 0; //存入0
		}
	}
	if(perm_store != NULL){
		if(r >= 0){ //系统发送成功
			*perm_store = thisenv->env_ipc_perm; //存入权限位
		}
		else{
			*perm_store = 0;
		}
	}
	if(r < 0){ //系统发送失败
		return r; //返回错误
	}
	else{
		return thisenv->env_ipc_value;
	}
}

// Send 'val' (and 'pg' with 'perm', if 'pg' is nonnull) to 'toenv'.
// This function keeps trying until it succeeds.
// It should panic() on any error other than -E_IPC_NOT_RECV.
//
// Hint:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	// 用户态的的发送函数，通过系统调用sys_ipc_try_send实现
	int r;
	if(pg == NULL){ //若pg为空就传入UTOP参数（传入一个对于映射页面invalid的地址）
		pg = (void *)UTOP;
	}
	while(1){
		r = sys_ipc_try_send(to_env, val, pg, perm);
		if(r < 0 && r != -E_IPC_NOT_RECV){
			panic("send fails."); //当系统发送报错的时候panic（除了-E_IPC_NOT_RECV的情况）
		}
		else if(r == -E_IPC_NOT_RECV){
			sys_yield(); //发送成功但对方没有接收到的情况，一直等待接收
		}
		else{
			break; //接收成功，结束程序
		}
	}
}

// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
