#!/bin/sh

# 检查参数


ROOT_DIR=$PWD
OUTPUT_DIR_Perf=$PWD/perf
OUTPUT_DIR_Test=$PWD/test
#删除已有输出结果
#rm -rf perf
#rm -rf test
# 创建输出目录（如果不存在）
mkdir -p "$OUTPUT_DIR_Perf"
mkdir -p "$OUTPUT_DIR_Test"
COUNT=0
count_file=$(mktemp)  # 创建临时文件来存储计数器

TOTAL=$(find "$ROOT_DIR" -name '*_test.go' -exec grep -oP 'func \K(Test\w*)' {} + | wc -l)
echo "总测试项数量为: $TOTAL"

# 查找所有 _test.go 文件
find  -name '*_test.go' | while read -r test_file; do
    echo "Processing file: $test_file"
    # 提取包名
    pkg=$(dirname "$test_file")
    echo $pkg
    cd $pkg
    # 查找所有测试函数
    grep -oP 'func \K(Test\w*)' "./$(echo "$test_file" | sed 's:.*/::')" | while read -r test_func; do
        echo $test_func
        # 生成执行命令
        cmd="go test -v -run ^$test_func$ -timeout 60m"
        path=$(echo "$test_file" | sed -n 's|.*\./\(.*\)\..*|\1|p' | sed 's|/|#|g')
        file="$test_func-$path"
        if [ -f "$OUTPUT_DIR_Test/$file.txt" ]; then
            echo "the test has completed"
        else
            $cmd > $file.txt 2>&1
            echo $test_func >>$file.txt
            echo "($test_file)" >>$file.txt
            mv $file.txt $OUTPUT_DIR_Test
        fi
        # 调用 perf 脚本
        if [ -f "$OUTPUT_DIR_Perf/$file.txt" ]; then
            echo "the perf test has completed"
        else
            $ROOT_DIR/performance_counter_920.sh "$cmd" "$OUTPUT_DIR_Perf" "$test_file"
        fi
        # 更新计数器
        COUNT=$((COUNT + 1))
        echo $COUNT > "$count_file"
        echo "rate of progress: $COUNT/$TOTAL "
        echo ""
    done
    cd $ROOT_DIR
    COUNT=$(cat "$count_file")
done

COUNT=$(cat "$count_file")
rm "$count_file"  
echo "test costs $(($SECONDS / 3600)) hours $(( ($SECONDS % 3600) / 60)) minutes $(($SECONDS % 60)) seconds。"
echo "Total number of tests completed: $COUNT"
