# 整理改动与验证范围

## 改动

整理版从本地lab1–lab4当前源码复制，原实验目录、PDF及提交包保持原样。

- 实验4使用最新四文件版和无 `u_` 前缀的实例名；不带入已合并的cycle_counter、bcd_counter旧文件。
- 为实验4模式同步、按键消抖输入同步寄存器补充 `ASYNC_REG` 属性，便于Vivado识别同步链。该属性不改变行为仿真逻辑；物理实现效果仍需Vivado验证。
- 实验2两个RTL模块补充统一的 `timescale`；实验3默认计数常量标明24位宽。接口、默认功能和老师要求的分支结构保持不变。
- 提供跨平台Python验证入口，每组测试指定独立顶层，避免同名testbench冲突；仿真产物集中到build目录。
- 用统一Tcl入口创建五个独立Vivado工程，固定器件型号并分开加入设计、仿真与约束。
- 添加GitHub Actions完整仿真、日志归档和忽略规则；以中文文档总结电路行为、参数和实际操作。

## 验证

本地完整命令：`python3 scripts/verify.py --full`。

| 测试 | 覆盖 |
|---|---|
| lab1_course | 10组课程输入及期望输出 |
| lab1_exhaustive | 全1024种二进制输入组合，包括加法溢出和减法借位 |
| lab2_dff_course / model | 课程6项；独立模型2119项、1000混合周期 |
| lab2_regfile_course / model | 课程36项；独立模型20505项、2048组地址数据写入及1000混合周期 |
| lab3_course / model | 课程波形；模型核对复位、计数、方向、模式及8种开关组合 |
| lab4_course / edge / model | 课程波形；两级边沿脉冲；扫描、译码、回绕、抖动、长按、启停与模式 |
| lab3_default | 默认慢档千万拍、快档二十万拍和不停机切换 |
| lab4_default | 默认1ms扫描、20ms消抖、0.1s计数和长按只计一次 |

课程波形测试并非全部含断言，需结合独立模型自检。失败通过 `$fatal` 返回非零状态，统一脚本会停止并保留日志；仿真设有超时限制。

实验2寄存器文件组合读的 `@* is sensitive to all 8 words in array` 是Icarus对组合敏感列表的提示。

截至整理时，实验4旧版已通过课程检查；精简、实例改名及本次属性整理后的版本不能据此声称已重新上板。本仓库未执行Vivado综合、实现、时序检查；统一Tcl入口也尚未在Vivado中运行。首次GitHub Actions完整验证已通过13组仿真，运行记录见[首次验证](https://github.com/peppaoinks/digital-logic-labs/actions/runs/41193408706)。后续提交状态以README中的徽章及Actions记录为准。
