//
//  SudachiEmulationController.swift
//  Pomelo
//
//  Created by Jarrod Norwell on 8/3/2024.
//

#if canImport(Sudachi)

import Sudachi
import Foundation
import GameController
import MetalKit.MTKView
import UIKit
import SwiftUI

class SudachiEmulationController : EmulationScreensController {
    fileprivate var thread: Thread!
    fileprivate var isRunning: Bool = false
    
    fileprivate var PomeloGame: PomeloGame!
    fileprivate let sudachi = Sudachi.shared
    override init(game: AnyHashable) {
        super.init(game: game)
        guard let game = game as? PomeloGame else {
            return
        }
        
        PomeloGame = game
        
        thread = .init(block: step)
        thread.name = "Pomelo"
        thread.qualityOfService = .userInteractive
        thread.threadPriority = 0.9
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        

        if userDefaults.bool(forKey: "exitgame") {
            customButton.addTarget(self, action: #selector(customButtonTapped), for: .touchUpInside)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isRunning {
            isRunning = true
            guard let primaryScreen = primaryScreen as? MTKView else {
                return
            }
            
            sudachi.configure(layer: primaryScreen.layer as! CAMetalLayer, with: primaryScreen.frame.size)
            if PomeloGame.title.isEmpty || PomeloGame.id.uuidString.isEmpty || PomeloGame.developer.isEmpty {
                sudachi.bootOS()
            } else {
                print("100% real game title: \(PomeloGame.title) fileurl: \(PomeloGame.fileURL) author: \(PomeloGame.developer) ieEmptytitle: \(PomeloGame.title.isEmpty)")
                sudachi.insert(game: PomeloGame.fileURL)
            }
            
            thread.start()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            let userDefaults = UserDefaults.standard
            if !userDefaults.bool(forKey: "isfullscreen") {
                self.sudachi.orientationChanged(orientation: UIApplication.shared.statusBarOrientation, with: self.primaryScreen.layer as! CAMetalLayer,
                                                size: self.primaryScreen.frame.size)
            }
        }
    }
    
    @objc func customButtonTapped() {
        stopEmulation()
    }
    func stopEmulation() {
        if isRunning {
            self.dismiss(animated: true)
            isRunning = false
            // sudachi.bootOS1()
            thread.cancel()
        }
    }
    
    @objc fileprivate func step() {
        while true {
            sudachi.step()
        }
    }
    
    // MARK: Touch Delegates
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        func position(in view: UIView, with location: CGPoint) -> (x: Float, y: Float) {
            let radius = view.frame.width / 2
            return (Float((location.x - radius) / radius), Float(-(location.y - radius) / radius))
        }
        
        switch touch.view {
        case virtualControllerView.dpadView:
            sudachi.thumbstickMoved(.left, x: position(in: virtualControllerView.dpadView,
                                                       with: touch.location(in: virtualControllerView.dpadView)).x,
                                    y: position(in: virtualControllerView.dpadView, with: touch.location(in: virtualControllerView.dpadView)).y)
        case virtualControllerView.xybaView:
            sudachi.thumbstickMoved(.right, x: position(in: virtualControllerView.xybaView,
                                                        with: touch.location(in: virtualControllerView.xybaView)).x,
                                    y: position(in: virtualControllerView.xybaView, with: touch.location(in: virtualControllerView.xybaView)).y)
        case primaryScreen:
            print("Tap location: \(touch.location(in: primaryScreen))")
            sudachi.touchBegan(at: touch.location(in: primaryScreen), for: 0)
        default:
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        switch touch.view {
        case virtualControllerView.dpadView:
            sudachi.thumbstickMoved(.left, x: 0, y: 0)
        case virtualControllerView.xybaView:
            sudachi.thumbstickMoved(.right, x: 0, y: 0)
        case primaryScreen:
            print("Tap location let go")
            sudachi.touchEnded(for: 0)
        default:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        func position(in view: UIView, with location: CGPoint) -> (x: Float, y: Float) {
            let radius = view.frame.width / 2
            return (Float((location.x - radius) / radius), Float(-(location.y - radius) / radius))
        }
        
        switch touch.view {
        case virtualControllerView.dpadView:
            sudachi.thumbstickMoved(.left, x: position(in: virtualControllerView.dpadView,
                                                       with: touch.location(in: virtualControllerView.dpadView)).x,
                                    y: position(in: virtualControllerView.dpadView, with: touch.location(in: virtualControllerView.dpadView)).y)
        case virtualControllerView.xybaView:
            sudachi.thumbstickMoved(.right, x: position(in: virtualControllerView.xybaView,
                                                        with: touch.location(in: virtualControllerView.xybaView)).x,
                                    y: position(in: virtualControllerView.xybaView, with: touch.location(in: virtualControllerView.xybaView)).y)
        case primaryScreen:
            print("Tap location moved: \(touch.location(in: primaryScreen))")
            sudachi.touchMoved(at: touch.location(in: primaryScreen), for: 0)
        default:
            break
        }
    }
    
    
    // MARK: Physical Controller Delegates
    override func controllerDidConnect(_ notification: Notification) {
        super.controllerDidConnect(notification)
        guard let controller = notification.object as? GCController, let extendedGamepad = controller.extendedGamepad else {
            return
        }
        
        extendedGamepad.dpad.up.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadUp) : self.touchUpInside(.dpadUp)
        }
        
        extendedGamepad.dpad.down.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadDown) : self.touchUpInside(.dpadDown)
        }
        
        extendedGamepad.dpad.left.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadLeft) : self.touchUpInside(.dpadLeft)
        }
        
        extendedGamepad.dpad.right.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadRight) : self.touchUpInside(.dpadRight)
        }
        
        extendedGamepad.buttonOptions?.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.minus) : self.touchUpInside(.minus)
        }
        
        extendedGamepad.buttonMenu.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.plus) : self.touchUpInside(.plus)
        }
        
        extendedGamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.a) : self.touchUpInside(.a)
        }
        
        extendedGamepad.buttonB.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.b) : self.touchUpInside(.b)
        }
        
        extendedGamepad.buttonX.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.x) : self.touchUpInside(.x)
        }
        
        extendedGamepad.buttonY.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.y) : self.touchUpInside(.y)
        }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.l) : self.touchUpInside(.l)
        }
        
        extendedGamepad.leftTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.zl) : self.touchUpInside(.zl)
        }
        
        extendedGamepad.rightShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.r) : self.touchUpInside(.r)
        }
        
        extendedGamepad.rightTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.zr) : self.touchUpInside(.zr)
        }
        
        extendedGamepad.leftThumbstick.valueChangedHandler = { dpad, x, y in
            self.sudachi.thumbstickMoved(.left, x: x, y: y)
        }
        
        extendedGamepad.rightThumbstick.valueChangedHandler = { dpad, x, y in
            self.sudachi.thumbstickMoved(.right, x: x, y: y)
        }
    }
    
    // MARK: Virtual Controller Delegates
    override func touchDown(_ buttonType: VirtualControllerButton.ButtonType) {
        super.touchDown(buttonType)
        switch buttonType {
        case .dpadUp:
            sudachi.virtualControllerButtonDown(.directionalPadUp)
        case .dpadDown:
            sudachi.virtualControllerButtonDown(.directionalPadDown)
        case .dpadLeft:
            sudachi.virtualControllerButtonDown(.directionalPadLeft)
        case .dpadRight:
            sudachi.virtualControllerButtonDown(.directionalPadRight)
        case .minus:
            sudachi.virtualControllerButtonDown(.minus)
        case .plus:
            sudachi.virtualControllerButtonDown(.plus)
        case .a:
            sudachi.virtualControllerButtonDown(.A)
        case .b:
            sudachi.virtualControllerButtonDown(.B)
        case .x:
            sudachi.virtualControllerButtonDown(.X)
        case .y:
            sudachi.virtualControllerButtonDown(.Y)
        case .l:
            sudachi.virtualControllerButtonDown(.triggerL)
        case .zl:
            sudachi.virtualControllerButtonDown(.triggerZL)
        case .r:
            sudachi.virtualControllerButtonDown(.triggerR)
        case .zr:
            sudachi.virtualControllerButtonDown(.triggerZR)
        }
    }
    
    override func touchUpInside(_ buttonType: VirtualControllerButton.ButtonType) {
        super.touchUpInside(buttonType)
        switch buttonType {
        case .dpadUp:
            sudachi.virtualControllerButtonUp(.directionalPadUp)
        case .dpadDown:
            sudachi.virtualControllerButtonUp(.directionalPadDown)
        case .dpadLeft:
            sudachi.virtualControllerButtonUp(.directionalPadLeft)
        case .dpadRight:
            sudachi.virtualControllerButtonUp(.directionalPadRight)
        case .minus:
            sudachi.virtualControllerButtonUp(.minus)
        case .plus:
            sudachi.virtualControllerButtonUp(.plus)
        case .a:
            sudachi.virtualControllerButtonUp(.A)
        case .b:
            sudachi.virtualControllerButtonUp(.B)
        case .x:
            sudachi.virtualControllerButtonUp(.X)
        case .y:
            sudachi.virtualControllerButtonUp(.Y)
        case .l:
            sudachi.virtualControllerButtonUp(.triggerL)
        case .zl:
            sudachi.virtualControllerButtonUp(.triggerZL)
        case .r:
            sudachi.virtualControllerButtonUp(.triggerR)
        case .zr:
            sudachi.virtualControllerButtonUp(.triggerZR)
        }
    }
}

struct SudachiEmulationViewController: UIViewControllerRepresentable {
    var game: PomeloGame
    @Binding var shouldStopEmulation: Bool

    func makeUIViewController(context: Context) -> SudachiEmulationController {
        let controller = SudachiEmulationController(game: game)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }

    func updateUIViewController(_ uiViewController: SudachiEmulationController, context: Context) {
        if shouldStopEmulation {
            uiViewController.stopEmulation()
        }
    }
}


func presentPomeloEmulation(PomeloGame: PomeloGame) {
    let PomeloEmulationController = SudachiEmulationController(game: PomeloGame)
    PomeloEmulationController.modalPresentationStyle = .fullScreen
    
    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")

    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = scene.windows.first,
       let rootViewController = window.rootViewController {
        rootViewController.present(PomeloEmulationController, animated: true, completion: nil)
    }
}


#endif
