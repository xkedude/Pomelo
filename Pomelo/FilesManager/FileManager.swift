//
//  FileManager.swift
//  Pomelo
//
//  Created by Stossy11 on 
//  Copyright © 2024 Stossy11. All rights reserved.16/7/2024.
//

import SwiftUI
import Foundation
import UIKit
import Sudachi
import Zip

struct Core : Comparable, Hashable {
    
    let name = "Pomelo"
    var games: [PomeloGame]
    let root: URL
    
    static func < (lhs: Core, rhs: Core) -> Bool {
        lhs.name < rhs.name
    }
    
    func AddFirmware(at fileURL: URL) {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent("nand/system/Contents/registered")
            
            
            if !fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            }

            
            try Zip.unzipFile(fileURL, destination: destinationURL, overwrite: true, password: nil)
            print("File unzipped successfully to \(destinationURL.path)")

        } catch {
            print("Failed to unzip file: \(error)")
        }
    }
}


class PomeloFileManager {
    static var shared = PomeloFileManager()
    
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

    func createdirectories() throws {
        let documentdir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try directories().forEach() { directory, filename in
            let directoryURL = documentdir.appendingPathComponent(directory)
            
            if !FileManager.default.fileExists(atPath: directoryURL.path) {
                print("creating dir at \(directoryURL.path)") // yippee
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: false, attributes: nil)
            }
        }
    }
    
    func DetectKeys() -> (Bool, Bool) {
        var prodkeys = false
        var titlekeys = false
        let filemanager = FileManager.default
        let documentdir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let KeysFolderURL = documentdir.appendingPathComponent("keys")
        
        prodkeys = filemanager.fileExists(atPath: KeysFolderURL.appendingPathComponent("prod.keys").path)
            
        titlekeys = filemanager.fileExists(atPath: KeysFolderURL.appendingPathComponent("title.keys").path)
        
        return (prodkeys, titlekeys)
    }
}

enum LibManError : Error {
    case ripenum, urlgobyebye
}

class LibraryManager {
    static let shared = LibraryManager()
    let documentdir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("roms", conformingTo: .folder)
    
    
    func removerom(_ game: PomeloGame) throws {
        do {
            try FileManager.default.removeItem(at: game.fileURL)
        } catch {
            throw error
        }
    }
    
    func homebrewroms() -> [PomeloGame] {
        
        var urls: [URL] = []
        
        let sdmc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sdmc", conformingTo: .folder)
        let sdfolder = sdmc.appendingPathComponent("switch", conformingTo: .folder)
        if FileManager.default.fileExists(atPath: sdfolder.path) {
            if let dirContents = FileManager.default.enumerator(at: sdmc, includingPropertiesForKeys: nil, options: []) {
                do {
                    try dirContents.forEach() { files in
                        if let file = files as? URL {
                            let getaboutfile = try file.resourceValues(forKeys: [.isRegularFileKey])
                            if let isfile = getaboutfile.isRegularFile, isfile {
                                if ["nso", "nro"].contains(file.pathExtension.lowercased()) {
                                    urls.append(file)
                                }
                            }
                        }
                    }
                } catch {
                    if let dirContents = FileManager.default.enumerator(at: documentdir, includingPropertiesForKeys: nil, options: []) {
                        do {
                            try dirContents.forEach() { files in
                                if let file = files as? URL {
                                    let getaboutfile = try file.resourceValues(forKeys: [.isRegularFileKey])
                                    if let isfile = getaboutfile.isRegularFile, isfile {
                                        if ["nso", "nro"].contains(file.pathExtension.lowercased()) {
                                            urls.append(file)
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("damn")
                            
                            if let dirContents = FileManager.default.enumerator(at: documentdir, includingPropertiesForKeys: nil, options: []) {
                                do {
                                    try dirContents.forEach() { files in
                                        if let file = files as? URL {
                                            let getaboutfile = try file.resourceValues(forKeys: [.isRegularFileKey])
                                            if let isfile = getaboutfile.isRegularFile, isfile {
                                                if ["nso", "nro"].contains(file.pathExtension.lowercased()) {
                                                    urls.append(file)
                                                }
                                            }
                                        }
                                    }
                                } catch {
                                    return []
                                }
                            } else {
                                return []
                            }
    
                        }
                    }
                }
            }
        }
        
        if let dirContents = FileManager.default.enumerator(at: documentdir, includingPropertiesForKeys: nil, options: []) {
            do {
                try dirContents.forEach() { files in
                    if let file = files as? URL {
                        let getaboutfile = try file.resourceValues(forKeys: [.isRegularFileKey])
                        if let isfile = getaboutfile.isRegularFile, isfile {
                            if ["nso", "nro"].contains(file.pathExtension.lowercased()) {
                                urls.append(file)
                            }
                        }
                    }
                }
            } catch {
                return []
            }
        } else {
            return []
        }
        
        func games(from urls: [URL]) -> [PomeloGame] {
            var pomelogames: [PomeloGame] = []
            pomelogames = urls.reduce(into: [PomeloGame]()) { partialResult, element in
                let iscustom = element.startAccessingSecurityScopedResource()
                let information = Sudachi.shared.information(for: element)
                let game = PomeloGame(developer: information.developer, fileURL: element,
                                      imageData: information.iconData,
                                      title: information.title)
                if iscustom {
                    element.stopAccessingSecurityScopedResource()
                }
                partialResult.append(game)
            }
            
            return pomelogames
        }
        
        return games(from: urls)
    }
    
    func library() throws -> Core {
        func getromsfromdir() throws -> [URL] {
            guard let dirContents = FileManager.default.enumerator(at: documentdir, includingPropertiesForKeys: nil, options: []) else {
                print("uhoh how unfortunate for some reason FileManager.default.enumerator aint workin")
                throw LibManError.ripenum
            }
            
            let sudachi = Sudachi.shared
            var urls: [URL] = []
            try dirContents.forEach() { files in
                if let file = files as? URL {
                    let getaboutfile = try file.resourceValues(forKeys: [.isRegularFileKey])
                    if let isfile = getaboutfile.isRegularFile, isfile {
                        if ["nca", "nro", "nsp", "nso", "xci"].contains(file.pathExtension.lowercased()) {
                            urls.append(file)
                        }
                    }
                }
            }
            
            let sdmc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sdmc", conformingTo: .folder)
            let sdfolder = sdmc.appendingPathComponent("switch", conformingTo: .folder)
            if FileManager.default.fileExists(atPath: sdfolder.path) {
                if let dirContents = FileManager.default.enumerator(at: sdmc, includingPropertiesForKeys: nil, options: []) {
                    try dirContents.forEach() { files in
                        if let file = files as? URL {
                            let getaboutfile = try file.resourceValues(forKeys: [.isRegularFileKey])
                            if let isfile = getaboutfile.isRegularFile, isfile {
                                if ["nso", "nro"].contains(file.pathExtension.lowercased()) {
                                    urls.append(file)
                                }
                            }
                        }
                    }
                }
            }
            
            sudachi.insert(games: urls)
            
            return urls
        }
        
        func games(from urls: [URL], core: inout Core) {
            core.games = urls.reduce(into: [PomeloGame]()) { partialResult, element in
                let iscustom = element.startAccessingSecurityScopedResource()
                let information = Sudachi.shared.information(for: element)
                
                let game = PomeloGame(developer: information.developer, fileURL: element,
                                      imageData: information.iconData,
                                      title: information.title)
                if iscustom {
                    element.stopAccessingSecurityScopedResource()
                }
                partialResult.append(game)
            }
        }
        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        

        var PomeloCore = Core(games: [], root: directory)
        games(from: try getromsfromdir(), core: &PomeloCore)
        
        return PomeloCore
    }
}
