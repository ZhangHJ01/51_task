; =========================================
; 模块名称：数码管显示模块
; 硬件连接：P0输出段码，P2.2~P2.4控制位选
; =========================================

SHOW_C875:
    ; 第1位显示C
    MOV P2, #11111111B
    CLR P2.2
    CLR P2.3
    CLR P2.4
    MOV P0, #39H
    LCALL DELAY
    MOV P0, #00H

    ; 第2位显示8
    SETB P2.2
    CLR P2.3
    CLR P2.4
    MOV P0, #7FH
    LCALL DELAY
    MOV P0, #00H

    ; 第3位显示7
    CLR P2.2
    SETB P2.3
    CLR P2.4
    MOV P0, #07H
    LCALL DELAY
    MOV P0, #00H

    ; 第4位显示5
    SETB P2.2
    SETB P2.3
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

    ; 第1位熄灭
    MOV P2, #11111111B
    CLR P2.2
    CLR P2.3
    CLR P2.4
    MOV P0, #00H
    LCALL DELAY

    ; 第2位熄灭
    SETB P2.2
    CLR P2.3
    CLR P2.4
    MOV P0, #00H
    LCALL DELAY

    ; 第3位熄灭
    CLR P2.2
    SETB P2.3
    CLR P2.4
    MOV P0, #00H
    LCALL DELAY

    ; 第4位显示按键值
    SETB P2.2
    SETB P2.3
    CLR P2.4
    MOV P0, R5
    LCALL DELAY
    MOV P0, #00H

    RET

; 共阴极数码管段码：0 1 2 3 4 5 6 7 8 9 A b C d E F
SEG_TABLE:
    DB 3FH, 06H, 5BH, 4FH
    DB 66H, 6DH, 7DH, 07H
    DB 7FH, 6FH, 77H, 7CH
    DB 39H, 5EH, 79H, 71H