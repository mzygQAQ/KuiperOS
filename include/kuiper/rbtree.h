#ifndef _KUIPER_RBTREE_H_INCLUDED_
#define _KUIPER_RBTREE_H_INCLUDED_

#include <kuiper/kernel.h>

/**
 * 内核使用的红黑树的实现. TODO
 *
 */

#define	RB_COLOR_RED		0
#define	RB_COLOR_BLACK  	1

struct rb_node {
    unsigned long rb_parent_color;
    struct rb_node *rb_left;
    struct rb_node *rb_right;
} __attribute__((aligned(sizeof(long))));       /* 字节对齐 */

struct rb_root {
    struct rb_node *rb_node;
};

#define rb_color(rn)        ((r)->rb_parent_color & 1)
#define rb_is_black(rn)     rb_color(rn)
#define rb_is_red(rn)       (!rb_color(rn))

#endif