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
        // didnt expect this to work actually
        joystickView.baseAlpha = -1
        
        
    
        // peepee poopoo
        joystickView.handleSizeRatio = 0.2
        return joystickView
    }


    func updateUIView(_ uiView: JoyStickView, context: Context) {
        // no need for this bitchesssss /j
    }
}

struct JoystickViewSwiftUI: View {
    @State var x: CGFloat = 0.0 // accedentially made it so both x and y went to the same var for both the right and left joystick :\
    @State var y: CGFloat = 0.0
    @State var iscool: Any?
    var sudachi = Sudachi.shared

    var body: some View {
        VStack {
            JoyStickViewRepresentable(x: $x, y: $y) // very representable
                .onChange(of: x) { newX in
                    updateThumbstick()
                }
                .onChange(of: y) { newY in
                    updateThumbstick()
                }
                .frame(width: 160, height: 160) // im wondering if i even need this anymore
        }
        .padding()
    }

    private func updateThumbstick() {
        let scaledX = Float(x)
        let scaledY = Float(y) // my dumbass broke this by having -y instead of y :/
        print("Joystick Position: (\(scaledX), \(scaledY))")
        
        if iscool != nil {
            sudachi.thumbstickMoved(.right, x: scaledX, y: scaledY)
        } else {
            sudachi.thumbstickMoved(.left, x: scaledX, y: scaledY)
        }
    }
}
