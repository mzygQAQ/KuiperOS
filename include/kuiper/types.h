#ifndef _KUIPER_TYPES_H_INCLUDED_
#define _KUIPER_TYPES_H_INCLUDED_

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif /* __cplusplus */
#endif /* __cplusplus */

#ifndef NULL
#define NULL ((void *)0)
#endif

// x86_32: sizeof(long) = 4   sizeof(long long) = 8
// x86_64: sizeof(long) = 8   sizeof(long long) = 8

typedef long unsigned int    size_t;
typedef int                  ptrdiff_t;
typedef int                  pid_t;
typedef long                 time_t;

typedef unsigned char        u8_t;
typedef unsigned short       u16_t;
typedef unsigned int         u32_t;
typedef unsigned long long   u64_t;

typedef signed char          i8_t;
typedef signed short         i16_t;
typedef signed int           i32_t;
typedef signed long long     i64_t;

#ifndef __bool_true_false_are_defined
#define __bool_true_false_are_defined
// typedef int bool;
typedef int BOOL;
#define TRUE  1
#define FALSE 0
#endif


#ifdef __cplusplus
#if __cplusplus
}
#endif /* __cplusplus */
#endif /* __cplusplus */

#endif /* _KUIPER_TYPES_H_INCLUDED_ */
