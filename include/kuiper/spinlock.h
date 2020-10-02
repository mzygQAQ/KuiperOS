#ifndef __KUIPER_SPIN_LOCK_H__
#define __KUIPER_SPIN_LOCK_H__

/**
 * KuiperOS暂时不支持多核心CPU
 * 这里只提供了单核的实现，且针对不同的调试级别作了不同实现.
 * 
 * 单核CPU+内核不支持抢占的情况下，自旋锁可以为空的.
 * 单核CPU+内核支持抢占的情况下， 自选锁需要关闭内核抢占.
 * 
 * 这里的spinlock_t只能在内核态使用.
 * 用户态的自旋锁，在单核CPUs上的实现不可能是空的!
 * 
 * 这里可能有一个疑惑,单核CPU上自旋锁为空的，假设这种场景:
 * A进程获取了自旋锁(空实现),然后处于临界区,但是时钟中断发生了，进行发生了切换
 * B进程获取到了CPU,此时再获取锁(空实现)，导致AB同时处于临界区造成安全问题.
 * 如果B这里需要自旋不为空而是循环检测等待,但是只有A释放锁才能B拿到锁,但是CPU
 * 只有一个，这样的话B一直自旋,直到时钟中断再次发生切换到A，A释放锁，这种情况
 * CPU大大的被浪费了?
 * 其实为了解决这个问题，时钟中断发生时, 并不会立即调用schedule()，只有当前处于用户态且
 * 时间片用完的时候才会调用schedule的, 内核态运行时不能调用schedule()。
 * 
 * 也就是说linux的内核抢占是完全针对内核态的情况下~
 * 
 */


#ifdef SMP_SUPPORT

#error "ERROR: KuiperOS暂时不支持多核心CPU!!!"

#else /* UP */

#include <kuiper/kernel.h>

#define SPIN_LOCK_DEBUG_LEVEL 0

#if SPIN_LOCK_DEBUG_LEVEL < 2

typedef struct {
    volatile u32_t lock;
} spinlock_t;

#define SPIN_LOCK_UNLOCKED   (spin_lock_t) {0}
#define spinlock_init(x)     do{ (x)->lock = 0; }while(0)
#define spinlock_lock(x)     do{ (x)->lock = 1; }while(0)
#define spinlock_unlock(x)   do{ (x)->lock = 0; }while(0)

#else /* SPIN_LOCK_DEBUG_LEVEL > 2 */

typedef struct {
	volatile unsigned long lock;
	volatile unsigned int babble;
	const char *module;
} spinlock_t;

#endif



#endif /* end of SMP_SUPPORT */
#endif /* end of __KUIPER_SPIN_LOCK_H__ */