#!/bin/bash
# -*- coding: utf-8 -*-
# Python虚拟环境管理工具 - Shell辅助脚本
# 提供便捷的命令来激活和退出虚拟环境

# 虚拟环境基础路径
VENV_BASE_PATH="$HOME/venvs"

# Python管理脚本路径（需要根据实际情况调整）
VENV_MANAGER_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/venv_manager.py"

# 颜色代码
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_CYAN='\033[0;36m'
COLOR_RESET='\033[0m'

# 创建虚拟环境
venv-create() {
    if [ -z "$1" ]; then
        echo -e "${COLOR_RED}✗ 请指定虚拟环境名称${COLOR_RESET}"
        echo "用法: venv-create <环境名称> [--python <python版本>]"
        return 1
    fi
    
    python3 "$VENV_MANAGER_SCRIPT" create "$@"
}

# 列出所有虚拟环境
venv-list() {
    python3 "$VENV_MANAGER_SCRIPT" list
}

# 删除虚拟环境
venv-delete() {
    if [ -z "$1" ]; then
        echo -e "${COLOR_RED}✗ 请指定虚拟环境名称${COLOR_RESET}"
        echo "用法: venv-delete <环境名称>"
        return 1
    fi
    
    python3 "$VENV_MANAGER_SCRIPT" delete "$1"
}

# 进入虚拟环境
venv-enter() {
    if [ -z "$1" ]; then
        echo -e "${COLOR_RED}✗ 请指定虚拟环境名称${COLOR_RESET}"
        echo "用法: venv-enter <环境名称>"
        return 1
    fi
    
    local venv_name="$1"
    local venv_path="$VENV_BASE_PATH/$venv_name"
    local activate_script="$venv_path/bin/activate"
    
    # 检查虚拟环境是否存在
    if [ ! -d "$venv_path" ]; then
        echo -e "${COLOR_RED}✗ 虚拟环境 '$venv_name' 不存在！${COLOR_RESET}"
        echo -e "${COLOR_CYAN}ℹ 可用的虚拟环境:${COLOR_RESET}"
        venv-list
        return 1
    fi
    
    # 检查是否已经在虚拟环境中
    if [ -n "$VIRTUAL_ENV" ]; then
        echo -e "${COLOR_YELLOW}⚠ 当前已在虚拟环境中: $(basename $VIRTUAL_ENV)${COLOR_RESET}"
        echo -e "${COLOR_CYAN}ℹ 请先使用 'venv-exit' 退出当前环境${COLOR_RESET}"
        return 1
    fi
    
    # 激活虚拟环境
    source "$activate_script"
    
    if [ $? -eq 0 ]; then
        # 获取Python版本
        local python_version=$(python --version 2>&1)
        
        echo -e "${COLOR_GREEN}✓ 已进入虚拟环境: $venv_name${COLOR_RESET}"
        echo -e "${COLOR_CYAN}ℹ $python_version${COLOR_RESET}"
        echo -e "${COLOR_CYAN}ℹ 路径: $venv_path${COLOR_RESET}"
        
        # 自动检测并安装PyTorch
        echo ""
        echo -e "${COLOR_BLUE}正在检查 PyTorch 安装状态...${COLOR_RESET}"
        python3 "$VENV_MANAGER_SCRIPT" check-pytorch "$venv_name"
        
        echo ""
        echo -e "${COLOR_CYAN}ℹ 使用 'venv-exit' 退出虚拟环境${COLOR_RESET}"
    else
        echo -e "${COLOR_RED}✗ 激活虚拟环境失败${COLOR_RESET}"
        return 1
    fi
}

# 退出虚拟环境
venv-exit() {
    if [ -z "$VIRTUAL_ENV" ]; then
        echo -e "${COLOR_YELLOW}⚠ 当前不在虚拟环境中${COLOR_RESET}"
        return 1
    fi
    
    local current_venv=$(basename "$VIRTUAL_ENV")
    deactivate 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${COLOR_GREEN}✓ 已退出虚拟环境: $current_venv${COLOR_RESET}"
        echo -e "${COLOR_CYAN}ℹ 已返回系统默认Python环境${COLOR_RESET}"
    else
        echo -e "${COLOR_RED}✗ 退出虚拟环境失败${COLOR_RESET}"
        return 1
    fi
}

# 显示当前虚拟环境状态
venv-status() {
    if [ -n "$VIRTUAL_ENV" ]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        local python_version=$(python --version 2>&1)
        
        echo -e "${COLOR_GREEN}当前虚拟环境:${COLOR_RESET}"
        echo -e "  名称: ${COLOR_CYAN}$venv_name${COLOR_RESET}"
        echo -e "  Python: ${COLOR_CYAN}$python_version${COLOR_RESET}"
        echo -e "  路径: ${COLOR_CYAN}$VIRTUAL_ENV${COLOR_RESET}"
        
        # 检查PyTorch状态
        if python -c "import torch" 2>/dev/null; then
            local pytorch_version=$(python -c "import torch; print(torch.__version__)" 2>/dev/null)
            echo -e "  PyTorch: ${COLOR_GREEN}$pytorch_version${COLOR_RESET}"
        else
            echo -e "  PyTorch: ${COLOR_YELLOW}未安装${COLOR_RESET}"
        fi
    else
        echo -e "${COLOR_YELLOW}当前不在虚拟环境中${COLOR_RESET}"
        echo -e "${COLOR_CYAN}使用 'venv-list' 查看可用的虚拟环境${COLOR_RESET}"
        echo -e "${COLOR_CYAN}使用 'venv-enter <环境名称>' 进入虚拟环境${COLOR_RESET}"
    fi
}

# 显示帮助信息
venv-help() {
    echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_CYAN}║       Python 虚拟环境管理工具 - 命令帮助                    ║${COLOR_RESET}"
    echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_GREEN}基本命令:${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}venv-create${COLOR_RESET} <环境名称>        创建新的虚拟环境"
    echo -e "  ${COLOR_YELLOW}venv-list${COLOR_RESET}                    列出所有虚拟环境"
    echo -e "  ${COLOR_YELLOW}venv-enter${COLOR_RESET} <环境名称>         进入指定的虚拟环境"
    echo -e "  ${COLOR_YELLOW}venv-exit${COLOR_RESET}                     退出当前虚拟环境"
    echo -e "  ${COLOR_YELLOW}venv-delete${COLOR_RESET} <环境名称>        删除指定的虚拟环境"
    echo -e "  ${COLOR_YELLOW}venv-status${COLOR_RESET}                   显示当前环境状态"
    echo -e "  ${COLOR_YELLOW}venv-help${COLOR_RESET}                     显示此帮助信息"
    echo ""
    echo -e "${COLOR_GREEN}使用示例:${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}# 创建名为 'myproject' 的虚拟环境${COLOR_RESET}"
    echo -e "  venv-create myproject"
    echo ""
    echo -e "  ${COLOR_CYAN}# 进入 'myproject' 虚拟环境（自动检测并安装PyTorch）${COLOR_RESET}"
    echo -e "  venv-enter myproject"
    echo ""
    echo -e "  ${COLOR_CYAN}# 查看当前环境状态${COLOR_RESET}"
    echo -e "  venv-status"
    echo ""
    echo -e "  ${COLOR_CYAN}# 退出虚拟环境${COLOR_RESET}"
    echo -e "  venv-exit"
    echo ""
    echo -e "${COLOR_GREEN}特性:${COLOR_RESET}"
    echo -e "  ${COLOR_BLUE}•${COLOR_RESET} 进入虚拟环境时自动检测PyTorch安装状态"
    echo -e "  ${COLOR_BLUE}•${COLOR_RESET} 如未安装PyTorch，自动使用ROCm 7.1版本安装"
    echo -e "  ${COLOR_BLUE}•${COLOR_RESET} 彩色输出，友好的命令行界面"
    echo -e "  ${COLOR_BLUE}•${COLOR_RESET} 统一管理所有虚拟环境在: $VENV_BASE_PATH"
    echo ""
}

# 命令补全（可选）
_venv_enter_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local venvs=$(ls -1 "$VENV_BASE_PATH" 2>/dev/null | xargs)
    COMPREPLY=($(compgen -W "$venvs" -- "$cur"))
}

_venv_delete_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local venvs=$(ls -1 "$VENV_BASE_PATH" 2>/dev/null | xargs)
    COMPREPLY=($(compgen -W "$venvs" -- "$cur"))
}

# 注册命令补全
complete -F _venv_enter_completion venv-enter
complete -F _venv_delete_completion venv-delete

# 初始化消息（仅在交互式shell中显示）
if [[ $- == *i* ]]; then
    echo -e "${COLOR_GREEN}✓ Python虚拟环境管理工具已加载${COLOR_RESET}"
    echo -e "${COLOR_CYAN}ℹ 使用 'venv-help' 查看可用命令${COLOR_RESET}"
fi

