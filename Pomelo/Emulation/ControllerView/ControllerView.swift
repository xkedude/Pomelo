//
//  ControllerView.swift
//  Pomelo-V2
//
//  Created by Stossy11 on 16/7/2024.
//


import SwiftUI
import GameController
import Sudachi
 

struct ControllerView: View {
    let sudachi = Sudachi.shared
    @State var isPressed = false
    @State var controllerconnected = false
    @State private var x: CGFloat = 0.0
    @State private var y: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !controllerconnected {
                    if geometry.size.height > geometry.size.width { // geometry reader stuff took me like how long to figure it out
                        // this might be portrait
                        VStack {
                            Spacer()
                            HStack {
                                VStack {
                                    ShoulderButtonsViewLeft()
                                    ZStack {
                                        JoystickViewSwiftUI()
                                        DPadView()
                                    }
                                }
                                Spacer()
                                VStack {
                                    ShoulderButtonsViewRight()
                                    ZStack {
                                        JoystickViewRightSwiftUI() // hope this works
                                        ABXYView()
                                    }
                                }
                            }
                            .padding(.bottom, geometry.size.height / 3.2) // very broken
                            .padding(.horizontal)
                        }
                    } else {
                        // could be landscape
                        VStack {
                            Spacer()
                            VStack {
                                HStack {
                                    VStack {
                                        ShoulderButtonsViewLeft()
                                        ZStack {
                                            JoystickViewSwiftUI()
                                            DPadView()
                                        }
                                    }
                                    Spacer()
                                    VStack {
                                        ShoulderButtonsViewRight()
                                        ZStack {
                                            JoystickViewRightSwiftUI() // hope this works
                                            ABXYView()
                                        }
                                    }
                                }
                                
                            }
                            .padding(.bottom, geometry.size.height / 3.2) // also extre=mally broken (
                        }
                    }
                }
            }
        }
        .onAppear {
            print("checking for controller:")
            controllerconnected = false
            DispatchQueue.main.async {
                setupControllers() // i dont know what half of this shit does
            }
        }
    }
    
    private func setupControllers() {
        NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { notification in
            if let controller = notification.object as? GCController {
                print("wow controller onstart") // yippeeee
                setupController(controller)
                controllerconnected = true
            } else {
                print("not GCController :((((((") // wahhhhhhh
            }
        }
        
        NotificationCenter.default.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { notification in
            // crazy
            print("wow controller gone")
            controllerconnected = false
        }
        
        GCController.controllers().forEach { controller in
            print("wow controller")
            controllerconnected = true
            setupController(controller)
        }
    }
    
    private func setupController(_ controller: GCController) {
        let extendedGamepad = controller.extendedGamepad!
        
        extendedGamepad.dpad.up.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.directionalPadUp) : self.touchUpInside(.directionalPadUp)
        }
        
        extendedGamepad.dpad.down.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.directionalPadDown) : self.touchUpInside(.directionalPadDown)
        }
        
        extendedGamepad.dpad.left.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.directionalPadLeft) : self.touchUpInside(.directionalPadLeft)
        }
        
        extendedGamepad.dpad.right.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.directionalPadRight) : self.touchUpInside(.directionalPadRight)
        }
        
        
        extendedGamepad.buttonOptions?.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.minus) : self.touchUpInside(.minus)
        }
        
        extendedGamepad.buttonMenu.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.plus) : self.touchUpInside(.plus)
        }
        
        extendedGamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.A) : self.touchUpInside(.A)
        }
        
        extendedGamepad.buttonB.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.B) : self.touchUpInside(.B)
        }
        
        extendedGamepad.buttonX.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.X) : self.touchUpInside(.X)
        }
        
        extendedGamepad.buttonY.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.Y) : self.touchUpInside(.Y)
        }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.triggerL) : self.touchUpInside(.L)
        }
        
        extendedGamepad.leftTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.triggerZL) : self.touchUpInside(.triggerZL)
        }
        
        extendedGamepad.rightShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.triggerR) : self.touchUpInside(.R)
        }
        
        extendedGamepad.rightTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.triggerZR) : self.touchUpInside(.triggerZR)
        }
        
        extendedGamepad.leftThumbstick.valueChangedHandler = { dpad, x, y in
            self.sudachi.thumbstickMoved(.left, x: x, y: y)
        }
        
        extendedGamepad.rightThumbstick.valueChangedHandler = { dpad, x, y in
            self.sudachi.thumbstickMoved(.right, x: x, y: y)
        }
    }
    
    
    private func touchDown(_ button: VirtualControllerButtonType) {
        sudachi.virtualControllerButtonDown(button)
    }
    
    private func touchUpInside(_ button: VirtualControllerButtonType) {
        sudachi.virtualControllerButtonUp(button)
    }
    
    private func handleDPad(_ dpad: GCControllerDirectionPad) {
        handleButton(dpad.up, virtualButton: .directionalPadUp)
        handleButton(dpad.down, virtualButton: .directionalPadDown)
        handleButton(dpad.left, virtualButton: .directionalPadLeft)
        handleButton(dpad.right, virtualButton: .directionalPadRight)
    }
    
    private func handleButton(_ button: GCControllerButtonInput, virtualButton: VirtualControllerButtonType) {
        button.pressedChangedHandler = { button, _, pressed in
            if pressed {
                sudachi.virtualControllerButtonDown(virtualButton)
            } else {
                sudachi.virtualControllerButtonUp(virtualButton)
            }
        }
    }
}

struct ShoulderButtonsViewLeft: View {
    var body: some View {
        HStack {
            ButtonView(button: .triggerZL)
                .padding(.horizontal)
            ButtonView(button: .triggerL)
                .padding(.horizontal)
        }
        .frame(width: 160, height: 60)
    }
}

struct ShoulderButtonsViewRight: View {
    var body: some View {
        HStack {
            ButtonView(button: .triggerR)
                .padding(.horizontal)
            ButtonView(button: .triggerZR)
                .padding(.horizontal)
        }
        .frame(width: 160, height: 60)

    }
}

//            Spacer(minLength: 20)
// ButtonView(button: .triggerZR)
// ButtonView(button: .R)

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
    @State var width: CGFloat = 50
    @State var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Image(systemName: buttonText)
            .resizable()
            .frame(width: width, height: 50)
            .foregroundColor(colorScheme == .dark ? Color.gray : Color.gray) // Adjust color based on mode
            .opacity(isPressed ? 0.5 : 1)
            .onAppear() {
                if button == .triggerL || button == .triggerZL || button == .triggerZR || button == .triggerR{
                    width = 65
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !self.isPressed {
                            self.isPressed = true
                            DispatchQueue.main.async {
                                sudachi.virtualControllerButtonDown(button)
                            }
                        }
                    }
                    .onEnded { _ in
                        self.isPressed = false
                        DispatchQueue.main.async {
                            sudachi.virtualControllerButtonUp(button)
                        }
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
        case .triggerZL:
            return "zl.button.roundedtop.horizontal.fill"
        case .triggerZR:
            return "zr.button.roundedtop.horizontal.fill"
        case .triggerL:
            return "l.button.roundedbottom.horizontal.fill"
        case .triggerR:
            return "r.button.roundedbottom.horizontal.fill"
        // Add cases for other button types as needed
        default:
            return ""
        }
    }
}
