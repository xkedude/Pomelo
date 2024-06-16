//
//  ContentView.swift
//  Pomelo
//
//  Created by Stossy11 on 15/6/2024.
//

import SwiftUI
import UIKit


struct ContentView: View {
    @Binding var cores: [Core]
    @Binding var showAlert: Bool
    
    var body: some View {
        LibraryView(core: $cores)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
                do {
                    try DirectoriesManager.shared.createMissingDirectoriesInDocumentsDirectory()
                    do {
                        cores = try LibraryManager.shared.library()
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

