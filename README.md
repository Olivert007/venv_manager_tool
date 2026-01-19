# Python 虚拟环境管理工具

一个功能完善的Python虚拟环境管理工具，专为简化虚拟环境的创建、管理和PyTorch自动安装而设计。

## ✨ 特性

- 🚀 统一管理所有虚拟环境在 `~/venvs`
- 🔄 简单命令进入/退出虚拟环境
- 🤖 自动检测并安装PyTorch（ROCm 7.1 nightly）
- 📋 查看所有环境列表及状态
- 🎨 彩色终端输出，用户友好界面
- ⚡ 命令自动补全

## 🚀 快速开始

### 一键安装

```bash
cd /path/to/venv_manager_tool
./install_venv_manager.sh
source ~/.bashrc  # 或 source ~/.zshrc
```

### 基本使用

```bash
# 创建虚拟环境
venv-create myproject

# 进入虚拟环境（自动检测并安装PyTorch）
venv-enter myproject

# 查看当前状态
venv-status

# 退出虚拟环境
venv-exit

# 查看所有环境
venv-list

# 查看帮助
venv-help
```

## 📚 文档

- **[QUICKSTART.md](QUICKSTART.md)** - 快速开始指南，包含最常用命令
- **[VENV_MANAGER_README.md](VENV_MANAGER_README.md)** - 完整文档，详细使用说明和故障排除

## 📂 文件说明

```
venv_manager_tool/
├── venv_manager.py           # 核心Python管理脚本
├── venv_helper.sh            # Shell辅助脚本（提供便捷命令）
├── install_venv_manager.sh   # 一键安装脚本
├── README.md                 # 本文件
├── QUICKSTART.md            # 快速开始指南
└── VENV_MANAGER_README.md   # 完整文档
```

## 🎯 主要命令

| 命令 | 说明 |
|------|------|
| `venv-create <名称>` | 创建新的虚拟环境 |
| `venv-enter <名称>` | 进入虚拟环境（自动安装PyTorch） |
| `venv-exit` | 退出当前虚拟环境 |
| `venv-list` | 列出所有虚拟环境 |
| `venv-status` | 查看当前环境状态 |
| `venv-delete <名称>` | 删除虚拟环境 |
| `venv-help` | 显示帮助信息 |

## 🔧 系统要求

- Python 3.7+
- Bash 或 Zsh shell
- Linux 系统（已在 Ubuntu/RHEL 系列上测试）

## 💡 使用场景

### 场景1：创建新项目环境

```bash
venv-create ml_project
venv-enter ml_project
pip install numpy pandas scikit-learn
# 开始工作...
venv-exit
```

### 场景2：在多个项目间切换

```bash
venv-list                    # 查看所有环境
venv-enter project_a         # 进入项目A
# 工作...
venv-exit                    # 退出项目A
venv-enter project_b         # 进入项目B
```

## 🤖 自动PyTorch安装

进入虚拟环境时，工具会：
1. 检测PyTorch是否已安装
2. 如果未安装，自动执行：
   ```bash
   pip3 install torch --index-url https://download.pytorch.org/whl/nightly/rocm7.1 --no-build-isolation
   ```
3. 验证安装并显示版本信息

## 📝 许可证

内部工具，可自由使用和修改。

## 🆘 支持

如有问题或建议，请查阅完整文档 [VENV_MANAGER_README.md](VENV_MANAGER_README.md)

---

**Enjoy coding with clean virtual environments! 🚀**

