#ifndef __KUIPER_TASK_H_INCLUDED__
#define __KUIPER_TASK_H_INCLUDED__


#include <kuiper/types.h>
#include <kuiper/list.h>
#include <kuiper/compiler.h>
#include <kuiper/spinlock.h>

#include <asm/current.h>
#include <asm/thread_info.h>




struct tss_struct
{
    /* fix me */
};



/**
 * 这里借鉴linux内核的设计,将内核栈和thread_info紧密放在一起，内核很容易通过esp寄存器的
 * 值得到当前运行进程的thread_info结构地址,从而拿到当前运行进程的task_struct指针.
 * 
 * -----------------------  high-address
 * |       data1         |  🔽
 * |       data2         |  🔽
 * |       data3         |  🔽   kernel stack direction
 * |       data4         |  🔽
 * |       data5         |  🔽
 * |       data6         |  🔽   (esp)
 * |                     |  
 * |                     |
 * |                     |  
 * |_____________________|
 * |   thread_info       |
 * |_____________________|  low-address
 * 
 * 
 * 
 * NOTE: x86_32: sizeof(long)=4   x86_64: sizeof(long)=8
 */
union thread_union
{
    struct thread_info thread_info;
    unsigned long stack[THREAD_SIZE / sizeof(long)];  /* 每个用户态进程使用的内核栈 */
};


/* task state definations: */
#define TASK_STATE_RUNNING           0
#define TASK_STATE_INTERRUPTIBLE     1
#define TASK_STATE_UNINTERRUPTIBLE   2
#define TASK_STATE_ZOMBIE            4
#define TASK_STATE_STOPPED           8


struct task_struct {
    pid_t pid;
    volatile int state;             /* TASK_STATE_XXX */
    struct list_head run_list;
    spinlock_t alloc_lock;
};

typedef struct tss_struct tss_t;
typedef struct thread_info thread_info_t;
typedef struct task_struct task_struct_t;

#endif