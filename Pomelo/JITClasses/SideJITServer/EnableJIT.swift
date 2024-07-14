//
//  EnableJIT.swift
//  Pomelo
//
//  Created by Stossy11 on 16/6/2024.
//

import Foundation

enum SideJITServerErrorType: Error {
     case invalidURL
     case errorConnecting
     case deviceNotFound
     case other(String)
 }



func sendrequestsidejit(url: String, completion: @escaping (Result<Void, SideJITServerErrorType>) -> Void) {
    let url = URL(string: url)!

    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        if let error = error {
            completion(.failure(.errorConnecting))
            return
        }
        
        guard let data = data, let datastring = String(data: data, encoding: .utf8) else { return }
        
        if datastring == "Enabled JIT for 'Pomelo'!" {
            completion(.success(()))
        } else {
            let errorType: SideJITServerErrorType = datastring == "Could not find device!" ? .deviceNotFound : .other(datastring)
            completion(.failure(errorType))
        }
    }

    task.resume()
}


func sendrefresh(url: String, completion: @escaping (Result<Void, SideJITServerErrorType>) -> Void) {
    let url = URL(string: url)!

    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        if let error = error {
            completion(.failure(.errorConnecting))
            return
        }
        
        guard let data = data, let datastring = String(data: data, encoding: .utf8) else { return }
        let inputText = "{\"OK\":\"Refreshed!\"}"
        if datastring == inputText {
            completion(.success(()))
        } else {
            let errorType: SideJITServerErrorType = datastring == "Could not find device!" ? .deviceNotFound : .other(datastring)
            completion(.failure(errorType))
        }
    }

    task.resume()
}
