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
    @Published var removedPlayer: Player?
    @Published var startingPlayer: Player?
    @Published var socketActive = false
    
    private var reconnectTries = 0
    private var roomNumber = 0
    
    func connect(roomNumber: Int) {
        print("Conecting")
        let url = URL(string: "ws://127.0.0.1:8000/ws/play/\(String(roomNumber))/")!
        self.roomNumber = roomNumber
        print("Connecting to room \(roomNumber)") 
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.receive(completionHandler: onReceive)
        webSocketTask?.resume()
        DispatchQueue.main.async {
            self.socketActive = true
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }

    private func onReceive(incoming: Result<URLSessionWebSocketTask.Message, Error>) {
        webSocketTask?.receive(completionHandler: onReceive)
        if case .success(let event) = incoming {
            onEvent(event: event)
            
            self.reconnectTries = 0
        }
        else if case .failure(let error) = incoming {
            print("Some socket error:", error.localizedDescription)
            self.disconnect()
            
            // TODO: change to time counting
            if self.reconnectTries <= 10000 {
                self.reconnectTries += 1
                self.connect(roomNumber: self.roomNumber)
            } else {
                DispatchQueue.main.async {
                    self.socketActive = false
                }
            }
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
            print("Error Encoding player move")
            return
        }
        
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
                print("Error Decoding player move")
                return
            }
            
            let playerEvent = playerAction.payload.event
            print(playerEvent)
            
            DispatchQueue.main.async {
                if playerEvent == "JOIN" {
                    self.newPlayer = playerAction.payload.action.player
                }
                if playerEvent == "LEAVE" {
                    self.removedPlayer = playerAction.payload.action.player
                }
                if playerEvent == "START" {
                    self.startingPlayer = playerAction.payload.action.player
                }
            }
        }
    }
}
