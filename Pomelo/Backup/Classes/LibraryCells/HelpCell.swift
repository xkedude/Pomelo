//
//  HelpCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 20/3/2024.
//

import Foundation
import UIKit

class HelpCell : UICollectionViewCell {
    fileprivate var textLabel, secondaryTextLabel, tertiaryTextLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        textLabel = .init()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
        textLabel.textAlignment = .left
        textLabel.textColor = .label
        addSubview(textLabel)
        
        secondaryTextLabel = .init()
        secondaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryTextLabel.font = .preferredFont(forTextStyle: .body)
        secondaryTextLabel.numberOfLines = 3
        secondaryTextLabel.textAlignment = .left
        secondaryTextLabel.textColor = .secondaryLabel
        addSubview(secondaryTextLabel)
        
        tertiaryTextLabel = .init()
        tertiaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        tertiaryTextLabel.font = .preferredFont(forTextStyle: .footnote)
        tertiaryTextLabel.textAlignment = .left
        tertiaryTextLabel.textColor = .tertiaryLabel
        addSubview(tertiaryTextLabel)
        
        addConstraints([
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            
            secondaryTextLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 8),
            secondaryTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            secondaryTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            
            tertiaryTextLabel.topAnchor.constraint(equalTo: secondaryTextLabel.bottomAnchor, constant: 8),
            tertiaryTextLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            tertiaryTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            tertiaryTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ text: String, _ secondaryText: String, _ tertiaryText: String) {
        textLabel.text = text
        secondaryTextLabel.text = secondaryText
        tertiaryTextLabel.text = tertiaryText
        
        tertiaryTextLabel.textColor = if tertiaryText == "Cytrus" {
            .systemYellow
        } else if tertiaryText == "Sudachi" {
            .systemGreen
        } else {
            .secondaryLabel
        }
    }
}
