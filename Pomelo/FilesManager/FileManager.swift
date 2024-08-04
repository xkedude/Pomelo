//
//  FileManager.swift
//  Pomelo
//
//  Created by Stossy11 on 16/7/2024.
//

import SwiftUI
import Foundation
import UIKit
import Sudachi

struct Core : Comparable, Hashable {
    enum Name : String, Hashable { // i dunno why i have this, i know what emulator this is
        case Pomelo = "Pomelo"
    }
    
    enum Console : String, Hashable {
        case nSwitch = "Nintendo Switch" // no shit sherlock
    }
    
    let console: Console
    let name: Name
    var games: [PomeloGame]
    let root: URL
    
    static func < (lhs: Core, rhs: Core) -> Bool {
        lhs.name.rawValue < rhs.name.rawValue
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
    
    func library() throws -> Core {
        func getromsfromdir() throws -> [URL] {
            guard let dirContents = FileManager.default.enumerator(at: documentdir, includingPropertiesForKeys: nil, options: []) else {
                print("uhoh how unfortunate for some reason FileManager.default.enumerator aint workin")
                throw LibManError.ripenum
            }
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
        

        var PomeloCore = Core(console: .nSwitch, name: .Pomelo, games: [], root: directory)
        games(from: try getromsfromdir(), core: &PomeloCore)
        
        return PomeloCore
    }
}
