org 0x9000

__loader_start:
    call clean_screen


clean_screen:
    push ax
    push bx
    push cx
    push dx
    mov ah, 0x06    ;BIOS中断号
    mov al, 0
    mov cx, 0       ;(0,0)
    mov dx, 0x184f  ;(24,79)
    mov bh, 0x07    ;(黑底白字)
    int 0x10
    pop dx
    pop cx
    pop bx
    pop ax
    ret
