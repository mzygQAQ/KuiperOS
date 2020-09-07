; 
; bootsect.asm
;

org 0x7c00

BaseOfStack  equ 0x7c00
AddrOfLoader equ 0x9000
FatSectStart equ 1
FatSectLen   equ 9

jmp short __start
nop                                     ; jmp short _start 机器码占用2个字节，添加nop填

fat12_header:
    BS_OEMName     db "KuiperOS"
    BPB_BytsPerSec dw 512
    BPB_SecPerClus db 1
    BPB_RsvdSecCnt dw 1
    BPB_NumFATs    db 2
    BPB_RootEntCnt dw 224
    BPB_TotSec16   dw 2880
    BPB_Media      db 0xF0
    BPB_FATSz16    dw 9
    BPB_SecPerTrk  dw 18
    BPB_NumHeads   dw 2
    BPB_HiddSec    dd 0
    BPB_TotSec32   dd 0
    BS_DrvNum      db 0
    BS_Reserved1   db 0
    BS_BootSig     db 0x29
    BS_VolID       dd 0
    BS_VolLab      db "KuiperOSSSS"
    BS_FileSysType db "FAT12   "

__start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax

    ;设置栈空间,0x7c00-0x500之前大概有30kb的物理内存可以使用
    ;这个栈大小对于引导程序是十分足够的
    mov sp, BaseOfStack

    ;清除屏幕(512b内存不够，直接删除清屏，到保护模式再进行操作)
    ;call clean_screen
    
    ;将光标设置到(0,0)处(内存还是不够,就不设置光标位置了)
    ;mov dx, 0
    ;call set_cursor


    ;输出引导信息
    mov ax, boot_msg
    mov bp, ax
    mov cx, BOOT_MSG_LEN
    call write_string

    ;加载根目录区 位于19逻辑扇区(1MBR+9FAT+9FAT2) 共14个扇区
    mov ax, 0x13
    mov cx, 0x0e
    mov bx, buffer
    call read_sect
    
    ;查找LOADER.BIN
    mov si, loader_filename
    mov cx, LOADER_FILENAME_LEN
    call search_root_entry
    cmp dx, 0
    je write_loader_notfound

    ;search_root_entry后 bx的值为LOADER.BIN的目录项地址
    ;这里单独将其拷贝出来
    mov si, bx
    mov di, loader_bin_dir_entry
    mov cx, 32  ; 每个FAT12根目录项占32个字节
    call memcpy


    ;LOAD FAT1
    mov ax, FatSectLen
    mov cx, [BPB_BytsPerSec]
    mul cx
    mov bx, AddrOfLoader
    sub bx, ax  ;bx->FatStartAddr
    mov ax, FatSectStart
    mov cx, FatSectLen
    call read_sect

    ;查找到LOADER.BIN后加载FAT表到内存中.
    ;一个8086段最大64kb即0x0000:0x0000-0x0000:0x10000也就意味着0x9000-0x10000之
    ;间大概有28kb的物理内存,我们要将LOADER程序的控制在28kb以内，否则就要修改段寄存器了.
    ;读取LOADER.BIN的内容到内存0x9000其实位置，然后将CPU交给LOADER执行
    
    ;获取LOADER.BIN的起始簇
    mov dx, [loader_bin_dir_entry + 0x1a]
    mov si, AddrOfLoader
load_load:
    mov ax, dx
    add ax, 31  ;根目录项最多224个文件项每个32字节 224*32/512=14扇区,也就意味着数据区从19+14=33扇区开始.
    mov cx, 1
    push dx
    push bx
    mov bx, si
    call read_sect
    pop bx
    pop cx; dx->cx
    call read_fat_item
    cmp dx, 0xff7
    jnb AddrOfLoader    ;如果读完则直接跳转loader.bin
    add si, 512
    jmp load_load

    ; 如果LOADER.BIN存在,则不会执行到这里
    jmp spin

write_loader_notfound:
    mov dx, 0x0100
    mov bp, no_loader_msg
    mov cx, NO_LOADER_MSG_LEN
    call write_string

spin:
    hlt
    jmp spin

;clean_screen:
;    push ax
;    push bx
;    push cx
;    push dx
;    mov ah, 0x06    ;BIOS中断号
;    mov al, 0
;    mov cx, 0       ;(0,0)
;    mov dx, 0x184f  ;(24,79)
;    mov bh, 0x07    ;(黑底白字)
;    int 0x10
;    pop dx
;    pop cx
;    pop bx
;    pop ax
;    ret

; DL: x坐标
; DH: y坐标
;set_cursor:
;    push ax
;    mov ah, 0x2
;    int 0x10
;    pop ax
;    ret

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
read_sect:
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
    mov cx, bp  ;根目录文件名占用11字节 memcmp会改变cx,用bp存
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

;@param bx fat表的地址入口
;@param cx fatitem的索引
;@param dx fatValue
read_fat_item:
    mov ax, cx
    mov cl, 2
    div cl
    push ax
    mov ah, 0
    mov cx, 3
    mul cx
    mov cx, ax ; b
    pop ax
    cmp ah, 0
    jz _idx_even
    jmp _idx_odd
_idx_even:
    ; (fat[b+1] & 0x0f) << 8 | fat[b]
    mov dx, cx
    add dx, 1
    add dx, bx
    mov bp, dx
    mov dl, byte [bp]
    and dl, 0x0f
    shl dx, 8   ; must 16 register shl
    add cx, bx
    mov bp, cx
    or dl, byte [bp]
    jmp _rfi_done
_idx_odd:
    ; fat[b+2] << 4 | (fat[b+1] & 0xf0) >> 4
    ;mov dx, cx
    ;add dx, 1
    ;add dx, bx
    ;mov bp, dx
    ;mov dl, byte [bp]
    ;and dl, 0xf0
    ;xor dh, dh
    ;shr dx, 4
    ;add cx, bx
    ;add cx, 2
    ;mov bp, cx
    ;mov al, byte [bp]
    ;xor ax, ax
    ;shl ax, 4   ; must 16 register shl
    ;or dx, ax
	mov dx, cx
	add dx, 2
	add dx, bx
	mov bp, dx
	mov dl, byte [bp]
	mov dh, 0
	shl dx, 4
	add cx, 1
	add cx, bx
	mov bp, cx
	mov cl, byte [bp]
	shr cl, 4
	add cl, 0x0f
	mov ch, 0
	or  dx, cx   
	jmp _rfi_done
_rfi_done:
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

; 内存复制,暂未考虑内存重叠问题,请谨慎使用
;@param ds:si
;@param es:di
;@param cx
memcpy:
    cld
    rep movsb
    ret

boot_msg:
    db "KuiperOS booting"
BOOT_MSG_LEN equ ($ - boot_msg)

loader_filename:
    db "LOADER  BIN"
LOADER_FILENAME_LEN equ ($ - loader_filename)

no_loader_msg:
    db "LOADER not found"
NO_LOADER_MSG_LEN equ ($ - no_loader_msg)

;LOADER.BIN的根目录项32字节将会加载到这里
loader_bin_dir_entry:
    times 32 db 0x00

buffer:
    db 0x00

times 510-($-$$) db 0x00

boot_flag:
    dw 0xaa55
