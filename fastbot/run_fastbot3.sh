#!/bin/bash

# 设置文件路径
FASTBOT_DIR="./fastbotfile"
APP_PACKAGE="com.weo.projectz"
#RUNNING_MINUTES=35
LOG_DIR="./logs"  # 本地保存日志的目录
mkdir -p $LOG_DIR  # 创建日志目录


# 检查 fastbot 进程
check_fastbot_process() {
    local device=$1
    adb -s $device shell "ps -A | grep 'monkey'" | grep -v grep
    return $?
}

# 清理设备上的日志和结果文件
clean_device_logs() {
    local device=$1
    echo "清理设备 $device 上的旧日志和结果文件..."

    # 清空或删除旧的日志文件
    adb -s $device shell "rm -rf /sdcard/fastbot_logs/*"

    # 清空或删除旧的结果文件
    adb -s $device shell "rm -rf /sdcard/fastbot-$APP_PACKAGE--running-minutes-$RUNNING_MINUTES/*"

    # 确保目录存在
    adb -s $device shell "mkdir -p /sdcard/fastbot_logs"
}

# 启动 fastbot
start_fastbot() {
    local device=$1
    local RUNNING_MINUTES=$2
    echo "正在设备 $device 上启动 fastbot..."

    # 首先清理旧的日志和结果文件
    clean_device_logs $device

    # 推送文件
    adb -s $device push $FASTBOT_DIR/monkeyq.jar /sdcard/
    adb -s $device push $FASTBOT_DIR/framework.jar /sdcard/
    adb -s $device push $FASTBOT_DIR/fastbot-thirdpart.jar /sdcard/
    adb -s $device push $FASTBOT_DIR/max.valid.strings /sdcard/
    adb -s $device shell "mkdir -p /data/local/tmp/arm64-v8a"
    adb -s $device push $FASTBOT_DIR/libfastbot_native.so /data/local/tmp/arm64-v8a/

    # 启动 fastbot，将日志保存在设备上，同时在本地创建一个新的日志文件
    nohup adb -s $device shell "CLASSPATH=/sdcard/monkeyq.jar:/sdcard/framework.jar:/sdcard/fastbot-thirdpart.jar exec app_process /system/bin com.android.commands.monkey.Monkey -p $APP_PACKAGE --agent reuseq --running-minutes $RUNNING_MINUTES --throttle 700 --bugreport > /sdcard/fastbot_logs/fastbot_log.txt 2>&1" > /dev/null 2>&1 &

    echo "$device 已启动"
}
# 检查设备是否已经链接
is_device_connected() {
    local device=$1
    adb devices | grep -w "$device" | grep -w "device" > /dev/null
    return $?
}

# 主函数
main() {
    if [ $# -lt 2 ]; then
        echo "请提供至少一个设备序列号 和运行时间（分钟)"
        exit 1
    fi

    IFS=',' read -ra DEVICES <<< "$1"
    local running_minutes=$2

    for DEVICE in "${DEVICES[@]}"; do
        echo "adb 检查设备 $DEVICE 是否连接..."
        if is_device_connected $DEVICE; then
            echo "设备 $DEVICE 已连接，准备启动 Fastbot..."
            start_fastbot $DEVICE $running_minutes
        else
            echo "设备 $DEVICE 未连接，跳过此设备。" 
        fi
    done
}

# 执行主函数
main "$@"

