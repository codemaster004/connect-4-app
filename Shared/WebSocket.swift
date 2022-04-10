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
    
    @Published private(set) var playerMove: MoveAction?
    
    func connect() {
        let url = URL(string: "ws://127.0.0.1:8000/ws/play/20/")!
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
    
    private func send(jsonString: String) {
        webSocketTask?.send(.string(jsonString)) { error in
            if let error = error {
                print("Error sending data", error)
            }
        }
    }
    
    private func onEvent(event: URLSessionWebSocketTask.Message) {
        if case .string(let text) = event {
            guard let data = text.data(using: .utf8),
                let playerAction = try? JSONDecoder().decode(ReceiveAction.self, from: data)
            else {
                return
            }

            DispatchQueue.main.async {
                print("Updating player action")
                self.playerMove = playerAction.payload.action
            }
        }
    }
}

extension GameSocket {
    func sendPlayerMove(playerNo: Int, columnNo: Int) {
        let action = SubmitAction(event: "MOVE", action: MoveAction(player: playerNo, column: columnNo), message: "")
        
        guard let json = try? JSONEncoder().encode(action),
            let jsonString = String(data: json, encoding: .utf8)
        else {
            print("Error encoding player move")
            return
        }
        
        self.send(jsonString: jsonString)
    }
}
