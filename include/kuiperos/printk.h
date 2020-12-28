#ifndef __KUIPER_PRINTK_H_INCLUDED__
#define __KUIPER_PRINTK_H_INCLUDED__

#define VGA_TEXT_MODE_MAX_ROW 25
#define VGA_TEXT_MODE_MAX_COL 80

#define MAX_ROW VGA_TEXT_MODE_MAX_ROW
#define MAX_COL VGA_TEXT_MODE_MAX_COL

extern volatile int posRow__;
extern volatile int posCol__;

void print_char(char x);
void print_int(int x);
void print_int_hex(int x);
void print_newline();
void clear_screen();
void scoll_screen(int x);

int printk(const char *fmt, ...);

#ifndef KERN_PRINTK_LEVELS
#define KERN_PRINTK_LEVELS
#define KERN_EMERG    "<0>"
#define KERN_ALERT    "<1>"
#define KERN_CRIT     "<2>"
#define KERN_ERR      "<3>"
#define KERN_WARNING  "<4>"
#define KERN_NOTICE   "<5>"
#define KERN_INFO     "<6>"
#define KERN_DEBUG    "<7>"
#endif


#endif