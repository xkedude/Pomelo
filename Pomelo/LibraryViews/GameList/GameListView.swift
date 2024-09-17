//
//  GameListView.swift
//  Pomelo
//
//  Created by Stossy11 on 
//  Copyright © 2024 Stossy11. All rights reserved.14/7/2024.
//

import SwiftUI
import Foundation
import UIKit
import UniformTypeIdentifiers
import Sudachi

struct GameListView: View {
    @State var core: Core
    @State private var searchText = ""
    @State var game: Int = 1
    @State var startgame: Bool = false
    @Binding var isGridView: Bool
    @State var showAlert = false
    @State var alertMessage: Alert? = nil
    
    var body: some View {
        let filteredGames = core.games.filter { game in
            guard let PomeloGame = game as? PomeloGame else { return false }
            return searchText.isEmpty || PomeloGame.title.localizedCaseInsensitiveContains(searchText)
        }
        
        
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    
                    if isGridView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 10) {
                            ForEach(0..<filteredGames.count, id: \.self) { index in
                                let game = core.games[index]
                                NavigationLink(destination: SudachiEmulationView(game: game).toolbar(.hidden, for: .tabBar)) {
                                    GameButtonView(game: game)
                                        .frame(maxWidth: .infinity, minHeight: 200)
                                }
                                .contextMenu {
                                    Button(action: {
                                        do {
                                            try LibraryManager.shared.removerom(core.games[index])
                                        } catch {
                                            showAlert = true
                                            alertMessage = Alert(title: Text("Unable to Remove Game"), message: Text(error.localizedDescription))
                                        }
                                    }) {
                                        Text("Remove")
                                    }
                                    Button(action: {
                                        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "roms") {
                                            // Open the directory in the Files app
                                            UIApplication.shared.open(documentsURL, options: [:], completionHandler: nil)
                                        }
                                    }) {
                                        if ProcessInfo.processInfo.isMacCatalystApp {
                                            Text("Open in Finder")
                                        } else {
                                            Text("Open in Files")
                                        }
                                    }
                                    
                                    
                                    NavigationLink(destination: SudachiEmulationView(game: game).toolbar(.hidden, for: .tabBar)) {
                                        Text("Launch")
                                    }
                                }
                            }
                        }
                    } else {
                        LazyVStack() {
                            ForEach(0..<filteredGames.count, id: \.self) { index in
                                let game = core.games[index]
                                NavigationLink(destination: SudachiEmulationView(game: game).toolbar(.hidden, for: .tabBar)) {
                                    GameButtonListView(game: game)
                                        .frame(maxWidth: .infinity, minHeight: 75)
                                }
                                .contextMenu {
                                    Button(action: {
                                        do {
                                            try LibraryManager.shared.removerom(core.games[index])
                                            try FileManager.default.removeItem(atPath: game.fileURL.path)
                                        } catch {
                                            showAlert = true
                                            alertMessage = Alert(title: Text("Unable to Remove Game"), message: Text(error.localizedDescription))
                                        }
                                    }) {
                                        Text("Remove")
                                    }
                                    
                                    Button(action: {
                                        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "roms") {
                                            // Open the directory in the Files app
                                            UIApplication.shared.open(documentsURL, options: [:], completionHandler: nil)
                                        }
                                    }) {
                                        if ProcessInfo.processInfo.isMacCatalystApp {
                                            Text("Open in Finder")
                                        } else {
                                            Text("Open in Files")
                                        }
                                    }
                                    
                                    NavigationLink(destination: SudachiEmulationView(game: game).toolbar(.hidden, for: .tabBar)) {
                                        Text("Launch")
                                    }
                                }
                            }
                        }
                    }
                }
                .searchable(text: $searchText)
                .padding()
            }
            .onAppear() {
                refreshcore()
                
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let romsFolderURL = documentsDirectory.appendingPathComponent("roms")
                    
                    let folderMonitor = FolderMonitor(folderURL: romsFolderURL) {
                        // This will be called whenever a file is added/removed in the "roms" folder
                        do {
                            core = Core(games: [], root: documentsDirectory)
                            core = try LibraryManager.shared.library()
                        } catch {
                            print("Error refreshing core: \(error)")
                        }
                    }
                }

            }
            .alert(isPresented: $showAlert) {
                alertMessage ?? Alert(title: Text("Error Not Found"))
            }
        }
    }
    
    func refreshcore() {
        do {
            core = try LibraryManager.shared.library()
        } catch {
            print("Failed to fetch library: \(error)")
            return
        }
    }
}
