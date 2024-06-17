//
//  DetectServer.swift
//  Pomelo
//
//  Created by Stossy11 on 16/6/2024.
//

import Foundation


func isSideJITServerDetected(completion: @escaping (Result<Void, Error>) -> Void) {
    let address = UserDefaults.standard.string(forKey: "sidejitserver") ?? ""
    
    var SJSURL = address
    
    if (address).isEmpty {
      SJSURL = "http://sidejitserver._http._tcp.local:8080"
    }
    
    // Create a network operation at launch to Refresh SideJITServer
    let url = URL(string: SJSURL)!
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("No SideJITServer on Network")
            completion(.failure(error))
            return
        }
        completion(.success(()))
    }
    task.resume()
    return
}
