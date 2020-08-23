#ifndef _KUIPER_BSTREE_H_INCLUDED_
#define _KUIPER_BSTREE_H_INCLUDED_

#include <kuiper/kernel.h>

/**
 * 简单的二叉树实现.
 * 非平衡且很可能畸形成链表导致时间复杂度为O(n)
 * 建议使用rbtree.h
 */

struct bst_node {
    struct bst_node *father;
    struct bst_node *left;
    struct bst_node *right;
};

typedef signed int (*bst_comparator_t)(struct bst_node *lhs, struct bst_node *rhs);

struct bst_struct {
    bst_node *root;
    unsigned int size;
    bst_comparator_t comp;
};

#define BST_ROOT_INIT(n) ({ \
    n->father = NULL;       \
    n->left = NULL;         \
    n->right = NULL;        \
    })

#define bst_size(s)         ((s)->size)
#define bst_is_empty(s)     (bst_size(s))

static __inline__ void bst_init(bst_struct *s, bst_comparator_t pComp)
{
    s->size = 0;
    s->root = NULL;
    s->comp = pComp;
}

static __inline__ void __bst_add(bst_node *cur, struct bst_node *new_ele)
{
    signed int comp_ret = s->comp(cur, new_ele);
    if(comp_ret < 0) {
       // TODO
    } else if (comp_ret > 0){
       // TODO
    } else {
        // TODO
    }
}

static __inline__ void bst_add(bst_struct *s, struct bst_node *new_ele)
{
    if (!s->root) {
        s->root = BST_ROOT_INIT(new_ele);
        s->size += 1;
    } else {
        __bst_add(s->root, new_ele);
    }
}




#endif //_KUIPER_BSTREE_H_INCLUDED_
