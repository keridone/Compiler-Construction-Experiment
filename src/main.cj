/*
    Intro:  A simple lexer written in Cangjie
    Author: S.H. Zhou
    Date:   2025/5/3
*/

package Cangjie_based_lexer
import std.console.*
import std.fs.*
import std.argopt.*

struct lexeme{
    public var category = Int64(0)
    public var token = String()

    public init(category: Int64, token: String){
        this.category = category
        this.token = token
    }
}

class file_reader {

    public file_reader(let file_path: String){
        let exist = File.exists(file_path)
        if(!exist){
            println("Error: File doesn't exist!\n")
        }
    }
    public func get_program(){
        let program_int = File.readFrom(this.file_path)
        var program = Array<Rune>(program_int.size, item: r'0')
        for(i in 0..program_int.size){
            program[i] = Rune(program_int[i])
        }
        program
    }
}

class lexer {

    private var is_error: Bool
    private var token_cnt: Int64
    private var pointer: Int64
    private let keywords: Array<String> = ["if", "else", "while", "for", "int"]
    private var num2category: Array<String> 
        = ["Identifier", "Integer\t", "Single signal", "Double signal", "Keyword\t"]
    private var results = Array<lexeme>(10000, {i => lexeme(0, "")})
    public lexer(let program: Array<Rune>){
        is_error = false
        pointer = 0
        token_cnt = 0
    }

    public func run(){
        while(pointer < program.size){
            if(is_error){
                break
            }
            if(is_empty(program[pointer])){
                pointer++
                continue
            }
            if(is_letter(program[pointer])){
                var id: String = String(program[pointer])
                pointer++
                while(pointer < program.size){
                    if(is_letter(program[pointer]) || program[pointer] == r'_'){
                        id += String(program[pointer])
                        pointer++
                    }else{
                        if(is_empty(program[pointer])){
                            if(is_keyword(id)){
                                results[token_cnt] = lexeme(4, id)
                            }else{
                                results[token_cnt] = lexeme(0, id)
                            }
                            token_cnt++; pointer++
                            break
                        }else{
                            found_error(program[pointer])
                            pointer++
                            break
                        }
                    }
                }
                continue
            }
            if(is_digit(program[pointer])){
                var num: String = String(program[pointer])
                pointer++
                while(pointer < program.size){
                    if(is_digit(program[pointer])){
                        num += String(program[pointer])
                        pointer++
                    }else{
                        if(is_empty(program[pointer])){
                            results[token_cnt] = lexeme(1, num)
                            token_cnt++; pointer++
                            break
                        }else{
                            found_error(program[pointer])
                            pointer++
                            break
                        }
                    }
                }
                continue
            }
            if(is_single_signal(program[pointer])){
                results[token_cnt] = lexeme(2, String(program[pointer]))
                token_cnt++; pointer++
                if(!is_empty(program[pointer])){
                    found_error(program[pointer])
                }
                pointer++
                continue
            }
            if(is_other_signal(program[pointer])){
                var op: String = String(program[pointer])
                pointer++
                if(program[pointer] == r'='){
                    op += String(r'=')
                    results[token_cnt] = lexeme(3, op)
                    token_cnt++; pointer++
                }else{
                    if(is_empty(program[pointer])){
                        results[token_cnt] = lexeme(3, op)
                        token_cnt++; pointer++
                    }else{
                        found_error(program[pointer])
                    }
                }
                continue
            }
            if(is_slash(program[pointer])){
                if(pointer+1 < program.size){
                    pointer++
                    if(program[pointer] == r'*'){
                        while(pointer < program.size){
                            pointer++
                            if(program[pointer] == r'*' && pointer+1 < program.size){
                                pointer++
                                if(program[pointer] == r'/'){
                                    pointer++
                                    break
                                }
                            }
                        }
                    }else{
                        if(is_empty(program[pointer])){
                            results[token_cnt] = lexeme(2, "/")
                            token_cnt++; pointer++
                        }else{
                            found_error(program[pointer])
                        }    
                    }
                }else{
                    results[token_cnt] = lexeme(2, "/")
                    token_cnt++
                }
                continue
            }
            found_error(program[pointer])
            break
        }
        if(!is_error){println("Lexical analysis succeeds!")}
        else{println("Lexical analysis fails!")}
    }

    public func show(){
        println("Token Category\t\t" + "Token")
        for(i in 0..results.size-1){
            if(results[i].token == ""){
                break
            }else{
                println(num2category[results[i].category] + "\t\t" + results[i].token)
            }
        }
    }

    private func found_error(ch: Rune){
        this.is_error = true
        println("Found error in the ${pointer}-th character: ${ch}")
    }

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
        return ch == r';' || ch == r',' || ch == r'(' || ch == r')' || ch == r'[' || ch == r']' || ch == r'{' || ch == r'}' || ch == r'+'  || ch == r'-' || ch == r'*' // || ch == r''
    }
    private func is_other_signal(ch: Rune){
        return ch == r'>' || ch == r'<' || ch == r'!' || ch == r'=' // || ch == r''
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
}

main(args: Array<String>) {
    let file_reader = file_reader(args[0])
    var program: Array<Rune> = file_reader.get_program()
    var lexer = lexer(program)
    lexer.run()
    lexer.show()
}
