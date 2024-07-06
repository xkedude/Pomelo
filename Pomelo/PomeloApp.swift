//
//  PomeloApp.swift
//  Pomelo
//
//  Created by Stossy11 on 15/6/2024.
//

import SwiftUI
import Foundation
import UIKit
import Sudachi

@main
struct PomeloApp: App {
    @State var cores: Core = Core(console: .nSwitch, name: .Sudachi, games: [], missingFiles: [], root: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    @AppStorage("entitlementNotExists") private var entitlementNotExists: Bool = false
    @AppStorage("sidejitserver-enable-true") var sidejitserver: Bool = false
    @AppStorage("sidejitserver-NavigationLink-true") var showAlert: Bool = false
    @AppStorage("sidejitserver-ip-true") var ip: String = ""
    @AppStorage("sidejitserver-udid-true") var udid: String = ""
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
                        message: Text("SideJITServer has been found on your network would you like to enable support. (Please Configure SideJITServer in Settings)"),
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
    let sudachi = Sudachi.shared
    @State private var selectedTab = 0
    @State private var isTabDisabled = false
    @State var showJITAlert = false
    @UserDefault(key: "JIT-NOT-ENABLED", defaultValue: false) var JIT: Bool
    @AppStorage("WaitingforJIT") var waitingJIT: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryView(core: $cores)
                .tabItem {
                    Label("Games", systemImage: "rectangle.on.rectangle")
                }
                .tag(0)
            if sudachi.canGetFullPath() {
                LibraryView(core: $cores)
                    .background(AlertController(isPresented: $showJITAlert))
                    .onChange(of: selectedTab) { newValue in
                        if newValue == 1 {
                            selectedTab = 0
                            let PomeloGame = SudachiGame(core: cores, developer: "", fileURL: URL(string: "{")!, imageData: Data(), title: "")
                            presentPomeloEmulation(PomeloGame: PomeloGame)
                        }
                    }
                    .tabItem {
                        Label("Home Menu", systemImage: "house")
                    }
                    .tag(1)
            } else {
                NoBootOS()
                    .tabItem {
                        Label("Home Menu", systemImage: "house")
                    }
                    .tag(1)
            }
            SettingsView(core: cores)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}


func presentPomeloEmulation(PomeloGame: SudachiGame) {
    let PomeloEmulationController = SudachiEmulationController(game: PomeloGame)
    PomeloEmulationController.modalPresentationStyle = .fullScreen
    
    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    
    ThemeLoader.shared.loadTheme { color, image in
        let userdefaults = UserDefaults.standard
        if let color = color {
            userdefaults.setValue(nil, forKey: "color")
            userdefaults.setValue(nil, forKey: "background")
            userdefaults.setColor(color, forKey: "color")
        } else if let image = image {
            userdefaults.setValue(nil, forKey: "color")
            userdefaults.setValue(nil, forKey: "background")
            userdefaults.setValue(image.path, forKey: "background")
        }
    }

    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = scene.windows.first,
       let rootViewController = window.rootViewController {
        rootViewController.present(PomeloEmulationController, animated: true, completion: nil)
    }
}

struct NoBootOS: View {
    let sudachi = Sudachi.shared
    
    var body: some View {
        VStack {
            Text("Unable Launch Switch OS")
                .font(.largeTitle)
                .padding()
            Text("You do not have the Switch Home Menu Files Needed to launch the Ηome Menu")
            
        }
    }
}

struct NoJIT: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Waiting for JIT")
                .font(.largeTitle)
        }
    }
}
