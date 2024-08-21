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
    @State var ShowPopup: Bool = false
    @State var mtkview: MTKView?
    @State private var thread: Thread!
    @State var uiTabBarController: UITabBarController?
    @State private var isFirstFrameShown = false
    @State private var timer: Timer?
    @AppStorage("isairplay") private var isairplay: Bool = true
    
    init(game: PomeloGame?) {
        _viewModel = StateObject(wrappedValue: SudachiEmulationViewModel(game: game))
    }

    var body: some View {
        ZStack {
            if !isairplay {
                MetalView(device: device) { view in
                    DispatchQueue.main.async {
                        if let metalView = view as? MTKView {
                            mtkview = metalView
                            viewModel.configureSudachi(with: metalView)
                        } else {
                            print("Error: view is not of type MTKView")
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    // Loading screen overlay on top of MetalView
                    Group {
                        if !isFirstFrameShown && !isairplay {
                            LoadingView()
                        }
                    }
                        .transition(.opacity)
                )
            }
            ControllerView()
        }
        .onAppear {
            
            print("AirPlay + \(Air.shared.connected)")
            
            isairplay = Air.shared.connected
            DispatchQueue.main.async {
                Air.connection({ fun in
                    print("AirPlay + \(fun)")
                    isairplay = fun
                })
                
                if isairplay {
                    Air.play(AnyView(
                    MetalView(device: device) { view in
                        DispatchQueue.main.async {
                            if let metalView = view as? MTKView {
                                mtkview = metalView
                                viewModel.configureSudachi(with: metalView)
                            } else {
                                print("Error: view is not of type MTKView")
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                    )
                    )

                }
            }
            
            if !isairplay {
                startPollingFirstFrameShowed()
            }
        }
        .onDisappear {
            if !isairplay {
                stopPollingFirstFrameShowed()
            }
            uiTabBarController?.tabBar.isHidden = false
            viewModel.customButtonTapped()
        }
        .navigationBarBackButtonHidden(true)
        .background(AlertController(isPresented: viewModel.$should))
        .onRotate { size in
            if sudachi.FirstFrameShowed() && !isairplay {
                viewModel.handleOrientationChange(size: size)
            }
        }
        .introspect(.tabView, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { (tabBarController) in
            tabBarController.tabBar.isHidden = true
            uiTabBarController = tabBarController
        }
    }
    
    private func startPollingFirstFrameShowed() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if sudachi.FirstFrameShowed() {
                withAnimation {
                    isFirstFrameShown = true
                }
                stopPollingFirstFrameShowed()
            }
        }
    }

    private func stopPollingFirstFrameShowed() {
        timer?.invalidate()
        timer = nil
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            Text("Please wait while the game loads.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
        .foregroundColor(.white)
    }
}
struct AlertController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let alert = UIAlertController(title: "Exiting Emulation", message: "Pomelo currently does not support exiting emulation as it will cause extra crashes", preferredStyle: .alert)

            uiViewController.present(alert, animated: true, completion: nil)
        }
        
        print(isPresented)

        if !isPresented && uiViewController.presentedViewController != nil {
            uiViewController.dismiss(animated: true, completion: nil)
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
