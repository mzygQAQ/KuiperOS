#ifndef __KUIPER_BSTREE_H_INCLUDED__
#define __KUIPER_BSTREE_H_INCLUDED__

#include <kuiperos/kernel.h>

/**
 * 简单的二叉树实现.
 * 非平衡且很可能畸形成链表导致时间复杂度为O(n)
 * 建议使用rbtree.h
 */

typedef struct bstree_s bstree_t;

struct bstree_node {
  struct bstree_node *father;
  struct bstree_node *left;
  struct bstree_node *right;
};

typedef signed int (*bst_comparator_t)(struct bstree_node *lhs,
                                       struct bstree_node *rhs);

struct bstree_s {
  bstree_node *root;
  unsigned int size;
  bst_comparator_t comp;
};

#define BST_ROOT_INIT(n)                                                       \
  ({                                                                           \
    n->father = NULL;                                                          \
    n->left = NULL;                                                            \
    n->right = NULL;                                                           \
    n                                                                          \
  })

#define bst_size(s) ((s)->size)
#define bst_is_empty(s) (bst_size(s))

static __inline__ void bst_init(bstree_t *s, bst_comparator_t pComp) {
  s->size = 0;
  s->root = NULL;
  s->comp = pComp;
}

static __inline__ void __bst_add(bstree_node *cur,
                                 struct bstree_node *new_ele) {
  signed int comp_ret = s->comp(cur, new_ele);
  if (comp_ret < 0) {
    // TODO
  } else if (comp_ret > 0) {
    // TODO
  } else {
    // TODO
  }
}

static __inline__ void bst_add(bstree_t *s, struct bstree_node *new_ele)

{
  if (!s->root) {
    s->root = BST_ROOT_INIT(new_ele);
    s->size += 1;
  } else {
    __bst_add(s->root, new_ele);
  }
}

#endif //__KUIPER_BSTREE_H_INCLUDED__
