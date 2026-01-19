#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Python虚拟环境管理工具
功能：创建、列表、删除虚拟环境，自动检测并安装PyTorch
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
import json

# 虚拟环境基础路径
VENV_BASE_PATH = Path("/mnt/data/wangj/venvs")

# PyTorch安装命令
PYTORCH_INSTALL_CMD = [
    "pip3", "install", "torch",
    "--index-url", "https://download.pytorch.org/whl/nightly/rocm7.1",
    "--no-build-isolation"
]

class Colors:
    """终端颜色代码"""
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def print_success(msg):
    """打印成功消息"""
    print(f"{Colors.OKGREEN}✓ {msg}{Colors.ENDC}")


def print_error(msg):
    """打印错误消息"""
    print(f"{Colors.FAIL}✗ {msg}{Colors.ENDC}", file=sys.stderr)


def print_info(msg):
    """打印信息消息"""
    print(f"{Colors.OKCYAN}ℹ {msg}{Colors.ENDC}")


def print_warning(msg):
    """打印警告消息"""
    print(f"{Colors.WARNING}⚠ {msg}{Colors.ENDC}")


def ensure_base_path():
    """确保基础路径存在"""
    VENV_BASE_PATH.mkdir(parents=True, exist_ok=True)
    print_info(f"虚拟环境基础路径: {VENV_BASE_PATH}")


def create_venv(name, python_version=None):
    """创建虚拟环境"""
    ensure_base_path()
    venv_path = VENV_BASE_PATH / name
    
    if venv_path.exists():
        print_error(f"虚拟环境 '{name}' 已存在！")
        return False
    
    print_info(f"正在创建虚拟环境 '{name}'...")
    
    try:
        # 使用指定的Python版本或默认版本
        python_cmd = python_version if python_version else "python3"
        subprocess.run(
            [python_cmd, "-m", "venv", str(venv_path)],
            check=True
        )
        
        # 获取Python版本信息
        python_exe = venv_path / "bin" / "python"
        result = subprocess.run(
            [str(python_exe), "--version"],
            capture_output=True,
            text=True
        )
        python_ver = result.stdout.strip()
        
        print_success(f"虚拟环境 '{name}' 创建成功！")
        print_info(f"Python版本: {python_ver}")
        print_info(f"路径: {venv_path}")
        print_info(f"\n使用以下命令激活环境:")
        print(f"  {Colors.BOLD}venv-enter {name}{Colors.ENDC}")
        
        return True
    except subprocess.CalledProcessError as e:
        print_error(f"创建虚拟环境失败: {e}")
        return False
    except Exception as e:
        print_error(f"发生错误: {e}")
        return False


def list_venvs():
    """列出所有虚拟环境"""
    ensure_base_path()
    
    if not VENV_BASE_PATH.exists():
        print_warning("虚拟环境目录不存在")
        return
    
    venvs = []
    for item in VENV_BASE_PATH.iterdir():
        if item.is_dir() and (item / "bin" / "python").exists():
            python_exe = item / "bin" / "python"
            try:
                # 获取Python版本
                result = subprocess.run(
                    [str(python_exe), "--version"],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                python_ver = result.stdout.strip().replace("Python ", "")
                
                # 检查PyTorch安装状态
                result = subprocess.run(
                    [str(python_exe), "-c", "import torch; print(torch.__version__)"],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                pytorch_installed = result.returncode == 0
                pytorch_ver = result.stdout.strip() if pytorch_installed else "未安装"
                
                venvs.append({
                    "name": item.name,
                    "path": str(item),
                    "python_version": python_ver,
                    "pytorch_version": pytorch_ver,
                    "pytorch_installed": pytorch_installed
                })
            except Exception as e:
                print_warning(f"获取 {item.name} 信息时出错: {e}")
    
    if not venvs:
        print_warning("没有找到虚拟环境")
        print_info("使用以下命令创建新环境:")
        print(f"  {Colors.BOLD}python venv_manager.py create <环境名称>{Colors.ENDC}")
        return
    
    print(f"\n{Colors.BOLD}{Colors.HEADER}虚拟环境列表:{Colors.ENDC}\n")
    print(f"{'环境名称':<20} {'Python版本':<15} {'PyTorch版本':<20} {'路径'}")
    print("-" * 90)
    
    for venv in sorted(venvs, key=lambda x: x['name']):
        pytorch_status = f"{Colors.OKGREEN}{venv['pytorch_version']}{Colors.ENDC}" if venv['pytorch_installed'] else f"{Colors.WARNING}{venv['pytorch_version']}{Colors.ENDC}"
        print(f"{venv['name']:<20} {venv['python_version']:<15} {pytorch_status:<30} {venv['path']}")
    
    print(f"\n总计: {len(venvs)} 个虚拟环境\n")


def delete_venv(name):
    """删除虚拟环境"""
    venv_path = VENV_BASE_PATH / name
    
    if not venv_path.exists():
        print_error(f"虚拟环境 '{name}' 不存在！")
        return False
    
    print_warning(f"确定要删除虚拟环境 '{name}' 吗？")
    print_info(f"路径: {venv_path}")
    response = input("输入 'yes' 确认删除: ")
    
    if response.lower() != 'yes':
        print_info("取消删除操作")
        return False
    
    try:
        import shutil
        shutil.rmtree(venv_path)
        print_success(f"虚拟环境 '{name}' 已删除")
        return True
    except Exception as e:
        print_error(f"删除失败: {e}")
        return False


def check_and_install_pytorch(name):
    """检查并安装PyTorch"""
    venv_path = VENV_BASE_PATH / name
    
    if not venv_path.exists():
        print_error(f"虚拟环境 '{name}' 不存在！")
        return False
    
    python_exe = venv_path / "bin" / "python"
    pip_exe = venv_path / "bin" / "pip3"
    
    print_info(f"检查虚拟环境 '{name}' 中的PyTorch安装状态...")
    
    # 检查PyTorch是否已安装
    try:
        result = subprocess.run(
            [str(python_exe), "-c", "import torch; print(torch.__version__)"],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode == 0:
            pytorch_ver = result.stdout.strip()
            print_success(f"PyTorch 已安装 (版本: {pytorch_ver})")
            return True
    except Exception as e:
        print_warning(f"检查PyTorch时出错: {e}")
    
    # 如果未安装，进行安装
    print_warning("PyTorch 未安装，开始自动安装...")
    print_info(f"安装命令: {' '.join(PYTORCH_INSTALL_CMD)}")
    
    try:
        # 先升级pip
        print_info("升级 pip...")
        subprocess.run(
            [str(pip_exe), "install", "--upgrade", "pip"],
            check=True
        )
        
        # 安装PyTorch
        print_info("正在安装 PyTorch（这可能需要几分钟）...")
        cmd = [str(pip_exe)] + PYTORCH_INSTALL_CMD[1:]  # 使用虚拟环境中的pip
        subprocess.run(cmd, check=True)
        
        # 验证安装
        result = subprocess.run(
            [str(python_exe), "-c", "import torch; print(torch.__version__)"],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode == 0:
            pytorch_ver = result.stdout.strip()
            print_success(f"PyTorch 安装成功！(版本: {pytorch_ver})")
            return True
        else:
            print_error("PyTorch 安装后验证失败")
            return False
            
    except subprocess.CalledProcessError as e:
        print_error(f"安装 PyTorch 失败: {e}")
        return False
    except Exception as e:
        print_error(f"发生错误: {e}")
        return False


def get_venv_info(name):
    """获取虚拟环境信息（用于shell脚本）"""
    venv_path = VENV_BASE_PATH / name
    
    if not venv_path.exists():
        return None
    
    python_exe = venv_path / "bin" / "python"
    
    try:
        result = subprocess.run(
            [str(python_exe), "--version"],
            capture_output=True,
            text=True,
            timeout=5
        )
        python_ver = result.stdout.strip()
        
        return {
            "name": name,
            "path": str(venv_path),
            "python_version": python_ver,
            "activate_script": str(venv_path / "bin" / "activate")
        }
    except Exception:
        return None


def main():
    parser = argparse.ArgumentParser(
        description="Python虚拟环境管理工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  创建虚拟环境:    python venv_manager.py create myenv
  列出所有环境:    python venv_manager.py list
  删除虚拟环境:    python venv_manager.py delete myenv
  检查PyTorch:     python venv_manager.py check-pytorch myenv
        """
    )
    
    subparsers = parser.add_subparsers(dest='command', help='可用命令')
    
    # 创建命令
    create_parser = subparsers.add_parser('create', help='创建新的虚拟环境')
    create_parser.add_argument('name', help='虚拟环境名称')
    create_parser.add_argument('--python', help='指定Python版本 (例如: python3.11)', default=None)
    
    # 列表命令
    subparsers.add_parser('list', help='列出所有虚拟环境')
    
    # 删除命令
    delete_parser = subparsers.add_parser('delete', help='删除虚拟环境')
    delete_parser.add_argument('name', help='虚拟环境名称')
    
    # 检查PyTorch命令
    check_parser = subparsers.add_parser('check-pytorch', help='检查并安装PyTorch')
    check_parser.add_argument('name', help='虚拟环境名称')
    
    # 获取信息命令（内部使用）
    info_parser = subparsers.add_parser('info', help='获取虚拟环境信息')
    info_parser.add_argument('name', help='虚拟环境名称')
    
    args = parser.parse_args()
    
    if args.command == 'create':
        create_venv(args.name, args.python)
    elif args.command == 'list':
        list_venvs()
    elif args.command == 'delete':
        delete_venv(args.name)
    elif args.command == 'check-pytorch':
        check_and_install_pytorch(args.name)
    elif args.command == 'info':
        info = get_venv_info(args.name)
        if info:
            print(json.dumps(info))
        else:
            sys.exit(1)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()

