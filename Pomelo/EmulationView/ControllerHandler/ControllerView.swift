//
//  ControllerView.swift
//  Pomelo
//
//  Created by Stossy11 on 14/7/2024.
//

import SwiftUI
import Sudachi


struct ControllerView: View {
    @StateObject var viewModel: SudachiEmulationViewModel
    let sudachi = Sudachi.shared
    @State var isPressed = false
    
    var body: some View {
        Circle()
             .frame(width: 200, height: 50)
             .foregroundColor(.secondary)
             .overlay(
                 Text("A")
                     .foregroundColor(.white)
             )
             .gesture(
                 DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !self.isPressed {
                            self.isPressed = true
                            sudachi.virtualControllerButtonUp(.A)
                        }
                    }
                    .onEnded { _ in
                        self.isPressed = false
                        print("Button released")
                        sudachi.virtualControllerButtonDown(.A)
                    }
               )
    }
}
