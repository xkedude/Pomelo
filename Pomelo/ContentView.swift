//
//  ContentView.swift
//  Pomelo
//
//  Created by Stossy11 on 13/7/2024.
//

import SwiftUI
import Sudachi


struct ContentView: View {
    @State var core = Core(console: .nSwitch, name: .Pomelo, games: [], root: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
    var body: some View {
        NavView(core: $core) // pain and suffering
            .onAppear() {
                do {
                    try PomeloFileManager.shared.createdirectories() // this took a while to create the proper directories
                    
                    do {
                        core = try LibraryManager.shared.library() // this shit is like you tried to throw a egg into a blender with no lid on
                    } catch {
                        print("Failed to fetch library: \(error)") // aaaaaaaaa
                    }
                    
                } catch {
                    print("Failed to create directories: \(error)") // i wonder why hmmmmmmm
                    return
                }
            }
    }
}

