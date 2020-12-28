#ifndef __KUIPER_COMPILER_H_INCLUDED__
#define __KUIPER_COMPILER_H_INCLUDED__


#include <kuiper/types.h>

/**
 * 关于编译器特性的一些代码,目前KuiperOS只支持使用GCC编译器进行编译
 * 这里使用到的绝大部分都是GCC编译器对GNU C的扩展语法，为内核开发提
 * 供便利。
 *
 * 内存屏障相关
 * 函数内联相关
 * 分支预测相关
 *
 */

#ifndef __asm__
#define __asm__ asm
#endif

#ifndef __volatile__
#define __volatile__ volatile
#endif

#ifndef __inline__
#define __inline__ inline
#endif

#ifndef __always_inline__
#define __always_inline__ inline
#endif

#define offsetof(type,member) ((size_t)&(((type*)0)->member))

#define container_of(ptr, type, member) ({ \
     const typeof( ((type *)0)->member ) *__mptr = (ptr); \
     (type *)( (char *)__mptr - offsetof(type,member) );})  


#define likely(x) __builtin_expect(!!(x), 1)
#define unlikely(x) __builtin_expect(!!(x), 0)

#define ACCESS_ONCE(x) (*(__volatile__ typeof(x))(&(x)))

#endif
