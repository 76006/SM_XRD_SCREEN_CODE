local FRAME_HEAD_1 = 0xEE
local FRAME_HEAD_2 = 0xB5
local FRAME_TAIL_1 = 0xFF
local FRAME_TAIL_2 = 0xFF
local FRAME_TAIL_3 = 0xFC
local FRAME_TAIL_4 = 0xFF
FA_OPEN_EXISTING = 0x00
FA_READ          = 0x01
FA_WRITE         = 0x02
FA_WRITE_BIN     = 0x03
FA_CREATE_NEW    = 0x04
FA_CREATE_ALWAYS = 0x08
FA_OPEN_ALWAYS   = 0x10

-- ================== 写变量通用函数 ==================
Progress_value = 0
Current_input_buff = ""--治疗头输入的密码
Engineer_Password_input_buff="" --工程师输入的密码
QR_CODE_INFO = ""
Engineer_QR_CODE_INFO=""
Press = 1 -- 按下
Bounce = 0 -- 回弹
Trigger = Bounce -- 触发
MAX_RETRY = 3
DEBUGFLAG = 1
Group_Num = 100
TABLE_SIZE = 372 --每个信息组的字节数
HEADER_SIZE = 132 --文件头大小
Uart_send_file_flag = 0
Uart_send_Verify_file_flag = 0 --发送数据并开启超时检测
Current_offset = 0
Remain = {} --解析后剩余的文件
Remain_len = 0 --解析时长度
COLOR_RED = 0XF800
COLOR_GREEN = 0X7E0
Real_index_map = {}
Image_index_map = {}
Gear_index_map = {}
GEAR_COUNT =16
LINE_LEN =40
Power_Geer_Range_High = 0.2
Power_Geer_Range_Low = 0.2
Current_Power_Debuginfo = {
    voltage ={} ,
    load_real =0,
    real_total = 0,
    imag_total = 0,
    total_count = 0, --当前第几个测试电压
    load_imag =0,   
    voltage_num = 0 --电压数量
}
Current_Power_Verifyinfo = {
    total_Geer= 0,
    Geer_count =0,
    Machine_power = 0,
    Measured_power = 0
}
skip_header = HEADER_SIZE

Prase_data_tables = {}
ImpedanceX_Real_table = {75,100,150,175,200,225,250,300,350,400}
ImpedanceX_Image_table = {0,-50,-100,-150,-180}
ImpedanceX_Save_Times = {}
Gear_table = {0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8}
Timer_ID={
    Error_Code_Clear = 0 ,
    MCU_Ack = 1 ,
    Uart_send = 2 ,
    Test_State =3 ,
    Uart_send_file =4,
    RF_Start =5,
    Verify_Gear_RF_Timer = 6,
    Verify_file_send = 7
}

data_frame = {
    group_count = 0,      -- 信息组数量 (u32)

    avg_real = 0.0,       -- 平均实部 (float)
    avg_imag = 0.0,       -- 平均虚部 (float)

    info_groups = {       -- 信息组数组
        {
            real = 0.0,               -- 实部 (float)
            imag = 0.0,               -- 虚部 (float)
            relay = 0,                -- 继电器值 (u32)
            voltage = 0.0,            -- 电压 (float)
            power = 0.0,              -- 功率 (float)
            current = 0.0,            -- 电流 (float)
            load_real = 0.0,          -- 负载阻值实部 (float)
            load_imag = 0.0,          -- 负载阻值虚部 (float)
            efficiency = 0.0          -- 继电器组合对应效率 (float)
        }
    }
}

Timer_Info = {
    -- 手具连接相关错误
    [Timer_ID.Error_Code_Clear] = {ID = Timer_ID.Error_Code_Clear, timeout = 5000, countdown =1 , timesrepeat = 1,curtimesrepeat = 0},
    [Timer_ID.MCU_Ack] = {ID = Timer_ID.MCU_Ack, timeout = 100, countdown =1 , timesrepeat = 1,curtimesrepeat = 0},
    [Timer_ID.Uart_send] = {ID = Timer_ID.Uart_send, timeout = 500, countdown =1 , timesrepeat = 3,curtimesrepeat = 0,waiting_ack = false,last_packet =nil},
    [Timer_ID.Test_State] = {ID = Timer_ID.Test_State, timeout = 100, countdown =1 , timesrepeat = 0,curtimesrepeat = 0},
    [Timer_ID.Uart_send_file] = {ID = Timer_ID.Uart_send_file, timeout = 100, countdown =1 , timesrepeat = 0,curtimesrepeat = 0},
    [Timer_ID.RF_Start] = {ID = Timer_ID.RF_Start, timeout = 10000, countdown =1 , timesrepeat = 0,curtimesrepeat = 0},
    [Timer_ID.Verify_Gear_RF_Timer] = {ID = Timer_ID.Verify_Gear_RF_Timer, timeout = 10000, countdown =1 , timesrepeat = 0,curtimesrepeat = 0},
    [Timer_ID.Verify_file_send] = {ID = Timer_ID.Verify_file_send, timeout = 1000, countdown =1 , timesrepeat = 0,curtimesrepeat = 0},
    
}
-- ================== 变量地址定义 ==================
VAR_ADDR={

    -- ============================================================================
    -- 基础信息变量
    -- ============================================================================
    Model              = 0x3000,  -- 型号（与治疗头类型共用地址）
    Headcount          = 0x3040,  -- 发数
    Date               = 0x3080,  -- 日期（与生产日期共用地址）
    VerifyQrCode       = 0x31C0,  -- 验真二维码A
    Head_Ok            = 0x4002,  -- 头端有效标志

    -- ============================================================================
    -- 治疗相关变量
    -- ============================================================================
    TreatmentProgress  = 0x3260,  -- 治疗进度条
    HeadIcon           = 0x3280,  -- 治疗头图标
    ErrorInput         = 0x32A0,  -- 错误输入框
    CoolLevel          = 0x34E0,  -- 制冷档位
    CoolantIcon        = 0x32E0,  -- 冷媒剂图标变量

    -- ============================================================================
    -- 升级相关变量
    -- ============================================================================
    UpgradeProgress    = 0x3400,  -- 升级进度条（与升级进度数字共用地址）
    UsedTotalShots     = 0x3460,  -- 已用发数/总发数
    Upgrade_Error_Input= 0x3380,  -- 升级错误码
    -- ============================================================================
    -- 设备信息变量
    -- ============================================================================
    DeviceModel        = 0x3600,  -- 设备型号
    MonitorVer         = 0x3640,  -- 监测版本
    MainCtrlVer        = 0x36C0,  -- 主控版本
    HandpieceVer       = 0x3700,  -- 手具版本
    Uid                = 0x3780,  -- UID
    Setting_Error_Input    =0x2010,    --设置错误码

    -- ============================================================================
    -- 工程师相关变量
    -- ============================================================================
    EngineerQrCode     = 0x3880,  -- 工程师二维码

    -- ============================================================================
    -- 波形参数变量
    -- ============================================================================
    Wave1Amplitude     = 0x16C0,  -- 波形1幅值
    Wave2Amplitude     = 0x1700,  -- 波形2幅值
    PhaseDiff          = 0x1730,  -- 相位差
    ImpedanceR         = 0x1760,  -- 阻抗R
    ImpedanceX         = 0x1790,  -- 阻抗X
    PowerDetect        = 0x17D0,  -- 功率检测值

    -- ============================================================================
    -- 匹配前参数
    -- ============================================================================
    PreMatchW1         = 0x1B20,  -- 匹配前W1
    PreMatchW2         = 0x1B30,  -- 匹配前W2
    PreMatchDeg        = 0x1B34,  -- 匹配前DEG

    -- ============================================================================
    -- 匹配后参数
    -- ============================================================================
    PostMatchW1        = 0x1B40,  -- 匹配后W1
    PostMatchW2        = 0x1B50,  -- 匹配后W2
    PostMatchDeg       = 0x1B54,  -- 匹配后DEG
    PostMatchPower     = 0x1B58,  -- 匹配后功率
    Body_Resistance_R  = 0x1B00,  -- 人体R
    Body_Reactance_X   = 0x1B10,  -- 人体X
    Current            = 0x1B14,  -- 电流

    -- ============================================================================
    -- 长脉冲参数
    -- ============================================================================
    LongPulseW1        = 0x1B60,  -- 长脉冲W1
    LongPulseW2        = 0x1B70,  -- 长脉冲W2
    LongPulseDeg       = 0x1B74,  -- 长脉冲DEG
    LongPulsePower     = 0x1B78,  -- 长脉冲功率

    -- ============================================================================
    -- 测量参数
    -- ============================================================================
    Efficiency         = 0x38FA,  -- 效率
    MeasuredPower      = 0x38F8,  -- 实测功率

    -- ============================================================================
    -- 结果状态
    -- ============================================================================
    Result             = 0x1A00,  -- 结果
    MatchRelayValue    = 0x1990,  -- 匹配继电器值
    NegPlateStatus     = 0x1B80,  -- 负极板状态
    ResultIcon         = 0x1980,  -- 结果图标

    -- ============================================================================
    -- 阻抗匹配参数
    -- ============================================================================
    PreMatchImpedanceR = 0x19C0,  -- 匹配前阻抗R
    PreMatchImpedanceX = 0x19D0,  -- 匹配前阻抗X
    PostMatchImpedanceR = 0x19E0, -- 匹配后阻抗R
    PostMatchImpedanceX = 0x19F0, -- 匹配后阻抗X
    Scope_Current =0x4026,  --示波器电流
    Vswr               = 0x19F4,  -- Vswr

    -- ============================================================================
    -- 温度压力监测
    -- ============================================================================
    CoolantPressure    = 0x2220,  -- 冷媒压力
    SolenoidPressure   = 0x2230,  -- 电磁阀压
    CoolantTemp        = 0x2240,  -- 冷媒温度
    AmpTemp            = 0x3AD0,  -- 放大温度

    -- ============================================================================
    -- 连接状态
    -- ============================================================================
    FootSwitchIcon     = 0x2250,  -- 脚踏连接图标
    HandpieceIcon      = 0x2260,  -- 手具连接图标
    BubbleSensor       = 0x3AD8,  -- 气泡传感器

    -- ============================================================================
    -- 治疗头温度
    -- ============================================================================
    Head1Temp          = 0x2310,  -- 头1温度
    Head2Temp          = 0x2320,  -- 头2温度
    Head3Temp          = 0x2330,  -- 头3温度
    Head4Temp          = 0x2340,  -- 头4温度

    -- ============================================================================
    -- 手具参数
    -- ============================================================================
    HandpiecePressure  = 0x2350,  -- 手具压力
    MagneticForce      = 0x2360,  -- 磁力
    -- HeadType           = 0x3000,  -- 治疗头类型（与型号共用地址）
    HeadVersion        = 0x2420,  -- 治疗头版本
    HeadId             = 0x2440,  -- 治疗头ID
    TotalCycles        = 0x2460,  -- 总次数
    RemainingCycycles  = 0x2470,  -- 剩余次数
    ProduceDate        = 0x3080,  -- 生产日期（与日期共用地址）

    -- ============================================================================
    -- 连接状态
    -- ============================================================================
    MonitorConn        = 0x39A0,  -- 监测版连接
    UsbConn            = 0x39C0,  -- U盘连接
    CRC_Num            = 0x3B00,  -- CRC数值
    Body_CRC_Num       = 0x3B08,  -- 身体CRC数值
    Voice_Adjustment   = 0x4000,  -- 音量修改

    -- ============================================================================
    -- 压力阈值
    -- ============================================================================
    PressureBase       = 0x3AE0,  -- 压力基准
    Treatment_Head_Skin_Contact     = 0x3AF8,  -- 治疗头贴肤

    -- ============================================================================
    -- 测试参数
    -- ============================================================================
    TestInterval       = 0x3914,  -- 测试间隔

    -- ============================================================================
    -- 射频校准信息
    -- ============================================================================
    OpenCircuit_Incident        =0x2600,
    OpenCircuit_Reflected       =0x2604,
    OpenCircuit_Phase           =0X2608,
    OpenCircuit_ResistanceR     =0X260C,
    OpenCircuit_ReactanceX      =0X2610,
    OpenCircuit_S11Real         =0X2614,
    OpenCircuit_S11Imag         =0X2618,

    ShortCircuit_Incident       =0x2620,
    ShortCircuit_Reflected      =0x2624,
    ShortCircuit_Phase          =0X2628,
    ShortCircuit_ResistanceR    =0X262C,
    ShortCircuit_ReactanceX     =0X2630,
    ShortCircuit_S11Real        =0X2634,
    ShortCircuit_S11Imag        =0X2638,

    Load50_Incident             =0x2640,
    Load50_Reflected            =0x2644,
    Load50_Phase                =0X2648,
    Load50_ResistanceR          =0X264C,
    Load50_ReactanceX           =0X2650,
    Load50_S11Real              =0X2654,
    Load50_S11Imag              =0X2658,

    LoadMeasurement_Incident    =0x2660,
    LoadMeasurement_Reflected   =0x2664,
    LoadMeasurement_Phase       =0X2668,
    LoadMeasurement_ResistanceR =0X266C,
    LoadMeasurement_ReactanceX  =0X2670,
    LoadMeasurement_S11Real     =0X2674,
    LoadMeasurement_S11Imag     =0X2678,
 
    ED_Real                     =0x2680,
    ED_Imag                     =0x2684,
    ES_Real                     =0X2688,
    ES_Imag                     =0X268C,
    ER_Real                     =0X2690,
    ER_Imag                     =0X2694,
    REALS11_Real                =0X2698,
    REALS11_Imag                =0X269C,
    REALImpedance_Real          =0X26A0,
    REALImpedance_Imag          =0X26A4,

    Timestamps                  =0x3904,    --时间戳
    Rleay_VSWR                 =0x400C,    --VSWR
    File_Write              =0x4110,  -- 上传文件数据
    File_Creat              =0x4100,  --  文件创建
    File_MCU_ERROR              =0x4120,  --  文件创建
    File_Screen_ERROR              =0x4121,  --  文件创建
    File_Send_Creat              =0x4150,  --  文件创建
    File_Send_Data              =0x4160,  --  文件创建
    File_Send_MCU_ERROR              =0x4170,  -- 上传文件数据
    File_Send_Screen_ERROR              =0x4171,  --  文件创建
    Verify_File_Send_Info_MCU              =0x4173,  -- 验证文件信息
    Verify_File_Send_Data_MCU              =0x4175,  --  验证文件数据
    RF_state              =0x4020,  -- 射频状态
    -- ============================================================================
    -- 控制参数
    -- ============================================================================
    VerifyCodeText     = 0x3200,  -- 验真码文本框内容
    UpgradeBtn         = 0x33A0,  -- 升级按钮
    ModeCtrl           = 0x34A0,  -- 模式控制
    PowerLevel         = 0x34C0,  -- 能量档位（与档位调节数据共用地址）
    VibrateBtn         = 0x3520,  -- 震动按钮
    VoltAdjustData     = 0x1690,  -- 电压调节数据
    -- LevelAdjustData    = 0x34C0,  -- 档位调节数据（与能量档位共用地址）
    RfSwitch           = 0x17C0,  -- 射频输出开关
    VoltAdjustMode     = 0x3AC0,  -- 电压档位调节方式
    OutputLimit        = 0x17F0,  -- 输出限制
    NegPlateLimit      = 0x3AF0,  -- 负极板限制
    LcrSwitch          = 0x17E0,  -- LCR开关
    MatchPulseDur      = 0x1900,  -- 匹配脉冲时长
    MatchPulseInt      = 0x1910,  -- 匹配脉冲间隔
    CoolantDur         = 0x1954,  -- 单次冷媒时长
    Test_Count         = 0x3900,  -- 测试发数
    K_Pulse_Duration_Plus       = 0x1920,   -- 长脉冲时长
    K_Pulse_Interval_Plus       = 0x1930,   -- 长脉冲间隔
    K_Pulse_Count_Plus          = 0x1940,   -- 长脉冲个数
    Test_Interval               = 0x3914,   --测试间隔
    Impedance_R                 = 0x38F2,   --阻抗实部
    Impedance_X                 = 0x38F4,   --阻抗虚部    
    CurrentRecord               = 0x38F0,   -- 电流记录
    ReleaseThreshold   = 0x3AE4,  -- 松开阈值
    PressThreshold     = 0x3AE8,  -- 按下阈值
    EngineerInput      = 0x3800,  -- 工程师文本输入框内容
    Switch_Info        = 0x3804,    --21个继电器信息（0-21位对应21个继电器）
    Coordinates        = 0x4006,    --坐标值
    Relay_VoltAdjustData =0x4016,  --继电器界面电压调节
    Volt_select =0x401C,  --电压选择信息
    Current_Voltage          = 0x2510,  --当前电压
    RF_start_select =0x4180,  --射频发射开关
    Measure_Pulse_Duration      = 0x2520 ,   --校准脉冲时长
    Time_Cali=0x3A00, --校准时间
    RF_TEST_END = 0x4182 --测试完成
}
-- ============================================================================
-- 错误码映射表 - 使用已定义的变量名称
-- ============================================================================
ERROR_ADDR={
    NOERROR                    = 0X0001,    -- 无错误
    ErrorHandpieceDisconnected = 0x0010,    -- 手具未连接: 请连接手具

    -- 冷媒相关错误
    ErrorCoolantSelfCheck      = 0x0018,    -- 制冷剂未降温: 若多次连续出现，请重插头端
    ErrorCoolantPreheating     = 0x0112,    -- 冷媒预热中: 请稍等
    ErrorCoolantInsufficient   = 0x0113,    -- 冷媒不足: 请更换冷媒剂
    ErrorNoCoolantBottle       = 0x0114,    -- 冷媒瓶未安装: 请放置冷媒瓶
    ErrorCoolantNoCooling      = 0x0058,    -- 制冷剂未降温: 若多次连续出现，请重插头端

    -- 内部错误系列 (0x0020-0x002B)
    ErrorInternal0020          = 0x0020,    -- 内部错误: 请联系售后
    ErrorInternal0021          = 0x0021,    -- 内部错误: 请联系售后
    ErrorInternal0022          = 0x0022,    -- 内部错误: 请联系售后
    ErrorInternal0023          = 0x0023,    -- 内部错误: 请联系售后
    ErrorInternal0024          = 0x0024,    -- 内部错误: 请联系售后
    ErrorInternal0025          = 0x0025,    -- 内部错误: 请联系售后
    ErrorInternal0026          = 0x0026,    -- 内部错误: 请联系售后
    ErrorInternal0027          = 0x0027,    -- 内部错误: 请联系售后
    ErrorInternal0028          = 0x0028,    -- 内部错误: 请联系售后
    ErrorInternal0029          = 0x0029,    -- 内部错误: 请联系售后
    ErrorInternal002A          = 0x002A,    -- 内部错误: 请联系售后
    ErrorInternal002B          = 0x002B,    -- 内部错误: 请联系售后

    -- 屏幕通信错误
    ErrorScreenCommunication   = 0x0030,    -- 内部错误: 请联系售后
    ErrorScreenCommunication2  = 0x0031,    -- 内部错误: 请联系售后
    ErrorScreenMailboxBlock    = 0x0032,    -- 内部错误: 请联系售后

    -- 维护警告
    ErrorMaintenanceWarning    = 0x0038,    -- 警告:接近维护时间: 请尽早联系售后
    ErrorMaintenanceRequired   = 0x0047,    -- 需要维护: 请联系售后

    -- 硬件错误
    ErrorConstantVoltageFail   = 0x0040,    -- 内部错误: 请联系售后
    ErrorFanMalfunction        = 0x0041,    -- 风扇不转: 请检查风扇是否供电或者被卡住
    ErrorPressureSensor1       = 0x0042,    -- 内部错误: 请联系售后
    ErrorPressureSensor2       = 0x0043,    -- 内部错误: 请联系售后
    ErrorFootPedalDisconnected = 0x0044,    -- 脚踏未连接: 请连接脚踏
    ErrorVoltageInsufficient   = 0x0046,    -- 电压不足: 请联系技术支持
    
    -- 恒压错误
    ErrorConstantVoltage       = 0x0045,    -- 恒压错误: 请更换冷媒剂，若多次失败，请联系售后
    ErrorConstantVoltage2      = 0x0048,    -- 恒压错误: 请更换冷媒剂，若多次失败，请联系售后
    ErrorConstantVoltage3      = 0x0049,    -- 恒压错误: 请更换冷媒剂，若多次失败，请联系售后
    ErrorConstantVoltage4      = 0x004A,    -- 恒压错误: 请更换冷媒剂，若多次失败，请联系售后

    -- 内部错误系列 (0x004B-0x0053)
    ErrorInternal004B          = 0x004B,    -- 内部错误: 请联系售后
    ErrorInternal004C          = 0x004C,    -- 内部错误: 请联系售后
    ErrorInternal004D          = 0x004D,    -- 内部错误: 请联系售后
    ErrorInternal0050          = 0x0050,    -- 内部错误: 请联系售后
    ErrorInternal0051          = 0x0051,    -- 内部错误: 请联系售后
    ErrorInternal0052          = 0x0052,    -- 内部错误: 请联系售后
    ErrorInternal0053          = 0x0053,    -- 内部错误: 请联系售后

    -- FPGA通信错误
    ErrorFPGACHKSum            = 0x0060,    -- 内部错误: 请联系售后
    ErrorFPGAParseFail         = 0x0061,    -- 内部错误: 请联系售后
    ErrorFPGANoResponse        = 0x0062,    -- 内部错误: 请联系售后
    ErrorFPGAResponseZero      = 0x0063,    -- 内部错误: 请联系售后

    -- 阻抗监测错误
    ErrorImpedanceUnmatched    = 0x0070,    -- 治疗时可能未良好接触: 若多次重试后失败，请联系售后
    ErrorImpedanceVoltageLow   = 0x0071,    -- 内部错误: 请联系售后
    ErrorImpedanceMatched      = 0x0072,    -- 治疗时可能未良好接触: 若多次重试后失败，请联系售后
    ErrorImpedanceMatchedVoltageLow = 0x0073,  -- 内部错误: 请联系售后
    ErrorDCPowerTooHigh        = 0x0074,    -- 治疗时可能未良好接触: 若多次重试后失败，请联系售后
    ErrorCouplerPowerHigh      = 0x0075,    -- 内部错误: 请联系售后
    ErrorCouplerPowerLow       = 0x0076,    -- 内部错误: 请联系售后
    ErrorACCurrentIdle         = 0x0078,    -- 内部错误: 若多次重试后失败，请联系售后
    ErrorACCurrentWorkHigh     = 0x0079,    -- 内部错误: 若多次重试后失败，请联系售后
    ErrorACCurrentWorkLow      = 0x007A,    -- 内部错误: 若多次重试后失败，请联系售后
    ErrorPAMTempHigh           = 0x007B,    -- 内部错误: 请联系售后
    ErrorCouplerPowerTooHigh2  = 0x007C,    -- 内部错误: 若多次重试后失败，请联系售后
    ErrorCouplerPowerTooLow2   = 0x007D,    -- 内部错误: 若多次重试后失败，请联系售后

    -- 治疗头相关错误
    ErrorHandpieceError        = 0x0080,    -- 治疗头错误: 更换有效的治疗头
    ErrorHandpieceTimeout      = 0x0081,    -- 治疗头超时: 更换有效的治疗头
    ErrorHandpieceCommError    = 0x0082,    -- 治疗头错误: 重新插拔治疗头
    ErrorHandpieceInvalid      = 0x0083,    -- 治疗头无效: 更换有效的治疗头
    ErrorHandpieceNotInserted  = 0x0084,    -- 治疗头没插好: 请重新插治疗头
    ErrorHandpieceOverheat     = 0x0085,    -- 治疗头过温: 请等待冷却
    ErrorHeadContactAbnormal   = 0x0086,    -- 头端接触异常: 请重新插拔
    ErrorHandpieceCompleted    = 0x0087,    -- 治疗完成: 请更换新的治疗头
    ErrorHandpieceTypeError    = 0x0089,    -- 治疗头错误: 更换有效的治疗头
    ErrorHandpieceActivated    = 0x008A,    -- 治疗头错误: 更换有效的治疗头
    ErrorHandpieceNotActivated = 0x008B,    -- 治疗头错误: 更换有效的治疗头
    ErrorHandpieceUnused       = 0x008C,    -- 治疗头错误: 更换有效的治疗头
    ErrorHandpieceUsed         = 0x008D,    -- 治疗头错误: 更换有效的治疗头
    ErrorHandpieceUndefinedUnused = 0x008E,  -- 治疗头错误: 更换有效的治疗头
    ErrorHandpieceUndefinedUsed = 0x008F,   -- 治疗头错误: 更换有效的治疗头
    ErrorHandpieceVersionFail  = 0x0091,    -- 治疗头无效: 更换有效的治疗头
    ErrorHandpieceUIDFail      = 0x0092,    -- 治疗头无效: 更换有效的治疗头
    ErrorHandpieceCountFail    = 0x0093,    -- 治疗头无效: 更换有效的治疗头
    ErrorHandpiecePage0Fail    = 0x0094,    -- 治疗头无效: 更换有效的治疗头
    ErrorHandpiecePage1Fail    = 0x0095,    -- 治疗头无效: 更换有效的治疗头
    ErrorHandpieceInvalid7     = 0x009B,    -- 治疗头无效: 更换有效的治疗头
    ErrorHandpieceCRCError     = 0x009C,    -- 治疗头无效: 更换有效的治疗头
    ErrorHandpieceExhausted    = 0x009E,    -- 治疗头次数耗尽: 更换有效的治疗头
    ErrorHandpieceNewChip      = 0x009F,    -- 治疗头无效: 更换有效的治疗头

    -- 射频校准错误
    ErrorCalibrationOpen       = 0x00A1,    -- 内部错误: 请联系售后
    ErrorCalibrationShort      = 0x00A2,    -- 内部错误: 请联系售后
    ErrorCalibration50R        = 0x00A3,    -- 内部错误: 请联系售后
    ErrorCalibrationLoad       = 0x00A4,    -- 内部错误: 请联系售后
    ErrorCalibrationSaveOpen   = 0x00AA,    -- 内部错误: 请联系售后
    ErrorCalibrationSaveShort  = 0x00AB,    -- 内部错误: 请联系售后
    ErrorCalibrationSave50R    = 0x00AC,    -- 内部错误: 请联系售后
    ErrorCalibrationMeasure    = 0x00B0,    -- 内部错误: 请联系售后

    -- 手具传感器错误
    ErrorHandpiecePressureSensor = 0x00C0,  -- 内部错误: 请联系售后

    -- 参数存储错误
    ErrorStorageDevice         = 0x0100,    -- 内部错误: 请联系售后
    ErrorStorageCalibration    = 0x0101,    -- 内部错误: 请联系售后
    ErrorStorageGeneral        = 0x0102,    -- 内部错误: 请联系售后
    ErrorImpedanceTable        = 0x0106,    -- 内部错误: 请联系售后

    -- 操作相关错误
    ErrorKeyPressedTooLong     = 0x0108,    -- 发射键按压时间过长: 请松开后重试
    ErrorHandpieceOverPressure = 0x0109,    -- 治疗头受压过重: 请调节为合适压力
    ErrorKeyReleased           = 0x010A,    -- 按键被松开: 请重试
    ErrorHandpieceNotOnSkin    = 0x010B,    -- 手具未贴肤: 请重试

    -- 监测板错误
    ErrorMonitorBoardDisconnect = 0x0110,   -- 内部错误: 请联系售后
    ErrorNegativePlateAbnormal = 0x0111,    -- 负极板未连接: 请连接好负极板
    ErrorCheckValveBlock       = 0x0115,    -- 内部错误: 请联系售后
    ErrorLCRRelayConnection    = 0x0118,    -- 内部错误: 请联系售后
    ErrorHumanResistanceExceeded = 0x0119,  -- 人体阻值超限值: 若多次重试后失败，请联系售后

    -- 验证码错误
    ErrorVerificationCode      = 0x0120,    -- 验真码输入错误: 请检查验真码
    ErrorMaintenanceCode       = 0x0121,    -- 维护码输入错误: 请检查维护码

    -- Python通信错误
    ErrorPythonDisconnect      = 0x0130,    -- 内部错误: 请联系售后
    ErrorPythonBlock           = 0x0131,    -- 内部错误: 请联系售后

    -- 治疗头版本错误
    ErrorHandpieceUnsupportedVersion = 0x0150,  -- 不支持的治疗头版本: 更换有效的治疗头

    -- 其他内部错误
    ErrorSolenoidValve         = 0x1010,    -- 内部错误: 请联系售后
    ErrorHandpieceWriteCount   = 0x1050,    -- 内部错误: 请联系售后
    ErrorHandpieceInvalidate   = 0x1051,    -- 内部错误: 请联系售后
    ErrorHandpieceActivate     = 0x1052,    -- 内部错误: 请联系售后

    -- 文件传输错误
    Error_File_MCU_ERROR       = 0x40,      -- 上传文件时下位机错误: 请重试
    Error_File_Screen_ERROR    = 0x201,     -- 上传文件时上位机错误: 请重试
    Error_File_Send_MCU_ERROR  = 0x41,      -- 下载文件时下位机错误: 请重试
    Error_File_Send_Screen_ERROR = 0x203,   -- 下载文件时上位机错误: 请重试
}
ErrorMessages = {
    -- 无错误
    [ERROR_ADDR.NOERROR] = {title = "", solution = "", type = "", level = ""},
    
    -- ==================== 手具连接相关错误 ====================
    [ERROR_ADDR.ErrorHandpieceDisconnected] = {title = "手具未连接", solution = "请连接手具", type = "handpiece", level = "error"},
    
    -- ==================== 冷媒相关错误 ====================
    [ERROR_ADDR.ErrorCoolantSelfCheck] = {title = "制冷剂未降温", solution = "若多次连续出现，请重插头端", type = "coolant", level = "error"},
    [ERROR_ADDR.ErrorCoolantNoCooling] = {title = "制冷剂未降温", solution = "若多次连续出现，请重插头端", type = "coolant", level = "error"},
    [ERROR_ADDR.ErrorCoolantPreheating] = {title = "冷媒预热中", solution = "请稍等", type = "coolant", level = "warning"},
    [ERROR_ADDR.ErrorCoolantInsufficient] = {title = "冷媒不足", solution = "请更换冷媒剂", type = "coolant", level = "error"},
    [ERROR_ADDR.ErrorNoCoolantBottle] = {title = "冷媒瓶未安装", solution = "请放置冷媒瓶", type = "coolant", level = "error"},
    
    -- ==================== 内部错误 0x0020-0x002B ====================
    [ERROR_ADDR.ErrorInternal0020] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0021] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0022] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0023] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0024] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0025] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0026] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0027] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0028] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0029] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal002A] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal002B] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    
    -- ==================== 屏幕通信错误 ====================
    [ERROR_ADDR.ErrorScreenCommunication] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorScreenCommunication2] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorScreenMailboxBlock] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    
    -- ==================== 维护警告 ====================
    [ERROR_ADDR.ErrorMaintenanceWarning] = {title = "警告:接近维护时间", solution = "请尽早联系售后", type = "maintenance", level = "warning"},
    [ERROR_ADDR.ErrorMaintenanceRequired] = {title = "需要维护", solution = "请联系售后", type = "maintenance", level = "warning"},
    
    -- ==================== 硬件错误 ====================
    [ERROR_ADDR.ErrorConstantVoltageFail] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorFanMalfunction] = {title = "风扇不转", solution = "请检查风扇是否供电或者被卡住", type = "hardware", level = "error"},
    [ERROR_ADDR.ErrorPressureSensor1] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorPressureSensor2] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorFootPedalDisconnected] = {title = "脚踏未连接", solution = "请连接脚踏", type = "accessory", level = "error"},
    [ERROR_ADDR.ErrorVoltageInsufficient] = {title = "电压不足", solution = "请联系技术支持", type = "voltage", level = "error"},
    
    -- ==================== 恒压错误 ====================
    [ERROR_ADDR.ErrorConstantVoltage] = {title = "恒压错误", solution = "请更换冷媒剂，若多次失败，请联系售后", type = "voltage", level = "error"},
    [ERROR_ADDR.ErrorConstantVoltage2] = {title = "恒压错误", solution = "请更换冷媒剂，若多次失败，请联系售后", type = "voltage", level = "error"},
    [ERROR_ADDR.ErrorConstantVoltage3] = {title = "恒压错误", solution = "请更换冷媒剂，若多次失败，请联系售后", type = "voltage", level = "error"},
    [ERROR_ADDR.ErrorConstantVoltage4] = {title = "恒压错误", solution = "请更换冷媒剂，若多次失败，请联系售后", type = "voltage", level = "error"},
    
    -- ==================== 内部错误 0x004B-0x0053 ====================
    [ERROR_ADDR.ErrorInternal004B] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal004C] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal004D] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0050] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0051] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0052] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorInternal0053] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    
    -- ==================== FPGA通信错误 ====================
    [ERROR_ADDR.ErrorFPGACHKSum] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorFPGAParseFail] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorFPGANoResponse] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorFPGAResponseZero] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    
    -- ==================== 阻抗监测错误 ====================
    [ERROR_ADDR.ErrorImpedanceUnmatched] = {title = "治疗时可能未良好接触", solution = "若多次重试后失败，请联系售后", type = "treatment", level = "warning"},
    [ERROR_ADDR.ErrorImpedanceVoltageLow] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorImpedanceMatched] = {title = "治疗时可能未良好接触", solution = "若多次重试后失败，请联系售后", type = "treatment", level = "warning"},
    [ERROR_ADDR.ErrorImpedanceMatchedVoltageLow] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorDCPowerTooHigh] = {title = "治疗时可能未良好接触", solution = "若多次重试后失败，请联系售后", type = "treatment", level = "warning"},
    [ERROR_ADDR.ErrorCouplerPowerHigh] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorCouplerPowerLow] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorACCurrentIdle] = {title = "内部错误", solution = "若多次重试后失败，请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorACCurrentWorkHigh] = {title = "内部错误", solution = "若多次重试后失败，请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorACCurrentWorkLow] = {title = "内部错误", solution = "若多次重试后失败，请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorPAMTempHigh] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorCouplerPowerTooHigh2] = {title = "内部错误", solution = "若多次重试后失败，请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorCouplerPowerTooLow2] = {title = "内部错误", solution = "若多次重试后失败，请联系售后", type = "internal", level = "error"},
    
    -- ==================== 治疗头相关错误 ====================
    [ERROR_ADDR.ErrorHandpieceError] = {title = "治疗头错误", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceTimeout] = {title = "治疗头超时", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceCommError] = {title = "治疗头错误", solution = "重新插拔治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceInvalid] = {title = "治疗头无效", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceNotInserted] = {title = "治疗头没插好", solution = "请重新插治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceOverheat] = {title = "治疗头过温", solution = "请等待冷却", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHeadContactAbnormal] = {title = "头端接触异常", solution = "请重新插拔", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceCompleted] = {title = "治疗完成", solution = "请更换新的治疗头", type = "handpiece", level = "info"},
    [ERROR_ADDR.ErrorHandpieceTypeError] = {title = "治疗头错误", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceActivated] = {title = "治疗头错误", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceNotActivated] = {title = "治疗头错误", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceUnused] = {title = "治疗头错误", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceUsed] = {title = "治疗头错误", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceUndefinedUnused] = {title = "治疗头错误", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceUndefinedUsed] = {title = "治疗头错误", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceVersionFail] = {title = "治疗头无效", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceUIDFail] = {title = "治疗头无效", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceCountFail] = {title = "治疗头无效", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpiecePage0Fail] = {title = "治疗头无效", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpiecePage1Fail] = {title = "治疗头无效", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceInvalid7] = {title = "治疗头无效", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceCRCError] = {title = "治疗头无效", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceExhausted] = {title = "治疗头次数耗尽", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    [ERROR_ADDR.ErrorHandpieceNewChip] = {title = "治疗头无效", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    
    -- ==================== 射频校准错误 ====================
    [ERROR_ADDR.ErrorCalibrationOpen] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorCalibrationShort] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorCalibration50R] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorCalibrationLoad] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorCalibrationSaveOpen] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorCalibrationSaveShort] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorCalibrationSave50R] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorCalibrationMeasure] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    
    -- ==================== 手具传感器错误 ====================
    [ERROR_ADDR.ErrorHandpiecePressureSensor] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    
    -- ==================== 参数存储错误 ====================
    [ERROR_ADDR.ErrorStorageDevice] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorStorageCalibration] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorStorageGeneral] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorImpedanceTable] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    
    -- ==================== 操作相关错误 ====================
    [ERROR_ADDR.ErrorKeyPressedTooLong] = {title = "发射键按压时间过长", solution = "请松开后重试", type = "operation", level = "warning"},
    [ERROR_ADDR.ErrorHandpieceOverPressure] = {title = "治疗头受压过重", solution = "请调节为合适压力", type = "operation", level = "warning"},
    [ERROR_ADDR.ErrorKeyReleased] = {title = "按键被松开", solution = "请重试", type = "operation", level = "warning"},
    [ERROR_ADDR.ErrorHandpieceNotOnSkin] = {title = "手具未贴肤", solution = "请重试", type = "operation", level = "warning"},
    
    -- ==================== 监测板错误 ====================
    [ERROR_ADDR.ErrorMonitorBoardDisconnect] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorNegativePlateAbnormal] = {title = "负极板未连接", solution = "请连接好负极板", type = "accessory", level = "error"},
    [ERROR_ADDR.ErrorCheckValveBlock] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorLCRRelayConnection] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorHumanResistanceExceeded] = {title = "人体阻值超限值", solution = "若多次重试后失败，请联系售后", type = "treatment", level = "error"},
    
    -- ==================== 验证码错误 ====================
    [ERROR_ADDR.ErrorVerificationCode] = {title = "验真码输入错误", solution = "请检查验真码", type = "verification", level = "error"},
    [ERROR_ADDR.ErrorMaintenanceCode] = {title = "维护码输入错误", solution = "请检查维护码", type = "verification", level = "error"},
    
    -- ==================== Python通信错误 ====================
    [ERROR_ADDR.ErrorPythonDisconnect] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorPythonBlock] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    
    -- ==================== 治疗头版本错误 ====================
    [ERROR_ADDR.ErrorHandpieceUnsupportedVersion] = {title = "不支持的治疗头版本", solution = "更换有效的治疗头", type = "handpiece", level = "error"},
    
    -- ==================== 其他内部错误 ====================
    [ERROR_ADDR.ErrorSolenoidValve] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorHandpieceWriteCount] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorHandpieceInvalidate] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    [ERROR_ADDR.ErrorHandpieceActivate] = {title = "内部错误", solution = "请联系售后", type = "internal", level = "error"},
    
    -- ==================== 文件传输错误 ====================
    [ERROR_ADDR.Error_File_MCU_ERROR] = {title = "上传文件时下位机错误", solution = "请重试", type = "file", level = "error"},
    [ERROR_ADDR.Error_File_Screen_ERROR] = {title = "上传文件时上位机错误", solution = "请重试", type = "file", level = "error"},
    [ERROR_ADDR.Error_File_Send_MCU_ERROR] = {title = "下载文件时下位机错误", solution = "请重试", type = "file", level = "error"},
    [ERROR_ADDR.Error_File_Send_Screen_ERROR] = {title = "下载文件时上位机错误", solution = "请重试", type = "file", level = "error"},
}
Treat_mode={
    Classic_Mode=0,
    Comfort_Mode=1
}

-- ================== 协议常量 ==================

local FUNC_WRITE   = 0x02   -- MCU 写变量
sending_in_progress = false          -- 是否有消息正在发送/等待回复
pending_messages = {}                -- 等待发送的消息队列（可选）
Current_info = { -- 当前信息
    Model = 0, -- 模式 0：经典 1：舒适
    Gear = 0, -- 档位
    Cold = 0, -- 制冷档位
    Vibration = 0, -- 是否振动
    Total_Count = 0, -- 总发数
    Used_Count = 0, -- 已用发数
    Error_Code_Buffer = "", -- 错误码
    Warning_Buffer = "", -- 提醒信息
    Cold_Limit_Low = 4.5, -- 制冷档位阈值
    Cold_Limit_High = 7.5, -- 制冷档位阈值
    Voltage_Value=10.6,  --调节电压
    Setting_Gear = 0 ,
    Match_Pulse_Duration_Plus=30,--匹配脉冲市场
    Match_Pulse_Duration_Value=20,--匹配脉冲间隔
    Single_Coolant_Duration_Plus=5,--单次冷媒时长
    Test_Count=1,--测试发数
    K_Pulse_Duration_Plus=200,--长脉冲时长
    K_Pulse_Interval_Plus=50,--长脉冲间隔
    K_Pulse_Count_Plus=5,--长脉冲个数
    Test_Interval=5,--测试间隔
    Impedance_R=0,
    Impedance_X=0,
    CurrentRecord=0,  
    ReleaseThreshold=0,
    PressThreshold=0,
    Switch_info = 0,
    timestamps = 0,
    Current_Voltage =0, --射频校准电压
    Measure_Pulse_Duration= 0 , --射频校准脉冲时长
    Cali_Time = 0,
    Head_Ok=0,
    retry = 0 ,
    File_Bytes = 0,
    File_CRC= 0 ,
    File_Current_Location = 0 , 
    File_Current_Bytes = 0 , 
    File_Data_Info = {},
    Show_table = {},
    Rf_Test_Flag = 0 , --开始射频测试 --0 关闭射频测试  1 开启射频测试 
    Rf_Test_State = 0 , --
    New_Table = {},
    Verify_Table_info = {}, --验证界面表内信息
    Verify_Gear_Select = {}, --验证档位选择
    Verify_Rf_Test_Flag = 0 , --开始射频测试 --0 关闭射频测试  1 开启射频测试  
    Verify_Rf_Test_State = 0 , --
    Retest_Select = 0 , --  选择号
    Retest_Select_Geer = 0 , --选择电压
    Retest_Select_Test_Flag = 0  -- 重测标志

}
SCREENID = {
    Treatment_Not_Recognized_SCREEN = 1, -- 治疗头未识别界面
    Treatment_Process_SCREEN = 3, -- 治疗头进行中
    Setting_SCREEN = 5, -- 设置界面
    Engineer_Password_SCREEN = 7, -- 工程师密码界面
    Engineer_Select_SCREEN = 9, -- 工程师功能选择界面
    Power_Impedance = 11, -- 电源及阻抗介面
    Relay_Control_SCREEN = 13, -- 继电器控制界面
    Impedance_Distribution_Matching_SCREEN = 15, -- 阻抗分布匹配界面
    Status_Check_SCREEN = 17, -- 状态查看界面
    RF_Calibration_SCREEN = 19, -- 射频校准界面
    Time_Calibration_SCREEN = 21, -- 时间界面
    Upgrade_SCREEN = 23, -- 升级界面
    Power_Debugging_Interface_SCREEN = 24, -- 功率调试界面
    Volt_Select_SCREEN = 25, -- 升级界面
    Current_Error_Code_SCREEN = 26, -- 错误码界面
    History_Error_Code_SCREEN = 27,-- 错误码界面
    Power_Verify_SCREEN = 28,--验证界面
    Power_Verify_Result_SCREEN = 29,--验证结果界面
    Geer_Select_Verify_SCREEN = 30,--档位验证界面
    BodyTreatment_Process_SCREEN = 31,--V2
    V2Treatment_Process_SCREEN = 32--V2
}
Treatment_Not_Recognized_SCREEN_CONTROL = {
    NUM1 = 1,
    NUM2 = 2,
    NUM3 = 3,
    NUM4 = 4,
    NUM5 = 5,
    NUM6 = 6,
    NUM7 = 7,
    NUM8 = 8,
    NUM9 = 9,
    NUM0 = 10,
    Cancel = 11,
    Confirm = 12,
    Model = 13, -- 型号
    Pulse_Count = 14, -- 发数
    Date = 15,
    Treatment_Progress_Icon = 16, -- 治疗进程
    Treatment_Complete_Icon = 17, -- 治疗头图标
    Warning_Code = 18, -- 警告码
    Warning_Details = 19, -- 警告详细信息
    Password_Input_Box = 24, -- 密码输入框
    Password_Delete = 21 ,-- 密码删一位
    QR_Code_Verification =25, -- 验真二维码
    Refrigerant_icon=22 , --冷媒剂图标
}
Treatment_Process_SCREEN_CONTROL = {

    Classic_Mode_Button = 1, -- 经典模式
    Comfort_Mode_Button = 2, -- 舒适模式
    Sub_Button = 3, -- 减
    Add_Button = 4, -- 加
    Vibration_Button = 5, -- 振动档位
    Cold_Button = 6, -- 冷媒档位切换按钮
    Refrigerant_icon=8 , --冷媒剂图标
    Gear_Text = 11, -- 档位文本
    Refrigeration_Icon = 14, -- 制冷图标
    Vibration_Icon = 15, -- 震动图标
    Treatment_Progress_Icon = 16, -- 治疗进程
    Treatment_Complete_Icon = 17, -- 治疗头图标
    Warning_Code = 18, -- 警告码
    Warning_Details = 19, -- 警告详细信息
    Totalused_Headcount=20  --已用发数/总发数
}
V2Treatment_Process_SCREEN_CONTROL = {

    Classic_Mode_Button = 1, -- 经典模式
    Comfort_Mode_Button = 2, -- 舒适模式
    Sub_Button = 3, -- 减
    Add_Button = 4, -- 加
    Vibration_Button = 5, -- 振动档位
    Cold_Button = 6, -- 冷媒档位切换按钮
    Refrigerant_icon=8 , --冷媒剂图标
    Gear_Text = 11, -- 档位文本
    Refrigeration_Icon = 14, -- 制冷图标
    Vibration_Icon = 15, -- 震动图标
    Treatment_Progress_Icon = 16, -- 治疗进程
    Treatment_Complete_Icon = 17, -- 治疗头图标
    Warning_Code = 18, -- 警告码
    Warning_Details = 19, -- 警告详细信息
    Totalused_Headcount=20  --已用发数/总发数
}
BODYTreatment_Process_SCREEN_CONTROL = {


    Sub_Button = 3, -- 减
    Add_Button = 4, -- 加
    Vibration_Button = 5, -- 振动档位
    Cold_Button = 6, -- 冷媒档位切换按钮
    Refrigerant_icon=8 , --冷媒剂图标
    Gear_Text = 11, -- 档位文本
    Refrigeration_Icon = 14, -- 制冷图标
    Vibration_Icon = 15, -- 震动图标
    Treatment_Progress_Icon = 16, -- 治疗进程
    Treatment_Complete_Icon = 17, -- 治疗头图标
    Warning_Code = 18, -- 警告码
    Warning_Details = 19, -- 警告详细信息
    Totalused_Headcount=20  --已用发数/总发数
}
Setting_SCREEN_CONTROL={
    Device_Model = 11, -- 设置界面
    Main_Control_Version=12,
    Monitoring_Version=13,
    Handtool_Version=14,
    Screen_Version=15,
    UID=16,
    Voice_Slider=1,
    Voice_Progress=3,
    Brightness_Slider=20,
    Brightness_Press=2
}
Relay_Control_SCREEN_CONRTOL={
    Error_Code=68,
    Coordinates = 52,
    RFswitch=70,
    Relay_VoltAdjustData=55,
    W1=56,
    W2=64,
    VSWR=65,
    R=66,
    X=62,

}
Engineer_Password_SCREEN_CONTROL={
    NUM0 = 48,
    NUM1 = 49,
    NUM2 = 50,
    NUM3 = 51,
    NUM4 = 52,
    NUM5 = 53,
    NUM6 = 54,
    NUM7 = 55,
    NUM8 = 56,
    NUM9 = 57,
    Letter_A = 97,
    Letter_B = 98,
    Letter_C = 99,
    Letter_D = 100,
    Letter_E = 101,
    Letter_F = 102,
    Letter_G = 103,
    Letter_H = 104,
    Letter_I = 105,
    Letter_J = 106,
    Letter_K = 107,
    Letter_L = 108,
    Letter_M = 109,
    Letter_N = 110,
    Letter_O = 111,
    Letter_P = 112,
    Letter_Q = 113,
    Letter_R = 114,
    Letter_S = 115,
    Letter_T = 116,
    Letter_U = 117,
    Letter_V = 118,
    Letter_W = 119,
    Letter_X = 120,
    Letter_Y = 121,
    Letter_Z = 122,
    Delete = 14,
    Cancel = 11,
    Confirm =12,
    Password_Input_Box = 13,
    Engineer_QR_CODE=45
}

POWER_IMPEDANCE_SCREEN_CONTROL = {
    -- 电压调节区域
    Voltage_Value = 1,           -- 电压值 (10.6)
    Voltage_Value_Add=2,
    Voltage_Value_Sub=3,

    Gear_Adjustment = 18,           -- 电压值 (10.6)
    Gear_Adjustment_Add=17,
    Gear_Adjustment_Sub=16,
    -- 射频输出控制
    RF_Output_State = 7,         -- 射频输出状态 (OFF)
    
    -- 信号值区域
    Wave1_Amplitude = 8,         -- 波形1幅值 mV (8)
    Wave2_Amplitude = 9,         -- 波形2幅值 mV (9)  
    Phase_Difference = 10,        -- 相位差 (10)
    
    -- 阻抗值区域
    Resistance_R = 12,            -- R(Q)值 (12)
    Reactance_X = 13,             -- X(Q)值 (13)
    
    -- 功率检测区域
    Power_Detection_Value = 11,   -- 功率检测值 mV (11)
    Error_Code = 15,             -- 错误代码
    
    Output_Limit_1 = 4,         -- 输出限制1 (ON)
    Negative_Plate_LCR_Switch = 5,  -- LCR开关
    Negative_Plate_Limit = 6        -- 负极板限制 (ON)
}

IMPEDANCE_MATCHING_SCREEN_CONTROL = {
    -- 匹配脉冲时长区域
    Match_Pulse_Duration_Plus = 17,      -- 匹配脉冲时长 +
    Match_Pulse_Duration_Plus_Add = 1,
    Match_Pulse_Duration_Plus_Sub = 2,
    --匹配脉冲间隔
    Match_Pulse_Duration_Value = 18,     -- 匹配脉冲间隔 ms
    Match_Pulse_Duration_Value_Add = 3,     -- 匹配脉冲间隔 ms
    Match_Pulse_Duration_Value_Sub = 4,     -- 匹配脉冲间隔 ms
    
    -- 单次冷媒时长区域
    Single_Coolant_Duration_Plus = 19,   -- 单次冷媒时长 +
    Single_Coolant_Duration_Plus_Add = 5,   -- 单次冷媒时长 +
    Single_Coolant_Duration_Plus_Sub = 6,   -- 单次冷媒时长 +

    -- 测试发数
    Test_Count = 20,                     -- 测试次数
    Test_Count_Add = 7,                     -- 测试次数
    Test_Count_Sub = 8,                     -- 测试次数

    -- 长脉冲时长
    K_Pulse_Duration_Plus = 21,          -- 脉冲时长 +
    K_Pulse_Duration_Plus_Add = 9,              -- 脉冲时长 A ms
    K_Pulse_Duration_Plus_Sub = 10,             -- 脉冲时长 B ms
    
    -- 长脉冲间隔
    K_Pulse_Interval_Plus = 22,          -- 脉冲间隔 +
    K_Pulse_Interval_Plus_Add = 11,          -- 脉冲间隔 +
    K_Pulse_Interval_Plus_Sub = 12,          -- 脉冲间隔 +
    
    -- 长脉冲个数
    K_Pulse_Count_Plus = 23,             -- K脉冲个数 +
    K_Pulse_Count_Plus_Add = 13,             -- K脉冲个数 +
    K_Pulse_Count_Plus_Sub = 14,             -- K脉冲个数 +
    
    -- 测试间隔
    Test_Interval = 24,                  -- 测试间隔
    Test_Interval_Add = 15,                  -- 测试间隔
    Test_Interval_Sub = 16,                  -- 测试间隔

    -- 电流记录
    CurrentRecord = 27,                 -- 电流记录
    -- 阻抗虚部
    Impedance_R = 25,                         -- 阻抗实部
    -- 阻抗实部
    Impedance_X = 26,                         -- 阻抗虚部
    
    
    -- 匹配前参数区域
    PreMatchW1 = 28,                    -- 匹配前 W1
    PreMatchW2 = 29,                    -- 匹配前 W2
    PreMatchDeg = 30,                  -- 匹配前 Deg
    -- 人体阻抗区域
    Body_Resistance_R = 35,              -- 人体阻抗 R(Q)
    Body_Reactance_X = 36,               -- 人体阻抗 X(Q)
    Current = 37,                   -- 人体电流 (mA)
    -- 匹配后参数区域
    PostMatchW1 = 31,                    -- 匹配后 W1
    PostMatchW2 = 32,                    -- 匹配后 W2
    PostMatchDeg = 33,                  -- 匹配后 Deg
    PostMatchPower = 34,                  -- 匹配后 功率
    
    -- 长脉冲参数区域
    LongPulseW1 = 38,                     -- K脉冲 W1
    LongPulseW2 = 39,                     -- K脉冲 W2
    LongPulseDeg = 40,                    -- K脉冲 Deg
    LongPulsePower = 41,                  -- K脉冲 功率(w)
    MeasuredPower = 42,           -- K脉冲 实测功率(w)
    
    
    -- 控制按钮区域
    Impedance_Head = 34,                 -- 阻抗头部
    Match_Save_Button = 50,                     -- 匹配保存
    Spray_Coolant_Button = 51,                  -- 喷射冷媒
    Start_Treatment_Button = 52,                 -- 开始治疗

    Automatic_Refrigerant_Control = 60,          -- 冷媒自动控制

    PreMatchImpedanceR =44, --匹配前R
    PreMatchImpedanceX = 45,    --匹配前X
    -- 匹配后阻抗区域
    PostMatchImpedanceR = 46,           -- 匹配后 R(Q)
    PostMatchImpedanceX = 47,            -- 匹配后 X(Q)
    Vswr = 48,                           -- Vswr

    --错误码
    Error_Code = 49,                     -- 错误码
    --效率
    Efficiency = 55,

    Result = 54 ,   --结果
    MatchRelayValue = 43 ,   --匹配继电器值
    NegPlateStatus=53, --负极板未连接
    ResultIcon=56,  --结果图标
    Scope_Current = 58,                   -- 示波器电流 (mA)
}

STATUS_VIEW_SCREEN_CONTROL = {
    -- 启动恒压/恒温区域
    Start_Pressure_Temp = 27,    -- 启动恒温 OFF
    Start_Constant_Temp = 28,    -- 启动恒温 OFF
    CoolantPressure = 1,                -- 冷媒压力 (Mpa)
    SolenoidPressure = 2,         -- 电磁阀压 (Mpa)
    CoolantTemp = 3,             -- 冷媒温度 (°C)
    AmpTemp = 21,           -- 放大温度 (°C)
    FootSwitchIcon = 5,           -- 脚踏连接
    HandpieceIcon = 6,            -- 手具连接
    BubbleSensor = 7,                   -- 气泡传感器
    Head1Temp = 8,               -- 头1温度 (°C)
    Head2Temp = 9,              -- 头2温度 (°C)
    Head3Temp = 10,              -- 头3温度 (°C)
    Head4Temp = 11,              -- 头4温度 (°C)
    HandpiecePressure = 12,             -- 手具压力 (°C)
    MagneticForce = 13,                 -- 磁力 (°Cs)

    -- 治疗头参数区域
    Treatment_Head_Type = 14,            -- 治疗头类型
    HeadVersion = 15,         -- 治疗头版本
    HeadId = 16,              -- 治疗头 ID
    TotalCycles = 17,                    -- 总次数
    RemainingCycycles = 19,                -- 剩余次数
    ProduceDate = 20,                -- 生产日期
    MonitorConn = 22,    -- 监测板连接
    UsbConn = 23,                 -- U盘连接
    CRC_Num = 42,
    Body_CRC_Num= 43,
    PressureBase=24,-- 压力基准区域
    ReleaseThreshold = 25,              -- 松开阈值
    ReleaseThreshold_add = 31,                -- 松开阈值加
    ReleaseThreshold_sub = 32,                -- 松开阈值减

    PressThreshold = 26,                -- 按下阈值
    PressThreshold_add = 33,                -- 按下阈值加
    PressThreshold_sub = 34,                -- 按下阈值减
    Save_Threshold = 37,                 -- 保存

    Log_Export=35,    -- 日志导出区域
    Match_Info_Export = 36 ,              -- 匹配信息导出
    Treatment_Head_Skin_Contact = 38 ,--治疗头贴肤
    --错误码
    Error_Code = 39,                     -- 错误码
}

RF_CALIBRATION_SCREEN_CONTROL = {
    -- 当前状态显示区域
    Current_Voltage = 29,                -- 当前电压为：ΔV
    Current_Voltage_add = 44,                -- 当前电压为：ΔV
    Current_Voltage_sub = 45,                -- 当前电压为：ΔV

    Measure_Pulse_Duration = 43,         -- 测量脉冲时长：□ ms
    Measure_Pulse_Duration_add = 46,         -- 测量脉冲时长：□ ms
    Measure_Pulse_Duration_sub = 47,         -- 测量脉冲时长：□ ms
    -- 参数标签区域
    Incident_Wave = 32,                  -- 入射
    Reflection_Phase_Diff = 33,          -- 反射相位差
    Resistance_R = 34,                   -- R
    Reactance_X = 35,                    -- X
    Sn_Real = 36,                        -- Sn 实
    Sn_Imaginary = 37,                   -- Sn 虚
    
    -- 测开路 S11 参数区域 (1-28)
    OpenCircuit_Incident = 1,              -- 测开路 S11 参数1
    OpenCircuit_Reflected = 2,              -- 测开路 S11 参数2
    OpenCircuit_Phase = 3,              -- 测开路 S11 参数3
    OpenCircuit_ResistanceR = 4,              -- 测开路 S11 参数4
    OpenCircuit_ReactanceX = 5,              -- 测开路 S11 参数5
    OpenCircuit_S11Real = 6,              -- 测开路 S11 参数6
    OpenCircuit_S11Imag = 7,              -- 测开路 S11 参数7
    
    ShortCircuit_Incident = 8,              -- 测开路 S11 参数8
    ShortCircuit_Reflected = 9,              -- 测开路 S11 参数9
    ShortCircuit_Phase = 10,            -- 测开路 S11 参数10
    ShortCircuit_ResistanceR = 11,            -- 测开路 S11 参数11
    ShortCircuit_ReactanceX = 12,            -- 测开路 S11 参数12
    ShortCircuit_S11Real = 13,            -- 测开路 S11 参数13
    ShortCircuit_S11Imag = 14,            -- 测开路 S11 参数14

    Load50_Incident = 15,            -- 测开路 S11 参数15
    Load50_Reflected = 16,            -- 测开路 S11 参数16
    Load50_Phase = 17,            -- 测开路 S11 参数17
    Load50_ResistanceR = 18,            -- 测开路 S11 参数18
    Load50_ReactanceX = 19,            -- 测开路 S11 参数19
    Load50_S11Real = 20,            -- 测开路 S11 参数20
    Load50_S11Imag = 21,            -- 测开路 S11 参数21


    LoadMeasurement_Incident = 22,            -- 测开路 S11 参数22
    LoadMeasurement_Reflected = 23,            -- 测开路 S11 参数23
    LoadMeasurement_Phase = 24,            -- 测开路 S11 参数24
    LoadMeasurement_ResistanceR = 25,            -- 测开路 S11 参数25
    LoadMeasurement_ReactanceX = 26,            -- 测开路 S11 参数26
    LoadMeasurement_S11Real = 27,            -- 测开路 S11 参数27
    LoadMeasurement_S11Imag = 28,            -- 测开路 S11 参数28
    
    ED_Real             =30,
    ED_Imag             =31,
    ES_Real             =32,
    ES_Imag             =33,
    ER_Real             =34,
    ER_Imag             =35,
    REALS11_Real        =36,
    REALS11_Imag        =37,
    REALImpedance_Real  =38,
    REALImpedance_Imag  =39,
    -- 测量按钮区域
    Measure_Open_Circuit = 53,           -- 测开路 S11
    Measure_Short_Circuit = 54,          -- 测短路 S11
    Measure_50ohm = 55,                  -- 测 50Ω S11
    Measure_Load = 56,                   -- 测负载 S11
    
    -- 负载测量参数区域
    Load_Measure_1 = 57,                 -- 负载测量参数1
    Load_Measure_2 = 58,                 -- 负载测量参数2
    Load_Measure_3 = 59,                 -- 负载测量参数3
    Load_Measure_4 = 60,                 -- 负载测量参数4
    
    -- 操作按钮区域
    Calculate = 61,                      -- 计算
    Save = 62,                           -- 保存
    
    -- 错误代码区域
    Error_Code = 42                      -- error code
}

Time_Calibration_SCREEN_CONTROL={
    Calibration_Button = 9,
    year =3,
    month = 4,
    day = 5,
    hour = 6,
    minute = 7,
    second = 8,
    Error_Code=11
}

Upgrade_SCREEN_CONTROL={
    Upgrade_Errorcode = 1,
    Upgrade_Progress = 2,
    Upgrade_Confirm = 3,
    Upgrade_ICON= 4,
    Upgrade_Progress_text= 7
}

Power_Debugging_Interface_CONTROL ={
    
    real_text = 8,
    image_text = 9 ,
    real_control = 13 ,
    image_control = 12 ,
    voltage_select_control = 11 ,
    verify_select_control = 43 ,
    upload = 15,
    download = 16 ,
    test_start = 17,
    test_text   = 37 ,
    info_record =14 ,
    avarage_real =32 ,
    avarage_image =34 ,
    person_real =32 ,
    person_image =34 ,
    save_button =4 ,
    Error_Code=5  ,
    file_progress =38 ,
    error_flag1 = 44,--
    Show_Error_Code=40  ,
    Efficiency_threshold= 39,
    save_times = 55,
    Current_Voltage =57,
    Current_VSWR =59
}

Power_Verify_Interface_CONTROL ={
    
    
    real_text = 28,
    real_control = 24,
    image_text = 27 ,
    image_control = 25 ,
    test_start = 21,
    test_stop = 19,
    save_button = 23,
    result_export = 9,
    retest = 15,
    Error_Code= 17  ,
    info_record =35,
    result_threshold =13,
    Geer_select  = 34,
    power_verify_result  = 12,
    file_progress  = 7,
    shengmei_flag_button  = 8,
    yimei_flag_button  = 10,

}

Error_Code_CONTROL= {
    NOW_BUTTON = 2,
    HISTORY_BUTTON = 3,
    NOW_Record = 5,
    HISTORY_Record = 8,

}
local function uart_send_frame(func, addr, data_buf, data_len)
    local buf = {}
    local idx = 0

    -- 帧头
    buf[idx] = 0xEE; idx = idx + 1
    buf[idx] = 0xB5; idx = idx + 1

    -- 功能码
    buf[idx] = 0X04; idx = idx + 1

    -- 数据量
    buf[idx] = 1; idx = idx + 1

    -- 数据长度
    buf[idx] = data_len; idx = idx + 1
    -- 地址
    buf[idx] = (addr >> 8) & 0xFF; idx = idx + 1
    buf[idx] = addr & 0xFF;        idx = idx + 1


    -- 数据区
    for i = 1, data_len do
        buf[idx] = data_buf[i]
        idx = idx + 1
    end

    -- CRC
    local crc = crc16_modbus(buf,1,idx - 1)
    buf[idx] = (crc >> 8) & 0xFF; idx = idx + 1
    buf[idx] = crc & 0xFF;        idx = idx + 1

    -- 帧尾
    buf[idx] = 0xFF; idx = idx + 1
    buf[idx] = 0xFC; idx = idx + 1
    buf[idx] = 0xFF; idx = idx + 1
    buf[idx] = 0xFF

    uart_send_data(buf)
    local hexStrings = {}
    for i, v in ipairs(buf) do
        hexStrings[i] = string.format("%02X", v)
    end
    print(table.concat(hexStrings, " "))
    -- table.insert(pending_messages, buf)
    -- -- start_timer(Timer_ID.MCU_Ack,Timer_Info[Timer_ID.MCU_Ack].timeout,Timer_Info[Timer_ID.MCU_Ack].countdown,Timer_Info[Timer_ID.MCU_Ack].timesrepeat)
    -- sending_in_progress=true
end

-- ================== 变量映射表 ==================
var_write_map = {

    [VAR_ADDR.VerifyCodeText] = function(val,len)
        uart_write_bytes(VAR_ADDR.VerifyCodeText, val)
    end,

    [VAR_ADDR.UpgradeBtn] = function(val,len)
        uart_write_number(VAR_ADDR.UpgradeBtn, val, 1)
    end,

    [VAR_ADDR.ModeCtrl] = function(val,len)
        uart_write_number(VAR_ADDR.ModeCtrl, val, 1)
    end,

    [VAR_ADDR.PowerLevel] = function(val,len)
        uart_write_number(VAR_ADDR.PowerLevel, val, 2)
    end,



    [VAR_ADDR.VibrateBtn] = function(val,len)
        uart_write_number(VAR_ADDR.VibrateBtn, val, 1)
    end,

    [VAR_ADDR.EngineerInput] =  function(val,len)
        uart_write_number(VAR_ADDR.EngineerInput, val, 1)
    end,

    [VAR_ADDR.VoltAdjustData] = function(val,len)
        uart_write_number(VAR_ADDR.VoltAdjustData, val, 2)
    end,

    -- [VAR_ADDR.LevelAdjustData] = function(val,len)
    --     uart_write_number(VAR_ADDR.VAR_MONITOR_CONNECTED, val, 1)
    -- end,

    [VAR_ADDR.RfSwitch] = function(val,len)
        uart_write_number(VAR_ADDR.RfSwitch, val, 1)
    end,

    [VAR_ADDR.VoltAdjustMode] = function(val,len)
        uart_write_number(VAR_ADDR.VoltAdjustMode, val, 1)
    end,

    [VAR_ADDR.OutputLimit] = function(val,len)
        uart_write_number(VAR_ADDR.OutputLimit, val, 1)
    end,

    [VAR_ADDR.NegPlateLimit] = function(val,len)
        uart_write_number(VAR_ADDR.NegPlateLimit, val, 1)
    end,

    [VAR_ADDR.LcrSwitch] =function(val,len)
        uart_write_number(VAR_ADDR.LcrSwitch, val, 1)
    end,

    [VAR_ADDR.MatchPulseDur] = function(val,len)
        uart_write_number(VAR_ADDR.MatchPulseDur, val, 2)
    end,

    [VAR_ADDR.MatchPulseInt] = function(val,len)
        uart_write_number(VAR_ADDR.MatchPulseInt, val, 2)
    end,

    [VAR_ADDR.CoolantDur] = function(val,len)
        uart_write_number(VAR_ADDR.CoolantDur, val, 2)
    end,

    [VAR_ADDR.Test_Count] = function(val,len)
        uart_write_number(VAR_ADDR.Test_Count, val, 2)
    end,

    [VAR_ADDR.K_Pulse_Duration_Plus] = function(val,len)
        uart_write_number(VAR_ADDR.K_Pulse_Duration_Plus, val, 2)
    end,

    [VAR_ADDR.K_Pulse_Interval_Plus] = function(val,len)
        uart_write_number(VAR_ADDR.K_Pulse_Interval_Plus, val, 2)
    end,

    [VAR_ADDR.K_Pulse_Count_Plus] = function(val,len)
        uart_write_number(VAR_ADDR.K_Pulse_Count_Plus, val, 2)
    end,
    
    [VAR_ADDR.Test_Interval] = function(val,len)
        uart_write_number(VAR_ADDR.Test_Interval, val, 2)
    end,
    
    [VAR_ADDR.Impedance_R] = function(val,len)
        uart_write_number(VAR_ADDR.Impedance_R, val, 2)
    end,

    [VAR_ADDR.Impedance_X] = function(val,len)
        uart_write_number(VAR_ADDR.Impedance_X, val, 2)
    end,

    [VAR_ADDR.CurrentRecord] = function(val,len)
        uart_write_number(VAR_ADDR.CurrentRecord, val, 2)
    end,

    [VAR_ADDR.PressThreshold] = function(val,len)
        uart_write_number(VAR_ADDR.PressThreshold, val, 2)
    end,

    [VAR_ADDR.ReleaseThreshold] = function(val,len)
        uart_write_number(VAR_ADDR.ReleaseThreshold, val, 2)
    end,

    [VAR_ADDR.Switch_Info] = function(val,len)
        uart_write_number(VAR_ADDR.Switch_Info, val, 4)
    end,
    
    [VAR_ADDR.Measure_Pulse_Duration] =function(val,len)
        uart_write_number(VAR_ADDR.Measure_Pulse_Duration, val, 4)
    end,
    
    [VAR_ADDR.Current_Voltage] =function(val,len)
        uart_write_number(VAR_ADDR.Current_Voltage, val, 4)
    end,
      
    [VAR_ADDR.Time_Cali] =function(val,len)
        uart_write_number(VAR_ADDR.Time_Cali, val, 4)
    end,

    [VAR_ADDR.File_Screen_ERROR] = function(val,len)
        uart_write_number(VAR_ADDR.File_Screen_ERROR, val, 1)
    end,

    [VAR_ADDR.File_Send_Screen_ERROR] = function(val,len)
        uart_write_number(VAR_ADDR.File_Send_Screen_ERROR, val, 1)
    end,
    [VAR_ADDR.Volt_select] = function(val,len)
        uart_write_bytes(VAR_ADDR.Volt_select, val, 1)
    end,

    [VAR_ADDR.File_Send_Data] = function(val,len)
        uart_write_bytes(VAR_ADDR.File_Send_Data, val, 1)
    end,
    [VAR_ADDR.File_Send_Creat] = function(val,len)
        uart_write_bytes(VAR_ADDR.File_Send_Creat, val, 1)
    end,
    [VAR_ADDR.Verify_File_Send_Info_MCU] = function(val,len)
        uart_write_bytes(VAR_ADDR.Verify_File_Send_Info_MCU, val, 1)
    end,
    [VAR_ADDR.Verify_File_Send_Data_MCU] = function(val,len)
        uart_write_bytes(VAR_ADDR.Verify_File_Send_Data_MCU, val, 1)
    end,
    [VAR_ADDR.RF_start_select] = function(val,len)
        uart_write_number(VAR_ADDR.RF_start_select, val, 1)
    end,
}

var_read_map = {

    -- 数值（2字节）
    [VAR_ADDR.Model] = function(data)
            local str = ""
            for i = 1, #data do
                if data[i] == 0x00 then 
                    break 
                end
                str = str .. string.char(data[i])
            end
            print("Model"..str)
            set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Model,str)
            set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Treatment_Head_Type,str)
    end,
    -- UID（16字节）

    -- 日期
    [VAR_ADDR.Date] = function(data)

        set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Date,data[4]..data[3].."-"..data[2].."-"..data[1])
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.ProduceDate,data[4]..data[3].."-"..data[2].."-"..data[1])

    end,

    [VAR_ADDR.VerifyQrCode] = function(data)
        local str = ""
        for i = 1, #data do
            if data[i] == 0x00 then 
                break 
            end
            str = str .. string.char(data[i])
        end
        print("VerifyQrCode"..str)
        if str == "" then
            print("验证码为空"..str)
            set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.QR_Code_Verification,"")
        else
            set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.QR_Code_Verification,str)
        end
    end,
    
    [VAR_ADDR.ModeCtrl] = function(data)
        local v = data[1]
        Current_info.Model = v
        if v == 0 then
            set_value (SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Classic_Mode_Button,1)
            set_value (SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Comfort_Mode_Button,0)

            set_value (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Classic_Mode_Button,1)
            set_value (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Comfort_Mode_Button,0)

            
        elseif v == 1 then
            set_value (SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Classic_Mode_Button,0)
            set_value (SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Comfort_Mode_Button,1)

            set_value (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Classic_Mode_Button,0)
            set_value (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Comfort_Mode_Button,1)

        end
    end,
    
    [VAR_ADDR.PowerLevel] = function(data)
        local v = data[1]
        Current_info.Gear = v/10
        set_text (SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Gear_Text,Current_info.Gear)
        set_text (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Gear_Text,Current_info.Gear)
        set_text (SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Gear_Text,Current_info.Gear)
    end,
    
    [VAR_ADDR.Head_Ok] = function(data)
        local v = data[1]
        print("Head_Ok="..v)
        Current_info.Head_Ok = v
        local i =0
        for i =0 , 12 , 1 do 
            set_enable (SCREENID.Treatment_Not_Recognized_SCREEN,i,Current_info.Head_Ok)
        end
        if v == 0 then
            NO_head_clear()
        else
            set_visiable(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.QR_Code_Verification,1)
        end
    end,
    
    [VAR_ADDR.TreatmentProgress] = function(data)
        local v = data[1] 
        print("TreatmentProgress:", v)
        set_value(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Treatment_Progress_Icon,v)
        set_value (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Treatment_Progress_Icon,v)
        set_value (SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Treatment_Progress_Icon,v)
        set_value(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Treatment_Progress_Icon,v)
    end,
    
    [VAR_ADDR.HeadIcon] = function(data)
        local v = data[1] 
        print("HeadIcon:", v)
        set_value(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Treatment_Complete_Icon,v)
        set_value (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Treatment_Complete_Icon,v)
        set_value (SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Treatment_Complete_Icon,v)
        set_value(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Treatment_Complete_Icon,v)
        if v == 4 then
            NO_head_clear()
        end 
    end,
    [VAR_ADDR.RF_state] = function(data)
        local v = data[1] 
        print("RF_state:", v)
        Process_Screen_Enable(1-data[1])
    end,
    
    [VAR_ADDR.ErrorInput] = function(data)
        local v = data[1] | (data[2] << 8)
        local title, solution, errorType, level = GetErrorMessage(v)
        
        print("ErrorInput:", v)
        print("title:", title)
        print("solution:", solution)
        print("errorType:", errorType)

        set_text(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Warning_Code,numberToE00Fixed(v).." "..title)
        set_text(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Warning_Details,solution)
        set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Warning_Code,numberToE00Fixed(v).." "..title)
        set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Warning_Details,solution)

        set_text (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Warning_Code,numberToE00Fixed(v).." "..title)
        set_text (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Warning_Details,solution)
        
        set_text (SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Warning_Code,numberToE00Fixed(v).." "..title)
        set_text (SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Warning_Details,solution)
    end,
    
    [VAR_ADDR.Upgrade_Error_Input] = function(data)
        local v = data[1] | (data[2] << 8)
        if v~= 0 then
            
            local title, solution, errorType, level = GetErrorMessage(v)
            
            print("ErrorInput:", v)
            print("title:", title)
            print("solution:", solution)
            print("errorType:", errorType)
            set_text(SCREENID.Upgrade_SCREEN,Upgrade_SCREEN_CONTROL.Upgrade_Errorcode,numberToE00Fixed(v).." "..title)
            set_value(SCREENID.Upgrade_SCREEN,Upgrade_SCREEN_CONTROL.Upgrade_ICON,2)
        else
            set_text(SCREENID.Upgrade_SCREEN,Upgrade_SCREEN_CONTROL.Upgrade_Errorcode,"")
            set_value(SCREENID.Upgrade_SCREEN,Upgrade_SCREEN_CONTROL.Upgrade_ICON,0)
        end

    end,
    
    [VAR_ADDR.Setting_Error_Input] = function(data)
        local v = data[1] | (data[2] << 8)
        local title, solution, errorType, level = GetErrorMessage(v)
        
        print("ErrorInput:", v)
        print("title:", title)
        print("solution:", solution)
        print("errorType:", errorType)
        start_timer(Timer_ID.Error_Code_Clear,Timer_Info[Timer_ID.Error_Code_Clear].timeout,Timer_Info[Timer_ID.Error_Code_Clear].countdown,Timer_Info[Timer_ID.Error_Code_Clear].timesrepeat)
        print ("timer:start")
        set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
        set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Error_Code,numberToE00Fixed(v))
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
        set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
        set_text(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
        set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Error_Code,numberToE00Fixed(v))
        set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Show_Error_Code,numberToE00Fixed(v))
        set_text(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.Error_Code,numberToE00Fixed(v))
        
        if v ~=ERROR_ADDR.ErrorHandpieceOverheat  and v ~=ERROR_ADDR.ErrorNegativePlateDisconnected then
            
            Power_test_screen_control_enable(1)
            Power_verify_screen_control_enable(1)
            stop_timer(Timer_ID.RF_Start)
            stop_timer(Timer_ID.Verify_Gear_RF_Timer)
            if Current_info.Rf_Test_Flag ~= 0 then
                RF_Test_Init()
            end
            if Current_info.Verify_Rf_Test_Flag ~= 0 then
                Verify_RF_Test_Init()
            end
        end
    end,
    
    [VAR_ADDR.CoolantIcon] = function(data)
        local v = data[1] 
        set_value(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Refrigerant_icon,v)
        set_value(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Refrigerant_icon,v)
        set_value (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Refrigerant_icon,v)
        set_value (SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Refrigerant_icon,v)
        print("Refrigeration_Icon:", v)
    end,
    
    [VAR_ADDR.CoolLevel] = function(data)
        local v = data[1] 
        set_value(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Refrigeration_Icon,v)
        set_value (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Refrigeration_Icon,v)
        set_value (SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Refrigeration_Icon,v)
        print("CoolLevel:", v)
    end,
    
    [VAR_ADDR.UpgradeProgress] = function(data)
        local v = data[1] 
        set_value(SCREENID.Upgrade_SCREEN,Upgrade_SCREEN_CONTROL.Upgrade_Progress,v)
        set_value(SCREENID.Upgrade_SCREEN,Upgrade_SCREEN_CONTROL.Upgrade_Progress_text,v)
        print("Upgrade_Progress:", v)
    end,
    
    [VAR_ADDR.UsedTotalShots] = function(data)
        local str = ""
        local total_count =  0 
        local used_count = 0
        used_count = data[2]*256+data[1]
        total_count = data[4]*256+data[3]
        print("UsedTotalShots"..used_count.."/"..total_count)

        set_text(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Totalused_Headcount,used_count.."/"..total_count)
        set_text (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Totalused_Headcount,used_count.."/"..total_count)
        set_text (SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Totalused_Headcount,used_count.."/"..total_count)
        set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Pulse_Count,total_count-used_count)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.TotalCycles,total_count)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.RemainingCycycles,(total_count-used_count))
    end,
    
    [VAR_ADDR.DeviceModel] = function(data)

        local str = ""
        for i = 1, #data do
            if data[i] == 0x00 then 
                break 
            end
            str = str .. string.char(data[i])
        end
        print("DeviceModel"..str)
        set_text(SCREENID.Setting_SCREEN,Setting_SCREEN_CONTROL.Device_Model,str)
    end,
    
    [VAR_ADDR.MonitorVer] = function(data)
        local v = data[1] +data[2]*256
        local str=formatNumber5Digits(v)
        set_text(SCREENID.Setting_SCREEN,Setting_SCREEN_CONTROL.Monitoring_Version,str)
        print("Monitoring_Version:", v)
    end,
    
    [VAR_ADDR.MainCtrlVer] = function(data)
        local v = data[1] +data[2]*256
        local str=formatNumber5Digits(v)
        set_text(SCREENID.Setting_SCREEN,Setting_SCREEN_CONTROL.Main_Control_Version,str)
        print("Main_Control_Version:", v)
    end,
    
    [VAR_ADDR.HandpieceVer] = function(data)
        local v = data[1] +data[2]*256
        local str=formatNumber5Digits(v)
        set_text(SCREENID.Setting_SCREEN,Setting_SCREEN_CONTROL.Handtool_Version,str)
        print("Handtool_Version:", v)
    end,
    
    [VAR_ADDR.Uid] = function(data)

        local str = string.format("%02X%02X%02X%02X", data[4], data[3], data[2], data[1])
        set_text(SCREENID.Setting_SCREEN,Setting_SCREEN_CONTROL.UID,str)
        print("Uid:", str)
        
    end,
    
    [VAR_ADDR.Voice_Adjustment] = function(data)

        local v = data[1]
        set_value(SCREENID.Setting_SCREEN,Setting_SCREEN_CONTROL.Voice_Progress,v)
        set_value(SCREENID.Setting_SCREEN,Setting_SCREEN_CONTROL.Voice_Slider,v)
        print("Voice_Adjustment:", v)
        
    end,
    
    [VAR_ADDR.EngineerQrCode] = function(data)
        local str = ""
        for i = 1, #data do
            if data[i] == 0x00 then 
                break 
            end
            str = str .. string.char(data[i])
        end
        print("EngineerQrCode"..str)
        set_text(SCREENID.Engineer_Password_SCREEN,Engineer_Password_SCREEN_CONTROL.Engineer_QR_CODE,str)
    end,
    
    [VAR_ADDR.VoltAdjustData] = function(data)
        print("Voltage_Value:", Current_info.Voltage_Value)
        Current_info.Voltage_Value=(data[1] +data[2]*256)/10
        set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value,Current_info.Voltage_Value)
        set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Relay_VoltAdjustData,Current_info.Voltage_Value)
    end,

    -- [VAR_ADDR.Relay_VoltAdjustData] = function(data)
    --     print("Voltage_Value:", Current_info.Relay_VoltAdjustData)
    --     Current_info.Relay_VoltAdjustData=(data[1] +data[2]*256)/10
    --     print("Voltage_Value:", Current_info.Relay_VoltAdjustData)
    --     set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Relay_VoltAdjustData,Current_info.Relay_VoltAdjustData)
    -- end,

    [VAR_ADDR.Wave1Amplitude] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Wave1_Amplitude,valuebuf)
        set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.W1,valuebuf)
        print("Wave1Amplitude:", value)
    end,
    
    [VAR_ADDR.Wave2Amplitude] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Wave2_Amplitude,valuebuf)
        set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.W2,valuebuf)
        print("Wave2Amplitude:", data)
    end,
    
    [VAR_ADDR.PhaseDiff] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Phase_Difference,valuebuf)
        print("PhaseDiff:", data)
    end,
    
    [VAR_ADDR.ImpedanceR] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Resistance_R,valuebuf)
        set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.R,valuebuf)
        print("ImpedanceR:", data)
    end,
    
    [VAR_ADDR.ImpedanceX] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Reactance_X,valuebuf)
        set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.X,valuebuf)
        print("ImpedanceX:", data)
    end,
    
    [VAR_ADDR.PowerDetect] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Power_Detection_Value,valuebuf)
        print("PowerDetect:", data)
    end,
    
    [VAR_ADDR.PreMatchW1] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PreMatchW1,valuebuf)
        print("PreMatchW1:", data)
    end,
    
    [VAR_ADDR.PreMatchW2] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PreMatchW2,valuebuf)
        print("PreMatchW2:", data)
    end,
    
    [VAR_ADDR.PreMatchDeg] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PreMatchDeg,valuebuf)
        print("PreMatchDeg:", data)
    end,
    
    [VAR_ADDR.PostMatchW1] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PostMatchW1,valuebuf)
        print("PostMatchW1:", data)
    end,
    
    [VAR_ADDR.PostMatchW2] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PostMatchW2,valuebuf)
        print("PostMatchW2:", data)
    end,
    
    [VAR_ADDR.PostMatchDeg] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PostMatchDeg,valuebuf)
        print("PostMatchDeg:", data)
    end,
    
    [VAR_ADDR.PostMatchPower] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PostMatchPower,valuebuf)
        print("PostMatchPower:", data)
    end,
    
    [VAR_ADDR.Body_Resistance_R] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Body_Resistance_R,valuebuf)
        print("Body_Resistance_R:", data)
    end,
    
    [VAR_ADDR.Body_Reactance_X] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Body_Reactance_X,valuebuf)
        print("Body_Reactance_X:", data)
    end,
    
    [VAR_ADDR.Current] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Current,valuebuf)
        print("Current:", data)
    end,
    
    [VAR_ADDR.LongPulseW1] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.LongPulseW1,valuebuf)
        print("LongPulseW1:", data)
    end,
    
    [VAR_ADDR.LongPulseW2] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.LongPulseW2,valuebuf)
        print("LongPulseW2:", data)
    end,
    
    [VAR_ADDR.LongPulseDeg] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.LongPulseDeg,valuebuf)
        print("LongPulseDeg:", data)
    end,
    
    [VAR_ADDR.LongPulsePower] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.LongPulsePower,valuebuf)
        print("LongPulsePower:", data)
    end,
    
    [VAR_ADDR.Efficiency] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Efficiency,valuebuf)
        print("Efficiency:", data)
    end,
    
    [VAR_ADDR.MeasuredPower] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.MeasuredPower,valuebuf)
        print("MeasuredPower:", data)
    end,
    -- [VAR_ADDR.ImpedanceReal] = function(data)
    --     local data = data[1] | (data[2] << 8)
    --     set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Matched_Power,data)
    --     print("ImpedanceReal:", data)
    -- end,
    -- [VAR_ADDR.ImpedanceImag] = function(data)
    --     local data = data[1] | (data[2] << 8)
    --     set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Matched_Power,data)
    --     print("ImpedanceImag:", data)
    -- end,
    [VAR_ADDR.Result] = function(data)
        local str = ""
        for i = 1, #data do
            if data[i] == 0x00 then 
                break 
            end
            str = str .. string.char(data[i])
        end
        print("Result"..str)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Result,str)
    end,
    
    [VAR_ADDR.MatchRelayValue] = function(data)
        local v = data[1] | (data[2] << 8)|(data[3] << 16) | (data[4] << 24)
        local str= getFirst21BitsToBinary2(v)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.MatchRelayValue,str)
        print("MatchRelayValue:", v)
    end,
    
    [VAR_ADDR.NegPlateStatus] = function(data)
        local v = data[1]
        set_value(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.NegPlateStatus,v)
        print("NegPlateStatus:", v)
    end,
    
    [VAR_ADDR.ResultIcon] = function(data)
        local v = data[1] 
        set_value(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.ResultIcon,v)
        print("ResultIcon:", v)
    end,
    
    [VAR_ADDR.PreMatchImpedanceR] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PreMatchImpedanceR,valuebuf)
        print("PreMatchImpedanceR:", valuebuf)
    end,
    
    [VAR_ADDR.PreMatchImpedanceX] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PreMatchImpedanceX,valuebuf)
        print("PreMatchImpedanceX:", valuebuf)
    end,
    
    [VAR_ADDR.Scope_Current] = function(data)
        local value = 0.0
        value=bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", (value/1000))
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Scope_Current,valuebuf)
        print("Scope_Current:", valuebuf)
    end,

    [VAR_ADDR.PostMatchImpedanceR] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PostMatchImpedanceR,valuebuf)
        print("PostMatchImpedanceR:", valuebuf)
    end,
    
    [VAR_ADDR.PostMatchImpedanceX] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PostMatchImpedanceX,valuebuf)
        print("PostMatchImpedanceX:", valuebuf)
    end,
    
    [VAR_ADDR.Vswr] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.2f", value)
        set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Vswr,valuebuf)
        print("Vswr:", valuebuf)
    end,

    [VAR_ADDR.CoolantPressure] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.2f", value)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.CoolantPressure,valuebuf)
        print("CoolantPressure:", valuebuf)
    end,

    [VAR_ADDR.SolenoidPressure] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.2f", value)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.SolenoidPressure,valuebuf)
        print("SolenoidPressure:", valuebuf)
    end,

    [VAR_ADDR.CoolantTemp] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.CoolantTemp,valuebuf)
        print("CoolantTemp:", valuebuf)
    end,

    [VAR_ADDR.AmpTemp] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.AmpTemp,valuebuf)
        print("AmpTemp:", valuebuf)
    end,

    [VAR_ADDR.FootSwitchIcon] = function(data)
        local v = data[1]
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.FootSwitchIcon,v)
        print("FootSwitchIcon:", v)
    end,

    [VAR_ADDR.HandpieceIcon] = function(data)
        local v = data[1] 
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.HandpieceIcon,v)
        print("HandpieceIcon:", v)
    end,

    [VAR_ADDR.BubbleSensor] = function(data)
        local v = data[1] 
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.BubbleSensor,v)
        print("BubbleSensor:", v)
    end,

    [VAR_ADDR.Head1Temp] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Head1Temp,valuebuf)
        print("Head1Temp:", valuebuf)
    end,

    [VAR_ADDR.Head2Temp] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Head2Temp,valuebuf)
        print("Head2Temp:", valuebuf)
    end,

    [VAR_ADDR.Head3Temp] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Head3Temp,valuebuf)
        print("Head3Temp:", valuebuf)
    end,

    [VAR_ADDR.Head4Temp] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Head4Temp,valuebuf)
        print("Head4Temp:", valuebuf)
    end,

    [VAR_ADDR.HandpiecePressure] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.HandpiecePressure,valuebuf)
        print("HandpiecePressure:", valuebuf)
    end,

    [VAR_ADDR.MagneticForce] = function(data)
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.MagneticForce,valuebuf)
        print("MagneticForce:", valuebuf)
    end,

    [VAR_ADDR.HeadVersion] = function(data)
        local v = data[1] | (data[2] << 8)
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.HeadVersion,v)
        print("HeadVersion:", v)
    end,

    [VAR_ADDR.HeadId] = function(data)
        
        local str = formatHexData(data)
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.HeadId,str)
        print("HeadId:", str)
    end,

    [VAR_ADDR.Switch_Info] = function(data)
        local bits = {}
        local v = data[1] | (data[2] << 8)| (data[3] << 16) | (data[4] << 24)
        for i = 0, 21 do
            set_value(SCREENID.Relay_Control_SCREEN,i+1,(v >> i) & 1)
        end
    end,

    [VAR_ADDR.TotalCycles] = function(data)
        local v = data[1] | (data[2] << 8)
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.TotalCycles,v)
        print("TotalCycles:", v)
    end,

    [VAR_ADDR.RemainingCycycles] = function(data)
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.RemainingCycycles,v)
        local v = data[1] | (data[2] << 8)
        print("RemainingCycycles:", v)
    end,
    -- [VAR_ADDR.ProduceDate] = function(data)
    --     local v = data[1] | (data[2] << 8)
    --     set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.ProduceDate,v)
    --     print("TotalCycles:", v)
    -- end,
    [VAR_ADDR.MonitorConn] = function(data)
        local v = data[1]
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.MonitorConn,v)
        print("MonitorConn:", v)
    end,

    [VAR_ADDR.UsbConn] = function(data)
        local v = data[1]
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.UsbConn,v)
        print("UsbConn:", v)
    end,
   
    [VAR_ADDR.CRC_Num] = function(data)
        
        local str = string.format("%02X%02X%02X%02X", data[4], data[3], data[2], data[1])
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.CRC_Num,str)
        print("CRC_Num:", str)
    end,
    [VAR_ADDR.Body_CRC_Num] = function(data)
        
        local str = string.format("%02X%02X%02X%02X", data[4], data[3], data[2], data[1])
        set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Body_CRC_Num,str)
        print("Body_CRC_Num:", str)
    end,

    [VAR_ADDR.Treatment_Head_Skin_Contact] = function(data)
        local v = data[1]
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Treatment_Head_Skin_Contact,v)
        print("Treatment_Head_Skin_Contact:", v)
    end,
    
    [VAR_ADDR.PressureBase] = function(data)
        local v = data[1]| (data[2] << 8)
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.PressureBase,v)
        print("PressureBase:", v)
    end,
    
    [VAR_ADDR.ReleaseThreshold] = function(data)
        local v = data[1]| (data[2] << 8)
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.ReleaseThreshold,v)
        print("ReleaseThreshold:", v)
    end,

    [VAR_ADDR.PressThreshold] = function(data)
        local v = data[1]| (data[2] << 8)
        set_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.PressThreshold,v)
        print("PressThreshold:", v)
    end,

    [VAR_ADDR.Test_Count] = function(data)
        local v = data[1] | (data[2] << 8)
        print("Test_Count:", v)
    end,
    [VAR_ADDR.TestInterval] = function(data)
        local v = data[1] | (data[2] << 8)
        print("TestInterval:", v)
    end,

    -- ==================================================
    -- 射频校准信息（RF Calibration）
    -- ==================================================

    -- ================= 开路 Open Circuit =================
    [VAR_ADDR.OpenCircuit_Incident] = function(data)
        if DEBUGFLAG == 1 then
            print("OpenCircuit_Incident =",bytesToFloatLE_manual(data) )
        end
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.OpenCircuit_Incident,valuebuf)
    end,

    [VAR_ADDR.OpenCircuit_Reflected] = function(data)
        if DEBUGFLAG == 1 then
            print("OpenCircuit_Reflected =", bytesToFloatLE_manual(data) )
        end
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
        set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.OpenCircuit_Reflected,valuebuf)
    end,

    [VAR_ADDR.OpenCircuit_Phase] = function(data)

        if DEBUGFLAG == 1 then
            print("OpenCircuit_Phase =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
            local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.OpenCircuit_Phase,valuebuf)
        end

    end,

    [VAR_ADDR.OpenCircuit_ResistanceR] = function(data)
        if DEBUGFLAG == 1 then
            print("OpenCircuit_ResistanceR =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
            local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.OpenCircuit_ResistanceR,valuebuf)
        end
    end,

    [VAR_ADDR.OpenCircuit_ReactanceX] = function(data)
        if DEBUGFLAG == 1 then
            print("OpenCircuit_ReactanceX =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
            local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.OpenCircuit_ReactanceX,valuebuf)
        end
    end,

    [VAR_ADDR.OpenCircuit_S11Real] = function(data)
        if DEBUGFLAG == 1 then
            print("OpenCircuit_S11Real =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
            local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.OpenCircuit_S11Real,valuebuf)
        end
    end,

    [VAR_ADDR.OpenCircuit_S11Imag] = function(data)
        if DEBUGFLAG == 1 then
            print("OpenCircuit_S11Imag =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
            local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.OpenCircuit_S11Imag,valuebuf)
        end
    end,

    -- ================= 短路 Short Circuit =================
    [VAR_ADDR.ShortCircuit_Incident] = function(data)
        if DEBUGFLAG == 1 then
            print("ShortCircuit_Incident =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
            local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ShortCircuit_Incident,valuebuf)
        end
    end,

    [VAR_ADDR.ShortCircuit_Reflected] = function(data)
        if DEBUGFLAG == 1 then
            print("ShortCircuit_Reflected =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
            local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ShortCircuit_Reflected,valuebuf)
        end
    end,

    [VAR_ADDR.ShortCircuit_Phase] = function(data)
        if DEBUGFLAG == 1 then
            print("ShortCircuit_Phase =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
            local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ShortCircuit_Phase,valuebuf)
        end
    end,

    [VAR_ADDR.ShortCircuit_ResistanceR] = function(data)
        if DEBUGFLAG == 1 then
            print("ShortCircuit_ResistanceR =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ShortCircuit_ResistanceR,valuebuf)
        end
    end,

    [VAR_ADDR.ShortCircuit_ReactanceX] = function(data)
        if DEBUGFLAG == 1 then
            print("ShortCircuit_ReactanceX =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ShortCircuit_ReactanceX,valuebuf)
        end
    end,

    [VAR_ADDR.ShortCircuit_S11Real] = function(data)
        if DEBUGFLAG == 1 then
            print("ShortCircuit_S11Real =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ShortCircuit_S11Real,valuebuf)
        end
    end,

    [VAR_ADDR.ShortCircuit_S11Imag] = function(data)
        if DEBUGFLAG == 1 then
            print("ShortCircuit_S11Imag =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ShortCircuit_S11Imag,valuebuf)
        end
    end,

    -- ================= 50Ω 负载 Load50 =================
    [VAR_ADDR.Load50_Incident] = function(data)
        if DEBUGFLAG == 1 then
            print("Load50_Incident =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Load50_Incident,valuebuf)
        end
    end,

    [VAR_ADDR.Load50_Reflected] = function(data)
        if DEBUGFLAG == 1 then
            print("Load50_Reflected =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Load50_Reflected,valuebuf)
        end
    end,

    [VAR_ADDR.Load50_Phase] = function(data)
        if DEBUGFLAG == 1 then
            print("Load50_Phase =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Load50_Phase,valuebuf)
        end
    end,

    [VAR_ADDR.Load50_ResistanceR] = function(data)
        if DEBUGFLAG == 1 then
            print("Load50_ResistanceR =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Load50_ResistanceR,valuebuf)
        end
    end,

    [VAR_ADDR.Load50_ReactanceX] = function(data)
        if DEBUGFLAG == 1 then
            print("Load50_ReactanceX =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Load50_ReactanceX,valuebuf)
        end
    end,

    [VAR_ADDR.Load50_S11Real] = function(data)
        if DEBUGFLAG == 1 then
            print("Load50_S11Real =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Load50_S11Real,valuebuf)
        end
    end,

    [VAR_ADDR.Load50_S11Imag] = function(data)
        if DEBUGFLAG == 1 then
            print("Load50_S11Imag =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Load50_S11Imag,valuebuf)
        end
    end,

    -- ================= 实际负载 Load Measurement =================
    [VAR_ADDR.LoadMeasurement_Incident] = function(data)
        if DEBUGFLAG == 1 then
            print("LoadMeasurement_Incident =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.LoadMeasurement_Incident,valuebuf)
        end
    end,

    [VAR_ADDR.LoadMeasurement_Reflected] = function(data)
        if DEBUGFLAG == 1 then
            print("LoadMeasurement_Reflected =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.LoadMeasurement_Reflected,valuebuf)
        end
    end,

    [VAR_ADDR.LoadMeasurement_Phase] = function(data)
        if DEBUGFLAG == 1 then
            print("LoadMeasurement_Phase =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.LoadMeasurement_Phase,valuebuf)
        end
    end,

    [VAR_ADDR.LoadMeasurement_ResistanceR] = function(data)
        if DEBUGFLAG == 1 then
            print("LoadMeasurement_ResistanceR =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.LoadMeasurement_ResistanceR,valuebuf)
        end
    end,

    [VAR_ADDR.LoadMeasurement_ReactanceX] = function(data)
        if DEBUGFLAG == 1 then
            print("LoadMeasurement_ReactanceX =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.LoadMeasurement_ReactanceX,valuebuf)
        end
    end,

    [VAR_ADDR.LoadMeasurement_S11Real] = function(data)
        if DEBUGFLAG == 1 then
            print("LoadMeasurement_S11Real =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.LoadMeasurement_S11Real,valuebuf)
        end
    end,

    [VAR_ADDR.LoadMeasurement_S11Imag] = function(data)
        if DEBUGFLAG == 1 then
            print("LoadMeasurement_S11Imag =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.LoadMeasurement_S11Imag,valuebuf)
        end
    end,
    
    [VAR_ADDR.ED_Real] = function(data)
        if DEBUGFLAG == 1 then
            print("ED_Real =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ED_Real,valuebuf)
        end
    end,
    
    [VAR_ADDR.ED_Imag] = function(data)
        if DEBUGFLAG == 1 then
            print("ED_Imag =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ED_Imag,valuebuf)
        end
    end,
    
    [VAR_ADDR.ES_Real] = function(data)
        if DEBUGFLAG == 1 then
            print("ES_Real =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ES_Real,valuebuf)
        end
    end,
    
    [VAR_ADDR.ES_Imag] = function(data)
        if DEBUGFLAG == 1 then
            print("ES_Imag =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ES_Imag,valuebuf)
        end
    end,
    
    [VAR_ADDR.ER_Real] = function(data)
        if DEBUGFLAG == 1 then
            print("ER_Real =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ER_Real,valuebuf)
        end
    end,
    
    [VAR_ADDR.ER_Imag] = function(data)
        if DEBUGFLAG == 1 then
            print("ER_Imag =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.ER_Imag,valuebuf)
        end
    end,
    
    [VAR_ADDR.REALS11_Imag] = function(data)
        if DEBUGFLAG == 1 then
            print("REALS11_Imag =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
            local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.REALS11_Imag,valuebuf)
        end
    end,
    
    [VAR_ADDR.REALS11_Real] = function(data)
        if DEBUGFLAG == 1 then
            print("REALS11_Real =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.REALS11_Real,valuebuf)
        end
    end,
    
    [VAR_ADDR.REALImpedance_Real] = function(data)
        if DEBUGFLAG == 1 then
            print("REALImpedance_Real =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.REALImpedance_Real,valuebuf)
        end
    end,
    
    [VAR_ADDR.REALImpedance_Imag] = function(data)
        if DEBUGFLAG == 1 then
            print("REALImpedance_Imag =", bytesToFloatLE_manual(data))
            local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.1f", value)
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.REALImpedance_Imag,valuebuf)
        end
    end,
    
    [VAR_ADDR.Coordinates] = function(data)
        if DEBUGFLAG == 1 then
            print("Coordinates =", (data[1] | (data[2] << 8))  .." "..((data[3] )|(data[4] << 8)))
        end
        local radius =156
        local Origin_X = 1056
        local Origin_Y = 584

        local valueX =( data[1] | (data[2] << 8))/1000
        local valueY = ((data[3] )|(data[4] << 8))/1000
        if valueY>20 then
            valueY = valueY-65.536
        end
        local r = valueX
        local x = valueY

        local denominator = (r+1)*(r+1) + x*x

        local Re = (r*r + x*x -1)/denominator
        local Im = (2*x)/denominator

        local Current_X = tonumber(string.format("%.0f",Origin_X + radius*Re))
        local Current_Y = tonumber(string.format("%.0f",Origin_Y - radius*Im))

        -- if valueY == 0 then
        --     valueY = 0.0001
        -- end
        -- if valueX <= -0.999 then
        --     valueX = -0.999
        -- end
        -- local Reactance_Circle_r = radius/(valueX+1)
        -- local Reactance_Arc_r = radius/valueY

        -- local sin2 = 2*Reactance_Circle_r*Reactance_Arc_r/(Reactance_Circle_r*Reactance_Circle_r+Reactance_Arc_r*Reactance_Arc_r)
        -- local Py = sin2 * Reactance_Circle_r
        -- local Px = math.sqrt(Reactance_Circle_r*Reactance_Circle_r-Py*Py)
        -- local Current_X = tonumber(string.format("%.0f",Origin_X + radius - Reactance_Circle_r - Px))
        -- -- if valueY > 0 then
        -- --     Current_Y = Origin_Y - Py
        -- -- else
        -- --     Current_Y = Origin_Y + Py
        -- -- end
        -- local Current_Y = tonumber(string.format("%.0f",Origin_Y - Py))
        -- if DEBUGFLAG == 1 then
        --     print("valueXx =", valueX  .."valueYy="..valueY)
        --     print("sin2 =", sin2 )
        --     print("Reactance_Circle_r =", Reactance_Circle_r  .."Reactance_Arc_r="..Reactance_Arc_r)
        --     print("Px =", Px  .."Py="..Py)
        --     print("x =", Current_X  .."y="..Current_Y)
        -- end
        set_pos(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Coordinates,Current_X,Current_Y,6,6)
    end,

    [VAR_ADDR.Rleay_VSWR] = function(data)
        if DEBUGFLAG == 1 then
            print("Rleay_VSWR =", bytesToFloatLE_manual(data))
        end
        local value = bytesToFloatLE_manual(data)
        local valuebuf = string.format("%.2f", value)
        set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.VSWR,valuebuf)
    end,

    [VAR_ADDR.File_Write] = function(data)

        if Current_info.File_Current_Location ~=((data[1]<< 8) | data[2]) then
            screen_write_to_MCU(VAR_ADDR.File_Screen_ERROR,0x01,1)
            local v = 0x201
            local title, solution, errorType, level = GetErrorMessage(v)
            
            print("ErrorInput:", v)
            print("title:", title)
            print("solution:", solution)
            print("errorType:", errorType)
            start_timer(Timer_ID.Error_Code_Clear,Timer_Info[Timer_ID.Error_Code_Clear].timeout,Timer_Info[Timer_ID.Error_Code_Clear].countdown,Timer_Info[Timer_ID.Error_Code_Clear].timesrepeat)
            print ("timer:start")
            set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Show_Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.Error_Code,numberToE00Fixed(v))
            Power_test_screen_control_enable(1)
            Power_verify_screen_control_enable(1)


        end
        Current_info.File_Current_Bytes =  ((data[3]<< 8) | data[4]) +Current_info.File_Current_Bytes--获取到了文件总字节数
        Current_info.File_Current_Location = ((data[1]<< 8) | data[2]) +((data[3]<< 8) | data[4])
            if  Current_info.File_Current_Bytes == 200 then
                
                Current_info.File_Data_Info[0 ] = data[5]
                for i = 6, 204 do
                    Current_info.File_Data_Info[#Current_info.File_Data_Info +1] = data[i]
                end

            else
                
                for i = 5, 204 do
                    Current_info.File_Data_Info[#Current_info.File_Data_Info +1] = data[i]
                end

            end
            print("Current_info.File_Current_Bytes: ",Current_info.File_Current_Bytes)
            set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.file_progress,string.format("%.1f",(Current_info.File_Current_Location*100/37200)).."%")
            -- screen_write_to_MCU
        if Current_info.File_Current_Bytes == 2000 and Current_info.File_Current_Location ==  2000  then
            print("Current_info.File_Current_Bytes: ",Current_info.File_Current_Bytes)
            myfile_write(Data_File_name,Current_info.File_Data_Info)
            Current_info.File_Current_Bytes=0
            Current_info.File_Data_Info = {}
        elseif Current_info.File_Current_Bytes >= 2000  or Current_info.File_Current_Location > 37200 then
            -- print("Current_info.File_Current_Bytes: ",Current_info.File_Current_Bytes)
            -- for i = 1, GROUP_NUM do
            Current_info.File_Current_Bytes=0
            -- print("All tables parsed:", #data_tables)
            print(#Current_info.File_Data_Info)
            print(Current_info.File_Data_Info[0])
            print(Current_info.File_Data_Info[1999])
            myfile_write_add(Data_File_name,Current_info.File_Data_Info)
            Current_info.File_Data_Info = {}
            
            if Current_info.File_Current_Location >= 37200 then
                Current_info.File_Current_Location =0
                set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.file_progress,"success")
            end
        end
        
    end,

    [VAR_ADDR.File_Creat] = function(data)
        Current_info.File_Bytes = data[1] | (data[2] << 8) --获取到了文件总字节数
        Current_info.File_CRC = data[3] | (data[4] << 8) --获取到了文件总字节数
        
        if DEBUGFLAG == 1 then
            print("File_Bytes =", Current_info.File_Bytes)
            print("File_CRC =", Current_info.File_CRC)
        end
        local head_data = {}
        Current_info.File_Current_Bytes=0
        skip_header=HEADER_SIZE
        myfile_write(Data_File_name,head_data)
    end,
    
    [VAR_ADDR.Timestamps] = function(data)
            local v = data[1] | (data[2] << 8)|(data[3] << 16)|(data[4] << 24)
            Current_info.timestamps = v
            local year ,month , day , hour ,minute ,second 
            local timeTable = os.date("*t", v)
            set_systime(timeTable.year, timeTable.month, timeTable.day, timeTable.hour, timeTable.min, timeTable.sec)
            set_text(SCREENID.Time_Calibration_SCREEN, Time_Calibration_SCREEN_CONTROL.year, timeTable.year)
            set_text(SCREENID.Time_Calibration_SCREEN, Time_Calibration_SCREEN_CONTROL.month, timeTable.month)
            set_text(SCREENID.Time_Calibration_SCREEN, Time_Calibration_SCREEN_CONTROL.day, timeTable.day)
            set_text(SCREENID.Time_Calibration_SCREEN, Time_Calibration_SCREEN_CONTROL.hour, timeTable.hour)
            set_text(SCREENID.Time_Calibration_SCREEN, Time_Calibration_SCREEN_CONTROL.minute, timeTable.min)
            set_text(SCREENID.Time_Calibration_SCREEN, Time_Calibration_SCREEN_CONTROL.second, timeTable.sec)
        if DEBUGFLAG == 1 then
            print("Timestamps =", v)
            print(timeTable.year)
            print(timeTable.month)
            print(timeTable.day)
            print(timeTable.hour)
            print(timeTable.min)
            print(timeTable.sec)
        end
    end,
    [VAR_ADDR.File_MCU_ERROR] = function(data)
        if  data[1] ~= 0 then
            
            Uart_send_file_flag =0
            Uart_send_Verify_file_flag =0
            local v = 0x200
            local title, solution, errorType, level = GetErrorMessage(v)
            Current_info.File_Current_Location = 0
            print("ErrorInput:", v)
            print("title:", title)
            print("solution:", solution)
            print("errorType:", errorType)
            start_timer(Timer_ID.Error_Code_Clear,Timer_Info[Timer_ID.Error_Code_Clear].timeout,Timer_Info[Timer_ID.Error_Code_Clear].countdown,Timer_Info[Timer_ID.Error_Code_Clear].timesrepeat)
            print ("timer:start")
            set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Error_Code,numberToE00Fixed(v))

            set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Show_Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.Error_Code,numberToE00Fixed(v))
            Power_test_screen_control_enable(1)
            Power_verify_screen_control_enable(1)
        end
    end,
      [VAR_ADDR.File_Send_MCU_ERROR] = function(data)
        if  data[1] ~= 0 then
            Uart_send_file_flag =0
            Uart_send_Verify_file_flag =0
            Current_offset =0
            local v = 0x202
            local title, solution, errorType, level = GetErrorMessage(v)
            Current_info.File_Current_Location =0
            print("ErrorInput:", v)
            print("title:", title)
            print("solution:", solution)
            print("errorType:", errorType)
            start_timer(Timer_ID.Error_Code_Clear,Timer_Info[Timer_ID.Error_Code_Clear].timeout,Timer_Info[Timer_ID.Error_Code_Clear].countdown,Timer_Info[Timer_ID.Error_Code_Clear].timesrepeat)
            print ("timer:start")
            set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.file_progress,"0%")
            set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Show_Error_Code,numberToE00Fixed(v))
            set_text(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.Error_Code,numberToE00Fixed(v))
            
            Power_test_screen_control_enable(1)
            Power_verify_screen_control_enable(1)

        end
    end,
    
    [VAR_ADDR.RF_TEST_END] = function(data)
        if DEBUGFLAG == 1 then
            print("RF_TEST_END =", data[1])
        end
        local value = data[1]
        if value == 1 then 
        
            if Current_info.Rf_Test_Flag  ~=  0 then
                print("Rf_Test_State.."..Current_info.Rf_Test_State)
                Current_info.Rf_Test_State  = 0
                table_info_record_add()
                set_value(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.ResultIcon,0)
                
            elseif Current_info.Verify_Rf_Test_Flag  ~=  0 then
                print("Verify_Rf_Test_Flag.."..Current_info.Verify_Rf_Test_Flag)
                Current_info.Verify_Rf_Test_State  = 0
                Verify_table_info_record_add()
                set_value(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.ResultIcon,0)
            elseif Current_info.Retest_Select_Test_Flag  ~=  0 then
                print("Retest_Select_Test_Flag.."..Current_info.Retest_Select_Test_Flag)
                Current_info.Retest_Select_Test_Flag  = 0
                stop_timer(Timer_ID.Verify_Gear_RF_Timer)
                
                Retest_Select_record_Modify()


                set_value(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.ResultIcon,0)
            end

        end
    end,
    
}

function screen_write_to_MCU(addr, value,len)
    -- print(addr)

    (var_write_map[addr] or function() end)(value,len)
end
-- ================== CRC16(Modbus) ==================
function crc16_modbus(buf,start, len)
    local crc = 0xFFFF

    for i = start, len do
        crc = crc ~ buf[i]
        for _ = 1, 8 do
            if (crc & 0x0001) ~= 0 then
                crc = (crc >> 1) ~ 0xA001
            else
                crc = crc >> 1
            end
        end
    end

    return crc
end

function uart_write_number(addr, value, byte_len)
    print("value="..value)
    print(addr)
    local data = {}
    for i = 1, byte_len do
        data[i] = math.floor(value / (256^(i-1))) % 256
    end
    uart_send_frame(0x02, addr, data, byte_len)
end

function uart_write_bytes(addr, bytes)
    -- bytes = {0x01,0x02,...}
    uart_send_frame(0x02, addr, bytes, #bytes)
end

function uart_write_string(addr, str)
    local data = {}
    for i = 1, #str do
        data[i] = string.byte(str, i)
    end
    uart_send_frame(0x02, addr, data, #data)
end

--================== 屏幕接收解析 ==================
function GetErrorMessage(errorCode)
    local errorInfo = ErrorMessages[errorCode]
    if errorInfo then
        return errorInfo.title, errorInfo.solution, errorInfo.type, errorInfo.level
    else
        return "", "", "", ""
    end
end

function screen_dispatch( addr, data)
    (var_read_map[addr] or function() end)(data)
end

function screen_read(rx_buf)
    local ack_buf={}
    local len = #rx_buf

    -- ================= CRC 校验 =================
    -- local crc_recv = rx_buf[len - 1] | (rx_buf[len ] << 8)
    -- local crc_calc = crc16_modbus(rx_buf, 0,len - 2)
    -- print("crc_recv:"..crc_recv)
    -- print("crc_calc:"..crc_calc)
    -- if crc_recv ~= crc_calc then return end
    -- ================= 协议解析 =================
    local idx = 0

    -- 功能码
    local func = rx_buf[idx]
    if func == 0x04 then
        ACK_flag = 0
        return 
    end
    idx = idx + 1
    -- 地址个数
    local addr_cnt = rx_buf[idx]
    local addr_cnt_tmp = addr_cnt
    print ("addr_cnt"..addr_cnt)
    idx = idx + 1
    -- uart_send_frame(func,rx_buf[0])
    -- 逐个解析变量
    for _ = 1, addr_cnt do
        -- 地址
        -- 数据长度
        local data_len = rx_buf[idx]
        idx = idx + 1

        local addr = (rx_buf[idx] << 8) | rx_buf[idx + 1]
        print("addr::"..addr)
        idx = idx + 2


        -- 数据
        local data = {}
        for i = 1, data_len do
            data[i] = rx_buf[idx]
            idx = idx + 1
        end

        -- 分发（每个变量独立处理）
        screen_dispatch(addr, data)
    end
    idx = 0
    ack_buf[idx]=0xEE;
    idx = idx + 1
    ack_buf[idx]=0xB5;
    idx = idx + 1
    ack_buf[idx]=0x02;
    idx = idx + 1
    ack_buf[idx]=addr_cnt_tmp;
    idx = idx + 1
    ack_buf[idx]=rx_buf[3];
    idx = idx + 1
    ack_buf[idx]=rx_buf[4];
    idx = idx + 1

    -- CRC
    -- local crc = crc16_modbus(ack_buf,1,idx - 1)
    -- ack_buf[idx] = (crc >> 8) & 0xFF; idx = idx + 1
    -- ack_buf[idx] = crc & 0xFF;        idx = idx + 1

    -- 帧尾
    ack_buf[idx] = 0xFF; idx = idx + 1
    ack_buf[idx] = 0xFC; idx = idx + 1
    ack_buf[idx] = 0xFF; idx = idx + 1
    ack_buf[idx] = 0xFF
    uart_send_data(ack_buf)
    local hexStrings = {}
    for i, v in ipairs(ack_buf) do
        hexStrings[i] = string.format("%02X", v)
    end
    print(table.concat(hexStrings, " "))
end



function numberToE00Fixed(num, totalLength) --格式化错误码
    totalLength = totalLength or 5  -- 默认总长度5位，如 E0018
    if num == 0 then
        return ""
    end
    -- 转换为十六进制
    local hex = string.format("%X", num)
    
    -- 计算需要的前导零数量
    local prefixLength = totalLength - #hex
    if prefixLength > 0 then
        return "E" .. string.rep("0", prefixLength - 1) .. hex
    else
        return "E" .. hex
    end
end

-- 将数字的第 n 位设置为 0（从 0 开始计数，最低位为第0位）
function clearBit(num, bitPos)
    -- 创建掩码：只有第 bitPos 位为 1，其他位为 0
    local mask = 1 << bitPos
    -- 取反后与操作：清除指定位
    return num & ~mask
end

-- 将数字的第 n 位设置为 1
function setBit(num, bitPos)
    -- 创建掩码：只有第 bitPos 位为 1，其他位为 0
    local mask = 1 << bitPos
    -- 或操作：设置指定位
    return num | mask
end

-- 将数字的第 n 位设置为指定值 (0 或 1)
function setBitTo(num, bitPos, value)
    if value == 1 then
        return setBit(num, bitPos)
    elseif value == 0 then
        return clearBit(num, bitPos)
    else
        error("value must be 0 or 1")
    end
end

-- 小端序字节数组转浮点数
function bytesToFloatLE_manual(bytes)
    -- 组合为32位整数（小端序）
    local intValue = 
        bytes[1] |
        (bytes[2] << 8) |
        (bytes[3] << 16) |
        (bytes[4] << 24)
    
    return intToFloat(intValue)
end

-- 32位整数转浮点数
function intToFloat(intValue)
    -- 提取符号位、指数、尾数
    local sign = (intValue >> 31) & 0x1
    local exponent = (intValue >> 23) & 0xFF
    local mantissa = intValue & 0x7FFFFF
    
    -- 处理特殊情况
    if exponent == 0xFF then
        -- 无穷大或NaN
        if mantissa == 0 then
            return sign == 1 and -math.huge or math.huge
        else
            return 0/0  -- NaN
        end
    elseif exponent == 0 then
        -- 非规格化数或零
        if mantissa == 0 then
            return sign == 1 and -0.0 or 0.0
        else
            return (sign == 1 and -1 or 1) * mantissa * 2^(-126 - 23)
        end
    else
        -- 规格化数
        local value = (sign == 1 and -1 or 1) * 
                     (1 + mantissa * 2^(-23)) * 
                     2^(exponent - 127)
        return value
    end
end

function formatNumber5Digits(num)
    -- 确保输入是5位数字
    local str = tostring(num)
    
    -- 如果不足5位，前面补0
    if #str < 5 then
        str = string.rep("0", 5 - #str) .. str
    elseif #str > 5 then
        -- 如果超过5位，取后5位
        str = string.sub(str, -5)
    end
    
    -- 按格式分割：X.YY.ZZ
    local part1 = string.sub(str, 1, 1)
    -- 第2-3位作为第二部分
    local part2_num = tonumber(string.sub(str, 2, 3))
    local part2 = tostring(part2_num)  -- 这样会去掉前导零
    local part3_num = tonumber(string.sub(str, 4, 5))
    local part3 = tostring(part3_num)
    
    return "V"..part1 .. "." .. part2 .. "." .. part3
end
-- 如果不使用bit32库
function hexToLittleEndianStringSimple(num)
    print("uidnum="..num)
    -- 使用数学运算
    local byte1 = num % 256                 -- 0x78
    local byte2 = math.floor(num / 256) % 256   -- 0x56
    local byte3 = math.floor(num / 65536) % 256 -- 0x34
    local byte4 = math.floor(num / 16777216) % 256 -- 0x12
    
    return string.char(byte1, byte2, byte3, byte4)
end
-- 优化版本：使用table提高性能
function getFirst21BitsToBinary2(num)
    local bits = {}
    
    for i = 20, 0, -1 do
        -- 使用位运算提取每一位
        local bit = (num >> i) & 1
        bits[i+1] = tostring(bit)  -- 从最高位开始
    end
    
    return table.concat(bits)
end

function uart_ack_frame_send(data)
    

end

function  NO_head_clear()--清楚文本狂内容
    
    set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Model,"")
    set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Pulse_Count,"")
    set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Date,"")
    set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.QR_Code_Verification,"")

    set_visiable(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.QR_Code_Verification,0)
    set_text(SCREENID.Treatment_Not_Recognized_SCREEN,Treatment_Not_Recognized_SCREEN_CONTROL.Password_Input_Box,"")
    Current_input_buff = ""

    
    set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.ProduceDate,"")
    set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.RemainingCycycles,"")
    set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.TotalCycles,"")
    set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.HeadId,"")
    set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.HeadVersion,"")
    set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Treatment_Head_Type,"")

    set_text(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Totalused_Headcount,"")
        set_text (SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Totalused_Headcount,"")
        set_text (SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Totalused_Headcount,"")

end

function  NO_Error_clear()--清楚文本狂内容
    
    set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Error_Code,"")
    set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Error_Code,"")
    set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Error_Code,"")
    set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.Error_Code,"")
    set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Error_Code,"")
    set_text(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.Error_Code,"")
    set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Error_Code,"")
    set_text(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.Error_Code,"")

end

function formatHexData(data)
    if not data or #data == 0 then
        return ""
    end
    
    local parts = {}
    -- 从最后一个元素开始到第一个元素
    for i = #data, 1, -1 do
        table.insert(parts, string.format("%02X", data[i]))
    end
    
    return table.concat(parts)
end
-- 发送数据并开启超时检测
function uart_send_with_retry(packet)

    -- 保存数据，用于重发
    last_packet = packet

    -- 清零重试次数
    retry_cnt = 0

    -- 标记等待回复
    waiting_ack = true

    -- 发送
    uart_send_data(packet, UART_PORT)

    print("发送数据")

    -- 启动超时定时器（单次）
    start_timer(UART_TIMER_ID, TIMEOUT_MS, 0, 1)

end

function Process_Screen_Enable(state)

    set_enable(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Add_Button,state)

    set_enable(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Sub_Button,state)

    set_enable(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Classic_Mode_Button,state)

    set_enable(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Comfort_Mode_Button,state)

    set_enable(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Cold_Button,state)

    set_enable(SCREENID.Treatment_Process_SCREEN,Treatment_Process_SCREEN_CONTROL.Vibration_Button,state)


    set_enable(SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Add_Button,state)

    set_enable(SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Sub_Button,state)

    set_enable(SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Classic_Mode_Button,state)

    set_enable(SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Comfort_Mode_Button,state)

    set_enable(SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Cold_Button,state)

    set_enable(SCREENID.V2Treatment_Process_SCREEN,V2Treatment_Process_SCREEN_CONTROL.Vibration_Button,state)

    set_enable(SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Add_Button,state)

    set_enable(SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Sub_Button,state)

    set_enable(SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Classic_Mode_Button,state)

    set_enable(SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Comfort_Mode_Button,state)

    set_enable(SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Cold_Button,state)

    set_enable(SCREENID.BodyTreatment_Process_SCREEN,BODYTreatment_Process_SCREEN_CONTROL.Vibration_Button,state)

end

function Power_test_screen_control_enable(state)


    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.real_control,state)

    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.image_control,state)

    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.voltage_select_control,state)

    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.verify_select_control,state)

    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.upload,state)

    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.download,state)

    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.test_start,state)


    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Efficiency_threshold,state)
end

function Power_verify_screen_control_enable(state)


    set_enable(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.real_control,state)

    set_enable(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.image_control,state)

    set_enable(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.Geer_select,state)

    set_enable(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.power_verify_result,state)

    set_enable(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.test_start,state)

    set_enable(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.save_button,state)

    set_enable(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.result_export,state)

    set_enable(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.retest,state)


    set_enable(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.result_threshold,state)
end
function RF_Test_Init()
        Current_Power_Debuginfo.voltage_num=    0
        Current_Power_Debuginfo.total_count = 0
        Current_Power_Debuginfo.real_total= 0 
        Current_Power_Debuginfo.imag_total= 0 
        Current_info.Rf_Test_State  = 0
        Current_info.Rf_Test_Flag    = 0
        set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.save_button,0)
        set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.test_text,"保存")

end


function Verify_RF_Test_Init()
        Current_Power_Verifyinfo.Geer_count=    0
        Current_Power_Verifyinfo.total_count = 0
        Current_Power_Verifyinfo.Machine_power= 0 
        Current_Power_Verifyinfo.Measured_power= 0 
        Current_Power_Verifyinfo.total_Geer= 0 
        Current_info.Verify_Rf_Test_Flag  = 0
        Current_info.Verify_Rf_Test_State    = 0

end

function Verify_Test_Rest()



end
-- 函数2：将分号替换为逗号，最后一个分号替换为换行符
function replace_semicolons(str)
    -- 找到最后一个分号的位置
    local last_semicolon_pos = string.find(str, ";", 1, true)
    local last_pos = last_semicolon_pos
    
    -- 循环找到最后一个分号
    while true do
        local pos = string.find(str, ";", last_pos + 1, true)
        if not pos then
            break
        end
        last_pos = pos
    end
    
    -- 如果没有分号，直接返回原字符串
    if not last_pos then
        return str
    end
    
    -- 分割字符串
    local before_last = string.sub(str, 1, last_pos - 1)
    local after_last = string.sub(str, last_pos + 1)
    
    -- 将前面的分号替换为逗号
    before_last = string.gsub(before_last, ";", ",")
    
    -- 组合结果：前面的部分 + 换行符 + 最后一部分
    return before_last .. "\n" .. after_last
end

function format_record_line(real_v, image_v, gear, meas_power, machine_power, err_value, result)
    return string.format(
        "%03d,%+04d,%04.1f,%07.2f,%07.2f,%+07.2f,%1d\n",
        real_v,
        image_v,
        gear,
        meas_power,
        machine_power,
        err_value,
        result
    )
end

--========================
-- 字符串 <-> 0下标字节表
--========================
function string_to_byte_table(str)
    local data = {}
    for i = 1, #str do
        data[i - 1] = string.byte(str, i)
    end
    return data
end

function byte_table_to_string(data)
    if data == nil then
        return nil
    end

    local t = {}
    local i = 0
    while data[i] ~= nil do
        t[#t + 1] = string.char(data[i])
        i = i + 1
    end
    return table.concat(t)
end

function get_record_index(real_v, image_v, gear)
    local real_idx = Real_index_map[real_v]
    local image_idx = Image_index_map[image_v]
    local gear_idx = Gear_index_map[string.format("%.1f", gear)]

    if not real_idx then
        return nil, "阻抗实部不存在: " .. tostring(real_v)
    end
    if not image_idx then
        return nil, "阻抗虚部不存在: " .. tostring(image_v)
    end
    if not gear_idx then
        return nil, "档位不存在: " .. tostring(gear)
    end

    local image_count = #ImpedanceX_Image_table

    local group_index = (real_idx - 1) * image_count + image_idx
    local record_index = (group_index - 1) * GEAR_COUNT + gear_idx

    return record_index
end


function impedance_db_init()
    if file_isexist(Verify_File_name) ==true then
        return true
    end

    if file_open(Verify_File_name,  FA_WRITE_BIN|FA_CREATE_ALWAYS)==false then
        return false, "创建文件失败"
    end

    for r = 1, #ImpedanceX_Real_table do
        for x = 1, #ImpedanceX_Image_table do
            local group_str = default_group_string(
                ImpedanceX_Real_table[r],
                ImpedanceX_Image_table[x]
            )

            local ok = file_write(string_to_byte_table(group_str))
            if not ok then
                file_close()
                return false, "初始化写文件失败"
            end
        end
    end

    file_close()
    return true
end

--========================
-- 解析输入字符串
-- 输入例子：
-- "2.5;9.38;10.0;-6.3%;0;"
--========================
function parse_info_string(info_str)
    local fields = {}
    print("info_str= "..info_str.gear )
    for item in string.gmatch(info_str, "([^;]+)") do
        print(item )
        fields[#fields + 1] = item
    end

    if #fields < 5 then
        print("fields_fail")
        return nil, "字符串格式错误: " .. tostring(info_str)
    end

    local gear = tonumber(fields[1])
    local meas_power = tonumber(fields[2])
    local machine_power = tonumber(fields[3])

    local err_str = string.gsub(fields[4], "%%", "")
    local err_value = tonumber(err_str)

    local result = tonumber(fields[5])

    if gear == nil or meas_power == nil or machine_power == nil or err_value == nil or result == nil then
        print("gear == nil or meas_power == nil or machine_power == nil or err_value == nil or result == nil")
        return nil, "字符串解析失败: " .. tostring(info_str)
    end

    return {
        gear = gear,
        meas_power = meas_power,
        machine_power = machine_power,
        err_value = err_value,
        result = result
    }
end

--========================
-- 读取某个阻抗组合下的全部16个档位
-- 返回 table
--========================
function impedance_db_read_group(real_v, image_v)

    local offset, err = get_group_offset(real_v, image_v)
    if offset == nil then
        return nil, err
    end

    local read_len = GEAR_COUNT * LINE_LEN   -- 16 * 40 = 640，小于2048

    if not file_open(Verify_File_name, FA_READ) then
        return nil, "open db for read failed"
    end

    if not file_seek(offset) then
        file_close()
        return nil, "file_seek failed"
    end

    local data = file_read(read_len)
    file_close()

    if data == nil then
        return nil, "file_read failed"
    end

    local str = byte_table_to_string(data)
    print("str="..str)
    if not str then
        return nil, "byte_table_to_string failed"
    end

    local result_list = {}

    for line in string.gmatch(str, "([^\n]+)\n?") do
        local real_s, image_s, gear_s, meas_s, machine_s, err_s, result_s =
            string.match(line, "([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")

        if real_s then
            result_list[#result_list + 1] = {
                real = tonumber(real_s),
                image = tonumber(image_s),
                gear = tonumber(gear_s),
                meas_power = tonumber(meas_s),
                machine_power = tonumber(machine_s),
                err_value = tonumber(err_s),
                result = tonumber(result_s)
            }
        end
    end

    return result_list
end


function default_group_string(real_v, image_v)
    local lines = {}
    for i = 1, GEAR_COUNT do
        lines[#lines + 1] = format_record_line(real_v, image_v, Gear_table[i], 0.0, 0.0, 0.0, 0)
    end
    return table.concat(lines)
end



local GROUP_LEN = LINE_LEN * GEAR_COUNT

function impedance_db_save_group(real_v, image_v, info_list)
    
    if info_list == nil then
        print("info_list=nil")
        return false, "info_list 必须是 table"
    end

    print("impedance_db_save_group start")
    -- if #info_list ~= GEAR_COUNT then
    --     return false, "info_list 数量必须是 16"
    -- end

    local lines = {}

    for i = 1, GEAR_COUNT do

        print("info_list[i]geer"..info_list[i].gear)


        lines[#lines + 1] = format_record_line(
            real_v,
            image_v,
            info_list[i].gear,
            info_list[i].meas_power,
            info_list[i].machine_power,
            info_list[i].err_value,
            info_list[i].result
        )

    end

    local group_str = table.concat(lines)
    if #group_str ~= GROUP_LEN then
        print("group_str_fail")
        return false, "组长度错误"
    end

    local offset, err = get_group_offset(real_v, image_v)
    if offset == nil then
        print("offset_fail")
        return false, err
    end

    if file_open(Verify_File_name, FA_WRITE | FA_WRITE_BIN )   ~= true then
        print("file_open_fail")
        return false, "打开文件失败"
    end

    
    print("group_offset="..offset)
    if file_seek(offset)  ~= true then
        file_close()
        print("file_seek_fail")
        return false, "file_seek 失败"
    end

    print("group_str="..group_str)
    print("group_str_count="..#group_str)
    local ok = file_write(string_to_byte_table(group_str))
    file_close()

    if ok  ~= true  then
        print("file_write_fail")
        return false, "file_write 失败"
    end
    print("file_write_success")

    return true
end

function get_group_index(real_v, image_v)
    local real_idx = Real_index_map[real_v]
    local image_idx = Image_index_map[image_v]

    if not real_idx then
        return nil, "阻抗实部不存在: " .. tostring(real_v)
    end
    if not image_idx then
        return nil, "阻抗虚部不存在: " .. tostring(image_v)
    end

    local image_count = #ImpedanceX_Image_table
    local group_index = (real_idx - 1) * image_count + image_idx
    return group_index
end

function get_group_offset(real_v, image_v)
    local group_index, err = get_group_index(real_v, image_v)
    if not group_index then
        return nil, err
    end

    local offset = (group_index - 1) * GROUP_LEN
    return offset
end

function collect_group_from_table(screen, control)
    local row_count = record_get_count(screen, control)
    if row_count == nil then
        return nil, "获取表格行数失败"
    end

    if row_count < 1 then
        return nil, "表格至少要有一行数据"
    end

    -- 先初始化16个固定档位槽位
    local info_list = {}
    for i = 1, GEAR_COUNT do
        info_list[i] = {
            gear = Gear_table[i],
            meas_power = 0.0,
            machine_power = 0.0,
            err_value = 0.0,
            result = 0
        }
    end

    -- 再把表格里已有行，按“档位值”填进对应槽位
    for i = 0, row_count - 1 do
        local record_str = record_read(screen, control, i)
        if record_str == nil then
            return nil, "读取表格第 " .. tostring(i + 1) .. " 行失败"
        end

        local info, err = parse_table_record(record_str, i + 1)
        if not info then
            return nil, err
        end

        local key = string.format("%.1f", info.gear)
        local slot = Gear_index_map[key]

        if slot == nil then
            return nil, "表格第 " .. tostring(i + 1) .. " 行档位不在允许范围内: " .. tostring(info.gear)
        end
        print("info.result")
        print(info.result)
        
        info_list[slot] = {
            gear = Gear_table[slot],
            meas_power = info.meas_power,
            machine_power = info.machine_power,
            err_value = info.err_value,
            result = info.result
        }
    end

    return info_list
end
function format_table_record(item)
    return string.format(
        "%.1f;%.2f;%.2f;%.2f;$ICON%d;",
        tonumber(item.gear) or 0,
        tonumber(item.meas_power) or 0,
        tonumber(item.machine_power) or 0,
        tonumber(item.err_value) or 0,
        tonumber(item.result) or 0
    )
end
function fill_group_to_table(screen, control, group_data)
    if type(group_data) ~= "table" then
        return false, "group_data 必须是 table"
    end

    if #group_data ~= GEAR_COUNT then
        return false, "group_data 数量必须是 16"
    end

    record_clear(screen, control)

    for i = 1, GEAR_COUNT do
        local item = group_data[i]

        -- 空记录跳过，不显示
        if not (
            item.gear == 0 and
            item.meas_power == 0 and
            item.machine_power == 0 and
            item.err_value == 0 and
            item.result == 0
        ) then
            local record_str = format_table_record(item)
            record_add(screen, control, record_str)
        end
    end

    return true
end

function parse_table_record(record_str, row_index)
    print("parse_start")
    local fields = {}
    for item in string.gmatch(record_str or "", "([^;]+)") do
        fields[#fields + 1] = trim(item)
    end

    if #fields < 5 then
        return nil, "表格第 " .. row_index .. " 行字段不足"
    end

    local gear = tonumber(fields[1])
    local meas_power = tonumber(fields[2])
    local machine_power = tonumber(fields[3])
    local err_value = tonumber(fields[4])
    local result = tonumber(string.sub(fields[5],-1,-1))

    if gear == nil or meas_power == nil or machine_power == nil or err_value == nil or result == nil then
        return nil, "表格第 " .. row_index .. " 行数据非法"
    end

    print("parse_end")
    return {
        gear = gear,
        meas_power = meas_power,
        machine_power = machine_power,
        err_value = err_value,
        result = result
    }
end
function trim(s)
    if s == nil then
        return ""
    end
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
