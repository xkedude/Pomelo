//
//  BootOSView.swift
//  Pomelo
//
//  Created by Stossy11 on 14/7/2024.
//

import SwiftUI
import Sudachi

struct BootOSView: View {
    @Binding var core: Core
    @Binding var currentnavigarion: Int
    @State var sudachi = Sudachi.shared
    var body: some View {
        if sudachi.canGetFullPath() {
            SudachiEmulationView(game: nil)
        } else {
            VStack {
                Text("Unable Launch Switch OS")
                    .font(.largeTitle)
                    .padding()
                Text("You do not have the Switch Home Menu Files Needed to launch the Ηome Menu")
            }
        }
    }
}
