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
    @State var game: PomeloGame? = nil
    @Binding var isGridView: Bool

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
                        }
                    }
                } else {
                    LazyVStack() {
                        ForEach(0..<filteredGames.count, id: \.self) { index in
                            let game = core.games[index]
                            NavigationLink(destination: SudachiEmulationView(game: nil).toolbar(.hidden, for: .tabBar)) {
                                GameButtonListView(game: game)
                                    .frame(maxWidth: .infinity, minHeight: 75)
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

                
            }
            .refreshable {
                core = Core(console: Core.Console.nSwitch, name: .Pomelo, games: [], root: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(string: "/")!)
                refreshcore()
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
