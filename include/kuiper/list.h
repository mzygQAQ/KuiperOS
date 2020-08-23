#ifndef _KUIPER_LIST_H_INCLUDED
#define _KUIPER_LIST_H_INCLUDED

#include "kernel.h"

/**
 * 简单的双向链表实现.
 *
 * 本实现参考了Linux内核链表的实现,传统的链表通常由一个结构中定义数据
 * 和前驱节点和后续节点,在C语言中没有模板，要想一个链表定义可以达到通
 * 用，只能将数据节点定义成`void*`,这意味着使用这个链表时需要经常类型
 * 转换,使用者也必须明确类型，否则会导致灾难性的内存错误。
 *
 * 这里采用了Linux内核链表的实现方式,让数据去包含链表节点实现通用性,从
 * 而在内核多种场景下可以使用。
 *
 * 向祖师爷Linus Torvalds致敬!
 *
 */

struct list_head {
	struct list_head *next;
	struct list_head_*prev;
};

static inline void list_add(struct list_head *new, struct list_head *head)
{

}



#endif
