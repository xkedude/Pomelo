//
//  NavView.swift
//  Pomelo
//
//  Created by Stossy11 on 14/7/2024.
//

import SwiftUI
import Sudachi

struct NavView: View {
    @Binding var core: Core
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryView(core: $core)
                .tabItem {
                    Label("Library", systemImage: "rectangle.on.rectangle")
                }
                .tag(0)
            BootOSView(core: $core, currentnavigarion: $selectedTab)
                .toolbar(.hidden, for: .tabBar)
                .tabItem {
                    Label("Boot OS", systemImage: "house")
                }
                .tag(1)
            SettingsView(core: core)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

