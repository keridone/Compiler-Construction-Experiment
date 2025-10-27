/*
    本项目所有代码已在Github开源，欢迎star
    开源链接：
    https://github.com/keridone/Compiler-Construction-Experiment.git
*/
package Cangjie_based_lexer

open class base{

    protected let keywords: Array<String> 
        = ["if", "else", "while", "for", "int", "write", "read"]
    protected var num2lexeme: Array<String> 
        = ["Identifier", "Integer\t", "Single signal", "Double signal", "Keyword\t", "End of file!"]
    
    protected open func word2low(word: String){
        var lower_word: String = ""
        for(letter in word.runes()){
            if(letter >= r'A' && letter <= r'Z'){
                lower_word += String(Rune(UInt32(letter) + 32))
            }else{
                lower_word += String(letter)
            }
        }
        lower_word
    }
    protected open func strcmp(word1: String, word2: String): Bool{
        if(word1.size != word2.size){return true}
        else{
            for(i in 0..=word1.size-1){
                if(word1[i] != word2[i]){return true}
            }
            return false
        }
    }
    protected open func atoi(str: String):Int64{
    var result = 0;
    var sign = 1;
    var i = 0;
    // 跳过空格
    while (Rune(str[i]) == r' ') {
        i++;
    }
    // 判断正负号
    if (Rune(str[i]) == r'-') {
        sign = -1;
        i++;
    } else if (Rune(str[i]) == r'+') {
        i++;
    }
    // 逐位累加
    while (i<str.size && UInt32(str[i]) >= UInt32(r'0') && UInt32(str[i]) <= UInt32(r'9')) {
        result = result * 10 + Int64(UInt32(str[i]) - UInt32(r'0'));
        i++;
    }
    return result * sign;
}

    protected open func itoa(value1: Int64): String{
        var value = value1
        var str: String = ""
        var buffer: Array<Rune>;      // 临时缓冲区，存储反转字符
        var i = 0;
        var is_negative = 0;
        buffer = Array<Rune>(100, item: r'\0')
        // 特殊情况：0
        if (value == 0) {
            str = '0';
            return str
        }

        // 处理负数
        if (value < 0) {
            is_negative = 1;
            value = -value;
        }

        // 从低位开始取余转换字符
        while (value > 0) {
            buffer[i] = Rune((value % 10) + Int64(UInt32(r'0')));  // 数字转字符
            i ++
            value /= 10;
        }

        // 如果是负数，加上负号
        if (is_negative == 1) {
            buffer[i] = r'-';
            i ++
        }

        // 反转 buffer 到 str
        while (i > 0) {
            i--
            str = str + String(buffer[i])
        }
        return str
    }
}