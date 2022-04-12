//
//  Home.swift
//  Connect4
//
//  Created by Filip Dabkowski on 28/03/2022.
//

import SwiftUI

struct Home: View {
    
    @State var inGame: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BgColor").edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        NavigationLink(isActive: self.$inGame) {
                            GameView(isActive: self.$inGame)
                        } label: {
                            VStack {
                                Circle()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(Color.blue)
                                    .padding(.bottom, 15)
                                
                                Text("Play Online")
                                    .fontWeight(.semibold)
                            }
                            .frame(width: getRect().width * 0.4, height: getRect().width * 0.5)
                            .background(Color("BgColor"))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 5, y: 5)
                            .foregroundColor(.white)
                        }
                    }
                }
            }
            .navigationBarTitle("Boards")
        }
        .navigationViewStyle(.stack)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Home()
                .environmentObject(GameState())
                .previewInterfaceOrientation(.portrait)
            
//            Home()
//                .environmentObject(GameState())
//                .previewInterfaceOrientation(.landscapeLeft)
        }
    }
}

extension View {
    func getRect() -> CGRect {
        #if os(iOS)
        return UIScreen.main.bounds
        #else
        return NSScreen.main!.visibleFrame
        #endif
    }
    
    func isMacOS() -> Bool {
        #if os(iOS)
        return false
        #else
        return true
        #endif
    }
}

struct PlayerNameTag: View {
    
    @EnvironmentObject var gameState: GameState
    
    let playerNum: Int
    let playerColor: String
    let playerName: String
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("CoinEmpty"))
                
                Text(String(gameState.playersWins[playerNum] ?? 0))
                    .font(.title2)
                    .foregroundColor(Color.white)
            }
            .padding(.trailing)
            
            Text(playerName)
                .font(.title2)
                .foregroundColor(Color.white)
        }
        .frame(maxWidth: 170, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(gameState.getPPColor(playerNum: playerNum))
        .cornerRadius(15)
    }
}
