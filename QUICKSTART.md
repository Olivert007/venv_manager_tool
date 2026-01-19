# 快速开始指南

## 一键安装

```bash
cd /mnt/data/wangj/workspace/tritonupstream/venv_manager_tool
./install_venv_manager.sh
source ~/.bashrc  # 或 source ~/.zshrc
```

## 基本使用

### 1️⃣ 创建虚拟环境

```bash
venv-create myproject
```

### 2️⃣ 进入虚拟环境（自动安装PyTorch）

```bash
venv-enter myproject
```

### 3️⃣ 查看环境状态

```bash
venv-status
```

### 4️⃣ 退出虚拟环境

```bash
venv-exit
```

### 5️⃣ 查看所有环境

```bash
venv-list
```

## 所有命令

| 命令 | 说明 |
|------|------|
| `venv-create <名称>` | 创建虚拟环境 |
| `venv-enter <名称>` | 进入虚拟环境 |
| `venv-exit` | 退出虚拟环境 |
| `venv-list` | 列出所有环境 |
| `venv-status` | 查看当前状态 |
| `venv-delete <名称>` | 删除虚拟环境 |
| `venv-help` | 显示帮助 |

## 特性

✨ **自动化**
- 进入环境时自动检测PyTorch
- 未安装时自动安装（ROCm 7.1 nightly版本）

✨ **友好界面**
- 彩色终端输出
- 清晰的状态提示
- 命令自动补全

## 完整文档

详细使用说明请查看：[VENV_MANAGER_README.md](VENV_MANAGER_README.md)

