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
                        Image("AppIcon-inapp")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .cornerRadius(20)
                    } else if iconused == 2 {
                        Image(.appIconSecondaryInapp)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .cornerRadius(20)
                    } else {
                        Image(.appIconInvertedInapp)
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
        }
    }
}

struct AppIconView: View {
    let icons = ["AppIcon-1", "Appicon-Secondary", "Appicon-inverted"] // Replace with your icon names
    @AppStorage("icon") var iconused = 1
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(icons, id: \.self) { iconName in
                    Button {
                        if iconName == "AppIcon" {
                            iconused = 1
                            UIApplication.shared.setAlternateIconName(iconName) { error in
                                if let error = error {
                                    print("fuck \(error.localizedDescription)")
                                }
                            }
                        } else if iconName == "Appicon-Secondary" {
                            iconused = 2
                            UIApplication.shared.setAlternateIconName(iconName) { error in
                                if let error = error {
                                    print("fuck \(error.localizedDescription)")
                                }
                            }
                        } else {
                            UIApplication.shared.setAlternateIconName(iconName) { error in
                                if let error = error {
                                    print("fuck \(error.localizedDescription)")
                                }
                            }
                        }
                    } label: {
                        VStack {
                            if iconName == "AppIcon-1" {
                                Image(.appIconInapp)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80) // Adjust size as needed
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                Text("Main App Icon")
                            } else if iconName == "Appicon-Secondary" {
                                Image(.appIconSecondaryInapp)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80) // Adjust size as needed
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                Text("Secondary App Icon")
                            } else if iconName == "Appicon-inverted" {
                                Image(.appIconInvertedInapp)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80) // Adjust size as needed
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                Text("Inverted Main App Icon")
                            } 
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("App Icons")
        Spacer()
        Text("All of these icons were generously made by ZxATHER")
            .padding(.bottom)
            .font(.footnote)
            .foregroundColor(.gray)
    }
}
// let userDefaults = UserDefaults.standard
// userDefaults.set(true, forKey: "isfullscreen")
