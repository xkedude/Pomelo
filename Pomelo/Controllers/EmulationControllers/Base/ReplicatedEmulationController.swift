//
//  ReplicatedEmulationController.swift
//  Pomelo
//
//  Created by Stossy11 on 5/7/2024.
//

import SwiftUI
import Sudachi
import Metal

struct MTKViewRepresentable: UIViewRepresentable {
    let device: MTLDevice?
    let configure: (MTKView) -> Void
    let touchBegan: (CGPoint) -> Void
    let touchMoved: (CGPoint) -> Void
    let touchEnded: () -> Void

    func makeUIView(context: Context) -> CustomMTKView {
        let mtkView = CustomMTKView(frame: .zero, device: device)
        mtkView.configureCallback = configure
        mtkView.touchBeganCallback = touchBegan
        mtkView.touchMovedCallback = touchMoved
        mtkView.touchEndedCallback = touchEnded
        return mtkView
    }

    func updateUIView(_ uiView: CustomMTKView, context: Context) {
        // Update the view if needed
    }
}


class SudachiEmulationViewModel: ObservableObject {
    @Published var isShowingCustomButton = true
    var device: MTLDevice?
    var CaLayer: CAMetalLayer?
    private var sudachiGame: SudachiGame!
    private let sudachi = Sudachi.shared
    private var thread: Thread!
    private var isRunning = false

    init(game: SudachiGame) {
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
        if sudachiGame.title.isEmpty || sudachiGame.id.uuidString.isEmpty || sudachiGame.developer.isEmpty {
            sudachi.bootOS()
        } else {
            sudachi.insert(game: sudachiGame.fileURL)
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
            sudachi.bootOS1()
            thread.cancel()
        }
    }
    
    
    
    func touchDown(_ buttonType: VirtualControllerButton.ButtonType) {
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
    
    func touchUpInside(_ buttonType: VirtualControllerButton.ButtonType) {
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
    
    // Handle touch events on Metal view
    func handleMetalViewTap(location: CGPoint) {
        sudachi.touchBegan(at: location, for: 1) // Example
    }

    func handleMetalViewDrag(_ location: CGPoint) {
        sudachi.touchMoved(at: location, for: 1) // Example
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


class CustomMTKView: MTKView {
    var touchBeganCallback: ((CGPoint) -> Void)?
    var touchMovedCallback: ((CGPoint) -> Void)?
    var touchEndedCallback: (() -> Void)?
    var configureCallback: ((MTKView) -> Void)?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureCallback?(self)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            touchBeganCallback?(touch.location(in: self))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            touchMovedCallback?(touch.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchEndedCallback?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchEndedCallback?()
    }
}


class SudachiScreenView: UIView {
    var primaryScreen: MTKView!
    var primaryBlurredScreen: UIImageView!
    var portraitConstraints = [NSLayoutConstraint]()
    var landscapeConstraints = [NSLayoutConstraint]()
    let sudachi = Sudachi.shared
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSudachiScreen()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSudachiScreen()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        
        sudachi.touchBegan(at: touch.location(in: primaryScreen), for: 0)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        sudachi.touchEnded(for: 0)
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
        
        sudachi.touchMoved(at: touch.location(in: primaryScreen), for: 0)
    }
    
    
    func setupSudachiScreen() {
        primaryScreen = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        primaryScreen.layer.borderColor = UIColor.red.cgColor // Replace with your color
        primaryScreen.layer.borderWidth = 1.0 // Replace with your width
        primaryScreen.layer.cornerCurve = .continuous
        primaryScreen.layer.cornerRadius = 10.0 // Replace with your radius
        addSubview(primaryScreen)
        
        primaryBlurredScreen = UIImageView(frame: .zero)
        primaryBlurredScreen.translatesAutoresizingMaskIntoConstraints = false
        addSubview(primaryBlurredScreen)
        
        insertSubview(primaryScreen, belowSubview: primaryBlurredScreen)
        
        portraitConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            primaryScreen.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 9 / 16),
        ]
        
        landscapeConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            primaryScreen.widthAnchor.constraint(equalTo: primaryScreen.heightAnchor, multiplier: 16 / 9),
            primaryScreen.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
        ]
        
        updateConstraintsForOrientation()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateConstraintsForOrientation()
    }
    
    private func updateConstraintsForOrientation() {
        removeConstraints(portraitConstraints)
        removeConstraints(landscapeConstraints)
        
        let isPortrait = UIApplication.shared.statusBarOrientation.isPortrait
        addConstraints(isPortrait ? portraitConstraints : landscapeConstraints)
    }
}

struct MTKViewRepresentableNonFullScreen: UIViewRepresentable {
    let device: MTLDevice?
    let configure: (MTKView) -> Void
    
    func makeUIView(context: Context) -> SudachiScreenView {
        let view = SudachiScreenView()
        configure(view.primaryScreen)
        return view
    }
    
    func updateUIView(_ uiView: SudachiScreenView, context: Context) {
        // Update the view if needed
    }
}


struct SudachiEmulationView: View {
    @StateObject private var viewModel: SudachiEmulationViewModel
    let sudachi = Sudachi.shared
    @State var isPressed = false
    @AppStorage("isfullscreen") var isfullscreen = false
    @State var mtkview = MTKView()
    @State var test: CGPoint = CGPoint(x:407.3333333333333, y: 271.3333282470703)
    
    init(game: SudachiGame) {
        _viewModel = StateObject(wrappedValue: SudachiEmulationViewModel(game: game))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !isfullscreen {
                    MTKViewRepresentableNonFullScreen(device: viewModel.device) { mtkView in
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
                } else {
                    MTKViewRepresentable(
                        device: viewModel.device,
                        configure: { mtkView in
                            mtkview = mtkView
                            DispatchQueue.main.async {
                                viewModel.configureMTKView(mtkView)
                            }
                        },
                        touchBegan: { location in
                            print("Tap location: \(location), new loc: \(self.test)")
                            test = location
                            sudachi.touchBegan(at: self.test, for: 0)
                        },
                        touchMoved: { location in
                            print("Tap location moved: \(location)")
                            // sudachi.touchMoved(at: self.test, for: 0)
                        },
                        touchEnded: {
                            print("Tap location let go")
                            sudachi.touchEnded(for: 0)
                        }
                    )
                    /*
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if !self.isPressed {
                                    let tapLocation = value.location
                                    print("Tap location: \(tapLocation)")
                                    sudachi.touchBegan(at: tapLocation, for: 0)
                                    self.isPressed = true
                                } else {
                                    let tapLocation = value.location
                                    print("Tap location moved: \(tapLocation)")
                                    sudachi.touchMoved(at: tapLocation, for: 0)
                                }
                            }
                            .onEnded { value in
                                let tapLocation = value.location
                                print("Tap location let go: \(tapLocation)")
                                sudachi.touchEnded(for: 0)
                                self.isPressed = false
                            }
                    )
                     */
                    .edgesIgnoringSafeArea(.all)
                }

                
                if viewModel.isShowingCustomButton {
                    Button(action: {
                        viewModel.customButtonTapped()
                    }) {
                        Image(systemName: "x.square")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                    }
                    .position(x: geometry.size.width - 60, y: 60)
                }
                FunController(viewModel: viewModel)
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

struct FunController: View {
    @StateObject var viewModel: SudachiEmulationViewModel
    let sudachi = Sudachi.shared
    @State var isPressed = false
    
    var body: some View {
        Circle()
             .frame(width: 200, height: 50)
             .foregroundColor(.secondary)
             .overlay(
                 Text("A")
                     .foregroundColor(.white)
             )
             .gesture(
                 DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !self.isPressed {
                            self.isPressed = true
                            sudachi.virtualControllerButtonUp(.A)
                        }
                    }
                    .onEnded { _ in
                        self.isPressed = false
                        print("Button released")
                        sudachi.virtualControllerButtonDown(.A)
                    }
               )
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
