; =========================================
; 模块名称：电话号码模块
; 功能描述：发送一次电话号码，并在数码管上循环滚屏显示
; 电话号码：占位号码，答辩前可直接修改PHONE_TABLE
; =========================================

PHONE_LEN       EQU 11
PHONE_SPEED     EQU 40

PHONE_TASK:
    MOV A, PHONE_SENT
    CJNE A, #01H, PHONE_FIRST_SEND
    SJMP PHONE_SCROLL

PHONE_FIRST_SEND:
    LCALL PHONE_SEND_ALL
    MOV PHONE_SENT, #01H
    LCALL PHONE_LOAD_4

PHONE_SCROLL:
    LCALL SHOW_BUF
    INC PHONE_CNT
    MOV A, PHONE_CNT
    CJNE A, #PHONE_SPEED, PHONE_RET
    MOV PHONE_CNT, #00H
    INC PHONE_POS
    MOV A, PHONE_POS
    CJNE A, #PHONE_LEN, PHONE_LOAD_NOW
    MOV PHONE_POS, #00H

PHONE_LOAD_NOW:
    LCALL PHONE_LOAD_4

PHONE_RET:
    RET

; =========================================
; PHONE_SEND_ALL
; 功能：把电话号码11位依次通过串口发送到电脑
; =========================================
PHONE_SEND_ALL:
    MOV R6, #00H
PHONE_SEND_LOOP:
    MOV A, R6
    MOV DPTR, #PHONE_TABLE
    MOVC A, @A+DPTR
    LCALL UART_SEND_A
    INC R6
    CJNE R6, #PHONE_LEN, PHONE_SEND_LOOP
    RET

; =========================================
; PHONE_LOAD_4
; 功能：从PHONE_POS开始取连续4位，转换为段码放入DISP0~DISP3
; =========================================
PHONE_LOAD_4:
    MOV R4, #00H
    LCALL PHONE_GET_SEG
    MOV DISP0, A

    MOV R4, #01H
    LCALL PHONE_GET_SEG
    MOV DISP1, A

    MOV R4, #02H
    LCALL PHONE_GET_SEG
    MOV DISP2, A

    MOV R4, #03H
    LCALL PHONE_GET_SEG
    MOV DISP3, A
    RET

; =========================================
; PHONE_GET_SEG
; 输入：R4=窗口偏移0~3
; 输出：A=对应数字的段码
; =========================================
PHONE_GET_SEG:
    MOV A, PHONE_POS
    ADD A, R4
    CJNE A, #PHONE_LEN, PGS_CHECK_OVER
    MOV A, #00H
    SJMP PGS_READ

PGS_CHECK_OVER:
    JC PGS_READ             ; A < PHONE_LEN，不需要回绕
    CLR C
    SUBB A, #PHONE_LEN      ; A >= PHONE_LEN，减去长度回绕

PGS_READ:
    MOV DPTR, #PHONE_TABLE
    MOVC A, @A+DPTR         ; 取ASCII数字
    CLR C
    SUBB A, #'0'            ; 转成0~9
    MOV DPTR, #SEG_TABLE
    MOVC A, @A+DPTR         ; 转成段码
    RET

PHONE_TABLE:
    DB '1','5','1','1','3','0','8','6','3','2','6'