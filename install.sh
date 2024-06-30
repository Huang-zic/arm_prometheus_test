#!/bin/bash

# 日志文件
LOGFILE="install.log"

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

# 下载 Prometheus
log "开始下载 Prometheus..."
if [ ! -d "prometheus" ]; then
    git clone https://github.com/prometheus/prometheus.git
    check_command "git clone https://github.com/prometheus/prometheus.git"
    chmod +x -R .
else
    log "Prometheus 已经下载，跳过此步骤."
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

# 安装 Node.js 和 npm
log "开始安装 Node.js 和 npm..."
if [ -z "$(command -v nvm)" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    check_command "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    log "NVM 已经安装，跳过此步骤."
fi

log "安装 Node.js 版本 20..."
nvm install 20
check_command "nvm install 20"
log "Node.js 安装完成."

# 检查 Node.js 和 npm 版本
NODE_VERSION=$(node -v)
NPM_VERSION=$(npm -v)
log "Node.js 版本: $NODE_VERSION"
log "NPM 版本: $NPM_VERSION"

# 处理可能的 nvm 命令未找到问题
log "处理 nvm 命令未找到问题..."
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
log "NVM 已成功加载."

# 添加 Go 代理
log "添加 Go 代理..."
go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/
check_command "go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/"

# 安装 goyacc 以解决 make test 报错问题
log "安装 goyacc..."
cd prometheus || error_exit "Failed to change directory to Prometheus."
go install golang.org/x/tools/cmd/goyacc
check_command "go install golang.org/x/tools/cmd/goyacc"
log "goyacc 安装完成."

log"下载自动化脚本"
if [ ! -d "arm_test" ]; then
    git clone https://github.com/Huang-zic/arm_test.git
    check_command "git clone https://github.com/Huang-zic/arm_test.git"
    chmod +x -R .
    log"自动化脚本下载成功"
else
    log "脚本已经下载，跳过此步骤."
fi
log"将脚本移动到指定目录中"
mv /home/cloud3/arm_test/run_tests.sh /home/cloud3/prometheus
mv /home/cloud3/arm_test/performance_counter_920.sh /home/cloud3/prometheus
chmod +x -R .
log"赋予执行权限"
cd /home/cloud3/prometheus
log"进入Prometheus目录"
make test  2>&1 | tee test_log.txt
log"make test结果保存至/home/cloud3/prometheus/test_log.txt"
log"进行perf测试"
./run_tests.sh
log "perf结果保存至/home/cloud3/prometheus/perf"
