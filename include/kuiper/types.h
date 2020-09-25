/*
 * Copyright (c) 2020 KuiperOS Developers
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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


#ifdef __cplusplus
#if __cplusplus
}
#endif /* __cplusplus */
#endif /* __cplusplus */

#endif /* _KUIPER_TYPES_H_INCLUDED_ */
