%include "boot.inc"
LOADER_STACK_TOP equ LOADER_BASE_ADDR
section loader vstart=LOADER_BASE_ADDR
jmp loader_start

;构建GDT与内部描述符
GDT_BASE:   dd  0x00000000
            dd  0x00000000

CODE_DESC   dd  0x0000FFFF
            dd  DESC_CODE_HIGH4

DATA_STACK_DESC   dd  0x0000FFFF
            dd  DESC_DATA_HIGH4
        
VIEDO_DESC  dd  0x80000007  ;limit=(0xbffff-0xb8000)/4k = 0x07
            dd  DESC_VIDEO_HIGH4

GDT_SIZE    equ $ - GDT_BASE
GDT_LIMIT   equ GDT_SIZE - 1
times 60 dq 0       ;预留60个描述符
SELECTOR_CODE   equ (0x0001<<3) + TI_GDT + RPL0
    ;(0x0001<<3)=(CODE_DESC - GDT_BASE)/8
SELECTOR_DATA   equ (0x0002<<3) + TI_GDT + RPL0
SELECTOR_VIDEO  equ (0x0003<<3) + TI_GDT + RPL0

;gdt指针,前2字节为gdt界限,后4字节为gdt起始位置
gdt_ptr     dw  GDT_LIMIT
            dd  GDT_BASE


loadingmsg db '2 loader is loading'

loader_start:
    mov sp, LOADER_BASE_ADDR
    mov bp, loadingmsg          ;es:bp = 字符串地址
    mov cx, 19                  ;cx = 字符长度
    mov ax, 0x1301              ;ah = 13, al = 01
    mov bx, 0x001f              ;bh = 0 页号为0,bl = 1fh 蓝底粉字
    mov dx, 0x1800
    int 0x10

;进入保护模式

    ;打开A20管线
    in al, 0x92
    or al, 0000_0010B
    out 0x92, al

    ;加载GDT
    lgdt [gdt_ptr]

    ;cr0的0位置1
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    jmp dword SELECTOR_CODE:p_mode_start    ;refresh pipline

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    mov byte [gs:160], 'P'

    jmp $
