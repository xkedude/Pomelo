//
//  PomeloApp.swift
//  Pomelo
//
//  Created by Stossy11 on 15/6/2024.
//

import SwiftUI

@main
struct PomeloApp: App {
    @State private var cores: [Core] = []
    @AppStorage("entitlementNotExists") private var entitlementNotExists: Bool = false
    @State private var latestVersion: String?
    
    var body: some Scene {
        WindowGroup {
            
            LibraryView(core: $cores)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    fetchLatestVersion()
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
                .alert(isPresented: $entitlementNotExists) {
                    Alert(title: Text("Entitlement"), message: Text("You did not install this correctly it will crash please join the discord server for more informations."), dismissButton: .default(Text("OK")))
                }
        }
    }
    
    func fetchLatestVersion() {
        guard let url = URL(string: "https://api.github.com/repos/stossy11/Pomelo/releases/latest") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching latest version: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let tagName = json?["tag_name"] as? String {
                    DispatchQueue.main.async {
                        self.latestVersion = tagName
                        checkForUpdate(tagName)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}


func checkForUpdate(_ latestVersion: String) {
    if isNewVersionAvailable(latestVersion) {
        showUpdatePrompt()
    }
}

func isNewVersionAvailable(_ latestVersion: String) -> Bool {
    guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
        return false
    }
    
    // Compare versions
    return currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending
}

func showUpdatePrompt() {
    let alert = UIAlertController(title: "Update Available", message: "A new version is available on GitHub. Do you want to update?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
        if let url = URL(string: "https://github.com//stossy11/Pomelo/") {
            UIApplication.shared.open(url)
        }
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
}
