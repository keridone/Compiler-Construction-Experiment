## 📘 Cangjie Compiler Construction Experiment

一个基于 **仓颉语言（Cangjie）** 编写的简易编译器前端与解释器项目，主要包含词法分析器、语法分析器、中间代码生成器以及伪机解释执行器。
该项目可作为编译原理课程实验的完整实现示例，也适合初学者了解从源码到中间代码再到执行的全过程。

> 🌟 **项目地址**： [https://github.com/keridone/Compiler-Construction-Experiment](https://github.com/keridone/Compiler-Construction-Experiment.git)

---

### 📂 项目结构

```
.
├── main.cj              # 项目主入口，调用词法分析、语法分析、中间代码生成与执行
├── Lexer.cj             # 词法分析器
├── Parser.cj            # 基本语法分析器（错误恢复）
├── Parser2.cj           # 语法分析 + 中间代码生成
├── TESTmachine.cj       # 伪机解释执行器（抽象机）
├── util.cj              # 工具与基础类支持
├── README.md            # 项目说明文档（你正在看）
```

---

### 🧰 功能简介

| 模块            | 文件               | 功能                                        |
| ------------- | ---------------- | ----------------------------------------- |
| **主程序**       | `main.cj`        | 程序入口，负责调用 `lexer`、`parser`、`TESTmachine`  |
| **词法分析器**     | `Lexer.cj`       | 将源代码分解成 token 序列，支持标识符、关键字、数字、运算符、注释、分隔符等 |
| **语法分析器**     | `Parser.cj`      | 对 token 序列进行递归下降分析，进行语法检查和错误报告            |
| **语法+中间代码生成** | `Parser2.cj`     | 在语法分析的同时生成伪汇编中间代码                         |
| **伪机执行器**     | `TESTmachine.cj` | 执行 Parser2 生成的中间代码，模拟 CPU 运行过程            |
| **工具函数**      | `util.cj`        | 字符串处理、关键字判断、数值转换等基础功能                     |

---

### 📖 支持的语言特性

* ✅ 变量声明（`int x;`）
* ✅ 表达式计算（加、减、乘、除）
* ✅ 关系运算（`>`, `>=`）
* ✅ if-else 控制语句
* ✅ read / write 语句
* ✅ 代码块与作用域
* ✅ 注释处理（`/* ... */`）
* ✅ 错误提示与基本错误恢复

示例代码：

```cangjie
int a;
int b;
read a;
read b;
if (a > b) {
    write a;
} else {
    write b;
}
```

---

### ⚙️ 伪汇编指令集（TESTmachine）

Parser2 会将程序翻译为类似如下的伪汇编代码，TESTmachine 逐条执行：

| 指令                          | 功能       |
| --------------------------- | -------- |
| `LOAD addr`                 | 从地址加载到栈顶 |
| `LOADI val`                 | 直接将常数压栈  |
| `STO addr`                  | 栈顶值存入地址  |
| `POP`                       | 弹栈       |
| `ADD`, `SUB`, `MULT`, `DIV` | 算术运算     |
| `GT`, `GE`                  | 比较运算     |
| `BR`, `BRF`                 | 无条件/条件跳转 |
| `IN`, `OUT`                 | 输入输出     |
| `STOP`                      | 程序结束     |

---

### 🏃 使用说明

1. 克隆项目

```bash
git clone https://github.com/keridone/Compiler-Construction-Experiment.git
cd Compiler-Construction-Experiment
```

2. 使用仓颉语言编译器运行
   （假设你的环境中已安装 Cangjie 编译器）：

```bash
cjc main.cj
```

3. 输入测试数据，查看词法分析、语法分析及执行结果。

---

### 🧪 示例运行

假设源文件如下：

```cangjie
int x;
int y;
read x;
read y;
if (x >= y) {
    write x;
} else {
    write y;
}
```

执行后输出伪汇编中间代码：

```
IN
STO 0
IN
STO 1
LOAD 0
LOAD 1
GE
BRF L1
LOAD 0
OUT
BR L2
L1:
LOAD 1
OUT
L2:
STOP
```

并在终端执行输出：

```
请输入数据：10
请输入数据：3
程序输出 10
```

---

### 🧱 开发环境

* **语言**：Cangjie 仓颉语言
* **运行环境**：Windows11
* **终端工具**：VS Code

---

### 🧑‍💻 贡献

欢迎通过以下方式参与本项目：

* ✨ 提交 Issue 报告错误或提出改进建议
* 🔥 提交 PR 优化代码结构或扩展功能
* 🌱 增加更多语言特性（如循环、函数、自定义类型）

---

### 📜 License

本项目基于 **MIT License** 开源。
自由修改与分发，但请保留作者与仓库来源链接 🙌。
如果你觉得这个项目对你有帮助，欢迎点个 **Star⭐**！
