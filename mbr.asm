;Unicon OS 主引导程序
;Author: runix

    org 0x7c00

    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00

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

;获取光标位置

    mov ah, 3
    mov bh, 0       ;需获取的光标页码
    int 0x10        ;(cl, ch) = 开始行,结束行
                    ;(dl, dh) = 行号,列号

;打印字符
    mov ax, message
    mov bp, ax      ;[es:bp]字符串首地址
    mov cx, 12       ;字符串长度
    mov ax, 0x1301  ;al=0x01 光标跟随移动
    mov bx, 0x0002  ;bh=页面号, bl=字符属性, bl=02h为黑底绿字
    int 0x10

    jmp $ 

    message db "Hello world!"

    ;用0填满剩余部分
    times 510-($-$$) db 0
    dw 0xaa55