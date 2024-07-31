//
//  ContentView.swift
//  Expression
//
//  Created by Henk on 29/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject
    var programContext = ProgramContext()
    let calculator = Calculator()
    @State var text: String = ""
    var body: some View {
        VStack {
            TextField("Enter expression", text: $text)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
               
            Text("Result: \(programContext.variable["Delta"] ?? 0)")
                .padding()
        }
        .onChange(of: text) { value in
            print(value)
            if let program = try? compile(value) {
                do {
                    try programContext.run(program)
                    
                    
                } catch {
                    
                }
               
            }
           
        }
        .padding()
        .task {
            test("delta = 42 + (y * 2) - not z + cos(pi)")
        }
    }
}

#Preview {
    ContentView()
}
