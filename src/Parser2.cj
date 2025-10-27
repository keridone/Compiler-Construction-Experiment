/*
    本项目所有代码已在Github开源，欢迎star
    开源链接：
    https://github.com/keridone/Compiler-Construction-Experiment.git
*/

package Cangjie_based_lexer

import std.collection.*
import std.fs.*

class parser2 <: base {
    private var pointer: Int64
    private var error_cnt: Int64
    private var symbol_table: Map<String, Int64>  // 变量名 -> 地址（整数）
    private var output_code: ArrayList<String>
    private var word_code: ArrayList<String>
    private var next_var_addr: Int64               // 下一个变量地址计数器
    private var label_count: Int64                  // 用于生成唯一标签编号
    public parser2(var token_table: Array<token>, let token_cnt: Int64, let out_path: String){
        pointer = 0
        error_cnt = 0
        symbol_table = HashMap<String, Int64>()
        output_code = ArrayList<String>()
        word_code = ArrayList<String>()
        next_var_addr = 0
        label_count = 0
    }
    public func run(){
        if(parse_program()){
            println("Parsing succeeded!")
            output_code.append("STOP")
            write2file()
            for(code in output_code){ println(code) }
        }
        else{println("Parsing failed with ${error_cnt} errors.")}
    }
    public func write2file(){
        let file = File.create(out_path)
        for(str in output_code){
            file.write((str+"\n").toArray())
        }
    }
    public func generate_word_code(): ArrayList<String> {
        for(line in output_code){
            var parts = line.split(" ")
            for(p in parts){
                if(p != "") {
                    word_code.append(p)
                }
            }
        }
        return word_code
}
    // 生成唯一标签
    private func new_label(): String{
        label_count++
        return "L${label_count}"
    }

    private func parse_program(assert!: Bool = true): Bool{
        // 初始化不输出任何 C 代码，直接开始解析
        return parse_main_declaration()
    }
    private func parse_main_declaration(assert!: Bool = true): Bool{
        return term("main") && term("(") && term(")") && parse_function_body()
    }
    private func parse_function_body(assert!: Bool = true): Bool{
        return term("{") && parse_declaration_list() && parse_statement_list() && term("}")
    }
    private func parse_declaration_list(assert!: Bool = true): Bool{
        var save = pointer
        return (pointer=save, parse_declaration_stat(assert: false) && parse_declaration_list())[1] || (pointer=save, parse_epsilon())[1]
    }
    private func parse_declaration_stat(assert!: Bool = true):Bool{
        var save = pointer
        if(term("int", assert: assert) && cat(0, check_id: false)){  // cat(0)代表标识符
            var var_name = token_table[pointer-1].name
            if(symbol_table.contains(var_name)){
                println("line ${token_table[pointer-1].line}: variable '${var_name}' redeclared.")
                error_cnt++
            } else {
                symbol_table[var_name] = next_var_addr
                next_var_addr++
                // 声明不生成汇编代码，只是分配地址
            }
            return term(";")
        }
        pointer = save
        return false
    }
    private func parse_epsilon(assert!: Bool = true): Bool{
        return true
    }
    private func parse_statement_list(assert!: Bool = true): Bool{
        var save = pointer
        return (pointer=save, parse_statement(assert: false) && parse_statement_list())[1] || (pointer=save, parse_epsilon())[1]
    }
    private func parse_statement(assert!: Bool = true): Bool{
        var save = pointer
        return (pointer=save, parse_if_stat(assert: false))[1] || (pointer=save, parse_read_stat(assert: false))[1] || (pointer=save, parse_write_stat(assert: false))[1] || (pointer=save, parse_compound_stat(assert: false))[1] || (pointer=save, parse_expression_stat(assert: assert))[1]
    }
    private func parse_if_stat(assert!: Bool = true): Bool{
        if(!term("if", assert: assert)) {return false}
        if(!term("(")) {return false}
        if(!parse_expression()) {return false}
        if(!term(")")) {return false}

        // 生成 if 语句汇编代码：
        // 栈顶为条件表达式结果，BRF 跳转到 else_label
        let else_label = new_label()
        let end_label = new_label()
        output_code.append("BRF ${else_label}")

        if(!parse_statement()) {return false}

        output_code.append("BR ${end_label}")

        output_code.append("${else_label}:")

        if(term("else", assert: false)){
            if(!parse_statement()) {return false}
        }

        output_code.append("${end_label}:")
        return true
    }
    private func parse_read_stat(assert!: Bool = true): Bool{
        var save = pointer
        if(term("read", assert: assert, cogen: false) && cat(0, cogen: false)){
            var var_name = token_table[pointer-1].name
            if(!symbol_table.contains(var_name)){
                error_cnt++
                println("line ${token_table[pointer-1].line}: variable '${var_name}' not declared before use.")
            } else {
                // 读入变量，生成IN指令，STO 地址
                output_code.append("IN")
                output_code.append("STO ${symbol_table[var_name]}")
            }
            return term(";", cogen: false)
        }
        pointer = save
        return false        
    }
    private func parse_write_stat(assert!: Bool = true): Bool{
        var save = pointer
        if(term("write", assert: assert, cogen: false)){
            if(!parse_expression()) {return false}
            // 表达式计算完成，栈顶为值，生成OUT指令输出
            output_code.append("OUT")
            if(!term(";", cogen: false)) {return false}
            return true
        }
        pointer = save
        return false
    }
    private func parse_compound_stat(assert!: Bool = true): Bool{
        return term("{", assert: assert) && parse_statement_list() && term("}")
    }
private func parse_expression_stat(assert!: Bool = true): Bool{
    var save = pointer
    if(pointer + 1 < token_cnt && token_table[pointer + 1].name == "="){
        if(!cat(0, assert: false)) {return false}
        var var_name = token_table[pointer-1].name
        if(!term("=")) {return false}
        if(!parse_bool_expr()) {return false}
        if(!term(";")) {return false}
        if(!symbol_table.contains(var_name)){
            error_cnt++
            println("line ${token_table[pointer-1].line}: variable '${var_name}' not declared before use.")
        } else {
            output_code.append("STO ${symbol_table[var_name]}")
            output_code.append("POP")    // 添加弹栈指令，避免栈顶残留
        }
        return true
    }
    pointer = save
    if(parse_expression(assert: false) && term(";")) {
        output_code.append("POP")        // 无赋值表达式语句，计算结果弹出
        return true
    }
    pointer = save
    if(term(";", assert: assert)){
        return true
    }
    return false
}

    private func parse_expression(assert!: Bool = true): Bool{
        return parse_bool_expr(assert: assert)
    }

    // 布尔表达式部分（支持 >, >= ）
    private func parse_bool_expr(assert!: Bool = true): Bool{
        if(!parse_additive_expr()) {return false}
        var save = pointer
        if(pointer < token_cnt){
            var op = token_table[pointer].name
            if(op == ">" || op == ">="){
                pointer++
                if(!parse_additive_expr()) {return false}
                if(op == ">"){
                    output_code.append("GT")
                } else if(op == ">="){
                    output_code.append("GE")
                }
                return true
            }
        }
        pointer = save
        return true
    }

    private func parse_additive_expr(assert!: Bool = true): Bool{
        if(!parse_term()) {return false}
        while(true){
            var save = pointer
            if(term("+", assert: false)){
                if(!parse_term()) {return false}
                output_code.append("ADD")
            } else if(term("-", assert: false)){
                if(!parse_term()) {return false}
                output_code.append("SUB")
            } else {
                pointer = save
                break
            }
        }
        return true
    }
    private func parse_term(assert!: Bool = true): Bool{
        if(!parse_factor()) {return false}
        while(true){
            var save = pointer
            if(term("*", assert: false)){
                if(!parse_factor()) {return false}
                output_code.append("MULT")
            } else if(term("/", assert: false)){
                if(!parse_factor()) {return false}
                output_code.append("DIV")
            } else {
                pointer = save
                break
            }
        }
        return true
    }
    private func parse_factor(assert!: Bool = true): Bool{
        var save = pointer
        if(term("(", assert: false)){
            if(!parse_additive_expr()) {return false}
            if(!term(")")) {return false}
            return true
        }
        pointer = save
        if(cat(0, assert: false)){  // 标识符
            var var_name = token_table[pointer-1].name
            if(!symbol_table.contains(var_name)){
                error_cnt++
                println("line ${token_table[pointer-1].line}: variable '${var_name}' used before declaration.")
                return false
            }
            output_code.append("LOAD ${symbol_table[var_name]}")
            return true
        }
        pointer = save
        if(cat(1, assert: assert)){  // 常数
            var val_str = token_table[pointer-1].name
            output_code.append("LOADI ${val_str}")
            return true
        }
        pointer = save
        return false
    }

    private func term(tok: String, assert!: Bool = true, cogen!: Bool = true): Bool{
        if(assert){
            if(afadd_term() == tok){
                return true
            }else{
                error_cnt++
                println("line ${token_table[pointer-1].line}: expect: '${tok}' , get: ${token_table[pointer-1].name}") 
                return false
            }
        }else{
            if(afadd_term() == tok){
                return true
            }else{
                return false
            } 
        }
    }
    private func afadd_term(): String{
        if(token_table[pointer].lexeme == 5){return "End of file!"}
        var tok = token_table[pointer].name
        pointer++
        return word2low(tok)
    }
    private func cat(lexeme: Int64, assert!: Bool = true, check_id!: Bool = true, cogen!: Bool = true): Bool{
        var side_check = false
        if(lexeme == 0 && token_table[pointer].lexeme == 0){side_check = true}
        if(assert || side_check){
            if(afadd_cat() == lexeme && (lexeme != 0 || !check_id || symbol_table.contains(token_table[pointer-1].name))){
                return true
            }
            else{
                error_cnt++
                if(token_table[pointer-1].lexeme != lexeme){println("line ${token_table[pointer-1].line}: expect lexeme: ${num2lexeme[lexeme]} , get: ${num2lexeme[token_table[pointer-1].lexeme]}")}
                if(token_table[pointer-1].lexeme == 0 && !symbol_table.contains(token_table[pointer-1].name)){println("line ${token_table[pointer-1].line}: variable '${token_table[pointer-1].name}' used before declaration.")}
                return false
            }
        }else{
            if(afadd_cat() == lexeme && (lexeme != 0 || !check_id || symbol_table.contains(token_table[pointer-1].name))){
                return true
            }else{
                return false
            }
        }
    }
    private func afadd_cat(): Int64{
        if(token_table[pointer].lexeme == 5){return 5}
        var lexeme = token_table[pointer].lexeme
        pointer++
        return lexeme
    }
}
