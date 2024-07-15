//
//  SudachiEmuView.swift
//  Pomelo
//
//  Created by Stossy11 on 14/7/2024.
//

import SwiftUI
import Sudachi
import Metal

struct SudachiEmulationView: View {
    @StateObject private var viewModel: SudachiEmulationViewModel
    let sudachi = Sudachi.shared
    @State var isPressed = false
    @State var mtkview = MTKView()
    @State private var isBackButtonTapped = false
    
    init(game: SudachiGame?) {
        _viewModel = StateObject(wrappedValue: SudachiEmulationViewModel(game: game))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MTKViewRepresentable(device: viewModel.device) { mtkView in
                    DispatchQueue.main.async { [self] in
                        mtkview = mtkView
                        viewModel.configureMTKView(mtkView)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                ControllerView(viewModel: viewModel)
            }
            .onRotate { newSize in
                DispatchQueue.main.async { [self] in
                    viewModel.handleOrientationChange(size: newSize)
                }
            }
        }
        .onDisappear {
            if isBackButtonTapped {
                print("Back button was tapped")
            } else {
                print("Back button was tapped")
            }
            
            viewModel.customButtonTapped()
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
