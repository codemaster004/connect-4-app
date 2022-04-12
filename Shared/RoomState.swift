//
//  RoomState.swift
//  Connect4
//
//  Created by Filip Dabkowski on 09/04/2022.
//

import SwiftUI

class RoomState: ObservableObject {
    @Published var players: [Player]?
    @Published var me: Player!
    @Published var boardState: Array<Array<Int>>!
    @Published var roomNumber: Int! = 0
    
    func roomReady() -> Bool {
        return self.players != nil && self.me != nil && self.roomNumber != nil
    }
    
    func reset() {
        self.players = []
        self.me = nil
        self.boardState = []
        self.roomNumber = 0
    }
}

struct Player: Encodable, Decodable, Equatable {
    var nick: String
    var number: Int
    var colorName: String
}
