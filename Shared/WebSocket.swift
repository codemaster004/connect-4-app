//
//  WebSocket.swift
//  Connect4
//
//  Created by Filip Dabkowski on 09/04/2022.
//

import Combine
import Foundation

final class GameSocket: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    
    @Published var playerMove: MoveAction?
    @Published var newPlayer: Player?
    
    func connect(roomNumber: Int) {
        let url = URL(string: "ws://127.0.0.1:8000/ws/play/\(String(roomNumber))/")!
        print("Connecting to room \(roomNumber)") 
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.receive(completionHandler: onReceive)
        webSocketTask?.resume()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }

    private func onReceive(incoming: Result<URLSessionWebSocketTask.Message, Error>) {
        webSocketTask?.receive(completionHandler: onReceive)
        if case .success(let event) = incoming {
            onEvent(event: event)
        }
        else if case .failure(let error) = incoming {
            print("Error", error)
        }
    }
    
    deinit {
        disconnect()
    }
    
    func send(action: SubmitAction) {
        print(action)
        guard let json = try? JSONEncoder().encode(action),
            let jsonString = String(data: json, encoding: .utf8)
        else {
            print("Error encoding player move")
            return
        }
        print("Action parsed")
        
        webSocketTask?.send(.string(jsonString)) { error in
            if let error = error {
                print("Error sending data", error)
            }
        }
    }
    
    func onEvent(event: URLSessionWebSocketTask.Message) {
        if case .string(let text) = event {
            guard let data = text.data(using: .utf8),
                let playerAction = try? JSONDecoder().decode(ReceiveAction.self, from: data)
            else {
                return
            }
            
//            let event = playerAction.payload.event
            
            DispatchQueue.main.async {
//                print("Handling socket event")
//                if event == "JOIN" {
//                    print("Event: JOIN")
//                    print(playerAction.payload.action.player)
                    self.newPlayer = playerAction.payload.action.player
//                    self.playerMove = playerAction.payload.action
//                }
            }
        }
    }
}
