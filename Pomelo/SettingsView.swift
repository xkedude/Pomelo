//
//  SettingsView.swift
//  Pomelo
//
//  Created by Stossy11 on 22/6/2024.
//

import SwiftUI

struct SettingsView: View {
    @State var core: Core
    @State var showprompt = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    VStack {
                        Text("Welcome to Pomelo")
                            .font(.title)
                    }
                    .padding()
                    
                    NavigationLink(destination: InfoView()) {
                        Rectangle()
                            .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                            .cornerRadius(10) // Apply rounded corners
                            .frame(width: .infinity, height: 50) // Set the desired dimensions
                            .overlay() {
                                HStack {
                                    Text("About")
                                        .foregroundColor(.primary)
                                        .padding()
                                    Spacer()
                                }
                            }
                    }
                    .padding()
                    
                    NavigationLink {
                        let configURL = core.root.appendingPathComponent("config").appendingPathComponent("config.ini")
                        INIEditControllerWrapper(console: core.console, configURL: configURL)
                            .onAppear() {
                                print(configURL)
                            }
                    } label: {
                        Rectangle()
                            .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                            .cornerRadius(10) // Apply rounded corners
                            .frame(width: .infinity, height: 50) // Set the desired dimensions
                            .overlay() {
                                HStack {
                                    Text("Core Settings")
                                        .foregroundColor(.primary)
                                        .padding()
                                    Spacer()
                                }
                            }
                    }
                    .foregroundColor(.primary)
                    .padding()
                    
                    if UIDevice.current.systemVersion <= "17.0.1" {
                        Button(action: {
                            /*
                             if UserDefaults.standard.bool(forKey: "useTrollStore") {
                             UserDefaults.standard.set(false, forKey: "useTrollStore")
                             } else {
                             UserDefaults.standard.set(true, forKey: "useTrollStore")
                             }
                             */
                            showprompt = true
                        }) {
                            Rectangle()
                                .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                                .cornerRadius(10) // Apply rounded corners
                                .frame(width: .infinity, height: 50) // Set the desired dimensions
                                .overlay() {
                                    HStack {
                                        Text("TrollStore")
                                            .foregroundColor(.primary)
                                            .padding()
                                        Image(systemName: UserDefaults.standard.bool(forKey: "useTrollStore") ? "checkmark" : "")
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                }
                        }
                        .foregroundColor(.primary)
                        .padding()
                    } else {
                        NavigationLink(destination: SideJITServerSettings()) {
                            Rectangle()
                                .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                                .cornerRadius(10) // Apply rounded corners
                                .frame(width: .infinity, height: 50) // Set the desired dimensions
                                .overlay() {
                                    HStack {
                                        Text("SideJITServer Settings")
                                            .foregroundColor(.primary)
                                            .padding()
                                        Spacer()
                                    }
                                    
                                }
                        }
                        .padding()
                    }
                    // NavigationLink(
                    NavigationLink(destination: AdvancedSettingsView()) {
                        Rectangle()
                            .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                            .cornerRadius(10) // Apply rounded corners
                            .frame(width: .infinity, height: 50) // Set the desired dimensions
                            .overlay() {
                                HStack {
                                    Text("Advanced Settings")
                                        .foregroundColor(.primary)
                                        .padding()
                                    Spacer()
                                }
                            }
                    }
                    .padding()
                }
            }
            .onAppear() {
                do {
                    core = try LibraryManager.shared.library()
                } catch {
                    print("Failed to fetch library: \(error)")
                }
            }
            .alert(isPresented: $showprompt) {
                Alert(title: Text("TrollStore"), message: Text("Enabling JIT in App is currenly not supported please enabble JIT from inside TrollStore."), dismissButton: .default(Text("OK")))
            }
        }
        
    }
}

struct AdvancedSettingsView: View {
    @AppStorage("isfullscreen") var isFullScreen: Bool = false
    var body: some View {
        ScrollView {
            Rectangle()
                .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                .cornerRadius(10) // Apply rounded corners
                .frame(width: .infinity, height: 50) // Set the desired dimensions
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
                
        }
    }
}

// let userDefaults = UserDefaults.standard
// userDefaults.set(true, forKey: "isfullscreen")
