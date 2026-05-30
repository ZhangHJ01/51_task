ORG 0000H       ; 上电复位入口
    LJMP MAIN       

    ORG 0030H       ; 主程序开始
MAIN:
    MOV SP, #5FH    ; 初始化堆栈

LOOP:
    ; --- 这里是主干死循环，结构非常清晰 ---
    LCALL SHOW_C875 ; 调用数码管显示模块
    
    ; 以后你的键盘扫描、串口通信都可以写成 LCALL KEY_SCAN 等等放在这里

    LJMP LOOP       ; 循环

; =========================================
; 引入外部功能模块 (编译时会自动将代码拼接到这里)
; 注意：$ 符号必须顶靠在最左侧！
; =========================================
$INCLUDE (display.asm)
$INCLUDE (delay.asm)

    END             ; 整个工程唯一的 END 必须放在 main.asm 的最后