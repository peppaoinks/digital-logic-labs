# 数字逻辑设计实验 1–4

基于 EGO1 开发板的 Verilog 课程实验整理：组合运算、D 触发器与寄存器文件、流水灯计数器、数码管控制器。器件为 `xc7a35tcsg324-1`，时序设计使用板载 100 MHz 时钟。

| 实验 | 顶层 | 功能 | 源码 |
|---|---|---|---|
| 1 | `mux` | 使能控制的 4 位加减法 | [lab1](lab1) |
| 2 | `dff` / `reg8file` | 带使能 D 触发器、8×8 位寄存器文件 | [lab2](lab2) |
| 3 | `flowing_water_lights` | 快慢、方向、单双灯切换 | [lab3](lab3) |
| 4 | `lab4` | 八位扫描、按键消抖、边沿检测与十进制计数 | [lab4](lab4) |

- [实验原理与操作说明](docs/labs.md)
- [整理改动与验证范围](docs/verification.md)

## 仿真

安装 Python 3 和 Icarus Verilog，将 `iverilog`、`vvp` 加入 PATH。在仓库根目录执行：

```sh
python3 scripts/verify.py         # 11 组课程激励及功能自检
python3 scripts/verify.py --full  # 13 组，含上板默认计时参数
```

每组测试独立编译并显式选择顶层，实验2的两个同名 `testbench` 不会混编。日志与 VCD 保存在 `build/<测试名>/`；生成文件不进入版本控制。部分课程激励仅用于观察波形，功能结论由对应的模型自检支持。GitHub Actions 运行完整验证并保存日志。

## Vivado

在配置好 Vivado 的命令行运行以下任一命令：

```sh
vivado -mode gui -source scripts/create_project.tcl -tclargs lab1
vivado -mode gui -source scripts/create_project.tcl -tclargs dff
vivado -mode gui -source scripts/create_project.tcl -tclargs reg8file
vivado -mode gui -source scripts/create_project.tcl -tclargs lab3
vivado -mode gui -source scripts/create_project.tcl -tclargs lab4
```

工程自动生成到 `build/vivado/`，重复执行打开已有工程。设计源、仿真源、约束分开加入；实验3的工程名仍为 `flowing_water_lights`。进入行为仿真后执行 `run all`。实验3/4也保留原波形配置脚本，可在 Tcl Console 中用 `source` 加载。

本仓库整理版已在本地通过 Icarus 仿真；Vivado 建工程脚本尚未实机运行，综合、实现、时序收敛和新版上板仍需验证。实验4较早版本已通过课程检查，不代表本整理版已经重新上板。

仓库仅收录代码、引脚约束、验证脚本和学习说明。课程报告、学生卡照片、教材及 Vivado 自动生成文件保留在原本地资料中。学习时请理解并独立完成课程要求。
