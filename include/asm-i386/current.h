#ifndef __KUIPER_ASM_I386_CURRENT_H_INCLUDED__
#define __KUIPER_ASM_I386_CURRENT_H_INCLUDED__

#include <asm-i386/thread_info.h>

struct task_struct;

static inline struct task_struct *get_current(void)
{
    return current_thread_info()->task;
};

#define current get_current()




#endif