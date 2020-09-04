; Copyright (c) 2020 KuiperOS Developers

; MIT License

; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files (the
; "Software"), to deal in the Software without restriction, including
; without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so, subject to
; the following conditions:

; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

org 0x7c00

BaseOfStack equ 0x7c00

jmp short _start
nop	                                    ; jmp short _start 机器码占用2个字节，添加nop填
                                        ; 充满3字节，使得符合Fat12FS格式

fat12_header:
    BS_OEMName     db "KuiperOS"        ; OEM字符串必须为8字节
    BPB_BytsPerSec dw 512               ; 每个扇区的字节数
    BPB_SecPerClus db 1                 ; 每簇占用的扇区数
    BPB_RsvdSecCnt dw 1                 ; 引导程序占用的扇区数
    BPB_NumFATs    db 2                 ; FAT表的记录数
    BPB_RootEntCnt dw 224               ; 最大根目录文件数
    BPB_TotSec16   dw 2880              ; 逻辑扇区总数量
    BPB_Media      db 0xF0              ; 媒体描述符(暂不知道用处)
    BPB_FATSz16    dw 9                 ; 每个FAT占用的扇区数量
    BPB_SecPerTrk  dw 18                ; 每个柱面的扇区数
    BPB_NumHeads   dw 2                 ; 磁头的数量
    BPB_HiddSec    dd 0                 ; 隐藏的扇区数
    BPB_TotSec32   dd 0                 ; ??
    BS_DrvNum      db 0                 ; 中断13的驱动器号
    BS_Reserved1   db 0                 ; 尚未使用
    BS_BootSig     db 0x29              ; 扩展引导标志
    BS_VolID       dd 0                 ; 卷序列号
    BS_VolLab      db "KuiperOSSSS"     ; 卷标必须为11字节
    BS_FileSysType db "FAT12   "        ; 文件系统的类型 必须8字节

_start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax

    ;设置栈空间,0x7c00-0x500之前大概有30kb的物理内存可以使用
    ;这个栈大小对于引导程序是十分足够的
    mov sp, BaseOfStack

    ;清除屏幕
    call clean_screen
	
    ;将光标设置到(0,0)处
    mov dx, 0
    call set_cursor

    ;输出引导信息
    mov ax, boot_msg
    mov bp, ax
    mov cx, BOOT_MSG_LEN
    call write_string

	;加载根目录区 位于19逻辑扇区(1MBR+9FAT+9FAT2) 共14个扇区
	mov ax, 0x13
	mov cx, 0x0e
	mov bx, buffer
	call read_from_floppy
	
	;查找LOADER.BIN
	mov si, loader_filename
	mov cx, LOADER_FILENAME_LEN
	call search_root_entry
	cmp dx, 0
	je write_loader_notfound

	;查找到LOADER.BIN后加载FAT表到内存中.
	;一个8086段最大64kb即0x0000:0x0000-0x0000:0x10000也就意味着0x9000-0x10000之
	;间大概有28kb的物理内存,我们要将LOADER程序的控制在28kb以内，否则就要修改段寄存器了.
	;BIOS提供的读取磁盘的中断不太清楚是否可以跨段处理。
    mov bx, 0x9000	
	call load_fat
    
	;读取LOADER.BIN的内容到内存0x9000其实位置，然后将CPU交给LOADER执行

	jmp spin

write_loader_notfound:
	mov dx, 0x0100
	call set_cursor
	mov bp, no_loader_msg
	mov cx, NO_LOADER_MSG_LEN
	call write_string

spin:
    hlt
    jmp spin

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

; DL: x坐标
; DH: y坐标
set_cursor:
    push ax
    mov ah, 0x2
    int 0x10
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

; BIOS 0x13 00号软驱复位
; AH=0x00 DL=驱动器号
; NO_ARGUMENT
reset_floppy:
    push ax
    push dx
    mov ax, 0x00
    mov dl, [BS_DrvNum]    ; 0代表A盘
    int 0x13
    pop dx
    pop ax
    ret

;从磁盘读取数据到内
;入参1： AX:传入逻辑扇区号
;入参2： CX:需要读取的扇区数
;入参3： ES:BX:读取到的内存地址
;
;
;参考:
;0x13号中断 0x02号功能号
;AH=0x02
;AL=长度(扇区数)
;CH=柱面号
;CL=起始扇区号
;DH=磁头号
;DL=驱动器号
;ES:BX=读取到的内存地址
read_from_floppy:
    pusha

    ;先保存读取的扇区数
    push bx
    push cx

    call reset_floppy

    ;AX在参数已就绪
    mov bl, [BPB_SecPerTrk]
    div bl
    ;计算扇区号
    mov cl, ah
    add cl, 1
    ;计算柱面号
    mov ch, al
    shr ch, 1
    ;计算磁头号
    mov dh, al
    and dh, 1
    ;计算驱动器号0代表A盘
    mov dl, [BS_DrvNum]

    pop ax; cx->ax
    pop bx
    mov ah, 0x02
_read_again:
    int 0x13
    jc _read_again

    popa
    ret

;在根目录区查找指定的文件
;每个根目录下占用32字节
;@param es:bx 根目录的起始偏移地址
;@param ds:si 文件名
;@param cx 文件名长度
;@return dx == 0 ? notfound : found
search_root_entry:
	push cx
	push bp
	push di
	mov dx, [BPB_RootEntCnt]
	mov bp, cx
_next:
	cmp dx, 0
	jz _notfound
	mov di, bx
	mov cx, bp	;根目录文件名占用11字节 memcmp会改变cx,用bp存
	call memcmp
	cmp cx, 0
	jz _found

	add bx, 32
	dec dx
	jmp _next
_found:
_notfound:
	pop di
	pop bp
	pop cx
	ret

;加载FAT表到内存中
;@param es:bp 加载到到内存地址
;fat1位于软盘的MBR之后，从1扇区开始，共9个扇区
load_fat:
    push ax
    push cx
    mov ax, 1
	mov cx, 9
	call read_from_floppy
	pop cx
	pop ax
	ret
		
		
; 内存比较,比较的长度不能超过一个段的大小
;@param ds:si
;@param es:di
;@param cx
;@return cx==0?eq:ne
memcmp:
	push ax
	push si
	push di
_comp:
	cmp cx, 0x00
	jz _eq
	mov al, byte [si]
	cmp al, byte [di]
	jne _ne
_conti:
	inc si
	inc di
	dec cx
	jmp _comp
_eq:
_ne:
	pop di
	pop si
	pop ax
	ret


; for test case, can be delete after test
test_case:
str_src:
    db "st1"
str_dest:
    db "sr1"
; =========================================

str_eq:
    db "equal"

str_ne:
    db "notequal"

boot_msg:
    db "DEBUG: KuiperOS is booting..."
    db 0x0d, 0x0a
BOOT_MSG_LEN equ ($ - boot_msg)

loader_filename:
	db "LOADER  BIN"
LOADER_FILENAME_LEN equ ($ - loader_filename)

no_loader_msg:
    db "PANIC: LOADER.BIN was not found!"
    db 0x0d, 0x0a
NO_LOADER_MSG_LEN equ ($ - no_loader_msg)

buffer:
	db "floppy data will recover here..."

times 510-($-$$) db 0x00

boot_flag:
    dw 0xaa55
