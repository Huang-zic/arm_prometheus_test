#!/bin/bash

# 日志文件
LOGFILE="install_benchmark.log"

# 日志记录函数
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

# 错误处理函数
error_exit() {
    log "Error: $1"
    exit 1
}

# 检查命令是否成功执行
check_command() {
    if [ $? -ne 0 ]; then
        log "Error executing: $1"
    else
        log "Successfully executed: $1"
    fi
}
log"进入工作目录"
cd /home/cloud3

# 下载 Prometheus-Benchmark
log "开始下载 Prometheus-Benchmark..."
if [ ! -d "prometheus-benchmark" ]; then
    git clone https://github.com/VictoriaMetrics/prometheus-benchmark.git
    check_command "git clone https://github.com/VictoriaMetrics/prometheus-benchmark.git"
    chmod +x -R .
else
    log "Prometheus-Benchmark 已经下载，跳过此步骤."
fi

# 安装 Go 语言
GO_URL="https://github.com/Huang-zic/go_golang.git"
log "开始下载 Go 语言..."
if [ ! -d "go_golang" ]; then
    git clone ${GO_URL} 
    check_command "git clone ${GO_URL}"
    chmod +x -R .
else
    log "Go 安装包已经下载，跳过此步骤."
fi


export PATH=$PATH:/home/cloud3/go_golang/go/bin
log "Go 安装完成."

log "赋予go执行权限"
chmod +x /home/cloud3/go_golang/go/bin/go
# 设置 GOROOT 和 GOPATH
log "设置 Go 环境变量..."
go env -w GOROOT=/home/cloud3/go_golang/go
check_command "go env -w GOROOT=/home/cloud3/go_golang/go"
go env -w GOPATH=/home/cloud3/go_golang/golang 
check_command "go env -w GOPATH=/home/cloud3/go_golang/golang "
log "Go 环境变量设置完成."

# 安装 kind
log "开始下载kind..."
if [ ! -d "/usr/local/bin/kind" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.12.0/kind-linux-arm64
    check_command "curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.12.0/kind-linux-arm64"
    chmod +x -R .
    sudo mv ./kind /usr/local/bin/kind
else
    log "kind已经下载，跳过此步骤."
fi

log"下载自动化脚本"
if [ ! -d "arm_test" ]; then
    git clone https://github.com/Huang-zic/arm_test.git
    check_command "git clone https://github.com/Huang-zic/arm_test.git"
    chmod +x -R .
    log"自动化脚本下载成功"
else
    log "脚本已经下载，跳过此步骤."
fi

log"将配置文件移动到指定目录中"
mv /home/cloud3/arm_test/kind-config.yaml /home/cloud3

log"根据配置文件创建k8s集群"
kind create cluster --config kind-config.yaml

cd /home/cloud3/prometheus-benchmark
log"将chart安装到配置的命名空间，即启动pod中的容器"
make install
log"将vmsingle端口转发到8428，在本地访问http://localhost:8428即可查看内容"
make monitor

