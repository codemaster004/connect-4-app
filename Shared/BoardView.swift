//
//  BoardView.swift
//  Connect4
//
//  Created by Filip Dabkowski on 08/04/2022.
//

import SwiftUI

struct BoardView: View {
    
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var roomState: RoomState
    @EnvironmentObject var game: GameSocket
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(0..<7) { nColumn in
                        Column(colNum: nColumn, onTap: {
//                            handleColumnChange(nColumn: Int(nColumn))
//                            playerNo, columnNo
//                            game.send()
                            
//                            game.sendPlayerMove(player: gameState.playingPlayer, columnNo: nColumn)
                        })
                    }
                    Spacer()
                }
                .padding(10)
            }
            
            if gameState.won {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        
                        Text("Game Won!")
                            .font(.title)
                            .bold()
                        
                        Text("By: ME")
                        
                        Spacer()
                    }
                    Spacer()
                }
                .background(Color("BgColor").opacity(0.8))
            }
        }
        .onDisappear() { game.disconnect() }
        .onChange(of: game.playerMove) { actionTaken in
            if actionTaken != nil {
//                gameState.playingPlayer = actionTaken?.player.number ?? 0
//                handleColumnChange(nColumn: actionTaken?.column ?? 0)
            }
        }
    }
    
    private func handleColumnChange(nColumn: Int) {
        for i in 0..<gameState.board[nColumn].count {
            if gameState.board[nColumn][i] == 0 {
                withAnimation {
                    gameState.updateBoard(x: nColumn, y: i)
                }
                
                let gameWon = self.gameState.checkForWinners(new_x: nColumn, new_y: i)
                gameState.won = gameWon
                
                if gameWon {
                    gameState.updateWins()
                } else {
                    withAnimation {
                        gameState.changePP()
                    }
                }
                
                break
            }
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
            .environmentObject(GameState())
    }
}

struct Column: View {
    
    @EnvironmentObject var gameState: GameState
    
    @State var currentColor = Color("BgColor")
    
    var colNum: Int
    var changingCoinN: Int!
    
    let onTap: () -> ()
    
    let playerColors = ["CoinEmpty", "Coin1", "Coin2"]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(maxHeight: .infinity)
            
            ForEach(0 ..< 7) { i in
                Circle()
                    .foregroundColor(Color(playerColors[gameState.board[colNum][6 - i]]))
                    .aspectRatio(contentMode: .fit)
                    .frame(minHeight: 50)
                    .padding(4)
            }
            Spacer()
                .frame(maxHeight: .infinity)
        }
        .padding(isMacOS() ? 8 : 0)
        .background(currentColor)
        .cornerRadius(50)
        .onHover { hovering in
            if hovering {
                self.currentColor = Color.init(red: 36 / 255, green: 38 / 255, blue: 44 / 255)
            } else {
                self.currentColor = Color("BgColor")
            }
        }
        .onTapGesture {
            gameState.playedColumn = self.colNum
            self.onTap()
        }
    }
}
