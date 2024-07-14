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
    @AppStorage("isfullscreen") var isfullscreen = false
    @State var mtkview = MTKView()
    
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
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            
                            if !self.isPressed {
                                let tapLocation = value.location
                                // touch.location(in: primaryScreen) print("Tap location: \(touch.location(in: primaryScreen))")
                                print("Tap location: \(tapLocation)")
                                sudachi.touchBegan(at: value.location, for: 0)
                                self.isPressed = true
                            } else {
                                let tapLocation = value.location
                                print("Tap location moved: \(tapLocation)")
                                sudachi.touchMoved(at: value.location, for: 0)
                            }
                            
                        }
                        .onEnded { value in
                            let tapLocation = value.location
                            print("Tap location let go: \(tapLocation)")
                            sudachi.touchEnded(for: 0)
                            self.isPressed = false
                        }
                )
                .edgesIgnoringSafeArea(.all)
                .onDisappear() {
                    print("crazy you just closed this window holy crap")
                }
                
                ControllerView(viewModel: viewModel)
            }
            .onRotate { newSize in
                DispatchQueue.main.async { [self] in
                    viewModel.handleOrientationChange(size: newSize)
                }
            }
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
