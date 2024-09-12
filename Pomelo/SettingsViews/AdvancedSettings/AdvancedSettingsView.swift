//
//  AdvancedSettingsView.swift
//  Pomelo
//
//  Created by Stossy11 on 14/7/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct AdvancedSettingsView: View {
    @AppStorage("isfullscreen") var isFullScreen: Bool = false
    @AppStorage("exitgame") var exitgame: Bool = false
    @AppStorage("ClearBackingRegion") var kpagetable: Bool = true
    @AppStorage("WaitingforJIT") var waitingJIT: Bool = false
    @AppStorage("cangetfullpath") var canGetFullPath: Bool = false
    var body: some View {
        ScrollView {
            Rectangle()
                .fill(Color(uiColor: UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .frame(width: .infinity, height: 50)
                .overlay() {
                    HStack {
                        Toggle("FullScreen", isOn: $isFullScreen)
                            .padding()
                    }
                }
            Text("This is unstable and can lead to crashes. Use at your own risk.")
                .padding(.bottom)
                .font(.footnote)
                .foregroundColor(.gray)
            Rectangle()
                .fill(Color(uiColor: UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .frame(width: .infinity, height: 50)
                .overlay() {
                    HStack {
                        Toggle("Exit Game Button", isOn: $exitgame)
                            .padding()
                    }
                }
            Text("This is very unstable and can lead to game freezing and overall bad preformance after you exit a game")
                .padding(.bottom)
                .font(.footnote)
                .foregroundColor(.gray)
            Rectangle()
                .fill(Color(uiColor: UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .frame(width: .infinity, height: 50)
                .overlay() {
                    HStack {
                        Toggle("Ram Usage Decrease", isOn: $kpagetable)
                            .padding()
                            .onChange(of: kpagetable) { NewValue in
                                UserDefaults.standard.setValue(NewValue, forKey: "ClearBackingRegion")
                            }
                    }
                }
            Text("This is a bit unstable but can lead to slower preformance but also can allow for a bunch more games to be playable")
                .padding(.bottom)
                .font(.footnote)
                .foregroundColor(.gray)
            
            Rectangle()
                .fill(Color(uiColor: UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .frame(width: .infinity, height: 50)
                .overlay() {
                    HStack {
                        Toggle("Check for Booting OS", isOn: $canGetFullPath)
                            .padding()
                    }
                }
            Text("If you do not have the neccesary files for Booting the Switch OS, it will just crash almost instantly.")
                .padding(.bottom)
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}
