ORG 0000H       ; 上电复位入口
    LJMP MAIN

KEY_SAVE EQU 30H    ; 保存最后一次按键值，FFH表示还没有按键

    ORG 0030H       ; 主程序开始
MAIN:
    MOV SP, #5FH    ; 初始化堆栈
    MOV KEY_SAVE, #0FFH

LOOP:
    LCALL KEY_SCAN          ; 扫描矩阵键盘，返回A=0~F或FFH
    CJNE A, #0FFH, KEY_PRESSED

    MOV A, KEY_SAVE
    CJNE A, #0FFH, SHOW_LAST_KEY
    LCALL SHOW_C875         ; 上电后还没按键，显示C875
    LJMP LOOP

KEY_PRESSED:
    MOV KEY_SAVE, A         ; 有按键时保存键值

SHOW_LAST_KEY:
    LCALL SHOW_KEY          ; 最右侧数码管显示键值
    LJMP LOOP

; =========================================
; 引入外部功能模块
; =========================================
$INCLUDE (display.asm)
$INCLUDE (delay.asm)
$INCLUDE (keyboard.asm)

    END