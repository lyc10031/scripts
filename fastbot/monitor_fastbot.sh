#!/bin/bash

# 设置参数
APP_PACKAGE="com.weo.projectz"
CHECK_INTERVAL=120  # 检查间隔时间（秒）
LOG_DIR="./fastbot_monitor_logs"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 检查 fastbot 进程
check_fastbot_process() {
    local device=$1
    adb -s "$device" shell "ps -A | grep monkey" | grep -v grep
    return $?
}

# 分析 fastbot 结果
analyze_fastbot_result() {
    sleep 1
    local device=$1
    local local_result_dir="$LOG_DIR/${device}_results"
    mkdir -p "$local_result_dir"

    echo "开始分析设备 $device 的 fastbot 执行结果..." | tee -a "$LOG_DIR/monitor_log.txt"

    # fastbot 生成的结果文件名是最新一个文件夹
    local remote_result_dir=$(adb -s $device shell 'ls -t /sdcard | grep "fastbot-com.weo.projectz--running-minutes-" | head -1')
    # 拼接完整路径
    local full_remote_result_dir="/sdcard/$remote_result_dir"
    # 获取运行时长
    local spent_time=$(echo "$remote_result_dir" |awk -F "-" '{print $6}')

    echo "远程 地址${full_remote_result_dir}" | tee -a "$LOG_DIR/monitor_log.txt"
    echo "本地 地址${local_result_dir}"  |  tee -a "$LOG_DIR/monitor_log.txt" 

    # 拉取结果文件
    adb -s "$device" pull "$full_remote_result_dir" "$local_result_dir"

    if [ $? -ne 0 ]; then
        echo "无法从设备 $device 拉取结果文件。" | tee -a "$LOG_DIR/monitor_log.txt"
        return 1
    fi

    local need_check_dir=$(ls -t "$local_result_dir" | head -1)
    local max_activity_statics="${local_result_dir}/${need_check_dir}/max.activity.statistics.log"

    # 检查文件是否存在
    if [ -f "${max_activity_statics}" ]; then
        local anr_crash_found=false
        # 提取 Coverage 信息
        local coverage=$(grep "Coverage" "${max_activity_statics}" | sed "s/.*Coverage/Coverage/; s/.$//; s/\"//")
        echo "Coverage: $coverage"
    

    
       if find "$local_result_dir/$need_check_dir" -type d \( -name "*Anr*" -o -name "*Crash*" \) | grep -q .; then
        echo "警告：在目录 $need_check_dir 中发现包含 'Anr' 或 'Crash' 的文件夹。" | tee -a "$LOG_DIR/monitor_log.txt"
        anr_crash_found=true

       fi

        {
        echo "===== $(date '+%Y-%m-%d %H:%M:%S') 设备 $device 的执行结果摘要 ====="
        echo "运行时长(minutes):$spent_time"
        echo "覆盖率(%):        $coverage"
        if [ "$anr_crash_found" = true ]; then
            echo "发现 'Anr' 或 'Crash'"
        fi
        echo "====================================="
        } >> "$LOG_DIR/summary.log"
    else
        echo "File ${max_activity_statics} does not exist."   
    fi

   
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        echo "请提供至少一个设备序列号"
        exit 1
    fi

    IFS=',' read -ra DEVICES <<< "$1"

    while true; do
        all_finished=true

        for DEVICE in "${DEVICES[@]}"; do
            if check_fastbot_process "$DEVICE" > /dev/null; then
                all_finished=false
                echo "$(date '+%Y-%m-%d %H:%M:%S') - 设备 $DEVICE 上的 fastbot 仍在运行..." | tee -a "$LOG_DIR/monitor_log.txt"
            else               
                echo "$(date '+%Y-%m-%d %H:%M:%S') - 设备 $DEVICE 的 fastbot 已完成，开始下载结果文件进行分析" | tee -a "$LOG_DIR/monitor_log.txt"
                analyze_fastbot_result "$DEVICE"
                touch "$LOG_DIR/${DEVICE}_finished"
                # 如果设备之前在运行但现在不在运行，进行结果分析
                # if [ ! -f "$LOG_DIR/${DEVICE}_finished" ]; then

                # fi
            fi
        done

        if $all_finished; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - 所有设备的 fastbot 测试已完成。" | tee -a "$LOG_DIR/monitor_log.txt"
            break
        fi

        sleep "$CHECK_INTERVAL"
        echo "-------------等待 $CHECK_INTERVAL 秒后再次检查------\n\n" | tee -a "$LOG_DIR/monitor_log.txt"
    done
}

# 执行主函数，并在后台运行
main "$@"
echo "monitor_fastbot.sh 已在后台启动。日志保存在 $LOG_DIR/"
