//
//  PomeloApp.swift
//  Pomelo
//
//  Created by Stossy11 on 15/6/2024.
//

import SwiftUI
import Foundation

func registerDefaultsFromSettingsBundle()
{
    let settingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
    let settingsPlist = NSDictionary(contentsOf:settingsUrl)!
    let preferences = settingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
    
    var defaultsToRegister = Dictionary<String, Any>()
    
    for preference in preferences {
        guard let key = preference["sidejitserver-enable"] as? String else {
            NSLog("Key not found")
            continue
        }
        defaultsToRegister[key] = preference[false]
    }
    UserDefaults.standard.register(defaults: defaultsToRegister)
}

@main
struct PomeloApp: App {
    @State private var cores: [Core] = []
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
            LibraryView(core: $cores)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    registerDefaultsFromSettingsBundle()
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
                        if sidejitserverauto {
                            var sidejitip2 = ip
                            DispatchQueue.global(qos: .userInteractive).async {
                                if sidejitip2.isEmpty {
                                    sidejitip2 = "http://sidejitserver._http._tcp.local:8080"
                                }
                                
                                guard udid.isEmpty else {
                                    alertstring = "Cannot Find Current Device UDID please input it inside the SideJITServer Settings"
                                    issue = true
                                    return
                                }
                                
                                    let sidejitip = sidejitip2 + "/" + udid + "/Pomelo/"
                                    print(sidejitip)
                                sendrequestsidejit(url: sidejitip) { completion in
                                    switch completion {
                                    case .success(()):
                                        print("yippee")
                                    case .failure(let error):
                                        switch error {
                                        case .invalidURL:
                                            alertstring = "Invalid URL"
                                            issue = true
                                        case .errorConnecting:
                                            alertstring = "Unable to connect to SideJITServer Please check that you are on the Same Wi-Fi and your Firewall has been set correctly"
                                            issue = true
                                        case .deviceNotFound:
                                            alertstring = "SideJITServer is unable to connect to your iDevice Please make sure you have paired your Device by doing 'SideJITServer -y' or try Refreshing SideJITServer from Settings"
                                            issue = true
                                        case .other(let message):
                                            if let startRange = message.range(of: "<p>"),
                                               let endRange = message.range(of: "</p>", range: startRange.upperBound..<message.endIndex) {
                                                let pContent = message[startRange.upperBound..<endRange.lowerBound]
                                                //self.finish(.failure(OperationError.SideJITIssue(error: String(pContent))))
                                                if message != "JIT already enabled for 'Pomelo'!" {
                                                    alertstring = "SideJITServer Error: \(pContent)"
                                                    issue = true
                                                    print(message)
                                                }
                                                print(message + " + " + String(pContent))
                                            } else {
                                                print(message)
                                                if message != "JIT already enabled for 'Pomelo'!" {
                                                    alertstring = "SideJITServer Error: \(message)"
                                                    issue = true
                                                    print(message)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
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
    
    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
}
