//
//  SudachiEmulationHandler.swift
//  Pomelo
//
//  Created by Stossy11 on 22/7/2024.
//

import SwiftUI
import Sudachi
import Metal
import Foundation

class SudachiEmulationViewModel: ObservableObject {
    @Published var isShowingCustomButton = true
    @State var should = false
    var device: MTLDevice?
    var CaLayer: CAMetalLayer?
    private var sudachiGame: PomeloGame?
    private let sudachi = Sudachi.shared
    private var thread: Thread!
    private var isRunning = false
    var doesneedresources = false

    init(game: PomeloGame?) {
        self.device = MTLCreateSystemDefaultDevice()
        self.sudachiGame = game
    }

    func configureMTKView(_ mtkView: MTKView) {
        mtkView.device = device
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.clipsToBounds = true
        mtkView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        mtkView.layer.borderWidth = 3
        mtkView.layer.cornerCurve = .continuous
        mtkView.layer.cornerRadius = 10
        configureSudachi(with: mtkView)
    }

    private func configureSudachi(with mtkView: MTKView) {
        guard !isRunning else { return }
        isRunning = true
        sudachi.configure(layer: mtkView.layer as! CAMetalLayer, with: mtkView.frame.size)
        
        if let sudachiGame = sudachiGame {
            sudachi.insert(game: sudachiGame.fileURL)
        } else {
            sudachi.bootOS()
        }
        
        do {
            CaLayer = mtkView.layer as? CAMetalLayer
        }

        thread = Thread { [weak self] in self?.step() }
        thread.name = "Pomelo"
        thread.qualityOfService = .userInteractive
        thread.threadPriority = 0.9
        thread.start()
    }

    private func step() {
        while true {
            sudachi.step()
        }
    }

    func customButtonTapped() {
        stopEmulation()
    }

    private func stopEmulation() {
        if isRunning {
            isRunning = false
            sudachi.exit()
            thread.cancel()
        }
    }
    
    func handleOrientationChange(size: CGSize) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let interfaceOrientation = self.getInterfaceOrientation(from: UIDevice.current.orientation)
            self.sudachi.orientationChanged(orientation: interfaceOrientation, with: self.CaLayer!, size: size)
        }
    }

    private func getInterfaceOrientation(from deviceOrientation: UIDeviceOrientation) -> UIInterfaceOrientation {
        switch deviceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .unknown
        }
    }
}
