//
//  MinimalRoundedTextField.swift
//  Folium
//
//  Created by Jarrod Norwell on 20/3/2024.
//

import Foundation
import UIKit

enum RoundedCorners {
    case all, bottom, none, top
}

class MinimalRoundedTextField : UITextField {
    init(_ placeholder: String, _ roundedCorners: RoundedCorners = .none, _ radius: CGFloat = 15) {
        super.init(frame: .zero)
        self.backgroundColor = .secondarySystemBackground
        self.placeholder = placeholder
        
        switch roundedCorners {
        case .all:
            self.layer.cornerCurve = .continuous
            self.layer.cornerRadius = radius
        case .bottom, .top:
            self.layer.cornerCurve = .continuous
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = roundedCorners == .bottom ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .none:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return editingRect(forBounds: bounds)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return editingRect(forBounds: bounds)
    }
}
