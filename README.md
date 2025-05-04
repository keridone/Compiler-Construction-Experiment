# A simple TEST-lexer written in Cangjie

## TEST词法分析器——大连海事大学编译原理实验

## Intro

用仓颉语言写的简易词法分析器。作者不会仓颉，代码写的依托，文档也是○|￣|_

### symbol table $\Sigma$

$$
\Sigma = \{[A-Z],[a-z],[0-9],[',',';','(',')','[',']','{','}','/'],['>','<','!','='],['+','-','*','/'],[LF/NL,CR,(Space)]\}
$$

### num2category

| Token Category | num2category |
| -------------- | ------------ |
| Identifiers    | 0            |
| Integers       | 1            |
| Single signals | 2            |
| Double signals | 3            |
| Keywords       | 4            |

## build

```cmd
cjpm build
```

## test

```cmd
cjpm run --run-args .\\testfile.txt
```

