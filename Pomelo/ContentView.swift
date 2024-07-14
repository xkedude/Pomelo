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
        NavView(core: $core)
            .onAppear() {
                do {
                    try DirectoriesManager.shared.createMissingDirectoriesInDocumentsDirectory()
                    
                    do {
                        core = try LibraryManager.shared.library()
                    } catch {
                        print("Failed to fetch library: \(error)")
                    }
                    
                } catch {
                    print("Failed to create directories: \(error)")
                    return
                }
            }
    }
}

