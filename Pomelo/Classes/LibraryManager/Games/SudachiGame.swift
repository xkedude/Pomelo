//
//  SudachiGame.swift
//  Pomelo
//
//  Created by Jarrod Norwell on 4/3/2024.
//

import Foundation

struct SudachiGame : Comparable, Hashable, Identifiable {
    var id = UUID()
    
    let core: Core
    let developer: String
    let fileURL: URL
    let imageData: Data
    let title: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(developer)
        hasher.combine(fileURL)
        hasher.combine(imageData)
        hasher.combine(title)
    }
    
    static func < (lhs: SudachiGame, rhs: SudachiGame) -> Bool {
        lhs.title < rhs.title
    }
    
    static func == (lhs: SudachiGame, rhs: SudachiGame) -> Bool {
        lhs.title == rhs.title
    }
}
