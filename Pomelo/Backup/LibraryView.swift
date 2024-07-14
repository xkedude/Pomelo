//
//  LibraryView.swift
//  Pomelo
//
//  Created by Stossy11 on 16/6/2024.
//

import SwiftUI
import Foundation
import UIKit
import UniformTypeIdentifiers


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
    @State var core: Core
    @State private var searchText = ""
    @State var ispoped = false
    @State var game: SudachiGame? = nil
    @AppStorage("JIT-NOT-ENABLED") var JIT = false
    @State var ShowPopup = false
    @AppStorage("WaitingforJIT") var waitingJIT: Bool = false

    var body: some View {
        let filteredGames = core.games.filter { game in
            if let sudachiGame = game as? SudachiGame {
                return searchText.isEmpty || sudachiGame.title.localizedCaseInsensitiveContains(searchText)
            }
            return false // Default case if the cast fails
        }
        ScrollView {
            VStack(alignment: .leading) {
                if core != nil {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 10) {
                        ForEach(0..<filteredGames.count, id: \.self) { index in
                            if let game = core.games[index] as? SudachiGame {
                                /*
                                NavigationLink(destination: SudachiEmulationView(game: PomeloGame)) {
                                    GameRowView(game: game)
                                        .frame(maxWidth: .infinity, minHeight: 200) // Set a consistent height for each row
                                }
                                 */
                                Button {
                                    if waitingJIT {
                                        self.game = game
                                        // ispoped = true
                                        presentPomeloEmulation(PomeloGame: game)
                                    } else {
                                        if !JIT {
                                            self.game = game
                                            // ispoped = true
                                            presentPomeloEmulation(PomeloGame: game)
                                        } else {
                                            ShowPopup = true
                                        }
                                    }
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
        .background(AlertController(isPresented: $ShowPopup))
        .onAppear() {
            core = Core(console: Core.Console.nSwitch, name: .Sudachi, games: [], missingFiles: [], root: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(string: "/")!)
            do {
                core = try LibraryManager.shared.library()
            } catch {
                print("Failed to fetch library: \(error)")
            }
        }
        .refreshable {
            core = Core(console: Core.Console.nSwitch, name: .Sudachi, games: [], missingFiles: [], root: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(string: "/")!)
            do {
                core = try LibraryManager.shared.library()
            } catch {
                print("Failed to fetch library: \(error)")
            }
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
    @AppStorage("sidejitserver-enable-true") var sidejitserver: Bool = false
    @AppStorage("sidejitserver-NavigationLink-true") var showAlert: Bool = false
    @AppStorage("sidejitserver-ip-true") var ip: String = ""
    @AppStorage("sidejitserver-udid-true") var udid: String = ""
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
                .padding(.top)
            Text("This is not needed if SideJITServer has already been detected")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom)
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

extension UTType {
    static var nro: UTType {
        UTType(exportedAs: "com.stossy11.nro")
    }
    static var nca: UTType {
        UTType(exportedAs: "com.stossy11.nca")
    }
    static var nso: UTType {
        UTType(exportedAs: "com.stossy11.nso")
    }
    static var nsp: UTType {
        UTType(exportedAs: "com.stossy11.nsp")
    }
    static var xci: UTType {
        UTType(exportedAs: "com.stossy11.xci")
    }
    static var keys: UTType {
        UTType(exportedAs: "com.stossy11.keys")
    }
}


struct LibraryView: View {
    @Binding var core: Core
    @State var showingEditConfig = false
    @State private var isActive: Bool = false
    @State private var isimport: Bool = false
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
        NavigationStack {
            VStack {
                let (doesKeyExist, doesProdExist) = doeskeysexist()
                if doesKeyExist && doesProdExist {
                    CoreDetailView(core: core)
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
            .fileImporter(isPresented: $isimport, allowedContentTypes: [.data], onCompletion: { result in
                switch result {
                case .success(let file):
                    if file.startAccessingSecurityScopedResource() {
                        moveFileToAppropriateFolder(file)
                        file.stopAccessingSecurityScopedResource()
                    } else {
                        print("Failed to access the file")
                    }
                    
                case .failure(let error):
                    isimport = false
                    print(error.localizedDescription)
                }
                //moveFileToAppropriateFolder()
            })
            .navigationBarTitle("Library", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isimport = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
        }
        
    }
    
    private func moveFileToAppropriateFolder(_ fileURL: URL) {
           let fileManager = FileManager.default
           let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
           
           let romsDirectory = documentsDirectory.appendingPathComponent("roms")
           let keysDirectory = documentsDirectory.appendingPathComponent("keys")
           
           let fileExtension = fileURL.pathExtension.lowercased()
           if ["nca", "nro", "nso", "nsp", "xci"].contains(fileExtension) {
               do {
                   try fileManager.copyItem(at: fileURL, to: romsDirectory.appendingPathComponent(fileURL.lastPathComponent))
               } catch {
                   print("Error moving file to roms folder: \(error.localizedDescription)")
               }
           } else if fileExtension == "keys" {
               do {
                   try fileManager.copyItem(at: fileURL, to: keysDirectory.appendingPathComponent(fileURL.lastPathComponent))
               } catch {
                   print("Error moving file to keys folder: \(error.localizedDescription)")
               }
           }
       }
    
    
    func doeskeysexist() -> (Bool, Bool) {
        var doesprodexist = false
        var doestitleexist = false
        var bean: [MissingFile] = []
        
        
        if #available(iOS 17, *) {
            do {
                bean = try LibraryManager.shared.library().missingFiles
            } catch {
                print("uhoh stinky")
            }
            
            print(bean.count)
            print(bean)
            
            // Check if "prod.keys" is missing
            doesprodexist = !bean.contains { $0.fileName == "prod.keys" && $0.directory.lastPathComponent == "keys" }
            if !doesprodexist {
                print("prod.keys does not exist")
            }
            
            // Check if "title.keys" is missing
            doestitleexist = !bean.contains { $0.fileName == "title.keys" && $0.directory.lastPathComponent == "keys" }
            if (!doestitleexist) {
                print("title.keys does not exist")
            }
            return (doestitleexist, doesprodexist)
        } else {
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
        return (doestitleexist, doesprodexist)
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

struct AlertController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let alert = UIAlertController(title: "Waiting for JIT", message: "Pomelo Needs Just-in-time compilation for the Emulation to run.", preferredStyle: .alert)

            uiViewController.present(alert, animated: true, completion: nil)
        }

        if !isPresented && uiViewController.presentedViewController != nil {
            uiViewController.dismiss(animated: true, completion: nil)
        }
    }
}
