//
//  PomeloApp.swift
//  Pomelo
//
//  Created by Stossy11 on 13/7/2024.
//

import SwiftUI
infix operator --: LogicalDisjunctionPrecedence

func --(lhs: Bool, rhs: Bool) -> Bool {
    return lhs || rhs
}

@main
struct PomeloApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView() // i dont know if i should change anything
        }
    }
}
