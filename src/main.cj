/*
    本项目所有代码已在Github开源，欢迎star
    开源链接：
    https://github.com/keridone/Compiler-Construction-Experiment.git
*/
package Cangjie_based_lexer

main(args: Array<String>) {
    let file_reader = file_reader(args[0])
    let filename = get_filename(args[0])
    var program: Array<Rune> = file_reader.get_program()
    var lexer = lexer(program, filename + ".txt")
    var res = lexer.run()
    lexer.show()
    res[lexer.get_token_cnt()] = token(5, "End of file!", lexer.get_line())
    var parser = parser2(res, lexer.get_token_cnt(), filename + ".midcode")
    parser.run()
    var wordcode = parser.generate_word_code()
    var machine = TESTmachine(wordcode)
    machine.run()
    // lexer.write2file()
}

func get_filename(file: String): String{
    var i = 0
    var filename = ""
    while (file[i] != UInt8(UInt32(r'.'))) {
        filename = filename + String(Rune(file[i]))
        i++
    }
    return filename
}