; =========================================
; 模块名称：矩阵键盘扫描模块
; 功能描述：使用线反转法扫描4x4矩阵键盘
; 硬件连接：P1.0~P1.3 与 P1.4~P1.7 接矩阵键盘两组线
; 返回值：A=00H~0FH表示按键值，A=FFH表示无按键
; =========================================

; 查找表：每两个字节一组
; 第1字节是线反转后读到的P1状态，第2字节是对应键值
; 普中板正常显示：S1->1，S2->2，...，S9->9，S10->0，S11->A，...，S16->F
KEY_TABLE:
    DB 0EEH, 0FH          ; S16 -> F
    DB 0DEH, 0BH          ; S12 -> B
    DB 0BEH, 08H          ; S8  -> 8
    DB 07EH, 04H          ; S4  -> 4
    DB 0EDH, 0EH          ; S15 -> E
    DB 0DDH, 0AH          ; S11 -> A
    DB 0BDH, 07H          ; S7  -> 7
    DB 07DH, 03H          ; S3  -> 3
    DB 0EBH, 0DH          ; S14 -> D
    DB 0DBH, 00H          ; S10 -> 0
    DB 0BBH, 06H          ; S6  -> 6
    DB 07BH, 02H          ; S2  -> 2
    DB 0E7H, 0CH          ; S13 -> C
    DB 0D7H, 09H          ; S9  -> 9
    DB 0B7H, 05H          ; S5  -> 5
    DB 077H, 01H          ; S1  -> 1

KEY_SCAN:
    LCALL KEY_READ          ; 先读一次键盘
    CJNE A, #0FFH, KS_DEBOUNCE
    RET                     ; 没有按键，直接返回FFH

KS_DEBOUNCE:
    LCALL DELAY             ; 延时消抖
    LCALL KEY_READ          ; 再读一次确认
    CJNE A, #0FFH, KS_LOOKUP
    MOV A, #0FFH
    RET

KS_LOOKUP:
    MOV R7, A               ; R7保存当前P1状态
    MOV DPTR, #KEY_TABLE
    MOV R6, #00H            ; R6作为查表序号，范围0~15

KS_NEXT:
    MOV A, R6
    ADD A, R6               ; 每个键占2字节，所以偏移=序号*2
    MOV R5, A
    MOVC A, @A+DPTR         ; 取表中的P1状态
    MOV B, R7
    CJNE A, B, KS_NOT_MATCH

    MOV A, R5
    INC A                   ; 偏移+1，取对应键值
    MOVC A, @A+DPTR
    SJMP KS_WAIT_RELEASE

KS_NOT_MATCH:
    INC R6
    CJNE R6, #10H, KS_NEXT
    MOV A, #0FFH            ; 查不到则认为无效按键
    RET

KS_WAIT_RELEASE:
    PUSH ACC                ; 保存键值，等待松手

KS_REL_LOOP:
    LCALL KEY_READ
    CJNE A, #0FFH, KS_REL_LOOP
    LCALL DELAY             ; 松手后再消抖一次
    POP ACC
    RET

KEY_READ:
    ; 第一次：高4位输出0，低4位写1作为输入，读取低4位状态
    MOV P1, #0FH
    NOP
    NOP
    MOV A, P1
    ANL A, #0FH
    MOV B, A

    ; 第二次：低4位输出0，高4位写1作为输入，读取高4位状态
    MOV P1, #0F0H
    NOP
    NOP
    MOV A, P1
    ANL A, #0F0H
    ORL A, B                ; 合成完整的8位状态
    RET