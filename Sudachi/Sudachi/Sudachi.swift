//
//  Sudachi.swift
//  Sudachi
//
//  Created by Jarrod Norwell on 4/3/2024.
//

import Foundation
import QuartzCore.CAMetalLayer

public struct Sudachi {
    
    public static let shared = Sudachi()
    
    fileprivate let sudachiObjC = SudachiObjC.shared()
    
    public func configure(layer: CAMetalLayer, with size: CGSize) {
        sudachiObjC.configure(layer: layer, with: size)
    }
    
    public func information(for url: URL) -> SudachiInformation {
        sudachiObjC.gameInformation.information(for: url)
    }
    
    public func insert(game url: URL) {
        sudachiObjC.insert(game: url)
    }
    
    public func insert(games urls: [URL]) {
        sudachiObjC.insert(games: urls)
    }
    
    public func bootOS() {
        sudachiObjC.bootOS()
    }
    
    public func pause() {
        sudachiObjC.pause()
    }
    
    public func play() {
        sudachiObjC.play()
    }
    
    public func togglepause() {
        if sudachiObjC.ispaused() {
            sudachiObjC.play()
        } else {
            sudachiObjC.pause()
        }
    }
    
    public func ispaused() -> Bool {
        return sudachiObjC.ispaused()
    }
    
    public func FirstFrameShowed() -> Bool {
        return sudachiObjC.hasfirstfame()
    }
    
    public func canGetFullPath() -> Bool {
        return sudachiObjC.canGetFullPath()
    }
    
    
    public func exit() {
        sudachiObjC.quit()
    }
    
    public func step() {
        sudachiObjC.step()
    }
    
    public func orientationChanged(orientation: UIInterfaceOrientation, with layer: CAMetalLayer, size: CGSize) {
        sudachiObjC.orientationChanged(orientation: orientation, with: layer, size: size)
    }
    
    public func touchBegan(at point: CGPoint, for index: UInt) {
        sudachiObjC.touchBegan(at: point, for: index)
    }
    
    public func touchEnded(for index: UInt) {
        sudachiObjC.touchEnded(for: index)
    }
    
    public func touchMoved(at point: CGPoint, for index: UInt) {
        sudachiObjC.touchMoved(at: point, for: index)
    }
    
    public func thumbstickMoved(_ analog: VirtualControllerAnalogType, x: Float, y: Float) {
        sudachiObjC.thumbstickMoved(analog, x: CGFloat(x), y: CGFloat(y))
    }
    
    public func virtualControllerButtonDown(_ button: VirtualControllerButtonType) {
        sudachiObjC.virtualControllerButtonDown(button)
    }
    
    public func virtualControllerButtonUp(_ button: VirtualControllerButtonType) {
        sudachiObjC.virtualControllerButtonUp(button)
    }
    
    public func settingsSaved() {
        sudachiObjC.settingsChanged()
    }
}
