//
//  LibraryView.swift
//  Pomelo
//
//  Created by Stossy11 on 
//  Copyright © 2024 Stossy11. All rights reserved.13/7/2024.
//

import SwiftUI

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

