//
//  SudachiScreenView.swift
//  Pomelo
//
//  Created by Stossy11 on 14/7/2024.
//

import SwiftUI
import Sudachi
import MetalKit

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
        
        print("Location: \(touch.location(in: primaryScreen))")
        sudachi.touchBegan(at: touch.location(in: primaryScreen), for: 0)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("Touch Ended")
        sudachi.touchEnded(for: 0)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: primaryScreen)
        print("Location Moved: \(location)")
        sudachi.touchMoved(at: location, for: 0)
    }
    
    
    func setupSudachiScreen() {
        primaryScreen = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        primaryScreen.layer.borderColor = UIColor.gray.cgColor // Replace with your color
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

