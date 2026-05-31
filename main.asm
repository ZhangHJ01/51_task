ORG 0000H       ; 上电复位入口
    LJMP MAIN

ORG 0003H       ; 外部中断0入口，K3/P3.2
    LJMP INT0_ISR

ORG 0013H       ; 外部中断1入口，K4/P3.3
    LJMP INT1_ISR

KEY_SAVE    EQU 30H    ; 保存最后一次显示值，FFH表示还没有按键，FEH表示串口超时
SYS_MODE    EQU 31H    ; 当前模式：0=普通键盘，1=串口自收发，2=电话滚屏
PHONE_POS   EQU 32H    ; 电话号码滚屏起始位置
PHONE_CNT   EQU 33H    ; 电话号码滚屏速度计数
PHONE_SENT  EQU 34H    ; 电话号码是否已经通过串口发送过
DISP0       EQU 35H    ; 显示缓冲第1位
DISP1       EQU 36H    ; 显示缓冲第2位
DISP2       EQU 37H    ; 显示缓冲第3位
DISP3       EQU 38H    ; 显示缓冲第4位

MODE_KEY    EQU 00H
MODE_UART   EQU 01H
MODE_PHONE  EQU 02H

    ORG 0030H       ; 主程序开始
MAIN:
    MOV SP, #5FH    ; 初始化堆栈
    MOV KEY_SAVE, #0FFH
    MOV SYS_MODE, #MODE_KEY
    MOV PHONE_POS, #00H
    MOV PHONE_CNT, #00H
    MOV PHONE_SENT, #00H

    LCALL UART_INIT ; 初始化串口
    SETB EA         ; 开总中断
    SETB EX0        ; 允许外部中断0，对应K3/P3.2
    SETB IT0        ; INT0下降沿触发
    SETB EX1        ; 允许外部中断1，对应K4/P3.3
    SETB IT1        ; INT1下降沿触发

LOOP:
    MOV A, SYS_MODE
    CJNE A, #MODE_PHONE, NOT_PHONE_MODE
    LCALL PHONE_TASK        ; 电话模式：发送一次号码，并滚屏显示
    LJMP LOOP

NOT_PHONE_MODE:
    LCALL KEY_SCAN          ; 扫描矩阵键盘，返回A=0~F或FFH
    CJNE A, #0FFH, KEY_PRESSED

    MOV A, KEY_SAVE
    CJNE A, #0FFH, CHECK_DASH
    LCALL SHOW_C875         ; 上电后还没按键，显示C875
    LJMP LOOP

CHECK_DASH:
    CJNE A, #0FEH, SHOW_LAST_KEY
    LCALL SHOW_DASH         ; 串口没有收到回环数据，显示----
    LJMP LOOP

SHOW_LAST_KEY:
    LCALL SHOW_KEY          ; 最右侧数码管显示键值
    LJMP LOOP

KEY_PRESSED:
    MOV R4, A               ; 保存本次按键值
    MOV A, SYS_MODE
    CJNE A, #MODE_UART, NORMAL_KEY_MODE

UART_KEY_MODE:
    MOV A, R4
    LCALL UART_SEND_A       ; 先从TXD发出
    LCALL UART_RECV_A       ; 再从RXD接收回环数据
    CJNE A, #0FFH, KEY_UART_OK
    MOV KEY_SAVE, #0FEH     ; 超时，没有收到数据
    LCALL SHOW_DASH
    LJMP LOOP

KEY_UART_OK:
    ANL A, #0FH             ; 只显示低4位键值
    MOV KEY_SAVE, A
    LCALL SHOW_KEY
    LJMP LOOP

NORMAL_KEY_MODE:
    MOV A, R4
    MOV KEY_SAVE, A         ; 普通模式：按键直接显示
    LCALL SHOW_KEY
    LJMP LOOP

; =========================================
; 引入外部功能模块
; =========================================
$INCLUDE (display.asm)
$INCLUDE (delay.asm)
$INCLUDE (keyboard.asm)
$INCLUDE (uart.asm)
$INCLUDE (phone.asm)
$INCLUDE (interrupt.asm)

    END