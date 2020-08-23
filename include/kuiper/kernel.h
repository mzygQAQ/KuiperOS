#ifndef _KUIPER_KERNEL_H_INCLUDED_
#define _KUIPER_KERNEL_H_INCLUDED_

#include "types.h"

#define offsetof(type,member) ((size_t)&(((type*)0)->member))

#define container_of(ptr, type, member) ({ \
     const typeof( ((type *)0)->member ) *__mptr = (ptr); \
     (type *)( (char *)__mptr - offsetof(type,member) );})  

#endif
