//
//  RoomState.swift
//  Connect4
//
//  Created by Filip Dabkowski on 09/04/2022.
//

import SwiftUI

class RoomState: ObservableObject {
    @Published var players: [Player]!
    @Published var me: Player!
    @Published var boardState: Array<Array<Int>>!
    @Published var roomNumber: Int!
    
    func roomReady() -> Bool {
        return self.players != nil && self.me != nil && self.boardState != nil && self.roomNumber != nil
    }
}

struct Player {
    var nick: String
    var number: Int
    var colorName: String
}
