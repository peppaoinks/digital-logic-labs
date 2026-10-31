# 实验1至4学习讲义

[阅读或下载PDF](lab1-4-learning-guide.pdf) · [LaTeX源码](source/main.tex)

面向零基础学习的中文讲义，按电平与时钟、Verilog语法、组合运算、时序存储、流水灯、数码管的顺序展开，包含原理、代码讲解、操作自测与代码附录。

## 阅读顺序

1. 数字逻辑基础：电平、时钟与寄存器。
2. Verilog基础：端口、赋值、时序与模块实例。
3. 实验1：组合运算与多路选择。
4. 实验2：D触发器与寄存器文件。
5. 实验3：参数化计数与流水灯。
6. 实验4：数码管扫描、消抖与边沿检测。
7. 操作、自测及完整代码附录。

## 与当前源码的关系

这份讲义来自2026年10月29日编写的学习资料。实验4讲解保留当时的模块拆分：`bcd_counter` 和 `cycle_counter` 独立存在，实例名也使用较早命名。`source/code/` 是与正文配套的历史示例快照，供阅读和编译讲义使用。

仓库当前可运行实现以根目录 [lab4](../../lab4) 为准：十进制计数合入 `lab4.v`，扫描计时合入 `led_ctrl_unit.v`，保留消抖和边沿检测，共四个设计文件。请勿将讲义附录中的旧代码混入当前Vivado工程；最新模块边界见[架构说明](../architecture.md)。

本次上传保留讲义正文和署名，仅移除封面、页眉中的学号和班级，原本地文件保持原样。讲义内的预期现象和操作说明不代表当前整理版已经完成上板验证。

## 从源码编译

安装带中文支持的TeX Live或MacTeX，以及XeLaTeX、latexmk。在此目录执行：

```sh
cd source
latexmk -xelatex -interaction=nonstopmode -halt-on-error -outdir=build main.tex
```

结果为 `source/build/main.pdf`。优先使用可用宋体，否则使用Fandol中文字体；字体替换可能改变分页。源码中的11个Verilog文件由LaTeX直接排版，无需先运行仿真。编译产物不纳入Git。
