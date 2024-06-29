#!/bin/sh

# 检查参数


ROOT_DIR=.
OUTPUT_DIR=/home/cloud3/prometheus/perf
#删除已有输出结果
rm -rf perf
# 创建输出目录（如果不存在）
mkdir -p "$OUTPUT_DIR"

# 查找所有 _test.go 文件
find "$ROOT_DIR" -name '*_test.go' | while read -r test_file; do
    echo "Processing file: $test_file"
    # 提取包名
    pkg=$(dirname "$test_file")
    echo $pkg
    # 查找所有测试函数
    grep -oP 'func \K(Test\w*)' "$test_file" | while read -r test_func; do
        echo $test_func
        # 生成执行命令
        cmd="go test -v -run ^$test_func$ $pkg"
        
        # 调用 perf 脚本
        ./performance_counter_920.sh "$cmd" "$OUTPUT_DIR"
    done
done
