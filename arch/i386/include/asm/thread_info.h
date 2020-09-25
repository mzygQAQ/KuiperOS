#ifndef __KUIPER_ASM_i386_THREAD_INFO_H_INCLUDED__
#define __KUIPER_ASM_i386_THREAD_INFO_H_INCLUDED__

#include <kuiper/types.h>
#include <kuiper/compiler.h>

#ifdef CONFIG_4KSTACKS
#define THREAD_SIZE     (4096)
#else
#define THREAD_SIZE     (8192)
#endif

struct task_struct;

struct thread_info
{
    unsigned long flags;
    struct  task_struct *task;     
    int preempt_count;             /* 0代表内核可以被强占,>0代表不能被强占 */
    int cpu;
};

static __always_inline__ struct thread_info *current_thread_info()
{
    struct thread_info *p_thread_info;;
    __volatile__ __asm__("andl %%esp, %0; ":"=r" (pThreadInfo):"0" (~(THREAD_SIZE - 1)));
    return p_thread_info;
};


#endif