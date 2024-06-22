//
//  ContentView.swift
//  Pomelo
//
//  Created by Stossy11 on 15/6/2024.
//

import CarPlay
import SwiftUI
import UIKit


struct ContentView: View {
    @State private var cores: Core
    @State var showAlert = false
    @AppStorage("sidejitserver-enable") var sidejitserver: Bool = false
    @AppStorage("sidejitserver-ip") var ip: String = ""
    @AppStorage("sidejitserver-udid") var udid: String = ""
    @AppStorage("alertstring") var alertstring = ""
    @AppStorage("alert") var alert = false
    @AppStorage("issue") var issue = false
    
    var body: some View {
        LibraryView(core: $cores)
            .alert(isPresented: $alert) {
                Alert(
                    title: Text("SideJITServer"),
                    message: Text("SideJITServer has been found on your network would you like to enable support."),
                    primaryButton: .default(Text("OK"), action: {
                        let defaults = UserDefaults.standard
                        sidejitserver = true
                    }),
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
            .alert(isPresented: $issue) {
                Alert(title: Text("SideJITServer"), message: Text(alertstring), dismissButton: .default(Text("OK")))
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear() {
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
            }
    }
}


struct BootOSView: View {
    @State var core: Core?
    var body: some View {
       Text("beans")
            .onAppear {
                if let core = core {
                    let PomeloGame = SudachiGame(core: core, developer: "", fileURL: URL(string: "{")!, imageData: Data(), title: "")
                    presentPomeloEmulation(PomeloGame: PomeloGame)
                }
            }
    }
}

func presentPomeloEmulation(PomeloGame: SudachiGame) {
    var backgroundColor: UIColor = .systemBackground
    let PomeloEmulationController = SudachiEmulationController(game: PomeloGame)
    PomeloEmulationController.modalPresentationStyle = .fullScreen
    
    ThemeLoader.shared.loadTheme { color in
        if let color = color {
            UserDefaults.standard.setValue(nil, forKey: "color")
            UserDefaults.standard.setColor(color, forKey: "color")
            backgroundColor = color
        }
    }

    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = scene.windows.first,
       let rootViewController = window.rootViewController {
        rootViewController.present(PomeloEmulationController, animated: true, completion: nil)
    }
}
