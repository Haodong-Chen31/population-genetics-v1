#!/bin/bash

#usage: sh pop_in_database_or_not.sh [poplist文件] [ind文件]

# 分别读取两个文件中的数据，并将其保存到两个数组中
mapfile -t file1_data < "$1"
mapfile -t file2_data < "$2"

# 遍历file1_data数组中的每个元素
for element in "${file1_data[@]}"; do
  # 使用grep命令在file2_data数组中查找当前元素
  if ! grep -q " $element " <<< "${file2_data[*]}"; then
    # 如果当前元素未在file2_data数组中出现，则输出它
    echo "$element"
  fi
done

