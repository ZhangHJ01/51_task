; =========================================
; 模块名称：串口通信模块
; 功能描述：串口模式1，真实自发自收需要短接P3.1(TXD)和P3.0(RXD)
; 默认参数：9600bps，11.0592MHz晶振，TH1/TL1=0FDH
; =========================================

UART_INIT:
    MOV SCON, #50H          ; 串口模式1，允许接收REN=1
    MOV TMOD, #20H          ; 定时器1方式2，8位自动重装
    MOV TH1, #0FDH          ; 9600bps @ 11.0592MHz
    MOV TL1, #0FDH
    SETB TR1                ; 启动定时器1
    CLR TI
    CLR RI
    RET

; =========================================
; UART_SEND_A
; 输入：A=要发送的数据
; =========================================
UART_SEND_A:
    CLR TI
    MOV SBUF, A
UART_WAIT_TX:
    JNB TI, UART_WAIT_TX
    CLR TI
    RET

; =========================================
; UART_RECV_A
; 输出：收到数据时A=SBUF，超时时A=FFH
; =========================================
UART_RECV_A:
    MOV R6, #0FFH
UART_RX_OUTER:
    MOV R7, #0FFH
UART_RX_INNER:
    JB RI, UART_RECV_OK
    DJNZ R7, UART_RX_INNER
    DJNZ R6, UART_RX_OUTER
    MOV A, #0FFH            ; 超时返回FFH
    RET

UART_RECV_OK:
    CLR RI
    MOV A, SBUF
    RET