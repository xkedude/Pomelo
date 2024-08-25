//
//  PomeloGame.swift
//  Pomelo
//
//  Created by Stossy11 on 
//  Copyright © 2024 Stossy11. All rights reserved.13/7/2024.
//

import Foundation

struct PomeloGame : Comparable, Hashable, Identifiable {
    var id = UUID()
    
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
    
    static func < (lhs: PomeloGame, rhs: PomeloGame) -> Bool {
        lhs.title < rhs.title
    }
    
    static func == (lhs: PomeloGame, rhs: PomeloGame) -> Bool {
        lhs.title == rhs.title
    }
}


