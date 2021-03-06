//
//  GameState.swift
//  Connect4
//
//  Created by Filip Dabkowski on 08/04/2022.
//

import SwiftUI

class GameState: ObservableObject {
    @Published var board: Array<Array<Int>>!
    @Published var players: Array<Player>! = []
    @Published var playingPlayer: Player!
    @Published var playersWins: Dictionary<String, Int>! = [:]
    @Published var won: Bool!
    @Published var playedColumn: Int!
    
    func changePP() {
//        self.playingPlayer.number = self.playingPlayer.number == 1 ? 2 : 1
    }
    
    func isPP(playerNum: Int) -> Bool {
        return self.playingPlayer.number == playerNum + 1
    }
    
    func getPPColor(player: Player) -> Color {
        return player == self.playingPlayer ? Color(player.colorName) : Color("BgColor")
    }
    
    func updateBoard(x: Int, y: Int) {
        self.board[x][y] = self.playingPlayer.number
    }
    
    func resetBoard() {
        self.board = [
            [0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0]
        ]
        self.won = false
//        self.playingPlayer = Int.random(in: 1...2)
    }
    
    func boardReady() -> Bool {
        return self.board != nil && self.players != nil && self.playersWins != nil && self.won != nil
    }
    
    func updateWins() {
//        if self.playersWins != nil && self.playersWins[self.playingPlayer.number - 1] != nil {
//            self.playersWins[self.playingPlayer.number - 1]! += 1
//        } else {
//            self.playersWins[self.playingPlayer.number - 1] = 1
//        }
    }
}

extension GameState {
    func checkForWinners(new_x: Int, new_y: Int) -> Bool {
//        Diagonal /
        var axis: [Int] = []
        var b = new_y - new_x
        for i in b..<7 {
            if i >= 0 && i < 7 && i - b < 7 {
                axis.append(self.board[i - b][i] )
            }
        }
        if self.checkAxis(axis: axis) {
            return true
        }
        
//        Diagonal \
        axis = []
        b = new_y + new_x
        for i in (0...b).reversed() {
            if i >= 0 && i < 7 && b - i < 7 {
                axis.append(self.board[b - i][i] )
            }
        }
        if self.checkAxis(axis: axis) {
            return true
        }
        
//        Horizontal -
        axis = []
        for i in 0..<7 {
            axis.append(self.board[i][new_y] )
        }
        if self.checkAxis(axis: axis) {
            return true
        }

//        Vertical |
        axis = []
        for i in 0..<7 {
            axis.append(self.board[new_x][i] )
        }
        if self.checkAxis(axis: axis) {
            return true
        }
        
        return false
    }
    
    func checkAxis(axis: Array<Int>) -> Bool {
        var count = 0
        var previous = axis.first ?? 0
        for player in axis {
            if player != 0 && previous == player {
                count += 1
            } else {
                count = 1
            }
            previous = player
            if count >= 4 {
                return true
            }
        }
        return false
    }
}
