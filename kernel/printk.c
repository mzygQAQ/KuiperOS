#include <kuiper/printk.h>

volatile int posRow__;
volatile int posCol__;

void print_char(char x)
{
    // TODO.
    if (posCol__ < MAX_COL - 1)
    {
        posCol__ += 1;
    } else {
        posCol__ = 0;
        posRow__ += 1;
    }
}

void print_int(int x)
{
    // FIX ME
}

void print_int_hex(int x)
{
    // FIX ME
}

void print_newline()
{
    posCol__ = 0;
    if (posRow__ == (MAX_ROW - 1))
       scoll_screen(1);
    else
        posRow__ += 1;
}

void clear_screen()
{
    for (int i = 0; i < MAX_ROW; i++)
    {
        for (int j = 0; i < MAX_COL; j++)
        {
            // FIX ME
        }
    }
}

int printk(const char *fmt, ...)
{
    // FIX ME
}