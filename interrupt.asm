; =========================================
; 模块名称：中断服务模块
; 功能描述：保存外部中断相关程序
; K3/P3.2/INT0：任务三，切换普通键盘模式和串口自发自收模式
; K4/P3.3/INT1：任务四，切换普通键盘模式和电话滚屏模式
; =========================================

INT0_ISR:
    PUSH ACC
    PUSH PSW
    PUSH 06H                ; DELAY会使用R6
    PUSH 07H                ; DELAY会使用R7

    LCALL DELAY             ; 简单消抖
    JB P3.2, INT0_EXIT      ; 如果已经松开，认为是抖动

    MOV A, SYS_MODE
    CJNE A, #MODE_KEY, INT0_SET_KEY
    MOV SYS_MODE, #MODE_UART
    MOV KEY_SAVE, #0FFH     ; 切到串口模式后先显示C875
    SJMP INT0_WAIT_RELEASE

INT0_SET_KEY:
    MOV SYS_MODE, #MODE_KEY
    MOV KEY_SAVE, #0FFH     ; 切回普通模式后先显示C875

INT0_WAIT_RELEASE:
    JNB P3.2, INT0_WAIT_RELEASE
    LCALL DELAY

INT0_EXIT:
    POP 07H
    POP 06H
    POP PSW
    POP ACC
    RETI

INT1_ISR:
    PUSH ACC
    PUSH PSW
    PUSH 06H                ; DELAY会使用R6
    PUSH 07H                ; DELAY会使用R7

    LCALL DELAY             ; 简单消抖
    JB P3.3, INT1_EXIT      ; 如果已经松开，认为是抖动

    MOV A, SYS_MODE
    CJNE A, #MODE_PHONE, INT1_SET_PHONE
    MOV SYS_MODE, #MODE_KEY
    MOV KEY_SAVE, #0FFH     ; 切回普通模式后先显示C875
    SJMP INT1_WAIT_RELEASE

INT1_SET_PHONE:
    MOV SYS_MODE, #MODE_PHONE
    MOV KEY_SAVE, #0FFH
    MOV PHONE_POS, #00H
    MOV PHONE_CNT, #00H
    MOV PHONE_SENT, #00H
    LCALL PHONE_LOAD_4      ; 进入电话模式后先装入前4位

INT1_WAIT_RELEASE:
    JNB P3.3, INT1_WAIT_RELEASE
    LCALL DELAY

INT1_EXIT:
    POP 07H
    POP 06H
    POP PSW
    POP ACC
    RETI