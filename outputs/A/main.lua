-------------------------------------------------------------------------------------------
Data_File_name = "B:/data.bin"
Verify_File_name = "B:/verify.txt"
Pos=0
local mymodule = require("addr")
local mymodule = require("file")
function on_init() -- 开机回调函数
    -- dofile("B:/addr.lua")
    uart_set_timeout(0, 0)
    math.randomseed(os.time())
    screen_init()
    local testdata ={}
    testdata[0]=0x31
    testdata[1]=0x32

    -- 初始化
    for _, real_val in ipairs(ImpedanceX_Real_table) do
        ImpedanceX_Save_Times[real_val] = {}
        for _, imag_val in ipairs(ImpedanceX_Image_table) do
            ImpedanceX_Save_Times[real_val][imag_val] = 0
        end
    end
    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.save_button,0)
    
    for i, v in ipairs(ImpedanceX_Real_table) do
        Real_index_map[v] = i
    end

    for i, v in ipairs(ImpedanceX_Image_table) do
        Image_index_map[v] = i
    end

    for i, v in ipairs(Gear_table) do
        Gear_index_map[string.format("%.1f", v)] = i
    end
    if impedance_db_init()~=true then
        print("db init failed:")
    end
    -- myfile_write("B:/test.txt",testdata)
    -- myfile_write_add("B:/test.txt",testdata)
end

function screen_init()

    local i =0
    for i =0 , 12 , 1 do 
        set_enable (SCREENID.Treatment_Not_Recognized_SCREEN,i,Current_info.Head_Ok)
    end

end

function on_timer(timer_id)
    if timer_id == Timer_ID.Error_Code_Clear then
        print("Error_Code_Clear")
        NO_Error_clear()
        stop_timer(Timer_ID.Error_Code_Clear)
    elseif timer_id == Timer_ID.MCU_Ack then
        -- print("MCU_Ack")
        -- print("ACK received for message")
        -- -- 停止定时器（如果需要）
        -- stop_timer(Timer_ID.MCU_Ack)
    elseif timer_id == Timer_ID.Uart_send then
        -- print("MCU_Ack")
        -- print("ACK received for message")
        -- if sending_in_progress then
        --     -- 方案A：直接拒绝新消息（最简单）
        --     retry=1+retry
        --     print("正在发送中，拒绝新消息：")
        -- else
        --     local next_msg = table.remove(pending_messages, 1)
        --     retry=0
        --     if next_msg ~= nil then
        --         uart_send_data(next_msg)
        --     end
            
        -- end
    elseif timer_id == Timer_ID.Test_State then

        local success_icon = 2
        local fail_icon = 1
        local warning_icon = 0
        local icon_flag = get_value(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.ResultIcon)
        if Current_info.Rf_Test_Flag == 1 and Current_info.Rf_Test_State  == 1 then
            if icon_flag ==success_icon then 
            
            elseif icon_flag == warning_icon then

                Current_info.Rf_Test_State  = 2
                print("Rf_Test_State.."..Current_info.Rf_Test_State)

            elseif  icon_flag ==fail_icon   then

            end

        end
    elseif timer_id == Timer_ID.Uart_send_file then

        if Uart_send_file_flag == 1 then
            send_file_data(Data_File_name)
        else
            stop_timer(Timer_ID.Uart_send_file)
        end 
   
    elseif timer_id == Timer_ID.Verify_file_send then

        stop_timer(Timer_ID.Verify_file_send)
        if Uart_send_Verify_file_flag == 1 then
            Verify_send_file_data(Verify_File_name)
            if Uart_send_Verify_file_flag == 1 then
                start_timer(Timer_ID.Verify_file_send,Timer_Info[Timer_ID.Verify_file_send].timeout,Timer_Info[Timer_ID.Verify_file_send].countdown,1)
            end
        else
            stop_timer(Timer_ID.Verify_file_send)
        end 

    elseif timer_id == Timer_ID.RF_Start then
        
        screen_write_to_MCU(VAR_ADDR.RF_start_select,0x01,1);


    elseif timer_id == Timer_ID.Verify_Gear_RF_Timer then
        
        screen_write_to_MCU(VAR_ADDR.RF_start_select,0x01,1);

    end
end

function on_draw()
    
end

function on_control_notify(screen, control, value)
    if DEBUGFLAG == 1 then
        print("screen=" .. screen .. "\n" .. "control=" .. control .. "\n" .. "value=" .. value)
        
    end
    if screen == SCREENID.Treatment_Not_Recognized_SCREEN then
        if (control >= Treatment_Not_Recognized_SCREEN_CONTROL.NUM1 and control <=
            Treatment_Not_Recognized_SCREEN_CONTROL.NUM0 and value == Trigger) then
            if string.len(Current_input_buff) < 6 then
                Current_input_buff = Current_input_buff .. (control % 10)
                set_text(SCREENID.Treatment_Not_Recognized_SCREEN,
                    Treatment_Not_Recognized_SCREEN_CONTROL.Password_Input_Box, Current_input_buff)
                -- screen_write_to_MCU(VAR_ADDR.VerifyCodeText,control+0X30);
            end
            
        elseif (control == Treatment_Not_Recognized_SCREEN_CONTROL.Cancel and value == Trigger) then
            Current_input_buff = ""
            set_text(SCREENID.Treatment_Not_Recognized_SCREEN,
                Treatment_Not_Recognized_SCREEN_CONTROL.Password_Input_Box, Current_input_buff)

        elseif (control == Treatment_Not_Recognized_SCREEN_CONTROL.Confirm and value == Trigger) then

            -- if (Current_input_buff == QR_CODE_INFO and Current_input_buff ~= "") then
            --     change_screen(SCREENID.Treatment_Process_SCREEN)
            -- end
            
            screen_write_to_MCU(VAR_ADDR.VerifyCodeText,Timestamp_frame(Current_info.timestamps),1);
            print("password:  "..get_text(SCREENID.Treatment_Not_Recognized_SCREEN,
                Treatment_Not_Recognized_SCREEN_CONTROL.Password_Input_Box))
            Current_input_buff = ""
            set_text(SCREENID.Treatment_Not_Recognized_SCREEN,
                Treatment_Not_Recognized_SCREEN_CONTROL.Password_Input_Box, Current_input_buff)

        elseif (control == Treatment_Not_Recognized_SCREEN_CONTROL.Password_Delete and value == Trigger) then

            Current_input_buff = string.sub(Current_input_buff, 1, -2)
            set_text(SCREENID.Treatment_Not_Recognized_SCREEN,
                Treatment_Not_Recognized_SCREEN_CONTROL.Password_Input_Box, Current_input_buff)
            
        end
    elseif screen == SCREENID.Treatment_Process_SCREEN then
        if DEBUGFLAG == 1 then
            print("Current_info.Cold:" .. Current_info.Cold)
            print("Current_info.Gear:" .. Current_info.Gear)
        end
        if control == Treatment_Process_SCREEN_CONTROL.Classic_Mode_Button and value == Press then
            set_value(SCREENID.Treatment_Process_SCREEN, Treatment_Process_SCREEN_CONTROL.Comfort_Mode_Button, Bounce)
            screen_write_to_MCU(VAR_ADDR.ModeCtrl,Treat_mode.Classic_Mode);
        elseif control == Treatment_Process_SCREEN_CONTROL.Comfort_Mode_Button and value == Press then
            set_value(SCREENID.Treatment_Process_SCREEN, Treatment_Process_SCREEN_CONTROL.Classic_Mode_Button, Bounce)
            screen_write_to_MCU(VAR_ADDR.ModeCtrl,Treat_mode.Comfort_Mode);
        elseif control == Treatment_Process_SCREEN_CONTROL.Sub_Button and value == Trigger then
            if Current_info.Gear <= 0 then
                return
            else
                Current_info.Gear = Current_info.Gear - 0.5
            end
            set_text(SCREENID.Treatment_Process_SCREEN, Treatment_Process_SCREEN_CONTROL.Gear_Text, Current_info.Gear)
            set_text(SCREENID.Power_Impedance, POWER_IMPEDANCE_SCREEN_CONTROL.Gear_Adjustment, Current_info.Gear)
            -- screen_write_to_MCU(VAR_ADDR.CoolLevel,Current_info.Cold,1);
            screen_write_to_MCU(VAR_ADDR.PowerLevel,Current_info.Gear*10);
        elseif control == Treatment_Process_SCREEN_CONTROL.Add_Button and value == Trigger then

            if Current_info.Gear >= 8 then
                return
            else
                Current_info.Gear = Current_info.Gear + 0.5
            end
            set_text(SCREENID.Treatment_Process_SCREEN, Treatment_Process_SCREEN_CONTROL.Gear_Text, Current_info.Gear)
            set_text(SCREENID.Power_Impedance, POWER_IMPEDANCE_SCREEN_CONTROL.Gear_Adjustment, Current_info.Gear)
            -- screen_write_to_MCU(VAR_ADDR.CoolLevel,Current_info.Cold,1);
            screen_write_to_MCU(VAR_ADDR.PowerLevel,Current_info.Gear*10);

        elseif control == Treatment_Process_SCREEN_CONTROL.Cold_Button and value == Trigger then

            -- screen_write_to_MCU(VAR_ADDR.CoolLevel,Current_info.Cold,1);

        elseif control == Treatment_Process_SCREEN_CONTROL.Vibration_Button  then

            Current_info.Vibration = value
            set_value(SCREENID.Treatment_Process_SCREEN, Treatment_Process_SCREEN_CONTROL.Vibration_Icon, value)
            print("Current_info.Vibration="..Current_info.Vibration)
            screen_write_to_MCU(VAR_ADDR.VibrateBtn,Current_info.Vibration);

        end
    
    elseif screen == SCREENID.Setting_SCREEN then

        if (control == Setting_SCREEN_CONTROL.Voice_Slider) then
            set_volume(value*10)
            set_value(SCREENID.Setting_SCREEN, Setting_SCREEN_CONTROL.Voice_Progress, value)
        elseif control == Setting_SCREEN_CONTROL.Brightness_Slider  then
            set_value(SCREENID.Setting_SCREEN, Setting_SCREEN_CONTROL.Brightness_Press, value)
            set_backlight(value*25)
        end

    elseif screen == SCREENID.Engineer_Password_SCREEN then

        if control >= Engineer_Password_SCREEN_CONTROL.NUM0 and control <= Engineer_Password_SCREEN_CONTROL.Letter_Z and value ==Trigger then

            print(string.len(Engineer_Password_input_buff))
            if string.len(Engineer_Password_input_buff) <=10 then
                Engineer_Password_input_buff=Engineer_Password_input_buff..string.char(control)
                set_text( SCREENID.Engineer_Password_SCREEN,Engineer_Password_SCREEN_CONTROL.Password_Input_Box,Engineer_Password_input_buff)
            end
        
        elseif control == Engineer_Password_SCREEN_CONTROL.Confirm and value ==Trigger then

            screen_write_to_MCU(VAR_ADDR.VerifyCodeText,Timestamp_frame(Current_info.timestamps),1);
            Engineer_Password_input_buff = ""
            set_text(SCREENID.Engineer_Password_SCREEN,
                Engineer_Password_SCREEN_CONTROL.Password_Input_Box, Engineer_Password_input_buff)

        elseif control == Engineer_Password_SCREEN_CONTROL.Delete and value ==Trigger then
            local len = string.len(Engineer_Password_input_buff)
            if len > 0 then
                -- 移除最后一个字符
                Engineer_Password_input_buff = string.sub(Engineer_Password_input_buff, 1, len - 1)
                -- 更新显示
                set_text(SCREENID.Engineer_Password_SCREEN, Engineer_Password_SCREEN_CONTROL.Password_Input_Box, Engineer_Password_input_buff)
                -- 可选：添加删除提示音或反馈
                print("删除一个字符，当前长度:", string.len(Engineer_Password_input_buff))
            else
                -- 可选：当字符串为空时的反馈
                print("密码输入框已为空")
            end
           
        elseif control == Engineer_Password_SCREEN_CONTROL.Cancel and value ==Trigger then

            Engineer_Password_input_buff = ""
            set_text(SCREENID.Engineer_Password_SCREEN,
                Engineer_Password_SCREEN_CONTROL.Password_Input_Box, Engineer_Password_input_buff)
        end

    elseif screen == SCREENID.Engineer_Select_SCREEN then

        
    elseif screen == SCREENID.Power_Impedance then

        if control == POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value_Add and value == Trigger then

            print(get_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value))
            
            Current_info.Voltage_Value=Current_info.Voltage_Value+1
            if Current_info.Voltage_Value >= 32 then
                Current_info.Voltage_Value = 32.0
            end
            set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value,Current_info.Voltage_Value)  
            set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Relay_VoltAdjustData,Current_info.Voltage_Value)
            screen_write_to_MCU(VAR_ADDR.VoltAdjustData,Current_info.Voltage_Value*10,1)

        elseif control == POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value_Sub and value == Trigger  then
            print(get_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value))
            if Current_info.Voltage_Value >= 7 then
                Current_info.Voltage_Value=Current_info.Voltage_Value-1
                set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value,Current_info.Voltage_Value)  
                set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Relay_VoltAdjustData,Current_info.Voltage_Value)
            end
            screen_write_to_MCU(VAR_ADDR.VoltAdjustData,Current_info.Voltage_Value*10,1)
        elseif control == POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value   then
            Current_info.Voltage_Value=get_value(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value)
            print(get_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value))
            set_text(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Relay_VoltAdjustData,Current_info.Voltage_Value)
            screen_write_to_MCU(VAR_ADDR.VoltAdjustData,Current_info.Voltage_Value*10,1)

        elseif control == POWER_IMPEDANCE_SCREEN_CONTROL.Gear_Adjustment_Add and value == Trigger  then
            
            if Current_info.Setting_Gear >= 8 then
                return
            else
                Current_info.Setting_Gear = Current_info.Setting_Gear + 0.5
            end
            print("Setting_Gear"..Current_info.Setting_Gear)
            set_text(SCREENID.Treatment_Process_SCREEN, Treatment_Process_SCREEN_CONTROL.Gear_Text, Current_info.Gear)
            set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Gear_Adjustment,Current_info.Setting_Gear)  
            screen_write_to_MCU(VAR_ADDR.PowerLevel,Current_info.Setting_Gear*10,1)
            
        elseif control == POWER_IMPEDANCE_SCREEN_CONTROL.Gear_Adjustment_Sub and value == Trigger  then
            if Current_info.Setting_Gear <= 0 then
                return
            else
                Current_info.Setting_Gear = Current_info.Setting_Gear - 0.5
            end
            print("Setting_Gear"..Current_info.Setting_Gear)
            set_text(SCREENID.Treatment_Process_SCREEN, Treatment_Process_SCREEN_CONTROL.Gear_Text, Current_info.Gear)
            set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Gear_Adjustment,Current_info.Setting_Gear)  
            screen_write_to_MCU(VAR_ADDR.PowerLevel,Current_info.Setting_Gear*10,1)
        elseif control == POWER_IMPEDANCE_SCREEN_CONTROL.RF_Output_State   then
           set_value(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.RFswitch,value)
        end

    elseif screen == SCREENID.Relay_Control_SCREEN then
        
        if control >= 1 and  control <= 22  then
            for i = 1 , 22 ,1 do 
                Current_info.Switch_info=setBitTo(Current_info.Switch_info,i-1,get_value(SCREENID.Relay_Control_SCREEN,i))
                -- print("Current_info.Switch_info:"..Current_info.Switch_info)
            end
            -- Current_info.Switch_info=setBitTo(Current_info.Switch_info,control-1,value)
            print("Current_info.Switch_info:"..Current_info.Switch_info)
            screen_write_to_MCU(VAR_ADDR.Switch_Info,Current_info.Switch_info)
        end 
        if control == 23 and value == Trigger then
            Current_info.Switch_info=0
            for i = 1 ,22 ,1 do 
                set_value(SCREENID.Relay_Control_SCREEN,i,0)
            end 
            screen_write_to_MCU(VAR_ADDR.Switch_Info,Current_info.Switch_info)
        end
        if control == Relay_Control_SCREEN_CONRTOL.Relay_VoltAdjustData   then
            Current_info.Voltage_Value=get_value(SCREENID.Relay_Control_SCREEN,Relay_Control_SCREEN_CONRTOL.Relay_VoltAdjustData)
            set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Voltage_Value,Current_info.Voltage_Value)
            print(get_text(SCREENID.Power_Impedance,Relay_Control_SCREEN_CONRTOL.Relay_VoltAdjustData))
            screen_write_to_MCU(VAR_ADDR.VoltAdjustData,Current_info.Voltage_Value*10,1)
        elseif control ==Relay_Control_SCREEN_CONRTOL.RFswitch then
            
           set_value(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.RF_Output_State,value)

        end
    elseif screen == SCREENID.Impedance_Distribution_Matching_SCREEN then
            if control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Save_Button and value == Trigger then
                
            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Spray_Coolant_Button  and value == Trigger then
                
            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Start_Treatment_Button  and value == Trigger then

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Automatic_Refrigerant_Control  and value == Trigger then
                
            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Plus  then
                Current_info.Match_Pulse_Duration_Plus=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Plus)
                screen_write_to_MCU(VAR_ADDR.MatchPulseDur,Current_info.Match_Pulse_Duration_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Plus_Add  and value == Trigger then
                Current_info.Match_Pulse_Duration_Plus=Cycle_ADD(Current_info.Match_Pulse_Duration_Plus,200,1,2,0)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Plus,Current_info.Match_Pulse_Duration_Plus)
                screen_write_to_MCU(VAR_ADDR.MatchPulseDur,Current_info.Match_Pulse_Duration_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Plus_Sub  and value == Trigger then
                Current_info.Match_Pulse_Duration_Plus=Cycle_SUB(Current_info.Match_Pulse_Duration_Plus,1,1,2,0)      
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Plus,Current_info.Match_Pulse_Duration_Plus)    
                screen_write_to_MCU(VAR_ADDR.MatchPulseDur,Current_info.Match_Pulse_Duration_Plus,2)   

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Value   then
                Current_info.Match_Pulse_Duration_Value=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Value)
                screen_write_to_MCU(VAR_ADDR.MatchPulseInt,Current_info.Match_Pulse_Duration_Value,2) 
                
            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Value_Add  and value == Trigger then
                Current_info.Match_Pulse_Duration_Value=Cycle_ADD(Current_info.Match_Pulse_Duration_Value,200,1,2,0)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Value,Current_info.Match_Pulse_Duration_Value)
                screen_write_to_MCU(VAR_ADDR.MatchPulseInt,Current_info.Match_Pulse_Duration_Value,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Value_Sub  and value == Trigger then
                Current_info.Match_Pulse_Duration_Value=Cycle_SUB(Current_info.Match_Pulse_Duration_Value,1,1,2,0)      
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Match_Pulse_Duration_Value,Current_info.Match_Pulse_Duration_Value)
                screen_write_to_MCU(VAR_ADDR.MatchPulseInt,Current_info.Match_Pulse_Duration_Value,2) 

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Single_Coolant_Duration_Plus then
                Current_info.Single_Coolant_Duration_Plus=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.Single_Coolant_Duration_Plus)
                screen_write_to_MCU(VAR_ADDR.CoolantDur,Current_info.Single_Coolant_Duration_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Single_Coolant_Duration_Plus_Add  and value == Trigger then
                Current_info.Single_Coolant_Duration_Plus=Cycle_ADD(Current_info.Single_Coolant_Duration_Plus,100,1,2,0)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Single_Coolant_Duration_Plus,Current_info.Single_Coolant_Duration_Plus)
                screen_write_to_MCU(VAR_ADDR.CoolantDur,Current_info.Single_Coolant_Duration_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Single_Coolant_Duration_Plus_Sub  and value == Trigger then
                Current_info.Single_Coolant_Duration_Plus=Cycle_SUB(Current_info.Single_Coolant_Duration_Plus,2,1,2,0)      
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Single_Coolant_Duration_Plus,Current_info.Single_Coolant_Duration_Plus)
                screen_write_to_MCU(VAR_ADDR.CoolantDur,Current_info.Single_Coolant_Duration_Plus,2)
                
            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Count   then
                Current_info.Test_Count=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Count)
                screen_write_to_MCU(VAR_ADDR.Test_Count,Current_info.Test_Count,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Count_Add  and value == Trigger then
                Current_info.Test_Count=Cycle_ADD(Current_info.Test_Count,9999,1,2,0)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Count,Current_info.Test_Count) 
                screen_write_to_MCU(VAR_ADDR.Test_Count,Current_info.Test_Count,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Count_Sub  and value == Trigger then
                Current_info.Test_Count=Cycle_SUB(Current_info.Test_Count,1,1,2,0)                
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Count,Current_info.Test_Count)  
                screen_write_to_MCU(VAR_ADDR.Test_Count,Current_info.Test_Count,2)


            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Duration_Plus   then
                Current_info.K_Pulse_Duration_Plus=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Duration_Plus)
                screen_write_to_MCU(VAR_ADDR.K_Pulse_Duration_Plus,Current_info.K_Pulse_Duration_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Duration_Plus_Add  and value == Trigger then
                Current_info.K_Pulse_Duration_Plus=Cycle_ADD(Current_info.K_Pulse_Duration_Plus,1000,10,1,0)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Duration_Plus,Current_info.K_Pulse_Duration_Plus)      
                screen_write_to_MCU(VAR_ADDR.K_Pulse_Duration_Plus,Current_info.K_Pulse_Duration_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Duration_Plus_Sub  and value == Trigger then
                Current_info.K_Pulse_Duration_Plus=Cycle_SUB(Current_info.K_Pulse_Duration_Plus,20,10,2,0)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Duration_Plus,Current_info.K_Pulse_Duration_Plus)      
                screen_write_to_MCU(VAR_ADDR.K_Pulse_Duration_Plus,Current_info.K_Pulse_Duration_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Interval_Plus   then
                Current_info.K_Pulse_Interval_Plus=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Interval_Plus)
                screen_write_to_MCU(VAR_ADDR.K_Pulse_Interval_Plus,Current_info.K_Pulse_Interval_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Interval_Plus_Add  and value == Trigger then
                Current_info.K_Pulse_Interval_Plus=Cycle_ADD(Current_info.K_Pulse_Interval_Plus,1000,10,2,1000)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Interval_Plus,Current_info.K_Pulse_Interval_Plus)   
                screen_write_to_MCU(VAR_ADDR.K_Pulse_Interval_Plus,Current_info.K_Pulse_Interval_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Interval_Plus_Sub  and value == Trigger then
                Current_info.K_Pulse_Interval_Plus=Cycle_SUB(Current_info.K_Pulse_Interval_Plus,20,10,2,20)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Interval_Plus,Current_info.K_Pulse_Interval_Plus)  
                screen_write_to_MCU(VAR_ADDR.K_Pulse_Interval_Plus,Current_info.K_Pulse_Interval_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Count_Plus   then
                Current_info.K_Pulse_Count_Plus=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Count_Plus)
                screen_write_to_MCU(VAR_ADDR.K_Pulse_Count_Plus,Current_info.K_Pulse_Count_Plus,2)  

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Count_Plus_Add  and value == Trigger then
                Current_info.K_Pulse_Count_Plus=Cycle_ADD(Current_info.K_Pulse_Count_Plus,100,1,2,0)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Count_Plus,Current_info.K_Pulse_Count_Plus)   
                screen_write_to_MCU(VAR_ADDR.K_Pulse_Count_Plus,Current_info.K_Pulse_Count_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Count_Plus_Sub  and value == Trigger then
                Current_info.K_Pulse_Count_Plus=Cycle_SUB(Current_info.K_Pulse_Count_Plus,1,1,2,0)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.K_Pulse_Count_Plus,Current_info.K_Pulse_Count_Plus)     
                screen_write_to_MCU(VAR_ADDR.K_Pulse_Count_Plus,Current_info.K_Pulse_Count_Plus,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Interval  then
                Current_info.Test_Interval=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Interval)
                screen_write_to_MCU(VAR_ADDR.Test_Interval,Current_info.Test_Interval,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Interval_Add  and value == Trigger then
                Current_info.Test_Interval=Cycle_ADD(Current_info.Test_Interval,999,1,2,0)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Interval,Current_info.Test_Interval)     
                screen_write_to_MCU(VAR_ADDR.Test_Interval,Current_info.Test_Interval,2) 

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Interval_Sub  and value == Trigger then

                Current_info.Test_Interval=Cycle_SUB(Current_info.Test_Interval,2,1,2,0)
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Test_Interval,Current_info.Test_Interval)    
                screen_write_to_MCU(VAR_ADDR.Test_Interval,Current_info.Test_Interval,2)
                
            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_R  then

                Current_info.Impedance_R=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_R)
                screen_write_to_MCU(VAR_ADDR.Impedance_R,Current_info.Impedance_R,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_X  then

                Current_info.Impedance_X=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_X)
                screen_write_to_MCU(VAR_ADDR.Impedance_X,Current_info.Impedance_X,2)

            elseif control == IMPEDANCE_MATCHING_SCREEN_CONTROL.CurrentRecord  then

                Current_info.CurrentRecord=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.CurrentRecord)
                screen_write_to_MCU(VAR_ADDR.CurrentRecord,Current_info.CurrentRecord,2)

            end
    elseif screen == 16 then
        if control == 1 then 
            set_value (16,2,get_value(16,2)+1)
        end

    elseif screen == SCREENID.Status_Check_SCREEN then
            if control == STATUS_VIEW_SCREEN_CONTROL.Match_Save_Button and value == Trigger then
                
            elseif control == STATUS_VIEW_SCREEN_CONTROL.ReleaseThreshold  then

                Current_info.ReleaseThreshold=get_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.ReleaseThreshold)
                screen_write_to_MCU(VAR_ADDR.ReleaseThreshold,Current_info.ReleaseThreshold,2)

            elseif control == STATUS_VIEW_SCREEN_CONTROL.ReleaseThreshold_add  and value == Trigger then
                Current_info.ReleaseThreshold=Cycle_ADD(Current_info.ReleaseThreshold,9999,10,2,0)
                set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.ReleaseThreshold,Current_info.ReleaseThreshold)   
                screen_write_to_MCU(VAR_ADDR.ReleaseThreshold,Current_info.ReleaseThreshold,2)

            elseif control == STATUS_VIEW_SCREEN_CONTROL.ReleaseThreshold_sub  and value == Trigger then

                Current_info.ReleaseThreshold=Cycle_SUB(Current_info.ReleaseThreshold,2,10,2,0)
                set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.ReleaseThreshold,Current_info.ReleaseThreshold)    
                screen_write_to_MCU(VAR_ADDR.ReleaseThreshold,Current_info.ReleaseThreshold,2)
                
            
            elseif control == STATUS_VIEW_SCREEN_CONTROL.PressThreshold  then

                Current_info.PressThreshold=get_value(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.PressThreshold)
                screen_write_to_MCU(VAR_ADDR.PressThreshold,Current_info.PressThreshold,2)


            elseif control == STATUS_VIEW_SCREEN_CONTROL.PressThreshold_add  and value == Trigger then
                Current_info.PressThreshold=Cycle_ADD(Current_info.PressThreshold,9999,10,2,0)
                set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.PressThreshold,Current_info.PressThreshold)   
                screen_write_to_MCU(VAR_ADDR.PressThreshold,Current_info.PressThreshold,2)

            elseif control == STATUS_VIEW_SCREEN_CONTROL.PressThreshold_sub  and value == Trigger then

                Current_info.PressThreshold=Cycle_SUB(Current_info.PressThreshold,2,10,2,0)
                set_text(SCREENID.Status_Check_SCREEN,STATUS_VIEW_SCREEN_CONTROL.PressThreshold,Current_info.PressThreshold)    
                screen_write_to_MCU(VAR_ADDR.PressThreshold,Current_info.PressThreshold,2)
                
            end

    elseif screen == SCREENID.RF_Calibration_SCREEN then
            -- if control == RF_CALIBRATION_SCREEN_CONTROL.Current_Voltage and value == Trigger then
                
            if control == RF_CALIBRATION_SCREEN_CONTROL.Current_Voltage_add and value == Trigger then
                Current_info.Current_Voltage=Current_info.Current_Voltage+1
                set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Current_Voltage,Current_info.Current_Voltage)  
                set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Current_Voltage,Current_info.Current_Voltage)  
                screen_write_to_MCU(VAR_ADDR.Current_Voltage,Current_info.Current_Voltage*10,1)
            elseif control == RF_CALIBRATION_SCREEN_CONTROL.Current_Voltage_sub and value == Trigger  then
                if Current_info.Current_Voltage >= 1 then
                    Current_info.Current_Voltage=Current_info.Current_Voltage-1
                    set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Current_Voltage,Current_info.Current_Voltage)  
                    set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Current_Voltage,Current_info.Current_Voltage)  
                end
                screen_write_to_MCU(VAR_ADDR.Current_Voltage,Current_info.Current_Voltage*10,1)
            elseif control == RF_CALIBRATION_SCREEN_CONTROL.Current_Voltage   then
                Current_info.Current_Voltage=get_value(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Current_Voltage)
                set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Current_Voltage,Current_info.Current_Voltage)  
                screen_write_to_MCU(VAR_ADDR.Current_Voltage,Current_info.Current_Voltage*10,1)
            end
            
            if control == RF_CALIBRATION_SCREEN_CONTROL.Measure_Pulse_Duration_add and value == Trigger then
                Current_info.Current_Voltage=Current_info.Current_Voltage+1
                set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Measure_Pulse_Duration,Current_info.Current_Voltage)  
                set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Current_Voltage,Current_info.Current_Voltage)  
                screen_write_to_MCU(VAR_ADDR.Measure_Pulse_Duration,Current_info.Current_Voltage*10,1)
                
            elseif control == RF_CALIBRATION_SCREEN_CONTROL.Measure_Pulse_Duration_sub and value == Trigger  then
                if Current_info.Current_Voltage >= 1 then
                    Current_info.Current_Voltage=Current_info.Current_Voltage-1
                    set_text(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Measure_Pulse_Duration,Current_info.Current_Voltage)  
                    set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Current_Voltage,Current_info.Current_Voltage)  
                end
                screen_write_to_MCU(VAR_ADDR.Measure_Pulse_Duration,Current_info.Current_Voltage*10,1)

            elseif control == RF_CALIBRATION_SCREEN_CONTROL.Measure_Pulse_Duration   then
                Current_info.Current_Voltage=get_value(SCREENID.RF_Calibration_SCREEN,RF_CALIBRATION_SCREEN_CONTROL.Measure_Pulse_Duration)
                set_text(SCREENID.Power_Impedance,POWER_IMPEDANCE_SCREEN_CONTROL.Current_Voltage,Current_info.Current_Voltage)  
                screen_write_to_MCU(VAR_ADDR.Measure_Pulse_Duration,Current_info.Current_Voltage*10,1)

            end
    
    elseif screen == SCREENID.Time_Calibration_SCREEN then
            if control == Time_Calibration_SCREEN_CONTROL.Calibration_Button and value == Trigger then
                local year = get_value(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.year)
                local month = get_value(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.month)
                local day = get_value(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.day)
                local hour = get_value(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.hour)
                local minute = get_value(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.minute)
                local second = get_value(SCREENID.Time_Calibration_SCREEN,Time_Calibration_SCREEN_CONTROL.second)
                local timeTable = {
                    year = year,
                    month = month,  -- 1-12
                    day = day,
                    hour = hour,    -- 0-23
                    min = minute,   -- 0-59
                    sec = second    -- 0-59
                }
                Current_info.Cali_Time = os.time(timeTable)
                screen_write_to_MCU(VAR_ADDR.Time_Cali,Current_info.Cali_Time,1)
            end
        
    elseif screen == SCREENID.Upgrade_SCREEN then
        if control == Upgrade_SCREEN_CONTROL.Upgrade_Confirm and value == Trigger then
            set_value(SCREENID.Upgrade_SCREEN,Upgrade_SCREEN_CONTROL.Upgrade_ICON,1)
        end
    elseif screen == SCREENID.Power_Debugging_Interface_SCREEN then

        if control == Power_Debugging_Interface_CONTROL.real_text  then
            power_test_tableinfo_read()
        elseif control == Power_Debugging_Interface_CONTROL.image_text  then
            power_test_tableinfo_read()
        elseif control == Power_Debugging_Interface_CONTROL.test_start and value == Trigger then
            error_flag_init()
            Current_Power_Debuginfo.voltage_num =0
            record_clear(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.info_record)
            start_timer(Timer_ID.Test_State,Timer_Info[Timer_ID.Test_State].timeout,Timer_Info[Timer_ID.Test_State].countdown,Timer_Info[Timer_ID.Test_State].timesrepeat)
                print("Current_info.Rf_Test_Flag",Current_info.Rf_Test_Flag)
            if Current_info.Rf_Test_Flag == 0 then 


                local i
                local j =1
                for i = 1 , 35 ,1 do 

                    if get_value (SCREENID.Volt_Select_SCREEN,i)==1 then

                        Current_Power_Debuginfo.voltage[j]= i
                        j=j+1

                    end 

                end
                Current_Power_Debuginfo.voltage_num=j-1
                if Current_Power_Debuginfo.voltage_num >0 then
                    Current_Power_Debuginfo.total_count =0
                    Current_info.Rf_Test_Flag = 1
                    Current_info.Rf_Test_State = 0
                    Current_Power_Debuginfo.load_real =get_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.real_text)
                    Current_Power_Debuginfo.load_imag =get_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.image_text)
                    print("Current_Power_Debuginfo.voltage_num",Current_Power_Debuginfo.voltage_num)
                    for  i = 1 ,#Current_Power_Debuginfo.voltage,1 do 
                        if Current_Power_Debuginfo.voltage[i]~=nil then
                            
                            print("Current_Power_Debuginfo.voltage"..Current_Power_Debuginfo.voltage[i])
                        end
                    end
                    set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.test_text,"停止")
                    screen_write_to_MCU(VAR_ADDR.VoltAdjustMode,0x00,1);
                    screen_write_to_MCU(VAR_ADDR.VoltAdjustData,(Current_Power_Debuginfo.voltage[Current_Power_Debuginfo.total_count+1]*10),1);
                    start_timer(Timer_ID.RF_Start,Timer_Info[Timer_ID.RF_Start].timeout,Timer_Info[Timer_ID.RF_Start].countdown,Current_Power_Debuginfo.voltage_num)
                    
                    if Current_info.Rf_Test_Flag ==1 then
                        
                        Current_info.Rf_Test_State = 1

                    end
                    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.save_button,1)
                    set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Show_Error_Code,"")
                    Power_test_screen_control_enable(0)
                    Power_verify_screen_control_enable(1)
                    Current_Power_Debuginfo.real_total= 0 
                    Current_Power_Debuginfo.imag_total= 0 
                end

            else

            end
            
            -- screen_write_to_MCU(VAR_ADDR.Volt_select,Current_Power_Debuginfo.voltage,1)

        elseif control == Power_Debugging_Interface_CONTROL.download and value == Trigger then
            if file_open(Data_File_name,0x01)  == true then
                file_close()
                send_file_info(Data_File_name)
                Uart_send_file_flag = 1 
                start_timer(Timer_ID.Uart_send_file,Timer_Info[Timer_ID.Uart_send_file].timeout,Timer_Info[Timer_ID.Uart_send_file].countdown,Timer_Info[Timer_ID.Uart_send_file].timesrepeat)
            end
            -- send_file_data(Data_File_name)
        elseif control == Power_Debugging_Interface_CONTROL.save_button and value == Trigger then
                print("Current_info.Rf_Test_Flag"..Current_info.Rf_Test_Flag)
            if Current_info.Rf_Test_Flag== 0 then 
                set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.file_progress,"save...")
                Current_info.New_Table=Get_Tableinfo_Fromscreen()
                print("Current_info.New_Table"..Current_info.New_Table.group_count)
                local  target_real  = get_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.real_text)
                local  target_image  = get_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.image_text)
                local id = find_table_by_load(Data_File_name,target_real,target_image)
                if id == -1 then
                    set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.file_progress,"save error")
                else

                    save_table_by_id(Data_File_name,id,Current_info.New_Table)
                    ImpedanceX_Save_Times[target_real][target_image] =ImpedanceX_Save_Times[target_real][target_image] +1
                    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.save_button,0)
                    set_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.save_times,ImpedanceX_Save_Times[target_real][target_image])
                    set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.file_progress,"save success")

                end
            else

                set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.save_button,0)
                stop_timer(Timer_ID.RF_Start)
                Current_info.Rf_Test_Flag=0
                Current_info.Rf_Test_State=0
                set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.test_text,"保存")
                Power_test_screen_control_enable(1)
                Power_verify_screen_control_enable(1)

            end

 
        end

    elseif screen == SCREENID.Volt_Select_SCREEN then

    elseif screen == SCREENID.Current_Error_Code_SCREEN then
    elseif screen == SCREENID.History_Error_Code_SCREEN then
    elseif screen == SCREENID.Power_Verify_SCREEN then
            if control == Power_Verify_Interface_CONTROL.image_text then
                
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_R,get_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.real_text))
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_X,get_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.image_text))
                load_verify_group_to_screen()

            elseif control == Power_Verify_Interface_CONTROL.real_text then
                
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_R,get_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.real_text))
                set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_X,get_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.image_text))
                load_verify_group_to_screen()
                

            elseif control == Power_Verify_Interface_CONTROL.test_start and value == Trigger then
                if Current_info.Verify_Rf_Test_Flag == 0 and Current_info.Retest_Select_Test_Flag ==0 then
                    local count = 0
                    for i=1 ,16 , 1 do
                        if get_value(SCREENID.Geer_Select_Verify_SCREEN,i) == 1 then
                            count= count+1
                            Current_info.Verify_Gear_Select[count] = i/2
                            if DEBUGFLAG == 1 then
                                
                                print("Current_info.Verify_Gear_Select[count].."..Current_info.Verify_Gear_Select[count])

                            end
                        end
                    end
                    if count ~= 0 then
                        record_clear(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.info_record)
                        Current_info.Verify_Rf_Test_Flag=1
                        Current_Power_Verifyinfo.total_Geer =count
                        Current_Power_Verifyinfo.Geer_count =0
                        start_timer(Timer_ID.Verify_Gear_RF_Timer,Timer_Info[Timer_ID.Verify_Gear_RF_Timer].timeout,Timer_Info[Timer_ID.Verify_Gear_RF_Timer].countdown,Timer_Info[Timer_ID.Verify_Gear_RF_Timer].timesrepeat)
                        Power_verify_screen_control_enable(0)
                        screen_write_to_MCU(VAR_ADDR.PowerLevel,Current_info.Verify_Gear_Select[1]*10,1)
                        screen_write_to_MCU(VAR_ADDR.VoltAdjustMode,0x01,1);
                    end
                    
                end
                -- screen_write_to_MCU(VAR_ADDR.PowerLevel,1,1)
            elseif control == Power_Verify_Interface_CONTROL.test_stop  and value == Trigger then
                
                stop_timer(Timer_ID.Verify_Gear_RF_Timer)
                Current_info.Verify_Rf_Test_Flag  = 0
                Current_info.Retest_Select_Test_Flag =0
                Power_verify_screen_control_enable(1)

            elseif control == Power_Verify_Interface_CONTROL.save_button and value == Trigger then

                -- local record_info_num = record_get_count(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.info_record)
                local real_x = get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.real_text)
                local image_x = get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.image_text)
                -- local record_select_info = ""
                -- local data
                -- for i =  0 ,record_info_num-1,1 do
                --     local parts = {}
                    
                --     record_select_info = record_read(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.info_record,i)
                --     print("record_select_info",record_select_info)
                --     for part in string.gmatch(record_select_info, "[^;]+") do
                --         table.insert(parts, part)
                --     end
        
                --     if #parts >= 5 then
                --     -- 提取四个字段
                --         data = {
                --             geer = parts[1],  -- 档位实测功率
                --             measured_power = parts[2], -- 档位实测功率
                --             machine_power = parts[3],   -- 机器功率
                --             error = parts[4],           -- 误差（可能带百分号）
                --             result = parts[5]                      -- 结果
                --         }   
                --     else
                --         print("错误：数据不完整，只有 " .. #parts .. " 个字段")
                --     end
                    
                --     print("format_record_line"..format_record_line(real_x,image_x,data.geer,data.measured_power,data.machine_power,data.error,data.result))
                --     print("replace_semicolons.."..replace_semicolons(record_select_info))
                --     print("data.geer",data.geer)
                --     print("data.measured_power",data.measured_power)
                --     print("data.machine_power",data.machine_power)
                --     print("data.error",data.error)
                --     print("data.result",data.result)

                -- end
                local info
                local err
                local info_list  ={}
                info_list =collect_group_from_table(SCREENID.Power_Verify_SCREEN ,Power_Verify_Interface_CONTROL.info_record)
                if info_list~=nil then
                    print("info_list"..info_list[1].gear)
                else
                     
                    print("info_list_nil")
                end
                info,err = impedance_db_save_group(real_x,image_x,info_list)
                print (err)
                -- file_read()
            elseif control == Power_Verify_Interface_CONTROL.result_export and value == Trigger then
                if file_open(Verify_File_name,0x01)  == true then
                    file_close()
                    Verify_send_file_info(Verify_File_name)
                    Uart_send_Verify_file_flag = 1 
                    start_timer(Timer_ID.Verify_file_send,Timer_Info[Timer_ID.Verify_file_send].timeout,Timer_Info[Timer_ID.Verify_file_send].countdown,Timer_Info[Timer_ID.Verify_file_send].timesrepeat)
                end
            elseif control== Power_Verify_Interface_CONTROL.info_record  then

            elseif control == Power_Verify_Interface_CONTROL.retest  and value == Trigger then
                if Current_info.Verify_Rf_Test_Flag == 0 and Current_info.Retest_Select_Test_Flag ==0  then
                    local select_info 
                    Current_info.Retest_Select=record_get_focusRow(SCREENID.Power_Verify_SCREEN, Power_Verify_Interface_CONTROL.info_record)
                    if Current_info.Retest_Select>=0 then

                        Current_info.Retest_Select_Geer=get_Geer_value(record_read(SCREENID.Power_Verify_SCREEN, Power_Verify_Interface_CONTROL.info_record,Current_info.Retest_Select))
                        start_timer(Timer_ID.Verify_Gear_RF_Timer,Timer_Info[Timer_ID.Verify_Gear_RF_Timer].timeout,Timer_Info[Timer_ID.Verify_Gear_RF_Timer].countdown,Timer_Info[Timer_ID.Verify_Gear_RF_Timer].timesrepeat)
                        Power_verify_screen_control_enable(0)
                        Current_info.Retest_Select_Test_Flag = 1
                        screen_write_to_MCU(VAR_ADDR.PowerLevel,Current_info.Retest_Select_Geer*10,1)
                        screen_write_to_MCU(VAR_ADDR.VoltAdjustMode,0x01,1);

                    end
                end
            elseif control == Power_Verify_Interface_CONTROL.power_verify_result and value == Trigger then
                for i = 1 ,10 ,1 do
                    for j = 1 ,5 , 1 do
                        set_back_color(SCREENID.Power_Verify_Result_SCREEN,(i-1)*5+j,0x7E0)
                        
                        local group_data, err = impedance_db_read_group(ImpedanceX_Real_table[i], ImpedanceX_Image_table[j])
                        if group_data == nil then

                            print("load_verify_group_to_screen fail:" .. tostring(err))
                            record_clear(SCREENID.Power_Verify_SCREEN, Power_Verify_Interface_CONTROL.info_record)
                            return 
                        end

                        for k = 1 ,16,1 do
                            
                            if group_data[k].result == 0 and  group_data[k].meas_power ~= 0 then

                                print("ImpedanceX_table_Error:" .. ImpedanceX_Real_table[i].."--"..ImpedanceX_Image_table[j])
                                set_back_color(SCREENID.Power_Verify_Result_SCREEN,(i-1)*5+j,0XF800)
                                break
                            end


                        end

                    end
                end
            end

    end
end

function on_uart_recv_data(packet, port)
    local hexBuf = ""
    for i = 0, #packet, 1 do
        local value = packet[i] or 0
        hexBuf = hexBuf .. string.format("%02X ", value & 0xFF)
    end
    print("recv:"..hexBuf)
    -- if Timer_Info[Timer_ID.Uart_send].waiting_ack then

    --     Timer_Info[Timer_ID.Uart_send].curtimesrepeat = Timer_Info[Timer_ID.Uart_send].curtimesrepeat + 1

    --     if Timer_Info[Timer_ID.Uart_send].curtimesrepeat <= MAX_RETRY then

    --         print("超时，重发第 "..retry_cnt.." 次")

    --         -- 重发
    --         uart_send_data(last_packet, UART_PORT)

    --         -- 重新启动定时器
    --         start_timer(Timer_Info[Timer_ID.Uart_send].timeout, Timer_Info[Timer_ID.Uart_send].timeout = 500, 0, 1)

    --     else
    --         -- 超过最大次数
    --         waiting_ack = false
    --         retry_cnt = 0

    --         print("连接失败 ")

    --     end
    screen_read(packet)
end

function on_screen_change(screen)

end

function Cycle_ADD(cur_count, max_count, step, type, result_count) -- 循环加，每步为step，若超过maxcount,判断type若type为1则返回result_count，若type为2则返回cur_count
    -- 参数验证
    if DEBUGFLAG == 1 then
        print("cur_count:" .. cur_count)
        print("max_count:" .. max_count)
        print("step:" .. step)
    end

    -- 计算新的计数值
    local new_count = cur_count + step
    if DEBUGFLAG == 1 then
        print("new_count:" .. new_count)
    end

    if new_count > max_count then
        -- 超过最大值时的处理
        if type == 1 then
            return result_count or 0
        elseif type == 2 then
            return cur_count
        else
            -- 未知类型，默认返回 result_count
            return result_count or 0
        end
    else
        -- 没有超过最大值，返回新的计数值
        return new_count
    end


end

function Cycle_SUB(cur_count, min_count, step, type, result_count)  -- 循环减，若低于
    -- 参数验证
    if DEBUGFLAG == 1 then
        print("cur_count:" .. cur_count)
        print("max_count:" .. min_count)
        print("step:" .. step)
    end

    -- 计算新的计数值
    local new_count = cur_count - step
    if DEBUGFLAG == 1 then
        print("new_count:" .. new_count)
    end

    if new_count < min_count then
        -- 超过最大值时的处理
        if type == 1 then
            return result_count or 0
        elseif type == 2 then
            return cur_count
        else
            -- 未知类型，默认返回 result_count
            return result_count or 0
        end
    else
        -- 没有超过最大值，返回新的计数值
        return new_count
    end
end

function uart_send_test() -- 循环减，若低于
    local testbuf = {}
    testbuf[0] = 1
    testbuf[1] = 2
    testbuf[2] = 3
    testbuf[3] = 4
    testbuf[4] = 5
    testbuf[5] = 6
    uart_send_data(testbuf)
end

function Treatment_Qrcode_Set(set_buf)
    set_text(SCREENID.Treatment_Not_Recognized_SCREEN, 25, "123456")
end

-- function ERROR_SEND()

-- end


-- 组帧函数
function Timestamp_frame(timestamp)
 -- 使用纯数学运算替代位操作
    local frame = {}
    
    -- 1. 时间戳部分（4字节，小端序）
    local ts = timestamp
    frame[1] = ts % 256              -- 字节1: 低8位
    ts = math.floor(ts / 256)
    frame[2] = ts % 256              -- 字节2
    ts = math.floor(ts / 256)
    frame[3] = ts % 256              -- 字节3
    ts = math.floor(ts / 256)
    frame[4] = ts % 256              -- 字节4: 高8位
    
    -- 2. 随机数部分（4字节）
    local randomNum = math.random(0xFFFF)
    frame[5] = randomNum % 256
    randomNum = math.floor(randomNum / 256)
    frame[6] = randomNum % 256
    local randomNum2 = math.random(0xFFFF)
    frame[7] = randomNum2 % 256
    randomNum = math.floor(randomNum / 256)
    frame[8] = randomNum2 % 256
    
    -- 3. 加密数据部分（8字节，前8字节每个字节加1）
    for i = 1, 8 do
        frame[8 + i] = (frame[i] + 1) % 256  -- 加1并取模256
    end
    
    return frame
end

function send_file_data(path)

    if file_open(path,0x03) ~= true then
        print("file open fail")
        return
    end

    local size = 37332
    if Current_offset < size then
        file_seek(Current_offset)
        local send_len = 200

        if Current_offset + send_len > size then
            send_len = 132
        end
        
        print("send_len:",send_len)
        local data = file_read(send_len)
        if data == nil  then 
            print("file_read file:Current_offset = ",Current_offset)
        else

            local frame = {}

            -- 当前字节位置
            frame[1] = (Current_offset) & 0xFF
            frame[2] = ((Current_offset )>> 8) & 0xFF

            -- 当前帧数据长度
            frame[3] = send_len & 0xFF
            frame[4] = (send_len >> 8) & 0xFF

            -- 数据
            for i=0,send_len-1 do
                frame[5+i] = data[i]
            end

            screen_write_to_MCU(VAR_ADDR.File_Send_Data,frame,1)
            
            set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.file_progress,string.format("%.1f",(Current_offset*100/37200)).."%")
            Current_offset = Current_offset + send_len
            print("Current_offset:",Current_offset)

        end
    else
        set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.file_progress,"success")
        Uart_send_file_flag = 0 
        Current_offset =0
    end

    file_close()

    print("file send finish")

end

function error_flag_init()
    for i= 44,53,1 do
        set_back_color(SCREENID.Power_Debugging_Interface_SCREEN,i,COLOR_GREEN)
    end
end
function get_Geer_value(str)
    local first = string.match(str, "([^;]+)")
    return tonumber(first)
end