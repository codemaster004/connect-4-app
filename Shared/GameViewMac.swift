//
//  GameViewMac.swift
//  Connect4 (macOS)
//
//  Created by Filip Dabkowski on 08/04/2022.
//

import SwiftUI

struct GameView: View {
    
    @EnvironmentObject var gameState: GameState
    
    @State var difficulty: Float = 5
    @State var useAi: Bool = false
    
    var body: some View {
        HStack {
            if gameState.boardReady() {
                sideBar()
                Divider()
                
                BoardView()
            }
        }
        .frame(minWidth: 1000, idealWidth: getRect().width / 1.5, idealHeight: getRect().height - 180, alignment: .leading)
        .background(Color("BgColor").ignoresSafeArea())
        .onAppear() {
            gameState.resetBoard()
            gameState.playingPlayer = 1
            gameState.players = ["Player 1", "Player 2"]
            gameState.playersWins = [
                0: 0,
                1: 0,
            ]
        }
    }
    
    @ViewBuilder
    func sideBar() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Game Settings")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
                .foregroundColor(Color.init(red: 0.8, green: 0.8, blue: 0.8))
            
            HStack {
                Text("Use AI")
                Spacer()
                Toggle(isOn: self.$useAi) {
                }
            }
            
            VStack(spacing: 0) {
                HStack {
                    Text("Difficulty")
                    Spacer()
                    Text("\(Int(self.difficulty.rounded()))")
                        .foregroundColor(Color("AccentColor"))
                }
                .opacity(self.useAi ? 1 : 0.2)
                
                Slider(value: self.$difficulty, in: 1...13)
                    .disabled(!self.useAi)
            }
            
            Text("Game State")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
                .foregroundColor(Color.init(red: 0.8, green: 0.8, blue: 0.8))
            
            PlayerNameTag(playerNum: 0, playerColor: "Coin1")
            
            PlayerNameTag(playerNum: 1, playerColor: "Coin2")
            
            Spacer()
            
            HStack {
                Button {
                    gameState.resetBoard()
                } label: {
                    Text("Reset")
                }

            }
        }
        .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
        .foregroundColor(Color.init(red: 87, green: 88, blue: 95))
        .tint(Color("AccentColor"))
        .padding()
    }
}

struct GameViewMac_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(GameState())
    }
}
