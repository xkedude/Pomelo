//
//  CoreSettingsView.swift
//  Pomelo
//
//  Created by Stossy11 on 14/7/2024.
//

import SwiftUI
import Foundation

struct ConfigEntry {
    var title: String?
    var value: Any?
}

struct CoreSettingsView: View {
    @State var configEntries: [ConfigEntry] = parseConfigFile() ?? []
    
    var body: some View {
     //   NavigationView {
            List {
                ForEach(configEntries.indices, id: \.self) { index in
                    if configEntries[index].value == nil {
                        if let title = configEntries[index].title {
                            Text(title)
                                .font(.title)
                                .bold()
                        }
                    } else {
                        if let title = configEntries[index].title {
                            if let value = configEntries[index].value as? Bool {
                                Toggle(isOn: Binding(
                                    get: { self.configEntries[index].value as? Bool ?? false },
                                    set: { let toggle = toggleValueChanged($0, for: title)
                                        self.configEntries[index].value = toggle
                                    }
                                )) {
                                    
                                    Text(title)
                                   
                                }
                            } else if let value = configEntries[index].value as? Int {
                                HStack {
                                
                                    Text(title)
                                    Spacer()
                                    TextField("", value: Binding(
                                        get: { self.configEntries[index].value as? Int ?? 0 },
                                        set: { let number = numberValueChanged($0, for: title)
                                            self.configEntries[index].value = number
                                        }
                                    ), formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                }
                                Spacer()
                            } else if let value = configEntries[index].value as? String {
                                HStack {
                                    Text(title)
                                    Spacer()
                                    TextField("", text: Binding(
                                        get: { self.configEntries[index].value as? String ?? "" },
                                        set: { let text = textValueChanged($0, for: title)
                                            self.configEntries[index].value = text
                                        }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                }
                                
                            }
                        } else {
                            Text(configEntries[index].value as? String ?? "")
                        }
                    }
                }
            }
            .navigationBarTitle("Config Entries")
       
            .onAppear() {
                configEntries = parseConfigFile() ?? []
            }
      
        }
    }
    
    private func toggleValueChanged(_ newValue: Bool, for title: String) -> Bool {
        return updateConfigFile(newValue: newValue ? "1" : "0", for: title)
    }
    
    private func numberValueChanged(_ newValue: Int, for title: String) -> Int {
        return updateConfigFile(newValue: "\(newValue)", for: title) ? newValue : 0
    }
    
    private func textValueChanged(_ newValue: String, for title: String) -> String {
        return updateConfigFile(newValue: newValue, for: title) ? newValue : ""
    }
    
    private func updateConfigFile(newValue: String, for title: String) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent("config").appendingPathComponent("config.ini")

        do {
            var configFileContents = try String(contentsOf: fileURL, encoding: .utf8)
            var updatedConfigFile = ""
            
            let lines = configFileContents.components(separatedBy: .newlines)
            
            for line in lines {
                var updatedLine = line
                
                let components = line.components(separatedBy: "=")
                guard components.count == 2 else {
                    updatedConfigFile += "\(updatedLine)\n"
                    continue
                }
                
                let configTitle = components[0].trimmingCharacters(in: .whitespaces)
                var configValue = components[1].trimmingCharacters(in: .whitespaces)
                
                if configTitle == title {
                    configValue = newValue
                    updatedLine = "\(configTitle) = \(configValue)"
                }
                
                updatedConfigFile += "\(updatedLine)\n"
            }
            
            // Write the updated content back to the file
            try updatedConfigFile.write(to: fileURL, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Error updating config file: \(error.localizedDescription)")
            return false
        }
    }
//}

func parseConfigFile() -> [ConfigEntry]? {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsDirectory.appendingPathComponent("config").appendingPathComponent("config.ini")

    do {
        let configFileContents = try String(contentsOf: fileURL, encoding: .utf8)
        var configEntries: [ConfigEntry] = []
        let lines = configFileContents.components(separatedBy: .newlines)

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmedLine.isEmpty || trimmedLine.starts(with: ";") || trimmedLine.starts(with: "#") {
                continue
            } else if trimmedLine.starts(with: "[") && trimmedLine.last == "]" {
                let currentSection = String(trimmedLine.dropFirst().dropLast())
                configEntries.append(ConfigEntry(title: currentSection, value: nil))
            } else {
                let components = trimmedLine.components(separatedBy: "=")
                guard components.count == 2 else { continue }

                let title = components[0].trimmingCharacters(in: .whitespaces)
                var value: Any = components[1].trimmingCharacters(in: .whitespaces)

                if value as? String == "1" {
                    value = true
                } else if value as? String == "0" {
                    value = false
                } else if let intValue = Int(value as? String ?? "") {
                    value = intValue
                }

                configEntries.append(ConfigEntry(title: title, value: value))
            }
        }
        return configEntries
    } catch {
        print("Error reading config file: \(error.localizedDescription)")
        return nil
    }
}
