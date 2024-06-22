//
//  ThemeLoader.swift
//  Pomelo
//
//  Created by Stossy11 on 18/6/2024.
//


import SwiftUI
import Foundation

struct Theme: Codable {
    let color: String
    let a: String?
    let b: String?
    let x: String?
    let y: String?
    // Add more properties for other button types as needed
    
    func color(for buttonType: VirtualControllerButton.ButtonType) -> UIColor? {
        switch buttonType {
        case .a:
            return UIColor(hex: a ?? "")
        case .b:
            return UIColor(hex: b ?? "")
        case .x:
            return UIColor(hex: x ?? "")
        case .y:
            return UIColor(hex: y ?? "")
        // Add cases for other button types
        default:
            return nil
        }
    }
}

class ThemeLoader {
    static let shared = ThemeLoader()

    func loadTheme(completion: @escaping (UIColor?) -> Void) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil)
            print("Unable to get documents directory.")
            return
        }

        let themeURL = documentsDirectory.appendingPathComponent("themes/theme.json")

        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: themeURL)
                let theme = try JSONDecoder().decode(Theme.self, from: data)
                let color = UIColor(hex: theme.color)
                DispatchQueue.main.async {
                    print("Loaded theme color: \(color) from \(themeURL)")
                    completion(color)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error loading theme: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }
    
    func loadTheme() -> Theme? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let themeURL = documentsDirectory.appendingPathComponent("themes/theme.json")

        do {
            let data = try Data(contentsOf: themeURL)
            let theme = try JSONDecoder().decode(Theme.self, from: data)
            return theme
        } catch {
            print("Error loading theme: \(error.localizedDescription)")
            return nil
        }
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UserDefaults {
    func setColor(_ color: UIColor, forKey key: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
            self.set(data, forKey: key)
        }
    }

    func color(forKey key: String) -> UIColor? {
        if let data = self.data(forKey: key), let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor {
            return color
        }
        return nil
    }
}

extension Color {
    init(_ uiColor: UIColor) {
        self.init(uiColor)
    }
}
