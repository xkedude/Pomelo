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

    var body: some View {
        let filteredGames = core.games.filter { game in
            if let PomeloGame = game as? PomeloGame {
                return searchText.isEmpty || PomeloGame.title.localizedCaseInsensitiveContains(searchText)
            }
            return false // Default case if the cast fails
        }
        ScrollView {
            VStack(alignment: .leading) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 10) {
                    ForEach(0..<filteredGames.count, id: \.self) { index in
                        if let game = core.games[index] as? PomeloGame {
                            
                            NavigationLink(destination: SudachiEmulationView(game: game)) {
                                GameButtonView(game: game)
                                    .frame(maxWidth: .infinity, minHeight: 200) // Set a consistent height for each row
                            }
                             
                        
                        }
                    }
                }
                .searchable(text: $searchText) // Add this line
                .frame(maxWidth: .infinity)
            }
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
    
    func refreshcore() {
        do {
            core = try LibraryManager.shared.library()
        } catch {
            print("Failed to fetch library: \(error)")
            return
        }
    }
}
