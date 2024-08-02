//
//  JoystickUIView.swift
//  Pomelo
//
//  Created by Stossy11 on 1/8/2024.
//

import SwiftUI
import UIKit
import JoyStickView
import Sudachi

struct JoyStickViewRepresentable: UIViewRepresentable {
    @Binding var x: CGFloat
    @Binding var y: CGFloat

    func makeUIView(context: Context) -> JoyStickView {
        let joystickView = JoyStickView()
        joystickView.monitor = .xy { report in
            x = report.x
            y = report.y
        }
        return joystickView
    }

    func updateUIView(_ uiView: JoyStickView, context: Context) {
        // Update the joystick view if needed
    }
}

struct JoystickViewSwift: View {
    @Binding var x: CGFloat
    @Binding var y: CGFloat
    var sudachi = Sudachi.shared

    var body: some View {
        VStack {
            JoyStickViewRepresentable(x: $x, y: $y)
                .onChange(of: x) { newX in
                    updateThumbstick()
                }
                .onChange(of: y) { newY in
                    updateThumbstick()
                }
                .frame(width: 200, height: 200)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(100)
        }
        .padding()
    }

    private func updateThumbstick() {
        let scaledX = Float(x)
        let scaledY = Float(-y) // Invert Y axis for proper orientation
        print("Joystick Position: (\(scaledX), \(scaledY))")
        sudachi.thumbstickMoved(.left, x: scaledX, y: scaledY)
    }
}
