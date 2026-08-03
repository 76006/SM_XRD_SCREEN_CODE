function bytes_to_float(buf,i) --字节转浮点数

    -- 组合为32位整数（小端序）
    local intValue = 
        buf[i] |
        (buf[i+1] << 8) |
        (buf[i+2] << 16) |
        (buf[i+3] << 24)
    return intToFloat(intValue)

end

function bytes_to_u32(buf,i) --字节转32位数据

    return buf[i]
        | (buf[i+1] << 8)
        | (buf[i+2] << 16)
        | (buf[i+3] << 24)
end


function parse_one_table(buf,start) --解析一组数据

    Current_info.Show_table = {}

    print("len",#buf)
    Current_info.Show_table.group_count = string.format("%d",bytes_to_u32(buf,start))
    Current_info.Show_table.avg_real = string.format("%.2f",bytes_to_float(buf,start+4))
    Current_info.Show_table.avg_imag = string.format("%.2f",bytes_to_float(buf,start+8))

    print("t.group_count",Current_info.Show_table.group_count)
    print("t.avg_real",Current_info.Show_table.avg_real)
    print("t.avg_imag",Current_info.Show_table.avg_imag)
    Current_info.Show_table.groups = {}

    local index = start + 12

    for i=1,Current_info.Show_table.group_count do

        local g = {}

        g.real = string.format("%.2f",bytes_to_float(buf,index))
        print("g.real",g.real)
        g.imag = string.format("%.2f",bytes_to_float(buf,index+4))
        print("g.imag",g.imag)

        print("g.relaynum",bytes_to_u32(buf,index+8))
        g.relay = dec_to_bin_group(bytes_to_u32(buf,index+8))
        print("g.relay",g.relay)

        g.voltage = string.format("%.2f",bytes_to_float(buf,index+12))
        print("g.voltage",g.voltage)
        g.power = string.format("%.2f",bytes_to_float(buf,index+16))
        print("g.power",g.power)
        g.current = string.format("%.2f",bytes_to_float(buf,index+20))
        print("g.current",g.current)

        g.load_real = bytes_to_float(buf,index+24)
        print("g.load_real",g.load_real)
        -- print("g.load_real",g.load_real)
        g.load_imag = bytes_to_float(buf,index+28)
        print("g.load_imag",g.load_imag)

        print("buf"..buf[index+28]..buf[index+29]..buf[index+30]..buf[index+31]..buf[index+32]..buf[index+33])
        print("buf"..buf[index+34])
        print("buf"..buf[index+35])
        print("buf"..buf[index+36])
        g.efficiency = string.format("%.3f",bytes_to_float(buf,index+32))
        Current_info.Show_table.groups[i] = g

        print("g.efficiency",g.efficiency)
        index = index + 36
    end
    print("parse_success")
end  

function find_table_by_load(path,target_real,target_imag) -- 找到对应的阻抗位置

        print(path)
    if file_open(path,0x01) ~= true then
        print("file open fail")
        return -1
    else
        print("file open success")
    end

    local offset = 131

    for i=1,100 do

        file_seek(offset + 36)

        local data = file_read(16)

        if DEBUGFLAG == 1 then 
            print("offset=",offset)
            print("data="..data[1]..data[2]..data[3]..data[4])
            print("data="..data[5]..data[6]..data[7]..data[8])
        end
        if data ~= nil then

            local lr = bytes_to_float(data,1)
            local li = bytes_to_float(data,5)

            print("lr="..lr)
            print("li="..li)
            if lr == target_real and li == target_imag then

                file_close()

                print("find table:",i)

                return i
            end

        end

        offset = offset + 372
    end

    file_close()

    return -1
end

function read_table_by_id(path,id) --从文件种读取出第几个块

    local offset = 131+ (id-1)*372

    if file_open(path,0x01) ~= true then
        return nil
    end

    file_seek(offset)

    local data = file_read(374)

    file_close()

    return parse_one_table(data,1)
end

function myfile_write(path,data)
    if  file_open(path,0x02|0X08) == true then
        print ("path OK")
    else
        print (path.. "Error")
    end


    if file_write(data)==true then
        print("file_writesuccess")
    else
        print("file_writefail")
    end
    print("filesize:"..file_size())
    file_close()
end

function myfile_read(count)
    file_open(path,0x03)

    local data ={}
    data=file_read(count)
    if data~=nil then
        print("data_success")
    else
        print("data_fail")
    end
    file_close()
    return data
end

function myfile_write_add(path,data)

    if  file_open(path,0x02|0x03) == true then
        print ("path OK")
    else
        print (path.. "Error")
    end
    print("filesize:"..file_size())
    file_seek(file_size())
    if file_write(data)==true then
        print("myfile_write_addsuccess")
    else
        print("myfile_write_addfail")
    end
    file_close()
end

function read_file_to_table(path)

    if file_open(path,0x01) ~= true then
        print("file open fail")
        return
    else
        print("file open OK")
    end
    local data ={}
    -- while true do
        --  file_seek(1)
        data = file_read(700)

        if data == nil then
         return 
        end
        print("data[498]"..data[698])
        print("data[499]"..data[699])
        parse_700_bytes(data,#data)

    -- end

    file_close()


end

function myfile_write_replace(path,data,location)


end

function show_table(table)    
    for i = 1,table.group_count,1 do
    

        print(table.groups[i].real..";"
        ..table.groups[i].imag..";"..table.groups[i].relay..";"..table.groups[i].voltage..";"..table.groups[i].power..";"
        ..table.groups[i].current..";"..table.groups[i].load_real..";"..table.groups[i].load_imag..";"
        ..table.groups[i].efficiency..";")
        set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.avarage_real,table.avg_real)
        set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.avarage_image,table.avg_imag)

        record_add(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.info_record,table.groups[i].real..";"
        ..table.groups[i].imag..";"..table.groups[i].relay..";"..table.groups[i].voltage..";"..table.groups[i].power..";"
        ..table.groups[i].current..";"..table.groups[i].load_real..";"..table.groups[i].load_imag..";"
        ..table.groups[i].efficiency..";")
       
    end
end



function save_table_by_id(path,id,t) --将表存入文件中

    local offset = 132 + (id-1)*372

    local data = table_to_bytes(t)
    for i = 1 ,372, 1 do
        if data[i]~= nil then
            print("data["..i.."]"..data[i])
        end
    end
    if file_open(path,0x02|0x03) ~= true then
        print("file open fail")
        return
    else
        print("file open success")
    end

    file_seek(offset)

    file_write(data)

    file_close()

    print("table saved:",id)

end

function Get_Tableinfo_Fromscreen()

    local i =0
    local record_info = {}
    record_info.groups = {}
    local avg_real_total  = 0
    local avg_imag_total  = 0
    record_info.avg_real =  0
    record_info.avg_imag = 0
    record_info.group_count = 0
    for  i = 0 ,9, 1 do  

        record_info.groups[i+1]=parse_group_string(record_read(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.info_record,i))
        print("tableinfo="..record_info.groups[i+1].real..";"
        ..record_info.groups[i+1].imag..";"..record_info.groups[i+1].relay..";"..record_info.groups[i+1].voltage..";"..record_info.groups[i+1].power..";"
        ..record_info.groups[i+1].current..";"..record_info.groups[i+1].load_real..";"..record_info.groups[i+1].load_imag..";"
        ..record_info.groups[i+1].efficiency..";")
        if record_info.groups[i+1].load_real ~=0 then
            record_info.group_count= record_info.group_count+1
        end

        avg_real_total = record_info.groups[i+1].real +avg_real_total

        avg_imag_total = record_info.groups[i+1].imag +avg_imag_total

    end

    if record_info.group_count ~= 0  then
        record_info.avg_real=string.format("%.2f",(avg_real_total /record_info.group_count))

        record_info.avg_imag=string.format("%.2f",(avg_imag_total /record_info.group_count))
    else
        record_info.avg_real =0
        record_info.avg_imag =0
    end

    return record_info

end

function parse_group_string(str) --解析一组字符串到表内

    local values_buff = {}
    local values = {}
    for v in string.gmatch(str,"([^;]+)") do
        values[#values+1] = v
    end

    if #values < 9 then

        values.real = 0
        values.imag = 0
        values.relay = 0
        values.voltage = 0
        values.power = 0
        values.current = 0
        values.load_real = 0
        values.load_imag = 0
        values.efficiency = 0

        return values

    end

    values.real = tonumber(values[1])
    print("values.real"..values.real)
    values.imag = tonumber(values[2])
    print("values.imag"..values.imag)
    values.relay = bin_to_dec(values[3])
    print("values.relay"..values.relay)
    values.voltage = tonumber(values[4])
    print("values.voltage"..values.voltage)
    values.power = tonumber(values[5])
    print("values.power"..values.power)
    values.current = tonumber(values[6])
    print("values.current"..values.power)
    values.load_real = tonumber(values[7])
    print("values.load_real"..values.power)
    values.load_imag = tonumber(values[8])
    print("values.load_imag"..values.power)
    values.efficiency = tonumber(values[9])
    print("values.efficiency"..values.power)
    
    return values
end

function table_info_record_add()
    local current_table_info  = {}
    -- current_table_info.group_count = current_table_info.group_count + 1
    Current_Power_Debuginfo.total_count = Current_Power_Debuginfo.total_count+1
    local current_count =Current_Power_Debuginfo.total_count
    print("Current_Power_Debuginfo.real_total.."..Current_Power_Debuginfo.real_total)
    print("Current_Power_Debuginfo.imag_total.."..Current_Power_Debuginfo.imag_total)
    set_text(SCREENID.Power_Debugging_Interface_SCREEN,61,Current_Power_Debuginfo.total_count  )
    set_text(SCREENID.Power_Debugging_Interface_SCREEN,62,Current_Power_Debuginfo.voltage_num)

    Current_Power_Debuginfo.real_total= Current_Power_Debuginfo.real_total+get_value (SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PreMatchImpedanceR)
    Current_Power_Debuginfo.imag_total= Current_Power_Debuginfo.imag_total+get_value (SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PreMatchImpedanceX)

    print("Current_Power_Debuginfo.voltage_num="..Current_Power_Debuginfo.voltage_num)
    print("Current_Power_Debuginfo.total_count="..Current_Power_Debuginfo.total_count)
    if Current_Power_Debuginfo.total_count  ==Current_Power_Debuginfo.voltage_num then

        current_table_info.avg_real = Current_Power_Debuginfo.real_total/Current_Power_Debuginfo.total_count
        current_table_info.avg_imag = Current_Power_Debuginfo.imag_total/Current_Power_Debuginfo.total_count
        -- set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.avarage_real,string.format("%.2f",current_table_info.avg_real))
        -- set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.avarage_image,string.format("%.2f",current_table_info.avg_imag))
        set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.person_real,get_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Body_Resistance_R))
        set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.person_image,get_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Body_Reactance_X))
        print("Current_Power_Debuginfo.voltage_num.."..Current_Power_Debuginfo.total_count)
        current_table_info.voltage= Current_Power_Debuginfo.voltage[Current_Power_Debuginfo.total_count]

        Current_Power_Debuginfo.voltage_num=    0
        Current_Power_Debuginfo.total_count = 0
        Current_Power_Debuginfo.real_total= 0 
        Current_Power_Debuginfo.imag_total= 0 
        Current_info.Rf_Test_State  = 0
        Current_info.Rf_Test_Flag    = 0
        set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.test_text,"保存")
        Power_test_screen_control_enable(1)
    else
        print ("Current_Power_Debuginfo.voltage"..Current_Power_Debuginfo.voltage[Current_Power_Debuginfo.total_count+1])
        set_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Current_Voltage,Current_Power_Debuginfo.voltage[Current_Power_Debuginfo.total_count+1])
        screen_write_to_MCU(VAR_ADDR.VoltAdjustData,(Current_Power_Debuginfo.voltage[Current_Power_Debuginfo.total_count+1]*10),1);
        if Current_info.Rf_Test_Flag ==1 then
            Current_info.Rf_Test_State = 1
        end
        print("Current_Power_Debuginfo.voltage_num.."..Current_Power_Debuginfo.total_count)
        current_table_info.voltage= Current_Power_Debuginfo.voltage[Current_Power_Debuginfo.total_count]
    end
    set_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Current_VSWR,get_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Vswr))

    current_table_info.real = get_value (SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PreMatchImpedanceR)
    current_table_info.imag = get_value (SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.PreMatchImpedanceX)

    current_table_info.relay= get_text (SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.MatchRelayValue)


    print("Current_Power_Debuginfo.voltage.."..current_table_info.voltage)
    current_table_info.power= get_value (SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.MeasuredPower)
    print("Current_Power_Debuginfo.power.."..current_table_info.power)

    current_table_info.current= get_value (SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Scope_Current)

    current_table_info.load_real= Current_Power_Debuginfo.load_real

    current_table_info.load_imag= Current_Power_Debuginfo.load_imag
    print("Current_Power_Debuginfo.load_imag.."..current_table_info.load_imag)

    current_table_info.efficiency= tonumber(string.format("%.2f",get_value (SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Efficiency)/100))
    print("Current_Power_Debuginfo.Efficiency.."..current_table_info.efficiency)

    -- current_table_info.real= 28.16

    -- current_table_info.imag= -85.55

    -- current_table_info.relay= 297301

    -- current_table_info.voltage= 11.50

    -- current_table_info.power= 25.96

    -- current_table_info.current= 1.66

    -- current_table_info.load_real= 75.0

    -- current_table_info.load_imag= 0.0

    -- current_table_info.efficiency= 0.000
    print("real="..current_table_info.real)
    print("imag="..current_table_info.imag)
    print("relay="..current_table_info.relay)
    print("voltage="..current_table_info.voltage)
    print("power="..current_table_info.power)
    print("current="..current_table_info.current)
    print("load_real="..current_table_info.load_real)
    print("load_imag="..current_table_info.load_imag)
    print("efficiency="..current_table_info.efficiency)
    print("tableinfo="..current_table_info.real..";"
    ..current_table_info.imag..";"..current_table_info.relay..";"..current_table_info.voltage..";"..current_table_info.power..";"
    ..current_table_info.current..";"..current_table_info.load_real..";"..current_table_info.load_imag..";"
    ..current_table_info.efficiency..";")
    
    local  Efficiency_threshold = 0 
    Efficiency_threshold = get_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Efficiency_threshold)/100

    if current_table_info.efficiency > Efficiency_threshold then
        set_back_color(SCREENID.Power_Debugging_Interface_SCREEN,(Power_Debugging_Interface_CONTROL.error_flag1+current_count-1),0X7E0)
    else
        set_back_color(SCREENID.Power_Debugging_Interface_SCREEN,(Power_Debugging_Interface_CONTROL.error_flag1+current_count-1),0XF800)
    end
    set_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.Current_Voltage,current_table_info.voltage)
    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.save_button,1)
    record_add(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.info_record,current_table_info.real..";"
    ..current_table_info.imag..";"..current_table_info.relay..";"..current_table_info.voltage..";"..current_table_info.power..";"
    ..current_table_info.current..";"..current_table_info.load_real..";"..current_table_info.load_imag..";"
    ..current_table_info.efficiency..";")



end

function Verify_table_info_record_add()
    local current_table_info  = {}
    local current_num = 0
    local current_Geer=0
    local calibrate_num =10
    local calibrate_power = 0
    Current_Power_Verifyinfo.Geer_count =Current_Power_Verifyinfo.Geer_count+1
    current_Geer=Current_Power_Verifyinfo.Geer_count
    if  Current_Power_Verifyinfo.Geer_count == Current_Power_Verifyinfo.total_Geer then
        Current_Power_Verifyinfo.Geer_count = 0 
        Current_info.Verify_Rf_Test_Flag = 0
        Power_verify_screen_control_enable(1)
        stop_timer(Timer_ID.Verify_Gear_RF_Timer)
    else
        
        screen_write_to_MCU(VAR_ADDR.PowerLevel,Current_info.Verify_Gear_Select[Current_Power_Verifyinfo.Geer_count+1]*10,1)
    end
    print("Geer_count="..current_Geer)
    current_table_info.Gear = Current_info.Verify_Gear_Select[current_Geer]
    print("Gear="..current_table_info.Gear)
    current_num= get_value (SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Scope_Current)
    print("current_num="..current_num)
    local x_r = 0
    x_r=get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.real_text)
    current_table_info.MeasuredPower =  current_num * current_num * x_r / 8
    
    print("MeasuredPower="..current_table_info.MeasuredPower)
    
    if get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.yimei_flag_button)  == 1 then
        calibrate_num =20
    else
        calibrate_num = 10
    end

    calibrate_power = current_table_info.Gear *calibrate_num +15 

    current_table_info.Machinepower  =  get_value(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.LongPulsePower)
    print("Machinepower="..current_table_info.Machinepower)
    local mistake_count = (current_table_info.MeasuredPower-calibrate_power) /calibrate_power
    local mistake = "" 
    mistake =(string.format("%.2f",mistake_count  ))
    print("mistake="..mistake)
    local result_flag = 0
    print("result_threshold="..get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.result_threshold))
    if mistake_count< 0 then
        mistake_count=0-mistake_count
    end

    if mistake_count  >=  get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.result_threshold)  or 
        Compare_geer_power(current_table_info.Gear,current_table_info.MeasuredPower ) == false
    
    then
        result_flag=  0
    else
        result_flag = 1
    end

    record_add(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.info_record,current_table_info.Gear..";"
    ..string.format("%.2f",current_table_info.MeasuredPower)..";"..current_table_info.Machinepower..";"..mistake..";".."$ICON"..result_flag..";")


end
function Retest_Select_record_Modify()
    
    local current_table_info  = {}
    local current_num = 0
    local standard_power  = 0 
    local calibrate_num =10
    local calibrate_power = 0
    current_table_info.Gear = Current_info.Retest_Select_Geer
    print("Gear="..current_table_info.Gear)
    current_num= get_value (SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Scope_Current)
    print("current_num="..current_num)
    local x_r = 0
    x_r=get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.real_text)
    current_table_info.MeasuredPower =  current_num * current_num * x_r  / 8
    print("MeasuredPower="..current_table_info.MeasuredPower)

        
    if get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.yimei_flag_button)  == 1 then
        calibrate_num =20
    else
        calibrate_num = 10
    end

    calibrate_power = current_table_info.Gear *calibrate_num +15 

    current_table_info.Machinepower  =  get_value(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.LongPulsePower)
    print("Machinepower="..current_table_info.Machinepower)
    local mistake_count = (current_table_info.MeasuredPower-calibrate_power) /calibrate_power
    local mistake = "" 
    mistake =(string.format("%.2f",mistake_count  ))
    print("mistake="..mistake)
    local result_flag = 0
    print("result_threshold="..get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.result_threshold))
    if mistake_count< 0 then
        mistake_count=0-mistake_count
    end
    if mistake_count  >=  get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.result_threshold) or
        Compare_geer_power(current_table_info.Gear,current_table_info.MeasuredPower ) == false 
        then
        result_flag= 0
    else
        result_flag = 1
    end

    Current_info.Retest_Select_Test_Flag = 0
    record_modify(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.info_record,Current_info.Retest_Select,current_table_info.Gear..";"
    ..string.format("%.2f",current_table_info.MeasuredPower)..";"..current_table_info.Machinepower..";"..mistake..";".."$ICON"..result_flag..";")
    Power_verify_screen_control_enable(1)

end

function table_to_bytes(t)

    local buf = {}
    local index = 0
    print(t.group_count)
    write_u32(buf,index,t.group_count)
    index = index + 4

    print(t.avg_real)
    write_float(buf,index,t.avg_real)
    index = index + 4

    print(t.avg_imag)
    write_float(buf,index,t.avg_imag)
    index = index + 4

    for i=1,t.group_count do

        local g = t.groups[i]

        write_float(buf,index,g.real); index=index+4
        write_float(buf,index,g.imag); index=index+4
        write_u32(buf,index,g.relay); index=index+4

        write_float(buf,index,g.voltage); index=index+4
        write_float(buf,index,g.power); index=index+4
        write_float(buf,index,g.current); index=index+4

        write_float(buf,index,g.load_real); index=index+4
        write_float(buf,index,g.load_imag); index=index+4
        write_float(buf,index,g.efficiency); index=index+4

    end

    return buf
end
function write_u32(buf,index,value)

    buf[index]   = value & 0xFF
    buf[index+1] = (value >> 8) & 0xFF
    buf[index+2] = (value >> 16) & 0xFF
    buf[index+3] = (value >> 24) & 0xFF

end

function write_float(buf,index,value)

    local s = string.pack("<f",value)

    buf[index]   = string.byte(s,1)
    buf[index+1] = string.byte(s,2)
    buf[index+2] = string.byte(s,3)
    buf[index+3] = string.byte(s,4)

end

function send_file_info(path)

    local size,crc = file_crc16(path)

    if size == nil then
        return
    end
    size = 37332
    print("file size:",size)
    print("file crc:",crc)

    local buf = {}

    -- 文件大小 (4字节)
    buf[1] = size & 0xFF
    buf[2] = (size >> 8) & 0xFF

    -- CRC16 (2字节)
    buf[3] = crc & 0xFF
    buf[4] = (crc >> 8) & 0xFF

    screen_write_to_MCU(VAR_ADDR.File_Send_Creat,buf,4)

end

function Verify_send_file_info(path)

    local size,crc = verigy_file_crc16(path)

    if size == nil then
        return
    end
    size = 32000
    print("file size:",size)
    print("file crc:",crc)

    local buf = {}

    -- 文件大小 (4字节)
    buf[1] = size & 0xFF
    buf[2] = (size >> 8) & 0xFF

    -- CRC16 (2字节)
    buf[3] = crc & 0xFF
    buf[4] = (crc >> 8) & 0xFF

    screen_write_to_MCU(VAR_ADDR.Verify_File_Send_Info_MCU,buf,4)

end

function file_crc16(path)

    local crc = 0xFFFF
    print("path="..path)

    if file_open(path,0x03) ~= true then
        print("open fail")
        Uart_send_file_flag = 0
        stop_timer(Timer_ID.Uart_send_file)
        return nil
    else
        
        print("open success")
    end

    local size = 37332
    local pos = 0

    while pos < size do

        local read_len = 200
        if pos + read_len > size then
            read_len = size - pos
        end
        file_seek(pos)
        local data = file_read(read_len)
        if data == nil then

            print("read fail pos=",pos)
            break

        else

            for i=0,read_len-1 do
                crc = crc16_update(crc,data[i])
            end

        end
        pos = pos + read_len
        file_seek(pos)
        data = nil
        print("pos:",pos,"crc:",crc)

    end

    file_close()

    print("file_crc16 cal success")

    return size,crc
end
function verigy_file_crc16(path)

    local crc = 0xFFFF
    print("path="..path)

    if file_open(path,0x03) ~= true then
        print("open fail")
        Uart_send_Verify_file_flag = 0
        stop_timer(Timer_ID.Verify_file_send)
        return nil
    else
        
        print("open success")
    end

    local size = 32000
    local pos = 0

    while pos < size do

        local read_len = 200
        if pos + read_len > size then
            read_len = size - pos
        end
        file_seek(pos)
        local data = file_read(read_len)
        if data == nil then

            print("read fail pos=",pos)
            break

        else

            for i=0,read_len-1 do
                crc = crc16_update(crc,data[i])
            end

        end
        pos = pos + read_len
        file_seek(pos)
        data = nil
        print("pos:",pos,"crc:",crc)

    end

    file_close()

    print("file_crc16 cal success")

    return size,crc
end
function crc16_update(crc, byte)

    crc = crc ~ byte

    for i=1,8 do
        if (crc & 1) ~= 0 then
            crc = (crc >> 1) ~ 0xA001
        else
            crc = crc >> 1
        end
    end

    return crc & 0xFFFF
end

function bin_to_dec(bin_str)
    local result = 0
    local len = string.len(bin_str)

    for i = 1, len do
        local bit = string.sub(bin_str, i, i)
        if bit == "1" then
            result = result + 2^( i-1)
        end
    end

    return result
end

function dec_to_bin(num ,total_bits )
    local result = ""

    while num > 0 do
        local bit = num % 2
        result = bit .. result
        num = math.floor(num / 2)
    end

    -- 补零到指定长度
    if total_bits then
        result = string.rep("0", total_bits - #result) .. result
    end

    return result
end

function dec_to_bin_group(num)
    local bin = dec_to_bin(num, 21)  -- 20位
    local reversed = ""
    for i = #bin, 1, -1 do
        reversed = reversed .. bin:sub(i, i)
    end
    return reversed
end

function verify_file_create(path)

    if file_open(path,0x01) ~= true then
        print("open fail")
        local datainit ={}
        for j=0, 263 , 1 do
            datainit[j]=0
        end
        file_open(path,0x04|0x02)
        for  i = 0 , 100 ,1 do 
            myfile_write_add (path,datainit)
        end
            file_close()

    else
        print("open success")
        file_close()
    end

end

function power_test_tableinfo_read()
    set_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.save_times,0)
    error_flag_init()
    set_enable(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.save_button,0)
    record_clear(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.info_record)
    local  target_real  = get_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.real_text)
    local  target_image  = get_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.image_text)
    set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_R,get_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.real_text))
    set_text(SCREENID.Impedance_Distribution_Matching_SCREEN,IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_X,get_text(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.image_text))
    Current_info.Impedance_R=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_R)
    screen_write_to_MCU(VAR_ADDR.Impedance_R,Current_info.Impedance_R,2)
    Current_info.Impedance_X=get_value(SCREENID.Impedance_Distribution_Matching_SCREEN, IMPEDANCE_MATCHING_SCREEN_CONTROL.Impedance_X)
    screen_write_to_MCU(VAR_ADDR.Impedance_X,Current_info.Impedance_X,2)

    print ("target_real=", target_real)
    print ("target_image=", target_image)
    local id = find_table_by_load(Data_File_name,target_real,target_image)
    print ("id=", id)
    read_table_by_id(Data_File_name,id)
    print("Current_info.Show_table",Current_info.Show_table.group_count)
    show_table(Current_info.Show_table)
    print("ImpedanceX_Save_Times[target_real][target_image]="..ImpedanceX_Save_Times[target_real][target_image])
    set_value(SCREENID.Power_Debugging_Interface_SCREEN,Power_Debugging_Interface_CONTROL.save_times,ImpedanceX_Save_Times[target_real][target_image])
end


function load_verify_group_to_screen()
    local real_x = get_value(SCREENID.Power_Verify_SCREEN, Power_Verify_Interface_CONTROL.real_text)
    local image_x = get_value(SCREENID.Power_Verify_SCREEN, Power_Verify_Interface_CONTROL.image_text)

    local group_data, err = impedance_db_read_group(real_x, image_x)
    if group_data == nil then
        print("load_verify_group_to_screen fail:" .. tostring(err))
        record_clear(SCREENID.Power_Verify_SCREEN, Power_Verify_Interface_CONTROL.info_record)
        return
    end

    local ok, fill_err = fill_group_to_table(
        SCREENID.Power_Verify_SCREEN,
        Power_Verify_Interface_CONTROL.info_record,
        group_data
    )
    if ok ~= true then
        print("fill_group_to_table fail:" .. tostring(fill_err))
    end
end


function Verify_send_file_data(path)

    if file_open(path,0x03) ~= true then
        print("file open fail")
        return
    end

    local size = 32000
    if Current_offset < size then
        file_seek(Current_offset)
        local send_len = 200

        if Current_offset + send_len > size then
            send_len = 200
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

            screen_write_to_MCU(VAR_ADDR.Verify_File_Send_Data_MCU,frame,1)
            
            set_text(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.file_progress,string.format("%.1f",(Current_offset*100/32000)).."%")
            Current_offset = Current_offset + send_len
            print("Current_offset:",Current_offset)

        end
    else
        set_text(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.file_progress,"success")
        Uart_send_Verify_file_flag = 0 
        Current_offset =0
    end

    file_close()

    print("file send finish")

end


function start_verify_retest(record_index)
    local record_str = record_read(
        SCREENID.Power_Verify_SCREEN,
        Power_Verify_Interface_CONTROL.info_record,
        record_index
    )

    if record_str == nil or trim(record_str) == "" then
        print("start_verify_retest empty row:" .. tostring(record_index))
        return false
    end

    local info, err = parse_table_record(record_str, record_index + 1)
    if info == nil then
        print("start_verify_retest parse fail:" .. tostring(err))
        return false
    end

    Verify_RF_Test_Init()
    Current_info.Verify_Retest_Flag = 1
    Current_info.Verify_Retest_Gear = info.gear
    Current_info.Verify_Rf_Test_Flag = 1
    Current_info.Verify_Gear_Select[1] = info.gear
    Current_Power_Verifyinfo.total_Geer = 1
    Current_Power_Verifyinfo.Geer_count = 0

    screen_write_to_MCU(VAR_ADDR.VoltAdjustMode,0x01,1)
    screen_write_to_MCU(VAR_ADDR.PowerLevel,info.gear * 10,1)
    start_timer(
        Timer_ID.Verify_Gear_RF_Timer,
        Timer_Info[Timer_ID.Verify_Gear_RF_Timer].timeout,
        Timer_Info[Timer_ID.Verify_Gear_RF_Timer].countdown,
        Timer_Info[Timer_ID.Verify_Gear_RF_Timer].timesrepeat
    )
    Power_verify_screen_control_enable(0)
    return true
end

function Compare_geer_power(geer,power)

    local power_range_max = 0 

    local power_range_min = 0 
    local calibrate_num  = 10
    if get_value(SCREENID.Power_Verify_SCREEN,Power_Verify_Interface_CONTROL.yimei_flag_button)  == 1 then
        calibrate_num =20
    else
        calibrate_num = 10
    end
    
    power_range_max = (geer *calibrate_num +15)*(1+Power_Geer_Range_High)
    power_range_min = (geer *calibrate_num +15)*(1-Power_Geer_Range_Low)

    if power > power_range_min and power < power_range_max then
        return true
    else
        return false
    end
end 