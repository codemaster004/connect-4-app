//
//  WinRequest.swift
//  Connect4 (iOS)
//
//  Created by Filip Dabkowski on 30/03/2022.
//

import SwiftUI


class Network: ObservableObject {
    @Published var won: Bool!
    @Published var roomStatus: RoomStatus!
    
    func getRoomPlayers(roomNumber: Int) {
        guard let url = URL(string: "http://127.0.0.1:8000/status/\(roomNumber)") else { fatalError("Missing URL") }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            
            if let decodedData = try? JSONDecoder().decode(RoomStatus.self, from: data) {
                DispatchQueue.main.async {
                    self.roomStatus = decodedData
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

struct RoomStatus: Decodable, Equatable {
    static func == (lhs: RoomStatus, rhs: RoomStatus) -> Bool {
        if lhs.players.count != rhs.players.count {
            return false
        }
        for i in 0..<lhs.players.count {
            if lhs.players[i] != rhs.players[i] {
                return false
            }
        }
        
        return true
    }
    
    var players: [Player]
}
