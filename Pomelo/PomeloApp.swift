//
//  PomeloApp.swift
//  Pomelo
//
//  Created by Stossy11 on 15/6/2024.
//

import SwiftUI
import Foundation
import UIKit

@main
struct PomeloApp: App {
    @State var cores: Core = Core(console: .nSwitch, name: .Sudachi, games: [], missingFiles: [], root: URL(fileURLWithPath: "/"))
    @AppStorage("entitlementNotExists") private var entitlementNotExists: Bool = false
    @AppStorage("sidejitserver-enable") var sidejitserver: Bool = false
    @AppStorage("sidejitserver-NavigationLink") var showAlert: Bool = false
    @AppStorage("sidejitserver-ip") var ip: String = ""
    @AppStorage("sidejitserver-udid") var udid: String = ""
    @AppStorage("sidejitserver-enable-auto") var sidejitserverauto: Bool = false
    @State private var latestVersion: String?
    @State var alertstring = ""
    @State var alert = false
    @State var issue = false
    
    var body: some Scene {
        WindowGroup {
            // LibraryView(core: $cores)
            NavView(cores: $cores)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    // registerDefaultsFromSettingsBundle()
                    
                    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
                    do {
                        try DirectoriesManager.shared.createMissingDirectoriesInDocumentsDirectory()
                        do {
                            cores = try LibraryManager.shared.library()
                        } catch {
                            print("Failed to fetch library: \(error)")
                        }
                    } catch {
                        print("Failed to create directories: \(error)")
                        return
                    }
                    let defaults = UserDefaults.standard
                    if #available(iOS 17.0, *) {
                        if !sidejitserver {
                            isSideJITServerDetected { completion in
                                DispatchQueue.main.async {
                                    switch completion {
                                    case .success():
                                        let alert = UIAlertController(title: "SideJITServer", message: "SideJITServer has been found on your network would you like to enable support?", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                            showAlert = true
                                            sidejitserver = true
                                        })
                                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                        
                                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                                        // self.alert = true
                                        print("found sidejit: \(alert)")
                                    case .failure(_):
                                        print("no sidejit :(")
                                    }
                                }
                            }
                        }
                    }
                }
                .alert(isPresented: $entitlementNotExists) {
                    Alert(title: Text("Entitlement"), message: Text("You did not install this correctly it will crash please join the discord server for more informations."), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $alert) {
                    Alert(
                        title: Text("SideJITServer"),
                        message: Text("SideJITServer has been found on your network would you like to enable support."),
                        primaryButton: .default(Text("OK"), action: {
                            UserDefaults.standard.set(true, forKey: "sidejitserver-enable")
                        }),
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
                .alert(isPresented: $issue) {
                    Alert(title: Text("SideJITServer"), message: Text(alertstring), dismissButton: .default(Text("OK")))
                }
        }
    }
    
}

struct NavView: View {
    @Binding var cores: Core
    var body: some View {
        TabView {
            LibraryView(core: $cores)
                .tabItem {
                    Label("Games", systemImage: "rectangle.on.rectangle")
                }
            BootOSView(core: cores)
                .tabItem {
                    Label("Home Menu", systemImage: "house")
                }
            SettingsView(core: cores)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        
    }
}

func presentPomeloEmulation(PomeloGame: SudachiGame) {
    var backgroundColor: UIColor = .systemBackground
    let PomeloEmulationController = SudachiEmulationController(game: PomeloGame)
    PomeloEmulationController.modalPresentationStyle = .fullScreen
    
    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    
    ThemeLoader.shared.loadTheme { color in
        if let color = color {
            UserDefaults.standard.setValue(nil, forKey: "color")
            UserDefaults.standard.setColor(color, forKey: "color")
        }
    }

    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = scene.windows.first,
       let rootViewController = window.rootViewController {
        rootViewController.present(PomeloEmulationController, animated: true, completion: nil)
    }
}
