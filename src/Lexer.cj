/*
    本项目所有代码已在Github开源，欢迎star
    开源链接：
    https://github.com/keridone/Compiler-Construction-Experiment.git
*/
/*
    Intro:  A simple lexer written in Cangjie
    Author: S.H. Zhou
    Date:   2025/5/3
*/

package Cangjie_based_lexer
import std.console.*
import std.fs.*
// import std.argopt.*

struct token{
    public var lexeme: Int64              // 词法类型编号
    public var name: String               // 词素本体
    public var line: UInt64               // 行号
    public init(lexeme: Int64, name: String, line: UInt64){
        this.lexeme = lexeme
        this.name = name
        this.line = line
    }
}

class file_reader {
    public file_reader(let file_path: String){
        let exist = File.exists(file_path)
        if(!exist){
            println("Error: File doesn't exist!\n")  // 文件不存在错误
        }
    }
    public func get_program(){
        let program_int = File.readFrom(this.file_path)
        var program = Array<Rune>(program_int.size, item: r'0')
        for(i in 0..program_int.size){
            program[i] = Rune(program_int[i])        // 字节转字符
        }
        program
    }
}

class lexer <: base {

    private var line: UInt64
    private var is_error: Bool
    private var token_cnt: Int64
    private var pointer: Int64
    private var results = Array<token>(10000, {_ => token(0, "", 0)})

    public lexer(let program: Array<Rune>, let out_path: String){
        is_error = false
        pointer = 0
        token_cnt = 0
        line = 1
    }

    public func run(){
        while(pointer < program.size){
            if(is_empty(program[pointer])){
                read_next()
                continue
            }
            if(is_letter(program[pointer])){         // 识别标识符或关键字
                var id: String = String(program[pointer])
                read_next()
                while(pointer < program.size){
                    if(is_letter(program[pointer]) || is_digit(program[pointer])){
                        id += String(program[pointer])
                        read_next()
                    }else{
                        if(is_keyword(word2low(id))){
                            results[token_cnt] = token(4, id, this.line)
                        }else{
                            results[token_cnt] = token(0, id, this.line)
                        }
                        token_cnt++;
                        break
                    }
                }
                continue
            }
            if(is_digit(program[pointer])){          // 识别数字
                var num: String = String(program[pointer])
                read_next()
                while(pointer < program.size){
                    if(is_digit(program[pointer])){
                        num += String(program[pointer])
                        read_next()
                    }else{
                        if(!is_letter(program[pointer]) && !is_slash(program[pointer])){
                            results[token_cnt] = token(1, num, this.line)
                            token_cnt++;
                            break
                        }else{
                            found_error(program[pointer])
                            break
                        }
                    }
                }
                continue
            }
            if(is_single_signal(program[pointer])){  // 识别单字符符号
                results[token_cnt] = token(2, String(program[pointer]), this.line)
                token_cnt++; read_next()
                continue
            }
            if(is_other_signal(program[pointer])){   // 识别运算符，如 >、<、!
                var op: String = String(program[pointer])
                read_next()
                if(program[pointer] == r'='){        // 识别 >=、<=、!= 等双字符操作符
                    op += String(r'=')
                    results[token_cnt] = token(3, op, this.line)
                    token_cnt++; read_next()
                }
                else{
                    results[token_cnt] = token(2, op, this.line)
                    token_cnt++;
                }
                continue
            }
            if(is_slash(program[pointer])){          // 处理注释或除号
                if(pointer+1 < program.size){
                    read_next()
                    if(program[pointer] == r'*'){    // 多行注释 /* ... */
                        while(pointer < program.size){
                            read_next()
                            if(program[pointer] == r'*' && pointer+1 < program.size){
                                read_next()
                                if(program[pointer] == r'/'){
                                    read_next()
                                    break
                                }
                            }
                        }
                    }else{                           // 单个 /
                        if(is_empty(program[pointer])){
                            results[token_cnt] = token(2, "/", this.line)
                            token_cnt++; read_next()
                        }else{
                            found_error(program[pointer])
                        }    
                    }
                }else{
                    results[token_cnt] = token(2, "/", this.line)
                    token_cnt++
                }
                continue
            }
            found_error(program[pointer])            // 遇到非法字符
            read_next()
        }
        if(!is_error){println("Lexical analysis succeeds!\n")}
        else{println("Lexical analysis fails!\n")}
        results
    }

    public func out_string(i: Int64){
        var str: String
        if(results[i].lexeme == 4){
            str = (word2low(results[i].name) + "\t\t\t" + results[i].name) // 输出关键字格式
        }else{
            str = (num2lexeme[results[i].lexeme] + "\t\t" + results[i].name)
        }
        str
    }

    public func show(){                               // 控制台展示词法分析结果
        println("Token Category\t\t" + "Token")
        for(i in 0..token_cnt){
            println(out_string(i))
        }
    }

    public func write2file(){                         // 将词法分析结果写入文件
        let file = File.create(out_path)
        file.write(("Token Category\t\t" + "Token\n").toArray())
        for(i in 0..token_cnt){
            file.write((out_string(i) + "\n").toArray())
        }
        println("\nLexical analysis results write to file ${out_path} !\n")
    }

    private func read_next(){
        this.pointer++
        if(pointer < program.size && UInt32(program[pointer]) == 10){
            this.line++                               // 换行符则行数加一
        }
    }

    private func found_error(ch: Rune){               // 词法错误提示
        this.is_error = true
        println("Found error in line ${this.line} : ${ch}")
    }

    // 以下为字符判断函数
    private func is_empty(ch: Rune){
        return UInt32(ch) == 10 || UInt32(ch) == 13 || UInt32(ch) == 32
    }
    private func is_letter(ch: Rune){
        return (ch >= r'A' && ch <= r'Z') || (ch >= r'a' && ch <= r'z')
    }
    private func is_digit(ch: Rune){
        return ch >= r'0' && ch <= r'9'
    }
    private func is_single_signal(ch: Rune){
        return ch == r';' || ch == r',' || ch == r'(' || ch == r')' || ch == r'[' || ch == r']' || ch == r'{' || ch == r'}' || ch == r'+'  || ch == r'-' || ch == r'*'
    }
    private func is_other_signal(ch: Rune){
        return ch == r'>' || ch == r'<' || ch == r'!' || ch == r'='
    }
    private func is_slash(ch: Rune){
        return ch == r'/'
    }

    private func is_keyword(str: String){
        for(keyword in keywords){
            if(str == keyword){
                return true
            }
        }
        return false
    }

    public func get_token_cnt(){token_cnt}
    public func get_line(){line}
}
