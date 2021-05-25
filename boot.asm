;Unicon OS 主引导程序
;Author: runix

%include "boot.inc"

    org 0x7c00

    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov gs, ax

;通过int 0x10上滚全部行，实现清屏
;input:
;ah = 0x06
;al = 上滚的行数
;bh = 上卷行的属性
;(cl, ch) = 左上角坐标
;(dl, dh) = 右下角坐标

    mov ax, 0x0600
    mov bx, 0x0700
    mov cx, 0
    mov dx, 0x184f  ;VGA文本模式中,一行80字符,共25行,即0x18=25-1, 0x4f=80-1
    int 0x10

    ;绿色底色, 红色前景色,并闪动
    mov byte [gs:0x00], '1'
    mov byte [gs:0x01], 0xA4

    mov byte [gs:0x02], ' '
    mov byte [gs:0x03], 0xA4

    mov byte [gs:0x04], 'b'
    mov byte [gs:0x05], 0xA4

    mov byte [gs:0x06], 'o'
    mov byte [gs:0x07], 0xA4

    mov byte [gs:0x08], 'o'
    mov byte [gs:0x09], 0xA4

    mov byte [gs:0x0a], 't'
    mov byte [gs:0x0b], 0xA4

    mov eax, LOADER_START_SECTOR    ;起始LBA地址
    mov bx, LOADER_BASE_ADDR        ;写入的地址
    mov cx, 1                       ;读取的扇区数
    call rd_disk_md_16

    jmp LOADER_BASE_ADDR    ;跳转到Loader

;读取硬盘的n个扇区
;eax=LBA扇区号
;bx=数据写入的内存地址
;cx=读取的扇区数
rd_disk_md_16:

    mov esi, eax    ;备份eax
    mov di, cx      ;备份cx

    ;设置读取扇区数
    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov eax, esi    ;恢复eax

    ;将LBA的地址存入0x1f3~0x1f6

    ;LBA地址0~7存入0x1f3
    mov dx, 0x1f3
    out dx, al

    ;LBA地址8~15存入0x1f4
    mov dx, 0x1f4
    shr eax, 8
    out dx, al

    ;LBA地址16~23存入0x1f5
    mov dx, 0x1f5
    shr eax, 8
    out dx, al

    ;LBA地址24~27存入0x1f6
    mov dx, 0x1f6
    shr eax, 8
    and al, 0x0f    ;lba24~27,并将高4位清零
    or al, 0xe0     ;设置主盘(1110的第6位置1)
    out dx, al

    ;向0x1f7端口(command reg)写入读盘命令(0x20)
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ;检测硬盘状态
.not_ready:
    ;同端口,读时代表读取硬盘状态
    nop
    in al, dx
    and al, 0x88    ;第3位为1表示硬盘控制器已准备好
                    ;第7位为1表示硬盘正忙
    cmp al, 0x08
    jnz .not_ready  ;如未准备好,repeat

    ;从0x1f0端口读取数据
    ;di为读取的扇区数,一扇区有512字节,一次读2字节
    mov ax, di
    mov dx, 256
    mul dx          ;乘法运算,被乘数为ax
    mov cx, ax
    mov dx, 0x1f0
.go_on_reading:
    in ax, dx
    mov [bx], ax
    add bx, 2
    loop .go_on_reading
    ret

    ;用0填满剩余部分
    times 510-($-$$) db 0
    dw 0xaa55