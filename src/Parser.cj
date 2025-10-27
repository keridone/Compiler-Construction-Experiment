/*
    本项目所有代码已在Github开源，欢迎star
    开源链接：
    https://github.com/keridone/Compiler-Construction-Experiment.git
*/
package Cangjie_based_lexer

class parser <: base {
    private var pointer: Int64
    private var error_cnt: Int64

    // 构造函数：初始化指针和错误计数器
    public parser(var token_table: Array<token>, let token_cnt: Int64){
        pointer = 0
        error_cnt = 0
    }

    // 运行解析程序入口
    public func run(){
        parse_program()
        if(error_cnt == 0){println("Parsing succeeded!")}
        else{println("Parsing failed with ${error_cnt} errors.")}
    }

    // 开始解析：进入主程序声明
    private func parse_program(){parse_main_declaration() }

    // 解析 main 函数声明格式：main ( ) { ... }
    private func parse_main_declaration(){
        if(token_table[pointer].name != "main"){ parse_error("main") }
        else {get_next()}
        if(token_table[pointer].name != "("){ parse_error("(")}
        else {get_next()}
        if(token_table[pointer].name != ")"){ parse_error(")")}
        else {get_next()}
        parse_function_body()
    }

    // 解析函数体：{ 声明语句 + 语句列表 }
    private func parse_function_body(){
        if(token_table[pointer].name != "{"){ parse_error("{") }
        else {get_next()}
        parse_declaration_list()
        parse_statement_list()
        if(token_table[pointer].name != "}"){ parse_error("}") }
        else {get_next()}
    }

    // 连续解析 int 类型的声明语句
    private func parse_declaration_list():Unit{
        while(word2low(token_table[pointer].name) == "int"){parse_declaration_stat()}
    }

    // 连续解析语句
    private func parse_statement_list(){
        while(is_statement()){parse_statement()}
    }

    // 解析 int 类型声明语句：int identifier;
    private func parse_declaration_stat(){
        if(word2low(token_table[pointer].name) != "int"){ parse_error("int")} else {get_next()}
        assert(0)
        if(token_table[pointer].name != ";"){ parse_error(";")} else {get_next()}
    }

    // 判断并解析单个语句（if, read, write, 复合语句，表达式）
    private func parse_statement(): Unit{
        if(word2low(token_table[pointer].name) == "if"){parse_if_stat()}
        else{
            if(word2low(token_table[pointer].name) == "read"){parse_read_stat()}
            else{
                if(word2low(token_table[pointer].name) == "write"){parse_write_stat()}
                else{
                    if(token_table[pointer].name == "{"){parse_compound_stat()}
                    else{
                        if(token_table[pointer].lexeme == 0 || token_table[pointer].name == ";" || token_table[pointer].name == "(" || token_table[pointer].lexeme == 1){parse_expression_stat()}
                        else{
                            parse_error("statement")
                        }
                    }
                }
            }
        }
    }

    // 解析 if 语句格式：if (expr) stmt [else stmt]
    private func parse_if_stat(){
        if(word2low(token_table[pointer].name) != "if"){ parse_error("if")} else {get_next()}
        if(token_table[pointer].name != '('){parse_error('(')} else{get_next()}
        parse_expression()
        if(token_table[pointer].name != ')'){parse_error(')')} else{get_next()}
        parse_statement()
        if(word2low(token_table[pointer].name) == "else"){
            get_next()
            parse_statement()
        }
    }

    // 解析 write 语句格式：write expr;
    private func parse_write_stat(){
        if(word2low(token_table[pointer].name) == "write"){
            get_next()
            parse_expression()
            if(token_table[pointer].name != ';'){parse_error(';')}else{get_next()}
        }
        else{parse_error("write")}
    }

    // 解析 read 语句格式：read identifier;
    private func parse_read_stat(){
        if(word2low(token_table[pointer].name) == "read"){
            get_next()
            assert(0)
            if(token_table[pointer].name != ';'){parse_error(';')}else{get_next()}
        }
        else{parse_error("read")}
    }

    // 解析复合语句：{ stmt; }
    private func parse_compound_stat(){
        if(token_table[pointer].name != '{'){parse_error('{')}else{get_next()}
        parse_statement()
        if(token_table[pointer].name != '}'){parse_error('}')}else{get_next()}
    }

    // 解析表达式语句，如 expr;
    private func parse_expression_stat(){
        if(token_table[pointer].name != ';'){
            parse_expression()
            if(token_table[pointer].name != ';'){parse_error(';')}else{get_next()}
        }
    }

    // 解析表达式：赋值或布尔表达式
    private func parse_expression(){
        if(pointer+2 < token_cnt){
            if(token_table[pointer+1].name == '='){
                assert(0)
                get_next()
                parse_bool_expr()
            }
            else{parse_bool_expr()}
        }
        else{
            parse_bool_expr()
        }
    }

    // 解析布尔表达式：如 a > b
    private func parse_bool_expr(){
        parse_additive_expr()
        if(token_table[pointer].name == '>' || token_table[pointer].name == '>='){
            get_next()
            parse_additive_expr()
        }
    }

    // 解析加法表达式：term [+|- term]*
    private func parse_additive_expr(): Unit{
        parse_term()
        while(token_table[pointer].name == '+' || token_table[pointer].name == '-'){
            get_next()
            parse_term()
        }
    }

    // 解析乘除表达式：factor [*|/ factor]*
    private func parse_term(){
        parse_factor()
        while(token_table[pointer].name == '*' || token_table[pointer].name == '/'){
            get_next()
            parse_factor()
        }
    }

    // 解析因子：整数、标识符或括号表达式
    private func parse_factor(){
        if(token_table[pointer].name != '('){
            if(token_table[pointer].lexeme == 0){assert(0)}
            else{if(token_table[pointer].lexeme == 1){assert(1)}else{parse_error("Identifier or Integer")}}
        }
        else{
            get_next()
            parse_additive_expr()
            if(token_table[pointer].name != ')'){parse_error(')')}else{get_next()}
        }
    }

    // 判断是否为语句的起始符号
    private func is_statement(): Bool{
        return word2low(token_table[pointer].name) == "if" || word2low(token_table[pointer].name) == "read" || word2low(token_table[pointer].name) == "write" || token_table[pointer].name == "{" || token_table[pointer].lexeme == 0 || token_table[pointer].name == ";"
    }

    // 断言当前 token 是否为指定词法类
    private func assert(lm: Int64){
        if(token_table[pointer].lexeme != lm){ 
            error_cnt++
            let tmp_line = token_table[pointer].line
            println("line ${token_table[pointer].line}: expect lexeme: ${num2lexeme[lm]} , get: ${num2lexeme[token_table[pointer].lexeme]}") 
            while(token_table[pointer].name != ';' || token_table[pointer].name != '}' || token_table[pointer].line != tmp_line){ get_next() }
        }
        else{get_next()}
    }

    // 解析错误处理
    private func parse_error(tk: String){ 
        error_cnt++
        let tmp_line = token_table[pointer].line
        println("line ${token_table[pointer].line}: expect: '${tk}' , get: ${token_table[pointer].name}") 
        println("Parsing failed with ${error_cnt} errors.")
        while(token_table[pointer].name != ';' || token_table[pointer].name != '}' || token_table[pointer].line != tmp_line){ get_next() }
    }

    // 指针前移一格
    private func get_next(){
        pointer++
        if(token_table[pointer].lexeme == 5){println("End of file!")}
    }
}
