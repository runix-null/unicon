%include "boot.inc"

    org LOADER_BASE_ADDR

    ;绿色底色, 红色前景色,并闪动
    mov byte [gs:0x00], '2'
    mov byte [gs:0x01], 0xA4

    mov byte [gs:0x02], ' '
    mov byte [gs:0x03], 0xA4

    mov byte [gs:0x04], 'L'
    mov byte [gs:0x05], 0xA4

    mov byte [gs:0x06], 'o'
    mov byte [gs:0x07], 0xA4

    mov byte [gs:0x08], 'a'
    mov byte [gs:0x09], 0xA4

    mov byte [gs:0x0a], 'd'
    mov byte [gs:0x0b], 0xA4

    mov byte [gs:0x0c], 'e'
    mov byte [gs:0x0d], 0xA4

    mov byte [gs:0x0e], 'r'
    mov byte [gs:0x0f], 0xA4

    jmp $
