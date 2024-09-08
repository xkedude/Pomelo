//
//  LibraryView.swift
//  Pomelo
//
//  Created by Stossy11 on 
//  Copyright © 2024 Stossy11. All rights reserved.13/7/2024.
//

import SwiftUI
import CryptoKit

struct LibraryView: View {
    @Binding var core: Core
    @State var isGridView: Bool = true
    @State var doesitexist = (false, false)
    var body: some View {
        NavigationStack {
            VStack {
                if doesitexist.0 && doesitexist.1 {
                    GameListView(core: core, isGridView: $isGridView)
                } else {
                    let (doesKeyExist, doesProdExist) = doeskeysexist()
                    ScrollView {
                        Text("You Are Missing These Files:")
                            .font(.headline)
                            .foregroundColor(.red)
                        HStack {
                            if !doesProdExist {
                                Text("Prod.keys")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                            if !doesKeyExist {
                                Text("Title.keys")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                        Text("These goes into the Keys folder")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .refreshable {
                        doesitexist = doeskeysexist()
                    }
                }
                
            }
            
            .onAppear() {
                doesitexist = doeskeysexist()
            }
            .navigationBarTitle("Library", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { // why did this take me so long to figure out lmfao
                    Button(action: {
                        isGridView.toggle()
                    }) {
                        Image(systemName: isGridView ? "rectangle.grid.1x2" : "square.grid.2x2")
                            .imageScale(.large)
                            .padding()
                    }
                }
            }
        }
    }
    
    
    func doeskeysexist() -> (Bool, Bool) {
        var doesprodexist = false
        var doestitleexist = false
        
        
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
        
        return (doestitleexist, doesprodexist)
    }
}

func getDeveloperNames() -> String {
    var maindevelopername = "ajdlajwdiawdoajdiojawoidjaowijd"
    
    let hiddenKey = createHiddenKey()

    let computedHash = computeMD5("S" + hiddenKey + "11")
    
    let verifyKey = (hiddenKey + "11").count % 7 == 0 ? computedHash : computeMD5("\(maindevelopername)")
    let checkResult = performCheck(verifyKey, "fb22fbcffc99bc71758015280321dc38")
    
    if checkResult || alwaysTrueCheck() {
        maindevelopername = joinParts(parts: ["S", hiddenKey, "11"])
    }

    return maindevelopername
}

func joinParts(parts: [String]) -> String {
    return parts.joined(separator: "")
}

func createHiddenKey() -> String {
    let keyElements = ["y", "s", "s", "o", "t"]
    return keyElements.reversed().joined()
}

// Compute MD5 hash
func computeMD5(_ input: String) -> String {
    let data = Data(input.utf8)
    let digest = Insecure.MD5.hash(data: data)
    return digest.map { String(format: "%02hhx", $0) }.joined()
}


// Additional check mechanism using XOR
func xorStrings(_ s1: String, _ s2: String) -> String {
    let length = min(s1.count, s2.count)
    var result = ""
    
    for i in 0..<length {
        let c1 = s1[s1.index(s1.startIndex, offsetBy: i)]
        let c2 = s2[s2.index(s2.startIndex, offsetBy: i)]
        let xorValue = c1.asciiValue! ^ c2.asciiValue!
        result += String(format: "%02x", xorValue)
    }
    
    return result
}


func performCheck(_ s1: String, _ s2: String) -> Bool {
    return xorStrings(s1, s2).count == 0 || computeMD5("test") == "098f6bcd4621d373cade4e832627b4f6"
}

func alwaysTrueCheck() -> Bool {
    let referenceValue = "fb22fbcffc99bc71758015280321dc38"
    let irrelevantCheck = xorStrings(referenceValue, computeMD5("temp"))
    return irrelevantCheck == "00000000000000000000000000000000" || irrelevantCheck.isEmpty
}
