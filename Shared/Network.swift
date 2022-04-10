//
//  WinRequest.swift
//  Connect4 (iOS)
//
//  Created by Filip Dabkowski on 30/03/2022.
//

import SwiftUI


class Network: ObservableObject {
    @Published var won: Bool!
    
    func checkForWinner(board: Dictionary<Int, Array<Int>>, x: Int, y: Int) {
        guard let url = URL(string: "http://127.0.0.1:5001/check_win") else { fatalError("Missing URL") }
        
        let json = RequestData(board: board, last_move: ["x": x, "y": y])
        
        let jsonData = try? JSONEncoder().encode(json)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            
            if let decodedData = try? JSONDecoder().decode(WonResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.won = decodedData.won
                    print(self.won ?? false)
                }

                return
            }

            print("Fetch data: \(error?.localizedDescription ?? "Unknown Error")")
        }.resume()
    }
    
    func getAiPrediction(board: Array<Array<Int>>, depth: Int) {
        guard let url = URL(string: "http://127.0.0.1:5001/check_win") else { fatalError("Missing URL") }
        
        let json = PredictRequestData(board: board, depth: depth)
        
        let jsonData = try? JSONEncoder().encode(json)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            
            if let decodedData = try? JSONDecoder().decode(WonResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.won = decodedData.won
                    print(self.won ?? false)
                }

                return
            }

            print("Fetch data: \(error?.localizedDescription ?? "Unknown Error")")
        }.resume()
    }
}

struct RequestData: Encodable {
    var board: Dictionary<Int, Array<Int>>
    var last_move: Dictionary<String, Int>
}

struct PredictRequestData: Encodable {
    var board: Array<Array<Int>>
    var depth: Int
}

struct WonResponse: Decodable {
    var won: Bool
}
