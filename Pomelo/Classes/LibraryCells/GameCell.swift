//
//  N3DSDefaultLibraryCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/5/2024.
//

import Foundation
import UIKit

extension UIColor {
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        max(0, min(1, toComponent + value))
    }
    
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return UIColor(red: add(componentDelta, toComponent: red), green: add(componentDelta, toComponent: green),
                       blue: add(componentDelta, toComponent: blue), alpha: alpha)
    }
    
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        makeColor(componentDelta: componentDelta)
    }
        
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        makeColor(componentDelta: -1 * componentDelta)
    }
}


class GradientView : UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    func set(_ color: UIColor, _ locations: [NSNumber]? = nil, _ darker: Bool = true) {
        guard let layer = layer as? CAGradientLayer else {
            return
        }
        
        layer.colors = [color.cgColor, darker ? color.darker().cgColor : color.cgColor]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        layer.locations = locations
    }
    
    func set(_ colors: (UIColor, UIColor), _ locations: [NSNumber]? = nil, _ darker: Bool = true) {
        guard let layer = layer as? CAGradientLayer else {
            return
        }
        
        layer.colors = [colors.0.cgColor, darker ? colors.1.darker().cgColor : colors.1.cgColor]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        layer.locations = locations
    }
}


class N3DSDefaultLibraryCell : UICollectionViewCell {
    var imageView: UIImageView!
    var gradientView: GradientView!
    var headlineLabel, titleLabel: UILabel!
    var optionsButton: UIButton!
    var missingImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tertiarySystemBackground
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        imageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        addSubview(imageView)
        
        missingImageView = .init()
        missingImageView.translatesAutoresizingMaskIntoConstraints = false
        missingImageView.contentMode = .scaleAspectFit
        missingImageView.tintColor = .tertiarySystemBackground
        imageView.addSubview(missingImageView)
        
        gradientView = .init()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(gradientView)
        
        titleLabel = .init()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        gradientView.addSubview(titleLabel)
        
        headlineLabel = .init()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        headlineLabel.textAlignment = .left
        headlineLabel.textColor = .lightText
        gradientView.addSubview(headlineLabel)
        
        var configuration = UIButton.Configuration.tinted()
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .white
        configuration.buttonSize = .mini
        configuration.cornerStyle = .capsule
        configuration.image = .init(systemName: "ellipsis")?
            .applyingSymbolConfiguration(.init(weight: .bold))
        
        optionsButton = .init(configuration: configuration)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.showsMenuAsPrimaryAction = true
        addSubview(optionsButton)
        
        addConstraints([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            missingImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            missingImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            missingImageView.widthAnchor.constraint(equalToConstant: 44),
            missingImageView.heightAnchor.constraint(equalToConstant: 44),
            
            gradientView.topAnchor.constraint(equalTo: imageView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            gradientView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -12),
            
            headlineLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 12),
            headlineLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -4),
            headlineLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -12),
            
            optionsButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            heightAnchor.constraint(equalTo: widthAnchor, multiplier: 3 / 4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        missingImageView.image = nil
    }
    
    func set(_ text: String, _ secondaryText: String) {
        titleLabel.attributedText = .init(string: text, attributes: [
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize),
            .foregroundColor : UIColor.white
        ])
        headlineLabel.attributedText = .init(string: secondaryText, attributes: [
            .font : UIFont.preferredFont(forTextStyle: .headline),
            .foregroundColor : UIColor.lightText
        ])
    }
}
