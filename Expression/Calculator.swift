//
//  Expression.swift
//  Expression
//
//  Created by Henk on 29/07/2024.
//

import Foundation

struct Handler {
    let params: Int
    let implementation: ([Double]) -> [Double]
    
    init(_ params: Int, _ implementation: @escaping ([Double]) -> [Double]) {
        self.params = params
        self.implementation = implementation
    }
}



private let handlers: [String: Handler] = [
    "pi": Handler(0) { _ in
        [Double.pi]
    },
    
    "sin": Handler(1) { args in
        [sin(args[0])]
    },
    "asin": Handler(1) { args in
        [asin(args[0])]
    },
    "cos": Handler(1) { args in
        [cos(args[0])]
    },
    "acos": Handler(1) { args in
        [acos(args[0])]
    },
    "tan": Handler(1) { args in
        [tan(args[0])]
    },
    "atan": Handler(1) { args in
        [atan(args[0])]
    },
    
    "sqrt": Handler(1) { args in
        [sqrt(args[0])]
    },
    "sqr": Handler(1) { args in
        [args[0] * args[0]]
    },
    "log": Handler(1) { args in
        [log(args[0])]
    },
    "exp": Handler(1) { args in
        [exp(args[0])]
    },
    "log10": Handler(1) { args in
        [log10(args[0])]
    },
    "pow": Handler(2) { args in
        [pow(args[0], args[1])]
    },
    
    "==": Handler(2) { args in
        [args[0] == args[1] ? 1 : 0]
    },
    "!=": Handler(2) { args in
        [args[0] != args[1] ? 1 : 0]
    },
    ">?": Handler(2) { args in
        [args[0] != args[1] ? 1 : 0]
    },
    ">": Handler(2) { args in
        [args[0] > args[1] ? 1 : 0]
    },
    "<": Handler(2) { args in
        [args[0] < args[1] ? 1 : 0]
    },
    ">=": Handler(2) { args in
        [args[0] >= args[1] ? 1 : 0]
    },
    "<=": Handler(2) { args in
        [args[0] <= args[1] ? 1 : 0]
    },
    
    "not": Handler(1) { args in
        [(args[0] == 0) ? 1 : 0]
    },
    "and": Handler(2) { args in
        [(args[0] != 0 && args[1] != 0) ? 1 : 0]
    },
    "or": Handler(2) { args in
        [(args[0] != 0 || args[1] != 0) ? 1 : 0]
    },
    "xor": Handler(2) { args in
        [((args[0] != 0) != (args[1] != 0)) ? 1 : 0]
    },

    "dup": Handler(1) { args in
        [args[0], args[0]]
    },
    "swap": Handler(2) { args in
        [args[1], args[0]]
    },
    
    "+": Handler(2) { args in
        [args[0] + args[1]]
    },
    "-": Handler(2) { args in
        [args[0] - args[1]]
    },
    "*": Handler(2) { args in
        [args[0] * args[1]]
    },
    "/": Handler(2) { args in
        [args[0] / args[1]]
    },
    
    "abs": Handler(1) { args in
        [abs(args[0])]
    },
    "min": Handler(2) { args in
        [min(args[0], args[1])]
    },
    "max": Handler(2) { args in
        [max(args[0], args[1])]
    },
    "if": Handler(3) { args in
        [args[0] != 0 ? args[1] : args[2]]
    },
    "neg": Handler(1) { args in
        [-args[0]]
    }
]

enum CalculateError: Error {
    case stackUnderflow(token: String, index: Int)
    case invalidToken(token: String, index: Int)
    case invalidResult
}




class Calculator {
    private var stack: [Double] = []
    var values: [String: Double] = [:]
    
    private func _evaluate(_ text: String) throws {
        stack.removeAll()
        let tokens = text.lowercased().split(separator: " ").map { String($0) }
        for (index, token) in tokens.enumerated() {
            if let handler = handlers[token] {
                guard
                    handler.params <= stack.count
                else {
                    throw CalculateError.stackUnderflow(token: token, index: index)
                }
                
                let result = handler.implementation(stack.suffix(handler.params))
                stack.removeLast(handler.params)
                stack.append(contentsOf: result)
            } else if let value = values[token] {
                stack.append(value)
            } else if let value = Double(token) {
                stack.append(value)
            } else {
                throw CalculateError.invalidToken(token: token, index: index)
            }
        }
        
        /*
         return  stack
         .map { String($0) }
         .joined(separator: ", ")
         */
    }
    
     /*
      (
      )
      +
      -
      
      */
    
    func evaluate(_ text: String) -> String? {
        do {
            try _evaluate(text)
            
            guard
                stack.count == 1
            else {
                return nil
            }
            
            return String(stack[0])
        } catch {
            return nil
        }
    }
}
