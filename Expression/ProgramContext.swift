//
//  ProgramContext.swift
//  Expression
//
//  Created by Henk on 31/07/2024.
//

import Foundation

enum ProgramError: Error {
    case underflow
    case undefined(String)
}

struct Symbol {
    let arity: Int
    let code: ([Double]) -> Double
}

let functions: [String: Symbol] = [
    "+": Symbol(arity: 2, code: { params in
        params[0] + params[1]
    }),
    "-": Symbol(arity: 2, code: { params in
        params[0] - params[1]
    }),
    "*": Symbol(arity: 2, code: { params in
        params[0] * params[1]
    }),
    "/": Symbol(arity: 2, code: { params in
        params[0] / params[1]
    }),
    "neg": Symbol(arity: 1, code: { params in
        -params[0]
    }),
    "log": Symbol(arity: 1, code: { params in
        log(params[0])
    }),
    "exp": Symbol(arity: 1, code: { params in
        exp(params[0])
    }),
    "log10": Symbol(arity: 1, code: { params in
        log10(params[0])
    }),
    "pow": Symbol(arity: 2, code: { params in
        pow(params[0], params[1])
    }),
    "sqrt": Symbol(arity: 1, code: { params in
        sqrt(params[0])
    }),
    
    "sin": Symbol(arity: 1, code: { params in
        sin(params[0])
    }),
    "cos": Symbol(arity: 1, code: { params in
        cos(params[0])
    }),
    "tan": Symbol(arity: 1, code: { params in
        tan(params[0])
    }),
    "asin": Symbol(arity: 1, code: { params in
        asin(params[0])
    }),
    "acos": Symbol(arity: 1, code: { params in
        acos(params[0])
    }),
    "atan": Symbol(arity: 1, code: { params in
        atan(params[0])
    }),
    "&&": Symbol(arity: 2, code: { params in
        (params[0] != 0 && params[1] != 0) ? 1 : 0
    }),
    "||": Symbol(arity: 2, code: { params in
        (params[0] != 0 || params[1] != 0) ? 1 : 0
    }),
    "!": Symbol(arity: 1, code: { params in
        params[0] != 0 ? 0 : 1
    }),
    
    "==": Symbol(arity: 2, code: { params in
        (params[0] == params[1]) ? 1 : 0
    }),
    "!=": Symbol(arity: 2, code: { params in
        (params[0] != params[1]) ? 1 : 0
    }),
    "<": Symbol(arity: 2, code: { params in
        (params[0] < params[1]) ? 1 : 0
    }),
    ">": Symbol(arity: 2, code: { params in
        (params[0] > params[1]) ? 1 : 0
    }),
    "<=": Symbol(arity: 2, code: { params in
        (params[0] <= params[1]) ? 1 : 0
    }),
    ">=": Symbol(arity: 2, code: { params in
        (params[0] >= params[1]) ? 1 : 0
    }),
    
    "abs": Symbol(arity: 1, code: { params in
        abs(params[0])
    }),
    "min": Symbol(arity: 2, code: { params in
        min(params[0], params[1])
    }),
    "max": Symbol(arity: 2, code: { params in
        max(params[0], params[1])
    }),
    "round": Symbol(arity: 1, code: { params in
        round(params[0])
    }),
    "if": Symbol(arity: 3, code: { params in
        params[0] != 0 ? params[1] : params[2]
    })
]

enum Instruction: CustomStringConvertible {
    // push value on the stack
    case pushValue(Double)
    // push variable value on the stack
    case pushVariable(String)
    // pop value onm the stack and assign it to a variable
    case popVariable(String)
    // call build-in function
    case call(String, Symbol)
    
    var description: String {
        switch self {
        case let .pushValue(value):
            "push \(value)"
        case let .pushVariable(name):
            "push \(name)"
        case let .popVariable(name):
            "pop \(name)"
        case let .call(name, _):
            "call \(name)"
        }
    }
    
    func execute(context: ProgramContext) throws {
        switch self {
        case let .pushValue(value):
            context.stack.append(value)
            
        case let .pushVariable(name):
            guard let value = context.variable[name]
            else { throw ProgramError.undefined(name) }
            
            context.stack.append(value)
            
        case let .popVariable(name):
            guard !context.stack.isEmpty
            else { throw ProgramError.underflow }
            
            context.variable[name] = context.stack.popLast()
            
        case let .call(_, impl):
            guard context.stack.count >= impl.arity
            else { throw ProgramError.underflow }
            
            let result = impl.code(context.stack.suffix(impl.arity))
            context.stack.removeLast(impl.arity)
            context.stack.append(result)
        }
    }
}

class ProgramContext: ObservableObject {
    var stack: [Double] = []
    @Published var variable: [String: Double] = [:]
    var program: [Instruction]
    
    init(_ program: [Instruction]) {
        self.program = program
        variable["pi"] = Double.pi
        variable["e"] = exp(1.0)
    }
    
    convenience init() {
        self.init([])
    }
    
    func run() {
        self.run(program)
    }

    func run(_ program: [Instruction]) {
        variable.removeAll()
        variable["pi"] = Double.pi
        variable["e"] = exp(1.0)
        stack.removeAll()
        do {
            for instruction in program {
                try instruction.execute(context: self)
            }
        } catch {
            print(error)
        }
    }
}
