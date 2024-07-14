//
//  BlurredImageButton.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/2/2024.
//

import Foundation
import UIKit

class BlurredImageButton : UIView {
    fileprivate var visualEffectView: UIVisualEffectView!
    var imageView: UIImageView!
    
    var actionHandler: () -> Void
    init(with actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
        super.init(frame: .zero)
        clipsToBounds = true
        layer.borderColor = UIColor.secondaryLabel.cgColor
        layer.borderWidth = 2
        layer.cornerCurve = .continuous
        
        visualEffectView = .init(effect: UIBlurEffect(style: .systemChromeMaterial))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        
        imageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.contentView.addSubview(imageView)
        
        addConstraints([
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: 20),
            imageView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor, constant: -10),
            imageView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor, constant: -20)
        ])
        
        if #available(iOS 17, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self.self], action: #selector(traitChange))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        actionHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.secondaryLabel.cgColor
    }
    
    @objc fileprivate func traitChange() {
        layer.borderColor = UIColor.secondaryLabel.cgColor
    }
    
    func set(_ systemName: String, _ foregroundColor: UIColor) {
        imageView.image = .init(systemName: systemName)?
            .applyingSymbolConfiguration(.init(scale: .large))
        imageView.tintColor = foregroundColor
    }
}
