#ifndef __ASM_I386_SYSTEM_H__
#define __ASM_I386_SYSTEM_H__

/*
 * The code implementation here refers to the Linux kernel to a 
 * certaion extent, and the copyright belongs to the original author.
 */

#define nop() __asm__ __volatile__ ("nop")

/* 单CPU只需要考虑编译优化导致的内存屏障, 多CPU或者多核心CPU还需要考虑CPU级别的指令乱序 */

#ifdef __GNUC__ 
#define barrier()	__asm__ __volatile__("" ::: "memory")
#else
#error gcc compiler required.
#endif

#define mb() 		barrier()
#define rmb()		barrier()
#define wmb()		barrier()

#ifdef CONFIG_SMP
#define smp_mb() 	mb()
#define smp_rmb() 	rmb()
#define smp_wmb()	wmb()
#define mb_set_val(var, value)  do{ var=value; barrier(); } while(0)
#else
#define smp_mb()	barrier()
#define smp_rmb()	barrier()
#define smp_wmb()	barrier()
#define mb_set_val(var, value)  do{ var=value;barrier(); } while(0)
#endif


#endif
