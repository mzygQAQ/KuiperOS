#ifndef __KUIPEROS_SCHED_H_INCLUDED__
#define __KUIPEROS_SCHED_H_INCLUDED__

#include <kuiperos/compiler.h>
#include <kuiperos/kernel.h>
#include <kuiperos/spinlock.h>
#include <kuiperos/types.h>

/**
 * 进程当前正在cpu上运行或者准备分配给cpu执行
 */
#define TASK_STATE_RUNNING 0

/**
 * 可以被中断的等待状态
 */
#define TASK_STATE_INTERRUPTIBLE 1

/**
 * 不可被中断的等待状态
 * 这种情况很少，但是有时也有用：比如进程打开一个设备文件，其相应的驱动程序在探测硬件设备时，就是这种状态。
 * 在探测完成前，设备驱动程序如果被中断，那么硬件设备的状态可能会处于不可预知状态。
 */
#define TASK_STATE_UNINTERRUPTIBLE 2

/**
 * 暂停状态。当收到SIGSTOP,SIGTSTP,SIGTTIN或者SIGTTOU信号后，会进入此状态。
 */
#define TASK_STATE_STOPPED 4

/**
 * 被跟踪状态。当进程被另外一个进程监控时
 */
#define TASK_STATE_TRACED 8

/**
 * 僵尸状态。进程的执行被终止，但是，父进程还没有调用完wait4和waitpid来返回有关
 * 死亡进程的信息。在此时，内核不能释放相关数据结构，因为父进程可能还需要它。
 */
#define TASK_STATE_EXIT_ZOMBIE 16

/**
 * 在父进程调用wait4后，删除前，为避免其他进程在同一进程上也执行wait4调用
 * 将其状态由EXIT_ZOMBIE转为EXIT_DEAD，即僵死撤销状态。
 */
#define TASK_STATE_EXIT_DEAD 32

struct mm_struct {};

#endif