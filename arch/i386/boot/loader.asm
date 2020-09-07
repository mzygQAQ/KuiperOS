org 0x9000

__loader_start:
	mov ax, cs
	mov ds, ax
	mov es, ax

    call clean_screen
	
	mov dx, 0
	call set_cursor

	mov bp, loader_entry_log
	mov cx, LOADER_ENTRY_LOG_LEN
	call write_string




_spin:
	nop
	jmp _spin

;DL: x
;DH: y
set_cursor:
	push ax
	mov ah, 0x02
	int 0x10
	pop ax
	ret
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

; int 10h 0x13号中断
; AH - 0x13
; AL - 打印模式 1-光标移动 0-光标不移动
; BH - 视频页码
; BL - 如果AL寄存器为 1 或者 0，设置属性
; CX - 长度
; DH - 行坐标
; DL - 纵坐标
; ES:BP - 指针
write_string:
    push ax
    push bx
    mov ax, 0x1301
    mov bx, 0x0007
    int 0x10
    pop bx
    pop ax
    ret
loader_entry_log:
	db 'LOADER was running...'
LOADER_ENTRY_LOG_LEN equ ($ - loader_entry_log)
