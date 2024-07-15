//
//  FileManager.swift
//  Pomelo
//
//  Created by Stossy11 on 13/7/2024.
//

import Sudachi
import Foundation
import UIKit

struct Core : Comparable, Hashable {
    enum Name : String, Hashable {
        case Pomelo = "Pomelo"
    }
    
    enum Console : String, Hashable {
        case nSwitch = "Nintendo Switch"
    }
    
    let console: Console
    let name: Name
    var games: [AnyHashable]
    let root: URL
    
    static func < (lhs: Core, rhs: Core) -> Bool {
        lhs.name.rawValue < rhs.name.rawValue
    }
}


class DirectoriesManager {
    static let shared = DirectoriesManager()
    
    func directories() -> [String : [String : String]] {
        [
            "themes" : [:],
            "amiibo" : [:],
            "cache" : [:],
            "config" : [:],
            "crash_dumps" : [:],
            "dump" : [:],
            "keys" : [:],
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
        }
    }
    
    func scanDirectoriesForRequiredFiles(for core: inout Core) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        directories().forEach { directory, fileNames in
            let coreDirectory = documentsDirectory.appendingPathComponent(directory, conformingTo: .folder)
            
            fileNames.forEach { (fileName, fileImportance) in
                let fileURL = coreDirectory.appendingPathComponent(fileName, conformingTo: .fileURL)
                
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    // core.missingFiles.append(.init(coreName: core.name, directory: coreDirectory, fileName: fileName))
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
            let documentsDirectory = URL(string: UserDefaults.standard.string(forKey: "SudachiDirectoryURL") ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("roms", conformingTo: .folder).absoluteString)!
            guard let enumerator = FileManager.default.enumerator(at: documentsDirectory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
                throw LibraryManagerError.invalidEnumerator
            }
            let iscustom = documentsDirectory.startAccessingSecurityScopedResource()
            
            var urls: [URL] = []
            try enumerator.forEach { element in
                switch element {
                case let url as URL:
                    let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                    if let isRegularFile = attributes.isRegularFile, isRegularFile {
                        switch coreName {
                        case .Pomelo:
                            if ["nca", "nro", "nso", "nsp", "xci"].contains(url.pathExtension.lowercased()) {
                                urls.append(url)
                            }
                        default:
                            break
                        }
                    }
                default:
                    break
                }
            }
            if iscustom {
                documentsDirectory.stopAccessingSecurityScopedResource()
            }
            return urls
        }
        
        func games(from urls: [URL], for core: inout Core) {
            switch core.name {
 
            case .Pomelo:
                core.games = urls.reduce(into: [SudachiGame]()) { partialResult, element in
                    let iscustom = element.startAccessingSecurityScopedResource()
                    let information = Sudachi.shared.information(for: element)
                
                    let game = SudachiGame(core: core, developer: information.developer, fileURL: element,
                                           imageData: information.iconData,
                                           title: information.title)
                    if iscustom {
                        element.stopAccessingSecurityScopedResource()
                    }
                    partialResult.append(game)
                }
            default:
                break
            }
        }
        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
 
        var SudachiCore = Core(console: .nSwitch, name: .Pomelo, games: [], root: directory)
        games(from: try romsDirectoryCrawler(for: .Pomelo), for: &SudachiCore)
        DirectoriesManager.shared.scanDirectoriesForRequiredFiles(for: &SudachiCore)
        
 
        return SudachiCore
    }
}
