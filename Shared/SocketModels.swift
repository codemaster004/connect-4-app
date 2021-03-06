//
//  SocketModels.swift
//  Connect4
//
//  Created by Filip Dabkowski on 09/04/2022.
//

import Foundation

struct SubmitAction: Encodable, Equatable {
    static func == (lhs: SubmitAction, rhs: SubmitAction) -> Bool {
        return lhs.event == rhs.event && lhs.message == rhs.message && lhs.action == rhs.action
    }
    
    var event: String
    var action: MoveAction
    var message: String
}

struct ReceiveAction: Decodable {
    var payload: ReceiveContent
}

struct ReceiveContent: Decodable {
    var type: String
    var action: MoveAction
    var message: String
    var event: String
}

struct MoveAction: Encodable, Decodable, Equatable {
    var player: Player
    var column: Int
}
