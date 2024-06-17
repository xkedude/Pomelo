//
//  ContentView.swift
//  Pomelo
//
//  Created by Stossy11 on 15/6/2024.
//

import SwiftUI
import UIKit


struct ContentView: View {
    @Binding var cores: [Core]
    @Binding var showAlert: Bool
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

