//
//  SudachiEmulationView.swift
//  Pomelo-V2
//
//  Created by Stossy11 on 16/7/2024.
//

import SwiftUI
import Sudachi
import Foundation
import GameController
import UIKit
import SwiftUIIntrospect


struct SudachiEmulationView: View {
    @StateObject private var viewModel: SudachiEmulationViewModel
    @State var controllerconnected = false
    @State var sudachi = Sudachi.shared
    var device: MTLDevice? = MTLCreateSystemDefaultDevice()
    @State var CaLayer: CAMetalLayer?
    @State var mtkview: MTKView?
    @State private var thread: Thread!
    @State var uiTabBarController: UITabBarController?
    
    init(game: PomeloGame?) {
        _viewModel = StateObject(wrappedValue: SudachiEmulationViewModel(game: game))
    }

    
    var body: some View {
        ZStack {
            MetalView(device: device) { view in
                DispatchQueue.main.async {
                    if let metalView = view as? MTKView {
                        mtkview = metalView
                        viewModel.configureMTKView(metalView)

                    } else {
                        print("Error: view is not of type MTKView")
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            ControllerView()
        }
        .onRotate { size in
            viewModel.handleOrientationChange(size: size)
        }
        .introspect(.tabView, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { (tabBarController) in
            tabBarController.tabBar.isHidden = true
            uiTabBarController = tabBarController
        }
        .onDisappear {
            uiTabBarController?.tabBar.isHidden = false
            viewModel.customButtonTapped()
        }
        .onAppear {
            print("checking for controller:")
        }
    }
}


extension View {
    func onRotate(perform action: @escaping (CGSize) -> Void) -> some View {
        self.modifier(DeviceRotationModifier(action: action))
    }
}



struct DeviceRotationModifier: ViewModifier {
    let action: (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            })
            .onPreferenceChange(SizePreferenceKey.self) { newSize in
                action(newSize)
            }
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
