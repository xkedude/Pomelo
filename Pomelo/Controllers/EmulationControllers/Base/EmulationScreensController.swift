//
//  EmulationScreensController.swift
//  Pomelo
//
//  Created by Jarrod Norwell on 17/3/2024.
//

import Foundation
import MetalKit
import UIKit

struct ScreenConfiguration {
    static let borderColor: CGColor = UIColor.secondarySystemBackground.cgColor
    static let borderWidth: CGFloat = 3
    static let cornerRadius: CGFloat = 10
}

class EmulationScreensController : EmulationVirtualControllerController {
    var primaryScreen, secondaryScreen: UIView!
    var primaryBlurredScreen, secondaryBlurredScreen: UIView!
    fileprivate var visualEffectView: UIVisualEffectView!
    
    fileprivate let device = MTLCreateSystemDefaultDevice()
    
    fileprivate var fullScreenConstraints: [NSLayoutConstraint]!
    
    fileprivate var portraitConstraints, landscapeConstraints: [NSLayoutConstraint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        visualEffectView = .init(effect: UIBlurEffect(style: .systemMaterial))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        view.addConstraints([
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        switch game {
        case _ as SudachiGame:
            let userDefaults = UserDefaults.standard
            if userDefaults.bool(forKey: "isfullscreen") {
                setupSudachiScreen2()
                print("lmao")
            } else {
                setupSudachiScreen()
                print("beans")
            }
        default:
            fatalError()
        }
        
        if #available(iOS 17, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(traitDidChange))
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "isfullscreen") {
            if UIApplication.shared.statusBarOrientation == .portrait {
                view.removeConstraints(fullScreenConstraints)
                view.addConstraints(portraitConstraints)
            } else {
                view.removeConstraints(fullScreenConstraints)
                view.addConstraints(fullScreenConstraints)
            }
        } else {
            if UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
                view.removeConstraints(landscapeConstraints)
                view.addConstraints(portraitConstraints)
            } else {
                view.removeConstraints(portraitConstraints)
                view.addConstraints(landscapeConstraints)
            }
        }
        
        coordinator.animate { _ in
            self.virtualControllerView.layout()
            self.view.layoutIfNeeded()
        }
    }
    
    func setupSudachiScreen2() {
        primaryScreen = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        primaryScreen.layer.borderColor = nil
        primaryScreen.layer.borderWidth = ScreenConfiguration.borderWidth
        primaryScreen.layer.cornerCurve = .continuous
        primaryScreen.layer.cornerRadius = ScreenConfiguration.cornerRadius
        view.addSubview(primaryScreen)

        primaryBlurredScreen = UIImageView(frame: .zero)
        primaryBlurredScreen.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(primaryBlurredScreen)

        view.insertSubview(primaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(visualEffectView, belowSubview: primaryScreen)
        view.insertSubview(primaryBlurredScreen, belowSubview: visualEffectView)

        fullScreenConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.topAnchor),
            primaryScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            primaryScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            primaryScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        portraitConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            primaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 9 / 16),
        ]
        
        view.addConstraints(fullScreenConstraints)
    }
    
    func setupSudachiScreen() {
        primaryScreen = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        primaryScreen.layer.borderColor = ScreenConfiguration.borderColor
        primaryScreen.layer.borderWidth = ScreenConfiguration.borderWidth
        primaryScreen.layer.cornerCurve = .continuous
        primaryScreen.layer.cornerRadius = ScreenConfiguration.cornerRadius
        view.addSubview(primaryScreen)
        
        primaryBlurredScreen = UIImageView(frame: .zero)
        primaryBlurredScreen.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(primaryBlurredScreen)
        
        view.insertSubview(primaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(visualEffectView, belowSubview: primaryScreen)
        view.insertSubview(primaryBlurredScreen, belowSubview: visualEffectView)
        
        portraitConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            primaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 9 / 16),
            
            primaryBlurredScreen.topAnchor.constraint(equalTo: view.topAnchor),
            primaryBlurredScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            primaryBlurredScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            primaryBlurredScreen.bottomAnchor.constraint(equalTo: primaryScreen.bottomAnchor, constant: 10)
        ]
        
        landscapeConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            primaryScreen.widthAnchor.constraint(equalTo: primaryScreen.heightAnchor, multiplier: 16 / 9),
            primaryScreen.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            primaryBlurredScreen.topAnchor.constraint(equalTo: view.topAnchor),
            primaryBlurredScreen.leadingAnchor.constraint(equalTo: primaryScreen.leadingAnchor, constant: -10),
            primaryBlurredScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            primaryBlurredScreen.trailingAnchor.constraint(equalTo: primaryScreen.trailingAnchor, constant: 10)
        ]
        
        view.addConstraints(UIApplication.shared.statusBarOrientation == .portrait ||
                            UIApplication.shared.statusBarOrientation == .portraitUpsideDown ? portraitConstraints : landscapeConstraints)
    }
    
    @objc fileprivate func traitDidChange() {
        primaryScreen.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        switch game {
        default:
            break
        }
    }
    
    func cgImage(from screenFramebuffer: UnsafeMutablePointer<UInt32>, width: Int, height: Int) -> CGImage? {
        var imageRef: CGImage?
        
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(.byteOrderDefault)
        guard let providerRef = CGDataProvider(dataInfo: nil, data: screenFramebuffer, size: totalBytes,
                                               releaseData: {_,_,_  in}) else {
            return nil
        }
        
        imageRef = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel,
                           bytesPerRow: bytesPerRow, space: colorSpaceRef, bitmapInfo: bitmapInfo, provider: providerRef,
                           decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        
        return imageRef
    }
}
