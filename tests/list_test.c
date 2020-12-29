#include "../include/kuiperos/list.h"


#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// gcc list_test.c -o app -I../include

extern void list_add_test();

int main(int argc, char **argv)
{
	list_add_test();	

	return 0;
}

typedef struct student {
    unsigned int id;
    char name[64];
    unsigned char age;
    struct list_head head;
} student_t;



void list_add_test()
{
	student_t *zs = (student_t *)malloc(sizeof(struct student));
	zs->id = 1;
	zs->age = 18;
	strcpy(zs->name, "zhangsan");
	zs->name[63] = 0;

    student_t *ls = (student_t *)malloc(sizeof(struct student));
    ls->id = 2;
    ls->age = 19;
    strcpy(ls->name, "lisi");
    ls->name[63] = 0;

    student_t *ww = (student_t *)malloc(sizeof(struct student));
    ww->id = 3;
    ww->age = 20;
    strcpy(ww->name, "wangwu");
    ww->name[63] = 0;

    LIST_HEAD(stuList);

    list_add(&zs->head, &stuList);
    list_add(&ls->head, &stuList);
    list_add(&ww->head, &stuList);

    struct list_head *tmp = NULL;
    struct student *stu = NULL;

    list_foreach(tmp, &stuList) {
        stu = list_entry(tmp, struct student, head);
        printf("%d, %d, %s \n", stu->id, stu->age, stu->name);
    }

    printf("after del ls ----------------------- \n");

    list_del(&ls->head);
    list_foreach(tmp, &stuList) {
        stu = list_entry(tmp, struct student, head);
        printf("%d, %d, %s \n", stu->id, stu->age, stu->name);
    }
}
