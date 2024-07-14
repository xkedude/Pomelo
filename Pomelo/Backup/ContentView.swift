//
//  ContentView.swift
//  Pomelo
//
//  Created by Stossy11 on 15/6/2024.
//

import CarPlay
import SwiftUI
import UIKit


struct ContentView: View {
    @AppStorage("JIT-NOT-ENABKED") var JIT = false
    
    var body: some View {
        Text("cool")
            .alert(isPresented: $JIT) {
                Alert(title: Text("JIT"), message: Text("Test"), dismissButton: .default(Text("OK")))
            }
    }
}


