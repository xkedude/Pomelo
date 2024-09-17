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
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !controllerconnected {
                    OnScreenController(geometry: geometry) // i did this to clean it up as it was quite long lmfao
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
    
    // Add a dictionary to track controller IDs
    @State var controllerIDs: [GCController: Int] = [:]

    private func setupControllers() {
        NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { notification in
            if let controller = notification.object as? GCController {
                print("wow controller onstart") // yippeeee
                self.setupController(controller)
                self.controllerconnected = true
            } else {
                print("not GCController :((((((") // wahhhhhhh
            }
        }
        
        
        NotificationCenter.default.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { notification in
            if let controller = notification.object as? GCController {
                print("wow controller gone")
                if self.controllerIDs.isEmpty {
                    controllerconnected = false
                }
                self.controllerIDs.removeValue(forKey: controller) // Remove the controller ID
            }
        }
        
        GCController.controllers().forEach { controller in
            print("wow controller")
            self.controllerconnected = true
            self.setupController(controller)
        }
    }

    private func setupController(_ controller: GCController) {
        // Assign a unique ID to the controller, max 5 controllers
        if controllerIDs.count < 6, controllerIDs[controller] == nil {
            controllerIDs[controller] = controllerIDs.count
        }
        
        guard let controllerId = controllerIDs[controller] else { return }
        
        let extendedGamepad = controller.extendedGamepad!
        
        
        extendedGamepad.dpad.up.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.directionalPadUp, controllerId: controllerId) : self.touchUpInside(.directionalPadUp, controllerId: controllerId)
        }
        
        extendedGamepad.dpad.down.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.directionalPadDown, controllerId: controllerId) : self.touchUpInside(.directionalPadDown, controllerId: controllerId)
        }
        
        extendedGamepad.dpad.left.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.directionalPadLeft, controllerId: controllerId) : self.touchUpInside(.directionalPadLeft, controllerId: controllerId)
        }
        
        extendedGamepad.dpad.right.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.directionalPadRight, controllerId: controllerId) : self.touchUpInside(.directionalPadRight, controllerId: controllerId)
        }
        
        extendedGamepad.buttonOptions?.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.minus, controllerId: controllerId) : self.touchUpInside(.minus, controllerId: controllerId)
        }
        
        extendedGamepad.buttonMenu.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.plus, controllerId: controllerId) : self.touchUpInside(.plus, controllerId: controllerId)
        }
        
        extendedGamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.A, controllerId: controllerId) : self.touchUpInside(.A, controllerId: controllerId)
        }
        
        extendedGamepad.buttonB.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.B, controllerId: controllerId) : self.touchUpInside(.B, controllerId: controllerId)
        }
        
        extendedGamepad.buttonX.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.X, controllerId: controllerId) : self.touchUpInside(.X, controllerId: controllerId)
        }
        
        extendedGamepad.buttonY.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.Y, controllerId: controllerId) : self.touchUpInside(.Y, controllerId: controllerId)
        }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.triggerL, controllerId: controllerId) : self.touchUpInside(.L, controllerId: controllerId)
        }
        
        extendedGamepad.leftTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.triggerZL, controllerId: controllerId) : self.touchUpInside(.triggerZL, controllerId: controllerId)
        }
        
        extendedGamepad.rightShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.triggerR, controllerId: controllerId) : self.touchUpInside(.triggerR, controllerId: controllerId)
        }
        
        extendedGamepad.rightTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.triggerZR, controllerId: controllerId) : self.touchUpInside(.triggerZR, controllerId: controllerId)
        }
        
        extendedGamepad.buttonHome?.pressedChangedHandler = { button, value, pressed in
            if pressed {
                sudachi.exit()
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        extendedGamepad.leftThumbstick.valueChangedHandler = { dpad, x, y in
            self.sudachi.thumbstickMoved(analog: .left, x: x, y: y, controllerid: controllerId)
        }
        
        extendedGamepad.rightThumbstick.valueChangedHandler = { dpad, x, y in
            self.sudachi.thumbstickMoved(analog: .right, x: x, y: y, controllerid: controllerId)
        }
    }

    private func touchDown(_ button: VirtualControllerButtonType, controllerId: Int) {
        sudachi.virtualControllerButtonDown(button: button, controllerid: controllerId)    }

    private func touchUpInside(_ button: VirtualControllerButtonType, controllerId: Int) {
        sudachi.virtualControllerButtonUp(button: button, controllerid: controllerId)
    }
}

struct OnScreenController: View {
    @State var geometry: GeometryProxy
    var body: some View {
        if geometry.size.height > geometry.size.width && UIDevice.current.userInterfaceIdiom != .pad {
            // portrait
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
                        VStack {
                            ShoulderButtonsViewRight()
                            ZStack {
                                JoystickViewSwiftUI(iscool: true) // hope this works
                                ABXYView()
                            }
                        }
                    }
                    
                    HStack {
                        ButtonView(button: .plus) // Adding the + button
                            .padding(.horizontal)
                        ButtonView(button: .minus) // Adding the - button
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, geometry.size.height / 4.2) // very broken
            }
        } else {
            // could be landscape
            VStack {
                HStack {
                    Spacer()
                    ButtonView(button: .home)
                        .padding(.horizontal)
                }
                Spacer()
                VStack {
                    HStack {
                        
                        // gotta fuckin add + and - now
                        VStack {
                            ShoulderButtonsViewLeft()
                            ZStack {
                                JoystickViewSwiftUI()
                                DPadView()
                            }
                        }
                        HStack {
                            VStack {
                                Spacer()
                                ButtonView(button: .plus) // Adding the + button
                            }
                            Spacer()
                            VStack {
                                Spacer()
                                ButtonView(button: .minus) // Adding the - button
                            }
                        }
                        VStack {
                            ShoulderButtonsViewRight()
                            ZStack {
                                JoystickViewSwiftUI(iscool: true) // hope this work s
                                ABXYView()
                            }
                        }
                    }
                    
                }
                .padding(.bottom, geometry.size.height / 3.2) // also extremally broken (
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
                .padding(.horizontal)
        }
        .frame(width: 160, height: 170)
    }
}

struct ButtonView: View {
    var button: VirtualControllerButtonType
    @StateObject private var viewModel: SudachiEmulationViewModel = SudachiEmulationViewModel(game: nil)
    let sudachi = Sudachi.shared
    @State var mtkView: MTKView?
    @State var width: CGFloat = 50
    @State var height: CGFloat = 50
    @State var isPressed = false
    var id: Int {
        if onscreenjoy {
            return 8
        }
        return 0
    }
    @AppStorage("onscreenhandheld") var onscreenjoy: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        Image(systemName: buttonText)
            .resizable()
            .frame(width: width, height: height)
            .foregroundColor(colorScheme == .dark ? Color.gray : Color.gray)
            .opacity(isPressed ? 0.5 : 1)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !self.isPressed {
                            self.isPressed = true
                            DispatchQueue.main.async {
                                if button == .home {
                                    presentationMode.wrappedValue.dismiss()
                                    sudachi.exit()
                                } else {
                                    sudachi.virtualControllerButtonDown(button: button, controllerid: id)
                                    Haptics.shared.play(.heavy)
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        self.isPressed = false
                        DispatchQueue.main.async {
                            if button != .home {
                                sudachi.virtualControllerButtonUp(button: button, controllerid: id)
                            }
                        }
                    }
            )
            .onAppear() {
                if button == .triggerL || button == .triggerZL || button == .triggerZR || button == .triggerR {
                    width = 65
                }
            
                
                if button == .minus || button == .plus || button == .home {
                    width = 45
                    height = 45
                }
            }
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
        case .plus:
            return "plus.circle.fill" // System symbol for +
        case .minus:
            return "minus.circle.fill" // System symbol for -
        case .home:
            return "house.circle.fill"
        // This should be all the cases
        default:
            return ""
        }
    }
}


