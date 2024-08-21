//
//  GameListView.swift
//  Pomelo
//
//  Created by Stossy11 on 14/7/2024.
//

import SwiftUI
import Foundation
import UIKit
import UniformTypeIdentifiers

struct GameListView: View {
    @State var core: Core
    @State private var searchText = ""
    @State var game: PomeloGame? = nil
    @State private var isGridView = true

    var body: some View {
        let filteredGames = core.games.filter { game in
            if let PomeloGame = game as? PomeloGame {
                return searchText.isEmpty || PomeloGame.title.localizedCaseInsensitiveContains(searchText)
            }
            return false
        }


        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isGridView.toggle()
                    }) {
                        Image(systemName: isGridView ? "rectangle.grid.1x2" : "square.grid.2x2")
                            .imageScale(.large)
                            .padding()
                        Spacer()
                    }
                
                    Spacer()
                }
                //.padding(.top, -65)
                //.padding(.bottom, 30)
                
            VStack(alignment: .leading) {
                
                if isGridView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 10) {
                        ForEach(0..<filteredGames.count, id: \.self) { index in
                            if let game = core.games[index] as? PomeloGame {
                                NavigationLink(destination: SudachiEmulationView(game: game).toolbar(.hidden, for: .tabBar)) {
                                    GameButtonView(game: game)
                                        .frame(maxWidth: .infinity, minHeight: 200)
                                }
                            }
                        }
                    }
                } else {
                    LazyVStack() {
                        ForEach(0..<filteredGames.count, id: \.self) { index in
                            if let game = core.games[index] as? PomeloGame {
                                NavigationLink(destination: SudachiEmulationView(game: game).toolbar(.hidden, for: .tabBar)) {
                                    GameButtonListView(game: game)
                                        .frame(maxWidth: .infinity, minHeight: 75)
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
