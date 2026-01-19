# Python 虚拟环境管理工具

这是一个功能完善的Python虚拟环境管理工具，专为简化虚拟环境的创建、管理和PyTorch安装而设计。

## 特性

✨ **核心功能**
- 🚀 在统一路径 `~/venvs` 下创建和管理虚拟环境
- 🔄 简单的命令进入/退出虚拟环境
- 🤖 进入环境时自动检测并安装PyTorch（使用ROCm 7.1）
- 📋 查看所有虚拟环境列表及其状态
- 🎨 彩色终端输出，用户友好的界面

✨ **便捷特性**
- 自定义环境名称
- 显示Python和PyTorch版本信息
- 命令自动补全
- 错误处理和状态提示
- 环境状态查看

## 安装步骤

### 1. 下载工具文件

确保以下文件在同一目录下：
- `venv_manager.py` - Python管理脚本
- `venv_helper.sh` - Shell辅助脚本

### 2. 赋予执行权限

```bash
chmod +x venv_manager.py
chmod +x venv_helper.sh
```

### 3. 配置Shell环境

在您的 `~/.bashrc` 或 `~/.zshrc` 文件末尾添加以下内容：

```bash
# Python虚拟环境管理工具
source /path/to/venv_manager_tool/venv_helper.sh
```

**注意**：请根据实际路径调整上述路径。

### 4. 重新加载Shell配置

```bash
source ~/.bashrc  # 如果使用bash
# 或
source ~/.zshrc   # 如果使用zsh
```

## 使用指南

### 创建虚拟环境

```bash
# 创建名为 'myproject' 的虚拟环境
venv-create myproject

# 使用特定Python版本创建环境
venv-create myproject --python python3.11
```

### 查看所有虚拟环境

```bash
venv-list
```

输出示例：
```
虚拟环境列表:

环境名称               Python版本       PyTorch版本           路径
------------------------------------------------------------------------------------------
myproject            Python 3.10.12  2.7.0+git123456      ~/venvs/myproject
test_env             Python 3.11.5   未安装                ~/venvs/test_env

总计: 2 个虚拟环境
```

### 进入虚拟环境

```bash
venv-enter myproject
```

进入环境后，工具会：
1. ✅ 激活虚拟环境
2. 🔍 自动检测PyTorch安装状态
3. 📦 如果未安装PyTorch，自动执行安装（使用ROCm 7.1 nightly版本）

输出示例：
```
✓ 已进入虚拟环境: myproject
ℹ Python 3.10.12
ℹ 路径: ~/venvs/myproject

正在检查 PyTorch 安装状态...
⚠ PyTorch 未安装，开始自动安装...
ℹ 安装命令: pip3 install torch --index-url https://download.pytorch.org/whl/nightly/rocm7.1 --no-build-isolation
✓ PyTorch 安装成功！(版本: 2.7.0+git123456)

ℹ 使用 'venv-exit' 退出虚拟环境
```

### 查看当前环境状态

```bash
venv-status
```

输出示例：
```
当前虚拟环境:
  名称: myproject
  Python: Python 3.10.12
  路径: ~/venvs/myproject
  PyTorch: 2.7.0+git123456
```

### 退出虚拟环境

```bash
venv-exit
```

输出示例：
```
✓ 已退出虚拟环境: myproject
ℹ 已返回系统默认Python环境
```

### 删除虚拟环境

```bash
venv-delete myproject
```

系统会要求确认后再删除。

### 查看帮助

```bash
venv-help
```

## 完整命令列表

| 命令 | 描述 | 示例 |
|------|------|------|
| `venv-create <名称>` | 创建新的虚拟环境 | `venv-create myenv` |
| `venv-list` | 列出所有虚拟环境 | `venv-list` |
| `venv-enter <名称>` | 进入指定的虚拟环境 | `venv-enter myenv` |
| `venv-exit` | 退出当前虚拟环境 | `venv-exit` |
| `venv-delete <名称>` | 删除指定的虚拟环境 | `venv-delete myenv` |
| `venv-status` | 显示当前环境状态 | `venv-status` |
| `venv-help` | 显示帮助信息 | `venv-help` |

## PyTorch安装说明

工具在进入虚拟环境时会自动检测PyTorch安装状态。如果未安装，会执行以下命令：

```bash
pip3 install torch --index-url https://download.pytorch.org/whl/nightly/rocm7.1 --no-build-isolation
```

此命令：
- 使用 PyTorch nightly 版本
- 针对 ROCm 7.1 优化
- 跳过构建隔离以加快安装速度

您也可以手动触发PyTorch检查和安装：

```bash
# 使用Python脚本直接检查
python3 venv_manager.py check-pytorch myproject
```

## 常见问题

### Q: 如何更改虚拟环境的默认路径？

A: 编辑 `venv_manager.py` 和 `venv_helper.sh` 中的 `VENV_BASE_PATH` 变量。

### Q: 可以安装不同版本的PyTorch吗？

A: 可以。进入环境后，手动运行 `pip install` 命令来安装您需要的版本。

### Q: 命令补全不工作？

A: 确保已正确 source `venv_helper.sh` 并且使用的是 bash shell。

### Q: 如何在虚拟环境中安装其他包？

A: 进入虚拟环境后，使用标准的 pip 命令：
```bash
venv-enter myproject
pip install numpy pandas matplotlib
```

## 工作流程示例

### 场景1：创建新项目环境

```bash
# 1. 创建环境
venv-create ml_project

# 2. 进入环境（自动安装PyTorch）
venv-enter ml_project

# 3. 安装其他依赖
pip install numpy pandas scikit-learn

# 4. 开始工作
python train.py

# 5. 完成后退出
venv-exit
```

### 场景2：切换项目环境

```bash
# 查看所有环境
venv-list

# 进入项目A环境
venv-enter project_a
# ... 工作中 ...
venv-exit

# 进入项目B环境
venv-enter project_b
# ... 工作中 ...
venv-exit
```

### 场景3：清理旧环境

```bash
# 查看所有环境
venv-list

# 删除不再使用的环境
venv-delete old_project
```

## 技术细节

### 文件结构

```
/path/to/venv_manager_tool/
├── venv_manager.py       # Python管理脚本（核心逻辑）
├── venv_helper.sh        # Shell辅助脚本（命令封装）
└── VENV_MANAGER_README.md   # 本文档

~/venvs/                  # 所有虚拟环境存储位置
├── project1/
├── project2/
└── ...
```

### 工作原理

1. **创建环境**：使用Python的 `venv` 模块创建标准虚拟环境
2. **激活环境**：通过 `source activate` 脚本激活环境
3. **检测PyTorch**：在虚拟环境的Python中尝试 `import torch`
4. **自动安装**：如果导入失败，使用指定的pip命令安装PyTorch
5. **退出环境**：调用 `deactivate` 函数返回系统环境

## 许可证

此工具为内部使用工具，根据项目需求自由修改和分发。

## 支持

如有问题或建议，请联系工具维护者。

---

**Enjoy coding with clean virtual environments! 🚀**

