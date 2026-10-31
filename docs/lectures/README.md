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

## 配套代码

讲义中的代码位于 `source/code/`，用于配合正文阅读和排版。开发板工程使用仓库根目录的 `lab1/` 至 `lab4/`，模块接口和组织方式见[架构说明](../architecture.md)。

## 从源码编译

安装带中文支持的TeX Live或MacTeX，以及XeLaTeX、latexmk。在此目录执行：

```sh
cd source
latexmk -xelatex -interaction=nonstopmode -halt-on-error -outdir=build main.tex
```

结果为 `source/build/main.pdf`。优先使用可用宋体，否则使用Fandol中文字体；字体替换可能改变分页。源码中的11个Verilog文件由LaTeX直接排版，无需先运行仿真。编译产物不纳入Git。
