//
//  Compiler.swift
//  Expression
//
//  Created by Henk on 31/07/2024.
//

import Foundation




func compile(_ text: String) throws -> [Instruction] {
    let tokenizer = Tokenizer(input: text)
    var token = tokenizer.nextToken()
    var program: [Instruction] = []
    
    func assert(_ condition: Bool, _ error: CompileError) throws {
        if !condition {
            print(error)
            throw error
        }
    }
    
    // code generation
    
    func genCode(_ instruction: Instruction) {
        program.append(instruction)
    }
    
    func call(_ name: String) throws {
        guard let impl = functions[name]
        else {
            throw CompileError.expected("")
        }
        genCode(.call(name, impl))
    }
    
    // parser

    func factor() throws {
        switch token {
        case let .function(name, params):
            token = tokenizer.nextToken()
            try assert(token == .lparen, .expected("("))
            token = tokenizer.nextToken()
            for i in stride(from: params, through: 1, by: -1) {
                try expression()
                if i > 1 {
                    try assert(token == .comma, .expected(","))
                    token = tokenizer.nextToken()
                }
            }
            try assert(token == .rparen, .expected(")"))
            token = tokenizer.nextToken()
            try call(name)
        case let .identifier(name):
            token = tokenizer.nextToken()
            genCode(.pushVariable(name))
        case .not:
            token = tokenizer.nextToken()
            try factor()
            try call("!")
        case let .literal(value):
            token = tokenizer.nextToken()
            genCode(.pushValue(value))
        case .lparen:
            token = tokenizer.nextToken()
            try expression()
            try assert(token == .rparen, CompileError.expected(")"))
            token = tokenizer.nextToken()
        default:
            throw CompileError.expected("identifier, number or (")
        }
    }
    
    func term() throws {
        try factor()
        while case let .mulop(op) = token {
            token = tokenizer.nextToken()
            try factor()
            try call(op)
        }
    }
        
    func simpleExpression() throws {
        var negate = false
        if case let .addop(op) = token, op == "+" || op == "-" {
            token = tokenizer.nextToken()
            negate = op == "-"
        }
        
        try term()
        while case let .addop(op) = token {
            token = tokenizer.nextToken()
            try term()
            try call(op)
        }
        if negate {
            try call("neg")
        }
    }
        
    func expression() throws {
        try simpleExpression()
        while case let .relop(op) = token {
            token = tokenizer.nextToken()
            try simpleExpression()
            try call(op)
        }
    }
    
    func assugnment() throws {
        guard case let .identifier(variableName) = token
        else { throw CompileError.expected("identifier") }
        token = tokenizer.nextToken()
        
        try assert(token == .equal, .expected("="))
        token = tokenizer.nextToken()
        
        try expression()
        
        genCode(.popVariable(variableName))
    }
    
    repeat {
        try assugnment()
    } while token != .eof
   
    return program
}


func test(_ test: String) {
}
