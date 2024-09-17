//
//  SettingsView.swift
//  Pomelo
//
//  Created by Stossy11 on 14/7/2024.
//

import SwiftUI

struct SettingsView: View {
    @State var core: Core
    @State var showprompt = false
    
    @AppStorage("icon") var iconused = 1
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center) {
                    if iconused == 1 {
                        if let image = UIImage(named: AppIconProvider.appIcon()) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 200, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
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
                        CoreSettingsView()
                    } label: {
                        Rectangle()
                            .fill(Color(uiColor: UIColor.secondarySystemBackground)) // Set the fill color (optional)
                            .cornerRadius(10) // Apply rounded corners
                            .frame(width: .infinity, height: 50) // Set the desired dimensions
                            .overlay() {
                                VStack {
                                    HStack {
                                        Text("Core Settings")
                                            .foregroundColor(.primary)
                                            .padding()
                                        Spacer()
                                    }
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
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Text("By \(getDeveloperNames())")
                            .font(.caption2)
                        Spacer()
                    }
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
