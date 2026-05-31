; =========================================
; 模块名称：数码管显示模块
; 硬件连接：P0输出段码，P2.2~P2.4控制位选
; 说明：普中板实际位选方向与代码编号相反，所以这里按物理从左到右显示
; =========================================

SHOW_C875:
    ; 最左位显示C
    SETB P2.2
    SETB P2.3
    CLR P2.4
    MOV P0, #39H
    LCALL DELAY
    MOV P0, #00H

    ; 左数第2位显示8
    CLR P2.2
    SETB P2.3
    CLR P2.4
    MOV P0, #7FH
    LCALL DELAY
    MOV P0, #00H

    ; 左数第3位显示7
    SETB P2.2
    CLR P2.3
    CLR P2.4
    MOV P0, #07H
    LCALL DELAY
    MOV P0, #00H

    ; 最右位显示5
    MOV P2, #11111111B
    CLR P2.2
    CLR P2.3
    CLR P2.4
    MOV P0, #6DH
    LCALL DELAY
    MOV P0, #00H

    RET

; =========================================
; SHOW_KEY
; 输入：A=0~0FH
; 功能：前三位熄灭，最右侧显示按键值
; =========================================
SHOW_KEY:
    ANL A, #0FH
    MOV DPTR, #SEG_TABLE
    MOVC A, @A+DPTR
    MOV R5, A

    ; 最左位熄灭
    SETB P2.2
    SETB P2.3
    CLR P2.4
    MOV P0, #00H
    LCALL DELAY

    ; 左数第2位熄灭
    CLR P2.2
    SETB P2.3
    CLR P2.4
    MOV P0, #00H
    LCALL DELAY

    ; 左数第3位熄灭
    SETB P2.2
    CLR P2.3
    CLR P2.4
    MOV P0, #00H
    LCALL DELAY

    ; 最右位显示按键值
    MOV P2, #11111111B
    CLR P2.2
    CLR P2.3
    CLR P2.4
    MOV P0, R5
    LCALL DELAY
    MOV P0, #00H

    RET

; =========================================
; SHOW_BUF
; 功能：按物理从左到右显示DISP0~DISP3四个显示缓冲段码
; =========================================
SHOW_BUF:
    ; 最左位显示DISP0
    SETB P2.2
    SETB P2.3
    CLR P2.4
    MOV P0, DISP0
    LCALL DELAY
    MOV P0, #00H

    ; 左数第2位显示DISP1
    CLR P2.2
    SETB P2.3
    CLR P2.4
    MOV P0, DISP1
    LCALL DELAY
    MOV P0, #00H

    ; 左数第3位显示DISP2
    SETB P2.2
    CLR P2.3
    CLR P2.4
    MOV P0, DISP2
    LCALL DELAY
    MOV P0, #00H

    ; 最右位显示DISP3
    MOV P2, #11111111B
    CLR P2.2
    CLR P2.3
    CLR P2.4
    MOV P0, DISP3
    LCALL DELAY
    MOV P0, #00H

    RET

; =========================================
; SHOW_DASH
; 功能：四位数码管显示----，表示串口接收超时
; =========================================
SHOW_DASH:
    MOV DISP0, #40H
    MOV DISP1, #40H
    MOV DISP2, #40H
    MOV DISP3, #40H
    LCALL SHOW_BUF
    RET

; 共阴极数码管段码：0 1 2 3 4 5 6 7 8 9 A b C d E F
SEG_TABLE:
    DB 3FH, 06H, 5BH, 4FH
    DB 66H, 6DH, 7DH, 07H
    DB 7FH, 6FH, 77H, 7CH
    DB 39H, 5EH, 79H, 71H