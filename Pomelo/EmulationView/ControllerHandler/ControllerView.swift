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
        GeometryReader { geometry in
            ZStack {
                if geometry.size.height > geometry.size.width {
                    // Portrait layout
                    VStack {
                        Spacer()
                        HStack {
                            DPadView()
                            Spacer()
                            ABXYView()
                        }
                        .padding(.bottom, geometry.size.height / 3.2) // Move the buttons up
                        .padding(.horizontal)
                    }
                } else {
                    // Landscape layout
                    HStack {
                        DPadView() 
                        Spacer()
                        ABXYView()
                    }
                    .padding(.top, geometry.size.height / 5) // Move the buttons up
                }
            }
        }
    }
}

struct DPadView: View {
    var body: some View {
        VStack {
            ButtonView(button: .directionalPadUp)
            HStack {
                ButtonView(button: .directionalPadLeft)
                Spacer(minLength: 20)
                ButtonView(button: .directionalPadRight)
            }
            ButtonView(button: .directionalPadDown)
        }
        .frame(width: 160, height: 170)
    }
}

struct ABXYView: View {
    var body: some View {
        VStack {
            ButtonView(button: .X)
            HStack {
                ButtonView(button: .Y)
                Spacer(minLength: 20)
                ButtonView(button: .A)
            }
            ButtonView(button: .B)
        }
        .frame(width: 160, height: 170)
    }
}

struct ButtonView: View {
    let button: VirtualControllerButtonType
    let sudachi = Sudachi.shared
    @State var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Image(systemName: buttonText)
            .resizable()
            .frame(width: 50, height: 50)
            .foregroundColor(colorScheme == .dark ? Color.gray : Color.gray) // Adjust color based on mode
            .opacity(isPressed ? 0.5 : 1)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !self.isPressed {
                            self.isPressed = true
                            sudachi.virtualControllerButtonDown(button)
                        }
                    }
                    .onEnded { _ in
                        self.isPressed = false
                        sudachi.virtualControllerButtonUp(button)
                    }
            )
    }
    
    private var buttonText: String {
        switch button {
        case .A:
            return "a.circle.fill"
        case .B:
            return "b.circle.fill"
        case .X:
            return "x.circle.fill"
        case .Y:
            return "y.circle.fill"
        case .directionalPadUp:
            return "arrowtriangle.up.circle.fill"
        case .directionalPadDown:
            return "arrowtriangle.down.circle.fill"
        case .directionalPadLeft:
            return "arrowtriangle.left.circle.fill"
        case .directionalPadRight:
            return "arrowtriangle.right.circle.fill"
        // Add cases for other button types as needed
        default:
            return ""
        }
    }
}
