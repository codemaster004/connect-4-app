//
//  Connect4App.swift
//  Shared
//
//  Created by Filip Dabkowski on 28/03/2022.
//

import SwiftUI

@main
struct Connect4App: App {
    var network = Network()
    var gameState = GameState()
//    var roomState = RoomState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(network)
                .environmentObject(gameState)
//                .environmentObject(roomState)
        }
    }
}
