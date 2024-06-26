//
//  LibraryManager.swift
//  Pomelo
//
//  Created by Jarrod Norwell on 1/18/24.
//

import Sudachi

import Foundation
import UIKit

struct MissingFile : Hashable, Identifiable {
    enum FileImportance : String, CustomStringConvertible {
        case optional = "Optional", required = "Required"
        
        var description: String {
            rawValue
        }
    }
    
    var id = UUID()
    
    let coreName: Core.Name
    let directory: URL
    var fileImportance: FileImportance
    let fileName: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(coreName)
        hasher.combine(directory)
        hasher.combine(fileImportance)
        hasher.combine(fileName)
    }
}

enum Core2 : String, Codable, Hashable {
    enum Console : String, Codable, Hashable {
        case nSwitch = "Nintendo Switch"
        
        var shortened: String {
            switch self {
            case .nSwitch: "nSwitch"
            }
        }
    }
    
    case Sudachi = "Sudachi"
    
    var console: Console {
        switch self {
        case .Sudachi: .nSwitch
        }
    }
    
    var isNintendo: Bool {
        self == .Sudachi
    }
    

    
    static let cores: [Core2] = [.Sudachi]
}


struct Core : Comparable, Hashable {
    enum Name : String, Hashable {
        case Sudachi = ""
    }
    
    enum Console : String, Hashable {
        case nSwitch = "Nintendo Switch"
        
        func buttonColors() -> [VirtualControllerButton.ButtonType : UIColor] {
            var colors: [VirtualControllerButton.ButtonType: UIColor] = [:]
            
            // Load theme
            if let theme = ThemeLoader.shared.loadThemes() {
                colors = [
                    .a: theme.color(for: .a) ?? .systemGray,
                    .b: theme.color(for: .b) ?? .systemGray,
                    .x: theme.color(for: .x) ?? .systemGray,
                    .y: theme.color(for: .y) ?? .systemGray,
                    
                    // Add more buttons as needed
                ]
            } else {
                // Default to system colors if theme fails to load
                colors = [
                    .a: .systemGray,
                    .b: .systemGray,
                    .x: .systemGray,
                    .y: .systemGray,
                    // Add more buttons as needed
                ]
            }
            
            return colors
        }
    }
    
    let console: Console
    let name: Name
    var games: [AnyHashable]
    var missingFiles: [MissingFile]
    let root: URL
    
    static func < (lhs: Core, rhs: Core) -> Bool {
        lhs.name.rawValue < rhs.name.rawValue
    }
}


class DirectoriesManager {
    static let shared = DirectoriesManager()
    
    func directories() -> [String : [String : MissingFile.FileImportance]] {
        [
            "themes" : [
                "theme.json": .optional],
                "amiibo" : [:],
                "cache" : [:],
                "config" : [:],
                "crash_dumps" : [:],
                "dump" : [:],
                "keys" : [
                    "prod.keys" : .required,
                    "title.keys" : .required
                ],
                "load" : [:],
                "log" : [:],
                "nand" : [:],
                "play_time" : [:],
                "roms" : [:],
                "screenshots" : [:],
                "sdmc" : [:],
                "shader" : [:],
                "tas" : [:],
                "icons" : [:]
    
        ]
    }
    
    func createMissingDirectoriesInDocumentsDirectory() throws {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try directories().forEach { directory, files in
            let coreDirectory = documentsDirectory.appendingPathComponent(directory, conformingTo: .folder)
            if !FileManager.default.fileExists(atPath: coreDirectory.path) {
                try FileManager.default.createDirectory(at: coreDirectory, withIntermediateDirectories: false)
            }
            
            var isDirectory: ObjCBool = true
            
            // Create theme.json file if it doesn't exist
            if directory == "themes" {
                let themeFileURL = coreDirectory.appendingPathComponent("theme.json")
                let themeimagefoler = coreDirectory.appendingPathComponent("images/")
                if !FileManager.default.fileExists(atPath: themeimagefoler.path, isDirectory: &isDirectory) {
                    try FileManager.default.createDirectory(at: themeimagefoler, withIntermediateDirectories: false)
                }
                if !FileManager.default.fileExists(atPath: themeFileURL.path) {
                    let defaultTheme = Theme(background: "", a: "", b: "", x: "", y: "", dpadUp: "", dpadLeft: "", dpadDown: "", dpadRight: "", minus: "", plus: "", l: "", zl: "", r: "", zr: "")
                    if let jsonData = try? JSONEncoder().encode(defaultTheme) {
                        FileManager.default.createFile(atPath: themeFileURL.path, contents: jsonData, attributes: nil)
                    }
                }
            }
        }
    }
    
    func scanDirectoriesForRequiredFiles(for core: inout Core) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        directories().forEach { directory, fileNames in
            let coreDirectory = documentsDirectory.appendingPathComponent(directory, conformingTo: .folder)
            
            fileNames.forEach { (fileName, fileImportance) in
                let fileURL = coreDirectory.appendingPathComponent(fileName, conformingTo: .fileURL)
                
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    core.missingFiles.append(.init(coreName: core.name, directory: coreDirectory, fileImportance: fileImportance, fileName: fileName))
                }
            }
        }
    }
}

enum LibraryManagerError : Error {
    case invalidEnumerator, invalidURL
}

class LibraryManager {
    static let shared = LibraryManager()
    
    func library() throws -> Core {
        func romsDirectoryCrawler(for coreName: Core.Name) throws -> [URL] {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            guard let enumerator = FileManager.default.enumerator(at: documentsDirectory.appendingPathComponent(coreName.rawValue, conformingTo: .folder)
                .appendingPathComponent("roms", conformingTo: .folder), includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
                throw LibraryManagerError.invalidEnumerator
            }
            
            var urls: [URL] = []
            try enumerator.forEach { element in
                switch element {
                case let url as URL:
                    let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                    if let isRegularFile = attributes.isRegularFile, isRegularFile {
                        switch coreName {
#if canImport(Sudachi)
                        case .Sudachi:
                            if ["nca", "nro", "nso", "nsp", "xci"].contains(url.pathExtension.lowercased()) {
                                urls.append(url)
                            }
#endif
                        default:
                            break
                        }
                    }
                default:
                    break
                }
            }
            
            return urls
        }
        
        func games(from urls: [URL], for core: inout Core) {
            switch core.name {
#if canImport(Sudachi)
            case .Sudachi:
                core.games = urls.reduce(into: [SudachiGame]()) { partialResult, element in
                    let information = Sudachi.shared.information(for: element)
                
                    let game = SudachiGame(core: core, developer: information.developer, fileURL: element,
                                           imageData: information.iconData,
                                           title: information.title)
                    partialResult.append(game)
                }
#endif
            default:
                break
            }
        }
        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
#if canImport(Sudachi)
        var SudachiCore = Core(console: .nSwitch, name: .Sudachi, games: [], missingFiles: [], root: directory.appendingPathComponent(Core.Name.Sudachi.rawValue, conformingTo: .folder))
        games(from: try romsDirectoryCrawler(for: .Sudachi), for: &SudachiCore)
        DirectoriesManager.shared.scanDirectoriesForRequiredFiles(for: &SudachiCore)
#endif
        
#if canImport(Sudachi)
        return SudachiCore
#endif
    }
}
