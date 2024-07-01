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
    @AppStorage("sidejitserver-enable-true") var sidejitserver: Bool = false
    @AppStorage("sidejitserver-NavigationLink-true") var showAlert: Bool = false
    @AppStorage("sidejitserver-ip-true") var ip: String = ""
    @AppStorage("sidejitserver-udid-true") var udid: String = ""
    
    @AppStorage("icon") var iconused = 1
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center) {
                    if iconused == 1 {
                        Image("AppIcon")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .cornerRadius(20)
                    }
                    Text("Welcome To Pomelo")
                        .padding()
                        .font(.title)
                }
                .padding()
                VStack(alignment: .leading) {
                    
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
                        Rectangle()
                            .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                            .cornerRadius(10) // Apply rounded corners
                            .frame(width: .infinity, height: 50) // Set the desired dimensions
                            .overlay() {
                                Toggle(isOn: $sidejitserver) {
                                    Text("SideJITServer")
                                }
                                .padding()
                            }
                            .padding()
                        
                        if sidejitserver {
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
                    }
                    
                    /*
                    NavigationLink(destination: AppIconView()) {
                        Rectangle()
                            .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                            .cornerRadius(10) // Apply rounded corners
                            .frame(width: .infinity, height: 50) // Set the desired dimensions
                            .overlay() {
                                HStack {
                                    Text("App Icon")
                                        .foregroundColor(.primary)
                                        .padding()
                                    Spacer()
                                }
                            }
                    }
                    .padding()
                     */
                
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
    @AppStorage("exitgame") var exitgame: Bool = false
    @AppStorage("ClearBackingRegion") var kpagetable: Bool = true
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
            Rectangle()
                .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                .cornerRadius(10) // Apply rounded corners
                .frame(width: .infinity, height: 50) // Set the desired dimensions
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
                .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                .cornerRadius(10) // Apply rounded corners
                .frame(width: .infinity, height: 50) // Set the desired dimensions
                .overlay() {
                    HStack {
                        Toggle("Ram Usage Decrease", isOn: $kpagetable)
                            .padding()
                    }
                }
            Text("This is a bit unstable but can lead to slower preformance but also can allow for a bunch more games to be playable")
                .padding(.bottom)
                .font(.footnote)
                .foregroundColor(.gray)
                .onChange(of: exitgame) { newValue in
                    UserDefaults.standard.setValue(newValue, forKey: "ClearBackingRegion")
                }
        }
    }
}

// let userDefaults = UserDefaults.standard
// userDefaults.set(true, forKey: "isfullscreen")
