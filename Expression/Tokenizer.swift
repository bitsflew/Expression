//
//  tokenizer.swift
//  Expression
//
//  Created by Henk on 30/07/2024.
//

import Foundation

import Foundation

enum CompileError: Error {
    case expected(String)
}

enum Token: Equatable {
    case identifier(String)
    case function(String, Int)
    case literal(Double)
    case addop(String)
    case mulop(String)
    case relop(String)
    case lparen
    case rparen
    case not
    case comma
    case invalid
    case equal
    case eof
    
    case set(String)
}

class Tokenizer {
    private var input: String
    private var currentIndex: String.Index
    
    init(input: String) {
        self.input = input
        self.currentIndex = input.startIndex
    }
     
    private func isDigit(_ char: Character) -> Bool {
        char.isNumber
    }
    
    private func isWhiteSpace(_ char: Character) -> Bool {
        char.isWhitespace
    }
    
    private func advance() {
        currentIndex = input.index(after: currentIndex)
    }
    
    private func peek() -> Character? {
        if currentIndex < input.endIndex {
            return input[currentIndex]
        }
        return nil
    }
    
    private func readWhile(_ condition: (Character) -> Bool) -> String {
        var result = ""
        while let char = peek(), condition(char) {
            result.append(char)
            advance()
        }
        return result
    }
    
    private func readLiteral() -> Double? {
        var result = readWhile(isDigit)
        if let char = peek(), char == "." {
            result.append(char)
            advance()
            result += readWhile(isDigit)
        }
        return Double(result)
    }
    
    func nextToken() -> Token {
        while let char = peek(), isWhiteSpace(char) {
            advance()
        }
        
        guard let char = peek() else {
            return .eof
        }
        
        if char.isLetter {
            let identifier = readWhile { $0.isLetter || $0.isNumber }
            switch identifier {
            case "not":
                return .not
            case "and":
                return .mulop("&&")
            case "or":
                return .addop("||")
            default:
                return if let impl = functions[identifier] {
                    .function(identifier, impl.params)
                } else {
                    .identifier(identifier)
                }
            }
        }
            
        if char.isNumber {
            return if let value = readLiteral() {
                .literal(value)
            } else {
                .invalid
            }
        }
            
        switch char {
        case "+":
            advance()
            return .addop("+")
        case "-":
            advance()
            return .addop("-")
        case "*":
            advance()
            return .mulop("*")
        case "/":
            advance()
            return .mulop("/")
        case "&":
            advance()
            if peek() == "&" {
                advance()
                return .mulop("&&")
            } else {
                return .invalid
            }
        case "|":
            advance()
            if peek() == "|" {
                advance()
                return .mulop("||")
            } else {
                return .invalid
            }
        case "!":
            advance()
            if peek() == "=" {
                advance()
                return .relop("!=")
            } else {
                return .not
            }
        case "=":
            advance()
            if peek() == "=" {
                advance()
                return .relop("==")
            } else {
                return .equal
            }
        case "<":
            advance()
            switch peek() {
            case "=":
                advance()
                return .relop("<=")
            case ">":
                advance()
                return .relop("!=")
            default:
                return .relop("<")
            }
        case ">":
            advance()
            if peek() == "=" {
                advance()
                return .relop(">=")
            }
            return .relop(">")
        case "(":
            advance()
            return .lparen
        case ")":
            advance()
            return .rparen
        case ",":
            advance()
            return .comma
        default:
            advance()
            return .invalid
        }
    }
}
