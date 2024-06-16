//
//  BlurredTextButton.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/2/2024.
//

import Foundation
import UIKit

class BlurredTextButton : UIView {
    fileprivate var visualEffectView: UIVisualEffectView!
    fileprivate var textLabel: UILabel!
    
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
        
        textLabel = .init()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.contentView.addSubview(textLabel)
        
        addConstraints([
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            textLabel.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor, constant: 10),
            textLabel.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: 20),
            textLabel.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor, constant: -10),
            textLabel.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor, constant: -20)
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
    
    func set(_ text: String) {
        textLabel.attributedText = .init(string: text, attributes: [
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize),
            .foregroundColor : UIColor.label
        ])
    }
}
