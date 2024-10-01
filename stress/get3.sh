#!/bin/bash

# 参数检查
if [ $# -lt 3 ]; then
    echo "Usage: $0 <device_id> <duration_in_seconds> <interval_in_seconds>"
    exit 1
fi

# 读取命令行参数
DEVICE_ID=$1
DURATION=$2
INTERVAL=$3

PACKAGE_NAME="com.weo.projectz"
OUTPUT_FILE="performance_data_${PACKAGE_NAME}.csv"

# 检查文件是否存在，如果不存在则创建并添加标题行
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Date,Total Frames Rendered,Total Time Spent Rendering,Average FPS,Memory Usage,Total CPU Usage,User Space CPU Usage,Kernel Space CPU Usage" > "$OUTPUT_FILE"
fi

# 计算结束时间
END_TIME=$(( $(date +%s) + DURATION ))

# 开始收集数据
while [ $(date +%s) -lt $END_TIME ]; do
    # 获取图形性能信息
    GFXINFO=$(adb -s $DEVICE_ID shell dumpsys gfxinfo $PACKAGE_NAME)
    TOTAL_FRAMES=$(echo "$GFXINFO" | grep "Total frames rendered:" | awk '{print $4}')
    TOTAL_TIME=$(echo "$GFXINFO" | grep "Total time spent rendering:" | awk '{print $7}' | sed 's/ms//')  # 移除'ms'单位
    AVERAGE_FPS=$(echo "$GFXINFO" | grep "Average frames per second:" | awk '{print $6}')

    # 获取内存使用信息
    MEMINFO=$(adb -s $DEVICE_ID shell dumpsys meminfo $PACKAGE_NAME | grep -m 1 "TOTAL")
    MEMORY_USAGE=$(echo "$MEMINFO" | awk '{print $2}' | sed 's/K//') # 移除'K'单位

    # 获取CPU使用信息
    CPUINFO=$(adb -s $DEVICE_ID shell dumpsys cpuinfo | grep $PACKAGE_NAME | head -1)
    TOTAL_CPU_USAGE=$(echo "$CPUINFO" | awk '{print $1}' | sed 's/%//') # 移除'%'单位
    USER_CPU=$(echo "$CPUINFO" | awk '{print $3}' | sed 's/% user//') # 移除'% user'文本
    KERNEL_CPU=$(echo "$CPUINFO" | awk '{print $5}' | sed 's/% kernel//') # 移除'% kernel'文本

    # 获取当前日期和时间
    CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

    # 将数据追加到CSV文件
    echo "$CURRENT_DATE,$TOTAL_FRAMES,$TOTAL_TIME,$AVERAGE_FPS,$MEMORY_USAGE,$TOTAL_CPU_USAGE,$USER_CPU,$KERNEL_CPU" >> "$OUTPUT_FILE"

    # 等待指定的间隔时间
    sleep $INTERVAL
done

# 输出完成消息
echo "Data collection completed and recorded to $OUTPUT_FILE"
