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

struct Impl {
    let params: Int
    let code: ([Double]) -> Double
}

let functions: [String: Impl] = [
    "+": Impl(params: 2, code: { params in
        params[0] + params[1]
    }),
    "-": Impl(params: 2, code: { params in
        params[0] - params[1]
    }),
    "*": Impl(params: 2, code: { params in
        params[0] * params[1]
    }),
    "/": Impl(params: 2, code: { params in
        params[0] / params[1]
    }),
    "neg": Impl(params: 1, code: { params in
        -params[0]
    }),
    "log": Impl(params: 1, code: { params in
        log(params[0])
    }),
    "exp": Impl(params: 1, code: { params in
        exp(params[0])
    }),
    "log10": Impl(params: 1, code: { params in
        log10(params[0])
    }),
    "pow": Impl(params: 2, code: { params in
        pow(params[0], params[1])
    }),
    "sqrt": Impl(params: 1, code: { params in
        sqrt(params[0])
    }),
    
    "sin": Impl(params: 1, code: { params in
        sin(params[0])
    }),
    "cos": Impl(params: 1, code: { params in
        cos(params[0])
    }),
    "tan": Impl(params: 1, code: { params in
        tan(params[0])
    }),
    "asin": Impl(params: 1, code: { params in
        asin(params[0])
    }),
    "acos": Impl(params: 1, code: { params in
        acos(params[0])
    }),
    "atan": Impl(params: 1, code: { params in
        atan(params[0])
    }),
    "&&": Impl(params: 2, code: { params in
        (params[0] != 0 && params[1] != 0) ? 1 : 0
    }),
    "||": Impl(params: 2, code: { params in
        (params[0] != 0 || params[1] != 0) ? 1 : 0
    }),
    "!": Impl(params: 1, code: { params in
        params[0] != 0 ? 0 : 1
    }),
    
    "==": Impl(params: 2, code: { params in
        (params[0] == params[1]) ? 1 : 0
    }),
    "!=": Impl(params: 2, code: { params in
        (params[0] != params[1]) ? 1 : 0
    }),
    "<": Impl(params: 2, code: { params in
        (params[0] < params[1]) ? 1 : 0
    }),
    ">": Impl(params: 2, code: { params in
        (params[0] > params[1]) ? 1 : 0
    }),
    "<=": Impl(params: 2, code: { params in
        (params[0] <= params[1]) ? 1 : 0
    }),
    ">=": Impl(params: 2, code: { params in
        (params[0] >= params[1]) ? 1 : 0
    }),
    
    "abs": Impl(params: 1, code: { params in
        abs(params[0])
    }),
    "min": Impl(params: 2, code: { params in
        min(params[0], params[1])
    }),
    "max": Impl(params: 2, code: { params in
        max(params[0], params[1])
    }),
    "round": Impl(params: 1, code: { params in
        round(params[0])
    }),
    "if": Impl(params: 3, code: { params in
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
    case call(String, Impl)
    
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
            guard context.stack.count >= impl.params
            else { throw ProgramError.underflow }
            
            let result = impl.code(context.stack.suffix(impl.params))
            context.stack.removeLast(impl.params)
            context.stack.append(result)
        }
    }
}

class ProgramContext: ObservableObject {
    var stack: [Double] = []
    @Published var variable: [String: Double] = [:]
    let program: [Instruction]
    
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
