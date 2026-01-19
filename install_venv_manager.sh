#!/bin/bash
# 虚拟环境管理工具 - 自动安装脚本

set -e

# 颜色代码
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_CYAN='\033[0;36m'
COLOR_RESET='\033[0m'

echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_CYAN}║     Python 虚拟环境管理工具 - 安装程序                      ║${COLOR_RESET}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${COLOR_BLUE}安装目录: $SCRIPT_DIR${COLOR_RESET}"
echo ""

# 检查必要文件是否存在
echo -e "${COLOR_YELLOW}[1/4] 检查必要文件...${COLOR_RESET}"
if [ ! -f "$SCRIPT_DIR/venv_manager.py" ]; then
    echo -e "${COLOR_RED}✗ 错误: venv_manager.py 不存在${COLOR_RESET}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/venv_helper.sh" ]; then
    echo -e "${COLOR_RED}✗ 错误: venv_helper.sh 不存在${COLOR_RESET}"
    exit 1
fi
echo -e "${COLOR_GREEN}✓ 所有必要文件已找到${COLOR_RESET}"
echo ""

# 赋予执行权限
echo -e "${COLOR_YELLOW}[2/4] 设置执行权限...${COLOR_RESET}"
chmod +x "$SCRIPT_DIR/venv_manager.py"
chmod +x "$SCRIPT_DIR/venv_helper.sh"
echo -e "${COLOR_GREEN}✓ 执行权限已设置${COLOR_RESET}"
echo ""

# 检测使用的Shell
echo -e "${COLOR_YELLOW}[3/4] 检测Shell配置...${COLOR_RESET}"
if [ -n "$BASH_VERSION" ]; then
    SHELL_NAME="bash"
    RC_FILE="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_NAME="zsh"
    RC_FILE="$HOME/.zshrc"
else
    echo -e "${COLOR_YELLOW}⚠ 未能自动检测Shell类型${COLOR_RESET}"
    echo -e "${COLOR_CYAN}请手动选择：${COLOR_RESET}"
    echo "1) bash (~/.bashrc)"
    echo "2) zsh (~/.zshrc)"
    read -p "请输入选项 [1-2]: " choice
    
    case $choice in
        1)
            SHELL_NAME="bash"
            RC_FILE="$HOME/.bashrc"
            ;;
        2)
            SHELL_NAME="zsh"
            RC_FILE="$HOME/.zshrc"
            ;;
        *)
            echo -e "${COLOR_RED}✗ 无效选项${COLOR_RESET}"
            exit 1
            ;;
    esac
fi

echo -e "${COLOR_GREEN}✓ 检测到 $SHELL_NAME shell${COLOR_RESET}"
echo -e "${COLOR_CYAN}ℹ 配置文件: $RC_FILE${COLOR_RESET}"
echo ""

# 配置Shell
echo -e "${COLOR_YELLOW}[4/4] 配置Shell环境...${COLOR_RESET}"

# 检查是否已经配置
MARKER="# Python虚拟环境管理工具"
if grep -q "$MARKER" "$RC_FILE" 2>/dev/null; then
    echo -e "${COLOR_YELLOW}⚠ 检测到已存在的配置${COLOR_RESET}"
    read -p "是否覆盖现有配置? [y/N]: " overwrite
    
    if [[ "$overwrite" =~ ^[Yy]$ ]]; then
        # 移除旧配置
        sed -i '/# Python虚拟环境管理工具/,/source.*venv_helper\.sh/d' "$RC_FILE"
        echo -e "${COLOR_CYAN}ℹ 已移除旧配置${COLOR_RESET}"
    else
        echo -e "${COLOR_CYAN}ℹ 保留现有配置，跳过此步骤${COLOR_RESET}"
        echo ""
        echo -e "${COLOR_GREEN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
        echo -e "${COLOR_GREEN}✓ 安装完成！${COLOR_RESET}"
        echo -e "${COLOR_GREEN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
        exit 0
    fi
fi

# 添加配置到RC文件
cat >> "$RC_FILE" << EOF

# Python虚拟环境管理工具
source $SCRIPT_DIR/venv_helper.sh
EOF

echo -e "${COLOR_GREEN}✓ 配置已添加到 $RC_FILE${COLOR_RESET}"
echo ""

# 创建虚拟环境基础目录
VENV_BASE_PATH="$HOME/venvs"
if [ ! -d "$VENV_BASE_PATH" ]; then
    mkdir -p "$VENV_BASE_PATH"
    echo -e "${COLOR_GREEN}✓ 创建虚拟环境目录: $VENV_BASE_PATH${COLOR_RESET}"
else
    echo -e "${COLOR_CYAN}ℹ 虚拟环境目录已存在: $VENV_BASE_PATH${COLOR_RESET}"
fi
echo ""

# 完成提示
echo -e "${COLOR_GREEN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
echo -e "${COLOR_GREEN}✓ 安装成功完成！${COLOR_RESET}"
echo -e "${COLOR_GREEN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
echo ""
echo -e "${COLOR_YELLOW}下一步操作：${COLOR_RESET}"
echo ""
echo -e "1. 重新加载Shell配置："
echo -e "   ${COLOR_CYAN}source $RC_FILE${COLOR_RESET}"
echo ""
echo -e "2. 查看可用命令："
echo -e "   ${COLOR_CYAN}venv-help${COLOR_RESET}"
echo ""
echo -e "3. 创建第一个虚拟环境："
echo -e "   ${COLOR_CYAN}venv-create myproject${COLOR_RESET}"
echo ""
echo -e "4. 进入虚拟环境："
echo -e "   ${COLOR_CYAN}venv-enter myproject${COLOR_RESET}"
echo ""
echo -e "${COLOR_BLUE}提示：进入虚拟环境时会自动检测并安装PyTorch (ROCm 7.1)${COLOR_RESET}"
echo ""

