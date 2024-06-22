//
//  LibraryView.swift
//  Pomelo
//
//  Created by Stossy11 on 16/6/2024.
//

import SwiftUI
import Foundation
import UIKit

struct Help : Comparable, Hashable, Identifiable {
    var id = UUID()
    
    let text, secondaryText, tertiaryText: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(secondaryText)
        hasher.combine(tertiaryText)
    }
    
    static func < (lhs: Help, rhs: Help) -> Bool {
        lhs.text < rhs.text
    }
    
    static func == (lhs: Help, rhs: Help) -> Bool {
        lhs.text == rhs.text
    }
}


struct CoreRowView: View {
    var core: Core

    var body: some View {
        VStack(alignment: .leading) {
            Text(core.name.rawValue)
                .font(.headline)
            Text(core.console.rawValue)
                .font(.subheadline)
        }
    }
}

struct GameRowView: View {
    var game: SudachiGame

    var body: some View {
        VStack {
            if let image = UIImage(data: game.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .frame(width: 48, height: 48)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(game.title)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 8)
                        .bold()
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    Text(game.developer)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 13))
                        .padding(.horizontal, 8) 
                        
                }
                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 200) // Adjust minHeight as needed
    }
}



struct CoreDetailView: View {
    var core: Core
    @State private var searchText = ""
    @State var ispoped = false

    var body: some View {
        let filteredGames = core.games.filter { game in
            if let sudachiGame = game as? SudachiGame {
                return searchText.isEmpty || sudachiGame.title.localizedCaseInsensitiveContains(searchText)
            }
            return false // Default case if the cast fails
        }
        
        VStack(alignment: .leading) {
            if core != nil {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 10) {
                    ForEach(0..<filteredGames.count, id: \.self) { index in
                        if let game = core.games[index] as? SudachiGame {
                            Button {
                                presentPomeloEmulation(PomeloGame: game)
                            } label: {
                                GameRowView(game: game)
                                    .frame(maxWidth: .infinity, minHeight: 200) // Set a consistent height for each row
                            }
                        }
                    }
                }
                .searchable(text: $searchText) // Add this line
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }
    
    
    func presentPomeloEmulation(PomeloGame: SudachiGame) {
        var backgroundColor: UIColor = .systemBackground
        let PomeloEmulationController = SudachiEmulationController(game: PomeloGame)
        PomeloEmulationController.modalPresentationStyle = .fullScreen
        
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
}


struct HelpRowView: View {
    var help: Help
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(help.text)
                .font(.headline)
            Text(help.secondaryText)
                .font(.subheadline)
            Text(help.tertiaryText)
                .font(.caption)
        }
    }
}

struct InfoView: View {
    @AppStorage("entitlementNotExists") private var entitlementNotExists: Bool = false
    @AppStorage("increaseddebugmem") private var increaseddebugmem: Bool = false
    @AppStorage("extended-virtual-addressing") private var extended: Bool = false
    let infoDictionary = Bundle.main.infoDictionary
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Welcome to Pomelo!")
                    .font(.largeTitle)
                Divider()
                Text("Entitlements:")
                    .font(.title)
                    .bold()
                Spacer()
                    .frame(height: 10)
                Group {
                    Text("Required:")
                        .font(.title2)
                        .foregroundColor(.red)
                        .bold()
                    Spacer()
                        .frame(height: 10)
                    Text("Increased Memory Limit: \(!entitlementNotExists)")
                    Spacer()
                        .frame(height: 10)
                }
                Group {
                    Spacer()
                        .frame(height: 10)
                    Text("Reccomended(paid):")
                        .font(.title2)
                        .bold()
                    Spacer()
                        .frame(height: 10)
                    Text("Increased Debugging Memory Limit: \(increaseddebugmem)")
                        .padding()
                    Text("Extended Virtual Addressing: \(extended)")
                }
                
            }.padding()
            
            Text("Version: \(getAppVersion())")
                .foregroundColor(.gray)
        }
    }
    func getAppVersion() -> String {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }
}

struct SideJITServerSettings: View {
    @AppStorage("sidejitserver-enable") var sidejitserver: Bool = false
    @AppStorage("sidejitserver-NavigationLink") var showAlert: Bool = false
    @AppStorage("sidejitserver-ip") var ip: String = ""
    @AppStorage("sidejitserver-udid") var udid: String = ""
    @AppStorage("sidejitserver-enable-auto") var sidejitserverauto: Bool = false
    @AppStorage("alertstring") var alertstring = ""
    @AppStorage("alert") var alert = false
    @AppStorage("issue") var issue = false
    var body: some View {
        VStack {
            Text("SideJITServer:")
                .font(.largeTitle)
            TextField("SideJITServer IP", text: $ip)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Text("This is not needed if SideJITServer has already been detected")
                .font(.subheadline)
                .foregroundColor(.secondary)
            SecureField("UDID", text: $udid)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                let defaults = UserDefaults.standard
                var sidejitip2 = ip
                DispatchQueue.global(qos: .userInteractive).async {
                    if sidejitip2.isEmpty {
                        sidejitip2 = "http://sidejitserver._http._tcp.local:8080"
                    }
                    if sidejitserver {
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
                                        alertstring = "SideJITServer Error: \((pContent))"
                                        issue = true
                                        print(message + " + " + String(pContent))
                                    } else {
                                        print(message)
                                        if !message.hasPrefix("JIT Already Enabled For") {
                                            alertstring = "SideJITServer Error: \(message)"
                                            issue = true
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }) {
                Label("Enable JIT with SideJITServer", systemImage: sidejitserverauto ? "checkmark" : "")
            }
            .padding()
            Button {
                var sidejitip2 = ip
                if sidejitip2.isEmpty {
                    sidejitip2 = "http://sidejitserver._http._tcp.local:8080"
                }
                
                guard udid.isEmpty else {
                    alertstring = "Cannot Find Current Device UDID please input it inside the SideJITServer Settings"
                    issue = true
                    showAlert = false
                    return
                }
                
                let sidejitip = sidejitip2 + "/re"
                sendrequestsidejit(url: sidejitip) { completion in
                    switch completion {
                    case .success(()):
                        print("yippee")
                        alert = true
                        showAlert = false
                    case .failure(let error):
                        switch error {
                        case .invalidURL:
                            alertstring = "Invalid URL"
                            issue = true
                            showAlert = false
                        case .errorConnecting:
                            alertstring = "Unable to connect to SideJITServer Please check that you are on the Same Wi-Fi and your Firewall has been set correctly"
                            issue = true
                            showAlert = false
                        case .deviceNotFound:
                            alertstring = "SideJITServer is unable to connect to your iDevice Please make sure you have paired your Device by doing 'SideJITServer -y' or try Refreshing SideJITServer from Settings"
                            issue = true
                            showAlert = false
                        case .other(let message):
                            if let startRange = message.range(of: "<p>"),
                               let endRange = message.range(of: "</p>", range: startRange.upperBound..<message.endIndex) {
                                let pContent = message[startRange.upperBound..<endRange.lowerBound]
                                //self.finish(.failure(OperationError.SideJITIssue(error: String(pContent))))
                                if message != "JIT already enabled for 'Pomelo'!" {
                                    alertstring = "SideJITServer Error: \((pContent))"
                                    issue = true
                                }
                                showAlert = false
                                print(message + " + " + String(pContent))
                                    
                            } else {
                                print(message)
                                if message != "JIT already enabled for 'Pomelo'!" {
                                    alertstring = "SideJITServer Error: \(message)"
                                    issue = true
                                    print(message)
                                }
                                    showAlert = false
                            }
                        }
                    }
                }
            } label: {
                Text("Refresh SideJITServer")
            }
        }
        .alert(isPresented: $issue) {
            Alert(title: Text("SideJITServer Refresh"), message: Text(alertstring), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $alert) {
            Alert(title: Text("SideJITServer Refresh"), message: Text("SideJITServer Refreshed Successfully"), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("SideJITServer Settings")
    }
}


struct LibraryView: View {
    @Binding var core: Core
    @State var showingEditConfig = false
    @State private var isActive: Bool = false
    @State private var showprompt: Bool = false
    @AppStorage("sidejitserver-enable") var sidejitserver: Bool = false
    @AppStorage("sidejitserver-NavigationLink") var showAlert: Bool = false
    @AppStorage("sidejitserver-ip") var ip: String = ""
    @AppStorage("sidejitserver-udid") var udid: String = ""
    @AppStorage("sidejitserver-enable-auto") var sidejitserverauto: Bool = false
    @AppStorage("alertstring") var alertstring = ""
    @AppStorage("alert") var alert = false
    @AppStorage("issue") var issue = false

    var body: some View {
        NavigationView {
            VStack {
                let (doesKeyExist, doesProdExist) = doeskeysexist()
                if doesKeyExist && doesProdExist {
                    ScrollView {
                        CoreDetailView(core: core)
                    }
                } else {
                    Text("You Are Missing These Files:")
                        .font(.headline)
                        .foregroundColor(.red)
                    if doesKeyExist && !doesProdExist {
                        Text("Prod.keys")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    if !doesKeyExist && !doesProdExist {
                        Text("Prod.keys and Title.keys")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    if !doesKeyExist && doesProdExist {
                        Text("Title.keys")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    Text("These goes into the Keys folder")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
            }
            .navigationBarTitle("Library", displayMode: .inline)
            
        }
        
    }
    
    
    
    func doeskeysexist() -> (Bool, Bool) {
        var doesprodexist = false
        var doestitleexist = false
        if core != nil {
            let title = core.root.appendingPathComponent("keys").appendingPathComponent("title.keys")
            let prod = core.root.appendingPathComponent("keys").appendingPathComponent("prod.keys")
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            if fileManager.fileExists(atPath: prod.path) {
                doesprodexist = true
            } else {
                print("File does not exist")
            }
            
            if fileManager.fileExists(atPath: title.path) {
                doestitleexist = true
            } else {
                print("File does not exist")
            }
        }
        return((doestitleexist, doesprodexist))
    }
}

struct INIEditControllerWrapper: UIViewControllerRepresentable {
    let console: Core.Console // Replace Console with your actual type
    let configURL: URL

    func makeUIViewController(context: Context) -> UINavigationController {
        let iniEditController = INIEditController(console: console, url: configURL)
        let navController = UINavigationController(rootViewController: iniEditController)
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Update the view controller if needed
    }
}


