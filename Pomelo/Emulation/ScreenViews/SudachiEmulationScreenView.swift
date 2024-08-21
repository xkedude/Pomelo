//
//  SudachiEmulationScreenView.swift
//  Pomelo-V2
//
//  Created by Stossy11 on 16/7/2024.
//

import SwiftUI
import Sudachi
import MetalKit

class SudachiScreenView: UIView {
    var primaryScreen: UIView!
    var portraitconstraints = [NSLayoutConstraint]()
    var landscapeconstraints = [NSLayoutConstraint]()
    var fullscreenconstraints = [NSLayoutConstraint]()
    let sudachi = Sudachi.shared
    let userDefaults = UserDefaults.standard
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if userDefaults.bool(forKey: "isfullscreen") {
            setupSudachiScreen2()
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            setupSudachiScreenforiPad()
        } else {
            setupSudachiScreen()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if userDefaults.bool(forKey: "isfullscreen") {
            setupSudachiScreen2()
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            setupSudachiScreenforiPad()
        } else {
            setupSudachiScreen()
        }
        
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
    
    func setupSudachiScreen2() {
        primaryScreen = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        addSubview(primaryScreen)

        fullscreenconstraints = [
            primaryScreen.topAnchor.constraint(equalTo: topAnchor),
            primaryScreen.leadingAnchor.constraint(equalTo: leadingAnchor),
            primaryScreen.trailingAnchor.constraint(equalTo: trailingAnchor),
            primaryScreen.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        addConstraints(fullscreenconstraints)
    }
    
    func setupSudachiScreenforiPad() {
        primaryScreen = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        primaryScreen.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        primaryScreen.layer.borderWidth = 3
        primaryScreen.layer.cornerCurve = .continuous
        primaryScreen.layer.cornerRadius = 10
        addSubview(primaryScreen)
        
        
        portraitconstraints = [
            primaryScreen.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            primaryScreen.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 9 / 16),
        ]
        
        landscapeconstraints = [
            primaryScreen.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
            primaryScreen.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -95),
            primaryScreen.widthAnchor.constraint(equalTo: primaryScreen.heightAnchor, multiplier: 16 / 9),
            primaryScreen.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
        ]
        
        updateConstraintsForOrientation()
    }
    
    
    
    func setupSudachiScreen() {
        primaryScreen = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        primaryScreen.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        primaryScreen.layer.borderWidth = 3
        primaryScreen.layer.cornerCurve = .continuous
        primaryScreen.layer.cornerRadius = 10
        addSubview(primaryScreen)
        
        
        portraitconstraints = [
            primaryScreen.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            primaryScreen.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 9 / 16),
        ]
        
        landscapeconstraints = [
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
        
        if userDefaults.bool(forKey: "isfullscreen") {
            removeConstraints(portraitconstraints)
            removeConstraints(landscapeconstraints)
            removeConstraints(fullscreenconstraints)
            addConstraints(fullscreenconstraints)
        } else {
            removeConstraints(portraitconstraints)
            removeConstraints(landscapeconstraints)
            
            let isPortrait = UIApplication.shared.statusBarOrientation.isPortrait
            addConstraints(isPortrait ? portraitconstraints : landscapeconstraints)
        }
    }
}
