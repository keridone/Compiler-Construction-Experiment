/*
    本项目所有代码已在Github开源，欢迎star
    开源链接：
    https://github.com/keridone/Compiler-Construction-Experiment.git
*/
package Cangjie_based_lexer

import std.collection.*
import std.fs.*
import std.console.*

class TESTmachine <: base{
    private var es: Int64
    private var i: Int64
    private var k: Int64
    private var codecount: Int64
    private var stacktop: Int64
    private var stack: Array<Int64>
    private var label: Array<Int64>
    private var data: Array<Int64>
    private var lno: Array<Rune>
    public TESTmachine(var code: ArrayList<String>){
        es = 0
        i = 0
        k = 0
        codecount = 0
        stacktop = 0
        stack = Array<Int64>(1000, item: 0)
        label = Array<Int64>(100, item: 0)
        lno = Array<Rune>(4, item: r'\0')
        data = Array<Int64>(1000, item: 0)
        // word_cnt = code.size
    }
    public func run(): Int64{
        var pt = 0
        while(pt < code.size){
            i = code[codecount].size-1
            if(UInt32(code[codecount][i]) == UInt32(r':')){
                i=i-5
                strncpy(codecount, 5, i)
                lno[i] = r'\0'
                label[atoi(lno2str())] = codecount
                println("label[ ${atoi(lno2str())}]= ${label[atoi(lno2str())]}")
                code[codecount] = ":"
                code[codecount] += lno2str()
                k++
            }
            codecount++
            pt++
        }
        for(i in 0..=code.size-1){
            var l = code[i].size
            println("label[2] = ${label[2]} ${i} ${code[i]} ${l}")
            if ((l> 1) && (UInt32(code[i][1]) == UInt32(r'A'))){
                strncpy(i, 5, l-5)
                println("llllllllllabel[2}=${label[2]} lho= ${lno2str()}")
                lno[l-5]= r'\0'
                code[i] = itoa(label[atoi(lno2str())])
            }
        }
        for(k in 0..=4){
            print("label${k} ${label[k]} An")
        }
        i=0
        while(i < code.size){
            println("code ${i} ${code[i]}")
            if (strcmp(code[i], "LOAD") == false)	  //LOAD D将D中的内容加载到操作数栈
		    {
                if(i+1 < code.size){i++}else{break}
			    stack[stacktop] = data[atoi(code[i])];
			    stacktop++;
		    }
            if (strcmp(code[i], "LOADI") == false)	 //LOADI 8将常量己压入操作数栈
		    {
			    if(i+1 < code.size){i++}else{break}
			    stack[stacktop] = atoi(code[i]);
			    stacktop++;
		    }
            //STO D将操作数栈栈顶单元内容存入0,且栈顶单元内容保持不变
            if(strcmp(code[i],"STO") == false)
            {
                if(i+1 < code.size){i++}else{break}
                data[atoi(code[i])]=(stack[stacktop-1]);
                println("sto stack ${stack[stacktop-1]}");
                println("sto data ${data[atoi(code[i])]}");
            }
            //POP桟顶单元内容出桟
            if (strcmp (code[i], "POP") == false)
            {
                stacktop--;
            }
            //ADD将次桟顶单元与栈顶单元内容出栈并相加，和置于栈顶
            if (strcmp(code[i], "ADD") == false)
            {
                stack[stacktop-2] = stack[stacktop-2] + stack[stacktop-1];
                println("add ${stack[stacktop-1]}");
                stacktop--;
            }
            //SUB 将次栈顶单元减去栈顶单元内容并出栈，差置于栈顶
            if(strcmp(code[i],"SUB") == false)
            {
                stack[stacktop-2] = stack[stacktop-2] - stack[stacktop-1];
                stacktop--;
            }
            //MULT 将次栈顶单元与栈顶单元内容出栈并相乘，积置于栈顶
            if (strcmp(code[i], "MULT") == false)
            {
                stack[stacktop - 2] = stack[stacktop - 2] * stack[stacktop - 1];
                stacktop--;
            }
            //DIV 将次栈顶单元与栈顶单元内容出栈并相除,商置于栈顶
            if (strcmp (code[i], "DIV") == false)
            {
                stack[stacktop-2]=stack[stacktop-2]/stack[stacktop-1];
                stacktop--;
            }
            //BR lab无条件转移到lab
            if(strcmp(code[i],"BR") == false)
            {
                if(i+1 < code.size){i++}else{break}
                i=atoi (code[i]);
            }
            //BRF lab检查栈顶单元逻辑值并出栈,若为假(0)则转移到lab
            if(strcmp(code[i],"BRF") == false)
            {
                if(i+1 < code.size){i++}else{break}
                if (stack[stacktop-1] == 0){i=atoi(code[i])}
                stacktop--;
            }
            //EQ将栈顶两单元做等于比较并出栈,并将结果真或假(1或0)置于栈顶
            if(strcmp(code[i], "EQ") == false)
            {
                if(stack[stacktop-2] == stack[stacktop- 1]){stack[stacktop-2] = 1}
                else{stack[stacktop-2] = 0}
                stacktop--;
            }
            //NOTEQ栈顶两单元做不等于比较并出栈，并将结果真或假(1或0)置于栈顶
            if(strcmp(code[i],"NOTEQ") == false)
            {
                if(stack[stacktop - 2] != stack[stacktop-1]){stack[stacktop - 2] = 1}
                else{stack[stacktop - 2] = 0}
                stacktop--;
            }
            //GT 次栈顶大于栈顶操作数并出栈，则栈顶置1,否则置0
            if (strcmp (code[i] , "GT") == false)
            {
                if(stack[stacktop-2]>stack[stacktop-1]){stack[stacktop-2]=1}
                else{stack[stacktop-2]=0}
                stacktop--;
            }
            //LES次桟顶小于栈顶操作数并出栈，则栈顶置1,否则置0
            if (strcmp(code[i], "LES") == false)
            {
                if(stack[stacktop - 2] < stack[stacktop - 1]){stack[stacktop - 2] = 1}
                else{stack[stacktop - 2] = 0}
                stacktop--;
            }
            //GE次栈顶大于等手栈顶操作数并出栈，则桟顶置1,否则置0
            if(strcmp(code[i],"GE") == false)
            {
                if(stack[stacktop-2] >= stack[stacktop-1]){stack[stacktop-2] = 1}
                else{stack[stacktop-2] = 0}
                stacktop--;
            }
            //LE次栈顶小于等于桟顶操作数并出栈，则栈顶置1,否则置0
            if (strcmp (code[i] , "LE") == false)
            {
                if(stack[stacktop-2] <= stack[stacktop-1]){stack[stacktop-2] = 1}
                else{stack[stacktop-2] = 0}
                stacktop--;
            }
            //AND将栈顶两单元做逻辑与运算并出栈，并将结果真或假(1或0>置于栈顶
            if (strcmp(code[i], "AND") == false)
            {
                if(stack[stacktop - 2]!=0 && stack[stacktop-1]!=0){stack[stacktop - 2] = 1}
                else{stack[stacktop - 2] = 0}
                stacktop--;
            }
            //0R将栈顶两单元做逻辑或运算并出栈，并将结果真或假(1或0)置于栈顶
            if (strcmp (code[i], "OR") == false)
            {
                if(stack[stacktop-2]!=0 || stack[stacktop-1]!=0){stack[stacktop-2] = 1}
                else{stack[stacktop-2] = 0}
                stacktop--;
            }
            //NOT将栈顶的逻辑值取反
            if(strcmp(code[i],"NOT") == false)
            {
                if(stack[stacktop-1] == 0){stack[stacktop-1] = 1}
                else{stack[stacktop-1] = 0}
            }
            //IN从标准输入设备(键盘)读入一个整型数据,并入栈
            if(strcmp(code[i], "IN")== false)
            {
                print("请输入数据：");
                var line = Console.stdIn.readln()
                var num = line.getOrThrow()
                stack[stacktop] = atoi(num)
                // stack[stacktop]=
                stacktop++;
            }
            //OUT将栈顶单元内容出栈，并输出到标准输出设备上(显示器)
            if(strcmp(code[i],"OUT") == false)
            {
                println("程序输出 ${stack[stacktop- 1]}");
                stacktop--;
            }
            //STOP停止执行
            if (strcmp (code[i], "STOP") == false)
            {
                break;
            }
            i++;
            println(" ${data[0]} ${data[1]}");
        }
        return es
    }
    private func strncpy(code_cnt: Int64, begin: Int64, length: Int64){
        var lno_pt = 0
        while(lno_pt < 4 && begin+lno_pt < code[code_cnt].size){
            lno[lno_pt] = Rune(code[code_cnt][begin+lno_pt])
            lno_pt++
        }
    }
    private func lno2str(): String{
        var str = ""
        var i = 0
        while(lno[i] != r'\0'){
            str += String(lno[i])
        }
        return str
    }
}