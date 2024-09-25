//
//  InfoView.swift
//  Pomelo
//
//  Created by Stossy11 on 
//  Copyright © 2024 Stossy11. All rights reserved.14/7/2024.
//

import SwiftUI

struct InfoView: View {
    @AppStorage("entitlementNotExists") private var entitlementNotExists: Bool = false
    @AppStorage("increaseddebugmem") private var increaseddebugmem: Bool = false
    @AppStorage("extended-virtual-addressing") private var extended: Bool = false
    let infoDictionary = Bundle.main.infoDictionary
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Welcome to Pomelo!")
                    .font(.largeTitle)
                Divider()
                Text("Entitlements:")
                    .font(.title)
                    .font(Font.headline.weight(.bold))
                Spacer()
                    .frame(height: 10)
                Group {
                    Text("Required:")
                        .font(.title2)
                        .foregroundColor(.red)
                        .font(Font.headline.weight(.bold))
                    Spacer()
                        .frame(height: 10)
                    Text("Increased Memory Limit: \(String(describing: !entitlementNotExists))")
                    Spacer()
                        .frame(height: 10)
                }
                Group {
                    Spacer()
                        .frame(height: 10)
                    Text("Reccomended (paid):")
                        .font(.title2)
                        .font(Font.headline.weight(.bold))
                    Spacer()
                        .frame(height: 10)
                    Text("Increased Debugging Memory Limit: \(String(describing: increaseddebugmem))")
                        .padding()
                    Text("Extended Virtual Addressing: \(String(describing: extended))")
                }
                
            }
            .padding()
            
            Text("Version: \(getAppVersion())")
                .foregroundColor(.gray)
        }
    }
    func getAppVersion() -> String {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }
}
