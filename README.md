# FPGA 模板项目

这是一个可复用的 FPGA 项目模板，适用于电子系《数字逻辑处理器基础实验》课程、本地 `macOS + VSCode` 开发。流程如下：（其中2，3，4，5由脚本自动完成）

1. 在本地编写 Verilog 和 XDC。
2. 将工程同步到远端 Linux 服务器。
3. 在远端通过 Vivado batch 模式生成 bitstream。
4. 将 bitstream 下载回本地。
5. 在本地使用 `openFPGALoader` 给 FPGA 板烧录。

## 安装以来

## 目录结构

- `rtl/`：Verilog 源文件
- `constr/`：XDC 约束文件
- `scripts/`：构建与辅助脚本
- `build/`：本地产生的构建产物
- `.vscode/`：VSCode 的任务与运行配置
- `fpga.env`：项目级配置文件

## 快速开始

1. 编辑 `fpga.env`。
2. 用你自己的设计替换 `rtl/top.v` 和 `constr/top.xdc`。
3. 用 VSCode 打开该文件夹。
4. 在 VSCode 左侧 `Run and Debug` 中运行 `Build + Program`。

## 配置说明

主要配置项位于 `fpga.env`：

- `REMOTE_HOST`
- `VIVADO_SETTINGS`
- `REMOTE_PROJECT_DIR`
- `TOP_MODULE`
- `FPGA_PART`
- `BITSTREAM_NAME`
- `PROGRAMMER`

如果将 `REMOTE_PROJECT_DIR` 保持为注释状态，脚本会默认使用：

`/mnt/data/fpga/<当前文件夹名>`

## 复用模板

你可以把这个仓库克隆到其他地方，然后执行：

```bash
./scripts/init_project.sh /path/to/new_project
```

这会创建一个新的工程目录，并自动生成同样的 workflow 文件。
