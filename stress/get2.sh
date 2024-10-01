#!/bin/bash

# 检查参数
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <device_id> <package_name> <duration_in_seconds> <interval_in_seconds>"
    exit 1
fi

DEVICE_ID=$1
PACKAGE_NAME=$2
DURATION=$3
INTERVAL=$4
OUTPUT_FILE="${PACKAGE_NAME}_performance_data.csv"

# 检查设备是否连接
if ! adb -s "$DEVICE_ID" get-state > /dev/null 2>&1; then
    echo "Error: Device $DEVICE_ID not found or not connected."
    exit 1
fi

# 创建 CSV 文件并写入标题
echo "Timestamp,CPU Usage (%),Memory Usage (KB),FPS" > "$OUTPUT_FILE"

# 获取开始时间
START_TIME=$(date +%s)
END_TIME=$((START_TIME + DURATION))

# 使用循环获取数据并写入文件
while [ $(date +%s) -lt $END_TIME ]; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    # 使用 adb shell 并行执行命令，提高效率
    CPU_USAGE=$(adb -s "$DEVICE_ID" shell top -n 1 -b | grep "$PACKAGE_NAME" | awk '{print $9}')
    MEMORY_USAGE=$(adb -s "$DEVICE_ID" shell dumpsys meminfo "$PACKAGE_NAME" | grep TOTAL | awk '{print $2}')
    FPS=$(adb -s "$DEVICE_ID" shell dumpsys gfxinfo "$PACKAGE_NAME" | grep "Total frames rendered:" | awk '{print $4}')

    # 写入数据到 CSV 文件
    echo "$TIMESTAMP,$CPU_USAGE,$MEMORY_USAGE,$FPS" >> "$OUTPUT_FILE"

    echo "Data collected at $TIMESTAMP"
    sleep "$INTERVAL"
done

echo "Data collection completed. Results saved in $OUTPUT_FILE"
