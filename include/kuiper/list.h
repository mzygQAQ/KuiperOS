#ifndef _KUIPER_LIST_H_INCLUDED
#define _KUIPER_LIST_H_INCLUDED

#include <kuiper/kernel.h>

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
	struct list_head *prev;
};

#define LIST_HEAD_INIT(name) {&(name),&(name)}

#define LIST_HEAD(name)	\
		struct list_head name = LIST_HEAD_INIT(name)

#define INIT_LIST_HEAD(ptr) do { \
		(ptr)->next = (ptr);     \
	    (ptr)->prev = (ptr);     \
	    } while(0)


static __inline__ void __list_add(struct list_head *new_ele,
				 struct list_head *prev,
				 struct list_head *next)
{
	next->prev      = new_ele;
	new_ele->next   = next;
	new_ele->prev   = prev;
	prev->next      = new_ele;
}

static __inline__ void list_add(struct list_head *new_ele, struct list_head *head)
{
    __list_add(new_ele, head, head->next);
}

static __inline__ void list_add_tail(struct list_head *new_ele, struct list_head* head)
{
    __list_add(new_ele, head->prev, head);
}

static __inline__ bool list_is_empty(struct list_head *head)
{
    return head == head->next;
}

static __inline__ void __list_del(struct list_head *prev, struct list_head *next)
{
    next->prev = prev;
    prev->next = next;
}

static __inline__ void list_del(struct list_head *entry)
{
    __list_del(entry->prev, entry->next);
}

static __inline__ void list_del_init(struct list_head *entry)
{
    __list_del(entry->prev, entry->next);
    INIT_LIST_HEAD(entry);
}

#define list_entry(ptr, type, member) \
    container_of(ptr,type,member)

#define list_foreach(pos, head) \
    for(pos = (head)->next; pos != (head); pos=pos->next)


#endif
