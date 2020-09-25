#ifndef __KUIPER_ASM_i386_THREAD_INFO_H_INCLUDED__
#define __KUIPER_ASM_i386_THREAD_INFO_H_INCLUDED__

#include <kuiper/kernel.h>

struct task_struct;

struct thread_info
{
    unsigned long flags;
    struct  task_struct *task;
    int preempt_count;
    int cpu;
};

static __always_inline__ struct thread_info *current_thread_info()
{
    struct thread_info *p_thread_info;;
    __volatile__ __asm__("andl %%esp, %0; ":"=r" (pThreadInfo):"0" (~(THREAD_SIZE - 1)));
    return p_thread_info;
};


#endif